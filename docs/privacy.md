# Privacy

Having an LLM/AI work with your documents means these are sent to the LLM provider's servers. Your data, potentially private, goes off-site. You may not want that.

DEVONthink's built-in chat does NOT send original documents to the LLM—metadata is stripped and images are processed. Look up DEVONthink's help on "AI Explained" for details. 
DEVONthink's treatment of documents before they are part of an AI query is well done - this MCP server does not yet come close to that level of anonymization, you do well to consider that before use. 

Whereas DEVONthink's chat removes PII and other sensitive information, dt-mcp's strategy is to replace it with a unique text string that is encoded with a local key. So the private info remains part of the contents that potentially can be searched locally since you, the user, has the encryption key. However, keep in mind that even then your query remains unencrypted.

**This MCP server now offers the `PRIVATE` tag:**

| Document Type | What Gets Sent to LLM |
|---------------|----------------------|
| Regular documents | Full content as-is |
| `PRIVATE`-tagged documents | Anonymized content with PII tokenized |

## How PRIVATE Tag Works

Tag any document with `PRIVATE` (case-insensitive) in DEVONthink, and when accessed via this MCP:

1. **PII is tokenized** - sensitive data is replaced with HMAC-encoded tokens:
   - Emails → `[EM:xxxxxxxx]`
   - Phone numbers → `[PH:xxxxxxxx]`
   - Credit cards → `[CC:xxxxxxxx]`
   - SSN → `[SS:xxxxxxxx]`
   - Account numbers/IDs → `[NN:xxxxxxxx]`

2. **Metadata is stripped** - author, dates, paths, URLs, comments are removed

3. **Tokens are correlatable** - the LLM can still understand "these 3 emails are from the same person" without seeing the actual address

4. **Tokens are decodable** - original values are stored locally in `~/.config/dt-mcp/token_cache.json` for later retrieval

5. **Write-protected** - the AI cannot modify, delete, move, or change metadata on PRIVATE-tagged documents

## What Stays Local

- Actual email addresses, phone numbers, SSNs, credit cards
- DEVONthink searches (run locally with real values)
- Token-to-original mappings

## Configuration Files

Located in `~/.config/dt-mcp/`:

| File | Purpose |
|------|---------|
| `config.json` | Encryption key (auto-generated on first run), phone patterns |
| `token_cache.json` | Maps tokens back to original values for later retrieval |

## What Goes to LLM

- Tokenized content (meaningless without local key)
- Document names and non-PII text
