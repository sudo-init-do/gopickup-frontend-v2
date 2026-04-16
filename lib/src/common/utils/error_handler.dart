class ErrorHandler {
  static String getMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';
    
    String msg = error.toString().replaceAll('Exception: ', '').trim();
    
    // Auth Errors
    if (msg.toLowerCase().contains('invalid email or password') || 
        msg.toLowerCase().contains('unauthorized')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (msg.toLowerCase().contains('not verified')) {
      return 'Account not verified. Please check your email for OTP.';
    }
    if (msg.toLowerCase().contains('user already exists')) {
      return 'An account with this email already exists.';
    }
    if (msg.toLowerCase().contains('invalid otp')) {
      return 'Invalid OTP code. Please check and try again.';
    }
    
    // Network Errors
    if (msg.toLowerCase().contains('connection refused') || 
        msg.toLowerCase().contains('xmlhttprequest') ||
        msg.toLowerCase().contains('socketexception') ||
        msg.toLowerCase().contains('network_error') ||
        msg.toLowerCase().contains('connection timeout')) {
      return 'Network issue, please check your internet connection.';
    }
    
    if (msg.toLowerCase().contains('limited to 1 product')) {
      return 'Each vendor is limited to 1 product for now. Please upgrade your plan for more.';
    }
    
    // Generic Errors
    if (msg.toLowerCase().contains('internal server error') || 
        msg.toLowerCase().contains('500')) {
      return 'Server error, please try again later.';
    }
    
    return msg.isEmpty ? 'Something went wrong' : msg;
  }
}
