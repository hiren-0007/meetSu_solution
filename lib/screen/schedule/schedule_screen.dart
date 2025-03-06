import 'package:flutter/material.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/screen/schedule/schedule_controller.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ScheduleController _controller = ScheduleController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [AppTheme.primaryShadow],
            ),
            margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          "Start Date",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "End Date",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(width: 10),

                    // Start date selector
                    Expanded(
                      child: ValueListenableBuilder<String>(
                        valueListenable: _controller.startDate,
                        builder: (context, startDate, _) {
                          return GestureDetector(
                            onTap: () => _controller.selectStartDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      startDate,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimaryColor,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    size: 18,
                                    color: AppTheme.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 15),

                    // End date selector
                    Expanded(
                      child: ValueListenableBuilder<String>(
                        valueListenable: _controller.endDate,
                        builder: (context, endDate, _) {
                          return GestureDetector(
                            onTap: () => _controller.selectEndDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      endDate,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimaryColor,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    size: 18,
                                    color: AppTheme.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 10),
                  ],
                ),
              ],
            ),
          ),

          // Information message
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: const Text(
              "Report:- All hours and amount are approximate for the current week",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),

          // Schedule content
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: _controller.isLoading,
              builder: (context, isLoading, _) {
                if (isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ValueListenableBuilder<bool>(
                    valueListenable: _controller.hasData,
                    builder: (context, hasData, _) {
                      if (hasData) {
                        return _buildScheduleData();
                      } else {
                        return const Center(
                          child: Text(
                            "No data found on this date",
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleData() {
    return Column(
      children: [
        // Display pay check if available
        ValueListenableBuilder<String?>(
          valueListenable: _controller.payCheck,
          builder: (context, payCheck, _) {
            if (payCheck != null && payCheck.isNotEmpty) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                child: Text(
                  "Pay Check: $payCheck",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // Schedule items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _controller.scheduleItems.value.length,
            itemBuilder: (context, index) {
              final item = _controller.scheduleItems.value[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date and Company
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.date ?? "N/A",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            item.company ?? "N/A",
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Position
                      Row(
                        children: [
                          const Icon(Icons.work, size: 16, color: AppTheme.textSecondaryColor),
                          const SizedBox(width: 8),
                          Text(
                            "Position: ${item.position ?? 'N/A'}",
                            style: const TextStyle(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Shift
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 16, color: AppTheme.textSecondaryColor),
                          const SizedBox(width: 8),
                          Text(
                            "Shift: ${item.shift ?? 'N/A'}",
                            style: const TextStyle(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Time
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: AppTheme.textSecondaryColor),
                          const SizedBox(width: 8),
                          Text(
                            "Time: ${item.startTime ?? 'N/A'} - ${item.endTime ?? 'N/A'}",
                            style: const TextStyle(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Hours
                      Row(
                        children: [
                          const Icon(Icons.timelapse, size: 16, color: AppTheme.textSecondaryColor),
                          const SizedBox(width: 8),
                          Text(
                            "Hours: ${item.hours ?? 'N/A'}",
                            style: const TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Pay information
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Rate: ${item.rate ?? 'N/A'}/hr",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Total: ${item.totalPay ?? 'N/A'}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}