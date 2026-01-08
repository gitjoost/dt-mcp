# dt-mcp

An MCP (Model Context Protocol) server for [DEVONthink](https://www.devontechnologies.com/apps/devonthink), enabling AI assistants like Claude to interact with your DEVONthink databases.

V0.5.0

## Features

- **Database Operations**: List databases, search records, navigate groups
- **Record Management**: Create, read, update, and organize records
- **Content Access**: Get record content in plain text, Markdown, or HTML
- **AI Features**: Classify documents, find similar records, summarize, concordance
- **Web Capture**: Create bookmarks, download web pages as archives or Markdown
- **Metadata**: Tags, labels, ratings, custom metadata, reminders
- **Links**: Item links, incoming/outgoing references
- **Privacy**: Tag documents as `PRIVATE` to anonymize PII before sending to LLM

## Quick Start

1. Download the latest binary from [Releases](../../releases)
2. Add to your MCP client config:
   ```json
   {
     "mcpServers": {
       "dt-mcp": {
         "command": "/path/to/dt-mcp"
       }
     }
   }
   ```
3. Start DEVONthink and ask Claude: "List my DEVONthink databases"

## Documentation

- [Installation & Configuration](docs/installation.md)
- [Available Tools](docs/tools.md)
- [Examples](docs/examples.md)
- [Privacy Features](docs/privacy.md)
- [Troubleshooting](docs/troubleshooting.md)

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

## License

Copyright 2025-2026 Intellecy Inc.

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.

## Disclaimer

This project is not affiliated with or endorsed by DEVONtechnologies, LLC. DEVONthink is a registered trademark of DEVONtechnologies.
