# mj.sh

Lightweight Trello JSON to mJSON converter for team workflows.

## Overview

`mj.sh` converts large Trello board exports (30+ MB) into compact, analyzable mJSON format (~100 KB). Built for Httplab's product management workflows.

**Key features:**
- Extracts custom fields (Project, Effort, Priority)
- Finds GitHub PR links in attachments
- Filters archived cards automatically
- Human-readable JSON output
- Single bash script, no dependencies except `jq`

## Quick Start

```bash
# Install
curl -o mj.sh https://raw.githubusercontent.com/YOUR_USERNAME/mj/main/mj.sh
chmod +x mj.sh
sudo mv mj.sh /usr/local/bin/mj.sh

# Verify
mj.sh --version

# Use
mj.sh --output board_overview_$(date +%Y%m%d).json
```

## Requirements

- macOS or Linux
- bash 4.0+
- jq (install: `brew install jq`)

## Usage

### Basic usage

```bash
# Convert all-projects.json from Desktop
mj.sh --output board_overview.json

# Use specific input file
mj.sh --input ~/Downloads/board.json --output result.json

# Output to stdout
mj.sh
```

### Export Trello board

1. Open your Trello board
2. Board menu → Print and Export → Export as JSON
3. Save to Desktop as `1yVt3bQ7 - all-projects.json`
4. Run `mj.sh`

## Output Format

### Basic format (default)

```json
[
  {
    "id": "67053c24b2e398461bb5e3fc",
    "name": "LV-6401 Mark photographs",
    "url": "https://trello.com/c/Dw8Y7j2C",
    "status": "Testing",
    
    "assignees": ["slavaaq", "sergeykovalevsky"],
    "labels": ["In Test", "Incomplete"],
    
    "project": "LV",
    "effort": "a day",
    "priority": "High",
    
    "pr": ["https://github.com/trafficrunners/gmbmanager/pull/5243"],
    
    "created": "2024-10-08T10:23:45.120Z",
    "updated": "2024-11-25T09:15:33.840Z",
    "due": null,
    
    "archived": false,
    "isMirror": false
  }
]
```

### Extended format (--include-details, v0.3+)

Future versions will support extended format with:
- `description` - Full markdown description
- `attachments` - Array of files with metadata
- `linkedCards` - Array of linked cards with statuses
- `checklists` - Array of checklists with items and completion data

## Supported Custom Fields

mj.sh automatically extracts these Trello custom fields (list type):

- **Project** - Project identifier (LV, WTRC, SRP, etc.)
- **Effort** - Estimated effort (small task, a day, few days, etc.)
- **Priority** - Priority level (High, Medium, Low)

## Examples

See [examples/](examples/) directory for:
- Sample output files
- Integration scripts
- Morning routine automation

## Development

### Project Structure

```
mj/
├── mj.sh              # Main script
├── README.md          # This file
├── CHANGELOG.md       # Version history
├── LICENSE            # MIT License
└── examples/          # Sample outputs and scripts
```

### Contributing

This is an internal tool for Httplab. If you want to contribute:

1. Test changes with real Trello exports
2. Ensure backward compatibility
3. Update CHANGELOG.md
4. Follow existing code style

### Versioning

This project uses semantic versioning (MAJOR.MINOR.PATCH):
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes

Current version: **0.1.0**

## Roadmap

### v0.2 - Filtering
- `--member <username>` - Filter by team member
- `--status <n>` - Filter by list/status
- `--critical` - Show only critical tasks
- `--compact` - Minimal output (exclude description, checklists, attachments, activity)

### v0.3 - Extended Fields
- `--include-details` - Add description, checklists, attachments, linkedCards
- `--include-archived --archived-days N` - Include recently archived cards

### v0.4 - Activity
- `--include-activity` - Add unified activity timeline

### v1.0 - Stable Release
- Full feature set
- Comprehensive documentation
- Migration guide from makejson.sh

## Migration from makejson.sh

If you're currently using `makejson.sh`:

| makejson.sh | mj.sh |
|-------------|-------|
| `makejson.sh --board all-projects board.json` | `mj.sh --output result.json` |
| Output: ~2-5 MB | Output: ~100 KB |
| Requires multiple JSON files | Works with single export |

mj.sh produces a simpler, flatter structure that's easier to parse and analyze.

## Troubleshooting

### "jq: command not found"

Install jq:
```bash
brew install jq
```

### "File *all-projects.json not found"

mj.sh looks for `*all-projects.json` on Desktop by default. Either:
- Export Trello board to Desktop, or
- Use `--input` to specify file location

### Custom fields are null

Check that your Trello board has custom fields named exactly:
- "Project"
- "Effort"  
- "Priority"

Field names are case-sensitive.

## License

MIT License - see [LICENSE](LICENSE) file.

## Author

Created by Olya Demchuk for Httplab team workflows.

## Links

- [Trello Developer Guide](https://developer.atlassian.com/cloud/trello/)
- [jq Manual](https://stedolan.github.io/jq/manual/)
