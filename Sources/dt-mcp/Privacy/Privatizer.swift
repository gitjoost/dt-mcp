//
//  Privatizer.swift
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
import CryptoKit

// MARK: - Privatizer

@MainActor
class Privatizer {
  static let shared = Privatizer()

  private let encryptionKey: SymmetricKey
  private let tokenCache: TokenCache
  private let phonePatterns: [String]
  private let encodePhones: [String]

  // Regex patterns
  private let emailRegex: NSRegularExpression
  private let ssnRegex: NSRegularExpression
  private let cardRegex: NSRegularExpression
  private let sensitiveNumberRegex: NSRegularExpression  // Generic account/ID numbers
  private var phoneRegexes: [NSRegularExpression]

  private init() {
    let config = ConfigManager.shared
    tokenCache = TokenCache.shared
    phonePatterns = config.phonePatterns
    encodePhones = config.encodePhones

    let keyData = Data(config.encryptionKey.utf8)
    encryptionKey = SymmetricKey(data: SHA256.hash(data: keyData))

    emailRegex = try! NSRegularExpression(
      pattern: #"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#
    )
    ssnRegex = try! NSRegularExpression(
      pattern: #"\d{3}-\d{2}-\d{4}"#
    )
    cardRegex = try! NSRegularExpression(
      pattern: #"\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b"#
    )
    // Catches account numbers, IDs: "123456789", "1234:5678", "12-34-56-78"
    // Matches 8+ digits with optional separators (:-. )
    sensitiveNumberRegex = try! NSRegularExpression(
      pattern: #"\b\d+[:\-.\s]\d+([:\-.\s]\d+)*\b|\b\d{8,}\b"#
    )

    phoneRegexes = phonePatterns.compactMap { pattern in
      try? NSRegularExpression(pattern: pattern)
    }
  }

  // MARK: - Email Encoding

  func encodeEmail(_ email: String) -> String {
    let normalized = email.lowercased()
    let hmac = HMAC<SHA256>.authenticationCode(
      for: Data(normalized.utf8),
      using: encryptionKey
    )
    let short = Data(hmac).prefix(4).map { String(format: "%02x", $0) }.joined()
    let token = "[EM:\(short)]"
    tokenCache.store(token, original: email)
    return token
  }

  // MARK: - Generic Token Encoding

  func encodeToken(_ value: String, prefix: String) -> String {
    let hmac = HMAC<SHA256>.authenticationCode(
      for: Data(value.lowercased().utf8),
      using: encryptionKey
    )
    let short = Data(hmac).prefix(4).map { String(format: "%02x", $0) }.joined()
    let token = "[\(prefix):\(short)]"
    tokenCache.store(token, original: value)
    return token
  }

  // MARK: - Phone Encoding

  func normalizePhone(_ phone: String) -> String {
    let digits = phone.filter { $0.isNumber || $0 == "+" }
    return digits.hasPrefix("+") ? digits : "+\(digits)"
  }

  func encodePhone(_ phone: String) -> String {
    let normalized = normalizePhone(phone)
    let hmac = HMAC<SHA256>.authenticationCode(
      for: Data(normalized.utf8),
      using: encryptionKey
    )
    let short = Data(hmac).prefix(4).map { String(format: "%02x", $0) }.joined()
    let token = "[PH:\(short)]"
    tokenCache.store(token, original: phone)
    return token
  }

  func isKnownPhone(_ phone: String) -> Bool {
    let normalized = normalizePhone(phone)
    return encodePhones.contains { normalizePhone($0) == normalized }
  }

  // MARK: - Privatize Content

  func privatize(_ text: String) -> String {
    var result = text

    // Email: encode with HMAC (preserves correlation)
    let emailMatches = emailRegex.matches(
      in: result,
      range: NSRange(result.startIndex..., in: result)
    )
    for match in emailMatches.reversed() {
      if let range = Range(match.range, in: result) {
        let email = String(result[range])
        result.replaceSubrange(range, with: encodeEmail(email))
      }
    }

    // Credit card: 16 digits with optional separators (must run before phone)
    let cardMatches = cardRegex.matches(
      in: result,
      range: NSRange(result.startIndex..., in: result)
    )
    for match in cardMatches.reversed() {
      if let range = Range(match.range, in: result) {
        let card = String(result[range])
        result.replaceSubrange(range, with: encodeToken(card, prefix: "CC"))
      }
    }

    // SSN: 123-45-6789
    let ssnMatches = ssnRegex.matches(
      in: result,
      range: NSRange(result.startIndex..., in: result)
    )
    for match in ssnMatches.reversed() {
      if let range = Range(match.range, in: result) {
        let ssn = String(result[range])
        result.replaceSubrange(range, with: encodeToken(ssn, prefix: "SS"))
      }
    }

    // Phone: all phones get encoded (runs after card/SSN)
    for phoneRegex in phoneRegexes {
      let phoneMatches = phoneRegex.matches(
        in: result,
        range: NSRange(result.startIndex..., in: result)
      )
      for match in phoneMatches.reversed() {
        if let range = Range(match.range, in: result) {
          let phone = String(result[range])
          result.replaceSubrange(range, with: encodePhone(phone))
        }
      }
    }

    // Sensitive numbers: catch remaining account numbers, IDs (runs last)
    let sensitiveMatches = sensitiveNumberRegex.matches(
      in: result,
      range: NSRange(result.startIndex..., in: result)
    )
    for match in sensitiveMatches.reversed() {
      if let range = Range(match.range, in: result) {
        let num = String(result[range])
        result.replaceSubrange(range, with: encodeToken(num, prefix: "NN"))
      }
    }

    return result
  }

  // MARK: - Privatize Record Metadata

  func privatizeRecord(_ record: [String: Any]) -> [String: Any] {
    var result = record

    // Strip metadata
    result.removeValue(forKey: "path")
    result.removeValue(forKey: "creationDate")
    result.removeValue(forKey: "modificationDate")
    result.removeValue(forKey: "comment")
    result.removeValue(forKey: "url")

    // Privatize text content if present
    if let plainText = result["plainText"] as? String {
      result["plainText"] = privatize(plainText)
    }

    return result
  }

  // MARK: - Check PRIVATE Tag

  func isPrivate(_ tags: [String]) -> Bool {
    tags.contains { $0.uppercased() == "PRIVATE" }
  }

  func isPrivate(_ record: [String: Any]) -> Bool {
    if let tags = record["tags"] as? [String] {
      return isPrivate(tags)
    }
    return false
  }
}

// MARK: - Token Cache

@MainActor
class TokenCache {
  static let shared = TokenCache()

  private var cache: [String: String] = [:]
  private let cacheFile: URL

  private init() {
    let home = FileManager.default.homeDirectoryForCurrentUser
    let configDir = home.appendingPathComponent(".config/dt-mcp")
    cacheFile = configDir.appendingPathComponent("token_cache.json")
    load()
  }

  private func load() {
    guard FileManager.default.fileExists(atPath: cacheFile.path) else { return }
    do {
      let data = try Data(contentsOf: cacheFile)
      cache = try JSONDecoder().decode([String: String].self, from: data)
    }
    catch {
      cache = [:]
    }
  }

  private func save() {
    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      let data = try encoder.encode(cache)
      try data.write(to: cacheFile)
    }
    catch {
      // Silent fail
    }
  }

  func store(_ token: String, original: String) {
    cache[token] = original
    save()
  }

  func decode(_ token: String) -> String? {
    cache[token]
  }

  func decodeAll(_ tokens: [String]) -> [String: String] {
    var result: [String: String] = [:]
    for token in tokens {
      if let original = cache[token] {
        result[token] = original
      }
    }
    return result
  }

  func clear() -> Int {
    let count = cache.count
    cache.removeAll()
    try? FileManager.default.removeItem(at: cacheFile)
    return count
  }
}
