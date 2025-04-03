import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/model/schedule/schedule_response_model.dart';

class ScheduleController {
  final ApiService _apiService;

  final ValueNotifier<String> startDate = ValueNotifier<String>("Feb-24-2025");
  final ValueNotifier<String> endDate = ValueNotifier<String>("Mar-09-2025");

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  final ValueNotifier<bool> hasData = ValueNotifier<bool>(false);

  final ValueNotifier<List<Data>> scheduleItems = ValueNotifier<List<Data>>([]);

  final ValueNotifier<String?> payCheck = ValueNotifier<String?>(null);

  ScheduleController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    _fetchScheduleData();
  }

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

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime minEndDate =
        _parseDate(startDate.value).add(const Duration(days: 14));
    final DateTime currentDate = _parseDate(endDate.value);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate.isBefore(minEndDate) ? minEndDate : currentDate,
      firstDate: minEndDate,
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != currentDate) {
      endDate.value = _formatDate(picked);
      _fetchScheduleData();
    }
  }

  Future<void> _fetchScheduleData() async {
    try {
      isLoading.value = true;

      final token = SharedPrefsService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

      _apiService.client.addAuthToken(token);

      final response = await _apiService.getSchedule(
          {"start_date": startDate.value, "end_date": endDate.value});

      final scheduleResponse = ScheduleResponseModel.fromJson(response);

      payCheck.value = scheduleResponse.payCheck;

      if (scheduleResponse.data != null && scheduleResponse.data!.isNotEmpty) {
        scheduleItems.value = scheduleResponse.data!;
        hasData.value = true;
      } else {
        scheduleItems.value = [];
        hasData.value = false;
      }
    } catch (e) {
      print("Error fetching schedule data: $e");
      scheduleItems.value = [];
      hasData.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    final month = _getMonthNumber(parts[0]);
    final day = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  String _formatDate(DateTime date) {
    final month = _getMonthName(date.month);
    return "$month-${date.day.toString().padLeft(2, '0')}-${date.year}";
  }

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

  void dispose() {
    startDate.dispose();
    endDate.dispose();
    isLoading.dispose();
    hasData.dispose();
    scheduleItems.dispose();
    payCheck.dispose();
  }
}
