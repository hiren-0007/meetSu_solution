import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // Options for dropdowns - fetched from API
  final ValueNotifier<List<Map<String, dynamic>>> shiftOptions = ValueNotifier<List<Map<String, dynamic>>>([]);
  final ValueNotifier<List<Map<String, dynamic>>> positionOptions = ValueNotifier<List<Map<String, dynamic>>>([]);

  final ValueNotifier<List<String>> typeOptions = ValueNotifier<List<String>>([
    'Male',
    'Female',
    'Any',
  ]);

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

  bool isValidRequest() {
    return selectedShift.value != null &&
        selectedPosition.value != null &&
        selectedType.value != null &&
        numberOfPersons.value > 0;
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

      debugPrint("🔄 Sending job request...");

      // Prepare job request data
      final jobRequestData = {
        'shift_id': selectedShift.value,
        'position_id': selectedPosition.value,
        'no_of_persons': numberOfPersons.value.toString(),
        'date': DateFormat('yyyy-MM-dd').format(selectedDate.value),
        'gender': selectedType.value,
      };

      debugPrint("📤 Job request data: $jobRequestData");

      // Call the API
      final response = await _apiService.createJobRequest(jobRequestData);

      debugPrint("📥 API Response: $response");

      if (response['success'] == true) {
        // Reset form after successful submission
        selectedShift.value = null;
        selectedPosition.value = null;
        selectedType.value = null;
        numberOfPersons.value = 0;
        selectedDate.value = DateTime.now();

        debugPrint("✅ Job request submitted successfully");
      } else {
        // Handle API error response
        final errorMsg = response['message'] ?? 'Failed to submit job request';
        errorMessage.value = errorMsg;
        debugPrint("❌ API Error: $errorMsg");
      }

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

      debugPrint("🔄 Fetching shifts and positions data...");

      // Fetch shifts and positions from API
      await Future.wait([
        fetchShifts(),
        fetchPositions(),
      ]);

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

  Future<void> fetchShifts() async {
    try {
      debugPrint("🔄 Fetching shifts from API...");

      final response = await _apiService.getClintShift();

      if (response['success'] == true && response['data'] != null) {
        final Map<String, dynamic> shiftsData = response['data'];
        List<Map<String, dynamic>> shifts = [];

        shiftsData.forEach((key, value) {
          shifts.add({
            'id': key,
            'name': value,
            'display': value,
          });
        });

        shiftOptions.value = shifts;
        debugPrint("✅ Shifts loaded: ${shifts.length} shifts");
      } else {
        throw Exception("Invalid response format for shifts");
      }
    } catch (e) {
      debugPrint("❌ Error fetching shifts: $e");
      // Fallback to default shifts if API fails
      shiftOptions.value = [
        {'id': '0', 'name': 'AM-10:00 to 18:00', 'display': 'AM-10:00 to 18:00'},
        {'id': '1', 'name': 'AM-07:30 to 15:30', 'display': 'AM-07:30 to 15:30'},
        {'id': '2', 'name': 'PM-15:30 to 23:30', 'display': 'PM-15:30 to 23:30'},
        {'id': '3', 'name': 'NS-23:30 to 07:30', 'display': 'NS-23:30 to 07:30'},
        {'id': '35', 'name': 'No shift assigned', 'display': 'No shift assigned'},
      ];
    }
  }

  Future<void> fetchPositions() async {
    try {
      debugPrint("🔄 Fetching positions from API...");

      final response = await _apiService.getClintPositions();

      if (response['success'] == true && response['data'] != null) {
        final Map<String, dynamic> positionsData = response['data'];
        List<Map<String, dynamic>> positions = [];

        positionsData.forEach((key, value) {
          positions.add({
            'id': key,
            'name': value,
            'display': value,
          });
        });

        positionOptions.value = positions;
        debugPrint("✅ Positions loaded: ${positions.length} positions");
      } else {
        throw Exception("Invalid response format for positions");
      }
    } catch (e) {
      debugPrint("❌ Error fetching positions: $e");
      // Fallback to default positions if API fails
      positionOptions.value = [
        {'id': '22', 'name': 'Office Help', 'display': 'Office Help'},
        {'id': '16', 'name': 'Office Cleaner', 'display': 'Office Cleaner'},
        {'id': '39', 'name': 'Door Monitor', 'display': 'Door Monitor'},
        {'id': '43', 'name': 'Outside Associate', 'display': 'Outside Associate'},
      ];
    }
  }

  void dispose() {
    debugPrint("🧹 Disposing ClintSendJobRequestController resources");
    isLoading.dispose();
    errorMessage.dispose();
    hasData.dispose();
    selectedShift.dispose();
    selectedDate.dispose();
    selectedPosition.dispose();
    numberOfPersons.dispose();
    selectedType.dispose();
    shiftOptions.dispose();
    positionOptions.dispose();
    typeOptions.dispose();
  }
}