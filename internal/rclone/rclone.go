package rclone

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
)

// Run streams rclone output to the caller's stdout/stderr.
func Run(args ...string) error {
	cmd := exec.Command("rclone", args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	return cmd.Run()
}

// Capture runs rclone and returns combined output.
func Capture(args ...string) (string, error) {
	cmd := exec.Command("rclone", args...)
	var buf bytes.Buffer
	cmd.Stdout = &buf
	cmd.Stderr = &buf
	if err := cmd.Run(); err != nil {
		return buf.String(), fmt.Errorf("rclone %v: %w", args, err)
	}
	return buf.String(), nil
}
