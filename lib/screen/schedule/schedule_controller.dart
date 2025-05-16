import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/model/schedule/schedule_response_model.dart';

class ScheduleController {
  final ApiService _apiService;

  final ValueNotifier<String> startDate = ValueNotifier<String>(
      _getCorrectStartDate(DateTime.now()));

  final ValueNotifier<String> endDate = ValueNotifier<String>(
      _getCorrectEndDate(DateTime.now()));

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> hasData = ValueNotifier<bool>(false);
  final ValueNotifier<List<Data>> scheduleItems = ValueNotifier<List<Data>>([]);
  final ValueNotifier<String?> payCheck = ValueNotifier<String?>(null);

  ScheduleController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    _fetchScheduleData();
  }

  static String _getCorrectStartDate(DateTime now) {
    if (now.day >= 1 && now.day <= 12) {
      final startDate = DateTime(now.year, now.month, 12);
      return _formatDateStatic(startDate);
    }
    else if (now.day >= 13 && now.day <= 25) {
      final startDate = DateTime(now.year, now.month, 12);
      return _formatDateStatic(startDate);
    }
    else {
      final startDate = DateTime(now.year, now.month, 26);
      return _formatDateStatic(startDate);
    }
  }

  static String _getCorrectEndDate(DateTime now) {
    if (now.day >= 1 && now.day <= 12) {
      final endDate = DateTime(now.year, now.month, 25);
      return _formatDateStatic(endDate);
    }
    else if (now.day >= 13 && now.day <= 25) {
      final endDate = DateTime(now.year, now.month, 25);
      return _formatDateStatic(endDate);
    }
    else {
      final endDate = DateTime(now.year, now.month, 26).add(const Duration(days: 13));
      return _formatDateStatic(endDate);
    }
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
      if (picked.day >= 1 && picked.day <= 12) {
        final newStartDate = DateTime(picked.year, picked.month, 12);
        final newEndDate = DateTime(picked.year, picked.month, 25);
        startDate.value = _formatDate(newStartDate);
        endDate.value = _formatDate(newEndDate);
      } else if (picked.day >= 13 && picked.day <= 25) {
        final newStartDate = DateTime(picked.year, picked.month, 12);
        final newEndDate = DateTime(picked.year, picked.month, 25);
        startDate.value = _formatDate(newStartDate);
        endDate.value = _formatDate(newEndDate);
      } else {
        final newStartDate = DateTime(picked.year, picked.month, 26);
        final newEndDate = newStartDate.add(const Duration(days: 13));
        startDate.value = _formatDate(newStartDate);
        endDate.value = _formatDate(newEndDate);
      }

      _fetchScheduleData();
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime currentDate = _parseDate(endDate.value);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != currentDate) {
      if (picked.day >= 1 && picked.day <= 8) {
        final newEndDate = DateTime(picked.year, picked.month, 8);
        final newStartDate = DateTime(picked.year, picked.month, 8).subtract(const Duration(days: 13));
        startDate.value = _formatDate(newStartDate);
        endDate.value = _formatDate(newEndDate);
      } else if (picked.day >= 9 && picked.day <= 25) {
        final newEndDate = DateTime(picked.year, picked.month, 25);
        final newStartDate = DateTime(picked.year, picked.month, 12);
        startDate.value = _formatDate(newStartDate);
        endDate.value = _formatDate(newEndDate);
      } else {
        final newStartDate = DateTime(picked.year, picked.month, 26);
        final newEndDate = newStartDate.add(const Duration(days: 13));
        startDate.value = _formatDate(newStartDate);
        endDate.value = _formatDate(newEndDate);
      }

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

  static DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    final month = _getMonthNumberStatic(parts[0]);
    final day = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  String _formatDate(DateTime date) {
    final month = _getMonthName(date.month);
    return "$month-${date.day.toString().padLeft(2, '0')}-${date.year}";
  }

  static String _formatDateStatic(DateTime date) {
    final monthNames = {
      1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun',
      7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'
    };
    final month = monthNames[date.month] ?? 'Jan';
    return "$month-${date.day.toString().padLeft(2, '0')}-${date.year}";
  }

  int _getMonthNumber(String monthName) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    return months[monthName] ?? 1;
  }

  static int _getMonthNumberStatic(String monthName) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    return months[monthName] ?? 1;
  }

  String _getMonthName(int monthNumber) {
    const months = {
      1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun',
      7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'
    };
    return months[monthNumber] ?? 'Jan';
  }

  void navigateToPreviousPeriod() {
    final currentStartDay = _parseDate(startDate.value).day;
    final currentStartMonth = _parseDate(startDate.value).month;
    final currentStartYear = _parseDate(startDate.value).year;

    if (currentStartDay == 12) {
      final previousMonth = currentStartMonth == 1 ? 12 : currentStartMonth - 1;
      final previousYear = currentStartMonth == 1 ? currentStartYear - 1 : currentStartYear;

      final newStartDate = DateTime(previousYear, previousMonth, 26);
      final newEndDate = newStartDate.add(const Duration(days: 13));

      startDate.value = _formatDate(newStartDate);
      endDate.value = _formatDate(newEndDate);
    } else if (currentStartDay == 26) {
      final newStartDate = DateTime(currentStartYear, currentStartMonth, 12);
      final newEndDate = DateTime(currentStartYear, currentStartMonth, 25);

      startDate.value = _formatDate(newStartDate);
      endDate.value = _formatDate(newEndDate);
    }

    _fetchScheduleData();
  }

  void navigateToNextPeriod() {
    final currentStartDay = _parseDate(startDate.value).day;
    final currentStartMonth = _parseDate(startDate.value).month;
    final currentStartYear = _parseDate(startDate.value).year;

    if (currentStartDay == 12) {
      final newStartDate = DateTime(currentStartYear, currentStartMonth, 26);
      final newEndDate = newStartDate.add(const Duration(days: 13));

      startDate.value = _formatDate(newStartDate);
      endDate.value = _formatDate(newEndDate);
    } else if (currentStartDay == 26) {
      final nextMonth = currentStartMonth == 12 ? 1 : currentStartMonth + 1;
      final nextYear = currentStartMonth == 12 ? currentStartYear + 1 : currentStartYear;

      final newStartDate = DateTime(nextYear, nextMonth, 12);
      final newEndDate = DateTime(nextYear, nextMonth, 25);

      startDate.value = _formatDate(newStartDate);
      endDate.value = _formatDate(newEndDate);
    }

    _fetchScheduleData();
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





/*import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/model/schedule/schedule_response_model.dart';

class ScheduleController {
  final ApiService _apiService;

  final ValueNotifier<String> startDate = ValueNotifier<String>(
      _getThisWeekMonday(DateTime.now()));

  final ValueNotifier<String> endDate = ValueNotifier<String>(
      _getNextWeekSunday(DateTime.now()));

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> hasData = ValueNotifier<bool>(false);
  final ValueNotifier<List<Data>> scheduleItems = ValueNotifier<List<Data>>([]);
  final ValueNotifier<String?> payCheck = ValueNotifier<String?>(null);

  ScheduleController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    _fetchScheduleData();
  }

  static String _getThisWeekMonday(DateTime now) {
    int daysToSubtract = (now.weekday - 1) % 7;
    final monday = now.subtract(Duration(days: daysToSubtract));
    return _formatDateStatic(monday);
  }

  static String _getNextWeekSunday(DateTime now) {
    int daysToSubtract = (now.weekday - 1) % 7;
    final monday = now.subtract(Duration(days: daysToSubtract));
    final nextSunday = monday.add(const Duration(days: 13));
    return _formatDateStatic(nextSunday);
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
      int daysToSubtract = (picked.weekday - 1) % 7;
      final monday = picked.subtract(Duration(days: daysToSubtract));

      final nextSunday = monday.add(const Duration(days: 13));

      startDate.value = _formatDate(monday);
      endDate.value = _formatDate(nextSunday);

      _fetchScheduleData();
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime currentDate = _parseDate(endDate.value);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != currentDate) {
      int daysToAdd = (7 - picked.weekday) % 7;
      final sunday = picked.add(Duration(days: daysToAdd));

      final previousMonday = sunday.subtract(const Duration(days: 13));

      startDate.value = _formatDate(previousMonday);
      endDate.value = _formatDate(sunday);

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

  static DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    final month = _getMonthNumberStatic(parts[0]);
    final day = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  String _formatDate(DateTime date) {
    final month = _getMonthName(date.month);
    return "$month-${date.day.toString().padLeft(2, '0')}-${date.year}";
  }

  static String _formatDateStatic(DateTime date) {
    final monthNames = {
      1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun',
      7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'
    };
    final month = monthNames[date.month] ?? 'Jan';
    return "$month-${date.day.toString().padLeft(2, '0')}-${date.year}";
  }

  int _getMonthNumber(String monthName) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    return months[monthName] ?? 1;
  }

  static int _getMonthNumberStatic(String monthName) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    return months[monthName] ?? 1;
  }

  String _getMonthName(int monthNumber) {
    const months = {
      1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun',
      7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'
    };
    return months[monthNumber] ?? 'Jan';
  }

  void navigateToPreviousPeriod() {
    final currentStartDate = _parseDate(startDate.value);
    final newStartDate = currentStartDate.subtract(const Duration(days: 14));
    final newEndDate = newStartDate.add(const Duration(days: 13));

    startDate.value = _formatDate(newStartDate);
    endDate.value = _formatDate(newEndDate);

    _fetchScheduleData();
  }

  void navigateToNextPeriod() {
    final currentStartDate = _parseDate(startDate.value);
    final newStartDate = currentStartDate.add(const Duration(days: 14));
    final newEndDate = newStartDate.add(const Duration(days: 13));

    startDate.value = _formatDate(newStartDate);
    endDate.value = _formatDate(newEndDate);

    _fetchScheduleData();
  }

  void dispose() {
    startDate.dispose();
    endDate.dispose();
    isLoading.dispose();
    hasData.dispose();
    scheduleItems.dispose();
    payCheck.dispose();
  }
}*/