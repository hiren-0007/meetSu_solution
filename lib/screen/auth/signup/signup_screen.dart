import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/auth/signup/signup_controller.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  // Use the controller
  final SignupController _controller = SignupController();

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
                              child:Image.asset('assets/images/logo.png',height: 50,width: 50,)
                            ),
                            SizedBox(height: AppTheme.smallSpacing),
                            const Text(
                              "MEETsu SOLUTIONS",
                              style: AppTheme.appNameStyle,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppTheme.largeSpacing),

                      // Signup card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(AppTheme.cardPadding),
                        decoration: AppTheme.cardDecoration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Create Account text
                            const Text(
                              "Create Account",
                              style: AppTheme.headerStyle,
                            ),
                            SizedBox(height: AppTheme.smallSpacing),
                            Text(
                              "Sign up to get started",
                              style: AppTheme.subHeaderStyle,
                            ),

                            SizedBox(height: AppTheme.largeSpacing),

                            // First Name field
                            TextField(
                              controller: _controller.firstNameController,
                              textCapitalization: TextCapitalization.words,
                              style: AppTheme.inputTextStyle,
                              decoration: AppTheme.getInputDecoration(
                                labelText: "First Name",
                                prefixIcon: Icons.person_outline,
                              ),
                            ),

                            SizedBox(height: AppTheme.contentSpacing),

                            // Last Name field
                            TextField(
                              controller: _controller.lastNameController,
                              textCapitalization: TextCapitalization.words,
                              style: AppTheme.inputTextStyle,
                              decoration: AppTheme.getInputDecoration(
                                labelText: "Last Name",
                                prefixIcon: Icons.person_outline,
                              ),
                            ),

                            SizedBox(height: AppTheme.contentSpacing),

                            // Username field
                            TextField(
                              controller: _controller.usernameController,
                              keyboardType: TextInputType.emailAddress,
                              style: AppTheme.inputTextStyle,
                              decoration: AppTheme.getInputDecoration(
                                labelText: "Username",
                                prefixIcon: Icons.alternate_email,
                              ),
                            ),

                            SizedBox(height: AppTheme.contentSpacing),

                            // Password field
                            ValueListenableBuilder<bool>(
                              valueListenable: _controller.obscurePassword,
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
                                      onPressed: _controller.togglePasswordVisibility,
                                    ),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: AppTheme.contentSpacing),

                            // Confirm Password field
                            ValueListenableBuilder<bool>(
                              valueListenable: _controller.obscureConfirmPassword,
                              builder: (context, obscureText, _) {
                                return TextField(
                                  controller: _controller.confirmPasswordController,
                                  obscureText: obscureText,
                                  style: AppTheme.inputTextStyle,
                                  decoration: AppTheme.getInputDecoration(
                                    labelText: "Confirm Password",
                                    prefixIcon: Icons.lock_outline_rounded,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscureText
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: AppTheme.textSecondaryColor,
                                        size: 22,
                                      ),
                                      onPressed: _controller.toggleConfirmPasswordVisibility,
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

                            // Signup Button
                            ValueListenableBuilder<bool>(
                              valueListenable: _controller.isLoading,
                              builder: (context, isLoading, _) {
                                return ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () async {
                                    final success = await _controller.signup();
                                    if (success && mounted) {
                                      // Navigate to success or login screen
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Account created successfully!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      // Navigate to login screen after successful signup
                                      Future.delayed(const Duration(seconds: 1), () {
                                        if (mounted) {
                                          Navigator.pop(context);
                                        }
                                      });
                                    }
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
                                    "SIGN UP",
                                    style: AppTheme.buttonTextStyle,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppTheme.contentSpacing),

                      // Already have an account
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: AppTheme.smallTextStyle,
                            ),
                            TextButton(
                              onPressed: () => _controller.navigateToLogin(context),
                              child: const Text(
                                "Login",
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