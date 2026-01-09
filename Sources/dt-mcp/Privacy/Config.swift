//
//  Config.swift
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

// MARK: - Configuration

struct MCPConfig: Codable {
  var privacyMode: Bool
  var encryptionKey: String
  var phonePatterns: [String]
  var encodePhones: [String]
  var excludedDatabases: [String]

  enum CodingKeys: String, CodingKey {
    case privacyMode = "privacy_mode"
    case encryptionKey = "encryption_key"
    case phonePatterns = "phone_patterns"
    case encodePhones = "encode_phones"
    case excludedDatabases = "excluded_databases"
  }

  static let defaultPhonePatterns = [
    #"\b\d{3}[-.\s]?\d{3,4}[-.\s]?\d{4}\b"#,  // Generic: 3-3-4 or 3-4-4 digit patterns
    #"(\+?1[-.\s]?)?(\(?\d{3}\)?[-.\s]?)?\d{3}[-.\s]?\d{4}"#,  // US format
    #"\+44\s?\d{4}\s?\d{6}"#,  // UK
    #"\+31\s?6\s?\d{8}"#  // Netherlands
  ]

  init(
    privacyMode: Bool = false,
    encryptionKey: String = "",
    phonePatterns: [String] = defaultPhonePatterns,
    encodePhones: [String] = [],
    excludedDatabases: [String] = []
  ) {
    self.privacyMode = privacyMode
    self.encryptionKey = encryptionKey
    self.phonePatterns = phonePatterns
    self.encodePhones = encodePhones
    self.excludedDatabases = excludedDatabases
  }
}

@MainActor
class ConfigManager {
  static let shared = ConfigManager()

  private let configDir: URL
  private let configFile: URL
  private(set) var config: MCPConfig

  private init() {
    let home = FileManager.default.homeDirectoryForCurrentUser
    configDir = home.appendingPathComponent(".config/dt-mcp")
    configFile = configDir.appendingPathComponent("config.json")
    config = MCPConfig()
    load()
  }

  private func load() {
    do {
      try FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true)

      if FileManager.default.fileExists(atPath: configFile.path) {
        let data = try Data(contentsOf: configFile)
        config = try JSONDecoder().decode(MCPConfig.self, from: data)
      }

      if config.encryptionKey.isEmpty {
        config.encryptionKey = generateEncryptionKey()
        save()
      }
    }
    catch {
      config = MCPConfig(encryptionKey: generateEncryptionKey())
      save()
    }
  }

  func save() {
    do {
      try FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true)
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      let data = try encoder.encode(config)
      try data.write(to: configFile)
    }
    catch {
      // Silent fail - config is still usable in memory
    }
  }

  private func generateEncryptionKey() -> String {
    var bytes = [UInt8](repeating: 0, count: 32)
    _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    return Data(bytes).base64EncodedString()
  }

  // MARK: - Accessors

  var encryptionKey: String {
    config.encryptionKey
  }

  var privacyMode: Bool {
    get { config.privacyMode }
    set {
      config.privacyMode = newValue
      save()
    }
  }

  var phonePatterns: [String] {
    config.phonePatterns
  }

  var encodePhones: [String] {
    config.encodePhones
  }

  // MARK: - Database Exclusion

  var excludedDatabases: [String] {
    config.excludedDatabases
  }

  func isExcluded(_ uuid: String) -> Bool {
    config.excludedDatabases.contains(uuid)
  }

  func excludeDatabase(_ uuid: String) {
    if !config.excludedDatabases.contains(uuid) {
      config.excludedDatabases.append(uuid)
      save()
    }
  }

  func includeDatabase(_ uuid: String) {
    config.excludedDatabases.removeAll { $0 == uuid }
    save()
  }
}
