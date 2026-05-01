# experimental / bash

Bash + Makefile prototype that preceded the Go rewrite. Kept here as a
reference for the verbs and the receipts-management ideas not yet ported.

## Use (rclone wrapper)

```sh
cd experimental/bash
make help
make status
make pull
make push
make sync
make resync
```

Override paths via env or `make` variables:

```sh
make status LOCAL=~/Downloads/foo REMOTE=gdrive:
```

## Use (receipts — prototype only)

```sh
bash scripts/receipts-lint.sh ~/Downloads/経理/領収書
bash scripts/receipts-rename-plan.sh
# review /tmp/receipts-rename-plan.tsv
# applying is not yet implemented in this prototype
```

`scripts/vendors.tsv` is the vendor-name normalization map (longest pattern
first; `#`-prefixed lines are comments).
