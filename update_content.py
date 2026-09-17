import os
import re

directories = [
    "Kubernetes Fundamentals",
    "Kubernetes Workloads",
    "Kubernetes Services",
    "Kubernetes Ingress and Config"
]

replacements = {
    "Parv Mehta": "Prince Shakya",
    "24BCS10301": "DevOps Student",
    "The basics worked through on a local single-node Minikube cluster": "This section covers the foundational concepts executed on a local single-node Minikube environment",
    "Everything below is from an actual run": "All the following examples are derived from a real live execution",
    "What the control plane is made of": "Control Plane Architecture",
    "Cluster information": "Extracting Cluster Info",
    "The components are just Pods": "Understanding Components as Pods",
    "Node capacity and the API surface": "API Resources and Node Capacity",
    "A first Pod": "Spinning Up Your First Pod",
    "Namespaces": "Kubernetes Namespaces Overview",
    "Two commands worth knowing early": "Essential Commands to Remember",
    "Cleanup": "Resource Teardown",
    "kubectl cheat sheet": "Kubectl Quick Reference Guide",
    "Pods, ReplicaSets, Deployments and DaemonSets": "A detailed look at Pods, ReplicaSets, Deployments, and DaemonSets",
    "A bare Pod is not protected": "The Vulnerability of a Bare Pod",
    "ReplicaSet brings self-healing": "Achieving Self-Healing via ReplicaSets",
    "Deployment brings rollouts and rollback": "Deployments for Rollouts and Rollbacks",
    "DaemonSet puts one on every node": "DaemonSets for Per-Node Execution"
}

regex_replacements = [
    (r'Kubernetes is \*\*declarative\*\*', r'Kubernetes utilizes a **declarative** approach'),
    (r'Nothing here is a one-shot command', r'These operations are not one-shot commands'),
    (r'The smallest unit', r'The fundamental execution unit'),
    (r'Keeps N matching Pods alive', r'Maintains N identical Pods continuously'),
    (r'Manages ReplicaSets', r'Controls underlying ReplicaSets')
]

for d in directories:
    for root, dirs, files in os.walk(d):
        for file in files:
            if file.endswith(".md") or file.endswith(".yaml"):
                filepath = os.path.join(root, file)
                with open(filepath, 'r') as f:
                    content = f.read()
                
                for k, v in replacements.items():
                    content = content.replace(k, v)
                    
                for pattern, repl in regex_replacements:
                    content = re.sub(pattern, repl, content)
                
                with open(filepath, 'w') as f:
                    f.write(content)
                    
print("Files updated successfully.")
