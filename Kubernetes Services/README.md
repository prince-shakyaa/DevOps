# Kubernetes Services

A Pod on its own is not addressable in any useful way: its IP changes the moment it is
rescheduled. A Service is the stable front door. This folder works through all five Service
types against **one and the same Nginx Pod**, and each one is then tested from the place it
is actually supposed to be reachable from — another Pod, the node itself, the laptop, or
plain DNS.

**Environment:** Minikube v1.39.0 with the Docker driver on macOS (Apple silicon),
Kubernetes v1.37.0, containerd 2.3.4. The node's internal IP is `192.168.49.2` and the Pod
was scheduled onto `10.244.0.3`.

![kubectl version, minikube status, nodes](screenshots/environment.png)

## The Pod

[`webapp-pod.yaml`](webapp-pod.yaml) holds two objects: a ConfigMap with a small HTML page,
and a Pod running `nginx:1.29-alpine` that mounts it at `/usr/share/nginx/html`. The
container port 80 is given the name `http`, and the Pod carries the label `app: webapp`.

Those two details are what make the rest of the folder work. Every selector-based Service
below matches on `app: webapp`, and each one writes `targetPort: http` instead of
`targetPort: 80` — referring to the port by name means the Service keeps working if the
container ever moves to a different port number.

![webapp-pod.yaml](screenshots/webapp-pod-yaml.png)

The cluster before anything was applied, and then the Pod running:

![clean state](screenshots/clean-state.png)
![webapp pod running](screenshots/webapp-pod.png)

Two throwaway Pods were created once and reused for every check that follows: `client`
(`curlimages/curl`) to make HTTP requests from inside the cluster, and `dns` (`busybox`) to
run `nslookup`.

## The five types

| Folder | Service | Reachable from | How it was verified |
|---|---|---|---|
| [ClusterIP](ClusterIP/) | `webapp-clusterip` | inside the cluster only | `curl` from the `client` Pod returned 200; the same IP from the laptop timed out |
| [NodePort](NodePort/) | `webapp-nodeport` `9090:30090` | any node IP on port 30090 | `curl` from inside the node, then a `minikube service` tunnel in the browser |
| [LoadBalancer](LoadBalancer/) | `webapp-loadbalancer` | an external IP handed out by the cloud | `EXTERNAL-IP` sits at `<pending>` on Minikube; the NodePort underneath works anyway |
| [Headless](Headless/) | `webapp-headless` (`clusterIP: None`) | through DNS, straight to the Pod IPs | `nslookup` answered `10.244.0.3`, which is the Pod's own IP |
| [ExternalName](ExternalName/) | `webapp-externalname` | resolves to `example.org` | `nslookup` answered with a CNAME to `example.org` |

Each folder contains its manifest, a README with the commands and what they printed, and the
screenshots taken during the run.

## How the types relate to each other

The first three are a stack, not three unrelated options:

- **ClusterIP** is the base — a virtual IP plus kube-proxy rules that forward to the matching
  Pods.
- **NodePort** is a ClusterIP *plus* a port reserved on every node.
- **LoadBalancer** is a NodePort *plus* a request to the cloud provider for an external IP
  pointing at that node port.

This is visible in the output rather than just being a claim: `webapp-loadbalancer` still has
a ClusterIP (`10.103.254.50`) and still had node port `32747` allocated to it, even though no
external IP ever showed up.

**Headless** and **ExternalName** are a different kind of thing altogether — neither one gets
a virtual IP, and kube-proxy is not involved. Headless publishes the Pod IPs through DNS and
lets the client choose; ExternalName is nothing but a CNAME pointing out of the cluster.

## Final state

All five Services, the EndpointSlices behind them, and the three Pods:

![final state](screenshots/final-state.png)

Worth noticing in that output: the four selector-based Services each got their own
EndpointSlice listing `10.244.0.3:80`, while `webapp-externalname` has none — there is
nothing for it to point at inside the cluster.

## Cleanup

```bash
kubectl delete -f ClusterIP -f NodePort -f LoadBalancer -f Headless -f ExternalName
kubectl delete pod client dns
kubectl delete -f webapp-pod.yaml
```

![cleanup](screenshots/cleanup.png)

---

**Parv Mehta** · Roll No. 24BCS10301
