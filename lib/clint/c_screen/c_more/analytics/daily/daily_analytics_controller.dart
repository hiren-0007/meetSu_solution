import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class DailyAnalyticsController {
  final ApiService _apiService;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> hasData = ValueNotifier<bool>(false);

  // Date controller
  final TextEditingController dateController = TextEditingController();
  final DateTime _selectedDate = DateTime.now();

  // Dropdown controller
  final List<String> shifts = [
    'Select',
    'AM-10:00 to 18:00',
    'AM-07:30 to 15:30',
    'PM-15:30 to 23:30',
    'NS-23:30 to 07:30',
    'No shift assigned'
  ];
  String selectedShift = 'Select';

  // Gender counts for analytics
  int maleCount = 3;
  int femaleCount = 5;

  // Analytics data
  final ValueNotifier<List<AnalyticsItem>> analyticsItems = ValueNotifier<List<AnalyticsItem>>([]);

  DailyAnalyticsController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    initialize();
  }

  void initialize() {
    final token = SharedPrefsService.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _apiService.client.addAuthToken(token);
    }

    // Set current date to date controller
    dateController.text = DateFormat('MMM dd, yyyy').format(_selectedDate);

    debugPrint("🔄 Initializing Daily Analytics Controller...");

    // Load initial data
    fetchAnalyticsData();
  }

  Future<void> fetchAnalyticsData() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      debugPrint("🔄 Fetching daily analytics data...");

      // Simulate API call with demo data
      await Future.delayed(const Duration(seconds: 1));

      // Mock data based on the image
      final List<AnalyticsItem> items = [
        AnalyticsItem(
            id: '1',
            empId: '5345',
            name: 'JOY BUENCAMINO',
            position: 'Office Help',
            gender: 'Male',
            count: 3
        ),
        AnalyticsItem(
            id: '2',
            empId: '42921',
            name: 'ROOPKARAN KAUR DHILLON',
            position: '',
            gender: 'Female',
            count: 4
        ),
        AnalyticsItem(
            id: '3',
            empId: '44382',
            name: 'SHARON PILA',
            position: 'Door Monitor',
            gender: 'Female',
            count: 5
        ),
        AnalyticsItem(
            id: '4',
            empId: '26670',
            name: 'MICHELLE MONTIEL',
            position: '',
            gender: 'Female',
            count: 1
        ),
        AnalyticsItem(
            id: '5',
            empId: '30482',
            name: 'NORELYN ESPIRITU',
            position: 'Office Help',
            gender: 'Female',
            count: 3
        ),
        AnalyticsItem(
            id: '6',
            empId: '14476',
            name: 'HIREN PANCHAL',
            position: '',
            gender: 'Male',
            count: 2
        ),
        AnalyticsItem(
            id: '7',
            empId: '1638',
            name: 'REGENOLD CHRISTIAN',
            position: 'Door Monitor',
            gender: 'Male',
            count: 3
        ),
        AnalyticsItem(
            id: '8',
            empId: '47007',
            name: 'SHUBHAM KHOSLA',
            position: '',
            gender: 'Male',
            count: 0
        ),
      ];

      analyticsItems.value = items;
      hasData.value = true;
      debugPrint("✅ Daily analytics data fetched successfully");
    } catch (e) {
      errorMessage.value = "Failed to load data: ${e.toString()}";
      hasData.value = false;
      debugPrint("❌ Error fetching daily analytics data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Function to show date picker
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      dateController.text = DateFormat('MMM dd, yyyy').format(picked);
      fetchAnalyticsData(); // Reload data with new date
    }
  }

  // Function to update selected shift
  void updateShift(String? newShift) {
    if (newShift != null && newShift != selectedShift) {
      selectedShift = newShift;
      fetchAnalyticsData(); // Reload data with new shift
    }
  }

  // Function to clear date
  void clearDate() {
    dateController.text = '';
    fetchAnalyticsData(); // Reload data with cleared date
  }

  // Function to navigate back
  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Calculate total values
  String getTotalCount() {
    return '$maleCount + $femaleCount = ${maleCount + femaleCount}';
  }

  // Get gender counts
  int getMaleCount() => maleCount;
  int getFemaleCount() => femaleCount;
  int getTotalPeople() => maleCount + femaleCount;

  void dispose() {
    debugPrint("🧹 Disposing DailyAnalyticsController resources");
    isLoading.dispose();
    errorMessage.dispose();
    hasData.dispose();
    dateController.dispose();
    analyticsItems.dispose();
  }
}

class AnalyticsItem {
  final String id;
  final String empId;
  final String name;
  final String position;
  final String gender;
  final int count;

  AnalyticsItem({
    required this.id,
    required this.empId,
    required this.name,
    required this.position,
    required this.gender,
    required this.count
  });
}