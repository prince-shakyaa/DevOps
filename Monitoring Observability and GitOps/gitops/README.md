# GitOps

## What it is

GitOps runs operations **through Git**. The desired state of the whole system (Deployments,
Services, config, even the cluster add-ons) is kept as declarative files in a Git repository.
An agent inside the cluster continuously makes reality match those files. Changing production
means changing the repository.

The four OpenGitOps principles:

1. **Declarative**: the system is described as *what* it should be, not as steps to run.
2. **Versioned and immutable**: that description lives in Git, with full history.
3. **Pulled automatically**: agents fetch the desired state themselves.
4. **Continuously reconciled**: agents keep comparing actual to desired state and correct
   any difference.

## Git as the source of truth

- Every change is a commit: author, time, message, diff. `git log` becomes the audit trail of
  production.
- Every change can be reviewed in a pull request, with CI checks before merge.
- Rollback is `git revert`, which is itself recorded (demo 7.4 in the main README).
- Disaster recovery: an empty cluster plus the repo plus Argo CD rebuilds everything.

## Declarative configuration

Imperative: `kubectl scale deploy campus-portal --replicas=3`. Nothing records it, and the
next person cannot tell what was intended.
Declarative: `replicas: 3` in `app/deployment.yaml`. That *is* the intent, and the tool
works out how to get there. Kubernetes manifests, Helm charts and Kustomize overlays are all
declarative, which is what makes GitOps possible.

## Continuous reconciliation

The GitOps controller runs the same loop Kubernetes controllers run:

```text
   ┌──────────── observe ────────────┐
   │                                 ▼
 desired state (Git)        actual state (cluster)
   ▲                                 │
   └──── act: apply the diff ◄─ diff ┘
```

Argo CD compares the rendered manifests at the latest commit with the live objects. If they
differ, the app is **OutOfSync**. With `automated` it applies the difference. With `prune` it
also deletes objects removed from Git. With `selfHeal` it reverts manual changes made in the
cluster (demo 7.3 in the main README).

## Push vs pull deployment

| | Push (classic CI/CD) | Pull (GitOps) |
|---|---|---|
| Who deploys | CI pipeline runs `kubectl apply` / `helm upgrade` | agent inside the cluster |
| Credentials | CI holds cluster-admin credentials | the cluster only needs read access to Git |
| Drift | unnoticed until the next deploy | detected and corrected continuously |
| Network | CI must reach the API server | cluster calls out, so no inbound access needed |
| Many clusters | pipeline must know every cluster | each cluster pulls its own config |

CI still has a job in GitOps: build, test and scan the image, then **commit the new tag** to
the config repo. Argo CD does the rest.

## Workflow

```text
developer ──PR──► app repo ──CI: test, build, scan, push image──► registry
                                     │
                                     └──commit new image tag──► config repo (Git)
                                                                    │  pulled every 30s-3m
                                                                    ▼
                                                     Argo CD in cluster ──apply──► Kubernetes
```

## Kubernetes and GitOps

Kubernetes is a natural fit for GitOps because its own API already works this way: you
submit desired state and controllers reconcile it. GitOps adds Git as the store in front of
the API. Common tools: **Argo CD** (used here, has a UI, Applications and ApplicationSets) and
**Flux** (a set of controllers, CLI-first). Both handle plain YAML, Kustomize and Helm.

Secrets need special care because Git is readable by many people: Sealed Secrets, SOPS, or
External Secrets Operator referencing a vault (see the Secrets section in
[`Kubernetes Ingress and Config Advanced`](../../Kubernetes%20Ingress%20and%20Config%20Advanced/README.md)).

---

**Prince Shakya** · Roll No. 24BCS10084
