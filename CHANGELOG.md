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

## [0.3.0] - 2025-11-26

### Added
- `--status <name>` flag to filter cards by status (case-insensitive, partial match)

## [0.3.1] - 2025-11-26

### Added
- `checklists` field with items (excluded in --compact mode)

## [0.3.2] - 2025-11-26

### Added
- `attachments` field with metadata (excluded in --compact mode)
- Attachments include: id, name, url, addedAt, addedBy (username)
- GitHub PRs excluded from attachments (already in `pr` field)

## [0.3.3] - 2025-11-26

### Added
- `linkedCards` field for Trello card links (excluded in --compact mode)

### Changed
- Trello card links now separated from attachments

## [0.4.0] - 2025-11-26

### Added
- `activity` field with unified timeline (excluded in --compact mode)
- Activity types: commentCard, updateCard (status changes), updateCheckItemStateOnCard, addMemberToCard, removeMemberFromCard, addAttachmentToCard, addChecklistToCard, createCard
- Position-only updateCard events filtered out
- Activities sorted by date (newest first)

## [0.4.1] - 2025-11-26

### Added
- `deleteAttachmentFromCard` activity type with attachment name

## [0.4.2] - 2025-11-26

### Added
- `updateCustomFieldItem` activity type (shows field name: Project, Effort, Priority)
- `moveCardFromBoard` activity type (shows source list name)

## [0.5.0] - 2025-11-26

### Added
- `--critical` filter (statuses: To Do HP, To Fix, Testing, To Deploy, To Final Verification; OR label: Priority)
- `--unassigned` filter (cards without assignees)

### Changed
- `--search` now uses AND-logic for multiple words ("company cam" finds "CompanyCam")

## [0.5.2] - 2025-11-26

### Added
- `--labels <names>` filter with OR-logic (comma-separated)

### Changed
- `--critical` now includes HP label (was only Priority)
- `--critical` excludes Done and Recently Released statuses
- `--critical` regex fixed: "ToDo HP" instead of "To Do HP"

## [0.6.1] - 2026-02-12

### Added
- `qaAssignee` field (array) for cards in Testing status
- Auto-detects QA engineers from activity: users who moved card to Testing OR added Fix checklist
- Returns empty array [] for non-Testing cards
- Supports multiple QA engineers per card
