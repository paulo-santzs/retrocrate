# Security policy

## Scope

RetroCrate describes and helps manage a Distrobox container. It is not a security sandbox and does not promise isolation from the host. Distrobox normally shares the user's home directory and integrates host devices and graphical/audio sessions.

## Reporting a concern

Please do not publish credentials, personal files, ROMs, BIOS, firmware, or exploit samples in an issue. Report the affected file, a concise impact description, and safe reproduction steps through a private GitHub security advisory when available; otherwise contact the repository owner through GitHub before public disclosure.

## Safe defaults

- Container is rootless (`root=false`).
- Existing containers are not replaced automatically (`replace=false`).
- Setup previews its generated command and requires `--apply` to create a container.
- Removal asks for the exact container name and never deletes host directories.
- No games, firmware, ROMs, or BIOS files are distributed.
