#!/bin/sh
echo "=== Installing Bulk Import Encryption Key ==="
echo "Ensuring data directory exists..."
mkdir -p "${SERVER_ROOT_DIR}/server/default/data"

echo "Installing encryption key from Kubernetes secret..."
if [ -f "/opt/secrets/encryption-key/pf.jwk" ]; then
    cp /opt/secrets/encryption-key/pf.jwk "${SERVER_ROOT_DIR}/server/default/data/pf.jwk"
    echo "✅ Encryption key installed from secret"
else
    echo "❌ Secret not found, installing fallback key"
    cat > "${SERVER_ROOT_DIR}/server/default/data/pf.jwk" << 'KEYEOF'
{"keys":[{"kty":"oct","kid":"Hw6TJb4ILB","k":"7JGj-RRIgH-AVdVcLMuJtmKVnsFQt5S2SiRD2W--SC8"}]}
KEYEOF
fi

# Verify installation
if grep -q "Hw6TJb4ILB" "${SERVER_ROOT_DIR}/server/default/data/pf.jwk"; then
    echo "✅ Bulk import key Hw6TJb4ILB verified"
else
    echo "❌ Bulk import key NOT found!"
fi
