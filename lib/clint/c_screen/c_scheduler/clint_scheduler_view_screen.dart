// import 'package:flutter/material.dart';
// import 'package:meetsu_solutions/clint/c_screen/c_scheduler/clint__scheduler_view_controller.dart';
// import 'package:meetsu_solutions/utils/theme/app_theme.dart';
// import 'package:intl/intl.dart';
//
// class ClintSchedulerViewScreen extends StatefulWidget {
//   const ClintSchedulerViewScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ClintSchedulerViewScreen> createState() => _ClintSchedulerViewScreenState();
// }
//
// class _ClintSchedulerViewScreenState extends State<ClintSchedulerViewScreen> {
//   final ClintSchedulerViewController _controller = ClintSchedulerViewController();
//
//   @override
//   void initState() {
//     super.initState();
//     _controller.fetchDashboardData();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.backgroundColor,
//       body: Stack(
//         children: [
//           // Blue gradient header
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               height: MediaQuery.of(context).size.height * 0.25,
//               decoration: AppTheme.headerClintContainerDecoration,
//             ),
//           ),
//           SafeArea(
//             child: Column(
//               children: [
//                 // Header with logo and title
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     children: [
//                       // Logo container
//                       Container(
//                         height: 35,
//                         width: 35,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(8),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(2.0),
//                             child: Image.asset(
//                               'assets/images/logo.png',
//                               fit: BoxFit.contain,
//                             ),
//                           ),
//                         ),
//                       ),
//                       // Title text centered
//                       Expanded(
//                         child: Center(
//                           child: const Text(
//                             'Scheduler',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       // ID Badge
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: const Text(
//                           'M14476',
//                           style: TextStyle(
//                             color: Colors.black87,
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Main Content with white background and rounded corners
//                 Expanded(
//                   child: Container(
//                     width: double.infinity,
//                     margin: const EdgeInsets.symmetric(horizontal: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(20),
//                         topRight: Radius.circular(20),
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 10,
//                           offset: const Offset(0, -3),
//                         ),
//                       ],
//                     ),
//                     child: RefreshIndicator(
//                       onRefresh: _controller.fetchDashboardData,
//                       child: ValueListenableBuilder<bool>(
//                         valueListenable: _controller.isLoading,
//                         builder: (context, isLoading, child) {
//                           if (isLoading) {
//                             return Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   const CircularProgressIndicator(
//                                     valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//                                   ),
//                                   const SizedBox(height: 16),
//                                   Text(
//                                     "Loading schedule data...",
//                                     style: TextStyle(
//                                       color: Colors.grey.shade600,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }
//
//                           return ValueListenableBuilder<String?>(
//                             valueListenable: _controller.errorMessage,
//                             builder: (context, errorMessage, child) {
//                               if (errorMessage != null) {
//                                 return _buildErrorView(errorMessage);
//                               }
//
//                               return ValueListenableBuilder<bool>(
//                                 valueListenable: _controller.hasData,
//                                 builder: (context, hasData, child) {
//                                   // Always show the scheduler view regardless of hasData
//                                   return _buildSchedulerView();
//                                 },
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSchedulerView() {
//     return Column(
//       children: [
//         // Date and view selection
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//           child: Column(
//             children: [
//               // Current week display with navigation
//               ValueListenableBuilder<DateTime>(
//                 valueListenable: _controller.currentWeekStart,
//                 builder: (context, currentWeekStart, child) {
//                   return Container(
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           Colors.blue.shade400,
//                           Colors.blue.shade600,
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.blue.withOpacity(0.2),
//                           blurRadius: 6,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // Previous week button
//                         Container(
//                           margin: const EdgeInsets.only(left: 8),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: IconButton(
//                             icon: const Icon(
//                               Icons.chevron_left,
//                               color: Colors.white,
//                               size: 22,
//                             ),
//                             padding: EdgeInsets.zero,
//                             constraints: const BoxConstraints(
//                               minWidth: 30,
//                               minHeight: 30,
//                             ),
//                             onPressed: _controller.previousWeek,
//                           ),
//                         ),
//
//                         // Week date range
//                         Text(
//                           _controller.getFormattedWeekRange(),
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                             shadows: [
//                               Shadow(
//                                 color: Colors.black.withOpacity(0.3),
//                                 blurRadius: 2,
//                                 offset: const Offset(0, 1),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         // Next week button
//                         Container(
//                           margin: const EdgeInsets.only(right: 8),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: IconButton(
//                             icon: const Icon(
//                               Icons.chevron_right,
//                               color: Colors.white,
//                               size: 22,
//                             ),
//                             padding: EdgeInsets.zero,
//                             constraints: const BoxConstraints(
//                               minWidth: 30,
//                               minHeight: 30,
//                             ),
//                             onPressed: _controller.nextWeek,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//
//               const SizedBox(height: 12),
//
//               // View selection tabs
//               Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.2),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(child: _buildViewTab('Month', false)),
//                     Expanded(child: _buildViewTab('Week', true)),
//                     Expanded(child: _buildViewTab('Day', false)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         // Week days header
//         ValueListenableBuilder<DateTime>(
//             valueListenable: _controller.currentWeekStart,
//             builder: (context, currentWeekStart, child) {
//               return Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                   ),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: Row(
//                   children: [
//                     _buildDayHeader(_formatHeaderDay(currentWeekStart), isCurrentDay(currentWeekStart)),
//                     _buildDayHeader(_formatHeaderDay(currentWeekStart.add(const Duration(days: 1))), isCurrentDay(currentWeekStart.add(const Duration(days: 1)))),
//                     _buildDayHeader(_formatHeaderDay(currentWeekStart.add(const Duration(days: 2))), isCurrentDay(currentWeekStart.add(const Duration(days: 2)))),
//                     _buildDayHeader(_formatHeaderDay(currentWeekStart.add(const Duration(days: 3))), isCurrentDay(currentWeekStart.add(const Duration(days: 3)))),
//                     _buildDayHeader(_formatHeaderDay(currentWeekStart.add(const Duration(days: 4))), isCurrentDay(currentWeekStart.add(const Duration(days: 4)))),
//                     _buildDayHeader(_formatHeaderDay(currentWeekStart.add(const Duration(days: 5))), isCurrentDay(currentWeekStart.add(const Duration(days: 5)))),
//                     _buildDayHeader(_formatHeaderDay(currentWeekStart.add(const Duration(days: 6))), isCurrentDay(currentWeekStart.add(const Duration(days: 6)))),
//                   ],
//                 ),
//               );
//             }
//         ),
//
//         // Schedule grid
//         Expanded(
//           child: ValueListenableBuilder<DateTime>(
//               valueListenable: _controller.currentWeekStart,
//               builder: (context, currentWeekStart, child) {
//                 return Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 16),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: const BorderRadius.only(
//                       bottomLeft: Radius.circular(12),
//                       bottomRight: Radius.circular(12),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.1),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: const BorderRadius.only(
//                       bottomLeft: Radius.circular(12),
//                       bottomRight: Radius.circular(12),
//                     ),
//                     child: ListView(
//                       padding: EdgeInsets.zero,
//                       children: [
//                         // AM | DM row
//                         _buildScheduleRow(
//                           'AM | DM',
//                           Colors.blue.withOpacity(0.05),
//                           List.generate(7, (index) {
//                             final DateTime dayDate = currentWeekStart.add(Duration(days: index));
//                             final ScheduleData? scheduleData = _controller.getScheduleForDayAndType(dayDate, 'AM | DM');
//
//                             return [
//                               scheduleData?.available.toString() ?? '0',
//                               scheduleData?.booked.toString() ?? '0',
//                               scheduleData?.pending.toString() ?? '0',
//                             ];
//                           }),
//                           currentDayIndex: getCurrentDayIndex(),
//                         ),
//
//                         // AM | OH row
//                         _buildScheduleRow(
//                           'AM | OH',
//                           Colors.green.withOpacity(0.05),
//                           List.generate(7, (index) {
//                             final DateTime dayDate = currentWeekStart.add(Duration(days: index));
//                             final ScheduleData? scheduleData = _controller.getScheduleForDayAndType(dayDate, 'AM | OH');
//
//                             return [
//                               scheduleData?.available.toString() ?? '0',
//                               scheduleData?.booked.toString() ?? '0',
//                               scheduleData?.pending.toString() ?? '0',
//                             ];
//                           }),
//                           currentDayIndex: getCurrentDayIndex(),
//                         ),
//
//                         // Additional empty rows to demonstrate scrolling
//                         for (int i = 0; i < 10; i++)
//                           _buildEmptyRow(
//                               i % 2 == 0
//                                   ? Colors.blue.withOpacity(0.02)
//                                   : Colors.green.withOpacity(0.02)
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               }
//           ),
//         ),
//
//         const SizedBox(height: 16),
//       ],
//     );
//   }
//
//   // Helper method to format day header text
//   String _formatHeaderDay(DateTime date) {
//     final DateFormat dayFormat = DateFormat('EEE');
//     final DateFormat dateFormat = DateFormat('M/d');
//
//     return '${dayFormat.format(date)}\n${dateFormat.format(date)}';
//   }
//
//   // Helper method to check if a date is today
//   bool isCurrentDay(DateTime date) {
//     final now = DateTime.now();
//     return date.year == now.year && date.month == now.month && date.day == now.day;
//   }
//
//   // Helper method to get the index of today in the current week
//   int getCurrentDayIndex() {
//     final now = DateTime.now();
//     final startOfWeek = _controller.currentWeekStart.value;
//
//     if (now.isBefore(startOfWeek) || now.isAfter(startOfWeek.add(const Duration(days: 6)))) {
//       return -1; // Today is not in the current week view
//     }
//
//     return now.difference(startOfWeek).inDays;
//   }
//
//   Widget _buildViewTab(String label, bool isSelected) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       decoration: BoxDecoration(
//         color: isSelected ? Colors.white : Colors.transparent,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: isSelected
//             ? [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 1),
//           ),
//         ]
//             : null,
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           color: isSelected ? Colors.blue : Colors.grey.shade700,
//           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//           fontSize: 14,
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
//
//   Widget _buildDayHeader(String text, bool isHighlighted) {
//     return Expanded(
//       child: Container(
//         decoration: BoxDecoration(
//           color: isHighlighted ? Colors.blue.withOpacity(0.1) : null,
//           border: Border(
//             right: BorderSide(color: Colors.grey.shade300),
//           ),
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         child: Text(
//           text,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
//             color: isHighlighted ? Colors.blue : Colors.grey.shade800,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildScheduleRow(String label, Color backgroundColor, List<List<String>> cellsData, {int currentDayIndex = -1}) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(color: Colors.grey.shade300),
//         ),
//       ),
//       child: IntrinsicHeight(
//         child: Row(
//           children: [
//             // Label cell
//             Container(
//               width: 70,
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//               decoration: BoxDecoration(
//                 color: backgroundColor,
//                 border: Border(
//                   right: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               child: Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//
//             // Data cells
//             ...List.generate(
//               cellsData.length,
//                   (index) => Expanded(
//                 child: GestureDetector(
//                   onTap: () {
//                     final DateTime dayDate = _controller.currentWeekStart.value.add(Duration(days: index));
//                     final ScheduleData? scheduleData = _controller.getScheduleForDayAndType(dayDate, label);
//
//                     if (scheduleData != null) {
//                     }
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: index == currentDayIndex
//                           ? Colors.yellow.withOpacity(0.2)
//                           : Colors.white,
//                       border: Border(
//                         right: BorderSide(color: Colors.grey.shade300),
//                       ),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             cellsData[index][0],
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.blue,
//                             ),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             cellsData[index][1],
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green,
//                             ),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             cellsData[index][2],
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.red,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyRow(Color bgColor) {
//     return Container(
//       height: 50,
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(color: Colors.grey.shade300),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 70,
//             decoration: BoxDecoration(
//               color: bgColor,
//               border: Border(
//                 right: BorderSide(color: Colors.grey.shade300),
//               ),
//             ),
//           ),
//           ...List.generate(
//             7,
//                 (index) => Expanded(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: index == getCurrentDayIndex() ? Colors.yellow.withOpacity(0.1) : Colors.white,
//                   border: Border(
//                     right: BorderSide(color: Colors.grey.shade300),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildErrorView(String errorMessage) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.error_outline,
//             size: 64,
//             color: Colors.red.withOpacity(0.5),
//           ),
//           const SizedBox(height: 16),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 32),
//             child: Text(
//               errorMessage,
//               style: const TextStyle(
//                 color: Colors.grey,
//                 fontSize: 16,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: _controller.fetchDashboardData,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   List<String> _buildCellData(List<String> values) {
//     return values;
//   }
// }

import 'package:flutter/material.dart';
import 'package:meetsu_solutions/clint/c_screen/c_scheduler/clint__scheduler_view_controller.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ClintSchedulerViewScreen extends StatefulWidget {
  const ClintSchedulerViewScreen({Key? key}) : super(key: key);

  @override
  State<ClintSchedulerViewScreen> createState() => _ClintSchedulerViewScreenState();
}

class _ClintSchedulerViewScreenState extends State<ClintSchedulerViewScreen> {
  final ClintSchedulerViewController _controller = ClintSchedulerViewController();
  final ValueNotifier<DateTime> selectedDate = ValueNotifier(DateTime.now());
  final ValueNotifier<String> selectedView = ValueNotifier('Month');
  @override
  void initState() {
    super.initState();
    _controller.fetchDashboardData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Blue gradient header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.25,
              decoration: AppTheme.headerClintContainerDecoration,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header with logo and title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Logo container
                      Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
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
                      ),
                      // Title text centered
                      Expanded(
                        child: Center(
                          child: const Text(
                            'Scheduler',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // ID Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'M14476',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content with white background and rounded corners
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
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
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                  ),
                                  const SizedBox(height: 16),
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

                          return ValueListenableBuilder<String?>(
                            valueListenable: _controller.errorMessage,
                            builder: (context, errorMessage, _) {
                              return _buildSchedulerView(); // Show scheduler always
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
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
        // Date Header
        ValueListenableBuilder<DateTime>(
          valueListenable: selectedDate,
          builder: (context, date, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                '${date.day} ${_monthName(date.month)} ${date.year}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        // View Tabs
        ValueListenableBuilder<String>(
          valueListenable: selectedView,
          builder: (context, selected, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildViewTab('Month', selected, selectedView)),
                    Expanded(child: _buildViewTab('Week', selected, selectedView)),
                    Expanded(child: _buildViewTab('Day', selected, selectedView)),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        // Calendar view (based on selected view)
        ValueListenableBuilder<String>(
          valueListenable: selectedView,
          builder: (context, view, _) {
            switch (view) {
              case 'Week':
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ValueListenableBuilder<DateTime>(
                    valueListenable: selectedDate,
                    builder: (context, date, _) => _buildWeekView(date),
                  ),
                );

              case 'Day':
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ValueListenableBuilder<DateTime>(
                    valueListenable: selectedDate,
                    builder: (context, date, _) => _buildDayView(date),
                  ),
                );

              case 'Month':
              default:
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ValueListenableBuilder<DateTime>(
                    valueListenable: selectedDate,
                    builder: (context, date, _) => _buildCalendar(date),
                  ),
                );
            }
          },
        ),

        const SizedBox(height: 12),
        const Divider(color: Colors.white24),

        Row(
          children: [
            _buildTaskCard('AM | DM', '3 | 3 | 0', Colors.grey.shade300),
            _buildTaskCard('AM | DM', '3 | 3 | 0', Colors.grey.shade300)
          ],
        )
        // Task Cards

      ],
    );
  }

  Widget _buildViewTab(String label, String selected, ValueNotifier<String> selectedView) {
    final isSelected = selected == label;
    return GestureDetector(
      onTap: () => selectedView.value = label,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(String title, String time, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildCalendar(DateTime selectedDateValue) {
    final DateTime firstDayOfMonth = DateTime(selectedDateValue.year, selectedDateValue.month, 1);
    final int weekdayOffset = firstDayOfMonth.weekday % 7;
    final DateTime start = firstDayOfMonth.subtract(Duration(days: weekdayOffset));
    final List<Widget> days = [];

    for (int i = 0; i < 42; i++) {
      final day = start.add(Duration(days: i));
      bool isCurrentMonth = day.month == selectedDateValue.month;
      bool isSelected = day.day == selectedDate.value.day &&
          day.month == selectedDate.value.month &&
          day.year == selectedDate.value.year;
      bool isToday = DateTime.now().day == day.day &&
          DateTime.now().month == day.month &&
          DateTime.now().year == day.year;

      days.add(GestureDetector(
        onTap: () => selectedDate.value = day,
        child: Container(
          margin: const EdgeInsets.all(2),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.transparent,
            shape: BoxShape.circle,
            border: isToday ? Border.all(color: Colors.white, width: 1.5) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: isCurrentMonth ? Colors.black : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ));
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                final newMonth = DateTime(selectedDateValue.year, selectedDateValue.month - 1, 1);
                selectedDate.value = newMonth;
              },
              icon: const Icon(Icons.chevron_left, color: Colors.black),
            ),
            Text(
              '${_monthName(selectedDateValue.month)} ${selectedDateValue.year}',
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
            IconButton(
              onPressed: () {
                final newMonth = DateTime(selectedDateValue.year, selectedDateValue.month + 1, 1);
                selectedDate.value = newMonth;
              },
              icon: const Icon(Icons.chevron_right, color: Colors.black),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map((d) => Expanded(
            child: Center(
              child: Text(d, style: TextStyle(color: Colors.black87)),
            ),
          ))
              .toList(),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: days,
        ),
      ],
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
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
            IconButton(
              onPressed: () {
                selectedDate.value = selectedDate.value.add(const Duration(days: 7));
              },
              icon: const Icon(Icons.chevron_right, color: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday ? Border.all(color: Colors.black87, width: 1.5) : null,
                  ),
                  child: Column(
                    children: [
                      Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][day.weekday - 1], style: const TextStyle(color: Colors.black)),
                      Text('${day.day}', style: TextStyle(color: Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
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
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
            IconButton(
              onPressed: () {
                selectedDate.value = selectedDate.value.add(const Duration(days: 1));
              },
              icon: const Icon(Icons.chevron_right, color: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text('No events', style: TextStyle(color: Colors.black54, fontSize: 14)),
              const SizedBox(height: 8),
              Text('${dayName.toUpperCase()}', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                '${selectedDateValue.day} $monthName ${selectedDateValue.year}',
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
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

