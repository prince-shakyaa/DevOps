#!/usr/bin/env bash
# Deploys the five broken gauntlet Pods into a namespace and prints a one-screen
# triage report: for every unhealthy Pod, the status, the likely cause class,
# the latest warning event and the last log line.
set -euo pipefail

NS="${1:-ts-gauntlet}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl get ns "$NS" >/dev/null 2>&1 || kubectl create ns "$NS" >/dev/null
for f in "$DIR"/scenario-*/broken.yaml; do
  kubectl -n "$NS" apply -f "$f" >/dev/null
done
echo "deployed $(ls "$DIR"/scenario-*/broken.yaml | wc -l | tr -d ' ') scenarios into $NS, waiting 60s for states to settle..."
sleep "${SETTLE:-60}"

kubectl -n "$NS" get pods -l gauntlet=true
echo

hint() {
  case "$1" in
    CrashLoopBackOff|Error)            echo "app exits on start -> read logs --previous" ;;
    ImagePullBackOff|ErrImagePull)     echo "image name/tag/registry/auth -> check events" ;;
    Pending)                           echo "scheduler cannot place it -> resources/selectors/taints" ;;
    OOMKilled)                         echo "memory limit too low for the workload" ;;
    CreateContainerConfigError)        echo "missing ConfigMap/Secret or key" ;;
    ContainerCreating)                 echo "volume/secret mount or CNI problem -> events" ;;
    Running)                           echo "running - but read the logs: app-level errors hide here" ;;
    *)                                 echo "describe the pod" ;;
  esac
}

for pod in $(kubectl -n "$NS" get pods -l gauntlet=true -o jsonpath='{.items[*].metadata.name}'); do
  waiting=$(kubectl -n "$NS" get pod "$pod" -o jsonpath='{.status.containerStatuses[0].state.waiting.reason}' 2>/dev/null || true)
  last=$(kubectl -n "$NS" get pod "$pod" -o jsonpath='{.status.containerStatuses[0].lastState.terminated.reason}' 2>/dev/null || true)
  phase=$(kubectl -n "$NS" get pod "$pod" -o jsonpath='{.status.phase}')
  # an OOMKilled or crashed container spends most of its time "Running" or "CrashLoopBackOff":
  # the last termination reason says more than the current state
  if [ "$last" = "OOMKilled" ]; then reason=OOMKilled
  elif [ -n "$waiting" ]; then reason=$waiting
  elif [ -n "$last" ]; then reason=CrashLoopBackOff
  else reason=$phase; fi
  event=$(kubectl -n "$NS" get events --field-selector "involvedObject.name=$pod,type=Warning" \
          --sort-by=.lastTimestamp -o jsonpath='{range .items[-1:]}{.reason}: {.message}{end}' 2>/dev/null | cut -c1-95 || true)
  logline=$(kubectl -n "$NS" logs "$pod" --tail=1 2>/dev/null || true)
  [ -z "$logline" ] && logline=$(kubectl -n "$NS" logs "$pod" --previous --tail=1 2>/dev/null || true)
  echo "== $pod  [$reason]"
  echo "   hint : $(hint "$reason")"
  [ -n "$event" ]   && echo "   event: $event"
  case "$logline" in "unable to retrieve"*) logline="(no output - killed before it could print)";; esac
  [ -n "$logline" ] && echo "   log  : $logline"
done
