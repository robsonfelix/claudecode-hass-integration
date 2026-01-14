#!/command/with-contenv bashio
# shellcheck shell=bash

# Initialize Claude Code environment
bashio::log.info "Initializing Claude Code environment..."

# Create necessary directories
mkdir -p /root/.claude /root/.config/claude-code

# Read configuration
ENABLE_MCP=$(bashio::config 'enable_mcp')
SUPERVISOR_TOKEN="${SUPERVISOR_TOKEN:-}"

# Configure MCP if enabled
if bashio::var.true "${ENABLE_MCP}"; then
    bashio::log.info "Configuring Home Assistant MCP server..."
    cat > /root/.claude/settings.json << EOF
{
  "mcpServers": {
    "homeassistant": {
      "command": "hass-mcp",
      "env": {
        "HASS_TOKEN": "${SUPERVISOR_TOKEN}",
        "HASS_HOST": "http://supervisor/core"
      }
    }
  }
}
EOF
else
    echo '{}' > /root/.claude/settings.json
fi

bashio::log.info "Claude Code initialization complete"
