# Core Linux Concepts

This section documents fundamental Linux operations executed on an Ubuntu environment.

## Hard vs. Symbolic Links

In Linux, filenames point to an inode which stores the actual data. Links provide alternative names for this data.

- **Hard Links**: Points directly to the inode. Data remains as long as at least one hard link exists. Cannot link directories or span filesystems.
- **Symbolic Links (Soft Links)**: A distinct file containing a path reference. If the original is deleted, the link breaks. Can span filesystems and link directories.

### Commands Used
`ln target linkname` (Hard)
`ln -s target linkname` (Soft)
`ls -li` (Check inode)

## User Management: `useradd` vs. `adduser`

- `useradd`: A low-level utility that requires explicit flags for home directories (`-m`) and shell assignments (`-s`). Best for automation.
- `adduser`: An interactive, higher-level script that automatically configures the home directory, shell, and prompts for passwords. Best for manual setups.

## System Logs: `journalctl`

Use `journalctl` to view `systemd` logs efficiently.
- `journalctl -b`: Logs for current boot.
- `journalctl -f`: Follow log output.
- `journalctl -u service_name`: Logs for a specific unit.

## Cheat Sheet

- **Navigation**: `pwd`, `ls -la`, `cd`, `find`
- **File Ops**: `mkdir`, `touch`, `cp`, `mv`, `rm`
- **Viewing**: `cat`, `less`, `grep`
- **Permissions**: `chmod`, `chown`
- **Processes**: `ps`, `top`, `kill`
- **Network**: `ip a`, `ping`, `curl`
