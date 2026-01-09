//
//  MCPServer+ContentTools.swift
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

// MARK: - Content Tool Handlers (Import/Export, AI, OCR, Web, Links, Windows, Reminders, Smart Groups)

extension MCPServer {

  static let contentTools = [
    "import_file", "export_record", "classify", "see_also", "summarize", "get_concordance",
    "ocr_file", "convert_to_searchable_pdf", "create_bookmark", "download_url", "download_markdown",
    "get_incoming_links", "get_outgoing_links", "get_item_url", "get_windows", "open_record",
    "open_window", "get_reminders", "set_reminder", "clear_reminder", "get_smart_groups",
    "get_smart_group_contents"
  ]

  func handleContentTool(name: String, arguments: [String: Any]) throws -> [String: Any]? {
    switch name {
    // Import/Export
    case "import_file":
      guard let path = arguments["path"] as? String,
            let database = arguments["database"] as? String else {
        throw MCPError.missingArgument("path or database")
      }
      if ConfigManager.shared.isExcluded(database) {
        throw MCPError.databaseExcluded(database)
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
      let exportDbUUID = try devonthink.getRecordDatabaseUUID(uuid: uuid)
      if ConfigManager.shared.isExcluded(exportDbUUID) {
        throw MCPError.databaseExcluded(exportDbUUID)
      }
      let success = try devonthink.exportRecord(uuid: uuid, to: path)
      return formatToolResult(["success": success])

    // AI/Classification
    case "classify":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let classifyDbUUID = try devonthink.getRecordDatabaseUUID(uuid: uuid)
      if ConfigManager.shared.isExcluded(classifyDbUUID) {
        throw MCPError.databaseExcluded(classifyDbUUID)
      }
      let suggestions = try devonthink.classify(uuid: uuid)
      return formatToolResult(suggestions)

    case "see_also":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let seeAlsoDbUUID = try devonthink.getRecordDatabaseUUID(uuid: uuid)
      if ConfigManager.shared.isExcluded(seeAlsoDbUUID) {
        throw MCPError.databaseExcluded(seeAlsoDbUUID)
      }
      let count = arguments["count"] as? Int
      let similar = try devonthink.seeAlso(uuid: uuid, count: count)
      return formatToolResult(similar)

    case "summarize":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let summarizeDbUUID = try devonthink.getRecordDatabaseUUID(uuid: uuid)
      if ConfigManager.shared.isExcluded(summarizeDbUUID) {
        throw MCPError.databaseExcluded(summarizeDbUUID)
      }
      let summary = try devonthink.summarize(uuid: uuid)
      return formatToolResult(["summary": summary])

    case "get_concordance":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let concordanceDbUUID = try devonthink.getRecordDatabaseUUID(uuid: uuid)
      if ConfigManager.shared.isExcluded(concordanceDbUUID) {
        throw MCPError.databaseExcluded(concordanceDbUUID)
      }
      let words = try devonthink.getConcordance(uuid: uuid)
      return formatToolResult(words)

    // OCR
    case "ocr_file":
      guard let path = arguments["path"] as? String,
            let database = arguments["database"] as? String else {
        throw MCPError.missingArgument("path or database")
      }
      if ConfigManager.shared.isExcluded(database) {
        throw MCPError.databaseExcluded(database)
      }
      let destination = arguments["destination"] as? String
      let record = try devonthink.ocrFile(path: path, databaseUUID: database, destinationUUID: destination)
      return formatToolResult(record)

    case "convert_to_searchable_pdf":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let pdfDbUUID = try devonthink.getRecordDatabaseUUID(uuid: uuid)
      if ConfigManager.shared.isExcluded(pdfDbUUID) {
        throw MCPError.databaseExcluded(pdfDbUUID)
      }
      let success = try devonthink.convertToSearchablePDF(uuid: uuid)
      return formatToolResult(["success": success])

    // Web
    case "create_bookmark":
      guard let url = arguments["url"] as? String,
            let database = arguments["database"] as? String else {
        throw MCPError.missingArgument("url or database")
      }
      if ConfigManager.shared.isExcluded(database) {
        throw MCPError.databaseExcluded(database)
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
      if ConfigManager.shared.isExcluded(database) {
        throw MCPError.databaseExcluded(database)
      }
      let destination = arguments["destination"] as? String
      let record = try devonthink.downloadURL(url: url, databaseUUID: database, destinationUUID: destination)
      return formatToolResult(record)

    case "download_markdown":
      guard let url = arguments["url"] as? String,
            let database = arguments["database"] as? String else {
        throw MCPError.missingArgument("url or database")
      }
      if ConfigManager.shared.isExcluded(database) {
        throw MCPError.databaseExcluded(database)
      }
      let destination = arguments["destination"] as? String
      let record = try devonthink.downloadMarkdown(url: url, databaseUUID: database, destinationUUID: destination)
      return formatToolResult(record)

    // Links
    case "get_incoming_links":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let inLinksDbUUID = try devonthink.getRecordDatabaseUUID(uuid: uuid)
      if ConfigManager.shared.isExcluded(inLinksDbUUID) {
        throw MCPError.databaseExcluded(inLinksDbUUID)
      }
      let links = try devonthink.getItemLinks(uuid: uuid)
      return formatToolResult(links)

    case "get_outgoing_links":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let outLinksDbUUID = try devonthink.getRecordDatabaseUUID(uuid: uuid)
      if ConfigManager.shared.isExcluded(outLinksDbUUID) {
        throw MCPError.databaseExcluded(outLinksDbUUID)
      }
      let links = try devonthink.getOutgoingLinks(uuid: uuid)
      return formatToolResult(links)

    case "get_item_url":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let itemUrlDbUUID = try devonthink.getRecordDatabaseUUID(uuid: uuid)
      if ConfigManager.shared.isExcluded(itemUrlDbUUID) {
        throw MCPError.databaseExcluded(itemUrlDbUUID)
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
      let openDbUUID = try devonthink.getRecordDatabaseUUID(uuid: uuid)
      if ConfigManager.shared.isExcluded(openDbUUID) {
        throw MCPError.databaseExcluded(openDbUUID)
      }
      let success = try devonthink.openRecordInWindow(uuid: uuid)
      return formatToolResult(["success": success])

    case "open_window":
      let database = arguments["database"] as? String
      if let database = database, ConfigManager.shared.isExcluded(database) {
        throw MCPError.databaseExcluded(database)
      }
      let success = try devonthink.openNewWindow(databaseUUID: database)
      return formatToolResult(["success": success])

    // Reminders
    case "get_reminders":
      let uuid = arguments["uuid"] as? String
      if let uuid = uuid {
        let reminderDbUUID = try devonthink.getRecordDatabaseUUID(uuid: uuid)
        if ConfigManager.shared.isExcluded(reminderDbUUID) {
          throw MCPError.databaseExcluded(reminderDbUUID)
        }
      }
      let reminders = try devonthink.getReminders(uuid: uuid)
      return formatToolResult(reminders)

    case "set_reminder":
      guard let uuid = arguments["uuid"] as? String,
            let date = arguments["date"] as? String else {
        throw MCPError.missingArgument("uuid or date")
      }
      let setRemDbUUID = try devonthink.getRecordDatabaseUUID(uuid: uuid)
      if ConfigManager.shared.isExcluded(setRemDbUUID) {
        throw MCPError.databaseExcluded(setRemDbUUID)
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
      let clearRemDbUUID = try devonthink.getRecordDatabaseUUID(uuid: uuid)
      if ConfigManager.shared.isExcluded(clearRemDbUUID) {
        throw MCPError.databaseExcluded(clearRemDbUUID)
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
      if ConfigManager.shared.isExcluded(database) {
        throw MCPError.databaseExcluded(database)
      }
      let groups = try devonthink.getSmartGroups(databaseUUID: database)
      return formatToolResult(groups)

    case "get_smart_group_contents":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let sgDbUUID = try devonthink.getRecordDatabaseUUID(uuid: uuid)
      if ConfigManager.shared.isExcluded(sgDbUUID) {
        throw MCPError.databaseExcluded(sgDbUUID)
      }
      let contents = try devonthink.getSmartGroupContents(uuid: uuid)
      return formatToolResult(contents)

    default:
      return nil
    }
  }
}
