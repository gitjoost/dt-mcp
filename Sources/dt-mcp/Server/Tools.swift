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

// MARK: - Tools Dispatch

extension MCPServer {

  func handleToolsList(id: RequestID?) -> JSONRPCResponse {
    let tools = getAvailableTools()
    let result = ToolsListResult(tools: tools)
    return JSONRPCResponse(id: id, result: AnyCodable(encodeToDict(result)), error: nil)
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

    // Try each category handler
    if let result = try handleDatabaseTool(name: name, arguments: arguments) {
      return result
    }
    if let result = try handleRecordTool(name: name, arguments: arguments) {
      return result
    }
    if let result = try handleContentTool(name: name, arguments: arguments) {
      return result
    }
    if let result = try handlePrivacyTool(name: name, arguments: arguments) {
      return result
    }

    throw MCPError.unknownTool(name)
  }
}
