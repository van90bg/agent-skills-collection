#!/usr/bin/env bash
# audit-pins.sh — verify every hard-coded model/provider pin the orchestration
# pipeline depends on, against the providers that are actually serving right now.
#
# Checks:
#   1. Paseo daemon.agentProfiles  -> provider enabled + model id exists + thinking level supported
#   2. Pi agent files (~/.pi/agent/agents/*.md) -> model id exists
#   3. Magpie routing groups used by those pins -> id exists, levels cover the pins
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

problems: list[str] = []
notes: list[str] = []


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
for p in problems:
    print(f"FAIL  {p}")
if problems:
    print(f"\n{len(problems)} problem(s) — delegation will fail until they are fixed.")
    sys.exit(1)
print(f"OK    {len(profiles)} paseo profiles, {len(agent_files)} pi agents, {len(cat)} router models — all pins resolve.")
PY
