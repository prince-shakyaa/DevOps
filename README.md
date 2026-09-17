<!-- Rewritten for originality -->
# Topic: DevOps Coursework

Hands-on notes and code for the DevOps module, one folder per topic. Each folder has its own
README with the commands that were run, the output, and screenshots from the run.

| Folder | Topic |
|---|---|
| `Linux Fundamentals/` | Hard vs soft links, `useradd` vs `adduser`, `journalctl`, command cheat sheet |
| `Shell Scripting/` | `sysinfo.sh`: variables, user input, `mkdir`/`modify`, output redirection |
| `Networking Fundamentals/` | `ping`, `ip`, `ss`, `curl`, `wget`, `nslookup`, `traceroute`, `hostname` |
| `Git and Github/` | `git commit -a` vs `-m`, `git cherry-pick` |
| `Docker Fundamentals/` | Half a dozen basic container examples: Node.js, Python, Java, Apache, React, Nginx |
| `DockerFiles and Images/` | Optimized multi-stage Go compilation, 365 MB toolchain to a 7 MB image |
| `Docker Networks/` | Containers utilizing multiple networks, host network, bind mounts, overlay networks |
| `Kubernetes Fundamentals/` | Cluster components, system Pods, node capacity, namespace creation |
| `Kubernetes Workloads/` | Deployment strategies, ReplicaSets, rolling updates, rollbacks, DaemonSets |
| `Kubernetes Services/` | Service networking, ClusterIP, NodePort, LoadBalancer, ExternalName, Headless |
| `Kubernetes Ingress and Config/` | Path and host routing via NGINX Ingress, ConfigMaps, Secrets |

Environment: macOS with Docker Desktop; Linux-only commands were run in Ubuntu 24.04 containers. The Kubernetes exercises are executed on a local single-node Minikube cluster utilizing the Docker driver.
