//
//  DEVONthinkBridge+Records.swift
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

// MARK: - Record Operations

extension DEVONthinkBridge {

  func getRecordDatabaseUUID(uuid: String) throws -> String {
    let script = """
    tell application id "DNtp"
      set theRecord to get record with uuid "\(escape(uuid))"
      if theRecord is missing value then error "Record not found"
      return uuid of database of theRecord
    end tell
    """

    let result = try runAppleScript(script)
    return result.stringValue ?? ""
  }

  func getRecord(uuid: String) throws -> [String: Any] {
    let script = """
    tell application id "DNtp"
      set theRecord to get record with uuid "\(escape(uuid))"
      if theRecord is missing value then error "Record not found"
      return {uuid of theRecord, name of theRecord, path of theRecord, location of theRecord, tags of theRecord, rating of theRecord, label of theRecord, flagged of theRecord, unread of theRecord, word count of theRecord, character count of theRecord, page count of theRecord, creation date of theRecord as string, modification date of theRecord as string, plain text of theRecord, comment of theRecord, URL of theRecord}
    end tell
    """

    let result = try runAppleScript(script)
    return parseRecord(result)
  }

  func getRecordContent(uuid: String, format: String) throws -> String {
    let contentProperty: String
    switch format {
    case "markdown":
      contentProperty = "markdown source"
    case "html":
      contentProperty = "source"
    default:
      contentProperty = "plain text"
    }

    let script = """
    tell application id "DNtp"
      set theRecord to get record with uuid "\(escape(uuid))"
      if theRecord is missing value then error "Record not found"
      return \(contentProperty) of theRecord
    end tell
    """

    let result = try runAppleScript(script)
    return result.stringValue ?? ""
  }

  func createRecord(name: String, type: String, content: String?, database: String, destination: String?, tags: [String]?) throws -> [String: Any] {
    let typeValue: String
    switch type {
    case "markdown": typeValue = "markdown"
    case "txt": typeValue = "txt"
    case "rtf": typeValue = "rtf"
    case "bookmark": typeValue = "bookmark"
    case "group": typeValue = "group"
    default: typeValue = "markdown"
    }

    var propsItems = ["name:\"\(escape(name))\"", "type:\(typeValue)"]

    if let content = content {
      propsItems.append("plain text:\"\(escape(content))\"")
    }

    let destClause: String
    if let destination = destination {
      destClause = "set destGroup to get record with uuid \"\(escape(destination))\"\n"
    }
    else {
      destClause = "set destGroup to incoming group of theDB\n"
    }

    var tagsClause = ""
    if let tags = tags, !tags.isEmpty {
      let tagList = tags.map { "\"\(escape($0))\"" }.joined(separator: ", ")
      tagsClause = "set tags of theRecord to {\(tagList)}"
    }

    let script = """
    tell application id "DNtp"
      set theDB to get database with uuid "\(escape(database))"
      if theDB is missing value then error "Database not found"
      \(destClause)
      set theRecord to create record with {\(propsItems.joined(separator: ", "))} in destGroup
      \(tagsClause)
      return {uuid of theRecord, name of theRecord, path of theRecord}
    end tell
    """

    let result = try runAppleScript(script)
    return parseSimpleRecord(result)
  }

  func updateRecord(uuid: String, properties: [String: Any]) throws -> [String: Any] {
    var setStatements: [String] = []

    if let name = properties["name"] as? String {
      setStatements.append("set name of theRecord to \"\(escape(name))\"")
    }
    if let comment = properties["comment"] as? String {
      setStatements.append("set comment of theRecord to \"\(escape(comment))\"")
    }
    if let rating = properties["rating"] as? Int {
      setStatements.append("set rating of theRecord to \(rating)")
    }
    if let label = properties["label"] as? Int {
      setStatements.append("set label of theRecord to \(label)")
    }
    if let flagged = properties["flagged"] as? Bool {
      setStatements.append("set flagged of theRecord to \(flagged)")
    }
    if let unread = properties["unread"] as? Bool {
      setStatements.append("set unread of theRecord to \(unread)")
    }
    if let content = properties["content"] as? String {
      setStatements.append("set plain text of theRecord to \"\(escape(content))\"")
    }
    if let url = properties["url"] as? String {
      setStatements.append("set URL of theRecord to \"\(escape(url))\"")
    }

    let script = """
    tell application id "DNtp"
      set theRecord to get record with uuid "\(escape(uuid))"
      if theRecord is missing value then error "Record not found"
      \(setStatements.joined(separator: "\n      "))
      return {uuid of theRecord, name of theRecord, path of theRecord}
    end tell
    """
    let result = try runAppleScript(script)
    return parseSimpleRecord(result)
  }

  func deleteRecord(uuid: String) throws -> Bool {
    let script = """
    tell application id "DNtp"
      set theRecord to get record with uuid "\(escape(uuid))"
      if theRecord is missing value then error "Record not found"
      delete record theRecord
      return true
    end tell
    """
    let result = try runAppleScript(script)
    return result.booleanValue
  }

  func moveRecord(uuid: String, to destinationUUID: String) throws -> [String: Any] {
    let script = """
    tell application id "DNtp"
      set theRecord to get record with uuid "\(escape(uuid))"
      if theRecord is missing value then error "Record not found"
      set destGroup to get record with uuid "\(escape(destinationUUID))"
      if destGroup is missing value then error "Destination not found"
      set movedRecord to move record theRecord to destGroup
      return {uuid of movedRecord, name of movedRecord, path of movedRecord}
    end tell
    """
    let result = try runAppleScript(script)
    return parseSimpleRecord(result)
  }

  func duplicateRecord(uuid: String, to destinationUUID: String?) throws -> [String: Any] {
    let destClause: String
    if let destinationUUID = destinationUUID {
      destClause = """
      set destGroup to get record with uuid "\(escape(destinationUUID))"
      if destGroup is missing value then error "Destination not found"
      set dupRecord to duplicate record theRecord to destGroup
      """
    }
    else {
      destClause = "set dupRecord to duplicate record theRecord"
    }

    let script = """
    tell application id "DNtp"
      set theRecord to get record with uuid "\(escape(uuid))"
      if theRecord is missing value then error "Record not found"
      \(destClause)
      return {uuid of dupRecord, name of dupRecord, path of dupRecord}
    end tell
    """
    let result = try runAppleScript(script)
    return parseSimpleRecord(result)
  }

  func replicateRecord(uuid: String, to destinationUUID: String) throws -> [String: Any] {
    let script = """
    tell application id "DNtp"
      set theRecord to get record with uuid "\(escape(uuid))"
      if theRecord is missing value then error "Record not found"
      set destGroup to get record with uuid "\(escape(destinationUUID))"
      if destGroup is missing value then error "Destination not found"
      set repRecord to replicate record theRecord to destGroup
      return {uuid of repRecord, name of repRecord, path of repRecord}
    end tell
    """
    let result = try runAppleScript(script)
    return parseSimpleRecord(result)
  }

  func getRecordChildren(uuid: String) throws -> [[String: Any]] {
    let script = """
    tell application id "DNtp"
      set theRecord to get record with uuid "\(escape(uuid))"
      if theRecord is missing value then error "Record not found"
      set resultList to {}
      repeat with c in children of theRecord
        set end of resultList to {uuid of c, name of c, path of c, type of c as string}
      end repeat
      return resultList
    end tell
    """
    let result = try runAppleScript(script)
    return parseRecordList(result, keys: ["uuid", "name", "path", "type"])
  }

  func getCurrentRecord() throws -> [String: Any]? {
    let script = """
    tell application id "DNtp"
      set theRecord to content record
      if theRecord is missing value then return missing value
      return {uuid of theRecord, name of theRecord, path of theRecord, location of theRecord}
    end tell
    """
    let result = try runAppleScript(script)
    if result.descriptorType == typeNull {
      return nil
    }
    return [
      "uuid": result.atIndex(1)?.stringValue ?? "",
      "name": result.atIndex(2)?.stringValue ?? "",
      "path": result.atIndex(3)?.stringValue ?? "",
      "location": result.atIndex(4)?.stringValue ?? ""
    ]
  }

  func createGroup(name: String, databaseUUID: String, parentUUID: String?) throws -> [String: Any] {
    let destClause: String
    if let parentUUID = parentUUID {
      destClause = "set destGroup to get record with uuid \"\(escape(parentUUID))\""
    }
    else {
      destClause = "set destGroup to root of theDB"
    }

    let script = """
    tell application id "DNtp"
      set theDB to get database with uuid "\(escape(databaseUUID))"
      if theDB is missing value then error "Database not found"
      \(destClause)
      set theGroup to create record with {type:group, name:"\(escape(name))"} in destGroup
      return {uuid of theGroup, name of theGroup, path of theGroup}
    end tell
    """
    let result = try runAppleScript(script)
    return parseSimpleRecord(result)
  }

  func getTrash(databaseUUID: String) throws -> [[String: Any]] {
    let script = """
    tell application id "DNtp"
      set theDB to get database with uuid "\(escape(databaseUUID))"
      if theDB is missing value then error "Database not found"
      set trashGroup to trash group of theDB
      set resultList to {}
      set counter to 0
      repeat with r in children of trashGroup
        if counter >= 50 then exit repeat
        set end of resultList to {uuid of r, name of r, path of r}
        set counter to counter + 1
      end repeat
      return resultList
    end tell
    """
    let result = try runAppleScript(script)
    return parseRecordList(result, keys: ["uuid", "name", "path"])
  }

  func emptyTrash(databaseUUID: String) throws -> Bool {
    let script = """
    tell application id "DNtp"
      set theDB to get database with uuid "\(escape(databaseUUID))"
      if theDB is missing value then error "Database not found"
      empty trash of theDB
      return true
    end tell
    """
    let result = try runAppleScript(script)
    return result.booleanValue
  }

  func getSmartGroups(databaseUUID: String) throws -> [[String: Any]] {
    let script = """
    tell application id "DNtp"
      set theDB to get database with uuid "\(escape(databaseUUID))"
      if theDB is missing value then error "Database not found"
      set smartGroupList to every smart parent of theDB
      set resultList to {}
      repeat with sg in smartGroupList
        set end of resultList to {uuid of sg, name of sg, search predicates of sg}
      end repeat
      return resultList
    end tell
    """
    let result = try runAppleScript(script)
    return parseRecordList(result, keys: ["uuid", "name", "searchPredicates"])
  }

  func getSmartGroupContents(uuid: String) throws -> [[String: Any]] {
    let script = """
    tell application id "DNtp"
      set theSmartGroup to get record with uuid "\(escape(uuid))"
      if theSmartGroup is missing value then error "Smart group not found"
      set contentList to children of theSmartGroup
      set resultList to {}
      set counter to 0
      repeat with c in contentList
        if counter >= 50 then exit repeat
        set end of resultList to {uuid of c, name of c, path of c}
        set counter to counter + 1
      end repeat
      return resultList
    end tell
    """
    let result = try runAppleScript(script)
    return parseRecordList(result, keys: ["uuid", "name", "path"])
  }
}
