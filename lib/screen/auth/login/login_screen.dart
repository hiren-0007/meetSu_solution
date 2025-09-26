import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/auth/login/login_controller.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
  }

  @override
  void dispose() {
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
            const _HeaderBackground(),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppTheme.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const _AppLogo(),
                    SizedBox(height: AppTheme.largeSpacing + 10),
                    _LoginForm(controller: _controller),
                    SizedBox(height: AppTheme.largeSpacing - 10),
                    // _SignupPrompt(controller: _controller),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.35,
        decoration: AppTheme.headerContainerDecoration,
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: AppTheme.appIconDecoration,
            child: Image.asset(
              'assets/images/logo.png',
              height: 50,
              width: 50,
            ),
          ),
          SizedBox(height: AppTheme.smallSpacing),
          const Text(
            "MEETsu Solutions",
            style: AppTheme.appNameStyle,
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.cardPadding),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          _UsernameField(controller: controller),
          SizedBox(height: AppTheme.contentSpacing),
          _PasswordField(controller: controller),
          _ErrorMessage(controller: controller),
          SizedBox(height: AppTheme.largeSpacing - 10),
          _LoginButton(controller: controller),
        ],
      ),
    );
  }
}

class _UsernameField extends StatelessWidget {
  const _UsernameField({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      style: AppTheme.inputTextStyle,
      decoration: AppTheme.getInputDecoration(
        labelText: "User Name",
        prefixIcon: Icons.person,
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.obscureText,
      builder: (context, obscureText, _) {
        return TextField(
          controller: controller.passwordController,
          obscureText: obscureText,
          style: AppTheme.inputTextStyle,
          decoration: AppTheme.getInputDecoration(
            labelText: "Password",
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.textSecondaryColor,
                size: 22,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
          ),
        );
      },
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: controller.errorMessage,
      builder: (context, errorMessage, _) {
        // Add debug print to check if error message is being set
        debugPrint('Error message in UI: $errorMessage');

        if (errorMessage == null || errorMessage.isEmpty) {
          return const SizedBox(
              height: 50); // Reserve space to prevent layout shifts
        }

        return Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            border: Border.all(color: Colors.red.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.isLoading,
      builder: (context, isLoading, _) {
        return ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  // Clear any previous errors before starting login
                  controller.errorMessage.value = null;

                  // Add small delay to ensure UI updates
                  await Future.delayed(const Duration(milliseconds: 100));

                  final success = await controller.login(context);
                  debugPrint('Login result: $success');
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
    );
  }
}
