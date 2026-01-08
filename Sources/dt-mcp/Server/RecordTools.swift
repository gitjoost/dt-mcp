//
//  MCPServer+RecordTools.swift
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

// MARK: - Record Tool Handlers

extension MCPServer {

  static let recordTools = [
    "search", "get_record", "get_record_content", "create_record", "get_selection",
    "update_record", "delete_record", "move_record", "duplicate_record", "replicate_record",
    "get_record_children", "get_tags", "set_record_tags", "add_record_tags", "remove_record_tags",
    "get_custom_metadata", "set_custom_metadata", "create_group", "get_trash", "empty_trash",
    "get_current_record", "get_annotations", "get_replicants", "get_duplicates"
  ]

  func handleRecordTool(name: String, arguments: [String: Any]) throws -> [String: Any]? {
    switch name {
    case "search":
      guard let query = arguments["query"] as? String else {
        throw MCPError.missingArgument("query")
      }
      let dbUUID = arguments["database"] as? String
      let records = try devonthink.search(query: query, inDatabase: dbUUID)
      let privatizer = Privatizer.shared
      let privacyMode = ConfigManager.shared.privacyMode
      let processedRecords = records.map { record -> [String: Any] in
        if privatizer.isPrivate(record) {
          return privatizer.privatizeRecord(record)
        }
        else if privacyMode {
          return privatizer.stripMetadata(record)
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
      else if ConfigManager.shared.privacyMode {
        record = privatizer.stripMetadata(record)
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
      let privacyMode = ConfigManager.shared.privacyMode
      let processedRecords = records.map { record -> [String: Any] in
        if privatizer.isPrivate(record) {
          return privatizer.privatizeRecord(record)
        }
        else if privacyMode {
          return privatizer.stripMetadata(record)
        }
        return record
      }
      return formatToolResult(processedRecords)

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

    case "create_group":
      guard let name = arguments["name"] as? String,
            let database = arguments["database"] as? String else {
        throw MCPError.missingArgument("name or database")
      }
      let parent = arguments["parent"] as? String
      let group = try devonthink.createGroup(name: name, databaseUUID: database, parentUUID: parent)
      return formatToolResult(group)

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

    case "get_current_record":
      if let record = try devonthink.getCurrentRecord() {
        return formatToolResult(record)
      }
      else {
        return formatToolResult(["message": "No record currently viewed"])
      }

    case "get_annotations":
      guard let uuid = arguments["uuid"] as? String else {
        throw MCPError.missingArgument("uuid")
      }
      let annotations = try devonthink.getAnnotations(uuid: uuid)
      return formatToolResult(annotations)

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

    default:
      return nil
    }
  }
}
