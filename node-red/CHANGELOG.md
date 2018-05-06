# Changelog
All notable changes to this project will be documented in this file.

## [1.9] - 2018-05-05
### Changed
- Updated node-red-contrib-home-assistant to 0.3.2

### Fixed
- node-red-contrib-home-assistant 0.3.2 update fixes [#11 (Crashing Issue)](https://github.com/korylprince/hassio-node-red/issues/11)

## [1.8] - 2018-03-19
### Added
- Added `palette_version` option to set [node-red-contrib-home-assistant](https://github.com/AYapejian/node-red-contrib-home-assistant) version

### Fixed
- Removed extraneous log output

## [1.7] - 2018-03-08
### Added
- Added openssh-keygen and curl to image
- Add-on now waits for Home Assistant API to be available before starting Node-RED

### Changed
- Updated Node-RED to 0.18.4
- Now using Host networking to support more palettes

### Fixed
- Fixed problem where disabling admin users would corrupt settings.js

## [1.6] - 2018-02-19
### Added
- Added git to image

### Changed
- Updated Node-RED to 0.18.3
- Updated node-red-contrib-home-assistant to 0.3.0

### Fixed
- Fixed problem with updating node-red-contrib-home-assistant because git was missing

## [1.5] - 2018-02-06
### Changed
- Removed RPi GPIO libraries
- Updated Node-RED to 0.18.2

### Fixed
- Fixed issue with GPIO config causing add-on to not start on non-RPi hardware

## [1.4] - 2018-02-01
### Added
- Added RPi GPIO libraries

### Changed
- Updated Node-RED to 0.18.0
- Updated node-red-contrib-home-assistant to 0.2.1
- Moved install of node-red-contrib-home-assistant to `/share/node-red`

### Fixed
- No longer get error messages in logs about missing GPIO library
- Allow user updating of node-red-contrib-home-assistant

## [1.3] - 2018-01-11
### Fixed
- Fixed setting the wrong HTTP Password (Issue #3)

## [1.2] - 2017-12-27
### Fixed
- Corrected default settings path

## [1.1] - 2017-12-27
### Changed
- Don't install Node-RED as global package

### Fixed
- Use bcryptjs instead of bcrypt because of build issues
- Fixed bug in string quoting

## 1.0 - 2017-12-26
### Added
- Initial Project

[1.9]: https://github.com/korylprince/hassio-node-red/compare/1.8...1.9
[1.8]: https://github.com/korylprince/hassio-node-red/compare/1.7...1.8
[1.7]: https://github.com/korylprince/hassio-node-red/compare/1.6...1.7
[1.6]: https://github.com/korylprince/hassio-node-red/compare/1.5...1.6
[1.5]: https://github.com/korylprince/hassio-node-red/compare/1.4...1.5
[1.4]: https://github.com/korylprince/hassio-node-red/compare/1.3...1.4
[1.3]: https://github.com/korylprince/hassio-node-red/compare/1.2...1.3
[1.2]: https://github.com/korylprince/hassio-node-red/compare/1.1...1.2
[1.1]: https://github.com/korylprince/hassio-node-red/compare/1.0...1.1
