# Changelog

All notable changes to mj.sh will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-11-25

### Added
- Initial release
- Basic conversion of Trello JSON to mJSON format
- Automatic extraction of custom fields (Project, Effort, Priority)
- GitHub PR link detection in attachments
- Filtering of archived cards
- Command-line options: `--input`, `--output`, `--version`, `--help`
- Automatic search for `*all-projects.json` on Desktop

### Features
- Converts 30+ MB Trello exports to ~100 KB mJSON
- Supports custom field types: list, text, number, date, checkbox
- Extracts assignees, labels, status, dates
- Mirror card detection by name prefix

### Technical Details
- Single bash script with jq dependency
- Lookup tables for fast ID → name resolution
- Denormalization of Trello data structure
- Proper handling of list-type custom fields via idValue

## [Unreleased]

### Planned for v0.2
- Member filtering (`--member <username>`)
- Status filtering (`--status <name>`)
- Critical tasks view (`--critical`)

### Planned for v0.3
- Description and checklists (`--include-details`)
- Comments and activity log (`--include-activity`)

### Planned for v1.0
- Complete feature set
- Production-ready stability
- Comprehensive test suite
- Migration guide from makejson.sh

## [0.2.0] - 2024-11-25

### Added
- `description` field included by default in mJSON output
- `--compact` flag to exclude description for quick analysis
- `--member <username>` flag to filter cards by team member

### Changed
- Updated help message with new options and examples

## [0.2.1] - 2025-11-26

### Fixed
- Mirror card detection now uses `cardRole == "mirror"` instead of name prefix
