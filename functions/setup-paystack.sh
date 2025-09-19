#!/bin/bash

# Paystack Configuration Setup Script
# This script configures Paystack API keys for Firebase Functions

echo "================================================"
echo "Paystack Payment Integration Setup"
echo "================================================"
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "Error: Firebase CLI is not installed."
    echo "Please install it with: npm install -g firebase-tools"
    exit 1
fi

echo "This script will configure your Paystack API keys for Firebase Functions."
echo ""
echo "You can find your API keys at:"
echo "https://dashboard.paystack.com/#/settings/developer"
echo ""

# Prompt for environment
echo "Select environment:"
echo "1) Test (use test keys)"
echo "2) Live (use live keys)"
read -p "Enter choice (1 or 2): " env_choice

# Set key prefix based on environment
if [ "$env_choice" = "1" ]; then
    key_prefix="sk_test_"
    echo ""
    echo "Using TEST environment"
elif [ "$env_choice" = "2" ]; then
    key_prefix="sk_live_"
    echo ""
    echo "Using LIVE environment"
    echo "⚠️  Warning: This will use real money for transactions!"
else
    echo "Invalid choice. Exiting."
    exit 1
fi

# Prompt for secret key
echo ""
read -p "Enter your Paystack Secret Key (starts with $key_prefix): " secret_key

# Validate key format
if [[ ! "$secret_key" =~ ^sk_(test|live)_.+ ]]; then
    echo "Error: Invalid key format. Key should start with sk_test_ or sk_live_"
    exit 1
fi

# Set Firebase Functions configuration
echo ""
echo "Setting Firebase Functions configuration..."
firebase functions:config:set paystack.secret_key="$secret_key"

if [ $? -eq 0 ]; then
    echo "✅ Configuration set successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Deploy the functions: firebase deploy --only functions"
    echo "2. Configure webhook in Paystack dashboard:"
    echo "   URL: https://us-central1-dfood-5aaf3.cloudfunctions.net/paystackWebhook"
    echo ""
    echo "Test your integration with Paystack test cards:"
    echo "Card: 4084084084084081"
    echo "CVV: 408"
    echo "Expiry: Any future date"
    echo "PIN: 0000"
    echo "OTP: 123456"
else
    echo "❌ Error setting configuration. Please check your Firebase login and try again."
    exit 1
fi