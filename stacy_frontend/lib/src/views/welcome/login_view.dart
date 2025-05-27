import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:stacy_frontend/src/services/logger.dart';
import 'package:stacy_frontend/src/utilities/manager/api_manager.dart';
import 'package:stacy_frontend/src/utilities/manager/storage_manager.dart';
import 'package:stacy_frontend/src/utilities/validators.dart';
import 'package:stacy_frontend/src/views/home_view.dart';
import 'package:stacy_frontend/src/views/welcome/signup_view.dart';
import 'package:stacy_frontend/src/widgets/social_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  static const String routeName = '/login';

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Logging in with Email: ${_emailController.text}, Password: ${_passwordController.text}'),
          backgroundColor: Colors.teal,
        ),
      );
      String hashedPassword = hashPassword(_passwordController.text);
      ApiManager.loginUser(_emailController.text, hashedPassword)
          .then((response) {
        if (response['uid'] != null) {
          log.info('UID: ${response['uid']}');

          StorageManager()
              .setString('uid', response['uid'].toString())
              .then((_) {
            log.info('User logged in successfully, navigating to HomeView');
            if (mounted) {
              GoRouter.of(context).go(HomeView.routeName);
            }
          }).catchError((error) {
            log.severe('Error storing uid: $error');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error storing uid'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
        } else {
          log.warning('UID not found in response');
        }
      });
    }
  }

  void _loginWithGoogle() {
    log.info('Login with Google pressed');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logging in with Google...'),
        backgroundColor: Colors.blueAccent,
      ),
    );
    // TODO: Implement Google Sign-In logic
  }

  void _loginWithApple() {
    log.info('Login with Apple pressed');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logging in with Apple...'),
        backgroundColor: Colors.black,
      ),
    );
    // TODO: Implement Apple Sign-In logic
  }

  void _loginWithFacebook() {
    log.info('Login with Facebook pressed');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logging in with Facebook...'),
        backgroundColor: Colors.blue.shade700,
      ),
    );
    // TODO: Implement Facebook Sign-In logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.teal.shade700),
          onPressed: () {
            GoRouter.of(context).go(HomeView.routeName);
          },
        ),
        title: Text(
          'Log In',
          style: TextStyle(
            color: Colors.teal.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Log in to continue monitoring your plants.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Email Input
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email, color: Colors.teal.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.teal.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.teal.shade300, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.teal.shade600, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.teal.shade50.withAlpha(128),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Input
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock, color: Colors.teal.shade400),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.teal.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.teal.shade300, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.teal.shade600, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.teal.shade50.withAlpha(128),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to Forgot Password Screen
                      log.info('Forgot Password pressed');
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.teal.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30), // Space before separator

                // Or Separator
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Or Log In With',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                  ],
                ),
                const SizedBox(height: 30), // Space after separator

                // Social Login Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Google Button
                    SocialButton(
                      icon: FontAwesomeIcons.google,
                      color: Colors.blue.shade600,
                      onPressed: _loginWithGoogle,
                    ),
                    // Apple Button
                    SocialButton(
                      icon: Icons.apple, // Use built-in Apple icon
                      color: Colors.black,
                      onPressed: _loginWithApple,
                    ),
                    // Facebook Button
                    SocialButton(
                      icon: FontAwesomeIcons.facebookF,
                      color: Colors.blue.shade800,
                      onPressed: _loginWithFacebook,
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Don't have an account? Sign Up button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    TextButton(
                      onPressed: () {
                        log.info('Sign Up link pressed');
                        GoRouter.of(context).go(SignUpView.routeName);
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.teal.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
