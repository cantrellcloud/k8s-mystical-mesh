###########
# CAUTION ##################################
# MAKE SURE YOU ARE IN THE CORRECT CLUSTER #
# CONTEXT BEFORE RUNNING THIS SCRIPT.      #
# IT DELETES DATA FROM THE NODES!          #
############################################

for ip in $(kubectl get nodes -o jsonpath='{range .items[*]}{range .status.addresses[?(@.type=="InternalIP")]}{.address}{"\n"}{end}{end}'); do
  echo "=== $ip ==="
  ssh -t -o StrictHostKeyChecking=no "$ip" \
    "cat <<'EOF' | sudo tee /etc/multipath.conf > /dev/null
defaults {
    user_friendly_names yes
    find_multipaths no
}
EOF
  sudo systemctl restart multipathd && \
  echo && sudo cat /etc/multipath.conf && echo && \
  sudo systemctl status  multipathd"
done
