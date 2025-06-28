String getAuthErrorMessage(String errorCode) {
  switch (errorCode) {
    case 'user-not-found':
      return 'No user found with this email address';
    case 'wrong-password':
      return 'Incorrect password';
    case 'user-disabled':
      return 'This user account has been disabled';
    case 'too-many-requests':
      return 'Too many failed attempts. Please try again later';
    case 'email-already-in-use':
      return 'An account already exists with this email address';
    case 'invalid-email':
      return 'Invalid email address';
    case 'operation-not-allowed':
      return 'Email/password accounts are not enabled';
    case 'weak-password':
      return 'Password is too weak';
    case 'network-request-failed':
      return 'Network error. Please check your connection';
    case 'requires-recent-login':
      return 'Please sign in again to perform this operation';
    case 'invalid-credential':
      return 'Invalid credentials provided';
    default:
      return 'Authentication error: $errorCode';
  }
}
