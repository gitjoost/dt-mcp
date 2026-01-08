//
//  MCPServer+PrivacyTools.swift
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

// MARK: - Privacy Tool Handlers

extension MCPServer {

  static let privacyTools = [
    "decode_token", "decode_tokens", "encode_value",
    "clear_token_cache", "set_privacy_mode", "get_privacy_mode"
  ]

  func handlePrivacyTool(name: String, arguments: [String: Any]) throws -> [String: Any]? {
    switch name {
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

    case "set_privacy_mode":
      guard let enabled = arguments["enabled"] as? Bool else {
        throw MCPError.missingArgument("enabled")
      }
      ConfigManager.shared.privacyMode = enabled
      return formatToolResult(["privacy_mode": enabled, "message": enabled ? "Privacy mode enabled" : "Privacy mode disabled"])

    case "get_privacy_mode":
      let enabled = ConfigManager.shared.privacyMode
      return formatToolResult(["privacy_mode": enabled])

    default:
      return nil
    }
  }
}
