# Auth Flow Fix Tasks

## Problem Summary
The authentication flow has a critical flaw in `UserDataSource.getCurrentUser()` method where it returns a mock user with `firstTimeLogin: true` when `firebase.currentUser` is null, causing unauthenticated users to bypass login and go directly to home/onboarding screens.

## Tasks

### 1. Fix UserDataSource getCurrentUser Method
**Priority: HIGH**
**Files to modify:** `/lib/food/features/auth/data/remote/data_sources/user_data_source.dart`

- [ ] 1.1 **Write comprehensive tests for UserDataSource getCurrentUser scenarios**
  - [ ] Test case: When firebase.currentUser is null (unauthenticated)
  - [ ] Test case: When firebase.currentUser exists but email not verified
  - [ ] Test case: When firebase.currentUser exists and email is verified
  - [ ] Test case: When firebase service throws exceptions
  - [ ] Create test file: `/test/features/auth/data/remote/data_sources/user_data_source_test.dart`

- [ ] 1.2 **Update getCurrentUser method to properly handle unauthenticated users**
  - [ ] Remove lines 18-39 that return mock UserProfileEntity when firebase.currentUser is null
  - [ ] Throw appropriate exception (e.g., `UserNotAuthenticatedException`) when firebase.currentUser is null
  - [ ] Ensure method only returns valid UserProfileEntity for authenticated users
  - [ ] Add proper null checks and exception handling

- [ ] 1.3 **Create custom exception for unauthenticated state**
  - [ ] Add `UserNotAuthenticatedException` to `/lib/food/features/auth/data/custom_exceptions/custom_exceptions.dart`
  - [ ] Update exception handling in auth repository layer
  - [ ] Update failure mapping in `/lib/food/features/auth/data/repositories/auth_repo_impl.dart`

- [ ] 1.4 **Verify UserDataSource tests pass**
  - [ ] Run `flutter test test/features/auth/data/remote/data_sources/user_data_source_test.dart`
  - [ ] Fix any failing tests
  - [ ] Ensure 100% coverage for getCurrentUser method

### 2. Update SplashScreen Authentication Logic
**Priority: HIGH**
**Files to modify:** `/lib/food/features/onboarding/presentation/screens/splash_screen.dart`

- [ ] 2.1 **Write tests for SplashScreen authentication flow**
  - [ ] Test case: Unauthenticated user should navigate to login
  - [ ] Test case: Authenticated unverified user should navigate to email verification
  - [ ] Test case: Authenticated verified user should navigate to home
  - [ ] Test case: Handle authentication errors gracefully
  - [ ] Create test file: `/test/features/onboarding/presentation/screens/splash_screen_test.dart`

- [ ] 2.2 **Update checkLoggedIn method to handle UserNotAuthenticatedException**
  - [ ] Add try-catch block to handle UserNotAuthenticatedException
  - [ ] When exception is caught, navigate to login screen instead of onboarding
  - [ ] Remove any fallback logic that assumes user is authenticated
  - [ ] Add proper loading states and error handling

- [ ] 2.3 **Implement proper navigation logic**
  - [ ] Unauthenticated users → Navigate to `/login`
  - [ ] Authenticated but unverified users → Navigate to `/email-verification`
  - [ ] Authenticated and verified users → Navigate to `/home`
  - [ ] Add transition animations and loading indicators

- [ ] 2.4 **Verify SplashScreen tests pass**
  - [ ] Run `flutter test test/features/onboarding/presentation/screens/splash_screen_test.dart`
  - [ ] Test navigation flows manually
  - [ ] Verify loading states work correctly

### 3. Update Authentication Repository and UseCase
**Priority: MEDIUM**
**Files to modify:** 
- `/lib/food/features/auth/data/repositories/auth_repo_impl.dart`
- `/lib/food/features/auth/domain/use_cases/auth_usecase.dart`

- [ ] 3.1 **Write tests for auth repository getCurrentUser method**
  - [ ] Test handling of UserNotAuthenticatedException from data source
  - [ ] Test proper failure mapping
  - [ ] Test successful user retrieval
  - [ ] Create test file: `/test/features/auth/data/repositories/auth_repo_impl_test.dart`

- [ ] 3.2 **Update auth repository to handle new exception**
  - [ ] Map UserNotAuthenticatedException to appropriate Failure
  - [ ] Ensure Either<Failure, UserProfileEntity> properly handles unauthenticated state
  - [ ] Add proper error logging

- [ ] 3.3 **Update auth usecase getCurrentUser method**
  - [ ] Ensure usecase properly handles repository failures
  - [ ] Add appropriate error handling and logging
  - [ ] Update method documentation

- [ ] 3.4 **Verify repository and usecase tests pass**
  - [ ] Run auth repository tests
  - [ ] Run auth usecase tests
  - [ ] Verify integration between layers

### 4. Add Route Guards and State Management
**Priority: MEDIUM**
**Files to modify:**
- `/lib/food/core/routes/routes.dart`
- `/lib/food/core/routes/getx_route_module.dart`

- [ ] 4.1 **Create authentication guard middleware**
  - [ ] Create `AuthGuard` class to protect authenticated routes
  - [ ] Add authentication state checking logic
  - [ ] Implement automatic redirection for unauthenticated users

- [ ] 4.2 **Update route definitions with authentication guards**
  - [ ] Add AuthGuard to protected routes (home, profile, orders, etc.)
  - [ ] Ensure login/signup routes are accessible without authentication
  - [ ] Add proper route transition handling

- [ ] 4.3 **Test route guard functionality**
  - [ ] Test accessing protected routes without authentication
  - [ ] Test proper redirects to login screen
  - [ ] Test authenticated user access to protected routes

### 5. Update Authentication BLoCs and State Management
**Priority: MEDIUM**
**Files to modify:**
- `/lib/food/features/auth/presentation/manager/auth_bloc/login/login_bloc.dart`
- `/lib/food/core/bloc/app_state.dart`

- [ ] 5.1 **Write tests for authentication state management**
  - [ ] Test login success updates app authentication state
  - [ ] Test logout clears authentication state
  - [ ] Test app state persistence across app restarts

- [ ] 5.2 **Update app state to properly track authentication**
  - [ ] Add isAuthenticated flag to AppState
  - [ ] Update state when login/logout events occur
  - [ ] Ensure state persistence works correctly

- [ ] 5.3 **Update login/logout BLoCs**
  - [ ] Ensure login success updates global app state
  - [ ] Ensure logout clears all user data and state
  - [ ] Add proper error handling and user feedback

- [ ] 5.4 **Verify authentication state management**
  - [ ] Test app state updates correctly
  - [ ] Test state persistence
  - [ ] Test BLoC integration with UI

### 6. Comprehensive Testing and Validation
**Priority: HIGH**

- [ ] 6.1 **End-to-end authentication flow testing**
  - [ ] Test complete unauthenticated user journey (splash → login → home)
  - [ ] Test authenticated user journey (splash → home directly)
  - [ ] Test email verification flow
  - [ ] Test logout and re-authentication

- [ ] 6.2 **Edge case testing**
  - [ ] Test app behavior when Firebase is offline
  - [ ] Test app behavior with corrupted user data
  - [ ] Test app behavior during network interruptions
  - [ ] Test memory and performance impact

- [ ] 6.3 **Code quality and analysis**
  - [ ] Run `flutter analyze` on all modified auth-related files
  - [ ] Fix any analyzer warnings or errors
  - [ ] Ensure code follows existing project patterns
  - [ ] Update documentation comments where needed

- [ ] 6.4 **Manual testing checklist**
  - [ ] Fresh app install → should go to login
  - [ ] Login with valid credentials → should go to home
  - [ ] Login with unverified email → should go to verification
  - [ ] Logout → should go to login
  - [ ] App restart while authenticated → should go to home
  - [ ] App restart while unauthenticated → should go to login

### 7. Documentation and Cleanup
**Priority: LOW**

- [ ] 7.1 **Update authentication flow documentation**
  - [ ] Document the fixed authentication flow
  - [ ] Update any existing auth-related comments
  - [ ] Add inline documentation for complex logic

- [ ] 7.2 **Code cleanup**
  - [ ] Remove any unused imports
  - [ ] Remove commented-out code
  - [ ] Ensure consistent code formatting
  - [ ] Remove debug print statements

- [ ] 7.3 **Final verification**
  - [ ] Run full test suite: `flutter test`
  - [ ] Run `flutter analyze` on entire codebase
  - [ ] Verify app builds successfully for all platforms
  - [ ] Test app performance and memory usage

## Definition of Done

- [ ] All authentication flows work as expected (unauthenticated → login, authenticated → home)
- [ ] No mock users are returned for unauthenticated state
- [ ] All new code is covered by unit tests
- [ ] All existing tests continue to pass
- [ ] `flutter analyze` passes with no errors or warnings on modified files
- [ ] Manual testing confirms proper authentication behavior
- [ ] Code follows existing project architecture and patterns

## Notes

- **Critical**: The mock user fallback in `UserDataSource.getCurrentUser()` must be completely removed
- **Testing**: Focus heavily on testing the authentication state transitions
- **Backward Compatibility**: Ensure existing authenticated users are not affected
- **Error Handling**: Provide clear user feedback for all authentication errors
- **Performance**: Minimize authentication checks to avoid UI blocking