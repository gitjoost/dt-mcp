# Available Tools

## Database & Navigation

| Tool | Description |
|------|-------------|
| `list_databases` | List all open DEVONthink databases |
| `search` | Search records with optional database filter |
| `get_record` | Get record metadata by UUID |
| `get_record_content` | Get record content (plain/markdown/html) |
| `get_record_children` | Get children of a group |
| `get_selection` | Get currently selected records |

## Record Management

| Tool | Description |
|------|-------------|
| `create_record` | Create a new record |
| `create_group` | Create a new group |
| `update_record` | Update record properties |
| `move_record` | Move record to another group |
| `delete_record` | Move record to trash |
| `duplicate_record` | Duplicate a record |
| `replicate_record` | Create a replicant |

## Tags & Metadata

| Tool | Description |
|------|-------------|
| `get_tags` | Get all tags in a database |
| `set_record_tags` | Set tags (replaces existing) |
| `add_record_tags` | Add tags to a record |
| `remove_record_tags` | Remove tags from a record |
| `get_custom_metadata` | Get custom metadata |
| `set_custom_metadata` | Set custom metadata |

## AI Features

| Tool | Description |
|------|-------------|
| `classify` | Get classification suggestions |
| `see_also` | Find similar records |
| `summarize` | Get document summary |
| `get_concordance` | Get word concordance |

## Web Operations

| Tool | Description |
|------|-------------|
| `create_bookmark` | Create a bookmark |
| `download_url` | Download URL as web archive |
| `download_markdown` | Download URL as Markdown |

## Links & References

| Tool | Description |
|------|-------------|
| `get_item_url` | Get x-devonthink-item:// URL |
| `get_incoming_links` | Get incoming references |
| `get_outgoing_links` | Get outgoing references |

## Database Operations

| Tool | Description |
|------|-------------|
| `get_database` | Get database details |
| `open_database` | Open a database file |
| `close_database` | Close a database |
| `verify_database` | Verify database integrity |
| `optimize_database` | Optimize database |

## Import/Export & OCR

| Tool | Description |
|------|-------------|
| `import_file` | Import a file into DEVONthink |
| `export_record` | Export record to filesystem |
| `ocr_file` | OCR a file and import |
| `convert_to_searchable_pdf` | Convert to searchable PDF |

## Windows & UI

| Tool | Description |
|------|-------------|
| `get_windows` | List open windows |
| `open_record` | Open record in new tab |
| `open_window` | Open new window |
| `get_current_record` | Get currently viewed record |

## Other

| Tool | Description |
|------|-------------|
| `get_reminders` | Get record reminders |
| `set_reminder` | Set a reminder |
| `clear_reminder` | Remove a reminder |
| `get_smart_groups` | List smart groups |
| `get_smart_group_contents` | Get smart group results |
| `get_trash` | Get trash contents |
| `empty_trash` | Empty database trash |
| `get_annotations` | Get record annotations |
| `get_replicants` | Get record parent locations |
| `get_duplicates` | Find duplicate records |

## Content Extraction Notes

When retrieving record content via `get_record_content`:

- **PDFs**: Only the extracted text is sent, not the raw PDF file. This keeps responses lightweight and avoids transmitting large binary files.
- **Embedded images**: Images embedded within PDFs are not extracted or sent. This means image content within PDFs is not searchable or accessible via MCP.
- **Other formats**: Text-based formats (Markdown, RTF, plain text) are sent as-is.
