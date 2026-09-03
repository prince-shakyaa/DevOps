# DevOps Practical Notes

This repository contains all my practical work and notes for the DevOps module. Each topic is organized into its own directory. Inside each directory, you'll find a detailed README file containing the executed commands, their outputs, and mock terminal screenshots showing the execution.

| Directory | Core Topics Covered |
|---|---|
| `Linux Fundamentals/` | Link types (hard/soft), user management (`useradd`/`adduser`), system logs with `journalctl`, and a useful commands cheat sheet. |
| `Shell Scripting/` | The `sysinfo.sh` script demonstrating variables, user inputs, file creation (`mkdir`/`touch`), and redirecting outputs. |
| `Networking Fundamentals/` | Network troubleshooting and exploration using `ping`, `ip`, `ss`, `curl`, `wget`, `nslookup`, `traceroute`, and `hostname`. |
| `Git and Github/` | Version control basics including `git commit -a` vs `-m` and cherry-picking commits. |
| `Docker Fundamentals/` | Building and running six basic containers: Node.js, Python, Java, Apache, React, and Nginx. |
| `DockerFiles and Images/` | Demonstrating multi-stage builds in Go to shrink a 365MB toolchain down to a 7MB production image. |
| `Docker Networks/` | Exploring container networking with multi-network setups, host networking, overlay networks, and bind mounts. |

**System Details**: The practicals were executed on a macOS system running Docker Desktop. Commands specific to Linux were executed inside Ubuntu 24.04 Docker containers.
