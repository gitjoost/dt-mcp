//
//  MCPServer.swift
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

// MARK: - MCP Server

@MainActor
class MCPServer {
  let devonthink = DEVONthinkBridge()
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()

  func run() async {
    encoder.outputFormatting = [.sortedKeys]

    while let line = readLine() {
      guard !line.isEmpty else { continue }

      do {
        let request = try decoder.decode(JSONRPCRequest.self, from: Data(line.utf8))
        let response = await handleRequest(request)
        try sendResponse(response)
      }
      catch {
        let errorResponse = JSONRPCResponse(
          id: nil,
          result: nil,
          error: JSONRPCError(code: -32700, message: "Parse error: \(error.localizedDescription)", data: nil)
        )
        try? sendResponse(errorResponse)
      }
    }
  }

  private func sendResponse(_ response: JSONRPCResponse) throws {
    let data = try encoder.encode(response)
    if let json = String(data: data, encoding: .utf8) {
      print(json)
      fflush(stdout)
    }
  }

  private func handleRequest(_ request: JSONRPCRequest) async -> JSONRPCResponse {
    switch request.method {
    case "initialize":
      return handleInitialize(id: request.id)
    case "initialized":
      return JSONRPCResponse(id: request.id, result: nil, error: nil)
    case "tools/list":
      return handleToolsList(id: request.id)
    case "tools/call":
      return await handleToolCall(id: request.id, params: request.params)
    case "resources/list":
      return handleResourcesList(id: request.id)
    case "resources/read":
      return await handleResourceRead(id: request.id, params: request.params)
    case "prompts/list":
      return handlePromptsList(id: request.id)
    case "ping":
      return JSONRPCResponse(id: request.id, result: AnyCodable([:] as [String: Any]), error: nil)
    default:
      return JSONRPCResponse(
        id: request.id,
        result: nil,
        error: JSONRPCError(code: -32601, message: "Method not found: \(request.method)", data: nil)
      )
    }
  }

  // MARK: - Initialize

  private func handleInitialize(id: RequestID?) -> JSONRPCResponse {
    let result = InitializeResult(
      protocolVersion: "2024-11-05",
      capabilities: ServerCapabilities(
        tools: ToolsCapability(listChanged: false),
        resources: ResourcesCapability(subscribe: false, listChanged: false),
        prompts: PromptsCapability(listChanged: false)
      ),
      serverInfo: ServerInfo(name: "dt-mcp", version: "0.5.1")
    )
    return JSONRPCResponse(id: id, result: AnyCodable(encodeToDict(result)), error: nil)
  }

  // MARK: - Resources

  private func handleResourcesList(id: RequestID?) -> JSONRPCResponse {
    let resources: [[String: Any]] = [
      [
        "uri": "devonthink://databases",
        "name": "DEVONthink Databases",
        "description": "List of all open databases",
        "mimeType": "application/json"
      ],
      [
        "uri": "devonthink://selection",
        "name": "Current Selection",
        "description": "Currently selected records in DEVONthink",
        "mimeType": "application/json"
      ]
    ]
    return JSONRPCResponse(id: id, result: AnyCodable(["resources": resources]), error: nil)
  }

  private func handleResourceRead(id: RequestID?, params: AnyCodable?) async -> JSONRPCResponse {
    guard let paramsDict = params?.value as? [String: Any],
          let uri = paramsDict["uri"] as? String else {
      return JSONRPCResponse(
        id: id,
        result: nil,
        error: JSONRPCError(code: -32602, message: "Invalid params: missing uri", data: nil)
      )
    }

    guard devonthink.isRunning else {
      return JSONRPCResponse(
        id: id,
        result: nil,
        error: JSONRPCError(code: -32000, message: "DEVONthink is not running", data: nil)
      )
    }

    var contents: [[String: Any]] = []

    do {
      if uri == "devonthink://databases" {
        let databases = try devonthink.listDatabases()
        let jsonData = try JSONSerialization.data(withJSONObject: databases)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? "[]"
        contents.append([
          "uri": uri,
          "mimeType": "application/json",
          "text": jsonString
        ])
      }
      else if uri == "devonthink://selection" {
        let records = try devonthink.getSelectedRecords()
        let jsonData = try JSONSerialization.data(withJSONObject: records)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? "[]"
        contents.append([
          "uri": uri,
          "mimeType": "application/json",
          "text": jsonString
        ])
      }
    }
    catch {
      return JSONRPCResponse(
        id: id,
        result: nil,
        error: JSONRPCError(code: -32000, message: error.localizedDescription, data: nil)
      )
    }

    return JSONRPCResponse(id: id, result: AnyCodable(["contents": contents]), error: nil)
  }

  // MARK: - Prompts

  private func handlePromptsList(id: RequestID?) -> JSONRPCResponse {
    let prompts: [[String: Any]] = [
      [
        "name": "analyze_document",
        "description": "Analyze a document and suggest tags/classification",
        "arguments": [
          ["name": "uuid", "description": "Record UUID", "required": true] as [String: Any]
        ] as [[String: Any]]
      ]
    ]
    return JSONRPCResponse(id: id, result: AnyCodable(["prompts": prompts]), error: nil)
  }

  // MARK: - Helpers

  func formatToolResult(_ data: Any) -> [String: Any] {
    let jsonData = try? JSONSerialization.data(withJSONObject: data)
    let jsonString = jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    return [
      "content": [["type": "text", "text": jsonString] as [String: Any]] as [[String: Any]],
      "isError": false
    ]
  }

  func encodeToDict<T: Encodable>(_ value: T) -> [String: Any] {
    guard let data = try? encoder.encode(value),
          let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      return [:]
    }
    return dict
  }
}
