//
//  DEVONthinkBridge+Database.swift
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

// MARK: - Database Operations

extension DEVONthinkBridge {

  func listDatabases() throws -> [[String: Any]] {
    let script = """
    tell application id "DNtp"
      set dbList to {}
      repeat with db in databases
        set end of dbList to {uuid of db, name of db, path of db}
      end repeat
      return dbList
    end tell
    """

    let result = try runAppleScript(script)
    return parseRecordList(result, keys: ["uuid", "name", "path"])
  }

  func search(query: String, inDatabase dbUUID: String?) throws -> [[String: Any]] {
    let script: String
    if let dbUUID = dbUUID {
      script = """
      tell application id "DNtp"
        set theDB to get database with uuid "\(escape(dbUUID))"
        set theRecords to search "\(escape(query))" in root of theDB
        set resultList to {}
        set counter to 0
        repeat with theRecord in theRecords
          if counter >= 50 then exit repeat
          set theTags to tags of theRecord
          set tagStr to ""
          repeat with t in theTags
            if tagStr is "" then
              set tagStr to t as string
            else
              set tagStr to tagStr & "||" & (t as string)
            end if
          end repeat
          set end of resultList to {uuid of theRecord, name of theRecord, path of theRecord, location of theRecord, tagStr}
          set counter to counter + 1
        end repeat
        return resultList
      end tell
      """
    }
    else {
      script = """
      tell application id "DNtp"
        set theRecords to search "\(escape(query))"
        set resultList to {}
        set counter to 0
        repeat with theRecord in theRecords
          if counter >= 50 then exit repeat
          set theTags to tags of theRecord
          set tagStr to ""
          repeat with t in theTags
            if tagStr is "" then
              set tagStr to t as string
            else
              set tagStr to tagStr & "||" & (t as string)
            end if
          end repeat
          set end of resultList to {uuid of theRecord, name of theRecord, path of theRecord, location of theRecord, tagStr}
          set counter to counter + 1
        end repeat
        return resultList
      end tell
      """
    }

    let result = try runAppleScript(script)
    return parseSearchResults(result)
  }

  private func parseSearchResults(_ descriptor: NSAppleEventDescriptor) -> [[String: Any]] {
    var result: [[String: Any]] = []
    let count = descriptor.numberOfItems
    guard count > 0 else { return result }
    for i in 1...count {
      guard let item = descriptor.atIndex(i) else { continue }
      let tagStr = item.atIndex(5)?.stringValue ?? ""
      let tags = tagStr.isEmpty ? [] : tagStr.components(separatedBy: "||")
      result.append([
        "uuid": item.atIndex(1)?.stringValue ?? "",
        "name": item.atIndex(2)?.stringValue ?? "",
        "path": item.atIndex(3)?.stringValue ?? "",
        "location": item.atIndex(4)?.stringValue ?? "",
        "tags": tags
      ])
    }
    return result
  }

  func getDatabase(uuid: String) throws -> [String: Any] {
    let script = """
    tell application id "DNtp"
      set theDB to get database with uuid "\(escape(uuid))"
      if theDB is missing value then error "Database not found"
      return {uuid of theDB, name of theDB, path of theDB, comment of theDB, read only of theDB, count of records of theDB}
    end tell
    """
    let result = try runAppleScript(script)
    return [
      "uuid": result.atIndex(1)?.stringValue ?? "",
      "name": result.atIndex(2)?.stringValue ?? "",
      "path": result.atIndex(3)?.stringValue ?? "",
      "comment": result.atIndex(4)?.stringValue ?? "",
      "readOnly": result.atIndex(5)?.booleanValue ?? false,
      "recordCount": result.atIndex(6)?.int32Value ?? 0
    ]
  }

  func openDatabase(path: String) throws -> [String: Any] {
    let script = """
    tell application id "DNtp"
      set theDB to open database "\(escape(path))"
      if theDB is missing value then error "Failed to open database"
      return {uuid of theDB, name of theDB, path of theDB}
    end tell
    """
    let result = try runAppleScript(script)
    return parseSimpleRecord(result)
  }

  func closeDatabase(uuid: String) throws -> Bool {
    let script = """
    tell application id "DNtp"
      set theDB to get database with uuid "\(escape(uuid))"
      if theDB is missing value then error "Database not found"
      close window of theDB
      return true
    end tell
    """
    let result = try runAppleScript(script)
    return result.booleanValue
  }

  func verifyDatabase(uuid: String) throws -> Int {
    let script = """
    tell application id "DNtp"
      set theDB to get database with uuid "\(escape(uuid))"
      if theDB is missing value then error "Database not found"
      return verify database theDB
    end tell
    """
    let result = try runAppleScript(script)
    return Int(result.int32Value)
  }

  func optimizeDatabase(uuid: String) throws -> Bool {
    let script = """
    tell application id "DNtp"
      set theDB to get database with uuid "\(escape(uuid))"
      if theDB is missing value then error "Database not found"
      optimize database theDB
      return true
    end tell
    """
    let result = try runAppleScript(script)
    return result.booleanValue
  }

  func getSelectedRecords() throws -> [[String: Any]] {
    let script = """
    tell application id "DNtp"
      set resultList to {}
      repeat with theRecord in (selected records)
        set theTags to tags of theRecord
        set tagStr to ""
        repeat with t in theTags
          if tagStr is "" then
            set tagStr to t as string
          else
            set tagStr to tagStr & "||" & (t as string)
          end if
        end repeat
        set end of resultList to {uuid of theRecord, name of theRecord, path of theRecord, location of theRecord, tagStr}
      end repeat
      return resultList
    end tell
    """

    let result = try runAppleScript(script)
    return parseSearchResults(result)
  }

  func getThinkWindows() throws -> [[String: Any]] {
    let script = """
    tell application id "DNtp"
      set winList to {}
      repeat with w in think windows
        set end of winList to {id of w, name of w}
      end repeat
      return winList
    end tell
    """
    let result = try runAppleScript(script)
    return parseRecordList(result, keys: ["id", "name"])
  }

  func openRecordInWindow(uuid: String) throws -> Bool {
    let script = """
    tell application id "DNtp"
      set theRecord to get record with uuid "\(escape(uuid))"
      if theRecord is missing value then error "Record not found"
      open tab for record theRecord
      return true
    end tell
    """
    let result = try runAppleScript(script)
    return result.booleanValue
  }

  func openNewWindow(databaseUUID: String?) throws -> Bool {
    let dbClause: String
    if let databaseUUID = databaseUUID {
      dbClause = """
      set theDB to get database with uuid "\(escape(databaseUUID))"
      if theDB is missing value then error "Database not found"
      open window for record root of theDB
      """
    }
    else {
      dbClause = "open window for record root of database 1"
    }

    let script = """
    tell application id "DNtp"
      \(dbClause)
      return true
    end tell
    """
    let result = try runAppleScript(script)
    return result.booleanValue
  }
}
