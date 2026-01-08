//
//  MCPServer+Tools.swift
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

// MARK: - Tools Handling

extension MCPServer {

  func handleToolsList(id: RequestID?) -> JSONRPCResponse {
    let tools = getAvailableTools()
    let result = ToolsListResult(tools: tools)
    return JSONRPCResponse(id: id, result: AnyCodable(encodeToDict(result)), error: nil)
  }

  func getAvailableTools() -> [Tool] {
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
      // Database operations
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
      ),
      // Record operations
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
      // Tag operations
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
      // Import/Export
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
      // AI/Classification
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
      // OCR
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
      // Web
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
      // Links
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
      // Windows
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
      // Reminders
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
      // Smart Groups
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
      ),
      // Custom Metadata
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
      // Groups
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
      // Trash
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
      // Current Record
      Tool(
        name: "get_current_record",
        description: "Get the currently viewed record in DEVONthink (dt)",
        inputSchema: [
          "type": AnyCodable("object"),
          "properties": AnyCodable([:] as [String: Any]),
          "required": AnyCodable([] as [String])
        ]
      ),
      // Annotations
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
      // Replicants/Duplicates
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
      ),
      // Privacy Token Tools
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
      )
    ]
  }

  func handleToolCall(id: RequestID?, params: AnyCodable?) async -> JSONRPCResponse {
    guard let paramsDict = params?.value as? [String: Any],
          let toolName = paramsDict["name"] as? String else {
      return JSONRPCResponse(
        id: id,
        result: nil,
        error: JSONRPCError(code: -32602, message: "Invalid params: missing tool name", data: nil)
      )
    }

    let arguments = paramsDict["arguments"] as? [String: Any] ?? [:]

    do {
      let result = try callTool(name: toolName, arguments: arguments)
      return JSONRPCResponse(id: id, result: AnyCodable(result), error: nil)
    }
    catch {
      let toolResult: [String: Any] = [
        "content": [["type": "text", "text": "Error: \(error.localizedDescription)"]] as [[String: Any]],
        "isError": true
      ]
      return JSONRPCResponse(id: id, result: AnyCodable(toolResult), error: nil)
    }
  }

  func callTool(name: String, arguments: [String: Any]) throws -> [String: Any] {
    guard devonthink.isRunning else {
      throw MCPError.devonthinkNotRunning
    }

    switch name {
    case "list_databases":
      let databases = try devonthink.listDatabases()
      return formatToolResult(databases)

    case "search":
      guard let query = arguments["query"] as? String else {
        throw MCPError.missingArgument("query")
      }
      let dbUUID = arguments["database"] as? String
      let records = try devonthink.search(query: query, inDatabase: dbUUID)
      let privatizer = Privatizer.shared
      let processedRecords = records.map { record -> [String: Any] in
        if privatizer.isPrivate(record) {
          return privatizer.privatizeRecord(record)
        }
        return record
      }
      return formatToolResult(processedRecords)

    case "get_record":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      var record = try devonthink.getRecord(uuid: uuid)
      let privatizer = Privatizer.shared
      if privatizer.isPrivate(record) {
        record = privatizer.privatizeRecord(record)
      }
      return formatToolResult(record)

    case "get_record_content":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let format = arguments["format"] as? String ?? "plain"
      var content = try devonthink.getRecordContent(uuid: uuid, format: format)
      let tags = try devonthink.getRecordTags(uuid: uuid)
      let privatizer = Privatizer.shared
      if privatizer.isPrivate(tags) {
        content = privatizer.privatize(content)
      }
      return formatToolResult(["content": content])

    case "create_record":
      guard let name = arguments["name"] as? String,
            let database = arguments["database"] as? String else {
        throw MCPError.missingArgument("name or database")
      }
      let type = arguments["type"] as? String ?? "markdown"
      let content = arguments["content"] as? String
      let destination = arguments["destination"] as? String
      let tags = arguments["tags"] as? [String]
      let record = try devonthink.createRecord(name: name, type: type, content: content, database: database, destination: destination, tags: tags)
      return formatToolResult(record)

    case "get_selection":
      let records = try devonthink.getSelectedRecords()
      let privatizer = Privatizer.shared
      let processedRecords = records.map { record -> [String: Any] in
        if privatizer.isPrivate(record) {
          return privatizer.privatizeRecord(record)
        }
        return record
      }
      return formatToolResult(processedRecords)

    // Database operations
    case "get_database":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let database = try devonthink.getDatabase(uuid: uuid)
      return formatToolResult(database)

    case "open_database":
      guard let path = arguments["path"] as? String else {
        throw MCPError.missingArgument("path")
      }
      let database = try devonthink.openDatabase(path: path)
      return formatToolResult(database)

    case "close_database":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let success = try devonthink.closeDatabase(uuid: uuid)
      return formatToolResult(["success": success])

    case "verify_database":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let issues = try devonthink.verifyDatabase(uuid: uuid)
      return formatToolResult(["issues": issues])

    case "optimize_database":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let success = try devonthink.optimizeDatabase(uuid: uuid)
      return formatToolResult(["success": success])

    // Record operations
    case "update_record":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let tags = try devonthink.getRecordTags(uuid: uuid)
      try Privatizer.shared.checkWritePermission(uuid: uuid, tags: tags)
      var props: [String: Any] = [:]
      if let name = arguments["name"] { props["name"] = name }
      if let comment = arguments["comment"] { props["comment"] = comment }
      if let rating = arguments["rating"] { props["rating"] = rating }
      if let label = arguments["label"] { props["label"] = label }
      if let flagged = arguments["flagged"] { props["flagged"] = flagged }
      if let unread = arguments["unread"] { props["unread"] = unread }
      if let content = arguments["content"] { props["content"] = content }
      if let url = arguments["url"] { props["url"] = url }
      let record = try devonthink.updateRecord(uuid: uuid, properties: props)
      return formatToolResult(record)

    case "delete_record":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let tags = try devonthink.getRecordTags(uuid: uuid)
      try Privatizer.shared.checkWritePermission(uuid: uuid, tags: tags)
      let success = try devonthink.deleteRecord(uuid: uuid)
      return formatToolResult(["success": success])

    case "move_record":
      guard let uuid = arguments["uuid"] as? String,
            let to = arguments["to"] as? String else {
        throw MCPError.missingArgument("uuid or to")
      }
      let tags = try devonthink.getRecordTags(uuid: uuid)
      try Privatizer.shared.checkWritePermission(uuid: uuid, tags: tags)
      let record = try devonthink.moveRecord(uuid: uuid, to: to)
      return formatToolResult(record)

    case "duplicate_record":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let tags = try devonthink.getRecordTags(uuid: uuid)
      try Privatizer.shared.checkWritePermission(uuid: uuid, tags: tags)
      let to = arguments["to"] as? String
      let record = try devonthink.duplicateRecord(uuid: uuid, to: to)
      return formatToolResult(record)

    case "replicate_record":
      guard let uuid = arguments["uuid"] as? String,
            let to = arguments["to"] as? String else {
        throw MCPError.missingArgument("uuid or to")
      }
      let tags = try devonthink.getRecordTags(uuid: uuid)
      try Privatizer.shared.checkWritePermission(uuid: uuid, tags: tags)
      let record = try devonthink.replicateRecord(uuid: uuid, to: to)
      return formatToolResult(record)

    case "get_record_children":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let children = try devonthink.getRecordChildren(uuid: uuid)
      return formatToolResult(children)

    // Tag operations
    case "get_tags":
      guard let database = arguments["database"] as? String else {
        throw MCPError.missingArgument("database")
      }
      let tags = try devonthink.getTags(databaseUUID: database)
      return formatToolResult(tags)

    case "set_record_tags":
      guard let uuid = arguments["uuid"] as? String,
            let newTags = arguments["tags"] as? [String] else {
        throw MCPError.missingArgument("uuid or tags")
      }
      let currentTags = try devonthink.getRecordTags(uuid: uuid)
      try Privatizer.shared.checkWritePermission(uuid: uuid, tags: currentTags)
      let success = try devonthink.setRecordTags(uuid: uuid, tags: newTags)
      return formatToolResult(["success": success])

    case "add_record_tags":
      guard let uuid = arguments["uuid"] as? String,
            let newTags = arguments["tags"] as? [String] else {
        throw MCPError.missingArgument("uuid or tags")
      }
      let currentTags = try devonthink.getRecordTags(uuid: uuid)
      try Privatizer.shared.checkWritePermission(uuid: uuid, tags: currentTags)
      let success = try devonthink.addRecordTags(uuid: uuid, tags: newTags)
      return formatToolResult(["success": success])

    case "remove_record_tags":
      guard let uuid = arguments["uuid"] as? String,
            let tagsToRemove = arguments["tags"] as? [String] else {
        throw MCPError.missingArgument("uuid or tags")
      }
      let currentTags = try devonthink.getRecordTags(uuid: uuid)
      try Privatizer.shared.checkWritePermission(uuid: uuid, tags: currentTags)
      let success = try devonthink.removeRecordTags(uuid: uuid, tags: tagsToRemove)
      return formatToolResult(["success": success])

    // Import/Export
    case "import_file":
      guard let path = arguments["path"] as? String,
            let database = arguments["database"] as? String else {
        throw MCPError.missingArgument("path or database")
      }
      let destination = arguments["destination"] as? String
      let name = arguments["name"] as? String
      let record = try devonthink.importFile(path: path, to: database, destinationUUID: destination, name: name)
      return formatToolResult(record)

    case "export_record":
      guard let uuid = arguments["uuid"] as? String,
            let path = arguments["path"] as? String else {
        throw MCPError.missingArgument("uuid or path")
      }
      let success = try devonthink.exportRecord(uuid: uuid, to: path)
      return formatToolResult(["success": success])

    // AI/Classification
    case "classify":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let suggestions = try devonthink.classify(uuid: uuid)
      return formatToolResult(suggestions)

    case "see_also":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let count = arguments["count"] as? Int
      let similar = try devonthink.seeAlso(uuid: uuid, count: count)
      return formatToolResult(similar)

    case "summarize":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let summary = try devonthink.summarize(uuid: uuid)
      return formatToolResult(["summary": summary])

    case "get_concordance":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let words = try devonthink.getConcordance(uuid: uuid)
      return formatToolResult(words)

    // OCR
    case "ocr_file":
      guard let path = arguments["path"] as? String,
            let database = arguments["database"] as? String else {
        throw MCPError.missingArgument("path or database")
      }
      let destination = arguments["destination"] as? String
      let record = try devonthink.ocrFile(path: path, databaseUUID: database, destinationUUID: destination)
      return formatToolResult(record)

    case "convert_to_searchable_pdf":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let success = try devonthink.convertToSearchablePDF(uuid: uuid)
      return formatToolResult(["success": success])

    // Web
    case "create_bookmark":
      guard let url = arguments["url"] as? String,
            let database = arguments["database"] as? String else {
        throw MCPError.missingArgument("url or database")
      }
      let name = arguments["name"] as? String
      let destination = arguments["destination"] as? String
      let record = try devonthink.createBookmark(url: url, name: name, databaseUUID: database, destinationUUID: destination)
      return formatToolResult(record)

    case "download_url":
      guard let url = arguments["url"] as? String,
            let database = arguments["database"] as? String else {
        throw MCPError.missingArgument("url or database")
      }
      let destination = arguments["destination"] as? String
      let record = try devonthink.downloadURL(url: url, databaseUUID: database, destinationUUID: destination)
      return formatToolResult(record)

    case "download_markdown":
      guard let url = arguments["url"] as? String,
            let database = arguments["database"] as? String else {
        throw MCPError.missingArgument("url or database")
      }
      let destination = arguments["destination"] as? String
      let record = try devonthink.downloadMarkdown(url: url, databaseUUID: database, destinationUUID: destination)
      return formatToolResult(record)

    // Links
    case "get_incoming_links":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let links = try devonthink.getItemLinks(uuid: uuid)
      return formatToolResult(links)

    case "get_outgoing_links":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let links = try devonthink.getOutgoingLinks(uuid: uuid)
      return formatToolResult(links)

    case "get_item_url":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let url = try devonthink.getItemURL(uuid: uuid)
      return formatToolResult(["url": url])

    // Windows
    case "get_windows":
      let windows = try devonthink.getThinkWindows()
      return formatToolResult(windows)

    case "open_record":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let success = try devonthink.openRecordInWindow(uuid: uuid)
      return formatToolResult(["success": success])

    case "open_window":
      let database = arguments["database"] as? String
      let success = try devonthink.openNewWindow(databaseUUID: database)
      return formatToolResult(["success": success])

    // Reminders
    case "get_reminders":
      let uuid = arguments["uuid"] as? String
      let reminders = try devonthink.getReminders(uuid: uuid)
      return formatToolResult(reminders)

    case "set_reminder":
      guard let uuid = arguments["uuid"] as? String,
            let date = arguments["date"] as? String else {
        throw MCPError.missingArgument("uuid or date")
      }
      let tags = try devonthink.getRecordTags(uuid: uuid)
      try Privatizer.shared.checkWritePermission(uuid: uuid, tags: tags)
      let alarm = arguments["alarm"] as? Bool ?? false
      let success = try devonthink.setReminder(uuid: uuid, date: date, alarm: alarm)
      return formatToolResult(["success": success])

    case "clear_reminder":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let tags = try devonthink.getRecordTags(uuid: uuid)
      try Privatizer.shared.checkWritePermission(uuid: uuid, tags: tags)
      let success = try devonthink.clearReminder(uuid: uuid)
      return formatToolResult(["success": success])

    // Smart Groups
    case "get_smart_groups":
      guard let database = arguments["database"] as? String else {
        throw MCPError.missingArgument("database")
      }
      let groups = try devonthink.getSmartGroups(databaseUUID: database)
      return formatToolResult(groups)

    case "get_smart_group_contents":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let contents = try devonthink.getSmartGroupContents(uuid: uuid)
      return formatToolResult(contents)

    // Custom Metadata
    case "get_custom_metadata":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let metadata = try devonthink.getCustomMetadata(uuid: uuid)
      return formatToolResult(metadata)

    case "set_custom_metadata":
      guard let uuid = arguments["uuid"] as? String,
            let key = arguments["key"] as? String,
            let value = arguments["value"] as? String else {
        throw MCPError.missingArgument("uuid, key, or value")
      }
      let tags = try devonthink.getRecordTags(uuid: uuid)
      try Privatizer.shared.checkWritePermission(uuid: uuid, tags: tags)
      let success = try devonthink.setCustomMetadata(uuid: uuid, key: key, value: value)
      return formatToolResult(["success": success])

    // Groups
    case "create_group":
      guard let name = arguments["name"] as? String,
            let database = arguments["database"] as? String else {
        throw MCPError.missingArgument("name or database")
      }
      let parent = arguments["parent"] as? String
      let group = try devonthink.createGroup(name: name, databaseUUID: database, parentUUID: parent)
      return formatToolResult(group)

    // Trash
    case "get_trash":
      guard let database = arguments["database"] as? String else {
        throw MCPError.missingArgument("database")
      }
      let items = try devonthink.getTrash(databaseUUID: database)
      return formatToolResult(items)

    case "empty_trash":
      guard let database = arguments["database"] as? String else {
        throw MCPError.missingArgument("database")
      }
      let success = try devonthink.emptyTrash(databaseUUID: database)
      return formatToolResult(["success": success])

    // Current Record
    case "get_current_record":
      if let record = try devonthink.getCurrentRecord() {
        return formatToolResult(record)
      }
      else {
        return formatToolResult(["message": "No record currently viewed"])
      }

    // Annotations
    case "get_annotations":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let annotations = try devonthink.getAnnotations(uuid: uuid)
      return formatToolResult(annotations)

    // Replicants/Duplicates
    case "get_replicants":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let replicants = try devonthink.getReplicants(uuid: uuid)
      return formatToolResult(replicants)

    case "get_duplicates":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let duplicates = try devonthink.getDuplicates(uuid: uuid)
      return formatToolResult(duplicates)

    // Privacy Token Tools
    case "decode_token":
      guard let token = arguments["token"] as? String else {
        throw MCPError.missingArgument("token")
      }
      if let original = TokenCache.shared.decode(token) {
        return formatToolResult(["token": token, "value": original])
      }
      else {
        return formatToolResult(["token": token, "value": NSNull(), "message": "Token not found in cache"])
      }

    case "decode_tokens":
      guard let tokens = arguments["tokens"] as? [String] else {
        throw MCPError.missingArgument("tokens")
      }
      let decoded = TokenCache.shared.decodeAll(tokens)
      return formatToolResult(decoded)

    case "encode_value":
      guard let value = arguments["value"] as? String,
            let type = arguments["type"] as? String else {
        throw MCPError.missingArgument("value or type")
      }
      let token = Privatizer.shared.encodeValue(value, type: type)
      return formatToolResult(["value": value, "type": type, "token": token])

    case "clear_token_cache":
      let count = TokenCache.shared.clear()
      return formatToolResult(["cleared": count, "message": "Token cache cleared"])

    default:
      throw MCPError.unknownTool(name)
    }
  }
}
