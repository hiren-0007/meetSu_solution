import 'package:flutter/material.dart';

// Model class for Training
class Training {
  final String id;
  final String clientName;
  final String trainingName;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;

  Training({
    required this.id,
    required this.clientName,
    required this.trainingName,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
  });
}

class TrainingController {
  // ValueNotifiers for reactive state management
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  // Lists of trainings
  final List<Training> _allTrainings = [];
  List<Training> get assignedTrainings => _allTrainings.where((t) => !t.isCompleted).toList();
  List<Training> get completedTrainings => _allTrainings.where((t) => t.isCompleted).toList();

  // Load trainings from data source
  Future<void> loadTrainings() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Simulate API call with delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for demonstration
      _allTrainings.clear();
      _allTrainings.addAll([
        Training(
          id: '1',
          clientName: 'ABC Corporation',
          trainingName: 'Safety Protocols',
          description: 'Learn about workplace safety protocols and emergency procedures.',
          dueDate: DateTime.now().add(const Duration(days: 7)),
        ),
        Training(
          id: '2',
          clientName: 'XYZ Industries',
          trainingName: 'Quality Assurance',
          description: 'Overview of quality control measures and standards.',
          dueDate: DateTime.now().add(const Duration(days: 14)),
        ),
        Training(
          id: '3',
          clientName: 'Tech Solutions',
          trainingName: 'New Software Orientation',
          description: 'Introduction to new project management software.',
          dueDate: DateTime.now().add(const Duration(days: 3)),
        ),
        Training(
          id: '4',
          clientName: 'Global Services',
          trainingName: 'Customer Relations',
          description: 'Training on handling customer inquiries and complaints.',
          dueDate: DateTime.now().add(const Duration(days: 10)),
          isCompleted: true,
        ),
        Training(
          id: '5',
          clientName: 'Innovate Inc.',
          trainingName: 'Product Knowledge',
          description: 'Detailed information about new product features.',
          dueDate: DateTime.now().subtract(const Duration(days: 5)),
          isCompleted: true,
        ),
      ]);

    } catch (e) {
      errorMessage.value = "Failed to load trainings. Please try again.";
    } finally {
      isLoading.value = false;
    }
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
              onPressed: () {
                // In a real app, you would call an API to update the status
                // For this demo, we'll update our local list
                final index = _allTrainings.indexWhere((t) => t.id == training.id);
                if (index >= 0) {
                  final updatedTraining = Training(
                    id: training.id,
                    clientName: training.clientName,
                    trainingName: training.trainingName,
                    description: training.description,
                    dueDate: training.dueDate,
                    isCompleted: true,
                  );

                  _allTrainings[index] = updatedTraining;

                  // Notify listeners by updating values (this triggers UI rebuild)
                  isLoading.value = isLoading.value;
                }

                Navigator.of(context).pop();

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Training marked as completed"),
                    backgroundColor: Colors.green,
                  ),
                );
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

  // Clean up resources
  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
  }
}