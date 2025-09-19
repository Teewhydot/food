# Paystack Payment Integration - Deployment Guide

## ✅ Deployment Completed

Your Firebase Functions have been successfully deployed to:
- **Project ID**: dfood-5aaf3
- **Region**: us-central1

## 🔗 Function URLs

| Function | URL |
|----------|-----|
| Create Transaction | https://us-central1-dfood-5aaf3.cloudfunctions.net/createPaystackTransaction |
| Verify Payment | https://us-central1-dfood-5aaf3.cloudfunctions.net/verifyPaystackPayment |
| Webhook Handler | https://us-central1-dfood-5aaf3.cloudfunctions.net/paystackWebhook |
| Transaction Status | https://us-central1-dfood-5aaf3.cloudfunctions.net/getTransactionStatus |

## 📋 Next Steps

### 1. Configure Paystack API Keys

Set your Paystack API keys in Firebase Functions configuration:

```bash
# For test environment
firebase functions:config:set paystack.secret_key="sk_test_your_secret_key"
firebase functions:config:set paystack.public_key="pk_test_your_public_key"

# For production
firebase functions:config:set paystack.secret_key="sk_live_your_secret_key"
firebase functions:config:set paystack.public_key="pk_live_your_public_key"

# Deploy configuration
firebase deploy --only functions
```

### 2. Configure Paystack Webhook

1. Log in to your [Paystack Dashboard](https://dashboard.paystack.com)
2. Go to **Settings** → **API Keys & Webhooks**
3. Add your webhook URL:
   ```
   https://us-central1-dfood-5aaf3.cloudfunctions.net/paystackWebhook
   ```
4. Copy the webhook secret and set it in Firebase:
   ```bash
   firebase functions:config:set paystack.webhook_secret="your_webhook_secret"
   firebase deploy --only functions
   ```

### 3. Update Your Flutter App

Add to your `.env` file (create if it doesn't exist):
```
DFOOD_FIREBASE_FUNCTIONS_URL=https://us-central1-dfood-5aaf3.cloudfunctions.net
```

### 4. Test Payment Flow

#### Test Cards for Paystack
- **Success**: 4084084084084081
- **Failed**: 4084080000000409
- **CVV**: 408
- **Expiry**: Any future date
- **PIN**: 0000
- **OTP**: 123456

#### Test Flow
1. Add items to cart
2. Go to Payment Method screen
3. Select Paystack
4. Click "Pay with Paystack"
5. Complete payment in browser
6. Return to app and verify payment

## 🔒 Security Checklist

- [ ] API keys are set in Firebase config (not in code)
- [ ] Webhook URL is configured in Paystack dashboard
- [ ] Webhook secret is set for signature verification
- [ ] Using HTTPS for all endpoints
- [ ] No sensitive data stored locally
- [ ] Payment verification happens on backend

## 📊 Monitoring

View function logs:
```bash
firebase functions:log
```

View specific function logs:
```bash
firebase functions:log --only createPaystackTransaction
```

## 🚨 Troubleshooting

### Payment not initializing
- Check Firebase Functions logs for errors
- Verify API keys are set correctly
- Ensure user is authenticated

### Webhook not working
- Verify webhook URL is exactly as shown above
- Check webhook secret matches
- Look for webhook events in Paystack dashboard

### Payment verification failing
- Ensure transaction reference is correct
- Check network connectivity
- Verify Firebase Functions are deployed

## 📞 Support

- **Paystack Support**: support@paystack.com
- **Paystack Docs**: https://paystack.com/docs
- **Firebase Support**: https://firebase.google.com/support

## ✅ Deployment Status

- [x] Firebase Functions deployed
- [x] Function URLs configured in app
- [ ] Paystack API keys configured
- [ ] Webhook URL added to Paystack
- [ ] Test payment completed
- [ ] Production keys configured (when ready)

---

**Last Updated**: 2025-09-19
**Deployed By**: Firebase CLI
**Environment**: Production (us-central1)
