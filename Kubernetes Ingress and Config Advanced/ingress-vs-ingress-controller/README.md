# Ingress vs Ingress Controller

The two names sound like one thing, but they are two separate pieces and neither does
anything useful without the other.

## Ingress: the rules

An **Ingress** is a Kubernetes API object (`networking.k8s.io/v1`). It describes HTTP(S)
routing: which hostnames and paths should go to which Service and port, and which TLS
Secret to present. It is stored in etcd like any other object, and that is all it is: data.

```yaml
rules:
  - host: hostel.local
    http:
      paths:
        - path: /api(/|$)(.*)
          backend: { service: { name: hostel-backend, port: { number: 8000 } } }
```

## Ingress Controller: the engine

An **Ingress Controller** is a program running in the cluster, usually a Deployment behind a
LoadBalancer or NodePort Service. It watches the API for Ingress objects of its class,
translates them into configuration for a real reverse proxy (an `nginx.conf`, Envoy routes,
HAProxy backends...), reloads that proxy, and then receives the actual traffic.

Kubernetes ships **no** controller of its own. The kube-controller-manager runs controllers for
Deployments, ReplicaSets, Jobs and so on, but none for Ingress. Someone has to install one.

## Side by side

| | Ingress | Ingress Controller |
|---|---|---|
| What it is | API object (YAML) | Running Pods (software) |
| Who writes it | The application team | The platform team installs it once |
| Lives in | etcd | A namespace such as `ingress-nginx` |
| Does it handle packets? | No | Yes, it is the proxy |
| How many | One per app, often many | Usually one or two per cluster |
| Linked by | `spec.ingressClassName` | `IngressClass.spec.controller` |

## Why both are needed

- The rules alone have nobody to enforce them.
- The controller alone has nothing to route.
- Splitting them lets a team write portable rules once and have the cluster decide how to
  run them: NGINX on Minikube, an AWS ALB on EKS, a GCE load balancer on GKE.
  `ingressClassName` is what pairs a particular Ingress with a particular controller, so
  several controllers can coexist in one cluster.

## Common controllers

| Controller | Notes |
|---|---|
| **ingress-nginx** | Community NGINX controller and the Minikube addon used here. Note that the project has announced retirement, and new clusters are moving to Gateway API implementations |
| **NGINX Ingress (F5/NGINX Inc.)** | Separate commercial-backed NGINX controller |
| **Traefik** | Default in k3s, auto-discovers routes, built-in Let's Encrypt |
| **HAProxy Ingress** | HAProxy based, high performance |
| **AWS Load Balancer Controller** | Provisions an ALB per Ingress (or group) |
| **GKE Ingress** | Provisions a Google Cloud HTTP(S) load balancer |
| **Contour / Emissary / Istio gateway** | Envoy based |

The newer **Gateway API** (`Gateway` + `HTTPRoute`) applies the same split even more strictly:
`GatewayClass`/`Gateway` belong to the platform team and `HTTPRoute` to the app team.

## Proof on this cluster

From [`../README.md`](../README.md#3-ingress), in order:

1. **Controller removed.** `kubectl get ingressclass` shows nothing. The Ingress is created
   anyway, but it gets no `ADDRESS` and port 80 on the node refuses connections.

   ![Ingress without controller](../screenshots/ingress-no-controller.png)

2. **Controller installed.** The Ingress object itself is not touched.

   ![install controller](../screenshots/install-controller.png)

3. **The same Ingress now routes.** It gets an address, `server_name` blocks show up in the
   controller's `nginx.conf`, and the identical request is answered.

   ![Ingress now works](../screenshots/ingress-now-works.png)

The [wrong `ingressClassName`](../troubleshooting/README.md#4-wrong-ingressclassname)
scenario shows the same thing from the other side: a controller is running, but because the
class does not match, it skips the Ingress and logs `Ignoring ingress`.

---

**Prince Shakya** · Roll No. 24BCS10084
