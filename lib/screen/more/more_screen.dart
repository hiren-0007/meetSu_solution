import 'package:flutter/material.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/screen/more/more_controller.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final MoreController _controller = MoreController();

  @override
  void initState() {
    super.initState();
    // Call the API when the screen initializes
    _controller.fetchCheckInButtonStatus();
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
            Positioned(
              top: 8,
              left: 7,
              right: 7,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: AppTheme.headerContainerDecoration,
              ),
            ),

            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Padding(
                    padding: EdgeInsets.all(AppTheme.screenPadding),
                    child: const Center(
                      child: Text(
                        "More",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // App Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: AppTheme.appIconDecoration,
                      child: const Icon(
                        Icons.menu,
                        color: AppTheme.primaryColor,
                        size: 40,
                      ),
                    ),
                  ),

                  SizedBox(height: AppTheme.largeSpacing),

                  // Status of CheckIn Button and Error Messages
                  ValueListenableBuilder<bool>(
                    valueListenable: _controller.isLoading,
                    builder: (context, isLoading, child) {
                      if (isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Error message
                  ValueListenableBuilder<String?>(
                    valueListenable: _controller.errorMessage,
                    builder: (context, errorMsg, child) {
                      if (errorMsg != null && errorMsg.isNotEmpty) {
                        // Only show unauthorized errors in debug console, not to user
                        if (errorMsg.contains('Unauthorized')) {
                          debugPrint('Authorization error: $errorMsg');
                          return const SizedBox.shrink();
                        }

                        // Show other errors to the user
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            errorMsg,
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Menu Card
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(
                        horizontal: AppTheme.screenPadding,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      decoration: AppTheme.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Menu Items
                          Expanded(
                            child: ValueListenableBuilder<List<MenuItem>>(
                              valueListenable: _controller.menuItemsNotifier,
                              builder: (context, menuItems, child) {
                                return ListView.separated(
                                  itemCount: menuItems.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final menuItem = menuItems[index];
                                    return ListTile(
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: menuItem.iconColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          menuItem.icon,
                                          color: menuItem.iconColor,
                                          size: 24,
                                        ),
                                      ),
                                      title: Text(
                                        menuItem.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      onTap: () => _controller.navigateTo(context, menuItem.route),
                                    );
                                  },
                                );
                              },
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