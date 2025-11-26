# mj.sh

Lightweight Trello JSON to mJSON converter for team workflows.

## Overview

`mj.sh` converts large Trello board exports (30+ MB) into compact, analyzable mJSON format (~100 KB). Built for Httplab's product management workflows.

**Key features:**
- 300x compression (34MB → 106KB, or 600x with --compact)
- Filter by team member, status
- Extracts custom fields (Project, Effort, Priority)
- Extracts GitHub PR links, attachments, linked cards
- Unified activity timeline (comments, status changes, etc.)
- Single bash script, only requires `jq`

## Quick Start

```bash
# Install
curl -o mj.sh https://raw.githubusercontent.com/olga-demchuk/mj/main/mj.sh
chmod +x mj.sh
mv mj.sh /usr/local/bin/mj.sh

# Verify
mj.sh --version  # v0.4.2

# Use
mj.sh --output board.json
```

## Requirements

- macOS or Linux
- bash 4.0+
- jq (`brew install jq` or `apt install jq`)

## Usage

```bash
# All active cards
mj.sh --output board.json

# Filter by team member
mj.sh --member slavaaq --output slava.json

# Filter by status (partial match, case-insensitive)
mj.sh --status "In Progress" --output in_progress.json
mj.sh --status todo --output todo.json

# Combine filters
mj.sh --member petrovmichael1 --status "In Progress"

# Compact output (faster analysis, smaller files)
mj.sh --compact --output board_compact.json

# Specific input file
mj.sh --input ~/Downloads/board.json --output result.json
```

### Export Trello board

1. Open your Trello board
2. Board menu → Print and Export → Export as JSON
3. Save to Desktop
4. Run `mj.sh`

## Output Format

### Full format (default)

```json
{
  "id": "67053c24b2e398461bb5e3fc",
  "name": "LV-6401 Mark photographs",
  "url": "https://trello.com/c/Dw8Y7j2C",
  "status": "Testing",
  
  "description": "Full markdown description...",
  
  "checklists": [
    {
      "name": "Notes",
      "items": [{"text": "Fix bug", "checked": true}]
    }
  ],
  
  "attachments": [
    {"name": "image.png", "url": "...", "addedBy": "slavaaq"}
  ],
  
  "linkedCards": [
    {"name": "Related task", "url": "https://trello.com/c/..."}
  ],
  
  "activity": [
    {"type": "updateCard", "user": "slavaaq", "data": {"from": "ToDo", "to": "In Progress"}},
    {"type": "commentCard", "user": "mike", "data": {"text": "Looks good!"}}
  ],
  
  "assignees": ["slavaaq", "sergeykovalevsky"],
  "labels": ["In Test"],
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
```

### Compact format (--compact)

Excludes: description, checklists, attachments, linkedCards, activity.
Only critical fields for quick status analysis.

## Activity Types

| Type | Description |
|------|-------------|
| commentCard | Comments |
| updateCard | Status changes |
| updateCheckItemStateOnCard | Checklist item changes |
| addMemberToCard / removeMemberFromCard | Member changes |
| addAttachmentToCard / deleteAttachmentFromCard | Attachment changes |
| addChecklistToCard | Checklist added |
| updateCustomFieldItem | Custom field changes |
| moveCardFromBoard | Card moved from another board |
| createCard | Card created |

## Documentation

- [Full Specification](mj_spec.md) - Detailed field descriptions, technical details
- [Changelog](CHANGELOG.md) - Version history

## Troubleshooting

### "jq: command not found"
```bash
brew install jq  # macOS
apt install jq   # Linux
```

### "File *all-projects.json not found"
Use `--input` to specify file location, or export Trello board to Desktop.

### Custom fields are null
Ensure your Trello board has custom fields named exactly "Project", "Effort", "Priority" (case-sensitive).

## Roadmap

### v0.5 - Filters
- `--labels <names>` - Filter by labels
- `--project <n>` - Filter by project
- `--unassigned` - Show unassigned tasks

### v0.6 - Archives
- `--include-archived` - Include archived cards
- `--archived-days N` - Archived within N days

### v1.0 - Stable Release
- Full feature set
- Migration guide from makejson.sh

## License

MIT License - see [LICENSE](LICENSE) file.

## Author

Created by Olya Demchuk for Httplab team workflows.
