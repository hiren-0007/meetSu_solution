import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:intl/intl.dart';

class ScheduleData {
  final String type; // "AM | DM" or "AM | OH"
  final int available;
  final int booked;
  final int pending;
  final List<AppointmentData> appointments;

  ScheduleData({
    required this.type,
    required this.available,
    required this.booked,
    required this.pending,
    required this.appointments,
  });
}

class AppointmentData {
  final String personName;
  final String timeSlot;
  final String status; // "Confirmed", "Pending"

  AppointmentData({
    required this.personName,
    required this.timeSlot,
    required this.status,
  });
}

class ClintSchedulerViewController {
  final ApiService _apiService;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> hasData = ValueNotifier<bool>(false);

  // Current week data
  final ValueNotifier<DateTime> currentWeekStart = ValueNotifier<DateTime>(DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)));
  final ValueNotifier<Map<String, Map<int, ScheduleData>>> scheduleData = ValueNotifier<Map<String, Map<int, ScheduleData>>>({});

  ClintSchedulerViewController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    initialize();
  }

  void initialize() {
    final token = SharedPrefsService.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _apiService.client.addAuthToken(token);
    }

    debugPrint("🔄 Initializing Client Scheduler Controller...");

    // Initialize with the current week
    DateTime monday = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    currentWeekStart.value = monday;
  }

  // Get formatted week range string (e.g., "May 5 – 11, 2025")
  String getFormattedWeekRange() {
    final DateFormat monthDayFormat = DateFormat('MMM d');
    final start = currentWeekStart.value;
    final end = start.add(const Duration(days: 6));

    return '${monthDayFormat.format(start)} – ${monthDayFormat.format(end)}, ${end.year}';
  }

  // Navigate to previous week
  void previousWeek() {
    currentWeekStart.value = currentWeekStart.value.subtract(const Duration(days: 7));
    fetchDashboardData();
  }

  // Navigate to next week
  void nextWeek() {
    currentWeekStart.value = currentWeekStart.value.add(const Duration(days: 7));
    fetchDashboardData();
  }

  // Get schedule data for specific day and type
  ScheduleData? getScheduleForDayAndType(DateTime date, String scheduleType) {
    final dayOfWeek = date.weekday; // 1 for Monday, 7 for Sunday

    if (scheduleData.value.containsKey(scheduleType) &&
        scheduleData.value[scheduleType]!.containsKey(dayOfWeek)) {
      return scheduleData.value[scheduleType]![dayOfWeek];
    }

    // Return default data if not found
    if (scheduleType == "AM | DM") {
      return ScheduleData(
        type: scheduleType,
        available: 3,
        booked: date.weekday <= 5 ? 3 : 0, // 3 on weekdays, 0 on weekends
        pending: 0,
        appointments: _generateMockAppointments(date, scheduleType),
      );
    } else {
      return ScheduleData(
        type: scheduleType,
        available: 5,
        booked: date.weekday <= 5 ? 5 : 0, // 5 on weekdays, 0 on weekends
        pending: 0,
        appointments: _generateMockAppointments(date, scheduleType),
      );
    }
  }

  // Helper to generate mock appointments for the demo
  List<AppointmentData> _generateMockAppointments(DateTime date, String scheduleType) {
    if (date.weekday > 5) {
      return []; // No appointments on weekends
    }

    final List<AppointmentData> result = [];
    final int count = scheduleType == "AM | DM" ? 3 : 5;

    final List<String> names = [
      "Michelle Montiel",
      "Norelyn Espiritu",
      "Shubham Khosla",
      "John Smith",
      "Jane Doe",
      "Alex Johnson",
      "Sarah Williams"
    ];

    for (int i = 0; i < count; i++) {
      final startHour = 9 + i;
      final endHour = 10 + i;
      final status = i % 3 == 0 ? "Pending" : "Confirmed";

      result.add(AppointmentData(
        personName: names[i % names.length],
        timeSlot: "$startHour:00 AM - $endHour:00 AM",
        status: status,
      ));
    }

    return result;
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      debugPrint("🔄 Fetching client scheduler data...");

      // Simulating API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Simulate successful data fetch
      final Map<String, Map<int, ScheduleData>> mockData = {};

      // Mock data for AM | DM
      mockData["AM | DM"] = {};
      for (int day = 1; day <= 7; day++) {
        final DateTime date = currentWeekStart.value.add(Duration(days: day - 1));
        mockData["AM | DM"]![day] = ScheduleData(
          type: "AM | DM",
          available: 3,
          booked: day <= 5 ? 3 : 0, // 3 on weekdays, 0 on weekends
          pending: 0,
          appointments: _generateMockAppointments(date, "AM | DM"),
        );
      }

      // Mock data for AM | OH
      mockData["AM | OH"] = {};
      for (int day = 1; day <= 7; day++) {
        final DateTime date = currentWeekStart.value.add(Duration(days: day - 1));
        mockData["AM | OH"]![day] = ScheduleData(
          type: "AM | OH",
          available: 5,
          booked: day <= 5 ? 5 : 0, // 5 on weekdays, 0 on weekends
          pending: 0,
          appointments: _generateMockAppointments(date, "AM | OH"),
        );
      }

      scheduleData.value = mockData;
      hasData.value = true;

      debugPrint("✅ Client scheduler data fetched. Has data: ${hasData.value}");
    } catch (e) {
      errorMessage.value = "Failed to load scheduler data: ${e.toString()}";
      hasData.value = false;
      debugPrint("❌ Error fetching client scheduler data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(DateTime date, String scheduleType, String personName, String newStatus) async {
    try {
      // This would typically make an API call
      debugPrint("Updating appointment status for $personName to $newStatus");

      // For demo, just show a delay
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      // Refresh data after update
      await fetchDashboardData();

    } catch (e) {
      errorMessage.value = "Failed to update appointment: ${e.toString()}";
      debugPrint("❌ Error updating appointment: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new appointment slot
  Future<void> addAppointmentSlot(DateTime date, String scheduleType) async {
    try {
      // This would typically make an API call
      debugPrint("Adding new appointment slot for ${DateFormat('yyyy-MM-dd').format(date)}, type: $scheduleType");

      // For demo, just show a delay
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      // Refresh data after adding
      await fetchDashboardData();

    } catch (e) {
      errorMessage.value = "Failed to add appointment slot: ${e.toString()}";
      debugPrint("❌ Error adding appointment slot: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    debugPrint("🧹 Disposing ClientSchedulerController resources");
    isLoading.dispose();
    errorMessage.dispose();
    hasData.dispose();
    currentWeekStart.dispose();
    scheduleData.dispose();
  }
}