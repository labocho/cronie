# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## v0.1.0
### Added
- Support ActiveJob.

### Deprecated
- Cronie.run_async is deprecated

## v0.0.5
### Changed
- Cronie.parse raises Cronie::ParseError rather than NameError when parsing failed.

### Fixed
- Translation comments, rewrite README.

## v0.0.4
### Added
- Add Cronie.utf_offset option to independent from system time zone.

## v0.0.3
### Added
- Support Resque.
- Support `String` or `Integer` value of `Time` for `Cronie.run`, `Cronie.run_async`

## v0.0.2
### Fixed
- Add spec.
- Fix typo.

## v0.0.1
### Added
- Initial release.
