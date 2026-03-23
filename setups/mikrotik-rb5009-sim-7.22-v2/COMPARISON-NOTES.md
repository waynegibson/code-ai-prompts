# Comparison Notes

## Improvements vs First Simulation

1. Correct hardware model handling

- This run uses the real RB5009 interface count.
- Invalid `ether9` and `ether10` references were eliminated.

2. Exact-version targeting is explicit

- This run is consistently targeted at RouterOS 7.22.
- It does not fall back to channel-only language.

3. Install-safety is surfaced

- Bootstrap management path, stage dependencies, and firewall ordering are now called out directly.
- The output explicitly distinguishes staged clean-start from idempotent config management.

4. Secret handling is cleaner

- Base scripts are treated as sanitized templates.
- Site-local values are expected in overlays/private handling.

5. Simulation honesty is better

- The result is framed as a deployable candidate pending validation, not an unquestioned final build.
- Remaining blockers are listed explicitly.

## Remaining Prompt Gaps Exposed By v2 (after operator clarifications)

1. Endpoint placement matrix should be mandatory, but operator choice is now known

- Decision captured: Mac Studio and Rodecaster Pro are both on VLAN 20.
- Prompt should still require a full endpoint-to-VLAN matrix every run.

2. AP capability confirmation still needs stronger enforcement

- Decision captured: ASUS AP capability is uncertain, fallback required.
- Prompt should force one of three states every run:
  - trunk-capable and confirmed
  - uncertain, design fallback required
  - not capable, access-only fallback required

3. Voice design branch is partially resolved

- Decision captured: 3CX is cloud-hosted.
- Prompt should still enforce explicit cloud vs on-prem branch logic in all runs.

4. Monitoring/backups are still partially under-specified

- Decision captured: unresolved ops dependencies are caveats only, not hard blockers.
- Cloud backup expectation should be clarified as indirect path (host/NAS sync to iCloud/Google Drive), not direct RouterOS upload.

## Recommended Next Prompt Refactors

1. Add required endpoint placement table (all key endpoints must be mapped)
2. Add AP capability decision states instead of a single free-text answer
3. Add explicit 3CX hosting branch logic
4. Add a "deployment blocker" tag plus caveat-mode option for unresolved ops dependencies
5. Add explicit backup target model options including indirect cloud backup path
