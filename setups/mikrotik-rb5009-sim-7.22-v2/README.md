# RB5009 Simulation v2

This folder contains a second-pass simulation generated using the hardened prompt in `setups/setup-mikrotik-router.md` together with the canonical requirements form in `setups/mikrotik-rb5009-golden-requirements-7.22.md`.

Purpose:

- test the updated prompt behavior
- compare this output against the earlier exploratory simulation
- identify any remaining prompt gaps before treating future output as deployable

Files:

- `INPUT-SNAPSHOT.md`: condensed input set used for this run
- `SIMULATION-OUTPUT.md`: second-pass prompt-style simulation output
- `COMPARISON-NOTES.md`: key differences vs the earlier simulation and remaining prompt refinements

Status:

- exact-version targeted: RouterOS 7.22
- output intent: deployable candidate pending operator validation
- script safety target: staged clean-start only
- idempotency: not claimed
