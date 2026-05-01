# grclone

A thin git-flavored CLI on top of [rclone](https://rclone.org/).

If you already think in `git fetch / pull / push`, `grclone` lets you talk to
an rclone remote with the same vocabulary.

> Not to be confused with [`gclone`](https://github.com/donwa/gclone), which is
> an unrelated rclone fork specialized for Google Drive.

## Why

`rclone` is excellent but its CLI surface (`copy`, `sync`, `bisync`, `check`,
flag combinations…) is broad. For day-to-day "keep these two locations in
sync" workflows, you usually want a handful of high-level verbs:

| grclone           | underlying rclone                          |
| ----------------- | ------------------------------------------ |
| `grclone status`  | `rclone check` (categorized read-only)     |
| `grclone fetch`   | alias of `status`                          |
| `grclone diff`    | `rclone check --combined -`                |
| `grclone pull`    | `rclone sync REMOTE LOCAL`                 |
| `grclone push`    | `rclone sync LOCAL REMOTE`                 |
| `grclone sync`    | `rclone bisync LOCAL REMOTE`               |
| `grclone resync`  | `rclone bisync ... --resync --resync-mode path2` |
| `grclone log`     | tail of latest bisync log                  |

All commands accept `-n / --dry-run` where applicable.

## Install

Requires Go 1.22+ and an existing `rclone` on `$PATH`.

```sh
go install github.com/O6lvl4/grclone/cmd/grclone@latest
```

Or build from source:

```sh
git clone https://github.com/O6lvl4/grclone
cd grclone
go build -o grclone ./cmd/grclone
```

## Configure

`grclone` keeps no state of its own; it just shells out to `rclone`. You point
it at one local path and one rclone remote.

```sh
export GRCLONE_LOCAL=$HOME/Downloads/myfolder
export GRCLONE_REMOTE=gdrive:somefolder
```

Or pass per-invocation flags:

```sh
grclone status --local ~/Downloads/myfolder --remote gdrive:somefolder
```

The remote must already exist in your `rclone.conf` (run `rclone config`
once to set it up).

## Use

```sh
grclone status      # what's different?
grclone pull        # remote → local (mirror)
grclone push        # local → remote (mirror)
grclone sync        # bisync (two-way)
grclone resync      # rebuild bisync baseline (remote wins)
grclone log         # tail latest bisync log
```

First-time bisync setup:

```sh
grclone resync      # establishes the baseline; required once
grclone sync        # routine two-way sync afterwards
```

## Companion tools

- [`keiri`](https://github.com/O6lvl4/keiri) — bookkeeping document
  hygiene CLI (receipt naming lint / plan / apply, with invoices and
  more to come). Originally lived under `grclone receipts`; moved into
  its own CLI to keep `grclone` focused on the rclone wrapper.

## Roadmap

- [ ] Direct rclone library integration (drop the `exec` boundary)
- [ ] Homebrew tap
- [ ] GitHub Actions release pipeline

A bash-and-Makefile prototype of the sync verbs lives under
[`experimental/bash/`](experimental/bash) as the original reference
implementation. The Go CLI is the source of truth.

## License

MIT
