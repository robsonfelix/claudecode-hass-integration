# Changelog

All notable changes to this project will be documented in this file.

## [0.1.3] - 2026-01-14

### Fixed
- Use pip to install requests (Alpine py3-requests is for Python 3.12, base image has 3.13)

## [0.1.2] - 2026-01-14

### Fixed
- Remove --strip-components=1 from tar (tarball has no subdirectory)

## [0.1.1] - 2026-01-14

### Fixed
- Fixed Monocle Gateway download URL (use alpine-x64/alpine-arm64 builds)

## [0.1.0] - 2026-01-14

### Added
- Initial release
- Auto-discover cameras from Home Assistant
- Support for UniFi Protect cameras
- Support for generic camera integration
- Periodic camera list refresh
- Camera name filters
- Monocle Gateway integration
