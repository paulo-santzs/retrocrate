# Contributing

Thanks for considering a contribution to RetroCrate.

## Scope

Please keep changes reproducible and focused on Linux hosts using Distrobox. Prefer packages from official distribution repositories. If a package is added or removed, update both manifests, the README package table, and the supported-scope notes.

## Before opening a change

- Explain the user problem and the host/distribution affected.
- Do not include ROMs, BIOS, firmware, game dumps, copyrighted artwork, credentials, or personal configuration.
- Keep the default setup non-root and non-destructive (`root=false`, `replace=false`).
- Do not add network install hooks or privileged host commands without a clear need and explicit documentation.
- Describe commands you ran and any environment-specific limitations.

## Pull requests

Small pull requests are easier to review. Include the manifest and documentation changes together, and call out package availability or GPU assumptions. This project is independent and does not accept copied code or documentation from other repositories.
