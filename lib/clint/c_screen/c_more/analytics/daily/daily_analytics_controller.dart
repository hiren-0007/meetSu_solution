import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class DailyAnalyticsController {
  // Constants
  static const List<String> _shifts = [
    'Select',
    'AM-10:00 to 18:00',
    'AM-07:30 to 15:30',
    'PM-15:30 to 23:30',
    'NS-23:30 to 07:30',
    'No shift assigned'
  ];

  // Private fields
  final ApiService _apiService;
  DateTime _selectedDate = DateTime.now();
  List<AnalyticsItem> _allApiData = [];
  String? _lastFetchedDate;

  // Controllers
  final TextEditingController dateController = TextEditingController();

  // State notifiers
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> hasData = ValueNotifier<bool>(false);
  final ValueNotifier<String> selectedShift = ValueNotifier<String>('Select');
  final ValueNotifier<List<AnalyticsItem>> analyticsItems = ValueNotifier<List<AnalyticsItem>>([]);
  final ValueNotifier<Map<String, List<AnalyticsItem>>> groupedItems = ValueNotifier<Map<String, List<AnalyticsItem>>>({});
  final ValueNotifier<int> maleCount = ValueNotifier<int>(0);
  final ValueNotifier<int> femaleCount = ValueNotifier<int>(0);

  // Public getters
  List<String> get shifts => _shifts;
  int get totalCount => maleCount.value + femaleCount.value;

  DailyAnalyticsController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    _initialize();
  }

  void _initialize() {
    _setupAuthentication();
    _setInitialDate();
    fetchAnalyticsData();
    _logInitialization();
  }

  void _setupAuthentication() {
    final token = SharedPrefsService.instance.getAccessToken();
    if (token?.isNotEmpty == true) {
      _apiService.client.addAuthToken(token!);
    }
  }

  void _setInitialDate() {
    dateController.text = DateFormat('MMM dd, yyyy').format(_selectedDate);
  }

  void _logInitialization() {
    debugPrint("🔄 Daily Analytics Controller initialized");
  }

  Future<void> fetchAnalyticsData() async {
    if (_isAlreadyFetching()) return;

    try {
      _setLoadingState(true);
      final formattedDate = _getFormattedDate();

      debugPrint("🔄 Fetching analytics data for: $formattedDate");

      final response = await _apiService.getWeeklyReport(formattedDate, formattedDate);
      final apiData = _extractDataFromResponse(response);

      if (apiData.isNotEmpty) {
        await _processApiData(apiData);
        _lastFetchedDate = formattedDate;
        debugPrint("✅ Successfully fetched ${_allApiData.length} employees");
      } else {
        _clearData();
        debugPrint("⚠️ No data found in API response");
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoadingState(false);
    }
  }

  bool _isAlreadyFetching() {
    return isLoading.value;
  }

  void _setLoadingState(bool loading) {
    isLoading.value = loading;
    if (loading) {
      errorMessage.value = null;
    }
  }

  String _getFormattedDate() {
    return DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  List<dynamic> _extractDataFromResponse(Map<String, dynamic> response) {
    debugPrint("📊 Processing API response");

    List<dynamic> apiData = [];

    if (response.containsKey('body')) {
      apiData = _extractFromBody(response['body']);
      if (apiData.isNotEmpty) {
        debugPrint("📊 Found ${apiData.length} records in 'body' key");
        return apiData;
      }
    }

    if (response.containsKey('data') && response['data'] is List) {
      apiData = response['data'] as List<dynamic>;
      debugPrint("📊 Found ${apiData.length} records in 'data' key");
      return apiData;
    }

    if (_isSuccessResponse(response)) {
      final data = response['data'];
      if (data is List) {
        apiData = data;
        debugPrint("📊 Found ${apiData.length} records in success response");
        return apiData;
      }
    }

    apiData = _findListInResponse(response);
    if (apiData.isNotEmpty) {
      debugPrint("📊 Found ${apiData.length} records in response values");
    }

    return apiData;
  }

  List<dynamic> _extractFromBody(dynamic body) {
    if (body is List) {
      return body;
    } else if (body is String) {
      try {
        final parsedBody = json.decode(body);
        return parsedBody is List ? parsedBody : [];
      } catch (e) {
        debugPrint("❌ Error parsing body string: $e");
        return [];
      }
    }
    return [];
  }

  bool _isSuccessResponse(Map<String, dynamic> response) {
    return response['success'] == true || response['status'] == 'success';
  }

  List<dynamic> _findListInResponse(Map<String, dynamic> response) {
    for (var value in response.values) {
      if (value is List) {
        return value;
      }
    }
    return [];
  }

  Future<void> _processApiData(List<dynamic> apiData) async {
    _allApiData.clear();

    for (int i = 0; i < apiData.length; i++) {
      final itemMap = apiData[i] as Map<String, dynamic>;
      final analyticsItem = _createAnalyticsItem(itemMap, i + 1);
      _allApiData.add(analyticsItem);
    }

    _applyFilters();
  }

  AnalyticsItem _createAnalyticsItem(Map<String, dynamic> itemMap, int index) {
    final name = itemMap['applicantName']?.toString() ?? '';
    final shift = itemMap['shift']?.toString() ?? '';

    return AnalyticsItem(
      id: index.toString(),
      empId: itemMap['logId']?.toString() ?? '',
      name: name,
      position: _extractPosition(shift),
      gender: _determineGender(name),
      shift: shift,
      date: itemMap['date']?.toString() ?? '',
      checkIn: itemMap['clockIn']?.toString() ?? '',
      checkOut: itemMap['clockOut']?.toString() ?? '',
      totalHours: itemMap['totalHours']?.toString() ?? '0',
    );
  }

  void _clearData() {
    _allApiData.clear();
    analyticsItems.value = [];
    groupedItems.value = {};
    hasData.value = false;
    _resetCounts();
  }

  void _resetCounts() {
    maleCount.value = 0;
    femaleCount.value = 0;
  }

  void _handleError(Object error) {
    errorMessage.value = "Failed to load data: ${error.toString()}";
    hasData.value = false;
    _clearData();
    debugPrint("❌ Error fetching analytics: $error");
  }

  void _applyFilters() {
    List<AnalyticsItem> filteredData = _getFilteredData();
    _updateCounts(filteredData);
    _updateDataState(filteredData);
    _logFilterResults(filteredData);
  }

  List<AnalyticsItem> _getFilteredData() {
    List<AnalyticsItem> filteredData = List.from(_allApiData);

    if (selectedShift.value != 'Select') {
      filteredData = filteredData.where((item) {
        return _matchesShiftFilter(item.shift, selectedShift.value);
      }).toList();
    }

    return filteredData;
  }

  void _updateCounts(List<AnalyticsItem> filteredData) {
    int maleCounter = 0;
    int femaleCounter = 0;

    for (var item in filteredData) {
      if (item.gender == 'Male') {
        maleCounter++;
      } else {
        femaleCounter++;
      }
    }

    maleCount.value = maleCounter;
    femaleCount.value = femaleCounter;
  }

  void _updateDataState(List<AnalyticsItem> filteredData) {
    final grouped = _groupItemsByPosition(filteredData);

    analyticsItems.value = filteredData;
    groupedItems.value = grouped;
    hasData.value = filteredData.isNotEmpty;
  }

  Map<String, List<AnalyticsItem>> _groupItemsByPosition(List<AnalyticsItem> items) {
    final Map<String, List<AnalyticsItem>> grouped = {};

    for (var item in items) {
      final position = item.position.isEmpty ? 'No Position' : item.position;
      grouped.putIfAbsent(position, () => []).add(item);
    }

    return grouped;
  }

  void _logFilterResults(List<AnalyticsItem> filteredData) {
    debugPrint("📊 Applied filters: ${filteredData.length} items, "
        "Male: ${maleCount.value}, Female: ${femaleCount.value}");
  }

  bool _matchesShiftFilter(String itemShift, String filterShift) {
    final shiftMatchers = {
      'AM-10:00 to 18:00': () => itemShift.contains('10:00') && itemShift.contains('18:00'),
      'AM-07:30 to 15:30': () => itemShift.contains('07:30') && itemShift.contains('15:30'),
      'PM-15:30 to 23:30': () => itemShift.contains('15:30') && itemShift.contains('23:30'),
      'NS-23:30 to 07:30': () => itemShift.contains('23:30') && itemShift.contains('07:30'),
      'No shift assigned': () => itemShift.isEmpty || itemShift.toLowerCase().contains('no shift'),
    };

    return shiftMatchers[filterShift]?.call() ?? true;
  }

  String _determineGender(String name) {
    if (name.isEmpty) return 'Male';

    final lowerName = name.toLowerCase();

    final femaleIndicators = [
      'sharon', 'michelle', 'norelyn', 'kaur', 'roopkaran',
      'priya', 'maya', 'sara', 'rita', 'sita'
    ];

    if (femaleIndicators.any((indicator) => lowerName.contains(indicator))) {
      return 'Female';
    }

    return 'Male';
  }

  String _extractPosition(String shift) {
    if (shift.contains('10:00') || shift.toLowerCase().contains('office')) {
      return 'Office Help';
    } else if (shift.contains('07:30') || shift.toLowerCase().contains('door')) {
      return 'Door Monitor';
    }
    return '';
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      _selectedDate = picked;
      dateController.text = DateFormat('MMM dd, yyyy').format(picked);
      debugPrint("📅 Date selected: ${DateFormat('yyyy-MM-dd').format(picked)}");
    }
  }

  void updateShift(String? newShift) {
    if (newShift != null && newShift != selectedShift.value) {
      selectedShift.value = newShift;
      debugPrint("🔄 Shift updated to: $newShift");
    }
  }

  void clearDate() {
    _selectedDate = DateTime.now();
    dateController.text = '';
    debugPrint("🗑️ Date cleared, reset to current date");
  }

  Future<void> performSearch() async {
    debugPrint("🔍 Performing search:");
    debugPrint("📅 Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}");
    debugPrint("🕐 Shift: ${selectedShift.value}");

    final currentDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    if (_shouldRefetchData(currentDateStr)) {
      await fetchAnalyticsData();
    } else {
      _applyFilters();
    }
  }

  bool _shouldRefetchData(String newDate) {
    return _allApiData.isEmpty || _lastFetchedDate != newDate;
  }

  String getTotalCountString() {
    return '${maleCount.value} + ${femaleCount.value} = ${totalCount}';
  }

  void dispose() {
    debugPrint("🧹 Disposing DailyAnalyticsController");

    isLoading.dispose();
    errorMessage.dispose();
    hasData.dispose();
    selectedShift.dispose();
    analyticsItems.dispose();
    groupedItems.dispose();
    maleCount.dispose();
    femaleCount.dispose();
    dateController.dispose();
  }
}

class AnalyticsItem {
  final String id;
  final String empId;
  final String name;
  final String position;
  final String gender;
  final String shift;
  final String date;
  final String checkIn;
  final String checkOut;
  final String totalHours;

  const AnalyticsItem({
    required this.id,
    required this.empId,
    required this.name,
    required this.position,
    required this.gender,
    required this.shift,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.totalHours,
  });

  factory AnalyticsItem.fromJson(Map<String, dynamic> json, int index) {
    final name = json['applicantName']?.toString() ?? '';
    final shift = json['shift']?.toString() ?? '';

    return AnalyticsItem(
      id: index.toString(),
      empId: json['logId']?.toString() ?? '',
      name: name,
      position: _extractPositionFromShift(shift),
      gender: _determineGenderFromName(name),
      shift: shift,
      date: json['date']?.toString() ?? '',
      checkIn: json['clockIn']?.toString() ?? '',
      checkOut: json['clockOut']?.toString() ?? '',
      totalHours: json['totalHours']?.toString() ?? '0',
    );
  }

  static String _extractPositionFromShift(String shift) {
    if (shift.contains('10:00') || shift.toLowerCase().contains('office')) {
      return 'Office Help';
    } else if (shift.contains('07:30') || shift.toLowerCase().contains('door')) {
      return 'Door Monitor';
    }
    return '';
  }

  static String _determineGenderFromName(String name) {
    if (name.isEmpty) return 'Male';

    final lowerName = name.toLowerCase();
    final femaleIndicators = [
      'sharon', 'michelle', 'norelyn', 'kaur', 'roopkaran'
    ];

    return femaleIndicators.any((indicator) => lowerName.contains(indicator))
        ? 'Female'
        : 'Male';
  }

  bool get hasPosition => position.isNotEmpty;
  bool get isMale => gender == 'Male';
  bool get isFemale => gender == 'Female';

  @override
  String toString() {
    return 'AnalyticsItem(id: $id, empId: $empId, name: $name, position: $position, gender: $gender)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyticsItem &&
        other.id == id &&
        other.empId == empId;
  }

  @override
  int get hashCode => Object.hash(id, empId);
}