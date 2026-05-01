package cli

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sort"

	"github.com/spf13/cobra"
)

var logCmd = &cobra.Command{
	Use:   "log",
	Short: "Show the most recent rclone bisync log",
	RunE: func(cmd *cobra.Command, args []string) error {
		home, err := os.UserHomeDir()
		if err != nil {
			return err
		}
		dir := filepath.Join(home, "Library", "Caches", "rclone", "bisync")
		entries, err := os.ReadDir(dir)
		if err != nil {
			return fmt.Errorf("no bisync log dir: %s", dir)
		}
		var logs []os.FileInfo
		for _, e := range entries {
			if filepath.Ext(e.Name()) != ".log" {
				continue
			}
			info, err := e.Info()
			if err != nil {
				continue
			}
			logs = append(logs, info)
		}
		if len(logs) == 0 {
			return fmt.Errorf("no .log files in %s", dir)
		}
		sort.Slice(logs, func(i, j int) bool {
			return logs[i].ModTime().After(logs[j].ModTime())
		})
		latest := filepath.Join(dir, logs[0].Name())
		fmt.Printf("# %s\n", latest)
		f, err := os.Open(latest)
		if err != nil {
			return err
		}
		defer f.Close()
		_, err = io.Copy(os.Stdout, f)
		return err
	},
}

func init() {
	rootCmd.AddCommand(logCmd)
}
