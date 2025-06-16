import 'package:flutter/material.dart';
import 'package:meetsu_solutions/clint/c_screen/c_more/clint_more_controller.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class ClintMoreScreen extends StatefulWidget {
  const ClintMoreScreen({super.key});

  @override
  State<ClintMoreScreen> createState() => _ClintMoreScreenState();
}

class _ClintMoreScreenState extends State<ClintMoreScreen> {
  final ClintMoreController _controller = ClintMoreController();
  bool _showAnalyticsOptions = false;

  @override
  void initState() {
    super.initState();
    _controller.fetchDashboardData();
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
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.25,
                decoration: AppTheme.headerClintContainerDecoration,
              ),
            ),
            SafeArea(
              child: RefreshIndicator(
                onRefresh: _controller.fetchDashboardData,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              const Text(
                                "MEETsu Solutions",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 30),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryClintColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      SharedPrefsService.instance.getUsername().isNotEmpty
                                          ? SharedPrefsService.instance.getUsername()[0].toUpperCase()
                                          : "U",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryClintColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        SharedPrefsService.instance.getUsername().isNotEmpty
                                            ? SharedPrefsService.instance.getUsername()
                                            : "User",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Client",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Text(
                                    "Active",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.only(top: 20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.05),
                              blurRadius: 10,
                              offset: Offset(0, -3),
                            ),
                          ],
                        ),
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _controller.isLoading,
                          builder: (context, isLoading, child) {
                            if (isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            return ValueListenableBuilder<String?>(
                              valueListenable: _controller.errorMessage,
                              builder: (context, errorMessage, child) {
                                if (errorMessage != null) {
                                  return _buildErrorView(errorMessage);
                                }

                                return ListView(
                                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                                  children: [
                                    _buildAnalyticsMenuOption(context),

                                    if (_showAnalyticsOptions)
                                      _buildAnalyticsSubOptions(context),

                                    _buildMenuOption(
                                      context: context,
                                      icon: Icons.person_outline,
                                      title: "Profile",
                                      route: "/clint-profile",
                                    ),

                                    _buildMenuOption(
                                      context: context,
                                      icon: Icons.logout,
                                      title: "Log Out",
                                      route: "/logout",
                                      isLogout: true,
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsMenuOption(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryClintColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryClintColor.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        onTap: () {
          setState(() {
            _showAnalyticsOptions = !_showAnalyticsOptions;
          });
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryClintColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.analytics_outlined,
            color: AppTheme.primaryClintColor,
            size: 24,
          ),
        ),
        title: Text(
          "Analytics",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          _showAnalyticsOptions ? Icons.keyboard_arrow_up : Icons.arrow_forward_ios,
          size: 20,
          color: AppTheme.primaryClintColor.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildAnalyticsSubOptions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 32, right: 16),
      child: Column(
        children: [
          _buildSubOption(
            context: context,
            icon: Icons.calendar_today_outlined,
            title: "Daily",
            route: "/analytics/daily",
          ),
          _buildSubOption(
            context: context,
            icon: Icons.date_range_outlined,
            title: "Weekly",
            route: "/analytics/weekly",
          ),
        ],
      ),
    );
  }

  Widget _buildSubOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.primaryClintColor.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        onTap: () {
          _controller.navigateTo(context, route);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          icon,
          color: AppTheme.primaryClintColor,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: AppTheme.primaryClintColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    bool isLogout = false,
  }) {
    final Color textColor = isLogout ? Colors.red : Colors.black87;
    final Color iconColor = isLogout ? Colors.red : AppTheme.primaryClintColor;
    final Color backgroundColor = isLogout
        ? Colors.red.withValues(alpha: 0.1)
        : AppTheme.primaryClintColor.withValues(alpha: 0.05);
    final Color borderColor = isLogout
        ? Colors.red.withValues(alpha: 0.3)
        : AppTheme.primaryClintColor.withValues(alpha: 0.2);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: ListTile(
        onTap: () {
          if (isLogout) {
            _controller.handleLogout(context);
          } else {
            _controller.navigateTo(context, route);
          }
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isLogout
                ? Colors.red.withValues(alpha: 0.2)
                : AppTheme.primaryClintColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: iconColor.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _controller.fetchDashboardData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryClintColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}