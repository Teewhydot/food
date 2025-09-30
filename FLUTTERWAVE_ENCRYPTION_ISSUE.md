# Flutterwave V4 API - Card Encryption Implementation Issue [SOLVED]

## Overview
~~We are implementing card payment encryption for the Flutterwave V4 API Direct Charges endpoint but encountering unclear specifications regarding the encryption implementation, specifically the relationship between the `nonce` field and the encryption/decryption process.~~

**UPDATE: ISSUE RESOLVED** - The problem was that we were using AES-256-CBC instead of AES-GCM, and not using the 12-character nonce as the IV directly.

## Previous Implementation (INCORRECT)

### Our Previous Encryption Setup (INCORRECT)
- **Algorithm**: ~~AES-256-CBC~~ (WRONG - should be AES-GCM)
- **Key Source**: Flutterwave dashboard encryption key (base64 encoded) ✓
- **IV Generation**: ~~16-byte random IV~~ (WRONG - should use 12-char nonce as IV)
- **Encoding**: UTF-8 for plaintext, Base64 for encrypted output ✓

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

## SOLUTION IMPLEMENTED ✅

### Root Cause
The issue was **algorithm mismatch** and **incorrect IV usage**:
1. **Wrong Algorithm**: We were using AES-256-CBC instead of AES-GCM
2. **Wrong IV**: We were generating random 16-byte IVs instead of using the 12-character nonce directly
3. **Disconnected Nonce**: The nonce sent to Flutterwave was unrelated to the encryption IV

### Correct Implementation
Based on Flutterwave's clarification, the V4 API requires:
- **Algorithm**: AES-GCM (not AES-256-CBC)
- **IV/Nonce**: Use the 12-character nonce directly as the Initialization Vector
- **Key**: Same 256-bit key from Flutterwave dashboard
- **Process**: Generate nonce → Use as IV for AES-GCM → Send same nonce to API

### Updated Code Structure

#### 1. Dependencies
```yaml
# pubspec.yaml
dependencies:
  cryptography: ^2.7.0  # Added for proper AES-GCM support
```

#### 2. Updated Encryption Service
```dart
// New AES-GCM implementation
import 'package:cryptography/cryptography.dart';

class CardEncryptionService {
  static AesGcm? _algorithm;
  static SecretKey? _secretKey;

  static Future<void> initialize() async {
    final keyBytes = await _getSecureEncryptionKeyBytes();
    _algorithm = AesGcm.with256bits();
    _secretKey = SecretKey(keyBytes);
  }

  Future<Map<String, String>> encryptAllCardDetails({
    required String cardNumber,
    required String cvv,
    required String expiryMonth,
    required String expiryYear,
    required String nonce, // Now required!
  }) async {
    // Convert 12-char nonce to bytes for use as IV
    final nonceBytes = utf8.encode(nonce);

    // Encrypt each field with the same nonce as IV
    final encryptedCardNumber = await _algorithm!.encrypt(
      utf8.encode(cleanCardNumber),
      secretKey: _secretKey!,
      nonce: nonceBytes,
    );
    // ... encrypt other fields

    return {
      'encrypted_card_number': base64Encode(encryptedCardNumber.cipherText),
      'encrypted_cvv': base64Encode(encryptedCVV.cipherText),
      'encrypted_expiry_month': base64Encode(encryptedExpiryMonth.cipherText),
      'encrypted_expiry_year': base64Encode(encryptedExpiryYear.cipherText),
      'nonce': nonce, // Same nonce used for encryption
    };
  }
}
```

#### 3. Updated Payment Flow
```dart
// Generate nonce BEFORE encryption
final nonce = _encryptionService.generateSecureNonce(12);

// Encrypt with the nonce
final encryptedCardData = await _encryptionService.encryptAllCardDetails(
  cardNumber: cardNumber,
  cvv: cvv,
  expiryMonth: expiryMonth,
  expiryYear: expiryYear,
  nonce: nonce, // Pass nonce to encryption
);

// Send to Flutterwave with the SAME nonce
final payload = {
  'payment_method': {
    'card': {
      'nonce': nonce, // Same nonce used for encryption
      'encrypted_card_number': encryptedCardData['encrypted_card_number'],
      'encrypted_cvv': encryptedCardData['encrypted_cvv'],
      // ...
    }
  }
};
```

### Key Changes Made
1. **Added cryptography package** for proper AES-GCM support
2. **Updated CardEncryptionService** to use AES-GCM instead of AES-256-CBC
3. **Modified encryption methods** to accept and use nonce as IV
4. **Updated Flutterwave data source** to generate nonce before encryption
5. **Fixed payload structure** to use the same nonce for API and encryption
6. **Updated all tests** to reflect AES-GCM implementation

### Verification
- All encryption methods now require a 12-character nonce
- The same nonce is used as IV for AES-GCM encryption and sent to Flutterwave
- Tests validate nonce-based encryption/decryption
- Integration follows the exact flow Flutterwave expects

### Files Modified
- `pubspec.yaml` - Added cryptography package
- `lib/food/core/services/card_encryption_service.dart` - Switched to AES-GCM
- `lib/food/features/payments/data/remote/data_sources/flutterwave_payment_data_source.dart` - Updated integration
- `test/core/services/card_encryption_service_test.dart` - Updated tests

**RESULT**: Flutterwave can now successfully decrypt card data using the provided nonce because we're using the correct AES-GCM algorithm with the nonce as the IV.

---

## Legacy Documentation (For Reference)

**Note**: ~~This issue is blocking our payment integration. We have the encryption key from the dashboard and can encrypt data, but without understanding the nonce's role in decryption, we cannot ensure Flutterwave can decrypt our card data properly.~~

**SOLVED**: ~~Specific Ask: Please provide a working example of how to encrypt card data with a 12-character nonce such that Flutterwave's servers can successfully decrypt it using the same nonce.~~
