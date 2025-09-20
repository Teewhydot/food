# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-09-19-flutterwave-payment-integration/spec.md

> Created: 2025-09-19
> Status: Ready for Implementation

## Tasks

- [ ] 1. Implement Flutterwave Data Layer (Entities and Models)
  - [ ] 1.1 Write tests for FlutterwaveTransactionEntity
  - [ ] 1.2 Create FlutterwaveTransactionEntity with all required fields (reference, orderId, userId, amount, currency, email, status, authorizationUrl, accessCode, timestamps, metadata)
  - [ ] 1.3 Add helper methods (isPending, isSuccess, isFailed, isProcessing) to entity
  - [ ] 1.4 Create JSON serialization methods (fromJson, toJson) for entity
  - [ ] 1.5 Add entity to dependency injection and exports
  - [ ] 1.6 Verify all tests pass

- [ ] 2. Implement Flutterwave Service Layer
  - [ ] 2.1 Write tests for FlutterwaveService
  - [ ] 2.2 Create FlutterwaveService class with HTTP client configuration
  - [ ] 2.3 Implement initializePayment method with Firebase Auth integration
  - [ ] 2.4 Implement verifyPayment method with proper error handling
  - [ ] 2.5 Implement getTransactionStatus method
  - [ ] 2.6 Add currency conversion logic (amount * 100 for kobo)
  - [ ] 2.7 Configure service in dependency injection
  - [ ] 2.8 Verify all tests pass

- [ ] 3. Implement Flutterwave Data Source and Repository
  - [ ] 3.1 Write tests for FlutterwavePaymentDataSource and Repository
  - [ ] 3.2 Create abstract FlutterwavePaymentDataSource interface
  - [ ] 3.3 Implement FirebaseFlutterwavePaymentDataSource with Firebase Functions integration
  - [ ] 3.4 Create FlutterwavePaymentRepository interface
  - [ ] 3.5 Implement FlutterwavePaymentRepositoryImpl with error handling
  - [ ] 3.6 Add repository to dependency injection
  - [ ] 3.7 Verify all tests pass

- [ ] 4. Implement Flutterwave BLoC State Management
  - [ ] 4.1 Write tests for FlutterwavePaymentBloc events and states
  - [ ] 4.2 Create FlutterwavePaymentEvent classes (Initialize, Verify, GetStatus, Clear)
  - [ ] 4.3 Create FlutterwavePaymentState classes (Initial, Loading, Initialized, Verified, Error)
  - [ ] 4.4 Implement FlutterwavePaymentBloc with event handlers
  - [ ] 4.5 Add proper error handling and state transitions
  - [ ] 4.6 Register bloc in app-level BLoC providers
  - [ ] 4.7 Verify all tests pass

- [ ] 5. Implement Flutterwave UI Components
  - [ ] 5.1 Write widget tests for FlutterwaveWebviewScreen
  - [ ] 5.2 Create FlutterwaveWebviewScreen with flutter_inappwebview
  - [ ] 5.3 Implement real-time Firebase listeners for payment status
  - [ ] 5.4 Add loading indicators and progress tracking
  - [ ] 5.5 Handle payment completion/cancellation callbacks
  - [ ] 5.6 Update PaymentMethodScreen to include Flutterwave option
  - [ ] 5.7 Add proper navigation and routing for Flutterwave flow
  - [ ] 5.8 Verify all tests pass

- [ ] 6. Implement Firebase Cloud Functions for Flutterwave
  - [ ] 6.1 Write unit tests for Cloud Functions
  - [ ] 6.2 Create createFlutterwaveTransaction function with validation
  - [ ] 6.3 Implement verifyFlutterwavePayment function with order updates
  - [ ] 6.4 Create getFlutterwaveTransactionStatus function
  - [ ] 6.5 Implement flutterwaveWebhook function with signature verification
  - [ ] 6.6 Add environment configuration for API keys and URLs
  - [ ] 6.7 Deploy functions and configure CORS/security
  - [ ] 6.8 Verify all tests pass

- [ ] 7. Update Database Schema and Security Rules
  - [ ] 7.1 Write tests for database operations
  - [ ] 7.2 Create flutterwave_transactions Firestore collection structure
  - [ ] 7.3 Add paymentProvider and flutterwaveTransactionId fields to orders collection
  - [ ] 7.4 Update Firestore security rules for flutterwave_transactions
  - [ ] 7.5 Create necessary Firestore indexes for optimal queries
  - [ ] 7.6 Test database operations and security rules
  - [ ] 7.7 Verify all tests pass

- [ ] 8. Integration Testing and Final Verification
  - [ ] 8.1 Write end-to-end integration tests
  - [ ] 8.2 Test complete payment flow from selection to completion
  - [ ] 8.3 Verify real-time payment status updates work correctly
  - [ ] 8.4 Test error handling and edge cases
  - [ ] 8.5 Validate webhook processing and order updates
  - [ ] 8.6 Test both sandbox and production configurations
  - [ ] 8.7 Verify existing Paystack functionality remains unaffected
  - [ ] 8.8 Verify all tests pass and documentation is complete