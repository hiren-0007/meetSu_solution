import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class ClintSendJobRequestController {
  final ApiService _apiService;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> hasData = ValueNotifier<bool>(false);

  // Form fields
  final ValueNotifier<String?> selectedShift = ValueNotifier<String?>(null);
  final ValueNotifier<DateTime> selectedDate = ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<String?> selectedPosition = ValueNotifier<String?>(null);
  final ValueNotifier<int> numberOfPersons = ValueNotifier<int>(0);
  final ValueNotifier<String?> selectedType = ValueNotifier<String?>(null);

  // Options for dropdowns
  final ValueNotifier<List<String>> shiftOptions = ValueNotifier<List<String>>([
    '10:00 AM to 18:00 PM',
    '07:30 AM to 15:30 PM',
    '15:30 PM to 23:30 PM',
    '23:30 PM to 07:30 AM',
    'No shift assigned'
  ]);

  final ValueNotifier<List<String>> positionOptions = ValueNotifier<List<String>>([
    'Office Help',
    'Office Cleaner',
    'Door Monitor',
    'Outside Associate',
  ]);

  final ValueNotifier<List<String>> typeOptions = ValueNotifier<List<String>>([
    'Male',
    'Female',
    'Any',
  ]);

  // List of job requests
  final ValueNotifier<List<Map<String, dynamic>>> jobRequests = ValueNotifier<List<Map<String, dynamic>>>([]);

  ClintSendJobRequestController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    initialize();
  }

  void initialize() {
    final token = SharedPrefsService.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _apiService.client.addAuthToken(token);
    }

    debugPrint("🔄 Initializing Client Send Job Request Controller...");
    fetchDashboardData();
  }

  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  void setNumberOfPersons(int number) {
    numberOfPersons.value = number;
  }

  void addMoreRequest() {
    if (isValidRequest()) {
      jobRequests.value = [...jobRequests.value, getCurrentRequestData()];

      selectedShift.value = null;
      selectedPosition.value = null;
      selectedType.value = null;
      numberOfPersons.value = 0;

      debugPrint("✅ Added new job request. Total: ${jobRequests.value.length}");
    } else {
      errorMessage.value = "Please fill all required fields before adding more";
      debugPrint("❌ Cannot add incomplete job request");
    }
  }

  bool isValidRequest() {
    return selectedShift.value != null &&
        selectedPosition.value != null &&
        selectedType.value != null &&
        numberOfPersons.value > 0;
  }

  Map<String, dynamic> getCurrentRequestData() {
    return {
      'shift': selectedShift.value,
      'date': selectedDate.value,
      'position': selectedPosition.value,
      'numberOfPersons': numberOfPersons.value,
      'type': selectedType.value,
    };
  }

  Future<void> sendJobRequest() async {
    if (!isValidRequest()) {
      errorMessage.value = "Please fill all required fields";
      debugPrint("❌ Invalid job request form");
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;

      if (jobRequests.value.isEmpty) {
        jobRequests.value = [getCurrentRequestData()];
      } else if (isValidRequest()) {
        jobRequests.value = [...jobRequests.value, getCurrentRequestData()];
      }

      debugPrint("🔄 Sending job request(s): ${jobRequests.value.length}");

      // Simulating API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Reset form after successful submission
      selectedShift.value = null;
      selectedPosition.value = null;
      selectedType.value = null;
      numberOfPersons.value = 0;
      jobRequests.value = [];

      debugPrint("✅ Job request(s) submitted successfully");


    } catch (e) {
      errorMessage.value = "Failed to submit job request: ${e.toString()}";
      debugPrint("❌ Error submitting job request: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      debugPrint("🔄 Fetching form options data...");

      await Future.delayed(const Duration(seconds: 1));

      hasData.value = true;
      debugPrint("✅ Form options loaded successfully");
    } catch (e) {
      errorMessage.value = "Failed to load form options: ${e.toString()}";
      hasData.value = false;
      debugPrint("❌ Error fetching form options: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    debugPrint("🧹 Disposing ClintSendJobRequestController resources");
    isLoading.dispose();
    errorMessage.dispose();
    hasData.dispose();

    // Dispose form field notifiers
    selectedShift.dispose();
    selectedDate.dispose();
    selectedPosition.dispose();
    numberOfPersons.dispose();
    selectedType.dispose();

    // Dispose options notifiers
    shiftOptions.dispose();
    positionOptions.dispose();
    typeOptions.dispose();

    // Dispose job requests notifier
    jobRequests.dispose();
  }
}