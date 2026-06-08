# Etapa 1: Traemos Grafana desde su imagen oficial optimizada
FROM grafana/grafana-oss:10.4.2 as grafana-source

# Etapa 2: Armamos nuestra imagen final basada en Ubuntu
FROM ubuntu:22.04

# Evitar preguntas interactivas
ENV DEBIAN_FRONTEND=noninteractive

# Instalar solo lo mínimo indispensable
RUN apt-get update && apt-get install -y \
    wget \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

# 1. Instalar Prometheus (Es liviano, baja en 2 segundos)
RUN wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz \
    && tar -xvf prometheus-2.45.0.linux-amd64.tar.gz \
    && mv prometheus-2.45.0.linux-amd64 /etc/prometheus \
    && rm prometheus-2.45.0.linux-amd64.tar.gz

# 2. Copiar Grafana desde la otra imagen (Cero descompresión, pasa directo)
COPY --from=grafana-source /usr/share/grafana /usr/share/grafana

# Configurar Grafana para Render
ENV GF_SERVER_HTTP_PORT=10000
EXPOSE 10000

# Copiar configuración base de Prometheus
COPY prometheus.yml /etc/prometheus/prometheus.base.yml

# Script de arranque
CMD sed "s|BACKEND_URL_PLACEHOLDER|$BACKEND_URL|g" /etc/prometheus/prometheus.base.yml > /etc/prometheus/prometheus.yml \
    && /etc/prometheus/prometheus --config.file=/etc/prometheus/prometheus.yml --web.listen-address="127.0.0.1:9090" & \
    /usr/share/grafana/bin/grafana-server --homepath=/usr/share/grafana
