# Playwright Browser Add-on

Headless Chromium browser with Chrome DevTools Protocol (CDP) endpoint for browser automation.

## Overview

This add-on runs a headless Chromium browser that exposes a CDP endpoint, allowing other add-ons (like Claude Code) to connect and perform browser automation tasks.

## Usage with Claude Code

1. Install and start this add-on
2. In Claude Code, enable "Playwright MCP" in the configuration
3. Claude Code will automatically connect to this browser for web automation

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `cdp_port` | 9222 | Port for the CDP endpoint |

## Architecture

```
┌─────────────────────┐     CDP WebSocket     ┌─────────────────────┐
│   Claude Code       │ ────────────────────> │  Playwright Browser │
│                     │   ws://addon:9222     │                     │
│  @playwright/mcp    │                       │  Headless Chromium  │
└─────────────────────┘                       └─────────────────────┘
```

## Why a separate add-on?

Playwright/Chromium requires Ubuntu/Debian (glibc) to work properly. Home Assistant's default add-on base is Alpine (musl), which is incompatible. This add-on uses the official Playwright Docker image (Ubuntu-based) while keeping Claude Code lightweight on Alpine.

## Supported Architectures

- amd64 (x86_64)

Note: ARM64 support may be added in a future release.
