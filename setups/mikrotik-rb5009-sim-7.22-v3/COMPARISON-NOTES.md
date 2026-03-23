# Comparison Notes: v3 vs v2

## What improved in v3

1. Trust-zone separation is explicit and security-driven

- v2 used a shared trusted VLAN for both wired and Wi-Fi.
- v3 splits trusted wired (VLAN20) and trusted Wi-Fi (VLAN25), matching the operator security goal.

2. Backup protection is modeled directly

- v3 introduces VLAN60 Backup/Storage with explicit deny from Wi-Fi and non-admin segments.
- v3 adds an allowlist model for approved wired endpoints to access backup assets.

3. Services segmentation is clearer

- v3 adds VLAN70 Printers/Services to reduce lateral movement from user segments.
- Media/streaming endpoints are isolated in VLAN40 instead of broad trusted VLAN.

4. Policy validation is more concrete

- Acceptance checks now include Wi-Fi-to-backup deny and wired allowlist verification.
- This directly tests the user's stated security intent.

## Remaining gaps and caveats

1. AP capability remains decisive

- If the ASUS AP cannot trunk/tag multiple VLANs, Wi-Fi segmentation must use fallback design.

2. Backup allowlist still needs concrete host list

- `backup-approved-wired` requires finalized IP/MAC-to-IP mapping for permitted VLAN20 devices.

3. Ops destinations remain unresolved

- Remote syslog endpoint, backup destination path, and alert channel are still TBD.

## Recommended next actions

1. Finalize backup allowlist values (for example Mac Studio static lease/IP).
2. Confirm AP trunk capability with a practical test; choose fallback if not supported.
3. Generate/refresh staged `.rsc` set from this v3 model and run a lab validation checklist.
