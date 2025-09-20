# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-09-19-flutterwave-payment-integration/spec.md

> Created: 2025-09-19
> Version: 1.0.0

## Technical Requirements

### Flutter Frontend Implementation

- **FlutterwaveTransactionEntity**: Create entity with fields for reference, orderId, userId, amount, currency, email, status, authorizationUrl, accessCode, timestamps, and metadata (excluding saved card fields)
- **FlutterwaveService**: HTTP service class for API communication with initialization, verification, and status checking methods using Firebase Auth tokens
- **FlutterwavePaymentDataSource**: Abstract interface and Firebase implementation following the same pattern as Paystack
- **FlutterwavePaymentRepository**: Repository pattern implementation with proper error handling and entity conversion
- **FlutterwavePaymentBloc**: BLoC state management with events (Initialize, Verify, GetStatus, Clear) and corresponding states
- **FlutterwaveWebviewScreen**: Secure payment screen using flutter_inappwebview with real-time Firebase listeners for status updates
- **Payment Method UI Integration**: Update existing payment method selection to include Flutterwave option alongside Paystack

### Firebase Cloud Functions Backend

- **createFlutterwaveTransaction**: Initialize payment with user validation, amount conversion (x100 for kobo), and order creation
- **verifyFlutterwavePayment**: Payment verification endpoint with order status updates and notification triggers
- **getFlutterwaveTransactionStatus**: Status checking endpoint for real-time updates
- **flutterwaveWebhook**: Webhook handler for Flutterwave payment notifications and automatic verification
- **Environment Configuration**: Sandbox and production API keys, base URLs, and webhook secret management
- **Error Handling**: Comprehensive logging, validation, and error response formatting
- **Security**: Request authentication, CORS configuration, and webhook signature verification

### Integration Architecture

- **Currency Handling**: Amount conversion to kobo (multiply by 100) consistent with Paystack implementation
- **Real-time Updates**: Firebase Firestore listeners for payment status changes and automatic UI updates
- **Order Management**: Integration with existing order entities and status workflows without modifications
- **Error Handling**: Consistent error states and user feedback patterns matching Paystack implementation
- **Dependency Injection**: Registration of Flutterwave services in existing GetIt configuration
- **BLoC Provider Integration**: Addition of FlutterwavePaymentBloc to app-level BLoC providers

### Security and Validation

- **API Communication**: All sensitive operations through Firebase Cloud Functions with proper authentication
- **Webview Security**: Secure payment processing with SSL validation and redirect handling
- **Data Validation**: Input sanitization, amount validation, and user authentication checks
- **Webhook Security**: Signature verification for incoming Flutterwave webhook notifications

## Approach

The implementation will follow the existing Paystack integration pattern to ensure consistency and maintainability:

1. **Entity Layer**: Create FlutterwaveTransactionEntity mirroring Paystack structure
2. **Data Layer**: Implement data sources and repositories following established patterns
3. **Domain Layer**: Define use cases and repository interfaces
4. **Presentation Layer**: Implement BLoC state management and UI components
5. **Backend Integration**: Deploy Firebase Cloud Functions with proper security measures
6. **Testing**: Unit tests for all layers and integration tests for payment flows

## External Dependencies

- **Flutterwave Flutter SDK** - Official Flutterwave SDK for Flutter integration
- **Justification:** Provides secure and standardized integration with Flutterwave payment APIs, handles authentication, and includes built-in security features

- **flutter_inappwebview** - Already included for Paystack, will be reused for Flutterwave webview payments
- **Justification:** Maintains consistency with existing payment flow and provides secure in-app browser functionality