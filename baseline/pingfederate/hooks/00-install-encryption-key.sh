#!/bin/sh
echo "Copying encryption key from secret mount..."
cp /opt/staging/instance/server/default/data/pf.jwk /opt/out/instance/server/default/data/pf.jwk 2>/dev/null && echo "✅ Key copied" || echo "❌ Key copy failed"
