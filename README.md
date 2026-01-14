# Claude Code Home Assistant Add-on

Run Claude Code, Anthropic's AI coding assistant, directly inside Home Assistant to create automations, debug configurations, and manage your smart home with natural language.

## Features

- **Web Terminal**: Access Claude Code from your Home Assistant sidebar
- **Full Config Access**: Read and write Home Assistant configuration files
- **MCP Integration**: Claude can directly interact with your HA entities and services
- **Multi-Architecture**: Supports amd64, aarch64, armv7, armhf, and i386

## Installation

1. Add this repository to your Home Assistant add-on store:

   [![Add Repository](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Frobsonfelix%2Fclaudecode-hass-integration)

   Or manually:
   - Go to **Settings** > **Add-ons** > **Add-on Store**
   - Click the menu (three dots) > **Repositories**
   - Add: `https://github.com/robsonfelix/robsonfelix-hass-addons`

2. Install the "Claude Code" add-on

3. Configure your Anthropic API key

4. Start the add-on and open the Web UI

## Quick Start

Once installed, open the Claude Code panel from your sidebar and try:

```bash
claude "List all my automations"
claude "Create an automation to turn on lights at sunset"
claude "Check my configuration.yaml for errors"
```

## Requirements

- Home Assistant OS or Supervised installation
- Anthropic API key (https://console.anthropic.com/)

## Documentation

See [DOCS.md](claudecode/DOCS.md) for full documentation.

## Support

- [Report Issues](https://github.com/robsonfelix/robsonfelix-hass-addons/issues)
- [Discussions](https://github.com/robsonfelix/robsonfelix-hass-addons/discussions)

## License

MIT License - see [LICENSE](LICENSE) for details.
