import 'package:flutter/material.dart';
import 'package:meetsu_solutions/clint/c_screen/c_scheduler/clint__scheduler_view_controller.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';

class ClintSchedulerViewScreen extends StatefulWidget {
  const ClintSchedulerViewScreen({super.key});

  @override
  State<ClintSchedulerViewScreen> createState() => _ClintSchedulerViewScreenState();
}

class _ClintSchedulerViewScreenState extends State<ClintSchedulerViewScreen> {
  late final ClintSchedulerViewController _controller;
  final ValueNotifier<DateTime> selectedDate = ValueNotifier(DateTime.now());
  final ValueNotifier<String> selectedView = ValueNotifier('Week'); // Default to Week view

  late final double _screenHeight;
  late final double _screenWidth;

  @override
  void initState() {
    super.initState();
    _controller = ClintSchedulerViewController();
    _controller.fetchDashboardData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    _screenHeight = size.height;
    _screenWidth = size.width;
  }

  @override
  void dispose() {
    _controller.dispose();
    selectedDate.dispose();
    selectedView.dispose();
    super.dispose();
  }

  void _showJobDetailsDialog(ScheduleData schedule) async {
    if (schedule.jobPositionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No job position ID available')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final jobDetails = await _controller.fetchJobDetails(schedule.jobPositionId!);

      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (context) => _buildJobDetailsDialog(jobDetails, schedule.jobPositionId!),
      );
    } catch (e) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading job details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          _buildGradientHeader(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: _screenHeight * 0.25,
        decoration: AppTheme.headerClintContainerDecoration,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(_screenWidth * 0.04),
      child: Row(
        children: [
          _buildLogo(),
          const Expanded(
            child: Center(
              child: Text(
                'MEETsu Solutions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _buildUserBadge(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 35,
      width: 35,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildUserBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _screenWidth * 0.03,
        vertical: _screenHeight * 0.008,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        SharedPrefsService.instance.getUsername(),
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: RefreshIndicator(
        onRefresh: _controller.fetchDashboardData,
        child: ValueListenableBuilder<bool>(
          valueListenable: _controller.isLoading,
          builder: (context, isLoading, _) {
            if (isLoading) {
              return _buildLoadingView();
            }

            return ValueListenableBuilder<String?>(
              valueListenable: _controller.errorMessage,
              builder: (context, errorMessage, _) {
                return _buildSchedulerView();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: _screenHeight * 0.02),
          Text(
            "Loading schedule data...",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulerView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: _screenHeight * 0.02),
        _buildViewTabs(),
        SizedBox(height: _screenHeight * 0.02),
        Expanded(
          child: ValueListenableBuilder<String>(
            valueListenable: selectedView,
            builder: (context, view, _) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: _screenWidth * 0.04),
                child: view == 'Week'
                    ? ValueListenableBuilder<DateTime>(
                  valueListenable: selectedDate,
                  builder: (context, date, _) => _buildWeekView(date),
                )
                    : ValueListenableBuilder<DateTime>(
                  valueListenable: selectedDate,
                  builder: (context, date, _) => _buildDayView(date),
                ),
              );
            },
          ),
        ),
        ValueListenableBuilder<String>(
          valueListenable: selectedView,
          builder: (context, view, _) {
            if (view == 'Day') {
              return ValueListenableBuilder<DateTime>(
                valueListenable: selectedDate,
                builder: (context, date, _) => _buildTaskCards(date),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        SizedBox(height: _screenHeight * 0.02),
      ],
    );
  }

  Widget _buildViewTabs() {
    return ValueListenableBuilder<String>(
      valueListenable: selectedView,
      builder: (context, selected, _) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: _screenWidth * 0.04),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(child: _buildViewTab('Week', selected)),
                Expanded(child: _buildViewTab('Day', selected)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewTab(String label, String selected) {
    final isSelected = selected == label;
    return GestureDetector(
      onTap: () => selectedView.value = label,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: _screenHeight * 0.01),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildWeekView(DateTime selectedDateValue) {
    final int currentWeekday = selectedDateValue.weekday;
    final DateTime monday = selectedDateValue.subtract(Duration(days: currentWeekday - 1));
    final days = List<DateTime>.generate(7, (index) => monday.add(Duration(days: index)));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                selectedDate.value = selectedDate.value.subtract(const Duration(days: 7));
              },
              icon: const Icon(Icons.chevron_left, color: Colors.black),
            ),
            Text(
              'Week of ${monday.day} ${_monthName(monday.month)} ${monday.year}',
              style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                selectedDate.value = selectedDate.value.add(const Duration(days: 7));
              },
              icon: const Icon(Icons.chevron_right, color: Colors.black),
            ),
          ],
        ),
        SizedBox(height: _screenHeight * 0.02),

        Row(
          children: days.map((day) {
            final bool isSelected = selectedDate.value.day == day.day &&
                selectedDate.value.month == day.month &&
                selectedDate.value.year == day.year;
            final bool isToday = DateTime.now().day == day.day &&
                DateTime.now().month == day.month &&
                DateTime.now().year == day.year;

            return Expanded(
              child: GestureDetector(
                onTap: () => selectedDate.value = day,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: _screenWidth * 0.01),
                  padding: EdgeInsets.symmetric(vertical: _screenHeight * 0.015),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday ? Border.all(color: Colors.blue, width: 2) : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday - 1],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: _screenHeight * 0.005),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        SizedBox(height: _screenHeight * 0.03),

        Expanded(
          child: Container(
            padding: EdgeInsets.all(_screenWidth * 0.04),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ValueListenableBuilder<List<ScheduleData>>(
              valueListenable: _controller.scheduleDataList,
              builder: (context, scheduleList, _) {
                final daySchedule = _controller.getScheduleForDay(selectedDate.value);

                if (daySchedule.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: _screenWidth * 0.15,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: _screenHeight * 0.02),
                      Text(
                        'No schedule for this day',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: _screenWidth * 0.04,
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_dayName(selectedDate.value.weekday)}, ${selectedDate.value.day} ${_monthName(selectedDate.value.month)}',
                      style: TextStyle(
                        fontSize: _screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: _screenHeight * 0.02),
                    Expanded(
                      child: ListView.builder(
                        itemCount: daySchedule.length,
                        itemBuilder: (context, index) {
                          final schedule = daySchedule[index];
                          return GestureDetector(
                            onTap: () => _showJobDetailsDialog(schedule),
                            child: Container(
                              margin: EdgeInsets.only(bottom: _screenHeight * 0.01),
                              padding: EdgeInsets.all(_screenWidth * 0.03),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(_screenWidth * 0.02),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.schedule,
                                      color: Colors.white,
                                      size: _screenWidth * 0.04,
                                    ),
                                  ),
                                  SizedBox(width: _screenWidth * 0.03),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          schedule.type,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: _screenWidth * 0.04,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          '${schedule.totalSlots} | ${schedule.booked} | ${schedule.available}',
                                          style: TextStyle(
                                            fontSize: _screenWidth * 0.035,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: _screenWidth * 0.04,
                                    color: Colors.grey.shade400,
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
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayView(DateTime selectedDateValue) {
    final dayName = _dayName(selectedDateValue.weekday);
    final monthName = _monthName(selectedDateValue.month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
              },
              icon: const Icon(Icons.chevron_left, color: Colors.black),
            ),
            Text(
              '$dayName, ${selectedDateValue.day} $monthName ${selectedDateValue.year}',
              style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                selectedDate.value = selectedDate.value.add(const Duration(days: 1));
              },
              icon: const Icon(Icons.chevron_right, color: Colors.black),
            ),
          ],
        ),
        SizedBox(height: _screenHeight * 0.03),

        Expanded(
          child: Container(
            padding: EdgeInsets.all(_screenWidth * 0.04),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: _screenWidth * 0.15,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: _screenHeight * 0.02),
                Text(
                  dayName.toUpperCase(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: _screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: _screenHeight * 0.01),
                Text(
                  '${selectedDateValue.day} $monthName ${selectedDateValue.year}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: _screenWidth * 0.04,
                  ),
                ),
                SizedBox(height: _screenHeight * 0.02),
                ValueListenableBuilder<List<ScheduleData>>(
                  valueListenable: _controller.scheduleDataList,
                  builder: (context, scheduleList, _) {
                    final daySchedule = _controller.getScheduleForDay(selectedDate.value);

                    if (daySchedule.isEmpty) {
                      return Text(
                        'No events scheduled',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: _screenWidth * 0.035,
                        ),
                      );
                    }

                    return Text(
                      '${daySchedule.length} schedule${daySchedule.length > 1 ? 's' : ''} found',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: _screenWidth * 0.035,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCards(DateTime date) {
    return ValueListenableBuilder<List<ScheduleData>>(
      valueListenable: _controller.scheduleDataList,
      builder: (context, scheduleList, _) {
        final daySchedule = _controller.getScheduleForDay(date);

        if (daySchedule.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: _screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(color: Colors.grey),
              SizedBox(height: _screenHeight * 0.01),
              Text(
                'Day\'s Schedule',
                style: TextStyle(
                  fontSize: _screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: _screenHeight * 0.015),
              ...daySchedule.map((schedule) => GestureDetector(
                onTap: () => _showJobDetailsDialog(schedule),
                child: Container(
                  margin: EdgeInsets.only(bottom: _screenHeight * 0.01),
                  child: _buildTaskCard(
                    schedule.type,
                    '${schedule.totalSlots} | ${schedule.booked} | ${schedule.available}',
                    Colors.blue.withValues(alpha: 0.1),
                    Colors.blue,
                  ),
                ),
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(String title, String stats, Color backgroundColor, Color accentColor) {
    return Container(
      padding: EdgeInsets.all(_screenWidth * 0.04),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(_screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: _screenWidth * 0.04,
                ),
              ),
              SizedBox(width: _screenWidth * 0.02),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: _screenWidth * 0.04,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: _screenWidth * 0.04,
                color: Colors.grey.shade400,
              ),
            ],
          ),
          SizedBox(height: _screenHeight * 0.01),
          Text(
            stats,
            style: TextStyle(
              fontSize: _screenWidth * 0.035,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: _screenHeight * 0.005),
          Text(
            'Total | Assigned | Available',
            style: TextStyle(
              fontSize: _screenWidth * 0.025,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetailsDialog(Map<String, dynamic> jobDetails, int orderId) {
    final jobData = jobDetails['jobDetails'] ?? {};
    final assignedApplicants = List<Map<String, dynamic>>.from(jobDetails['assignedApplicants'] ?? []);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: _screenWidth * 0.85,
        constraints: BoxConstraints(
          maxHeight: _screenHeight * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(_screenWidth * 0.04),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${jobData['date']?.toString() ?? 'N/A'} | ${jobData['shiftName']?.toString() ?? 'N/A'} | ${jobData['positionName']?.toString() ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _screenWidth * 0.033,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: _screenWidth * 0.02),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: _screenWidth * 0.045,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _screenHeight * 0.01),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order ID: $orderId',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: _screenWidth * 0.03,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            jobData['positionCount']?.toString() ?? '0',
                            style: TextStyle(
                              color: Colors.blue.shade300,
                              fontSize: _screenWidth * 0.038,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' - ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: _screenWidth * 0.038,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            jobData['assignCount']?.toString() ?? '0',
                            style: TextStyle(
                              color: Colors.green.shade300,
                              fontSize: _screenWidth * 0.038,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' - ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: _screenWidth * 0.038,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${(int.tryParse(jobData['positionCount']?.toString() ?? '0') ?? 0) - (int.tryParse(jobData['assignCount']?.toString() ?? '0') ?? 0)}',
                            style: TextStyle(
                              color: Colors.orange.shade300,
                              fontSize: _screenWidth * 0.038,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Flexible(
              child: Padding(
                padding: EdgeInsets.all(_screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(_screenWidth * 0.015),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.people,
                            color: Colors.blue,
                            size: _screenWidth * 0.04,
                          ),
                        ),
                        SizedBox(width: _screenWidth * 0.025),
                        Text(
                          'Assigned Applicants (${assignedApplicants.length})',
                          style: TextStyle(
                            fontSize: _screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: _screenHeight * 0.015),

                    if (assignedApplicants.isEmpty)
                      Container(
                        height: _screenHeight * 0.15,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off,
                              size: _screenWidth * 0.08,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: _screenHeight * 0.01),
                            Text(
                              'No applicants assigned yet',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: _screenWidth * 0.035,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: assignedApplicants.length,
                          separatorBuilder: (context, index) => SizedBox(height: _screenHeight * 0.008),
                          itemBuilder: (context, index) {
                            final applicant = assignedApplicants[index];
                            return _buildCompactApplicantCard(applicant, index);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: _screenWidth * 0.04,
                vertical: _screenHeight * 0.015,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: _screenHeight * 0.012),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontSize: _screenWidth * 0.038,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactApplicantCard(Map<String, dynamic> applicant, int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];
    final cardColor = colors[index % colors.length];

    return Container(
      padding: EdgeInsets.all(_screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: _screenWidth * 0.1,
            height: _screenWidth * 0.1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cardColor.withValues(alpha: 0.8), cardColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(_screenWidth * 0.05),
            ),
            child: Center(
              child: Text(
                (applicant['applicantName']?.toString() ?? 'U').substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: _screenWidth * 0.03),
          Expanded(
            child: Text(
              applicant['applicantName']?.toString() ?? 'Unknown',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: _screenWidth * 0.035,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _dayName(int weekday) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return days[weekday - 1];
  }
}