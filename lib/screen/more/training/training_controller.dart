import 'package:flutter/material.dart';
import 'package:meetsu_solutions/model/training/assigned_training_response_model.dart';
import 'package:meetsu_solutions/model/training/completed_training_response_model.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

// Model class based on response model
class Training {
  final String id;
  final String clientName;
  final String trainingName;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final String? document;

  Training({
    required this.id,
    required this.clientName,
    required this.trainingName,
    this.description = 'No description available',
    required this.dueDate,
    this.isCompleted = false,
    this.document,
  });
}

class TrainingController {
  // API Service
  final ApiService _apiService;

  // ValueNotifiers for reactive state management
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  // Training data ValueNotifier
  final ValueNotifier<List<Training>> trainingsData = ValueNotifier<List<Training>>([]);

  // Lists of trainings with computed getters
  List<Training> get assignedTrainings => trainingsData.value.where((t) => !t.isCompleted).toList();
  List<Training> get completedTrainings => trainingsData.value.where((t) => t.isCompleted).toList();

  TrainingController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(
      ApiClient(headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      })
  ) {
    // Immediately initialize with token
    _initializeWithToken();
  }

  // Initialize with token from SharedPrefs
  Future<void> _initializeWithToken() async {
    // Get token from SharedPreferences
    final token = SharedPrefsService.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      // Add the authentication token to the API client
      _apiService.client.addAuthToken(token);
      debugPrint('Token set in API client: $token');
    } else {
      debugPrint('No token found in SharedPreferences');
    }
  }

  // Load trainings from API
  Future<void> loadTrainings() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Make sure we have a token before proceeding
      await _initializeWithToken();

      // Load both assigned and completed trainings
      final List<Training> allTrainings = [];

      // Get assigned trainings
      final assignedResponse = await _apiService.getTrainingAssigned();
      debugPrint('Assigned trainings response: $assignedResponse');

      // Parse using the response model class
      final AssignedTrainingResponseModel assignedTrainings =
      AssignedTrainingResponseModel.fromJson(assignedResponse);

      if (assignedTrainings.data != null) {
        for (var item in assignedTrainings.data!) {
          allTrainings.add(Training(
            id: item.trainingId?.toString() ?? '',
            clientName: item.clientName ?? '',
            trainingName: item.trainingName ?? '',
            description: 'Assigned training', // Default description
            dueDate: DateTime.now().add(const Duration(days: 7)), // Default due date
            isCompleted: item.docRead == 1,
          ));
        }
      }

      // Get completed trainings
      final completedResponse = await _apiService.getTrainingCompleted();
      debugPrint('Completed trainings response: $completedResponse');

      // Parse using the response model class
      final CompletedTrainingResponseModel completedTrainings =
      CompletedTrainingResponseModel.fromJson(completedResponse);

      if (completedTrainings.data != null) {
        for (var item in completedTrainings.data!) {
          allTrainings.add(Training(
            id: item.trainingId?.toString() ?? '',
            clientName: item.clientName ?? '',
            trainingName: item.trainingName ?? '',
            description: 'Completed training', // Default description
            dueDate: DateTime.now().subtract(const Duration(days: 1)), // Passed due date
            isCompleted: true, // Always completed
            document: item.document,
          ));
        }
      }

      // Update the ValueNotifier with parsed data
      trainingsData.value = allTrainings;
      errorMessage.value = null;
    } catch (e) {
      debugPrint('Error loading trainings: $e');
      errorMessage.value = "Failed to load trainings: ${e.toString()}";
      // For development, you may still want to load mock data if the API fails
      _loadMockTrainingData();
    } finally {
      isLoading.value = false;
    }
  }

  // Load mock training data in case API fails
  void _loadMockTrainingData() {
    debugPrint('Loading mock training data due to API failure');
    trainingsData.value = [
      Training(
        id: "1",
        clientName: "ABC Corporation",
        trainingName: "Safety Procedures",
        description: "Learn about workplace safety procedures and protocols",
        dueDate: DateTime.now().add(const Duration(days: 5)),
        isCompleted: false,
      ),
      Training(
        id: "2",
        clientName: "XYZ Industries",
        trainingName: "Customer Service Training",
        description: "Enhance your customer service skills and best practices",
        dueDate: DateTime.now().add(const Duration(days: 10)),
        isCompleted: false,
      ),
      Training(
        id: "3",
        clientName: "Tech Innovators",
        trainingName: "Flutter Development",
        description: "Advanced Flutter development techniques",
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        isCompleted: true,
        document: "Tech_Flutter_Development.pdf",
      ),
    ];
  }

  // View training details
  void viewTraining(BuildContext context, Training training) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(training.trainingName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoRow("Client:", training.clientName),
                const SizedBox(height: 8),
                _buildInfoRow("Due Date:", "${training.dueDate.day}/${training.dueDate.month}/${training.dueDate.year}"),
                const SizedBox(height: 8),
                _buildInfoRow("Status:", training.isCompleted ? "Completed" : "Pending"),
                if (training.document != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow("Document:", training.document!),
                ],
                const SizedBox(height: 16),
                const Text(
                  "Description:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(training.description),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            if (!training.isCompleted)
              TextButton(
                child: const Text("Mark as Completed"),
                onPressed: () {
                  Navigator.of(context).pop();
                  markAsCompleted(context, training);
                },
              ),
          ],
        );
      },
    );
  }

  // Mark training as completed
  void markAsCompleted(BuildContext context, Training training) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Complete Training"),
          content: Text("Are you sure you want to mark '${training.trainingName}' as completed?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Complete"),
              onPressed: () async {
                Navigator.of(context).pop();

                // Show loading indicator
                isLoading.value = true;

                try {
                  // Call API to mark training as completed
                  final success = await markTrainingCompleted(training.id);

                  if (success) {
                    // Update local list if API call succeeds
                    final updatedTrainings = List<Training>.from(trainingsData.value);
                    final index = updatedTrainings.indexWhere((t) => t.id == training.id);

                    if (index >= 0) {
                      final updatedTraining = Training(
                        id: training.id,
                        clientName: training.clientName,
                        trainingName: training.trainingName,
                        description: training.description,
                        dueDate: training.dueDate,
                        isCompleted: true,
                        document: "completed_${training.id}.pdf", // Example document name
                      );

                      updatedTrainings[index] = updatedTraining;
                      trainingsData.value = updatedTrainings;
                    }

                    // Show success message
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Training marked as completed"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    // Show error message
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Failed to mark training as completed: ${errorMessage.value}"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  // Show error message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to mark training as completed: ${e.toString()}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  // Hide loading indicator
                  isLoading.value = false;
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Helper method for building info rows
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  // Future to mark training as completed via API
  Future<bool> markTrainingCompleted(String trainingId) async {
    try {
      // Make sure we have a token before proceeding
      await _initializeWithToken();

      // You need to implement this API endpoint
      // For now, we'll simulate a successful response
      await Future.delayed(const Duration(seconds: 1));

      // In a real implementation, you would call something like:
      // await _apiService.markTrainingAsCompleted(trainingId);

      errorMessage.value = null;
      return true;
    } catch (e) {
      errorMessage.value = "Failed to mark training as completed: ${e.toString()}";
      return false;
    }
  }

  // Clean up resources
  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
    trainingsData.dispose();
  }
}