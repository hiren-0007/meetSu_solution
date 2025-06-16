import 'dart:convert';
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
  final ValueNotifier<int> totalItems = ValueNotifier<int>(0);
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

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    startDate.value = DateFormat('yyyy-MM-dd').format(startOfWeek);
    endDate.value = DateFormat('yyyy-MM-dd').format(endOfWeek);

    debugPrint("🔄 Initializing Weekly Analytics Controller...");

    fetchAnalyticsData();
  }

  Future<void> fetchAnalyticsData() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      debugPrint("🔄 Fetching weekly analytics data...");
      debugPrint("📅 Date range: ${startDate.value} to ${endDate.value}");

      final response = await _apiService.getWeeklyReport(startDate.value, endDate.value);

      debugPrint("📊 API Response: $response");

      List<dynamic> apiData = [];

      if (response.containsKey('body')) {
        final bodyData = response['body'];
        if (bodyData is List) {
          apiData = bodyData;
          debugPrint("📊 Found data in 'body' key: ${apiData.length} records");
        } else if (bodyData is String) {
          try {
            final parsedBody = json.decode(bodyData);
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
        final Map<String, List<Map<String, dynamic>>> groupedData = {};

        for (var item in apiData) {
          final Map<String, dynamic> itemMap = item as Map<String, dynamic>;
          final key = "${itemMap['logId']}_${itemMap['applicantName']}";
          if (!groupedData.containsKey(key)) {
            groupedData[key] = [];
          }
          groupedData[key]!.add(itemMap);
        }

        debugPrint("📊 Grouped data: Found ${groupedData.length} employees");

        final List<WeeklyAnalyticsItem> items = groupedData.entries.map((entry) {
          final employeeData = entry.value;
          final firstRecord = employeeData.first;

          final List<DayEntry> days = employeeData.map((dayData) {
            return DayEntry(
              dayName: _getDayName(dayData['date']?.toString() ?? ''),
              date: dayData['date']?.toString() ?? '',
              shift: dayData['shift']?.toString() ?? 'Morning Shift',
              checkIn: _formatTime(dayData['clockIn']?.toString()),
              checkOut: _formatTime(dayData['clockOut']?.toString()),
              hours: dayData['totalHours']?.toString() ?? '0.0',
              isNotYet: dayData['clockIn'] == null || dayData['clockOut'] == null,
            );
          }).toList();

          days.sort((a, b) {
            try {
              final dateA = DateTime.parse(a.date);
              final dateB = DateTime.parse(b.date);
              return dateA.compareTo(dateB);
            } catch (e) {
              return 0;
            }
          });

          double totalHours = 0.0;
          for (var dayData in employeeData) {
            if (dayData['totalHours'] != null) {
              totalHours += double.tryParse(dayData['totalHours'].toString()) ?? 0.0;
            }
          }

          return WeeklyAnalyticsItem(
            logId: firstRecord['logId']?.toString() ?? '',
            applicantName: firstRecord['applicantName']?.toString() ?? '',
            days: days,
            totalHours: totalHours.toStringAsFixed(2),
          );
        }).toList();

        analyticsItems.value = items;
        hasData.value = items.isNotEmpty;
        totalItems.value = items.length;

        debugPrint("✅ Weekly analytics data processed successfully. Found ${items.length} employees");
      } else {
        analyticsItems.value = [];
        hasData.value = false;
        debugPrint("⚠️ No data found in API response");
      }
    } catch (e) {
      errorMessage.value = "Failed to load data: ${e.toString()}";
      hasData.value = false;
      analyticsItems.value = [];
      debugPrint("❌ Error fetching weekly analytics data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String _getDayName(String dateStr) {
    try {
      if (dateStr.isEmpty) return 'Unknown';
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE').format(date);
    } catch (e) {
      debugPrint("Error parsing date: $dateStr - $e");
      return 'Unknown';
    }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty || timeStr == 'null') {
      return '00:00';
    }

    try {
      if (timeStr.contains(' ')) {
        final parts = timeStr.split(' ');
        if (parts.length > 1) {
          final timePart = parts[1];
          if (timePart.contains(':')) {
            final timeParts = timePart.split(':');
            return "${timeParts[0]}:${timeParts[1]}";
          }
        }
      }
      if (timeStr.contains(':')) {
        final timeParts = timeStr.split(':');
        return "${timeParts[0]}:${timeParts[1]}";
      }

      return timeStr;
    } catch (e) {
      debugPrint("Error formatting time: $timeStr - $e");
      return '00:00';
    }
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _parseDate(startDate.value),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      startDate.value = DateFormat('yyyy-MM-dd').format(picked);
      fetchAnalyticsData(); 
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _parseDate(endDate.value),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      endDate.value = DateFormat('yyyy-MM-dd').format(picked);
      fetchAnalyticsData(); 
    }
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  void navigateToPreviousPeriod() {
    final start = _parseDate(startDate.value);
    final end = _parseDate(endDate.value);

    final newStart = start.subtract(const Duration(days: 7));
    final newEnd = end.subtract(const Duration(days: 7));

    startDate.value = DateFormat('yyyy-MM-dd').format(newStart);
    endDate.value = DateFormat('yyyy-MM-dd').format(newEnd);

    fetchAnalyticsData();
  }

  void navigateToNextPeriod() {
    final start = _parseDate(startDate.value);
    final end = _parseDate(endDate.value);

    final newStart = start.add(const Duration(days: 7));
    final newEnd = end.add(const Duration(days: 7));

    startDate.value = DateFormat('yyyy-MM-dd').format(newStart);
    endDate.value = DateFormat('yyyy-MM-dd').format(newEnd);

    fetchAnalyticsData();
  }

  void search() {
    final allItems = analyticsItems.value;
    final logIdFilter = logIdController.text.trim().toLowerCase();
    final nameFilter = applicantNameController.text.trim().toLowerCase();

    if (logIdFilter.isEmpty && nameFilter.isEmpty) {
      fetchAnalyticsData();
      return;
    }

    final filteredItems = allItems.where((item) {
      final matchesLogId = logIdFilter.isEmpty ||
          item.logId.toLowerCase().contains(logIdFilter);
      final matchesName = nameFilter.isEmpty ||
          item.applicantName.toLowerCase().contains(nameFilter);

      return matchesLogId && matchesName;
    }).toList();

    analyticsItems.value = filteredItems;
    hasData.value = filteredItems.isNotEmpty;
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      fetchAnalyticsData();
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      fetchAnalyticsData();
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchAnalyticsData();
    }
  }

  String getPagerInfo() {
    final int start = ((currentPage.value - 1) * itemsPerPage.value) + 1;
    final int end = start + analyticsItems.value.length - 1;
    return "Showing $start-$end of ${totalItems.value} items.";
  }

  String formatDateForDisplay(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
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