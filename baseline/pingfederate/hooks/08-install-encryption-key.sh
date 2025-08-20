#!/usr/bin/env sh
echo "=== Installing Merged Encryption Keys ==="

# Ensure the target directory exists
mkdir -p "${SERVER_ROOT_DIR}/server/default/data"

SECRET_PATH="/opt/secrets/encryption-key/pf.jwk"
TARGET_PATH="${SERVER_ROOT_DIR}/server/default/data/pf.jwk"

if [ -f "$SECRET_PATH" ]; then
    echo "✅ Found secret at $SECRET_PATH"
    
    # Check if target already has keys (from server profile)
    if [ -f "$TARGET_PATH" ]; then
        echo "📋 Existing keys found, merging with secret..."
        
        # Create merged keystore with secret keys first (primary)
        echo '{"keys":[' > "$TARGET_PATH.tmp"
        
        # Extract keys from secret (your bulk import key first)
        cat "$SECRET_PATH" | grep -o '"kty":"oct","kid":"[^"]*","k":"[^"]*"' | \
        while read key; do
            echo "{$key}," >> "$TARGET_PATH.tmp"
        done
        
        # Extract keys from existing file (baseline keys)
        cat "$TARGET_PATH" | grep -o '"kty":"oct","kid":"[^"]*","k":"[^"]*"' | \
        while read key; do
            echo "{$key}," >> "$TARGET_PATH.tmp"
        done
        
        # Clean up trailing comma and close JSON
        sed '$ s/,$//' "$TARGET_PATH.tmp" | sed '$ s/$/]}/' > "$TARGET_PATH"
        rm "$TARGET_PATH.tmp"
        
        echo "✅ Keys merged successfully"
    else
        echo "📋 No existing keys, installing from secret..."
        cp "$SECRET_PATH" "$TARGET_PATH"
    fi
    
    # Verify bulk import key is present
    if grep -q "Hw6TJb4ILB" "$TARGET_PATH"; then
        echo "✅ Bulk import key Hw6TJb4ILB verified"
        echo "📊 Total keys available: $(grep -o '"kid":"[^"]*"' "$TARGET_PATH" | wc -l)"
    else
        echo "❌ Bulk import key NOT found after merge!"
        exit 1
    fi
else
    echo "❌ CRITICAL: Secret not found at $SECRET_PATH"
    echo "Cannot proceed without encryption key secret"
    exit 1
fi
