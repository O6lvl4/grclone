package cli

import (
	"errors"
	"os"

	"github.com/spf13/cobra"
)

const (
	envLocal  = "GRCLONE_LOCAL"
	envRemote = "GRCLONE_REMOTE"
)

var (
	flagLocal  string
	flagRemote string
)

var rootCmd = &cobra.Command{
	Use:   "grclone",
	Short: "git-style CLI for rclone",
	Long: `grclone wraps rclone with git-flavored verbs.

  status / fetch / diff   – inspect divergence between local and remote
  pull / push             – one-way mirror (overwrites destination)
  sync                    – two-way sync via rclone bisync
  resync                  – rebuild bisync baseline (remote wins)

Configure paths via flags or env:
  --local / GRCLONE_LOCAL    (e.g. ~/Downloads/foo)
  --remote / GRCLONE_REMOTE  (e.g. gdrive:)
`,
	SilenceUsage: true,
}

// Execute is the program entry point.
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}

func init() {
	rootCmd.PersistentFlags().StringVarP(&flagLocal, "local", "l", "", "local path (overrides $GRCLONE_LOCAL)")
	rootCmd.PersistentFlags().StringVarP(&flagRemote, "remote", "r", "", "rclone remote (overrides $GRCLONE_REMOTE)")
}

func resolvePaths() (local, remote string, err error) {
	local = firstNonEmpty(flagLocal, os.Getenv(envLocal))
	remote = firstNonEmpty(flagRemote, os.Getenv(envRemote))
	if local == "" || remote == "" {
		return "", "", errors.New("both --local and --remote are required (or set $GRCLONE_LOCAL / $GRCLONE_REMOTE)")
	}
	return local, remote, nil
}

func firstNonEmpty(values ...string) string {
	for _, v := range values {
		if v != "" {
			return v
		}
	}
	return ""
}
