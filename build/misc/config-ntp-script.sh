#!/bin/bash
for ip in $(kubectl get nodes -o jsonpath='{range .items[*]}{range .status.addresses[?(@.type=="InternalIP")]}{.address}{"\n"}{end}{end}'); do
  echo "=== $ip ==="
  ssh -t -o StrictHostKeyChecking=no "$ip" \
    "cat <<'EOF' | sudo tee /etc/systemd/timesyncd.conf > /dev/null
[Time]
NTP=10.231.0.1
PollIntervalMinSec=32s
PollIntervalMaxSec=8min
EOF
  sudo systemctl restart systemd-timesyncd && \
  sudo timedatectl show -p ServerName -p PollIntervalUSec -p NTPSynchronized && \
  sudo systemctl status systemd-timesyncd"
done


for cxt in "j64manager j64domain j52domain r01domain"; do
  kubectl delete ns monitoring --context ${cxt}
done


contexts=("j64manager" "j64domain" "j52domain" "r01domain")
for ctx in "${contexts[@]}"; do

for ctx in j64manager j64domain j52domain r01domain; do
  echo === $ctx ===; kubectl delete ns monitoring --context $ctx;
done


ctxs=("j64manager" "j64domain" "j52domain" "r01domain")
for c in "${ctxs[@]}"; do
  echo === $c ===; echo;
done

