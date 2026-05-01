package cli

import (
	"fmt"

	"github.com/O6lvl4/grclone/internal/rclone"
	"github.com/spf13/cobra"
)

var statusCmd = &cobra.Command{
	Use:     "status",
	Aliases: []string{"st"},
	Short:   "Show divergence summary (read-only)",
	RunE: func(cmd *cobra.Command, args []string) error {
		local, remote, err := resolvePaths()
		if err != nil {
			return err
		}
		section("remote にしかない (pull で取得)")
		_ = rclone.Run("check", remote, local, "--missing-on-dst", "-")

		section("local にしかない (push で送出)")
		_ = rclone.Run("check", local, remote, "--missing-on-dst", "-")

		section("内容が違うファイル")
		_ = rclone.Run("check", local, remote, "--differ", "-")
		return nil
	},
}

var fetchCmd = &cobra.Command{
	Use:   "fetch",
	Short: "Alias of `status` (read-only inspection)",
	RunE:  statusCmd.RunE,
}

var diffCmd = &cobra.Command{
	Use:   "diff",
	Short: "Show full path-by-path comparison",
	RunE: func(cmd *cobra.Command, args []string) error {
		local, remote, err := resolvePaths()
		if err != nil {
			return err
		}
		return rclone.Run("check", local, remote, "--combined", "-")
	},
}

func section(title string) {
	fmt.Printf("\n── %s ──\n", title)
}

func init() {
	rootCmd.AddCommand(statusCmd, fetchCmd, diffCmd)
}
