#!/bin/bash
set -e

echo "========================================"
echo "  Playwright Browser Add-on Starting"
echo "========================================"

# Read configuration
CDP_PORT=$(jq -r '.cdp_port // 9222' /data/options.json)
INTERNAL_PORT=9223

echo "[INFO] CDP port: ${CDP_PORT}"

# Find Chromium executable (Playwright installs it in /ms-playwright/)
CHROMIUM_PATH=$(find /ms-playwright -name "chrome" -type f 2>/dev/null | head -1)

if [ -z "$CHROMIUM_PATH" ]; then
    # Fallback to system chromium
    CHROMIUM_PATH=$(which chromium-browser 2>/dev/null || which chromium 2>/dev/null || which google-chrome 2>/dev/null || echo "")
fi

if [ -z "$CHROMIUM_PATH" ]; then
    echo "[ERROR] Chromium not found!"
    exit 1
fi

echo "[INFO] Using Chromium: ${CHROMIUM_PATH}"

# Create user data directory
USER_DATA_DIR="/tmp/chromium-data"
mkdir -p "$USER_DATA_DIR"

# Create nginx config to proxy CDP with Host header rewrite
cat > /tmp/nginx.conf << EOF
worker_processes 1;
error_log /dev/stderr warn;
pid /tmp/nginx.pid;

events {
    worker_connections 1024;
}

http {
    access_log /dev/stdout;

    # WebSocket support
    map \$http_upgrade \$connection_upgrade {
        default upgrade;
        '' close;
    }

    server {
        listen ${CDP_PORT};

        location / {
            proxy_pass http://127.0.0.1:${INTERNAL_PORT};
            proxy_http_version 1.1;

            # Rewrite Host header to localhost (Chrome security requirement)
            proxy_set_header Host localhost;

            # WebSocket support
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection \$connection_upgrade;

            # Timeouts for long-running connections
            proxy_read_timeout 86400s;
            proxy_send_timeout 86400s;
        }
    }
}
EOF

echo "[INFO] Starting Chromium on internal port ${INTERNAL_PORT}..."
echo "[INFO] CDP endpoint: http://playwright-browser:${CDP_PORT}"
echo "[INFO] (dbus errors below are harmless - no system bus in container)"

# Start Chromium in background on internal port
"$CHROMIUM_PATH" \
    --headless \
    --disable-gpu \
    --no-sandbox \
    --disable-setuid-sandbox \
    --disable-dev-shm-usage \
    --disable-software-rasterizer \
    --remote-debugging-port="${INTERNAL_PORT}" \
    --user-data-dir="$USER_DATA_DIR" \
    --disable-background-networking \
    --disable-default-apps \
    --disable-extensions \
    --disable-sync \
    --disable-translate \
    --disable-features=TranslateUI,BlinkGenPropertyTrees \
    --metrics-recording-only \
    --mute-audio \
    --no-first-run \
    --safebrowsing-disable-auto-update \
    --disable-breakpad \
    --disable-component-update \
    --disable-domain-reliability \
    --disable-features=AudioServiceOutOfProcess \
    --disable-print-preview \
    --disable-speech-api \
    --no-pings \
    --remote-allow-origins=* \
    --disable-notifications \
    --disable-permissions-api \
    --disable-background-mode \
    --disable-client-side-phishing-detection \
    --disable-hang-monitor \
    --disable-popup-blocking \
    --disable-prompt-on-repost \
    --password-store=basic \
    --use-mock-keychain &

CHROME_PID=$!

# Wait for Chrome to start
echo "[INFO] Waiting for Chromium to start..."
for i in {1..30}; do
    if curl -sf "http://127.0.0.1:${INTERNAL_PORT}/json/version" > /dev/null 2>&1; then
        echo "[INFO] Chromium is ready!"
        break
    fi
    sleep 1
done

# Start nginx reverse proxy
echo "[INFO] Starting nginx reverse proxy on 0.0.0.0:${CDP_PORT} -> 127.0.0.1:${INTERNAL_PORT}"
echo "[INFO] (nginx rewrites Host header to 'localhost' for Chrome CDP security)"
nginx -g 'daemon off;' -c /tmp/nginx.conf &
NGINX_PID=$!

echo "[INFO] CDP endpoint ready at http://playwright-browser:${CDP_PORT}"

# Give nginx a moment to start
sleep 2

# Monitor both processes
while true; do
    if ! kill -0 $CHROME_PID 2>/dev/null; then
        echo "[ERROR] Chrome process exited!"
        kill $NGINX_PID 2>/dev/null || true
        exit 1
    fi
    if ! kill -0 $NGINX_PID 2>/dev/null; then
        echo "[ERROR] nginx process exited!"
        kill $CHROME_PID 2>/dev/null || true
        exit 1
    fi
    sleep 5
done
