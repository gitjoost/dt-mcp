//
//  MCPServer+DatabaseTools.swift
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

// MARK: - Database Tool Handlers

extension MCPServer {

  static let databaseTools = [
    "list_databases", "get_database", "open_database",
    "close_database", "verify_database", "optimize_database"
  ]

  func handleDatabaseTool(name: String, arguments: [String: Any]) throws -> [String: Any]? {
    switch name {
    case "list_databases":
      let databases = try devonthink.listDatabases()
      return formatToolResult(databases)

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

    default:
      return nil
    }
  }
}
