import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ScheduleData {
  final String type;
  final int totalSlots;
  final int booked;
  final int available;
  final List<AppointmentData> appointments;
  final String? date;
  final int? jobPositionId;

  const ScheduleData({
    required this.type,
    required this.totalSlots,
    required this.booked,
    required this.available,
    required this.appointments,
    this.date,
    this.jobPositionId,
  });

  factory ScheduleData.fromJson(Map<String, dynamic> json) {
    return ScheduleData(
      type: json['title']?.toString() ?? '',
      totalSlots: int.tryParse(json['positionCount']?.toString() ?? '0') ?? 0,
      booked: int.tryParse(json['assignCount']?.toString() ?? '0') ?? 0,
      available: int.tryParse(json['leftCount']?.toString() ?? '0') ?? 0,
      appointments: [],
      date: json['date']?.toString(),
      jobPositionId: int.tryParse(json['job_position_id']?.toString() ?? '0'),
    );
  }

  double get utilizationRate => totalSlots > 0 ? (booked / totalSlots) : 0.0;
  bool get hasAvailableSlots => available > 0;
  bool get isFullyBooked => available == 0 && totalSlots > 0;

  @override
  String toString() {
    return 'ScheduleData(type: $type, total: $totalSlots, booked: $booked, available: $available, date: $date)';
  }
}

class AppointmentData {
  final String personName;
  final String timeSlot;
  final String status;
  final String? notes;
  final DateTime? appointmentDate;

  const AppointmentData({
    required this.personName,
    required this.timeSlot,
    required this.status,
    this.notes,
    this.appointmentDate,
  });

  factory AppointmentData.fromJson(Map<String, dynamic> json) {
    return AppointmentData(
      personName: json['personName']?.toString() ?? '',
      timeSlot: json['timeSlot']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      notes: json['notes']?.toString(),
      appointmentDate: json['appointmentDate'] != null
          ? DateTime.tryParse(json['appointmentDate'].toString())
          : null,
    );
  }

  bool get isConfirmed => status.toLowerCase() == 'confirmed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  @override
  String toString() {
    return 'AppointmentData(name: $personName, timeSlot: $timeSlot, status: $status)';
  }
}

class ClintSchedulerViewController {
  final ApiService _apiService;

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> hasData = ValueNotifier<bool>(false);
  final ValueNotifier<DateTime> currentWeekStart = ValueNotifier<DateTime>(DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)));
  final ValueNotifier<List<ScheduleData>> scheduleDataList = ValueNotifier<List<ScheduleData>>([]);
  final ValueNotifier<Map<String, List<ScheduleData>>> groupedScheduleData = ValueNotifier<Map<String, List<ScheduleData>>>({});

  ClintSchedulerViewController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    _initialize();
  }

  void _initialize() {
    _setupAuthentication();
    _setInitialWeek();
    _logInitialization();
  }

  void _setupAuthentication() {
    final token = SharedPrefsService.instance.getAccessToken();
    if (token?.isNotEmpty == true) {
      _apiService.client.addAuthToken(token!);
    }
  }

  void _setInitialWeek() {
    final monday = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    currentWeekStart.value = monday;
  }

  void _logInitialization() {
    debugPrint("🔄 Client Scheduler Controller initialized");
  }

  String getFormattedWeekRange() {
    final DateFormat monthDayFormat = DateFormat('MMM d');
    final start = currentWeekStart.value;
    final end = start.add(const Duration(days: 6));

    if (start.month == end.month) {
      return '${monthDayFormat.format(start)} – ${end.day}, ${end.year}';
    } else {
      return '${monthDayFormat.format(start)} – ${monthDayFormat.format(end)}, ${end.year}';
    }
  }

  void previousWeek() {
    final newWeekStart = currentWeekStart.value.subtract(const Duration(days: 7));
    currentWeekStart.value = newWeekStart;
    fetchDashboardData();
    debugPrint("📅 Navigated to previous week: ${getFormattedWeekRange()}");
  }

  void nextWeek() {
    final newWeekStart = currentWeekStart.value.add(const Duration(days: 7));
    currentWeekStart.value = newWeekStart;
    fetchDashboardData();
    debugPrint("📅 Navigated to next week: ${getFormattedWeekRange()}");
  }

  Future<void> fetchDashboardData() async {
    if (isLoading.value) return;

    try {
      _setLoadingState(true);
      debugPrint("🔄 Fetching scheduler data for week: ${getFormattedWeekRange()}");

      final DateFormat apiDateFormat = DateFormat('yyyy-MM-dd');
      final startDate = apiDateFormat.format(currentWeekStart.value);
      final endDate = apiDateFormat.format(currentWeekStart.value.add(const Duration(days: 6)));

      final requestBody = {
        'start': startDate,
        'end': endDate,
      };

      debugPrint("📡 API Request: $requestBody");

      final response = await _apiService.getClientSchedule(requestBody);

      debugPrint("📡 API Response: $response");

      List<dynamic> apiData = [];

      if (response.containsKey('body')) {
        final bodyData = response['body'];
        if (bodyData is List) {
          apiData = bodyData;
          debugPrint("📊 Found data in 'body' key: ${apiData.length} records");
        } else if (bodyData is String) {
          try {
            final parsedBody = jsonDecode(bodyData);
            if (parsedBody is List) {
              apiData = parsedBody;
              debugPrint("📊 Parsed JSON from 'body' string: ${apiData.length} records");
            }
          } catch (e) {
            debugPrint("❌ Error parsing body string: $e");
          }
        }
      }

      if (apiData.isEmpty) {
        if (response.containsKey('data') && response['data'] is List) {
          apiData = response['data'] as List<dynamic>;
          debugPrint("📊 Found data in 'data' key: ${apiData.length} records");
        } else if (response['success'] == true || response['status'] == 'success') {
          final data = response['data'];
          if (data is List) {
            apiData = data;
            debugPrint("📊 Found data in success response: ${apiData.length} records");
          }
        }
      }

      if (apiData.isEmpty) {
        for (var value in response.values) {
          if (value is List) {
            apiData = value;
            debugPrint("📊 Found List data in response values: ${apiData.length} records");
            break;
          }
        }
      }

      debugPrint("📊 Final parsed API Data: Found ${apiData.length} records");

      if (apiData.isNotEmpty) {
        final List<ScheduleData> scheduleList = apiData
            .map((item) => ScheduleData.fromJson(item))
            .toList();

        scheduleDataList.value = scheduleList;

        final Map<String, List<ScheduleData>> grouped = {};
        for (var schedule in scheduleList) {
          if (!grouped.containsKey(schedule.type)) {
            grouped[schedule.type] = [];
          }
          grouped[schedule.type]!.add(schedule);
        }

        groupedScheduleData.value = grouped;
        hasData.value = scheduleList.isNotEmpty;
        errorMessage.value = null;

        debugPrint("✅ Scheduler data processed successfully. Items: ${scheduleList.length}");
        debugPrint("📊 Grouped data: ${grouped.keys.toList()}");

        for (var schedule in scheduleList.take(3)) {
          debugPrint("📋 Sample: ${schedule.toString()}");
        }

      } else {
        debugPrint("⚠️ No data found in API response");
        scheduleDataList.value = [];
        groupedScheduleData.value = {};
        hasData.value = false;
      }

    } catch (e) {
      _handleError(e);
    } finally {
      _setLoadingState(false);
    }
  }

  void _setLoadingState(bool loading) {
    isLoading.value = loading;
    if (loading) {
      errorMessage.value = null;
    }
  }

  void _handleError(Object error) {
    final errorMsg = "Failed to load scheduler data: ${error.toString()}";
    errorMessage.value = errorMsg;
    hasData.value = false;
    scheduleDataList.value = [];
    groupedScheduleData.value = {};
    debugPrint("❌ Error fetching scheduler data: $error");
  }

  List<ScheduleData> getScheduleForDayAndType(DateTime date, String scheduleType) {
    final DateFormat apiDateFormat = DateFormat('yyyy-MM-dd');
    final targetDate = apiDateFormat.format(date);

    final allSchedules = groupedScheduleData.value[scheduleType] ?? [];

    return allSchedules.where((schedule) => schedule.date == targetDate).toList();
  }

  List<ScheduleData> getScheduleForDay(DateTime date) {
    final DateFormat apiDateFormat = DateFormat('yyyy-MM-dd');
    final targetDate = apiDateFormat.format(date);

    return scheduleDataList.value.where((schedule) => schedule.date == targetDate).toList();
  }

  List<String> getScheduleTypes() {
    return groupedScheduleData.value.keys.toList();
  }

  int getTotalBookedForWeek() {
    return scheduleDataList.value.fold(0, (sum, schedule) => sum + schedule.booked);
  }

  int getTotalAvailableForWeek() {
    return scheduleDataList.value.fold(0, (sum, schedule) => sum + schedule.available);
  }

  int getTotalSlotsForWeek() {
    return scheduleDataList.value.fold(0, (sum, schedule) => sum + schedule.totalSlots);
  }

  double getWeekUtilizationRate() {
    final totalSlots = getTotalSlotsForWeek();
    final bookedSlots = getTotalBookedForWeek();

    return totalSlots > 0 ? (bookedSlots / totalSlots) : 0.0;
  }

  Map<String, int> getWeekSummaryForType(String scheduleType) {
    final typeSchedules = groupedScheduleData.value[scheduleType] ?? [];

    final totalSlots = typeSchedules.fold(0, (sum, schedule) => sum + schedule.totalSlots);
    final booked = typeSchedules.fold(0, (sum, schedule) => sum + schedule.booked);
    final available = typeSchedules.fold(0, (sum, schedule) => sum + schedule.available);

    return {
      'totalSlots': totalSlots,
      'booked': booked,
      'available': available,
    };
  }

  bool isCurrentWeek(DateTime date) {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final currentWeekEnd = currentWeekStart.add(const Duration(days: 6));

    return date.isAfter(currentWeekStart.subtract(const Duration(days: 1))) &&
        date.isBefore(currentWeekEnd.add(const Duration(days: 1)));
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool isPastDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    return checkDate.isBefore(today);
  }

  bool isWeekend(DateTime date) {
    return date.weekday > 5;
  }

  void goToCurrentWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    currentWeekStart.value = monday;
    fetchDashboardData();

    debugPrint("📅 Navigated to current week: ${getFormattedWeekRange()}");
  }

  void goToSpecificWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));

    currentWeekStart.value = monday;
    fetchDashboardData();

    debugPrint("📅 Navigated to specific week: ${getFormattedWeekRange()}");
  }

  Future<Map<String, dynamic>> fetchJobDetails(int jobPositionId) async {
    try {
      debugPrint("🔄 Fetching job details for ID: $jobPositionId");

      final response = await _apiService.getJobDetails(jobPositionId);

      debugPrint("📡 Job Details API Response: $response");

      Map<String, dynamic> result = {
        'jobDetails': {},
        'assignedApplicants': [],
      };

      if (response.containsKey('jobDetails')) {
        result['jobDetails'] = response['jobDetails'];
      } else if (response.containsKey('data')) {
        result['jobDetails'] = response['data'];
      } else {
        result['jobDetails'] = response;
      }

      if (response.containsKey('assignedApplicants')) {
        result['assignedApplicants'] = response['assignedApplicants'];
      } else if (response.containsKey('applicants')) {
        result['assignedApplicants'] = response['applicants'];
      } else if (response.containsKey('data') && response['data'] is Map) {
        final data = response['data'] as Map<String, dynamic>;
        if (data.containsKey('assignedApplicants')) {
          result['assignedApplicants'] = data['assignedApplicants'];
        }
      }

      debugPrint("✅ Job details processed successfully");
      return result;

    } catch (e) {
      debugPrint("❌ Error fetching job details: $e");
      throw Exception("Failed to load job details: $e");
    }
  }
  void dispose() {
    debugPrint("🧹 Disposing ClientSchedulerController resources");

    isLoading.dispose();
    errorMessage.dispose();
    hasData.dispose();
    currentWeekStart.dispose();
    scheduleDataList.dispose();
    groupedScheduleData.dispose();
  }
}