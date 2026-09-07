#!/bin/bash
###############################################################################
# user_data.sh.tpl — RKE2 single-node bootstrap for Amazon Linux 2023
# Rendered by Terraform templatefile(); variable: aws_region
###############################################################################
set -euo pipefail
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "=== [1/7] Fetching instance public IP from EC2 metadata ==="
TOKEN=$(curl -sS -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
PUBLIC_IP=$(curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Public IP: $PUBLIC_IP"

echo "=== [2/7] Installing RKE2 server (latest stable) ==="
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="server" sh -

echo "=== [3/7] Writing RKE2 config ==="
mkdir -p /etc/rancher/rke2
cat > /etc/rancher/rke2/config.yaml <<EOF
node-external-ip: "$PUBLIC_IP"
tls-san:
  - "$PUBLIC_IP"
  - "localhost"
  - "127.0.0.1"
write-kubeconfig-mode: "0644"
EOF

echo "=== [4/7] Enabling and starting rke2-server ==="
systemctl enable rke2-server.service
systemctl start rke2-server.service

echo "=== [5/7] Waiting for rke2-server to be active (up to 5 min) ==="
for i in $(seq 1 60); do
  if systemctl is-active --quiet rke2-server.service; then
    echo "rke2-server is active."
    break
  fi
  echo "  attempt $i/60 — waiting 5 s..."
  sleep 5
done
systemctl is-active --quiet rke2-server.service || {
  echo "ERROR: rke2-server failed to start. Journal:"
  journalctl -u rke2-server --no-pager -n 50
  exit 1
}

echo "=== [6/7] Configuring PATH and kubectl symlink ==="
RKE2_BIN="/var/lib/rancher/rke2/bin"

# Persist PATH addition for all future shells
cat > /etc/profile.d/rke2.sh <<'PROFILE'
export PATH=$PATH:/var/lib/rancher/rke2/bin
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
PROFILE

# Make immediately available in this script
export PATH="$PATH:$RKE2_BIN"
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml

# Symlink kubectl into a directory already on PATH
ln -sf "$RKE2_BIN/kubectl" /usr/local/bin/kubectl

echo "=== [7/7] Waiting for node to be Ready (up to 10 min) ==="
for i in $(seq 1 120); do
  STATUS=$(kubectl get nodes --kubeconfig /etc/rancher/rke2/rke2.yaml \
    --no-headers 2>/dev/null | awk '{print $2}' | head -1)
  if [ "$STATUS" = "Ready" ]; then
    echo "Node is Ready!"
    kubectl get nodes --kubeconfig /etc/rancher/rke2/rke2.yaml
    break
  fi
  echo "  attempt $i/120 — node status: '$STATUS' — waiting 5 s..."
  sleep 5
done

# Configure AWS CLI region for ECR login (used by deploy workflow)
aws configure set region ${aws_region}

echo "=== Bootstrap complete ==="
