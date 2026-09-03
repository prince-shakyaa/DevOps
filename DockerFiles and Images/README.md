# Optimizing Docker Images

A deep dive into creating efficient Docker images using multi-stage builds.

## Multi-Stage Builds
Multi-stage builds allow you to use one image for compiling code and another for running it, drastically reducing the final image size.

### Go Example
We compiled a Go application.
- **Build Stage**: Uses the heavy `golang` image (around 365 MB) to compile the binary.
- **Production Stage**: Uses a minimal image like `alpine` or `scratch` (around 7 MB), copying only the compiled binary from the build stage.

This approach ensures the production image is secure, minimal, and fast to pull.
