FROM ubuntu:22.04

# Evitar preguntas interactivas durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias básicas
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    software-properties-common \
    wget \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

# 1. Instalar Prometheus
RUN wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz \
    && tar -xvf prometheus-2.45.0.linux-amd64.tar.gz \
    && mv prometheus-2.45.0.linux-amd64 /etc/prometheus \
    && rm prometheus-2.45.0.linux-amd64.tar.gz

# 2. Instalar Grafana OSS
RUN mkdir -p /etc/apt/keyrings/ \
    && wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/grafana.gpg > /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee /etc/apt/sources.list.d/grafana.list \
    && apt-get update && apt-get install -y grafana-oss \
    && rm -rf /var/lib/apt/lists/*

# Copiar nuestra configuración base de Prometheus hacia el contenedor
COPY prometheus.yml /etc/prometheus/prometheus.base.yml

# Configurar Grafana para que escuche en el puerto 10000 (el que exige Render)
ENV GF_SERVER_HTTP_PORT=10000
EXPOSE 10000

# Script de arranque: Reemplaza la URL en el config de Prometheus y ejecuta ambos servicios
CMD sed "s|BACKEND_URL_PLACEHOLDER|$BACKEND_URL|g" /etc/prometheus/prometheus.base.yml > /etc/prometheus/prometheus.yml \
    && /etc/prometheus/prometheus --config.file=/etc/prometheus/prometheus.yml --web.listen-address="127.0.0.1:9090" & \
    /usr/share/grafana/bin/grafana-server --homepath=/usr/share/grafana --config=/etc/grafana/grafana.ini
