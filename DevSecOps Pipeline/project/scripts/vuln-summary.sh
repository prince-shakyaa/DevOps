#!/usr/bin/env bash
# vuln-summary IMAGE: severity counts (all), fixable HIGH/CRITICAL, and secrets for one image
img="$1"
all=$(trivy image --quiet --scanners vuln --format json "$img" 2>/dev/null)
fix=$(trivy image --quiet --scanners vuln,secret --severity HIGH,CRITICAL --ignore-unfixed --format json "$img" 2>/dev/null)
printf '%-26s ' "$img"
echo "$all" | jq -r '[.Results[]?.Vulnerabilities[]?.Severity] | group_by(.) | map({(.[0]): length}) | add // {} |
  "CRITICAL \(.CRITICAL // 0)  HIGH \(.HIGH // 0)  MEDIUM \(.MEDIUM // 0)  LOW \(.LOW // 0)" ' | tr -d '\n'
echo "$fix" | jq -r '"   | gate: fixable HIGH/CRIT \([.Results[]?.Vulnerabilities[]?] | length), secrets \([.Results[]?.Secrets[]?] | length)"'
