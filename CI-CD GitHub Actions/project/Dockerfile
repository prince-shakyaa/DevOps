# ---- build stage: install dependencies into an isolated prefix ----
FROM python:3.12-slim AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ---- runtime stage: only the app and its installed packages ----
FROM python:3.12-slim
ARG GIT_SHA=dev
ENV GIT_SHA=${GIT_SHA} \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
LABEL org.opencontainers.image.title="campus-grade-api" \
      org.opencontainers.image.revision="${GIT_SHA}"
RUN useradd --create-home --uid 10001 appuser
WORKDIR /srv
COPY --from=builder /install /usr/local
COPY app ./app
USER 10001
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s \
  CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"]
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "app.main:app"]
