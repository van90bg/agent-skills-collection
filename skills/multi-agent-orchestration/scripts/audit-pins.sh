#!/usr/bin/env bash
# audit-pins.sh — verify every hard-coded model/provider pin the orchestration
# pipeline depends on, against the providers that are actually serving right now.
#
# Checks:
#   1. Paseo daemon.agentProfiles  -> provider enabled + model id exists + thinking level supported
#                                    + the model is the role's own routing group (group/<role-id>)
#   2. Pi agent files (~/.pi/agent/agents/*.md) -> same two checks
#   3. Cross-surface coverage      -> every profile id has a pi agent twin
#   4. --probe                     -> ask each group member what model it *really* serves
#                                     (an id can lie: autoclaw/zai_auto serves deepseek-vision-exp).
#                                     A deliberate exception is declared in
#                                     ~/.config/magpie/audit-pins.exceptions, one line per member:
#                                       group/se-coder autoclaw/zai_auto -> deepseek
#
# Usage:
#   audit-pins.sh                 structural checks only (fast, no tokens)
#   audit-pins.sh --probe         also probe the first 2 members of every role group
#   audit-pins.sh --probe-all     probe every member (costs one tiny request per member)
#
# Exit 0 = every pin resolves. Exit 1 = at least one pin is dead (delegation will 404).
# Run it after any model/provider change in the Paseo UI or the magpie router.

set -uo pipefail

python3 - "$@" <<'PY'
import glob
import json
import os
import re
import sys
import urllib.request

PI_DIR = os.environ.get("PI_CODING_AGENT_DIR", os.path.expanduser("~/.pi/agent"))
PASEO_CONFIG = os.environ.get("PASEO_CONFIG", os.path.expanduser("~/.paseo/config.json"))
MAGPIE_CONFIG = os.environ.get(
    "MAGPIE_CONFIG", os.path.expanduser("~/.config/magpie/providers.json")
)
ARGS = set(sys.argv[1:])
PROBE_ALL = "--probe-all" in ARGS
PROBE = PROBE_ALL or "--probe" in ARGS

problems: list[str] = []
notes: list[str] = []
warnings: list[str] = []


def load(path):
    try:
        with open(path, encoding="utf-8") as fh:
            return json.load(fh)
    except FileNotFoundError:
        problems.append(f"missing file: {path}")
        return {}


def router_catalogue():
    models_json = load(os.path.join(PI_DIR, "models.json"))
    providers = models_json.get("providers", {})
    magpie = providers.get("magpie")
    if not magpie:
        problems.append(f"{PI_DIR}/models.json has no 'magpie' provider — cannot resolve baseUrl")
        return {}
    base = magpie.get("baseUrl", "").rstrip("/")
    try:
        with urllib.request.urlopen(f"{base}/models", timeout=15) as resp:
            payload = json.load(resp)
    except Exception as exc:  # noqa: BLE001
        problems.append(f"cannot read {base}/models: {exc}")
        return {}
    cat = {}
    for m in payload.get("data", []):
        cat[m["id"]] = m
    return cat


def router_base():
    models_json = load(os.path.join(PI_DIR, "models.json"))
    magpie = models_json.get("providers", {}).get("magpie")
    return (magpie or {}).get("baseUrl", "").rstrip("/")


def norm(name: str) -> str:
    """Loose model identity: drop the vendor prefix and every separator."""
    s = name.strip().lower()
    if "/" in s:
        s = s.rsplit("/", 1)[1]
    for token in (":free", "-free", ":fast", ".", "_", "-", " "):
        s = s.replace(token, "")
    return s


def load_exceptions():
    """Deliberate 'this id serves that family' declarations.

    Line format:  <group id> <member id> -> <expected substring of the served model>
    Blank lines and lines starting with '#' are ignored.
    """
    paths = [
        os.path.expanduser("~/.config/magpie/audit-pins.exceptions"),
        os.path.join(os.path.dirname(os.path.abspath(__file__)), "audit-pins.exceptions"),
    ]
    rules = {}
    for path in paths:
        if not os.path.exists(path):
            continue
        for raw in open(path, encoding="utf-8"):
            line = raw.split("#", 1)[0].strip()
            if not line or "->" not in line:
                continue
            left, expected = line.split("->", 1)
            parts = left.split()
            if len(parts) < 2:
                continue
            gid, member = parts[0].removeprefix("group/"), parts[1]
            rules[(gid, member)] = expected.strip().lower()
    return rules


EXCEPTIONS = load_exceptions()


def probe_member(model: str):
    """Ask the router what this member actually serves. Returns (served, error)."""
    base = router_base()
    if not base:
        return None, "no magpie baseUrl in models.json"
    body = json.dumps(
        {
            "model": model,
            "max_tokens": 8,
            "messages": [{"role": "user", "content": "hi"}],
        }
    ).encode()
    req = urllib.request.Request(
        f"{base}/chat/completions",
        data=body,
        headers={"Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=90) as resp:
            payload = json.load(resp)
    except Exception as exc:  # noqa: BLE001
        msg = str(exc)
        try:  # HTTPError carries the router's JSON body: useful for quota messages
            msg = exc.read().decode("utf-8", "replace")[:160]  # type: ignore[attr-defined]
        except Exception:  # noqa: BLE001
            pass
        return None, msg
    if payload.get("error"):
        return None, str(payload["error"])[:160]
    return payload.get("model"), None


def probe_groups(cat):
    """Compare each role group's member ids with the model the router really served."""
    conf = load(MAGPIE_CONFIG)
    groups = {g.get("id"): g for g in (conf.get("groups") or []) if isinstance(g, dict)}
    role_groups = [gid for gid in groups if f"group/{gid}" in cat]
    if not role_groups:
        problems.append(f"{MAGPIE_CONFIG}: no routing groups found to probe")
        return
    for gid in sorted(role_groups):
        members = groups[gid].get("members") or []
        plain = [
            m
            for m in members
            if isinstance(m, str) and not m.startswith("group/") and "*" not in m
        ]
        limit = len(plain) if PROBE_ALL else min(2, len(plain))
        for idx, member in enumerate(plain[:limit]):
            served, err = probe_member(member)
            if err:
                position = "primary" if idx == 0 else f"member #{idx + 1}"
                warnings.append(f"group/{gid} {position} '{member}' is not answering: {err.strip()[:140]}")
                if idx == 0:
                    warnings.append(
                        f"group/{gid}: a dead primary costs a wasted round-trip on every call — move "
                        f"'{member}' to the end of the list"
                    )
                continue
            expected = EXCEPTIONS.get((gid, member))
            if expected:
                if expected not in (served or "").lower():
                    problems.append(
                        f"group/{gid} member '{member}' is declared to serve a '{expected}' model but "
                        f"actually serves '{served}' — the exception no longer holds"
                    )
                continue
            if norm(served or "") != norm(member) and norm(served or "") not in norm(member) \
                    and norm(member) not in norm(served or ""):
                problems.append(
                    f"group/{gid} member '{member}' actually serves '{served}' — the id lies, so the "
                    f"group's family policy is not what it says. Declare it in "
                    f"~/.config/magpie/audit-pins.exceptions if that is deliberate"
                )


def check_model(cat, model_id, where, thinking=None):
    if model_id not in cat:
        hint = ""
        lowered = model_id.lower().split("/")[-1]
        close = [i for i in cat if lowered in i.lower() or i.lower().split("/")[-1] in lowered]
        if close:
            hint = f" — did you mean {', '.join(sorted(close)[:3])}?"
        problems.append(f"{where}: model '{model_id}' is not served by the router{hint}")
        return
    if thinking:
        levels = cat[model_id].get("reasoning_levels") or [
            lv.get("effort") for lv in cat[model_id].get("supported_reasoning_levels", [])
        ]
        if levels and thinking not in levels:
            problems.append(
                f"{where}: thinking level '{thinking}' unsupported by '{model_id}' "
                f"(levels: {', '.join(str(x) for x in levels)})"
            )


cat = router_catalogue()
if not cat:
    print("\n".join(problems) or "router unreachable")
    sys.exit(1)
if PROBE:
    probe_groups(cat)

# 1. Paseo profiles
paseo = load(PASEO_CONFIG)
daemon = paseo.get("daemon", {})
providers_enabled = {
    name: cfg.get("enabled", True)
    for name, cfg in (paseo.get("agents", {}).get("providers") or {}).items()
}
profiles = daemon.get("agentProfiles") or []
if not profiles:
    problems.append(f"{PASEO_CONFIG}: no daemon.agentProfiles — the skill's role ids cannot be launched")
for p in profiles:
    pid = p.get("id", "?")
    provider = p.get("provider")
    model = p.get("model")
    where = f"paseo profile '{pid}'"
    if provider and providers_enabled.get(provider) is False:
        problems.append(f"{where}: provider '{provider}' is disabled in the Paseo config")
    if not model:
        notes.append(f"{where}: no model pinned — the child inherits the caller's model")
        continue
    # pi's magpie models are addressed as magpie/<router id>; anything else is not ours to verify
    if not model.startswith("magpie/"):
        notes.append(
            f"{where}: provider '{provider}' model '{model}' — not a magpie pin, skipped"
        )
        continue
    router_id = model.split("/", 1)[1]
    check_model(cat, router_id, where, p.get("thinkingOptionId"))
    # convention: a role's model is its own routing group, so policy lives in one place
    expected = f"group/{pid}"
    if router_id != expected:
        problems.append(
            f"{where}: model '{router_id}' should be '{expected}' "
            f"(one routing group per role id — see SKILL.md §5)"
        )

# 2. Pi agent files
agent_files = sorted(glob.glob(os.path.join(PI_DIR, "agents", "*.md")))
if not agent_files:
    problems.append(f"{PI_DIR}/agents has no *.md agent files — the subagent tool has nothing to launch")
for path in agent_files:
    text = open(path, encoding="utf-8").read()
    m = re.search(r"^model:\s*(\S+)\s*$", text, re.M)
    name = re.search(r"^name:\s*(\S+)\s*$", text, re.M)
    label = name.group(1) if name else os.path.basename(path)
    if not m:
        notes.append(f"pi agent '{label}': no model pin — inherits the caller's model")
        continue
    model = m.group(1)
    if not model.startswith("magpie/"):
        notes.append(f"pi agent '{label}': model '{model}' — not a magpie pin, skipped")
        continue
    router_id = model.split("/", 1)[1]
    check_model(cat, router_id, f"pi agent '{label}'")
    expected = f"group/{label}"
    if router_id != expected:
        problems.append(
            f"pi agent '{label}': model '{router_id}' should be '{expected}' "
            f"(one routing group per role id — see SKILL.md §5)"
        )

# 3. Cross-surface id coverage: every Paseo profile should have a pi agent twin
pi_names = {
    re.search(r"^name:\s*(\S+)\s*$", open(f, encoding="utf-8").read(), re.M).group(1)
    for f in agent_files
    if re.search(r"^name:\s*(\S+)\s*$", open(f, encoding="utf-8").read(), re.M)
}
for p in profiles:
    pid = p.get("id")
    if pid and pid not in pi_names and pid != "lead-coordinator":
        problems.append(
            f"paseo profile '{pid}' has no pi agent twin — the subagent fallback cannot launch it"
        )

for n in notes:
    print(f"NOTE  {n}")
for w in warnings:
    print(f"WARN  {w}")
for p in problems:
    print(f"FAIL  {p}")
if problems:
    print(f"\n{len(problems)} problem(s) — delegation will fail or route to the wrong family.")
    sys.exit(1)
print(
    f"OK    {len(profiles)} paseo profiles, {len(agent_files)} pi agents, {len(cat)} router models"
    + (f", {len(warnings)} warning(s)" if warnings else "")
    + " — all pins resolve."
)
PY
