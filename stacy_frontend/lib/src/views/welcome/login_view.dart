import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:stacy_frontend/src/services/logger.dart';
import 'package:stacy_frontend/src/utilities/constants.dart';
import 'package:stacy_frontend/src/utilities/manager/api_manager.dart';
import 'package:stacy_frontend/src/utilities/manager/storage_manager.dart';
import 'package:stacy_frontend/src/views/home_view.dart';
import 'package:stacy_frontend/src/views/welcome/signup_view.dart';
import 'package:stacy_frontend/src/widgets/home/home_input_field.dart';
import 'package:stacy_frontend/src/widgets/lottie_animation.dart';
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

  final bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      ApiManager.loginUser(_emailController.text, _passwordController.text)
          .then((response) {
        if (response['uid'] != null) {
          log.info('UID: ${response['uid']}');

          StorageManager()
              .setString('uid', response['uid'].toString())
              .then((_) {
            log.info('User logged in successfully, navigating to Home View');
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
      }).catchError((error) {
        log.severe('Login failed: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString().substring(11)),
              backgroundColor: Colors.red,
            ),
          );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 150.0, vertical: 10.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LottieAnimation(
                assetPath: 'assets/lotties/1751142016712.json',
                height: 200,
                repeat: true,
              ),
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Log in to continue monitoring your plants.',
                style: TextStyle(
                  fontSize: 16,
                  color: textGreyColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              HomeInputField(
                label: 'Email',
                hint: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(Icons.email, color: primaryColor),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              HomeInputField(
                label: 'Password',
                hint: 'Enter your password',
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                prefixIcon: Icon(Icons.lock, color: primaryColor),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                obscureText: !_isPasswordVisible,
                onFieldSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Navigate to Forgot Password Screen
                    log.info('Forgot Password pressed');
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    foregroundColor: textSecondaryColor,
                    overlayColor: textSecondaryColor,
                  ),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: textSecondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
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

              Container(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    log.info('Sign Up link pressed');
                    GoRouter.of(context).go(SignUpView.routeName);
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    foregroundColor: textSecondaryColor,
                    overlayColor: textSecondaryColor,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: textSecondaryColor,
                        ),
                      ),
                      Text(
                        "Sign Up",
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
