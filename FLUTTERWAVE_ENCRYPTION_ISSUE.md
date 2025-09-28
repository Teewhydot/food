# Flutterwave V4 API - Card Encryption Implementation Issue

## Overview
We are implementing card payment encryption for the Flutterwave V4 API Direct Charges endpoint but encountering unclear specifications regarding the encryption implementation, specifically the relationship between the `nonce` field and the encryption/decryption process.

## Current Implementation

### Our Encryption Setup
- **Algorithm**: AES-256-CBC
- **Key Source**: Flutterwave dashboard encryption key (base64 encoded)
- **IV Generation**: 16-byte random IV (as required by AES-256-CBC)
- **Encoding**: UTF-8 for plaintext, Base64 for encrypted output

### Code Implementation
```dart
// Encryption Service
final iv = IV.fromSecureRandom(16); // 16-byte IV for AES-256-CBC
final encrypted = _encrypter.encrypt(cardNumber, iv: iv);

// Returns
{
  'encrypted': encrypted.base64,
  'iv': iv.base64  // 16-byte IV in base64
}
```

### API Request Structure
```json
{
  "payment_method": {
    "card": {
      "nonce": "A1B2C3D4E5F6",  // 12-char alphanumeric
      "encrypted_card_number": "base64_encrypted_data",
      "encrypted_cvv": "base64_encrypted_data",
      "encrypted_expiry_month": "base64_encrypted_data",
      "encrypted_expiry_year": "base64_encrypted_data"
    }
  }
}
```

## The Problem

### 1. Nonce vs IV Mismatch
- **AES-256-CBC Requirement**: 16-byte (128-bit) Initialization Vector (IV)
- **Flutterwave API Requirement**: 12-character alphanumeric `nonce` field
- **Issue**: These formats are incompatible

### 2. Unclear Nonce Usage
The API documentation states:
> "nonce: A single-use 12 character alphanumeric string for field-level encryption"

However, it doesn't specify:
- Is the nonce used as the IV for decryption?
- How is a 12-char nonce converted to a 16-byte IV?
- Should we derive the IV from the nonce using a specific method?

### 3. Current Implementation Gap
Our current implementation:
- Generates a random 12-char nonce (unrelated to encryption)
- Uses a separate 16-byte IV for actual encryption
- Flutterwave receives encrypted data + nonce, but they're not connected
- **Result**: Flutterwave cannot decrypt the data

## Questions for Flutterwave Support

### 1. Encryption Specification
- What is the exact encryption algorithm expected? (AES-256-CBC, AES-128-CBC, other?)
- How should the 12-character nonce relate to the encryption process?
- Is there a specific IV derivation method from the nonce?

### 2. Implementation Details
- Should we:
  a) Use the nonce directly as part of the encryption (how, given the size mismatch)?
  b) Derive a 16-byte IV from the 12-char nonce (what method)?
  c) Use a different encryption approach entirely?

### 3. Decryption Process
- How does Flutterwave use the nonce to decrypt the card data?
- Can you provide a working example of the encryption/decryption process?
- Is there reference implementation or SDK code we can review?

## Test Scenarios

### Scenario 1: Random Nonce (Current)
```dart
nonce: "A1B2C3D4E5F6" // Random, unrelated to encryption
IV: [separate 16-byte IV used for encryption]
Result: Decryption fails - nonce and IV are unrelated
```

### Scenario 2: Nonce-Derived IV (Proposed)
```dart
nonce: "A1B2C3D4E5F6"
IV: derive_16_bytes_from_nonce(nonce) // How?
Result: Unknown - need derivation method
```

## Environment Details
- **Flutterwave Environment**: Sandbox/Production
- **API Version**: V4
- **Endpoint**: `https://api.flutterwave.cloud/developersandbox/orchestration/direct-orders`
- **SDK/Language**: Dart/Flutter
- **Encryption Library**: encrypt package (Dart)

## Request for Documentation
We need:
1. Complete encryption/decryption specification
2. Sample code showing proper nonce usage
3. Test vectors (input → encrypted output) to verify our implementation
4. Clarification on the nonce-to-IV relationship

## Code Samples Available
We can provide:
- Our complete encryption service implementation
- API request/response logs (with sensitive data redacted)
- Test cases showing the current issue

## Contact Information
[abubakarissa47722@gmail.com]

---

**Note**: This issue is blocking our payment integration. We have the encryption key from the dashboard and can encrypt data, but without understanding the nonce's role in decryption, we cannot ensure Flutterwave can decrypt our card data properly.

**Specific Ask**: Please provide a working example of how to encrypt card data with a 12-character nonce such that Flutterwave's servers can successfully decrypt it using the same nonce.
