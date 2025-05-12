import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class WeeklyAnalyticsController {
  final ApiService _apiService;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> hasData = ValueNotifier<bool>(false);

  // Date controllers
  final ValueNotifier<String> startDate = ValueNotifier<String>('');
  final ValueNotifier<String> endDate = ValueNotifier<String>('');

  // Search controllers
  final TextEditingController logIdController = TextEditingController();
  final TextEditingController applicantNameController = TextEditingController();

  // Analytics data
  final ValueNotifier<List<WeeklyAnalyticsItem>> analyticsItems = ValueNotifier<List<WeeklyAnalyticsItem>>([]);
  final ValueNotifier<int> currentPage = ValueNotifier<int>(1);
  final ValueNotifier<int> totalPages = ValueNotifier<int>(1);
  final ValueNotifier<int> totalItems = ValueNotifier<int>(40);
  final ValueNotifier<int> itemsPerPage = ValueNotifier<int>(20);

  WeeklyAnalyticsController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    initialize();
  }

  void initialize() {
    final token = SharedPrefsService.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _apiService.client.addAuthToken(token);
    }

    // Set default date range (current week)
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    startDate.value = DateFormat('MMM dd, yyyy').format(startOfWeek);
    endDate.value = DateFormat('MMM dd, yyyy').format(endOfWeek);

    debugPrint("🔄 Initializing Weekly Analytics Controller...");

    // Load initial data
    fetchAnalyticsData();
  }

  Future<void> fetchAnalyticsData() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      debugPrint("🔄 Fetching weekly analytics data...");

      // Simulate API call with demo data
      await Future.delayed(const Duration(seconds: 1));

      // Mock data based on the image
      final List<WeeklyAnalyticsItem> items = [
        WeeklyAnalyticsItem(
            logId: '14476',
            applicantName: 'HIREN PANCHAL',
            days: _generateDaysForPerson(1),
            totalHours: '32.50'
        ),
        WeeklyAnalyticsItem(
            logId: '5345',
            applicantName: 'JOY BUENCAMINO',
            days: _generateDaysForPerson(2),
            totalHours: '32.50'
        ),
        WeeklyAnalyticsItem(
            logId: '26670',
            applicantName: 'MICHELLE MONTIEL',
            days: _generateDaysForPerson(3),
            totalHours: '32.50'
        ),
        WeeklyAnalyticsItem(
            logId: '30482',
            applicantName: 'NORELYN ESPIRITU',
            days: _generateDaysForPerson(4),
            totalHours: '32.50'
        ),
      ];

      analyticsItems.value = items;
      hasData.value = true;
      debugPrint("✅ Weekly analytics data fetched successfully");
    } catch (e) {
      errorMessage.value = "Failed to load data: ${e.toString()}";
      hasData.value = false;
      debugPrint("❌ Error fetching weekly analytics data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  List<DayEntry> _generateDaysForPerson(int personId) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    final List<DayEntry> days = [];

    for (int i = 0; i < 5; i++) {
      final currentDay = monday.add(Duration(days: i));
      final dayName = DateFormat('EEEE').format(currentDay);
      final date = DateFormat('MMM dd, yyyy').format(currentDay);

      final shift = (personId <= 2)
          ? 'Morning Shift (10:00 to 18:00)'
          : 'Morning Shift (07:30 to 15:30)';

      final checkIn = (personId <= 2) ? '10:00' : '07:30';
      final checkOut = (personId <= 2) ? '18:00' : '15:30';

      days.add(DayEntry(
          dayName: dayName,
          date: date,
          shift: shift,
          checkIn: checkIn,
          checkOut: checkOut,
          hours: '7.50',
          isNotYet: i >= 4 // Friday is "not yet" in the example
      ));
    }

    return days;
  }

  // Function to show date picker for start date
  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _parseDate(startDate.value),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      startDate.value = DateFormat('MMM dd, yyyy').format(picked);
      fetchAnalyticsData(); // Reload data with new date
    }
  }

  // Function to show date picker for end date
  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _parseDate(endDate.value),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      endDate.value = DateFormat('MMM dd, yyyy').format(picked);
      fetchAnalyticsData(); // Reload data with new date
    }
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('MMM dd, yyyy').parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  // Function to navigate to previous week
  void navigateToPreviousPeriod() {
    final start = _parseDate(startDate.value);
    final end = _parseDate(endDate.value);

    final newStart = start.subtract(const Duration(days: 7));
    final newEnd = end.subtract(const Duration(days: 7));

    startDate.value = DateFormat('MMM dd, yyyy').format(newStart);
    endDate.value = DateFormat('MMM dd, yyyy').format(newEnd);

    fetchAnalyticsData();
  }

  // Function to navigate to next week
  void navigateToNextPeriod() {
    final start = _parseDate(startDate.value);
    final end = _parseDate(endDate.value);

    final newStart = start.add(const Duration(days: 7));
    final newEnd = end.add(const Duration(days: 7));

    startDate.value = DateFormat('MMM dd, yyyy').format(newStart);
    endDate.value = DateFormat('MMM dd, yyyy').format(newEnd);

    fetchAnalyticsData();
  }

  // Function to search by log ID and applicant name
  void search() {
    fetchAnalyticsData();
  }

  // Function to navigate to specific page
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      fetchAnalyticsData();
    }
  }

  // Function to navigate to next page
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      fetchAnalyticsData();
    }
  }

  // Function to navigate to previous page
  void prevPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchAnalyticsData();
    }
  }

  // Calculate pager info
  String getPagerInfo() {
    final int start = ((currentPage.value - 1) * itemsPerPage.value) + 1;
    final int end = start + analyticsItems.value.length - 1;
    return "Showing $start-$end of ${totalItems.value} items.";
  }

  void dispose() {
    debugPrint("🧹 Disposing WeeklyAnalyticsController resources");
    isLoading.dispose();
    errorMessage.dispose();
    hasData.dispose();
    startDate.dispose();
    endDate.dispose();
    analyticsItems.dispose();
    logIdController.dispose();
    applicantNameController.dispose();
    currentPage.dispose();
    totalPages.dispose();
    totalItems.dispose();
    itemsPerPage.dispose();
  }
}

class WeeklyAnalyticsItem {
  final String logId;
  final String applicantName;
  final List<DayEntry> days;
  final String totalHours;

  WeeklyAnalyticsItem({
    required this.logId,
    required this.applicantName,
    required this.days,
    required this.totalHours
  });
}

class DayEntry {
  final String dayName;
  final String date;
  final String shift;
  final String checkIn;
  final String checkOut;
  final String hours;
  final bool isNotYet;

  DayEntry({
    required this.dayName,
    required this.date,
    required this.shift,
    required this.checkIn,
    required this.checkOut,
    required this.hours,
    this.isNotYet = false
  });
}