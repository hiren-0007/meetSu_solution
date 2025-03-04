import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/model/schedule/schedule_response_model.dart';

class ScheduleController {
  // API Service
  final ApiService _apiService;

  // Date range
  final ValueNotifier<String> startDate = ValueNotifier<String>("Feb-24-2025");
  final ValueNotifier<String> endDate = ValueNotifier<String>("Mar-09-2025");

  // Loading state
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  // Data state
  final ValueNotifier<bool> hasData = ValueNotifier<bool>(false);

  // Schedule data
  final ValueNotifier<List<Data>> scheduleItems = ValueNotifier<List<Data>>([]);

  // Pay check data
  final ValueNotifier<String?> payCheck = ValueNotifier<String?>(null);

  // Constructor
  ScheduleController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    // Initialize data when created
    _fetchScheduleData();
  }

  // Select start date
  Future<void> selectStartDate(BuildContext context) async {
    final DateTime currentDate = _parseDate(startDate.value);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != currentDate) {
      startDate.value = _formatDate(picked);
      _fetchScheduleData();
    }
  }

  // Select end date
  Future<void> selectEndDate(BuildContext context) async {
    final DateTime currentDate = _parseDate(endDate.value);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != currentDate) {
      endDate.value = _formatDate(picked);
      _fetchScheduleData();
    }
  }

  // Fetch schedule data from API
  Future<void> _fetchScheduleData() async {
    try {
      isLoading.value = true;

      // Get user token from Shared Preferences
      final token = SharedPrefsService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

      // Add Authorization Token to API Client
      _apiService.client.addAuthToken(token);

      // Make API Call with date parameters
      final response = await _apiService.getSchedule();

      // Convert Response to ScheduleResponseModel
      final scheduleResponse = ScheduleResponseModel.fromJson(response);

      // Update payCheck
      payCheck.value = scheduleResponse.payCheck;

      // Check if data is available
      if (scheduleResponse.data != null && scheduleResponse.data!.isNotEmpty) {
        scheduleItems.value = scheduleResponse.data!;
        hasData.value = true;
      } else {
        scheduleItems.value = [];
        hasData.value = false;
      }
    } catch (e) {
      print("❌ Error fetching schedule data: $e");
      scheduleItems.value = [];
      hasData.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  // Parse date string to DateTime
  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    final month = _getMonthNumber(parts[0]);
    final day = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  // Format DateTime to string
  String _formatDate(DateTime date) {
    final month = _getMonthName(date.month);
    return "$month-${date.day.toString().padLeft(2, '0')}-${date.year}";
  }

  // Get month number from name
  int _getMonthNumber(String monthName) {
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12
    };
    return months[monthName] ?? 1;
  }

  // Get month name from number
  String _getMonthName(int monthNumber) {
    const months = {
      1: 'Jan',
      2: 'Feb',
      3: 'Mar',
      4: 'Apr',
      5: 'May',
      6: 'Jun',
      7: 'Jul',
      8: 'Aug',
      9: 'Sep',
      10: 'Oct',
      11: 'Nov',
      12: 'Dec'
    };
    return months[monthNumber] ?? 'Jan';
  }

  // Dispose resources
  void dispose() {
    startDate.dispose();
    endDate.dispose();
    isLoading.dispose();
    hasData.dispose();
    scheduleItems.dispose();
    payCheck.dispose();
  }
}
