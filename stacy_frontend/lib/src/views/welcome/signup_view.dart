import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:stacy_frontend/src/services/logger.dart';
import 'package:stacy_frontend/src/utilities/manager/storage_manager.dart';
import 'package:stacy_frontend/src/utilities/validators.dart';
import 'package:stacy_frontend/src/views/home_view.dart';
import 'package:stacy_frontend/src/views/welcome/login_view.dart';
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
  bool _isConfirmPasswordVisible = false;

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
          'Create Account',
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
                  'Join Stacy today!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
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
                  validator: (value) => emailValidator(value),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 20),

                // Password Input
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
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
                  validator: (value) => passwordValidator(value),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    prefixIcon:
                        Icon(Icons.lock_reset, color: Colors.teal.shade400),
                    suffixIcon: ExcludeFocus(
                      child: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
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
                  validator: (value) => passwordValidator(
                    value,
                    _passwordController.text,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    TextButton(
                      onPressed: () {
                        log.info('Login link pressed');
                        GoRouter.of(context).go(LoginView.routeName);
                      },
                      child: Text(
                        'Log In',
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
