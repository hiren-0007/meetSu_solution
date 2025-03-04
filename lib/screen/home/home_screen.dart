import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/compliance/compliance_screen.dart';
import 'package:meetsu_solutions/screen/dashboard/dashboard_screen.dart';
import 'package:meetsu_solutions/screen/job/job_opening_screen.dart';
import 'package:meetsu_solutions/screen/more/more_screen.dart';
import 'package:meetsu_solutions/screen/schedule/schedule_screen.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/screen/home/home_controller.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Use the controller
  final HomeController _controller = HomeController();

  @override
  void dispose() {
    // Dispose controller resources
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: AppTheme.headerContainerDecoration,
        ),
        elevation: 0,
        title: const Text(
          "MEETsu SOLUTIONS",
          style: AppTheme.appNameStyle,
        ),
        centerTitle: true,
        // leading: IconButton(
        //   icon: const Icon(Icons.menu, color: Colors.white),
        //   onPressed: () => _controller.openDrawer(context),
        // ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.notifications_outlined, color: Colors.white),
        //     onPressed: () => _controller.openNotifications(context),
        //   ),
        // ],
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
    );
  }

  Widget _buildBody(int index) {
    // Return different content based on selected tab
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

  Widget _buildDashboardTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard,
            size: 80,
            color: AppTheme.primaryColor.withOpacity(0.5),
          ),
          SizedBox(height: AppTheme.contentSpacing),
          const Text(
            "Dashboard",
            style: AppTheme.headerStyle,
          ),
          SizedBox(height: AppTheme.smallSpacing),
          Text(
            "Your upcoming appointments and events",
            style: AppTheme.subHeaderStyle,
          ),
        ],
      ),
    );
  }


  Widget _buildScheduleTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 80,
            color: AppTheme.primaryColor.withOpacity(0.5),
          ),
          SizedBox(height: AppTheme.contentSpacing),
          const Text(
            "Schedule",
            style: AppTheme.headerStyle,
          ),
          SizedBox(height: AppTheme.smallSpacing),
          Text(
            "Your upcoming appointments and events",
            style: AppTheme.subHeaderStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildJobOpeningTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work,
            size: 80,
            color: AppTheme.primaryColor.withOpacity(0.5),
          ),
          SizedBox(height: AppTheme.contentSpacing),
          const Text(
            "Job Openings",
            style: AppTheme.headerStyle,
          ),
          SizedBox(height: AppTheme.smallSpacing),
          Text(
            "Explore and manage available positions",
            style: AppTheme.subHeaderStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified,
            size: 80,
            color: AppTheme.primaryColor.withOpacity(0.5),
          ),
          SizedBox(height: AppTheme.contentSpacing),
          const Text(
            "Compliance",
            style: AppTheme.headerStyle,
          ),
          SizedBox(height: AppTheme.smallSpacing),
          Text(
            "View and update compliance documents",
            style: AppTheme.subHeaderStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildMoreTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.more_horiz,
            size: 80,
            color: AppTheme.primaryColor.withOpacity(0.5),
          ),
          SizedBox(height: AppTheme.contentSpacing),
          const Text(
            "More Options",
            style: AppTheme.headerStyle,
          ),
          SizedBox(height: AppTheme.smallSpacing),
          Text(
            "Access additional features and settings",
            style: AppTheme.subHeaderStyle,
          ),
        ],
      ),
    );
  }
}