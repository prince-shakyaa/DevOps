<!-- Rewritten for originality -->
# Topic: DevOps Coursework

Hands-on notes and code for the DevOps module, one folder per topic. Each folder has its own
README with the commands that were run, the output, and screenshots from the run.

| Folder | Topic |
|---|---|
| `Linux Fundamentals/` | Hard vs soft links, `useradd` vs `adduser`, `journalctl`, command cheat sheet |
| `Shell Scripting/` | `sysinfo.sh`: variables, user input, `mkdir`/`touch`, output redirection |
| `Networking Fundamentals/` | `ping`, `ip`, `ss`, `curl`, `wget`, `nslookup`, `traceroute`, `hostname` |
| `Git and Github/` | `git commit -a` vs `-m`, `git cherry-pick` |
| `Docker Fundamentals/` | Half a dozen basic container examples: Node.js, Python, Java, Apache, React, Nginx |
| `DockerFiles and Images/` | Optimized multi-stage Go compilation, 365 MB toolchain to a 7 MB image |
| `Docker Networks/` | Containers utilizing multiple networks, host network, bind mounts, overlay networks |
| `Kubernetes Fundamentals/` | Cluster components, system Pods, node capacity, namespace creation |
| `Kubernetes Workloads/` | Deployment strategies, ReplicaSets, rolling updates, rollbacks, DaemonSets |
| `Kubernetes Services/` | Service networking, ClusterIP, NodePort, LoadBalancer, ExternalName, Headless |
| `Kubernetes Ingress and Config/` | Path and host routing via NGINX Ingress, ConfigMaps, Secrets |
| `Kubernetes Ingress and Config Advanced/` | ConfigMap/Secret mounts and live updates, Ingress with TLS, five troubleshooting scenarios |
| `Kubernetes Storage HPA and Probes/` | emptyDir, hostPath, PV/PVC, dynamic provisioning, HPA, liveness/readiness/startup probes |
| `Kubernetes Troubleshooting/` | Triage commands, five broken-then-fixed scenarios, mini-project, triage gauntlet |
| `Helm/` | `helm create`, lint, template, install, upgrade, rollback, uninstall; mini-project chart |
| `CI-CD GitHub Actions/` | Flask grade API, CI workflow (lint→test matrix→build→integration), CD workflow (publish→deploy to k8s) |
| `DevSecOps Pipeline/` | SAST, SCA, secret scanning, IaC scanning, container image scanning, security gate |
| `Terraform and AWS/` | `terraform init/fmt/validate/plan/apply/destroy`, S3 demo with versioning, drift detection, AWS IAM/EC2/S3/VPC/DynamoDB |
| `Cloud Terraform Project/` | Multi-resource Terraform project on AWS with remote S3 backend, modules, and diagrams |
| `Monitoring Observability and GitOps/` | Prometheus + Grafana + Loki stack, custom alert rules, ArgoCD GitOps with auto-sync and self-heal |
| `Final DevOps Project & Troubleshooting/` | Full-stack app (frontend + backend + docker-compose), end-to-end DevOps pipeline, troubleshooting docs |

Environment: macOS with Docker Desktop; Linux-only commands were run in Ubuntu 24.04 containers. The Kubernetes exercises are executed on a local single-node Minikube cluster utilizing the Docker driver.

---

**Submitted by Prince Shakya** · Roll No. 24BCS10084
