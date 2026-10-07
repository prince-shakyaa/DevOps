# Helm

Helm is the package manager for Kubernetes. Instead of applying a pile of YAML files by
hand, the YAML is written once as **templates**, the parts that change between
environments are pulled out into **values**, and the whole thing is installed, upgraded
and rolled back as one versioned **release**.

Everything here was run with Helm v4.3 against the single-node Minikube cluster used in the
Kubernetes folders, each exercise in its own `helm-*` namespace.

| Term | Meaning |
|---|---|
| **Chart** | A package: `Chart.yaml` (metadata), `values.yaml` (defaults), `templates/` (Go-templated manifests) |
| **Values** | Inputs to the templates. Overridden with `-f file.yaml` or `--set key=value` (the last one wins) |
| **Release** | One installed instance of a chart, with a name and a namespace. The same chart can be installed many times |
| **Revision** | Every install, upgrade or rollback adds a numbered revision, stored as a Secret in the release namespace |
| **Repository** | An HTTP index of packaged charts (`helm repo add`). Artifact Hub searches all public ones |

```text
Helm/
├── 01-helm-commands/      helm create, lint, template, install, status, get, upgrade,
│   └── campus-site/        history, rollback, dry-run, uninstall, repo, search, package
├── 02-helm-rollback/      upgrade → upgrade → broken upgrade → rollback, step by step
│   └── timetable-chart/
├── mini-project/          lost-and-found API chart with dev and prod values files
│   └── lostfound-chart/
└── screenshots/
```

## Exercises

1. [**Helm commands**](01-helm-commands/README.md): every everyday command on a chart
   scaffolded with `helm create`, plus a public chart (podinfo) installed from a repository.
2. [**Rollback workflow**](02-helm-rollback/README.md): revision 1 → 2 (good) → 3
   (non-existent image) → rollback to 2, with the page content proving which revision is
   live.
3. [**Mini project**](mini-project/README.md): a chart written from scratch, with
   conditionals, helpers, a config checksum, dev/prod values, two kinds of failed upgrade
   and a rollback.

## Cheat sheet

```bash
# charts
helm create NAME                       # scaffold
helm lint CHART [-f values.yaml]       # static checks
helm template REL CHART [-f/--set]     # render locally, nothing sent to the cluster
helm package CHART                     # -> NAME-VERSION.tgz

# lifecycle
helm install REL CHART -n NS --create-namespace [-f ...] [--set ...] [--wait]
helm upgrade REL CHART -n NS [-f ...] [--reuse-values] [--wait --timeout 60s]
helm upgrade --install REL CHART       # install if missing, otherwise upgrade (CI-friendly)
helm rollback REL [REVISION] -n NS
helm uninstall REL -n NS
helm install ... --dry-run=server      # validate against the API without creating anything

# inspect
helm list -A
helm status REL -n NS
helm history REL -n NS
helm get values|manifest|notes|metadata|all REL -n NS [--revision N]

# repositories
helm repo add NAME URL && helm repo update
helm search repo KEYWORD [--versions]
helm search hub KEYWORD
helm show chart|values|readme REPO/CHART
helm repo remove NAME
```

---

**Prince Shakya** · Roll No. 24BCS10084
