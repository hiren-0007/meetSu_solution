import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/compliance/compliance_screen.dart';
import 'package:meetsu_solutions/screen/dashboard/dashboard_screen.dart';
import 'package:meetsu_solutions/screen/home/home_controller.dart';
import 'package:meetsu_solutions/screen/job/job_opening_screen.dart';
import 'package:meetsu_solutions/screen/more/more_screen.dart';
import 'package:meetsu_solutions/screen/schedule/schedule_screen.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final HomeController _controller = HomeController();

  // State Management Flags
  bool _isInitialized = false;
  bool _notificationHandled = false;
  String? _lastHandledNotificationType;

  @override
  void initState() {
    super.initState();
    debugPrint("🏠 HomeScreen initState called");

    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Handle initial notification after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialNotification();
    });

    _requestATTIfNeeded();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint("📱 App resumed - resetting notification flags");
        _resetNotificationFlags();
        break;
      case AppLifecycleState.paused:
        debugPrint("📱 App paused");
        break;
      case AppLifecycleState.detached:
        debugPrint("📱 App detached");
        break;
      case AppLifecycleState.inactive:
        debugPrint("📱 App inactive");
        break;
      case AppLifecycleState.hidden:
        debugPrint("📱 App hidden");
        break;
    }
  }

  Future<void> _requestATTIfNeeded() async {
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;

      debugPrint("📌 ATT status: $status");

      if (status == TrackingStatus.notDetermined) {
        // Apple requires visible UI before popup
        await Future.delayed(const Duration(milliseconds: 600));

        await AppTrackingTransparency.requestTrackingAuthorization();

        debugPrint("✅ ATT popup displayed");
      }
    } catch (e) {
      debugPrint("❌ ATT error: $e");
    }
  }

  void _handleInitialNotification() {
    if (_notificationHandled || !mounted) {
      debugPrint("🚫 Notification already handled or not mounted, skipping...");
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    debugPrint("📱 Initial arguments: $args");

    if (args != null && args is Map<String, dynamic>) {
      final notificationType = args['name'] as String?;

      if (notificationType != null &&
          _lastHandledNotificationType != notificationType) {
        _notificationHandled = true;
        _lastHandledNotificationType = notificationType;

        debugPrint("✅ Processing notification: $notificationType");

        // Add delay to ensure proper context
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _processNotification(notificationType);
          }
        });
      }
    }

    _isInitialized = true;
  }

  void _processNotification(String notificationType) {
    switch (notificationType) {
      case 'Quiz':
        debugPrint("📝 Processing Quiz notification");
        _controller.openNotifications(context, fromNotification: true);
        break;
      case 'Clock-In':
        debugPrint("⏰ Processing Clock-In notification");
        _controller.resetClockInFlags(); // Reset flags before showing
        _controller.showClockInDialog(context);
        break;
      default:
        debugPrint("❓ Unknown notification type: $notificationType");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitialized) {
      // Log current arguments for debugging
      final currentArgs = ModalRoute.of(context)?.settings.arguments;
      debugPrint("🔍 didChangeDependencies - Current args: $currentArgs");
    }
  }

  // Reset notification handling flags
  void _resetNotificationFlags() {
    setState(() {
      _notificationHandled = false;
      _lastHandledNotificationType = null;
    });
    debugPrint("🔄 Notification handling reset");
  }

  // Method to manually handle quiz (from Quiz button)
  void _handleManualQuiz() {
    debugPrint("🎯 Manual quiz button pressed");
    _controller.resetQuizFlags();
    _controller.openNotifications(context, fromNotification: false);
  }

  @override
  void dispose() {
    debugPrint("🗑️ HomeScreen disposing...");
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          // Handle back button - ensure clean state
          _controller.forceCloseAllDialogs(context);
        }
      },
      child: ConnectivityWidget(
        child: Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: _buildAppBar(),
          body: _buildBody(),
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: AppTheme.headerContainerDecoration,
      ),
      elevation: 0,
      title: const Text(
        "MEETsu Solutions",
        style: AppTheme.appNameStyle,
      ),
      centerTitle: true,
      actions: [
        ValueListenableBuilder<int>(
          valueListenable: _controller.selectedIndex,
          builder: (context, selectedIndex, _) {
            return _buildAppBarActions(selectedIndex);
          },
        ),
      ],
    );
  }

  Widget _buildAppBarActions(int selectedIndex) {
    if (selectedIndex == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quiz button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildActionButton(
              text: 'Quiz ?',
              color: Colors.blue,
              onPressed: _handleManualQuiz,
            ),
          ),
        ],
      );
    } else {
      return _buildUserNameContainer();
    }
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
    double fontSize = 14,
  }) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUserNameContainer() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          SharedPrefsService.instance.getUsername(),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder<int>(
      valueListenable: _controller.selectedIndex,
      builder: (context, selectedIndex, _) {
        switch (selectedIndex) {
          case 0:
            return const DashboardScreen();
          case 1:
            return const ScheduleScreen();
          case 2:
            return const JobOpeningScreen();
          case 3:
            return const ComplianceScreen();
          case 4:
            return const MoreScreen();
          default:
            return const DashboardScreen();
        }
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return ValueListenableBuilder<int>(
      valueListenable: _controller.selectedIndex,
      builder: (context, selectedIndex, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [AppTheme.primaryShadow],
          ),
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: _controller.changeTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textSecondaryColor,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Schedule',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.work_outline),
                activeIcon: Icon(Icons.work),
                label: 'Job Opening',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.verified_outlined),
                activeIcon: Icon(Icons.verified),
                label: 'Compliance',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz),
                activeIcon: Icon(Icons.more_horiz),
                label: 'More',
              ),
            ],
          ),
        );
      },
    );
  }
}
