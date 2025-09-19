# Paystack Setup Instructions

## ✅ Configuration Fixed!

The Firebase Functions have been updated to use **only** Firebase Functions config (no .env files).

## 🚀 Quick Setup

### Windows Users:
```bash
cd functions
setup-paystack.bat
```

### Mac/Linux Users:
```bash
cd functions
chmod +x setup-paystack.sh
./setup-paystack.sh
```

### Manual Setup:
```bash
# Set your Paystack secret key
firebase functions:config:set paystack.secret_key="sk_test_YOUR_KEY_HERE"

# Deploy the functions
firebase deploy --only functions
```

## 📝 Important Notes

1. **No .env files needed** - The functions now only use Firebase Functions config
2. **Get your keys from**: https://dashboard.paystack.com/#/settings/developer
3. **Use test keys first**: Keys starting with `sk_test_` for development
4. **Production keys**: Keys starting with `sk_live_` when ready for production

## 🔍 Verify Configuration

After setting the config, you can verify it:
```bash
firebase functions:config:get
```

You should see:
```json
{
  "paystack": {
    "secret_key": "sk_test_..."
  }
}
```

## 🚨 Troubleshooting

If you see "Payment service not configured" error:
1. You haven't set the Paystack secret key
2. Run the setup script or manual command above
3. Redeploy with `firebase deploy --only functions`

## ✅ What Changed

- Removed all `.env` file dependencies
- Functions now only read from Firebase Functions config
- Added validation to check if key is configured
- Better error messages when key is missing

---

**Ready to go!** Just run the setup script and deploy.