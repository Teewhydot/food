@echo off
REM Paystack Configuration Setup Script for Windows
REM This script configures Paystack API keys for Firebase Functions

echo ================================================
echo Paystack Payment Integration Setup
echo ================================================
echo.

REM Check if Firebase CLI is installed
where firebase >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: Firebase CLI is not installed.
    echo Please install it with: npm install -g firebase-tools
    exit /b 1
)

echo This script will configure your Paystack API keys for Firebase Functions.
echo.
echo You can find your API keys at:
echo https://dashboard.paystack.com/#/settings/developer
echo.

REM Prompt for environment
echo Select environment:
echo 1) Test (use test keys)
echo 2) Live (use live keys)
set /p env_choice="Enter choice (1 or 2): "

REM Set key prefix based on environment
if "%env_choice%"=="1" (
    set key_prefix=sk_test_
    echo.
    echo Using TEST environment
) else if "%env_choice%"=="2" (
    set key_prefix=sk_live_
    echo.
    echo Using LIVE environment
    echo WARNING: This will use real money for transactions!
) else (
    echo Invalid choice. Exiting.
    exit /b 1
)

REM Prompt for secret key
echo.
set /p secret_key="Enter your Paystack Secret Key (starts with %key_prefix%): "

REM Set Firebase Functions configuration
echo.
echo Setting Firebase Functions configuration...
firebase functions:config:set paystack.secret_key="%secret_key%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Configuration set successfully!
    echo.
    echo Next steps:
    echo 1. Deploy the functions: firebase deploy --only functions
    echo 2. Configure webhook in Paystack dashboard:
    echo    URL: https://us-central1-dfood-5aaf3.cloudfunctions.net/paystackWebhook
    echo.
    echo Test your integration with Paystack test cards:
    echo Card: 4084084084084081
    echo CVV: 408
    echo Expiry: Any future date
    echo PIN: 0000
    echo OTP: 123456
) else (
    echo.
    echo Error setting configuration. Please check your Firebase login and try again.
    exit /b 1
)