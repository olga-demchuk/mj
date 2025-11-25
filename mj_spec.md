# Спецификация mj.sh

**Обновлено:** 25 ноября 2025  
**Статус:** В разработке  
**Цель:** Преобразование Trello JSON экспортов в компактный mJSON формат

---

## Контекст

mj.sh - bash-скрипт для преобразования Trello JSON экспортов в компактный mJSON формат для ПМ-анализа. Заменяет makejson.sh с улучшенной архитектурой и упрощённым форматом вывода.

**Ключевые преимущества:**
- Работает с локальными JSON-экспортами (не требует API)
- 34MB Trello JSON → 106KB mJSON (в 300 раз меньше)
- Чистая семантичная структура данных
- Минимум зависимостей (только jq)

---

## Источник данных

**Trello JSON Export:**
- Экспорт через UI: Board menu → Print and Export → Export as JSON
- Файл по умолчанию: `*all-projects.json` на Desktop
- Структура: single JSON объект с массивами `cards`, `lists`, `members`, `labels`, `customFields`, `actions`

**Дополнительные доски для resolve mirrors:**
- `lindai-chat.json`
- `web20-ranker.json`
- `web20-mobile.json`
- `customer-support.json`

---

## Формат mJSON

Упрощённый плоский формат с минимумом вложенности.

### Базовый формат (по умолчанию)

```json
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
  
  "pr": [
    "https://github.com/trafficrunners/gmbmanager/pull/5235"
  ],
  
  "created": "2024-10-08T10:23:45.120Z",
  "updated": "2024-11-25T09:15:33.840Z",
  "due": null,
  
  "archived": false,
  "isMirror": false
}
```

**Поля:**
- `id` - технический ID карточки
- `name` - оригинальное название (как в Trello, без изменений)
- `url` - shortUrl карточки
- `status` - название списка (list.name)
- `assignees` - массив username участников (Trello usernames)
- `labels` - массив названий меток
- `project` - значение customFields.Project (LV, WTRC, SRP, etc.)
- `effort` - значение customFields.Effort ("small task", "a day", "few days", "a week", null)
- `priority` - значение customFields.Priority ("High", "Medium", "Low", null)
- `pr` - массив URL на GitHub PR (из attachments)
- `created` - дата создания карточки (UTC)
- `updated` - dateLastActivity (UTC)
- `due` - дедлайн (UTC или null)
- `archived` - closed статус (boolean)
- `isMirror` - признак mirror-карточки (boolean)

### Расширенный формат (--include-details)

```json
{
  ...базовые поля...,
  
  "description": "Create a new directory in project root for form tracking widget.\n\nThe goal of the widget is to track form submits...\n\n## UPDATE: Deployment\n\nAccording to discussion...",
  
  "attachments": [
    {
      "id": "attach_id",
      "name": "image.png",
      "url": "...",
      "addedAt": "2025-11-11T17:31:00Z",
      "addedBy": "slavaaq"
    }
  ],
  
  "linkedCards": [
    {
      "id": "linked_card_id",
      "name": "Customer Support",
      "url": "https://trello.com/c/...",
      "status": "Done 🎉"
    }
  ],
  
  "checklists": [
    {
      "id": "checklist_id",
      "name": "Notes",
      "items": [
        {
          "id": "item_id",
          "text": "Let's remove leading and trailing whitespace",
          "checked": true,
          "completedAt": "2025-11-11T17:26:00Z",
          "completedBy": "slavaaq"
        }
      ]
    }
  ]
}
```

**Дополнительные поля:**
- `description` - markdown описание карточки (сохраняется 1:1)
- `attachments` - массив файлов с метаданными
- `linkedCards` - массив связанных карточек со статусами
- `checklists` - массив чек-листов с элементами

### Компактный формат (--compact)

При использовании флага `--compact` исключаются:
- `description`
- `attachments`
- `linkedCards`
- `checklists`
- `activity` (когда будет реализовано)

Остаются только критичные поля для быстрого анализа.

---

## Архитектура mj.sh v0.1

Единый bash скрипт с функциями, разделёнными по ответственности.

### Текущая реализация (v0.1.0)

```bash
#!/bin/bash

VERSION="0.1"

# Поиск входного файла
find_input_file() {
    # Ищет *all-projects.json на Desktop
    # Или использует --input параметр
}

# Основная обработка
process_cards() {
    # 1. Создаёт lookup tables (lists, members, labels, customFields)
    # 2. Фильтрует незаархивированные карточки
    # 3. Denormalization: ID → читаемые названия
    # 4. Извлекает custom fields (Project, Effort, Priority)
    # 5. Находит PR в attachments
    # 6. Определяет mirror-карточки по префиксу [MIRROR]
    # 7. Форматирует в mJSON
}

main() {
    # Парсинг аргументов
    # Вызов process_cards
    # Вывод результата
}
```

### Roadmap развития

**v0.1.0** (готово) ✅
- Базовая конвертация Trello JSON → mJSON
- Извлечение custom fields (Project, Effort, Priority)
- Поиск PR в attachments
- Фильтрация архивных карточек
- Определение mirror-карточек

**v0.2.0** - Фильтрация
- `--member <username>` - карточки участника
- `--status <name>` - карточки в статусе
- `--labels <names>` - карточки с метками
- `--project <name>` - карточки проекта
- `--compact` - минимальный вывод (без description, checklists, attachments)

**v0.3.0** - Расширенные поля
- `--include-details` - добавить description, checklists, attachments, linkedCards
- `--include-archived --archived-days N` - включить архивные карточки

**v0.4.0** - Activity
- `--include-activity` - добавить единую ленту событий

**v1.0.0** - Stable Release
- Полный feature set
- Comprehensive documentation
- Migration guide from makejson.sh

---

## API mj.sh

### Текущая версия (v0.1.0)

```bash
mj.sh [OPTIONS]

OPTIONS:
  --input <file>      Путь к Trello JSON файлу
                      По умолчанию: ищет *all-projects.json на Desktop
  
  --output <file>     Путь к выходному mJSON файлу
                      По умолчанию: stdout
  
  --version           Показать версию
  --help              Показать справку
```

**Примеры:**

```bash
# Автоматический поиск *all-projects.json на Desktop
mj.sh --output board_overview.json

# Использование конкретного файла
mj.sh --input ~/Downloads/board.json --output result.json

# Вывод в stdout
mj.sh
```

### Планируемые опции (v0.2+)

```bash
# Фильтрация
--member <username>           Карточки участника
--status <name>               Карточки в статусе
--labels <names>              Карточки с метками (через запятую)
--project <name>              Карточки проекта

# Детализация
--include-details             Добавить description, checklists, attachments, linkedCards
--include-activity            Добавить ленту событий
--compact                     Минимальный вывод (только критичные поля)

# Архивные
--include-archived            Включить архивные карточки
--archived-days N             Архивные за последние N дней
```

---

## Типовые задачи ПМ

### Утренняя рутина

```bash
# Обзор доски (все активные карточки)
mj.sh --output ~/Desktop/pm-reports/board_overview_$(date +%Y%m%d).json

# Статистика по проектам и статусам
jq -r 'group_by(.project) | map({project: .[0].project, count: length})' \
  board_overview_$(date +%Y%m%d).json
```

### Анализ по участникам (v0.2+)

```bash
# Задачи конкретного участника
mj.sh --member slavaaq --output slava_$(date +%Y%m%d).json

# Задачи в Testing
mj.sh --status Testing --output testing_$(date +%Y%m%d).json

# Неназначенные задачи
mj.sh --unassigned --output unassigned_$(date +%Y%m%d).json
```

### Анализ дельты

```bash
# Сегодняшний snapshot
mj.sh --output board_$(date +%Y%m%d).json

# Сравнение с вчерашним
jq --slurpfile old board_20251124.json '
  . as $new |
  $old[0] as $old_cards |
  [.[] | . as $card |
    ($old_cards[] | select(.id == $card.id)) as $old_card |
    select($old_card.status != $card.status) |
    {
      name: .name,
      was: $old_card.status,
      now: .status
    }
  ]
' board_20251125.json
```

---

## Технические детали

### Custom Fields Extraction

Trello хранит custom fields как связь через IDs:
```json
{
  "customFieldItems": [
    {
      "idCustomField": "62836ba8aeb8ea3345cbbb9b",
      "idValue": "628e477ba73d2e5eab85a389"
    }
  ]
}
```

mj.sh делает двойной lookup:
1. Найти customField по `idCustomField` → получить тип и options
2. Для list-типа: найти option по `idValue` → получить `.value.text`

Результат: `"project": "SRP"`

### Mirror Card Detection

Mirror-карточки определяются по префиксу в названии:
- `^[MIRROR]` - старый формат
- `^MIRROR:` - новый формат

Поле `isMirror` устанавливается в `true` для таких карточек.

### PR Extraction

PR извлекаются из attachments:
```json
{
  "attachments": [
    {
      "url": "https://github.com/trafficrunners/gmbmanager/pull/5235"
    }
  ]
}
```

Фильтр: `url contains "github.com" and contains "/pull/"`

---

## Зависимости

**Обязательные:**
- `bash` 4.0+
- `jq` - JSON processor (brew install jq)

**Опциональные (для будущих версий):**
- `curl` - для GitHub enrichment
- `git` - для git diff анализа

---

## Нерешённые вопросы

### Автоинкремент

Пока не трогаем. Какое `name` есть в Trello, такое выводим в mJSON. Разберёмся позже с:
- Извлечением номера из name
- Проблемой сломанного автоинкремента
- Кастомным полем с LV-XXXX

### Activity format

Нужно определить:
- Типы событий для включения
- Формат представления каждого типа
- Сортировку и группировку

### Resolve mirrors

Для полного resolve mirrors потребуется:
- Загрузка дополнительных JSON досок
- Поиск source карточки по shortUrl
- Копирование данных из source в mirror

### GitHub enrichment

Детали для будущих версий:
- Формат поля `reviews`
- Формат поля `ci`
- Обработка git diff

---

## Обратная совместимость

**С makejson.sh:**
- mj.sh использует другую архитектуру (JSON exports вместо multiple JSON files)
- Формат вывода несовместим (новый формат mJSON vs старый mJSON v3.x)
- Миграция: использовать оба скрипта параллельно, затем переключиться

**Между версиями mj.sh:**
- Базовый формат (v0.1) останется совместимым
- Новые поля добавляются опционально (через флаги)
- Breaking changes только в major версиях (v1.0 → v2.0)

---

## Changelog

### v0.1.0 (2024-11-25)

**Added:**
- Initial release
- Basic conversion Trello JSON → mJSON
- Custom fields extraction (Project, Effort, Priority)
- GitHub PR link detection in attachments
- Archived cards filtering
- Mirror card detection by name prefix
- Command-line options: `--input`, `--output`, `--version`, `--help`
- Automatic search for `*all-projects.json` on Desktop

**Features:**
- Converts 30+ MB Trello exports to ~100 KB mJSON
- Supports custom field types: list, text, number, date, checkbox
- Extracts assignees, labels, status, dates
- Single bash script with jq dependency

---

## GitHub Repository

**Repository:** https://github.com/olga-demchuk/mj  
**Release:** v0.1.0  
**License:** MIT

**Installation:**
```bash
curl -o mj.sh https://raw.githubusercontent.com/olga-demchuk/mj/main/mj.sh
chmod +x mj.sh
sudo mv mj.sh /usr/local/bin/mj.sh
```

**Verification:**
```bash
mj.sh --version
# Output: mj.sh v0.1
```
