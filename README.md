# Code AI Prompts

This repository contains a collection of prompts designed to assist developers in generating code using AI models. These prompts cover a wide range of programming languages and use cases, providing a valuable resource for developers looking to leverage AI for code generation.

## RouterOS Template Workflow

This repository also contains sanitized MikroTik RouterOS deployment templates and supporting operational documentation under `setups/mikrotik-rb5009/`.

These files are intended to stay safe for public version control by keeping placeholders instead of live secrets.

For production use:

- Keep real passwords, WireGuard keys, syslog targets, and local environment overlays in a private infrastructure repository.
- Use the staged pack in `setups/mikrotik-rb5009/` as the public template source.
- Sync sanitized templates into your private repo with:

```bash
make sync-private-dry-run
make sync-private
```

Useful references:

- `setups/mikrotik-rb5009/README.md`
- `setups/mikrotik-rb5009/OPS-CHEATSHEET.md`
- `setups/mikrotik-rb5009/PRIVATE-REPO-MIGRATION.md`

## Contributors

- [Wayne Gibson](https://github.com/waynegibson)
