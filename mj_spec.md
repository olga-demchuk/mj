# Спецификация mj.sh

**Версия:** 0.4.2  
**Обновлено:** 26 ноября 2025  
**Репозиторий:** https://github.com/olga-demchuk/mj

---

## Обзор

mj.sh — bash-скрипт для преобразования Trello JSON экспортов в компактный mJSON формат для ПМ-анализа.

**Ключевые преимущества:**
- Работает с локальными JSON-экспортами (не требует API)
- 34MB Trello JSON → 106KB mJSON (компрессия ~300x)
- С флагом --compact: 56KB (компрессия ~600x)
- Чистая семантичная структура данных
- Единственная зависимость: jq

---

## Установка

```bash
# Из GitHub
curl -o mj.sh https://raw.githubusercontent.com/olga-demchuk/mj/main/mj.sh
chmod +x mj.sh
mv mj.sh /usr/local/bin/mj.sh

# Проверка
mj.sh --version
```

---

## Использование

```bash
mj.sh [OPTIONS]

OPTIONS:
  --input <file>      Путь к Trello JSON файлу
                      По умолчанию: ищет *all-projects.json на Desktop
  
  --output <file>     Путь к выходному mJSON файлу
                      По умолчанию: stdout
  
  --member <username> Фильтр по участнику (Trello username)
  
  --status <name>     Фильтр по статусу (частичное совпадение, регистронезависимо)
  
  --compact           Минимальный вывод (без description, checklists, 
                      attachments, linkedCards, activity)
  
  --version           Показать версию
  --help              Показать справку
```

**Примеры:**

```bash
# Все активные карточки
mj.sh --output board.json

# Карточки участника
mj.sh --member slavaaq --output slava.json

# Карточки в статусе (частичное совпадение)
mj.sh --status "In Progress" --output in_progress.json
mj.sh --status todo --output todo.json

# Комбинация фильтров
mj.sh --member petrovmichael1 --status "In Progress" --output petrov_ip.json

# Компактный вывод для быстрого анализа
mj.sh --compact --output board_compact.json
```

---

## Формат mJSON

### Полный формат (по умолчанию)

```json
{
  "id": "67053c24b2e398461bb5e3fc",
  "name": "LV-6401 Mark photographs",
  "url": "https://trello.com/c/Dw8Y7j2C",
  "status": "Testing",
  
  "description": "Create a new directory in project root...",
  
  "checklists": [
    {
      "id": "checklist_id",
      "name": "Notes",
      "items": [
        {
          "id": "item_id",
          "text": "Let's remove leading and trailing whitespace",
          "checked": true
        }
      ]
    }
  ],
  
  "attachments": [
    {
      "id": "attach_id",
      "name": "image.png",
      "url": "https://trello.com/1/cards/.../attachments/.../download/image.png",
      "addedAt": "2025-11-11T17:31:00Z",
      "addedBy": "slavaaq"
    }
  ],
  
  "linkedCards": [
    {
      "id": "linked_card_id",
      "name": "3229-kylesogoodteamcomreporting-pulling-non-existing-grids",
      "url": "https://trello.com/c/TduZ664l/..."
    }
  ],
  
  "activity": [
    {
      "type": "updateCard",
      "date": "2025-11-21T10:38:51.323Z",
      "user": "slavaaq",
      "data": {
        "from": "To Final Verification",
        "to": "Recently Released"
      }
    },
    {
      "type": "commentCard",
      "date": "2025-11-24T19:25:37.041Z",
      "user": "r_av66",
      "data": {
        "text": "it seems that posts feature has been fixed"
      }
    }
  ],
  
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

### Компактный формат (--compact)

При использовании `--compact` исключаются:
- description
- checklists
- attachments
- linkedCards
- activity

Остаются только критичные поля для быстрого анализа статусов и назначений.

---

## Описание полей

### Базовые поля

| Поле | Тип | Описание |
|------|-----|----------|
| id | string | Технический ID карточки Trello |
| name | string | Оригинальное название (как в Trello) |
| url | string | shortUrl карточки |
| status | string | Название списка (list.name) |
| assignees | string[] | Массив Trello usernames участников |
| labels | string[] | Массив названий меток |
| project | string\|null | Custom field "Project" (LV, WTRC, SRP, etc.) |
| effort | string\|null | Custom field "Effort" |
| priority | string\|null | Custom field "Priority" |
| pr | string[] | Массив URL на GitHub PR |
| created | string | dateLastActivity (UTC ISO) |
| updated | string | dateLastActivity (UTC ISO) |
| due | string\|null | Дедлайн (UTC ISO или null) |
| archived | boolean | Статус архивации |
| isMirror | boolean | Признак mirror-карточки |

### Расширенные поля (исключаются в --compact)

| Поле | Тип | Описание |
|------|-----|----------|
| description | string | Markdown описание карточки |
| checklists | array | Чеклисты с items |
| attachments | array | Файлы с метаданными (без PR и linkedCards) |
| linkedCards | array | Ссылки на другие карточки Trello |
| activity | array | Лента событий (отсортировано по дате, новые первые) |

---

## Activity Types

Поддерживаемые типы событий в поле `activity`:

| Тип | data | Описание |
|-----|------|----------|
| commentCard | {text} | Комментарий |
| updateCard | {from, to} | Смена статуса |
| updateCheckItemStateOnCard | {checkItem, state} | Изменение пункта чеклиста |
| addMemberToCard | {member} | Добавление участника |
| removeMemberFromCard | {member} | Удаление участника |
| addAttachmentToCard | {attachment} | Добавление вложения |
| deleteAttachmentFromCard | {attachment} | Удаление вложения |
| addChecklistToCard | {checklist} | Добавление чеклиста |
| updateCustomFieldItem | {field} | Изменение custom field |
| moveCardFromBoard | {fromList} | Перемещение с другой доски |
| createCard | {list} | Создание карточки |

События `updateCard` без смены статуса (только изменение позиции) отфильтровываются.

---

## Технические детали

### Mirror Card Detection

Mirror-карточки определяются по полю `cardRole`:
```javascript
card.cardRole === "mirror"
```

**Важно:** У mirror-карточек `idMembers` пустой, поэтому фильтр `--member` их не найдёт.

### Custom Fields Extraction

Trello хранит custom fields как связь через IDs. mj.sh делает двойной lookup:
1. Найти customField по `idCustomField` → получить тип и options
2. Для list-типа: найти option по `idValue` → получить `.value.text`

### PR Extraction

PR извлекаются из attachments по фильтру:
```
url contains "github.com" AND contains "/pull/"
```

### Attachments Separation

Attachments разделяются на три категории:
- **pr** — GitHub PR ссылки (в отдельное поле)
- **linkedCards** — Trello card ссылки (в отдельное поле)
- **attachments** — остальные файлы

---

## Ограничения

### Trello JSON Export

- Экспорт включает только **последние 1000 actions** для всей доски
- Для карточек с длинной историей activity будет неполным
- PDF карточки Trello содержит полную историю

### Mirror Cards

- Mirror-карточки не содержат assignees
- Для полного resolve mirrors требуется загрузка source досок

---

## Зависимости

**Обязательные:**
- bash 4.0+
- jq (JSON processor)

**Установка jq:**
```bash
# macOS
brew install jq

# Ubuntu/Debian
apt install jq
```

---

## Changelog

См. полный [CHANGELOG.md](https://github.com/olga-demchuk/mj/blob/main/CHANGELOG.md)

### v0.4.2 (2025-11-26)
- Добавлены activity types: updateCustomFieldItem, moveCardFromBoard

### v0.4.1 (2025-11-26)
- Добавлен activity type: deleteAttachmentFromCard

### v0.4.0 (2025-11-26)
- Добавлено поле activity с unified timeline (11 типов событий)

### v0.3.3 (2025-11-26)
- Добавлено поле linkedCards

### v0.3.2 (2025-11-26)
- Добавлено поле attachments с метаданными

### v0.3.1 (2025-11-26)
- Добавлено поле checklists

### v0.3.0 (2025-11-26)
- Добавлен флаг --status

### v0.2.1 (2025-11-26)
- Исправлено определение mirror cards (cardRole вместо name prefix)

### v0.2.0 (2025-11-26)
- Добавлены флаги --compact, --member
- Добавлено поле description

### v0.1.0 (2025-11-26)
- Initial release
