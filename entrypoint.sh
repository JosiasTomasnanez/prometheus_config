#!/bin/bash

# 1. Arrancar Prometheus apuntando a 0.0.0.0 para que lo puedas ver desde afuera del contenedor
echo "--> ARRANCANDO PROMETHEUS EN SEGUNDO PLANO..."
/etc/prometheus/prometheus --config.file=/etc/prometheus/prometheus.yml --web.listen-address="0.0.0.0:9090" > /dev/null 2>&1 &

# 2. Arrancar Grafana en primer plano (mantiene vivo el contenedor)
echo "--> ARRANCANDO GRAFANA..."
exec /usr/share/grafana/bin/grafana-server --homepath=/usr/share/grafana
