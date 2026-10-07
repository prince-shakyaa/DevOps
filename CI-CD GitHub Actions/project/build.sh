#!/usr/bin/env bash
# Build the image and a versioned source bundle - used by the Makefile and by the CI build job.
set -euo pipefail
TAG="${1:-local}"
SHA="$(git rev-parse --short HEAD 2>/dev/null || echo dev)"
mkdir -p build
docker build --build-arg GIT_SHA="$SHA" -t "campus-grade-api:${TAG}" .
tar --exclude='__pycache__' -czf "build/campus-grade-api-${TAG}.tar.gz" app requirements.txt Dockerfile
{
  echo "image=campus-grade-api:${TAG}"
  echo "git_sha=${SHA}"
  echo "built_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} > build/build-info.txt
cat build/build-info.txt
