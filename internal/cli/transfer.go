package cli

import (
	"github.com/O6lvl4/grclone/internal/rclone"
	"github.com/spf13/cobra"
)

var (
	flagDryRun bool
)

var pullCmd = &cobra.Command{
	Use:   "pull",
	Short: "remote → local (overwrites local; deletes extra files)",
	RunE: func(cmd *cobra.Command, args []string) error {
		local, remote, err := resolvePaths()
		if err != nil {
			return err
		}
		return rclone.Run(syncArgs(remote, local)...)
	},
}

var pushCmd = &cobra.Command{
	Use:   "push",
	Short: "local → remote (overwrites remote; deletes extra files)",
	RunE: func(cmd *cobra.Command, args []string) error {
		local, remote, err := resolvePaths()
		if err != nil {
			return err
		}
		return rclone.Run(syncArgs(local, remote)...)
	},
}

var syncCmd = &cobra.Command{
	Use:   "sync",
	Short: "two-way sync via rclone bisync",
	RunE: func(cmd *cobra.Command, args []string) error {
		local, remote, err := resolvePaths()
		if err != nil {
			return err
		}
		return rclone.Run(bisyncArgs(local, remote, false)...)
	},
}

var resyncCmd = &cobra.Command{
	Use:   "resync",
	Short: "rebuild bisync baseline (remote wins on conflict)",
	RunE: func(cmd *cobra.Command, args []string) error {
		local, remote, err := resolvePaths()
		if err != nil {
			return err
		}
		return rclone.Run(bisyncArgs(local, remote, true)...)
	},
}

func syncArgs(src, dst string) []string {
	a := []string{"sync", src, dst, "--progress"}
	if flagDryRun {
		a = append(a, "--dry-run")
	}
	return a
}

func bisyncArgs(local, remote string, resync bool) []string {
	a := []string{"bisync", local, remote, "--progress"}
	if resync {
		a = append(a, "--resync", "--resync-mode", "path2")
	}
	if flagDryRun {
		a = append(a, "--dry-run")
	}
	return a
}

func init() {
	for _, c := range []*cobra.Command{pullCmd, pushCmd, syncCmd, resyncCmd} {
		c.Flags().BoolVarP(&flagDryRun, "dry-run", "n", false, "preview without writing")
	}
	rootCmd.AddCommand(pullCmd, pushCmd, syncCmd, resyncCmd)
}
