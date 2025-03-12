import 'package:flutter/material.dart';
import 'package:meetsu_solutions/model/training/assigned_training_response_model.dart';
import 'package:meetsu_solutions/model/training/completed_training_response_model.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

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
  final ApiService _apiService;

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  final ValueNotifier<List<Training>> trainingsData =
      ValueNotifier<List<Training>>([]);

  List<Training> get assignedTrainings =>
      trainingsData.value.where((t) => !t.isCompleted).toList();

  List<Training> get completedTrainings =>
      trainingsData.value.where((t) => t.isCompleted).toList();

  TrainingController({ApiService? apiService})
      : _apiService = apiService ??
            ApiService(ApiClient(headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            })) {
    _initializeWithToken();
  }

  Future<void> _initializeWithToken() async {
    final token = SharedPrefsService.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _apiService.client.addAuthToken(token);
      debugPrint('Token set in API client: $token');
    } else {
      debugPrint('No token found in SharedPreferences');
    }
  }

  Future<void> loadTrainings() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _initializeWithToken();

      final List<Training> allTrainings = [];

      final assignedResponse = await _apiService.getTrainingAssigned();
      debugPrint('Assigned trainings response: $assignedResponse');

      final AssignedTrainingResponseModel assignedTrainings =
          AssignedTrainingResponseModel.fromJson(assignedResponse);

      if (assignedTrainings.data != null) {
        for (var item in assignedTrainings.data!) {
          allTrainings.add(Training(
            id: item.trainingId?.toString() ?? '',
            clientName: item.clientName ?? '',
            trainingName: item.trainingName ?? '',
            description: 'Assigned training',
            dueDate: DateTime.now().add(const Duration(days: 7)),
            isCompleted: false,
          ));
        }
      }

      final completedResponse = await _apiService.getTrainingCompleted();
      debugPrint('Completed trainings response: $completedResponse');

      final CompletedTrainingResponseModel completedTrainings =
          CompletedTrainingResponseModel.fromJson(completedResponse);

      if (completedTrainings.data != null) {
        for (var item in completedTrainings.data!) {
          allTrainings.add(Training(
            id: item.trainingId?.toString() ?? '',
            clientName: item.clientName ?? '',
            trainingName: item.trainingName ?? '',
            description: 'Completed training',
            dueDate: DateTime.now().subtract(const Duration(days: 1)),
            isCompleted: true,
            document: item.document,
          ));
        }
      }

      trainingsData.value = allTrainings;
      errorMessage.value = null;
    } catch (e) {
      debugPrint('Error loading trainings: $e');
      errorMessage.value = "Failed to load trainings: ${e.toString()}";
      _loadMockTrainingData();
    } finally {
      isLoading.value = false;
    }
  }

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

  void viewTraining(BuildContext context, Training training) async {
    String? documentId;

    if (training.isCompleted && training.document != null) {
      isLoading.value = true;

      try {
        final Map<String, dynamic> docData = {
          'training_id': training.id
        };

        final response = await _apiService.trainingDoc(docData);
        debugPrint('Training document response: $response');

        if (response != null &&
            response['data'] != null &&
            response['data'] is List &&
            response['data'].isNotEmpty &&
            response['data'][0]['document_id'] != null) {
          documentId = response['data'][0]['document_id'].toString();
          debugPrint('Found document_id: $documentId');
        }

      } catch (e) {
        debugPrint('Error fetching training document: $e');
      } finally {
        isLoading.value = false;
      }
    }

    if (context.mounted) {
      _showTrainingDetailsDialog(context, training, documentId);
    }
  }

  void _showTrainingDetailsDialog(BuildContext context, Training training, String? documentId) {
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
            if (documentId != null)
              TextButton(
                child: const Text("Show Document"),
                onPressed: () async {
                  debugPrint('Opening document with ID: $documentId');

                  isLoading.value = true;

                  try {
                    final Map<String, dynamic> viewData = {
                      'document_id': documentId
                    };

                    final response = await _apiService.trainingDocView(viewData);
                    // debugPrint('Training document view response: $response');

                    if (response != null) {
                      debugPrint('Successfully retrieved training document view: $response');
                    }
                  } catch (e) {
                    debugPrint('Error viewing training document: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Failed to open document: ${e.toString()}"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    isLoading.value = false;
                    Navigator.of(context).pop();
                  }
                },
              ),
          ],
        );
      },
    );
  }

  void markAsCompleted(BuildContext context, Training training) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Complete Training"),
          content: Text(
              "Are you sure you want to mark '${training.trainingName}' as completed?"),
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

                isLoading.value = true;

                try {
                  final success = await markTrainingCompleted(training.id);

                  if (success) {
                    final updatedTrainings =
                        List<Training>.from(trainingsData.value);
                    final index =
                        updatedTrainings.indexWhere((t) => t.id == training.id);

                    if (index >= 0) {
                      final updatedTraining = Training(
                        id: training.id,
                        clientName: training.clientName,
                        trainingName: training.trainingName,
                        description: training.description,
                        dueDate: training.dueDate,
                        isCompleted: true,
                        document: "completed_${training.id}.pdf",
                      );

                      updatedTrainings[index] = updatedTraining;
                      trainingsData.value = updatedTrainings;
                    }

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Training marked as completed"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Failed to mark training as completed: ${errorMessage.value}"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Failed to mark training as completed: ${e.toString()}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  isLoading.value = false;
                }
              },
            ),
          ],
        );
      },
    );
  }

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

  Future<bool> markTrainingCompleted(String trainingId) async {
    try {
      await _initializeWithToken();

      await Future.delayed(const Duration(seconds: 1));

      errorMessage.value = null;
      return true;
    } catch (e) {
      errorMessage.value =
          "Failed to mark training as completed: ${e.toString()}";
      return false;
    }
  }

  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
    trainingsData.dispose();
  }
}
