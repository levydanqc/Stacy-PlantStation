import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:stacy_frontend/src/services/logger.dart';
import 'package:stacy_frontend/src/utilities/constants.dart';
import 'package:stacy_frontend/src/utilities/manager/storage_manager.dart';
import 'package:stacy_frontend/src/utilities/validators.dart';
import 'package:stacy_frontend/src/views/home_view.dart';
import 'package:stacy_frontend/src/views/welcome/login_view.dart';
import 'package:stacy_frontend/src/widgets/home/home_input_field.dart';
import 'package:stacy_frontend/src/widgets/lottie_animation.dart';
import 'package:stacy_frontend/src/widgets/social_button.dart';
import 'package:stacy_frontend/src/utilities/manager/api_manager.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  static const String routeName = '/signup';

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Signing up with Email: ${_emailController.text}, Password: ${_passwordController.text}'),
          backgroundColor: Colors.teal,
        ),
      );

      ApiManager.signUp(_emailController.text, _passwordController.text)
          .then((response) {
        log.info('User created successfully: ${response['userId']}');

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User created successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          StorageManager().setString('uid', response['uid'].toString());

          GoRouter.of(context).go(HomeView.routeName);
        }
      }).catchError((error) {
        log.severe('Error creating user: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating user: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  void _signUpWithGoogle() {
    log.info('Sign Up with Google pressed');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signing up with Google...'),
        backgroundColor: Colors.blueAccent,
      ),
    );
    // TODO: Implement Google Sign-In/Sign-Up logic
  }

  void _signUpWithApple() {
    log.info('Sign Up with Apple pressed');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signing up with Apple...'),
        backgroundColor: Colors.black,
      ),
    );
    // TODO: Implement Apple Sign-In/Sign-Up logic
  }

  void _signUpWithFacebook() {
    log.info('Sign Up with Facebook pressed');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Signing up with Facebook...'),
        backgroundColor: Colors.blue.shade700,
      ),
    );
    // TODO: Implement Facebook Sign-In/Sign-Up logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 150.0, vertical: 10.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LottieAnimation(
                  assetPath: 'assets/lotties/1751322622263.json',
                  height: 200,
                  repeat: true,
                ),
                Text(
                  'Join Stacy today!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Create your account to get started with Stacy',
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
                  validator: (value) => emailValidator(value),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                HomeInputField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  prefixIcon: Icon(Icons.lock, color: Colors.teal.shade400),
                  suffixIcon: ExcludeFocus(
                    child: IconButton(
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
                  ),
                  validator: (value) => passwordValidator(value),
                  textInputAction: TextInputAction.next,
                  obscureText: !_isPasswordVisible,
                ),
                const SizedBox(height: 20),
                HomeInputField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  controller: _confirmPasswordController,
                  keyboardType: TextInputType.visiblePassword,
                  prefixIcon:
                      Icon(Icons.lock_reset, color: Colors.teal.shade400),
                  suffixIcon: ExcludeFocus(
                    child: IconButton(
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
                  ),
                  validator: (value) => passwordValidator(
                    value,
                    _passwordController.text,
                  ),
                  textInputAction: TextInputAction.done,
                  obscureText: !_isPasswordVisible,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Or Sign Up With',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Google Button
                    SocialButton(
                      icon: FontAwesomeIcons.google,
                      color: Colors.blue.shade600,
                      onPressed: _signUpWithGoogle,
                    ),
                    // Apple Button
                    SocialButton(
                      icon: Icons.apple, // Use built-in Apple icon
                      color: Colors.black,
                      onPressed: _signUpWithApple,
                    ),
                    // Facebook Button
                    SocialButton(
                      icon: FontAwesomeIcons.facebookF,
                      color: Colors.blue.shade800,
                      onPressed: _signUpWithFacebook,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      log.info('Sign Up link pressed');
                      GoRouter.of(context).go(LoginView.routeName);
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
                          "Already have an account? ",
                          style: TextStyle(
                            color: textSecondaryColor,
                          ),
                        ),
                        Text(
                          "Log In",
                          style: TextStyle(
                            color: textSecondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
