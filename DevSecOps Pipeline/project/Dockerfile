# ---- stage 1: resolve and install dependencies with a full toolchain ----
FROM python:3.13-slim-trixie AS deps
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --target=/deps -r requirements.txt

# ---- stage 2: distroless runtime - no shell, no package manager, non-root ----
FROM gcr.io/distroless/python3-debian13:nonroot
ARG GIT_SHA=dev
ENV GIT_SHA=${GIT_SHA} \
    PYTHONPATH=/deps:/srv \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
LABEL org.opencontainers.image.title="campus-notice-board" \
      org.opencontainers.image.revision="${GIT_SHA}"
WORKDIR /srv
COPY --from=deps /deps /deps
COPY app ./app
USER 65532:65532
EXPOSE 8080
ENTRYPOINT ["python3", "-m", "gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "--worker-tmp-dir", "/tmp", "app.app:app"]
