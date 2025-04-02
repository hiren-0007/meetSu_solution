import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/auth/login/login_controller.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  // Use the controller
  final LoginController _controller = LoginController();

  @override
  void dispose() {
    // Dispose controller resources
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidget(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Stack(
          children: [
            // Top design
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: AppTheme.headerContainerDecoration,
              ),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Logo and app name
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: AppTheme.appIconDecoration,
                              child:Image.asset('assets/images/logo.png',height: 50,width: 50,),
                            ),
                            SizedBox(height: AppTheme.smallSpacing),
                            const Text(
                              "MEETsu Solutions",
                              style: AppTheme.appNameStyle,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppTheme.largeSpacing + 10),

                      // Login card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(AppTheme.cardPadding),
                        decoration: AppTheme.cardDecoration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome text
                            const Text(
                              "Welcome Back",
                              style: AppTheme.headerStyle,
                            ),
                            SizedBox(height: AppTheme.smallSpacing),
                            Text(
                              "Sign in to continue",
                              style: AppTheme.subHeaderStyle,
                            ),

                            SizedBox(height: AppTheme.largeSpacing),

                            // Email field
                            TextField(
                              controller: _controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: AppTheme.inputTextStyle,
                              decoration: AppTheme.getInputDecoration(
                                labelText: "User Name",
                                prefixIcon: Icons.person,
                              ),
                            ),

                            SizedBox(height: AppTheme.contentSpacing),

                            // Password field
                            ValueListenableBuilder<bool>(
                              valueListenable: _controller.obscureText,
                              builder: (context, obscureText, _) {
                                return TextField(
                                  controller: _controller.passwordController,
                                  obscureText: obscureText,
                                  style: AppTheme.inputTextStyle,
                                  decoration: AppTheme.getInputDecoration(
                                    labelText: "Password",
                                    prefixIcon: Icons.lock_outline_rounded,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscureText
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: AppTheme.textSecondaryColor,
                                        size: 22,
                                      ),
                                      onPressed:
                                          _controller.togglePasswordVisibility,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Error message (if any)
                            ValueListenableBuilder<String?>(
                              valueListenable: _controller.errorMessage,
                              builder: (context, errorMessage, _) {
                                return errorMessage != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          errorMessage,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              },
                            ),

                            SizedBox(height: AppTheme.largeSpacing - 10),

                            // Login Button
                            ValueListenableBuilder<bool>(
                              valueListenable: _controller.isLoading,
                              builder: (context, isLoading, _) {
                                return ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () async {
                                              await _controller.login(context);
                                          // if (success && mounted) {
                                          //   // Navigate to home screen or main app
                                          //   // Navigator.pushReplacementNamed(context, '/home');
                                          //   ScaffoldMessenger.of(context)
                                          //       .showSnackBar(
                                          //     const SnackBar(
                                          //       content: Text(
                                          //           'Login successful! Navigating...'),
                                          //       backgroundColor: Colors.green,
                                          //     ),
                                          //   );
                                          // }
                                        },
                                  style: AppTheme.primaryButtonStyle,
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          "LOGIN",
                                          style: AppTheme.buttonTextStyle,
                                        ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppTheme.largeSpacing - 10),

                      // Don't have an account
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: AppTheme.smallTextStyle,
                            ),
                            TextButton(
                              onPressed: () =>
                                  _controller.navigateToSignup(context),
                              child: const Text(
                                "Sign Up",
                                style: AppTheme.linkTextStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
