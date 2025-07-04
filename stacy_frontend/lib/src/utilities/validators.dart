String? passwordValidator(String? pwd, [String? confirmPwd]) {
  // Check if the password is at least 8 characters long
  if (pwd == null || pwd.length < 8) {
    return 'Password must be at least 8 characters long';
  }

  // Check if the password contains at least one uppercase letter
  if (!RegExp(r'[A-Z]').hasMatch(pwd)) {
    return 'Password must contain at least one uppercase letter';
  }

  // Check if the password contains at least one lowercase letter
  if (!RegExp(r'[a-z]').hasMatch(pwd)) {
    return 'Password must contain at least one lowercase letter';
  }

  // Check if the password contains at least one digit
  if (!RegExp(r'[0-9]').hasMatch(pwd)) {
    return 'Password must contain at least one digit';
  }

  if (confirmPwd != null && confirmPwd != pwd) {
    return 'Passwords do not match';
  }

  return null;
}

String? emailValidator(String? email) {
  // Regular expression for validating an Email
  String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  RegExp regex = RegExp(pattern);
  return email != null && regex.hasMatch(email)
      ? null
      : 'Please enter a valid email address';
}
