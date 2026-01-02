//
//  DEVONthinkBridge.swift
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

// MARK: - DEVONthink Bridge (AppleScript-based)

class DEVONthinkBridge {

  func runAppleScript(_ script: String) throws -> NSAppleEventDescriptor {
    var error: NSDictionary?
    guard let appleScript = NSAppleScript(source: script) else {
      throw MCPError.appleScriptFailed
    }

    let result = appleScript.executeAndReturnError(&error)
    if let error = error {
      throw MCPError.appleScriptError(error.description)
    }
    return result
  }

  var isRunning: Bool {
    let script = """
    tell application "System Events"
      set isRunning to exists (processes where name is "DEVONthink")
    end tell
    return isRunning
    """
    do {
      let result = try runAppleScript(script)
      return result.booleanValue
    }
    catch {
      return false
    }
  }

  // MARK: - Helpers

  func escape(_ str: String) -> String {
    return str.replacingOccurrences(of: "\\", with: "\\\\")
              .replacingOccurrences(of: "\"", with: "\\\"")
  }

  func parseRecordList(_ descriptor: NSAppleEventDescriptor, keys: [String]) -> [[String: Any]] {
    var result: [[String: Any]] = []
    let count = descriptor.numberOfItems
    guard count > 0 else { return result }
    for i in 1...count {
      guard let item = descriptor.atIndex(i) else { continue }
      var entry: [String: Any] = [:]
      for (index, key) in keys.enumerated() {
        entry[key] = item.atIndex(index + 1)?.stringValue ?? ""
      }
      result.append(entry)
    }
    return result
  }

  func parseSimpleRecord(_ descriptor: NSAppleEventDescriptor) -> [String: Any] {
    return [
      "uuid": descriptor.atIndex(1)?.stringValue ?? "",
      "name": descriptor.atIndex(2)?.stringValue ?? "",
      "path": descriptor.atIndex(3)?.stringValue ?? ""
    ]
  }

  func parseRecord(_ descriptor: NSAppleEventDescriptor) -> [String: Any] {
    var tags: [String] = []
    if let tagsDesc = descriptor.atIndex(5) {
      for i in 1...tagsDesc.numberOfItems {
        if let tag = tagsDesc.atIndex(i)?.stringValue {
          tags.append(tag)
        }
      }
    }

    return [
      "uuid": descriptor.atIndex(1)?.stringValue ?? "",
      "name": descriptor.atIndex(2)?.stringValue ?? "",
      "path": descriptor.atIndex(3)?.stringValue ?? "",
      "location": descriptor.atIndex(4)?.stringValue ?? "",
      "tags": tags,
      "rating": descriptor.atIndex(6)?.int32Value ?? 0,
      "label": descriptor.atIndex(7)?.int32Value ?? 0,
      "flagged": descriptor.atIndex(8)?.booleanValue ?? false,
      "unread": descriptor.atIndex(9)?.booleanValue ?? false,
      "wordCount": descriptor.atIndex(10)?.int32Value ?? 0,
      "characterCount": descriptor.atIndex(11)?.int32Value ?? 0,
      "pageCount": descriptor.atIndex(12)?.int32Value ?? 0,
      "creationDate": descriptor.atIndex(13)?.stringValue ?? "",
      "modificationDate": descriptor.atIndex(14)?.stringValue ?? "",
      "plainText": descriptor.atIndex(15)?.stringValue ?? "",
      "comment": descriptor.atIndex(16)?.stringValue ?? "",
      "url": descriptor.atIndex(17)?.stringValue ?? ""
    ]
  }

  func parseCustomMetadata(_ descriptor: NSAppleEventDescriptor) -> [String: Any] {
    var result: [String: Any] = [:]
    for i in 1...descriptor.numberOfItems {
      guard let item = descriptor.atIndex(i),
            let key = item.atIndex(1)?.stringValue else { continue }
      let value = item.atIndex(2)?.stringValue ?? ""
      result[key] = value
    }
    return result
  }

  // MARK: - Privacy Helpers

  func getRecordTags(uuid: String) throws -> [String] {
    let script = """
    tell application id "DNtp"
      set theRecord to get record with uuid "\(escape(uuid))"
      if theRecord is missing value then error "Record not found"
      return tags of theRecord
    end tell
    """
    let result = try runAppleScript(script)
    var tags: [String] = []
    let count = result.numberOfItems
    guard count > 0 else { return tags }
    for i in 1...count {
      if let tag = result.atIndex(i)?.stringValue {
        tags.append(tag)
      }
    }
    return tags
  }
}
