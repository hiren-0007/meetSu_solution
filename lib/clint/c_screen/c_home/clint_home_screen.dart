import 'package:flutter/material.dart';
import 'package:meetsu_solutions/clint/c_screen/c_dashboard/clint_dashboard_screen.dart';
import 'package:meetsu_solutions/clint/c_screen/c_home/clint_home_controller.dart';
import 'package:meetsu_solutions/clint/c_screen/c_more/clint_more_screen.dart';
import 'package:meetsu_solutions/clint/c_screen/c_scheduler/clint_scheduler_view_screen.dart';
import 'package:meetsu_solutions/clint/c_screen/cs_job/clint_send_job_request_screen.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final ClientHomeController _controller = ClientHomeController();

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
                selectedItemColor: AppTheme.primaryClintColor,
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
                    icon: Icon(Icons.send_outlined),
                    activeIcon: Icon(Icons.send),
                    label: 'Send Job Request',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today_outlined),
                    activeIcon: Icon(Icons.calendar_today),
                    label: 'Scheduler View',
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
        return const ClientDashboardScreen();
      case 1:
        return const ClintSendJobRequestScreen();
      case 2:
        return const ClintSchedulerViewScreen();
      case 3:
        return const ClintMoreScreen();
      default:
        return const ClientDashboardScreen();
    }
  }
}