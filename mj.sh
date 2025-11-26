#!/bin/bash

# mj.sh - Trello JSON to mJSON converter
# Version: 0.3.0
# Date: 2025-11-26

set -euo pipefail

VERSION="0.3.0"
DESKTOP_PATH="$HOME/Desktop"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция вывода ошибок
error() {
    echo -e "${RED}Error:${NC} $1" >&2
    exit 1
}

# Функция вывода предупреждений
warn() {
    echo -e "${YELLOW}Warning:${NC} $1" >&2
}

# Функция вывода успеха
success() {
    echo -e "${GREEN}$1${NC}"
}

# Поиск all-projects.json на Desktop
find_all_projects_json() {
    local json_file
    json_file=$(find "$DESKTOP_PATH" -maxdepth 1 -name "*all-projects.json" -type f 2>/dev/null | head -n 1)
    
    if [[ -z "$json_file" ]]; then
        error "File *all-projects.json not found on Desktop"
    fi
    
    echo "$json_file"
}

# Проверка зависимостей
check_dependencies() {
    if ! command -v jq &> /dev/null; then
        error "jq is not installed. Install it with: brew install jq"
    fi
}

# Основная функция преобразования
convert_to_mjson() {
    local input_file="$1"
    local output_file="${2:-}"
    local compact_mode="$3"
    local member_filter="$4"
    local status_filter="$5"
    
    # Создаём временный файл для промежуточного результата
    local temp_file
    temp_file=$(mktemp)
    
    # jq фильтр для преобразования
    jq -r --arg compact "$compact_mode" --arg member "$member_filter" --arg status_filter "$status_filter" '
    # Создаём lookup tables для быстрого доступа
    . as $root |
    
    # Lists lookup: id -> name
    ($root.lists | map({(.id): .name}) | add) as $lists_map |
    
    # Members lookup: id -> username
    ($root.members | map({(.id): .username}) | add) as $members_map |
    
    # Labels lookup: id -> name
    ($root.labels | map({(.id): .name}) | add) as $labels_map |
    
    # Обрабатываем карточки
    $root.cards |
    map(
        select(.closed == false) |  # Только незаархивированные
        . as $card |
        
        # Получаем имя списка
        ($lists_map[$card.idList] // "Unknown") as $status |
        
        # Фильтруем по status если указан
        select(if $status_filter != "" then ($status | ascii_downcase | contains($status_filter | ascii_downcase)) else true end) |
        
        # Получаем usernames участников
        ([$card.idMembers[] | $members_map[.] // empty]) as $assignees |
        
        # Фильтруем по member если указан
        select(if $member != "" then ($assignees | contains([$member])) else true end) |
        
        # Получаем названия меток
        ([$card.idLabels[] | $labels_map[.] // empty]) as $label_names |
        
        # Извлекаем значения кастомных полей (правильный способ для list-типа)
        (
            $card.customFieldItems // [] | map(
                . as $item |
                ($root.customFields[] | select(.id == $item.idCustomField)) as $field |
                {
                    field: $field.name,
                    value: (
                        if $field.type == "list" and $item.idValue then
                            ($field.options[] | select(.id == $item.idValue) | .value.text)
                        elif $item.value then
                            (
                                if $item.value.text then $item.value.text
                                elif $item.value.number then $item.value.number
                                elif $item.value.checked then $item.value.checked
                                elif $item.value.date then $item.value.date
                                else null
                                end
                            )
                        else null
                        end
                    )
                }
            )
        ) as $custom_items |
        
        # Извлекаем конкретные поля
        ($custom_items | map(select(.field == "Project")) | .[0].value // null) as $project |
        ($custom_items | map(select(.field == "Effort")) | .[0].value // null) as $effort |
        ($custom_items | map(select(.field == "Priority")) | .[0].value // null) as $priority |
        
        # Извлекаем PR из attachments
        ([$card.attachments[]? | select(.url | contains("github.com") and contains("/pull/")) | .url]) as $pr_urls |
        
        # Проверяем, является ли карточка mirror (по полю cardRole)
        ($card.cardRole == "mirror") as $is_mirror |
        
        # Формируем результат
        {
            id: $card.id,
            name: $card.name,
            url: $card.shortUrl,
            status: $status
        } +
        # description - только если не compact mode
        (if $compact == "false" then {description: $card.desc} else {} end) +
        {
            assignees: $assignees,
            labels: $label_names,
            project: $project,
            effort: $effort,
            priority: $priority,
            pr: $pr_urls,
            created: $card.dateLastActivity,
            updated: $card.dateLastActivity,
            due: $card.due,
            archived: $card.closed,
            isMirror: $is_mirror
        }
    )
    ' "$input_file" > "$temp_file"
    
    # Выводим результат
    if [[ -n "$output_file" ]]; then
        mv "$temp_file" "$output_file"
        success "mJSON created: $output_file"
    else
        cat "$temp_file"
        rm "$temp_file"
    fi
}

# Показать помощь
show_help() {
    cat << EOF
mj.sh v${VERSION} - Trello JSON to mJSON converter

Usage:
    mj.sh [OPTIONS]

Options:
    --output <file>     Save output to file (default: stdout)
    --input <file>      Use specific JSON file (default: find *all-projects.json on Desktop)
    --member <username> Filter cards by team member (Trello username)
    --status <name>     Filter cards by status (case-insensitive, partial match)
    --compact           Minimal output (exclude description)
    --version           Show version
    --help              Show this help

Examples:
    # Convert all-projects.json from Desktop to stdout
    mj.sh

    # Save to file
    mj.sh --output board_overview.json

    # Filter by member
    mj.sh --member slavaaq --output slava_tasks.json

    # Filter by status
    mj.sh --status "In Progress" --output in_progress.json
    mj.sh --status review --output review_tasks.json

    # Combine filters
    mj.sh --member slavaaq --status "In Progress" --output slava_in_progress.json
    mj.sh --member slavaaq --compact --output slava_compact.json

    # Use specific input file
    mj.sh --input ~/Downloads/backup.json --output result.json

EOF
}

# Парсинг аргументов
INPUT_FILE=""
OUTPUT_FILE=""
COMPACT_MODE=false
MEMBER_FILTER=""
STATUS_FILTER=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --input)
            INPUT_FILE="$2"
            shift 2
            ;;
        --compact)
            COMPACT_MODE=true
            shift
            ;;
        --member)
            MEMBER_FILTER="$2"
            shift 2
            ;;
        --status)
            STATUS_FILTER="$2"
            shift 2
            ;;
        --version)
            echo "mj.sh v${VERSION}"
            exit 0
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            error "Unknown option: $1\nUse --help for usage information"
            ;;
    esac
done

# Основная логика
main() {
    check_dependencies
    
    # Определяем входной файл
    if [[ -z "$INPUT_FILE" ]]; then
        INPUT_FILE=$(find_all_projects_json)
        warn "Using: $INPUT_FILE"
    fi
    
    # Проверяем существование файла
    if [[ ! -f "$INPUT_FILE" ]]; then
        error "Input file not found: $INPUT_FILE"
    fi
    
    # Конвертируем
    convert_to_mjson "$INPUT_FILE" "$OUTPUT_FILE" "$COMPACT_MODE" "$MEMBER_FILTER" "$STATUS_FILTER"
}

main
