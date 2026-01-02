# dt-mcp

An MCP (Model Context Protocol) server for [DEVONthink](https://www.devontechnologies.com/apps/devonthink), enabling AI assistants like Claude to interact with your DEVONthink databases. The most excellent DEVONthink application version 4 does have a 'chat' feature that permits one to interact with an LLM, so why an MCP then? See below but first an important aspect of this MCP server vs DEVONthink's chat feature.

## Privacy

Having an LLM/AI work with your documents means these are sent to the LLM provider's servers. Your data, potentially private, goes off-site. You may not want that.

DEVONthink's built-in chat does NOT send original documents to the LLM—metadata is stripped and images are processed. That's an enormous privacy benefit.

**This MCP server now offers similar protection via the `PRIVATE` tag:**

| Document Type | What Gets Sent to LLM |
|---------------|----------------------|
| Regular documents | Full content as-is |
| `PRIVATE`-tagged documents | Anonymized content with PII tokenized |

### How PRIVATE Tag Works

Tag any document with `PRIVATE` (case-insensitive) in DEVONthink, and when accessed via this MCP:

1. **PII is tokenized** - sensitive data is replaced with HMAC-encoded tokens:
   - Emails → `[EM:xxxxxxxx]`
   - Phone numbers → `[PH:xxxxxxxx]`
   - Credit cards → `[CC:xxxxxxxx]`
   - SSN → `[SS:xxxxxxxx]`
   - Account numbers/IDs → `[NN:xxxxxxxx]`

2. **Metadata is stripped** - author, dates, paths, URLs, comments are removed

3. **Tokens are correlatable** - the LLM can still understand "these 3 emails are from the same person" without seeing the actual address

4. **Tokens are decodable** - original values are stored locally in `~/.config/dt-mcp/token_cache.json` for later retrieval

**What stays local:**
- Actual email addresses, phone numbers, SSNs, credit cards
- DEVONthink searches (run locally with real values)
- Token-to-original mappings

**What goes to LLM:**
- Tokenized content (meaningless without local key)
- Document names and non-PII text

## dt-mcp vs DEVONthink Built-in Chat

  | Aspect | dt-mcp | DEVONthink Chat |
  |--------|--------|-----------------|
  | Integration | External via MCP protocol | Native in DEVONthink UI |
  | LLM Provider | Any MCP client (Claude, etc.) | OpenAI API or local LLMs |
  | Scope | Programmatic access to all DT operations | Conversation about documents |
  | Actions | Can create, move, tag, search, modify records | Read-only Q&A about content |

### dt-mcp Pros
- **Model flexibility** - Use Claude, GPT-4, local models, any MCP-compatible client
- **Write operations** - Create records, set tags, move files, not just read
- **Automation** - Chain operations, batch processing, integrate into workflows
- **Context sharing** - AI assistant can access DT data alongside other tools/files
- **Extensible** - Add custom tools as needed

### dt-mcp Cons
- **Setup complexity** - Requires MCP client configuration
- **No native UI** - Operates through external chat interface
- **Requires running server** - Additional process to manage

### DEVONthink Chat Pros
- **Zero setup** - Built into the app
- **Tight UI integration** - Select documents, chat in sidebar
- **Document focus** - Optimized for discussing specific documents

### DEVONthink Chat Cons
- **Read-only** - Cannot modify database through chat
- **Limited to OpenAI/local** - No Claude or other providers
- **Siloed** - Can't combine with other data sources in one conversation
- **No automation** - Pure conversational, no programmatic control

## Examples
#### Using Tools

  You can call tools directly by name:

  > "Call list_databases"

  Or simply use natural language - the AI will determine which tool to use:

  > "What databases do I have?"

  Both achieve the same result. The AI interprets your intent and calls the appropriate dt-mcp tool automatically.

#### Simple interactions
 **Find and summarize recent notes**

  Search your database for notes on a topic and get a quick summary. Assume the database is called 'projects'

  > "Search projects for notes about 'project planning' and summarize the key points."

 **Create a meeting note**

  Quickly capture meeting notes directly into DEVONthink with proper tagging.

  > "Create a new markdown note in DEVONthink called 'Team Sync 2024-12-24' with tags 'meetings' and 'work'. Include these discussion points: budget review, Q1 goals, hiring timeline."

  **Analyze selected document**

  Work with whatever document you currently have selected in DEVONthink.

  > "Look at my currently selected document in DEVONthink and extract all action items or tasks mentioned."
  
#### Cross-Tool Examples

  **Import project documentation**

  Scan a codebase and import relevant docs into DEVONthink.

  > "Find all README and markdown files in ~/Projects/myapp and import them into my 'Development' database in DEVONthink."

  **Research with web + archive**

  Combine live web search with your personal knowledge base.

  > "Search the web for 'Swift concurrency best practices' and also check what I have in DEVONthink on this topic. Compare the findings."

  **Export for version control**

  Pull content from DEVONthink into your project.

  > "Get the API specification document from DEVONthink and save it as docs/api-spec.md in my current project."

  **Patent prior art search**

  When an engineer has a new idea, check it against your patent database for potential conflicts.

  > "I have an idea for a 'wireless charging system that uses resonant inductive coupling with automatic frequency tuning to optimize power transfer based on device distance.' Search my 'patents & ip' database for similar patents and tell me if this concept appears to already be covered."

  The AI will search your patent database, use DEVONthink's "see also" to find conceptually similar documents, analyze matching patents, and flag potential prior art.

## Features

- **Database Operations**: List databases, search records, navigate groups
- **Record Management**: Create, read, update, and organize records
- **Content Access**: Get record content in plain text, Markdown, or HTML
- **AI Features**: Classify documents, find similar records, summarize, concordance
- **Web Capture**: Create bookmarks, download web pages as archives or Markdown
- **Metadata**: Tags, labels, ratings, custom metadata, reminders
- **Links**: Item links, incoming/outgoing references


## Requirements

- macOS 14.0 or later
- [DEVONthink 3](https://www.devontechnologies.com/apps/devonthink) or DEVONthink 4
- DEVONthink must be running when using the MCP server

## Installation

### Option 1: Download Pre-built Binary
I take it most have little appetite to compile the code, certainly if Xcode is not installed. So
therefore this binary. It is notarized by Apple so it should run without warnings.

1. Download the latest release from the [Releases](../../releases) page
2. If you want, verify the download:
   ```bash
   shasum -a 256 -c dt-mcp-vX.Y.Z-macos.zip.sha256
   ```
3. Unzip and move `dt-mcp` to a permanent location, e.g., `/usr/local/bin/` or `~/.local/bin/`


### Option 2: Build from Source

Requires Xcode Command Line Tools or Xcode with Swift 5.9+.

```bash
# Clone the repository
git clone https://github.com/Intellecy-Inc/dt-mcp.git
cd dt-mcp

# Build release binary
swift build -c release

# Binary location: .build/release/dt-mcp
```

## Configuration

### Claude Code

Add to your project's `.mcp.json` or global `~/.claude/mcp.json`:

```json
{
  "mcpServers": {
    "dt-mcp": {
      "command": "/path/to/dt-mcp"
    }
  }
}
```

Then restart Claude Code or run `/mcp` to reload servers.

### Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "dt-mcp": {
      "command": "/path/to/dt-mcp"
    }
  }
}
```

## Available Tools in dt-mcp

### Database & Navigation
| Tool | Description |
|------|-------------|
| `list_databases` | List all open DEVONthink databases |
| `search` | Search records with optional database filter |
| `get_record` | Get record metadata by UUID |
| `get_record_content` | Get record content (plain/markdown/html) |
| `get_record_children` | Get children of a group |
| `get_selection` | Get currently selected records |

### Record Management
| Tool | Description |
|------|-------------|
| `create_record` | Create a new record |
| `create_group` | Create a new group |
| `update_record` | Update record properties |
| `move_record` | Move record to another group |
| `delete_record` | Move record to trash |
| `duplicate_record` | Duplicate a record |
| `replicate_record` | Create a replicant |

### Tags & Metadata
| Tool | Description |
|------|-------------|
| `get_tags` | Get all tags in a database |
| `set_record_tags` | Set tags (replaces existing) |
| `add_record_tags` | Add tags to a record |
| `remove_record_tags` | Remove tags from a record |
| `get_custom_metadata` | Get custom metadata |
| `set_custom_metadata` | Set custom metadata |

### AI Features
| Tool | Description |
|------|-------------|
| `classify` | Get classification suggestions |
| `see_also` | Find similar records |
| `summarize` | Get document summary |
| `get_concordance` | Get word concordance |

### Web Operations
| Tool | Description |
|------|-------------|
| `create_bookmark` | Create a bookmark |
| `download_url` | Download URL as web archive |
| `download_markdown` | Download URL as Markdown |

### Links & References
| Tool | Description |
|------|-------------|
| `get_item_url` | Get x-devonthink-item:// URL |
| `get_incoming_links` | Get incoming references |
| `get_outgoing_links` | Get outgoing references |

### Database Operations
| Tool | Description |
|------|-------------|
| `get_database` | Get database details |
| `open_database` | Open a database file |
| `close_database` | Close a database |
| `verify_database` | Verify database integrity |
| `optimize_database` | Optimize database |

### Import/Export & OCR
| Tool | Description |
|------|-------------|
| `import_file` | Import a file into DEVONthink |
| `export_record` | Export record to filesystem |
| `ocr_file` | OCR a file and import |
| `convert_to_searchable_pdf` | Convert to searchable PDF |

### Windows & UI
| Tool | Description |
|------|-------------|
| `get_windows` | List open windows |
| `open_record` | Open record in new tab |
| `open_window` | Open new window |
| `get_current_record` | Get currently viewed record |

### Other
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

## Usage Examples

Once configured, you can ask Claude questions like:

- "List my DEVONthink databases"
- "Search for documents about machine learning"
- "Show me the contents of [record name]"
- "Create a new markdown note called 'Meeting Notes' in the Inbox"
- "What tags are in my research database?"
- "Find documents similar to this one"

## Troubleshooting

### Server not connecting
- Ensure DEVONthink is running
- Check the path in your MCP configuration is correct
- Run `/mcp` in Claude Code to reload servers

### Permission errors
- DEVONthink may prompt for automation permission on first use
- Grant permission in System Settings > Privacy & Security > Automation

### macOS blocking the binary
- Right-click the binary and select "Open"
- Or: `xattr -d com.apple.quarantine /path/to/dt-mcp`

## License

Copyright 2025 Intellecy Inc.

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.

## Disclaimer

This project is not affiliated with or endorsed by DEVONtechnologies, LLC. DEVONthink is a registered trademark of DEVONtechnologies.

