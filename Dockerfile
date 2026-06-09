# Etapa 1: Traemos Grafana desde su imagen oficial optimizada
FROM grafana/grafana-oss:10.4.2 as grafana-source

# Etapa 2: Armamos nuestra imagen final basada en Ubuntu
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalar lo mínimo indispensable (Agregamos bash)
RUN apt-get update && apt-get install -y \
    wget \
    gettext-base \
    bash \
    && rm -rf /var/lib/apt/lists/*

# 1. Instalar Prometheus
RUN wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz \
    && tar -xvf prometheus-2.45.0.linux-amd64.tar.gz \
    && mv prometheus-2.45.0.linux-amd64 /etc/prometheus \
    && rm prometheus-2.45.0.linux-amd64.tar.gz

# 2. Copiar Grafana
COPY --from=grafana-source /usr/share/grafana /usr/share/grafana

ENV GF_SERVER_HTTP_PORT=10000
EXPOSE 10000

# Copiar la configuración base
COPY prometheus.yml /etc/prometheus/prometheus.base.yml

# --- ESTO ES LO NUEVO ---
# Copiar y preparar el script de arranque
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Reemplazar la URL y ejecutar el entrypoint
CMD sed "s|BACKEND_URL_PLACEHOLDER|$BACKEND_URL|g" /etc/prometheus/prometheus.base.yml > /etc/prometheus/prometheus.yml \
    && /entrypoint.sh
