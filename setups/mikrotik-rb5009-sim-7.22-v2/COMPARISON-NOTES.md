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

## Remaining Prompt Gaps Exposed By v2

1. Endpoint placement still benefits from a dedicated matrix

- The prompt still allows ambiguity around whether Mac Studio and Rodecaster belong in VLAN 10 or VLAN 20.
- A required endpoint-to-VLAN mapping table would reduce this.

2. AP capability confirmation is still too soft

- The prompt asks for SSID-to-VLAN mapping, but should force a stronger decision when AP VLAN capability is unknown:
  - trunk-capable and confirmed
  - uncertain, design fallback required
  - not capable, access-only fallback required

3. Voice design still needs a stronger branch

- If 3CX is cloud-hosted vs on-prem, the prompt should branch more explicitly.
- Voice VLAN policy and QoS are meaningfully different once host location is known.

4. Monitoring/backups remain structurally under-specified

- The prompt is honest about missing backup targets and alerts, but could require a deployment blocker label if remote ops are mandatory.

## Recommended Next Prompt Refactors

1. Add required endpoint placement table
2. Add AP capability decision states instead of a single free-text answer
3. Add explicit 3CX hosting branch logic
4. Add a "deployment blocker" tag for unresolved operational dependencies like syslog and backup destination
