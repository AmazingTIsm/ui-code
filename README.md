# Plex frontends

`frontends/aether.lua` (default), `frontends/native.lua` and `frontends/zolar.lua` are executable frontend libraries. Each accepts the Plex context through `...` and returns the common library table.

Maintained sources live in the Plex script repository under `src/ui/`. The copies in `src/` record the source used for this release. Export with `python .tools/export_frontends.py <ui-code-checkout>` from the script repository, compile the frontend files, then commit and push this checkout. Pin that commit in `src/ui/frontend_dispatcher.lua` before rebuilding Plex.

This repository contains UI code only. Never upload tokens or executor data.
