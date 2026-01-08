//
//  MCPServer+ToolDefinitions.swift
//  dt-mcp - MCP Server for DEVONthink
//
//  Copyright © 2025 Intellecy Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  NOTICE: This software integrates with DEVONthink, a product of
//  DEVONtechnologies, LLC. DEVONthink is a registered trademark of
//  DEVONtechnologies. This project is not affiliated with or endorsed
//  by DEVONtechnologies.
//

import Foundation

// MARK: - Tool Definitions

extension MCPServer {

  func getAvailableTools() -> [Tool] {
    return databaseToolDefinitions()
      + recordToolDefinitions()
      + contentToolDefinitions()
      + privacyToolDefinitions()
  }

  // MARK: - Database Tools

  func databaseToolDefinitions() -> [Tool] {
    return [
      Tool(
        name: "list_databases",
        description: "List all open DEVONthink (dt) databases",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([:] as [String: Any]),
          "required": AnyCodable([] as [String])
        ]
      ),
      Tool(
        name: "get_database",
        description: "Get DEVONthink (dt) database details by UUID",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Database UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "open_database",
        description: "Open a DEVONthink (dt) database file",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "path": ["type": "string", "description": "POSIX path to .dtBase2 file"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["path"])
        ]
      ),
      Tool(
        name: "close_database",
        description: "Close a DEVONthink (dt) database",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Database UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "verify_database",
        description: "Verify DEVONthink (dt) database integrity",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Database UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "optimize_database",
        description: "Optimize a DEVONthink (dt) database",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Database UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      )
    ]
  }

  // MARK: - Record Tools

  func recordToolDefinitions() -> [Tool] {
    return [
      Tool(
        name: "search",
        description: "Search for records in DEVONthink (dt)",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "query": ["type": "string", "description": "Search query"] as [String: Any],
            "database": ["type": "string", "description": "Database UUID (optional, searches all if omitted)"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["query"])
        ]
      ),
      Tool(
        name: "get_record",
        description: "Get DEVONthink (dt) record metadata by UUID",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "get_record_content",
        description: "Get DEVONthink (dt) record text content",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any],
            "format": ["type": "string", "description": "Content format: plain, markdown, html", "default": "plain"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "create_record",
        description: "Create a new record in DEVONthink (dt)",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "name": ["type": "string", "description": "Record name"] as [String: Any],
            "type": ["type": "string", "description": "Record type: markdown, txt, rtf, bookmark, group"] as [String: Any],
            "content": ["type": "string", "description": "Record content"] as [String: Any],
            "database": ["type": "string", "description": "Database UUID"] as [String: Any],
            "destination": ["type": "string", "description": "Destination group UUID (optional)"] as [String: Any],
            "tags": ["type": "array", "items": ["type": "string"] as [String: Any], "description": "Tags to apply"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["name", "database"])
        ]
      ),
      Tool(
        name: "get_selection",
        description: "Get currently selected records in DEVONthink (dt)",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([:] as [String: Any]),
          "required": AnyCodable([] as [String])
        ]
      ),
      Tool(
        name: "update_record",
        description: "Update DEVONthink (dt) record properties. Fails for PRIVATE-tagged documents (fully write-protected).",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any],
            "name": ["type": "string", "description": "New name"] as [String: Any],
            "comment": ["type": "string", "description": "Comment"] as [String: Any],
            "rating": ["type": "integer", "description": "Rating (0-5)"] as [String: Any],
            "label": ["type": "integer", "description": "Label index (0-7)"] as [String: Any],
            "flagged": ["type": "boolean", "description": "Flagged status"] as [String: Any],
            "unread": ["type": "boolean", "description": "Unread status"] as [String: Any],
            "content": ["type": "string", "description": "Plain text content"] as [String: Any],
            "url": ["type": "string", "description": "URL"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "delete_record",
        description: "Delete DEVONthink (dt) record (moves to trash). Fails for PRIVATE-tagged documents.",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "move_record",
        description: "Move DEVONthink (dt) record to a different group. Fails for PRIVATE-tagged documents.",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any],
            "to": ["type": "string", "description": "Destination group UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid", "to"])
        ]
      ),
      Tool(
        name: "duplicate_record",
        description: "Duplicate a DEVONthink (dt) record. Fails for PRIVATE-tagged documents.",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any],
            "to": ["type": "string", "description": "Destination group UUID (optional)"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "replicate_record",
        description: "Create a DEVONthink (dt) replicant of a record. Fails for PRIVATE-tagged documents.",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any],
            "to": ["type": "string", "description": "Destination group UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid", "to"])
        ]
      ),
      Tool(
        name: "get_record_children",
        description: "Get children of a DEVONthink (dt) group",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Group UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "get_tags",
        description: "Get all tags in a DEVONthink (dt) database",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "database": ["type": "string", "description": "Database UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["database"])
        ]
      ),
      Tool(
        name: "set_record_tags",
        description: "Set tags on DEVONthink (dt) record (replaces existing). Fails for PRIVATE-tagged documents.",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any],
            "tags": ["type": "array", "items": ["type": "string"] as [String: Any], "description": "Tags to set"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid", "tags"])
        ]
      ),
      Tool(
        name: "add_record_tags",
        description: "Add tags to DEVONthink (dt) record. Fails for PRIVATE-tagged documents.",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any],
            "tags": ["type": "array", "items": ["type": "string"] as [String: Any], "description": "Tags to add"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid", "tags"])
        ]
      ),
      Tool(
        name: "remove_record_tags",
        description: "Remove tags from DEVONthink (dt) record. Fails for PRIVATE-tagged documents (tag cannot be removed via MCP).",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any],
            "tags": ["type": "array", "items": ["type": "string"] as [String: Any], "description": "Tags to remove"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid", "tags"])
        ]
      ),
      Tool(
        name: "get_custom_metadata",
        description: "Get custom metadata of DEVONthink (dt) record",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "set_custom_metadata",
        description: "Set custom metadata on DEVONthink (dt) record. Fails for PRIVATE-tagged documents.",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any],
            "key": ["type": "string", "description": "Metadata key"] as [String: Any],
            "value": ["type": "string", "description": "Metadata value"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid", "key", "value"])
        ]
      ),
      Tool(
        name: "create_group",
        description: "Create a new group in DEVONthink (dt) database",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "name": ["type": "string", "description": "Group name"] as [String: Any],
            "database": ["type": "string", "description": "Database UUID"] as [String: Any],
            "parent": ["type": "string", "description": "Parent group UUID (optional, root if omitted)"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["name", "database"])
        ]
      ),
      Tool(
        name: "get_trash",
        description: "Get contents of DEVONthink (dt) database trash",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "database": ["type": "string", "description": "Database UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["database"])
        ]
      ),
      Tool(
        name: "empty_trash",
        description: "Empty DEVONthink (dt) database trash",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "database": ["type": "string", "description": "Database UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["database"])
        ]
      ),
      Tool(
        name: "get_current_record",
        description: "Get the currently viewed record in DEVONthink (dt)",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([:] as [String: Any]),
          "required": AnyCodable([] as [String])
        ]
      ),
      Tool(
        name: "get_annotations",
        description: "Get annotations linked to DEVONthink (dt) record",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "get_replicants",
        description: "Get all replicants of DEVONthink (dt) record",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "get_duplicates",
        description: "Get potential duplicate DEVONthink (dt) records",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      )
    ]
  }

  // MARK: - Content Tools

  func contentToolDefinitions() -> [Tool] {
    return [
      Tool(
        name: "import_file",
        description: "Import a file into DEVONthink (dt)",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "path": ["type": "string", "description": "POSIX path to file"] as [String: Any],
            "database": ["type": "string", "description": "Database UUID"] as [String: Any],
            "destination": ["type": "string", "description": "Destination group UUID (optional)"] as [String: Any],
            "name": ["type": "string", "description": "Override name (optional)"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["path", "database"])
        ]
      ),
      Tool(
        name: "export_record",
        description: "Export DEVONthink (dt) record to filesystem",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any],
            "path": ["type": "string", "description": "Destination POSIX path"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid", "path"])
        ]
      ),
      Tool(
        name: "classify",
        description: "Get DEVONthink (dt) suggested groups to classify a record into",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "see_also",
        description: "Find similar documents in DEVONthink (dt)",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any],
            "count": ["type": "integer", "description": "Number of results (default 10)"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "summarize",
        description: "Get DEVONthink (dt) AI summary of a record",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "get_concordance",
        description: "Get DEVONthink (dt) word frequency analysis of a record",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "ocr_file",
        description: "OCR a file and import into DEVONthink (dt) database",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "path": ["type": "string", "description": "POSIX path to image/PDF file"] as [String: Any],
            "database": ["type": "string", "description": "Database UUID"] as [String: Any],
            "destination": ["type": "string", "description": "Destination group UUID (optional)"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["path", "database"])
        ]
      ),
      Tool(
        name: "convert_to_searchable_pdf",
        description: "Convert DEVONthink (dt) record to searchable PDF using OCR",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "create_bookmark",
        description: "Create a bookmark to a URL in DEVONthink (dt)",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "url": ["type": "string", "description": "URL to bookmark"] as [String: Any],
            "name": ["type": "string", "description": "Bookmark name (optional)"] as [String: Any],
            "database": ["type": "string", "description": "Database UUID"] as [String: Any],
            "destination": ["type": "string", "description": "Destination group UUID (optional)"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["url", "database"])
        ]
      ),
      Tool(
        name: "download_url",
        description: "Download a URL as web archive into DEVONthink (dt)",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "url": ["type": "string", "description": "URL to download"] as [String: Any],
            "database": ["type": "string", "description": "Database UUID"] as [String: Any],
            "destination": ["type": "string", "description": "Destination group UUID (optional)"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["url", "database"])
        ]
      ),
      Tool(
        name: "download_markdown",
        description: "Download a URL as markdown into DEVONthink (dt)",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "url": ["type": "string", "description": "URL to download"] as [String: Any],
            "database": ["type": "string", "description": "Database UUID"] as [String: Any],
            "destination": ["type": "string", "description": "Destination group UUID (optional)"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["url", "database"])
        ]
      ),
      Tool(
        name: "get_incoming_links",
        description: "Get DEVONthink (dt) records that link to this record",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "get_outgoing_links",
        description: "Get DEVONthink (dt) records this record links to",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "get_item_url",
        description: "Get DEVONthink (dt) reference URL for a record",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "get_windows",
        description: "Get list of open DEVONthink (dt) windows",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([:] as [String: Any]),
          "required": AnyCodable([] as [String])
        ]
      ),
      Tool(
        name: "open_record",
        description: "Open DEVONthink (dt) record in a new tab",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "open_window",
        description: "Open a new DEVONthink (dt) window for a database",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "database": ["type": "string", "description": "Database UUID (optional)"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable([] as [String])
        ]
      ),
      Tool(
        name: "get_reminders",
        description: "Get DEVONthink (dt) reminders for a record or all records",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID (optional, gets all if omitted)"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable([] as [String])
        ]
      ),
      Tool(
        name: "set_reminder",
        description: "Set a reminder on DEVONthink (dt) record. Fails for PRIVATE-tagged documents.",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any],
            "date": ["type": "string", "description": "Reminder date (e.g., 'January 1, 2025')"] as [String: Any],
            "alarm": ["type": "boolean", "description": "Show alarm notification"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid", "date"])
        ]
      ),
      Tool(
        name: "clear_reminder",
        description: "Remove reminder from DEVONthink (dt) record. Fails for PRIVATE-tagged documents.",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Record UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      ),
      Tool(
        name: "get_smart_groups",
        description: "Get all smart groups in DEVONthink (dt) database",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "database": ["type": "string", "description": "Database UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["database"])
        ]
      ),
      Tool(
        name: "get_smart_group_contents",
        description: "Get DEVONthink (dt) records matching a smart group",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "uuid": ["type": "string", "description": "Smart group UUID"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["uuid"])
        ]
      )
    ]
  }

  // MARK: - Privacy Tools

  func privacyToolDefinitions() -> [Tool] {
    return [
      Tool(
        name: "decode_token",
        description: "Decode a privacy token back to its original value. Tokens are generated when reading PRIVATE-tagged documents.",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "token": ["type": "string", "description": "Token to decode (e.g., [EM:abc123])"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["token"])
        ]
      ),
      Tool(
        name: "decode_tokens",
        description: "Decode multiple privacy tokens at once. Returns mapping of tokens to original values.",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "tokens": ["type": "array", "items": ["type": "string"] as [String: Any], "description": "Array of tokens to decode"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["tokens"])
        ]
      ),
      Tool(
        name: "encode_value",
        description: "Encode a value to get its privacy token. Use this to search PRIVATE-tagged documents for known PII values.",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "value": ["type": "string", "description": "Value to encode (email, phone, SSN, etc.)"] as [String: Any],
            "type": ["type": "string", "description": "Value type: email, phone, ssn, card, number"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["value", "type"])
        ]
      ),
      Tool(
        name: "clear_token_cache",
        description: "Clear the privacy token cache. Use for maintenance or to start fresh.",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([:] as [String: Any]),
          "required": AnyCodable([] as [String])
        ]
      ),
      Tool(
        name: "set_privacy_mode",
        description: "Enable or disable privacy mode. When enabled, metadata (author, path, dates, comments, URL) is stripped from ALL documents.",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([
            "enabled": ["type": "boolean", "description": "Enable (true) or disable (false) privacy mode"] as [String: Any]
          ] as [String: Any]),
          "required": AnyCodable(["enabled"])
        ]
      ),
      Tool(
        name: "get_privacy_mode",
        description: "Check if privacy mode is currently enabled.",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([:] as [String: Any]),
          "required": AnyCodable([] as [String])
        ]
      )
    ]
  }
}
