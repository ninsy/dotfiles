#!/bin/bash

prom_port=9090

target_port=8887
target="host.docker.internal:${target_port}"

cat > prometheus.yml << EOL
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'tr_local'
    metrics_path: /metrics
    static_configs:
      - targets: ['${target}']
EOL

docker run --rm --name my-prometheus \
  --add-host=host.docker.internal:host-gateway \
  -p $prom_port:$prom_port \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus
