# RB5009 Simulation v3

This folder contains a third-pass simulation generated after adopting Option B trust-zone segmentation (split trusted wired and trusted Wi-Fi) in the canonical requirements.

Purpose:

- validate security-first VLAN separation for small-business hardening
- test whether updated requirements remove previous ambiguity
- compare v3 behavior against v2 before lab execution

Files:

- `INPUT-SNAPSHOT.md`: condensed input set used for this run
- `SIMULATION-OUTPUT.md`: third-pass prompt-style simulation output
- `COMPARISON-NOTES.md`: key differences vs v2 and remaining actions

Status:

- exact-version targeted: RouterOS 7.22
- output intent: deployable candidate pending operator validation
- script safety target: staged clean-start only
- idempotency: not claimed
