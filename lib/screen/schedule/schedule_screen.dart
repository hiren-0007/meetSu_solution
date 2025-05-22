import 'package:flutter/material.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/screen/schedule/schedule_controller.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';
import 'package:meetsu_solutions/model/schedule/schedule_response_model.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with AutomaticKeepAliveClientMixin {

  late final ScheduleController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = ScheduleController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Device type detection
  bool get isMobile => MediaQuery.of(context).size.width < 600;
  bool get isTablet => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ConnectivityWidget(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Column(
          children: [
            _buildDateSelector(),
            _buildNoticeCard(),
            _buildCompanyInfoCard(),
            Expanded(child: _buildMainContent()),
            _buildTotalPayCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [AppTheme.primaryShadow],
      ),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    "Start Date",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
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
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Date selector row
          Row(
            children: [
              // Previous button
              GestureDetector(
                onTap: () async {
                  await _controller.navigateToPreviousPeriod();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_left,
                      size: 24,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Start Date Picker
              Expanded(
                flex: 3,
                child: ValueListenableBuilder<String>(
                  valueListenable: _controller.startDate,
                  builder: (context, startDate, _) {
                    return GestureDetector(
                      onTap: () => _controller.selectStartDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 18,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                startDate,
                                style: const TextStyle(
                                  color: AppTheme.textPrimaryColor,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              // End Date Picker
              Expanded(
                flex: 3,
                child: ValueListenableBuilder<String>(
                  valueListenable: _controller.endDate,
                  builder: (context, endDate, _) {
                    return GestureDetector(
                      onTap: () => _controller.selectEndDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 18,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                endDate,
                                style: const TextStyle(
                                  color: AppTheme.textPrimaryColor,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Next button
              GestureDetector(
                onTap: () async {
                  await _controller.navigateToNextPeriod();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_right,
                      size: 24,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: const Text(
        "All Hours And Amounts Are Approximate",
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildCompanyInfoCard() {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.hasData,
      builder: (context, hasData, _) {
        if (hasData && _controller.scheduleItems.value.isNotEmpty) {
          final firstItem = _controller.scheduleItems.value.first;
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Top row - Company and Position
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        label: "Company",
                        value: firstItem.company ?? 'N/A',
                        isHighlighted: true,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: _buildInfoItem(
                        label: "Position",
                        value: firstItem.position ?? 'N/A',
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Bottom row - Shift and Rate
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        label: "Shift",
                        value: firstItem.shift ?? 'N/A',
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: _buildInfoItem(
                        label: "Rate",
                        value: "${firstItem.rate ?? 'N/A'}/hr",
                        isHighlighted: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    bool isHighlighted = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label:",
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isHighlighted ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
            fontSize: 14,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
            letterSpacing: 0.2,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.isLoading,
      builder: (context, isLoading, _) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return ValueListenableBuilder<bool>(
            valueListenable: _controller.hasData,
            builder: (context, hasData, _) {
              if (hasData) {
                return _buildScheduleTable();
              } else {
                return const Center(
                  child: Text(
                    "No data found for this date range",
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
    );
  }

  Widget _buildScheduleTable() {
    return ValueListenableBuilder<List<Data>>(
      valueListenable: _controller.scheduleItems,
      builder: (context, scheduleItems, _) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        "Date",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Start",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "End",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Hours",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        "Total Pay",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),

              // Table Body
              Expanded(
                child: ListView.builder(
                  itemCount: scheduleItems.length,
                  itemBuilder: (context, index) {
                    final item = scheduleItems[index];

                    String startTime = "00:00";
                    String endTime = "00:00";

                    if (item.startTime != null) {
                      final startTimeParts = item.startTime!.split(' ');
                      if (startTimeParts.length > 1) {
                        startTime = startTimeParts[1].substring(0, 5);
                      }
                    }

                    if (item.endTime != null) {
                      final endTimeParts = item.endTime!.split(' ');
                      if (endTimeParts.length > 1) {
                        endTime = endTimeParts[1].substring(0, 5);
                      }
                    }

                    String formattedDate = item.date ?? "N/A";
                    try {
                      if (item.date != null) {
                        final dateParts = item.date!.split('-');
                        if (dateParts.length == 3) {
                          final year = dateParts[0];
                          final month = dateParts[1];
                          final day = dateParts[2];

                          const monthNames = [
                            "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
                          ];
                          final monthName = monthNames[int.parse(month) - 1];

                          formattedDate = "$monthName $day, $year";
                        }
                      }
                    } catch (e) {}

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              formattedDate,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              startTime,
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              endTime,
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              item.hours ?? "0.00",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              item.totalPay ?? "\$0.00",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalPayCard() {
    return ValueListenableBuilder<List<Data>>(
      valueListenable: _controller.scheduleItems,
      builder: (context, scheduleItems, _) {
        if (scheduleItems.isNotEmpty) {
          double totalPay = 0;
          for (var item in scheduleItems) {
            if (item.totalPay != null) {
              final payString = item.totalPay!.replaceAll('\$', '');
              try {
                totalPay += double.parse(payString);
              } catch (e) {}
            }
          }

          return Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              "Total Pay: \$${totalPay.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}