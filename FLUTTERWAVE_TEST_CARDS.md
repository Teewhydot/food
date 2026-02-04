# Flutterwave Test Cards

This document contains the test card details for Flutterwave sandbox testing.

## Most Common Test Cards

### MasterCard - Successful Payment (3D Secure)
- **Card Number:** `5399 8383 8383 8381`
- **Expiry:** `09/32` (or any future date)
- **CVV:** `828`
- **PIN:** `3310`
- **OTP:** `12345`

### Visa - Successful Payment (No 3D Secure)
- **Card Number:** `4187 4274 1556 4246`
- **Expiry:** `09/32`
- **CVV:** `828`
- **PIN:** Not required

### MasterCard - PIN Required
- **Card Number:** `5438 8980 1456 0229`
- **Expiry:** `09/30`
- **CVV:** `890`
- **PIN:** `470`

### MasterCard - Failed Payment
- **Card Number:** `5258 5962 0302 4182`
- **Expiry:** `09/32`
- **CVV:** `828`
- **PIN:** `0000`

## Other Test Scenarios

### Insufficient Funds
- **Card Number:** `5555 5555 5555 5557`
- **Expiry:** `09/32`
- **CVV:** `828`

### Card Expired
- Use any valid card number with an expiry date in the past (e.g., `09/20`)

### Invalid CVV
- Use any valid card number with CVV `000`

## Testing Guidelines

### Important Notes
- These cards **only work in sandbox/test mode**
- Use any future expiry date (e.g., `09/30`, `09/32`, `12/25`)
- All test cards use the same billing address format
- **No real money is charged** in sandbox mode
- The environment is determined by your Flutterwave Secret Key prefix:
  - `FLWSECK_TEST-*` = Sandbox/Test mode
  - `FLWSECK-*` (without _TEST) = Live mode

### OTP for Testing
When prompted for OTP during 3D Secure authentication, use: **`12345`**

### Successful Payment Flow
1. Enter card details
2. If 3D Secure: enter OTP `12345`
3. Payment should be approved
4. You'll receive a successful payment response

### Failed Payment Flow
1. Use the failed payment card above
2. Payment will be declined
3. You'll receive an error response

## Resources

For more information, visit:
- [Flutterwave Official Testing Documentation](https://developer.flutterwave.com/v3.0/docs/testing)
- [Flutterwave Dashboard](https://dashboard.flutterwave.com/)

## Troubleshooting

If payments fail during testing:
1. **Check your API keys** - Ensure you're using test keys (FLWSECK_TEST-*)
2. **Verify function deployment** - Ensure Firebase Functions are deployed
3. **Check environment variables** - Ensure `FLUTTERWAVE_SECRET_KEY` is set in functions/.env.yaml
4. **Review function logs** - Use Firebase Console to view Cloud Functions logs
5. **Test card format** - Ensure card number has no spaces (use `5399838383838381`, not `5399 8383 8383 8381`)

## Quick Reference Card Numbers

| Purpose | Card Number | Notes |
|---------|-------------|-------|
| Success (3DS) | 5399 8383 8383 8381 | Requires OTP: 12345 |
| Success (No 3DS) | 4187 4274 1556 4246 | Easiest for testing |
| PIN Required | 5438 8980 1456 0229 | PIN: 470 |
| Failed Payment | 5258 5962 0302 4182 | Will decline |
| Insufficient Funds | 5555 5555 5555 5557 | Low balance |

---

**Last Updated:** January 2025
**Flutterwave API Version:** v3
