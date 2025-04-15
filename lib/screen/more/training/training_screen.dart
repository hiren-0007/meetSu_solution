import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/more/training/training_controller.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

import '../../../services/pref/shared_prefs_service.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final TrainingController _controller = TrainingController();

  @override
  void initState() {
    super.initState();
    _controller.loadTrainings();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidget(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppTheme.cardColor,
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              "Trainings",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.cardColor,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            SharedPrefsService.instance.getUsername() ?? "User",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school,
                        color: AppTheme.primaryColor,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _controller.isLoading,
                      builder: (context, isLoading, child) {
                        if (isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        return ValueListenableBuilder<String?>(
                          valueListenable: _controller.errorMessage,
                          builder: (context, errorMessage, child) {
                            if (errorMessage != null) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      errorMessage,
                                      style: const TextStyle(
                                          color: AppTheme.cardColorRed),
                                      textAlign: TextAlign.center,
                                    ),
                                    TextButton(
                                      onPressed: _controller.loadTrainings,
                                      child: const Text("Retry"),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ValueListenableBuilder<List<Training>>(
                              valueListenable: _controller.trainingsData,
                              builder: (context, trainings, child) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardColor,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: ListView(
                                    padding: EdgeInsets.zero,
                                    children: [
                                      _buildSectionTitle("Assigned Trainings"),
                                      if (_controller.assignedTrainings.isEmpty)
                                        _buildEmptyState(
                                            "No assigned trainings found.")
                                      else
                                        ...List.generate(
                                          _controller.assignedTrainings.length,
                                          (index) => _buildTrainingItem(
                                            _controller
                                                .assignedTrainings[index],
                                            isAssigned: true,
                                          ),
                                        ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 10),
                                        child: Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                      _buildSectionTitle("Completed Trainings"),
                                      if (_controller
                                          .completedTrainings.isEmpty)
                                        _buildEmptyState(
                                            "No completed trainings found.")
                                      else
                                        ...List.generate(
                                          _controller.completedTrainings.length,
                                          (index) => _buildTrainingItem(
                                            _controller
                                                .completedTrainings[index],
                                            isAssigned: false,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildTrainingItem(Training training, {required bool isAssigned}) {
    return InkWell(
      onTap: () {
        _controller.viewTraining(context, training);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isAssigned ? Icons.school : Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    training.trainingName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Client: ${training.clientName}",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  if (training.document != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      "Document: ${training.document}",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            isAssigned
                ? IconButton(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                    onPressed: () =>
                        _controller.markAsCompleted(context, training),
                  )
                : const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
          ],
        ),
      ),
    );
  }
}
