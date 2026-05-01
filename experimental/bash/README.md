# experimental / bash

Bash + Makefile prototype that preceded the Go rewrite. Kept here as a
reference for the verbs.

## Use

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
