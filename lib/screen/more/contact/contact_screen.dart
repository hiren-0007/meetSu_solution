import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/more/contact/contact_controller.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

import '../../../services/pref/shared_prefs_service.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final ContactController _controller = ContactController();

  @override
  void initState() {
    super.initState();
    _controller.initListeners();
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

            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(AppTheme.screenPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back arrow on the left
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),

                        // Title in the center
                        const Text(
                          "Contact Us", // Replace with your screen title
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        // Username in pill container on the right
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            SharedPrefsService.instance.getUsername() ?? "User",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Logo
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: AppTheme.appIconDecoration,
                      child: const Icon(
                        Icons.contact_support,
                        color: AppTheme.primaryColor,
                        size: 40,
                      ),
                    ),
                  ),

                  SizedBox(height: AppTheme.largeSpacing),

                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(
                        horizontal: AppTheme.screenPadding,
                      ),
                      padding: EdgeInsets.all(AppTheme.cardPadding),
                      decoration: AppTheme.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Get in Touch",
                            style: AppTheme.headerStyle,
                          ),
                          SizedBox(height: AppTheme.smallSpacing),
                          Text(
                            "We'd love to hear from you",
                            style: AppTheme.subHeaderStyle,
                          ),
                          SizedBox(height: AppTheme.largeSpacing),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Subject",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: AppTheme.smallSpacing),
                                  TextField(
                                    controller: _controller.subjectController,
                                    style: AppTheme.inputTextStyle,
                                    decoration: AppTheme.getInputDecoration(
                                        labelText: "Enter Your Subject",
                                        prefixIcon: Icons.subject),
                                  ),
                                  SizedBox(height: AppTheme.contentSpacing),
                                  const Text(
                                    "Query",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: AppTheme.smallSpacing),
                                  TextField(
                                    controller: _controller.queryController,
                                    style: AppTheme.inputTextStyle,
                                    decoration: AppTheme.getInputDecoration(
                                      labelText: "Enter Your Query",
                                      prefixIcon: Icons.query_builder,
                                    ),
                                    maxLines: 5,
                                  ),
                                  SizedBox(height: AppTheme.contentSpacing),
                                  ValueListenableBuilder<String?>(
                                    valueListenable: _controller.errorMessage,
                                    builder: (context, errorMessage, _) {
                                      return errorMessage != null
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10),
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
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ValueListenableBuilder<bool>(
                                      valueListenable: _controller.isLoading,
                                      builder: (context, isLoading, _) {
                                        return ElevatedButton(
                                          onPressed: isLoading
                                              ? null
                                              : () => _controller
                                                  .submitForm(context),
                                          style: AppTheme.primaryButtonStyle,
                                          child: isLoading
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Text(
                                                  "Submit",
                                                  style:
                                                      AppTheme.buttonTextStyle,
                                                ),
                                        );
                                      },
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
                  SizedBox(height: AppTheme.largeSpacing),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
