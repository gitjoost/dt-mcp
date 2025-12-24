# Release Procedure for dt-mcp

## Prerequisites

- Xcode command line tools installed
- Developer ID Application certificate in Keychain
- App-specific password for notarization (stored in `../app-specific-pwd.md`)

## Version Update

1. Update version in `Sources/dt-mcp/Server/MCPServer.swift`:
   ```swift
   serverInfo: ServerInfo(name: "dt-mcp", version: "X.Y.Z")
   ```

2. Update version in README.md if mentioned

## Build Universal Binary

```bash
cd /Users/joost/Documents/projects/XCode/dt/dt-mcp
swift build -c release --arch arm64 --arch x86_64
```

Binary output: `.build/apple/Products/Release/dt-mcp`

## Sign Binary

```bash
codesign --sign "Developer ID Application: intellecy inc. (HVNSG55X3A)" \
  --options runtime \
  --timestamp \
  --force \
  .build/apple/Products/Release/dt-mcp
```

Verify signature:
```bash
codesign --verify --verbose .build/apple/Products/Release/dt-mcp
```

## Notarize with Apple

1. Copy binary to dist folder:
   ```bash
   mkdir -p dist
   cp .build/apple/Products/Release/dt-mcp dist/
   ```

2. Create zip for notarization:
   ```bash
   cd dist
   zip dt-mcp-notarize.zip dt-mcp
   ```

3. Submit for notarization:
   ```bash
   xcrun notarytool submit dt-mcp-notarize.zip \
     --apple-id "jib_0@hotmail.com" \
     --team-id "HVNSG55X3A" \
     --password "APP-SPECIFIC-PASSWORD" \
     --wait
   ```

4. Wait for "status: Accepted" (usually 1-5 minutes)

Note: Standalone executables cannot be stapled. The notarization ticket is stored on Apple's servers and verified online by Gatekeeper.

## Package for Distribution

```bash
cd dist
rm -f dt-mcp-notarize.zip
zip dt-mcp-vX.Y.Z-macos.zip dt-mcp
shasum -a 256 dt-mcp-vX.Y.Z-macos.zip > dt-mcp-vX.Y.Z-macos.zip.sha256
```

## Git Release

```bash
git add -A
git commit -m "Release vX.Y.Z"
git tag vX.Y.Z
git push origin main --tags
```

## GitHub Release

1. Go to GitHub repo → Releases → "Create new release"
2. Select tag `vX.Y.Z`
3. Title: `dt-mcp vX.Y.Z`
4. Attach files:
   - `dist/dt-mcp-vX.Y.Z-macos.zip`
   - `dist/dt-mcp-vX.Y.Z-macos.zip.sha256`
5. Add release notes describing changes
6. Publish release

## Verification

Users can verify the binary:
```bash
# Check signature
codesign -dv --verbose=2 dt-mcp

# Verify checksum
shasum -a 256 -c dt-mcp-vX.Y.Z-macos.zip.sha256
```
