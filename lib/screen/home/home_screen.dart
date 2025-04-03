import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/compliance/compliance_screen.dart';
import 'package:meetsu_solutions/screen/dashboard/dashboard_screen.dart';
import 'package:meetsu_solutions/screen/job/job_opening_screen.dart';
import 'package:meetsu_solutions/screen/more/more_screen.dart';
import 'package:meetsu_solutions/screen/schedule/schedule_screen.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/screen/home/home_controller.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController _controller = HomeController();

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
        appBar: AppBar(
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
                if (selectedIndex == 0) {
                  return IconButton(
                    icon: const Icon(Icons.question_mark, color: Colors.white),
                    onPressed: () => _controller.openNotifications(context),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(
                        right: 16.0, top: 8.0, bottom: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            SharedPrefsService.instance.getUsername(),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        body: ValueListenableBuilder<int>(
          valueListenable: _controller.selectedIndex,
          builder: (context, selectedIndex, _) {
            return _buildBody(selectedIndex);
          },
        ),
        bottomNavigationBar: ValueListenableBuilder<int>(
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
        ),
      ),
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
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
  }
}
