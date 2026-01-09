//
//  Errors.swift
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

// MARK: - MCP Errors

enum MCPError: Error, LocalizedError {
  case devonthinkNotRunning
  case unknownTool(String)
  case missingArgument(String)
  case appleScriptFailed
  case appleScriptError(String)
  case writeProtected(String)
  case databaseExcluded(String)

  var errorDescription: String? {
    switch self {
    case .devonthinkNotRunning:
      return "DEVONthink is not running"
    case .unknownTool(let name):
      return "Unknown tool: \(name)"
    case .missingArgument(let arg):
      return "Missing required argument: \(arg)"
    case .appleScriptFailed:
      return "Failed to create AppleScript"
    case .appleScriptError(let msg):
      return "AppleScript error: \(msg)"
    case .writeProtected(let uuid):
      return "Record '\(uuid)' is PRIVATE and fully write-protected. All modifications are blocked including edits, moves, tag changes, and deletions. The PRIVATE tag cannot be removed via MCP."
    case .databaseExcluded(let uuid):
      return "Database '\(uuid)' is excluded and not accessible via MCP."
    }
  }
}
