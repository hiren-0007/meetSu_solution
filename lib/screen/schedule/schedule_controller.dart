import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/model/schedule/schedule_response_model.dart';

class ScheduleController {
  static const Duration _apiTimeout = Duration(seconds: 30);
  static const int _periodDurationDays = 14;
  static final DateTime _referencePeriodStart = DateTime(2025, 4, 14);

  final ApiService _apiService;

  // Cache for better performance
  String? _cachedToken;
  DateTime? _lastFetchTime;
  static const Duration _cacheValidityDuration = Duration(minutes: 5);

  final List<Map<String, String>> _standardPeriods = [
    {'start': 'Apr-14-2025', 'end': 'Apr-27-2025'},
    {'start': 'Apr-28-2025', 'end': 'May-11-2025'},
    {'start': 'May-12-2025', 'end': 'May-25-2025'},
    {'start': 'May-26-2025', 'end': 'Jun-08-2025'},
  ];

  // ValueNotifiers for reactive UI
  final ValueNotifier<String> startDate = ValueNotifier<String>('');
  final ValueNotifier<String> endDate = ValueNotifier<String>('');
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> hasData = ValueNotifier<bool>(false);
  final ValueNotifier<List<Data>> scheduleItems = ValueNotifier<List<Data>>([]);
  final ValueNotifier<String?> payCheck = ValueNotifier<String?>(null);
  final ValueNotifier<bool> usingStandardPeriods = ValueNotifier<bool>(true);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  ScheduleController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    _initializeController();
  }

  void _initializeController() {
    _cacheAuthToken();
    _setCurrentPeriod();
    _fetchScheduleData(forceRefresh: true);
  }

  void _cacheAuthToken() {
    _cachedToken = SharedPrefsService.instance.getAccessToken();
  }

  // Enhanced date calculation methods
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

  // Optimized period generation
  Map<String, String> _generateEarlierPeriod() {
    DateTime firstStart = _parseDate(_standardPeriods.first['start']!);
    DateTime newStart = firstStart.subtract(const Duration(days: _periodDurationDays));
    DateTime newEnd = newStart.add(const Duration(days: _periodDurationDays - 1));

    return {
      'start': _formatDate(newStart),
      'end': _formatDate(newEnd)
    };
  }

  Map<String, String> _generateLaterPeriod() {
    DateTime lastStart = _parseDate(_standardPeriods.last['start']!);
    DateTime newStart = lastStart.add(const Duration(days: _periodDurationDays));
    DateTime newEnd = newStart.add(const Duration(days: _periodDurationDays - 1));

    return {
      'start': _formatDate(newStart),
      'end': _formatDate(newEnd)
    };
  }

  // Enhanced date selection with validation
  Future<void> selectStartDate(BuildContext context) async {
    try {
      final DateTime currentDate = _parseDate(startDate.value);
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Colors.blue, // Your primary color
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && picked != currentDate) {
        startDate.value = _formatDate(picked);
        final newEndDate = picked.add(const Duration(days: _periodDurationDays - 1));
        endDate.value = _formatDate(newEndDate);

        usingStandardPeriods.value = false;
        await _fetchScheduleData(forceRefresh: true);
      }
    } catch (e) {
      debugPrint('Error selecting start date: $e');
      _setErrorMessage('Failed to select start date');
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    try {
      final DateTime currentDate = _parseDate(endDate.value);
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Colors.blue, // Your primary color
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && picked != currentDate) {
        endDate.value = _formatDate(picked);
        usingStandardPeriods.value = false;
        await _fetchScheduleData(forceRefresh: true);
      }
    } catch (e) {
      debugPrint('Error selecting end date: $e');
      _setErrorMessage('Failed to select end date');
    }
  }

  // Improved period index finding
  int _findCurrentPeriodIndex() {
    final currentStart = _parseDate(startDate.value);

    // First, check exact matches
    for (int i = 0; i < _standardPeriods.length; i++) {
      if (_standardPeriods[i]['start'] == startDate.value) {
        return i;
      }
    }

    // Then check ranges
    for (int i = 0; i < _standardPeriods.length - 1; i++) {
      DateTime periodStart = _parseDate(_standardPeriods[i]['start']!);
      DateTime nextPeriodStart = _parseDate(_standardPeriods[i + 1]['start']!);

      if (currentStart.isAfter(periodStart.subtract(const Duration(days: 1))) &&
          currentStart.isBefore(nextPeriodStart)) {
        return i;
      }
    }

    // Handle boundary cases
    if (currentStart.isBefore(_parseDate(_standardPeriods.first['start']!))) {
      _standardPeriods.insert(0, _generateEarlierPeriod());
      return 0;
    }

    if (currentStart.isAfter(_parseDate(_standardPeriods.last['start']!))) {
      _standardPeriods.add(_generateLaterPeriod());
      return _standardPeriods.length - 1;
    }

    return 0;
  }

  // Enhanced API call with caching and error handling
  Future<void> _fetchScheduleData({bool forceRefresh = false}) async {
    if (isLoading.value) {
      debugPrint("⚠️ Already loading, skipping duplicate call");
      return; // Prevent multiple simultaneous calls
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;

      // Check cache validity (skip cache for navigation)
      if (!forceRefresh &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheValidityDuration) {
        debugPrint('📋 Using cached data');
        isLoading.value = false;
        return;
      }

      // Validate token
      final token = _cachedToken ?? SharedPrefsService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("Authentication required");
      }

      // Update cached token if needed
      if (_cachedToken != token) {
        _cachedToken = token;
      }

      _apiService.client.addAuthToken(token);

      // Validate date range
      if (startDate.value.isEmpty || endDate.value.isEmpty) {
        throw Exception("Invalid date range");
      }

      debugPrint("🔄 Fetching schedule data for ${startDate.value} to ${endDate.value}");

      final response = await _apiService.getSchedule({
        "start_date": startDate.value,
        "end_date": endDate.value
      }).timeout(_apiTimeout);

      await _processScheduleResponse(response);
      _lastFetchTime = DateTime.now();

    } catch (e) {
      debugPrint("❌ Error fetching schedule data: $e");
      _handleFetchError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _processScheduleResponse(Map<String, dynamic> response) async {
    try {
      final scheduleResponse = ScheduleResponseModel.fromJson(response);

      payCheck.value = scheduleResponse.payCheck;

      if (scheduleResponse.data?.isNotEmpty == true) {
        scheduleItems.value = scheduleResponse.data!;
        hasData.value = true;
        debugPrint("✅ Loaded ${scheduleItems.value.length} schedule items");
      } else {
        scheduleItems.value = [];
        hasData.value = false;
        debugPrint("⚠️ No schedule data available");
      }
    } catch (e) {
      debugPrint("❌ Error processing schedule response: $e");
      throw Exception("Failed to process schedule data");
    }
  }

  void _handleFetchError(dynamic error) {
    scheduleItems.value = [];
    hasData.value = false;

    if (error.toString().contains('timeout')) {
      _setErrorMessage('Request timed out. Please try again.');
    } else if (error.toString().contains('Authentication')) {
      _setErrorMessage('Please login again.');
    } else {
      _setErrorMessage('Failed to load schedule data.');
    }
  }

  void _setErrorMessage(String message) {
    errorMessage.value = message;
    // Auto-clear error after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (errorMessage.value == message) {
        errorMessage.value = null;
      }
    });
  }

  // Enhanced date parsing and formatting
  static DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) throw Exception('Invalid date format');

      final month = _getMonthNumberStatic(parts[0]);
      final day = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      debugPrint('Error parsing date: $dateStr - $e');
      return DateTime.now();
    }
  }

  String _formatDate(DateTime date) {
    final month = _getMonthName(date.month);
    return "$month-${date.day.toString().padLeft(2, '0')}-${date.year}";
  }

  static String _formatDateStatic(DateTime date) {
    const monthNames = {
      1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun',
      7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'
    };
    final month = monthNames[date.month] ?? 'Jan';
    return "$month-${date.day.toString().padLeft(2, '0')}-${date.year}";
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

  // Enhanced period setting logic
  void _setCurrentPeriod() {
    final now = DateTime.now();

    // First, check if current date falls within existing periods
    for (int i = 0; i < _standardPeriods.length; i++) {
      DateTime periodStart = _parseDate(_standardPeriods[i]['start']!);
      DateTime periodEnd = _parseDate(_standardPeriods[i]['end']!);

      if (now.isAfter(periodStart.subtract(const Duration(days: 1))) &&
          now.isBefore(periodEnd.add(const Duration(days: 1)))) {
        startDate.value = _standardPeriods[i]['start']!;
        endDate.value = _standardPeriods[i]['end']!;
        return;
      }
    }

    // Calculate period based on reference date
    int periodsPassed = (now.difference(_referencePeriodStart).inDays / _periodDurationDays).floor();
    DateTime currentPeriodStart = _referencePeriodStart.add(Duration(days: periodsPassed * _periodDurationDays));
    DateTime currentPeriodEnd = currentPeriodStart.add(const Duration(days: _periodDurationDays - 1));

    startDate.value = _formatDate(currentPeriodStart);
    endDate.value = _formatDate(currentPeriodEnd);

    // Add to standard periods if not exists
    bool periodExists = _standardPeriods.any((period) =>
    period['start'] == startDate.value && period['end'] == endDate.value);

    if (!periodExists) {
      _standardPeriods.add({
        'start': startDate.value,
        'end': endDate.value
      });

      // Sort periods by start date
      _standardPeriods.sort((a, b) {
        DateTime dateA = _parseDate(a['start']!);
        DateTime dateB = _parseDate(b['start']!);
        return dateA.compareTo(dateB);
      });
    }
  }

  // Enhanced navigation methods
  Future<void> navigateToPreviousPeriod() async {
    try {
      debugPrint("🔄 Navigating to previous period");
      usingStandardPeriods.value = true;
      int currentIndex = _findCurrentPeriodIndex();
      debugPrint("📍 Current period index: $currentIndex");

      if (currentIndex > 0) {
        startDate.value = _standardPeriods[currentIndex - 1]['start']!;
        endDate.value = _standardPeriods[currentIndex - 1]['end']!;
        debugPrint("📅 Set to existing period: ${startDate.value} - ${endDate.value}");
      } else {
        Map<String, String> newPeriod = _generateEarlierPeriod();
        _standardPeriods.insert(0, newPeriod);
        startDate.value = newPeriod['start']!;
        endDate.value = newPeriod['end']!;
        debugPrint("📅 Generated new earlier period: ${startDate.value} - ${endDate.value}");
      }

      debugPrint("🔄 Calling _fetchScheduleData from navigateToPreviousPeriod");
      await _fetchScheduleData(forceRefresh: true);
    } catch (e) {
      debugPrint('❌ Error navigating to previous period: $e');
      _setErrorMessage('Failed to navigate to previous period');
    }
  }

  Future<void> navigateToNextPeriod() async {
    try {
      debugPrint("🔄 Navigating to next period");
      usingStandardPeriods.value = true;
      int currentIndex = _findCurrentPeriodIndex();
      debugPrint("📍 Current period index: $currentIndex");

      if (currentIndex >= 0 && currentIndex < _standardPeriods.length - 1) {
        startDate.value = _standardPeriods[currentIndex + 1]['start']!;
        endDate.value = _standardPeriods[currentIndex + 1]['end']!;
        debugPrint("📅 Set to existing period: ${startDate.value} - ${endDate.value}");
      } else {
        Map<String, String> newPeriod = _generateLaterPeriod();
        _standardPeriods.add(newPeriod);
        startDate.value = newPeriod['start']!;
        endDate.value = newPeriod['end']!;
        debugPrint("📅 Generated new later period: ${startDate.value} - ${endDate.value}");
      }

      debugPrint("🔄 Calling _fetchScheduleData from navigateToNextPeriod");
      await _fetchScheduleData(forceRefresh: true);
    } catch (e) {
      debugPrint('❌ Error navigating to next period: $e');
      _setErrorMessage('Failed to navigate to next period');
    }
  }

  // Retry mechanism
  Future<void> retryFetch() async {
    debugPrint("🔄 Retrying schedule data fetch");
    _cachedToken = null; // Clear cached token
    _lastFetchTime = null; // Clear cache
    _cacheAuthToken();
    await _fetchScheduleData(forceRefresh: true);
  }

  // Calculate total pay efficiently
  double calculateTotalPay() {
    double totalPay = 0;
    for (var item in scheduleItems.value) {
      if (item.totalPay?.isNotEmpty == true) {
        final payString = item.totalPay!.replaceAll('\$', '').replaceAll(',', '');
        try {
          totalPay += double.parse(payString);
        } catch (e) {
          debugPrint('Error parsing pay amount: ${item.totalPay}');
        }
      }
    }
    return totalPay;
  }

  // Enhanced disposal
  void dispose() {
    debugPrint("🧹 Disposing ScheduleController resources");
    startDate.dispose();
    endDate.dispose();
    isLoading.dispose();
    hasData.dispose();
    scheduleItems.dispose();
    payCheck.dispose();
    usingStandardPeriods.dispose();
    errorMessage.dispose();
  }
}