import 'package:flutter/material.dart';
import 'package:meetsu_solutions/clint/c_screen/c_more/analytics/daily/daily_analytics_controller.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

class DailyAnalyticsScreen extends StatefulWidget {
  const DailyAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<DailyAnalyticsScreen> createState() => _DailyAnalyticsScreenState();
}

class _DailyAnalyticsScreenState extends State<DailyAnalyticsScreen> {
  final DailyAnalyticsController _controller = DailyAnalyticsController();
  final List<String> _typeOptions = ['Any', 'Male', 'Female'];
  String _selectedType = 'Any';

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
                  // Header with back button and title
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button in white container with shadow
                        Container(
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
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.blue),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            iconSize: 20,
                          ),
                        ),

                        // Title
                        const Text(
                          "Daily Analytics",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        // ID Badge pill
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
                          child: Text(
                            (SharedPrefsService.instance.getUsername()),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main content with rounded corners and shadow
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: 10,
                            offset: Offset(0, -3),
                          ),
                        ],
                      ),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _controller.isLoading,
                        builder: (context, isLoading, child) {
                          if (isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          return ValueListenableBuilder<String?>(
                            valueListenable: _controller.errorMessage,
                            builder: (context, errorMessage, child) {
                              if (errorMessage != null) {
                                return _buildErrorView(errorMessage);
                              }

                              return ListView(
                                padding: const EdgeInsets.all(16),
                                children: [
                                  // Shift dropdown with improved styling
                                  _buildFilterSection(
                                    label: 'Shift',
                                    child: Container(
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _controller.selectedShift,
                                          icon: const Icon(Icons.keyboard_arrow_down),
                                          isExpanded: true,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          onChanged: _controller.updateShift,
                                          items: _controller.shifts
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Date selector with improved styling
                                  _buildFilterSection(
                                    label: 'Date',
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 45,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.grey.shade300),
                                            ),
                                            child: TextField(
                                              controller: _controller.dateController,
                                              readOnly: true,
                                              decoration: const InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                                border: InputBorder.none,
                                                hintText: 'Select date',
                                                hintStyle: TextStyle(color: Colors.grey),
                                              ),
                                              onTap: () => _controller.selectDate(context),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Clear button
                                        Container(
                                          width: 45,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey.shade300),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.close, size: 20, color: Colors.red),
                                            onPressed: _controller.clearDate,
                                            tooltip: 'Clear date',
                                            padding: EdgeInsets.zero,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Calendar button
                                        Container(
                                          width: 45,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.calendar_month, size: 20, color: Colors.white),
                                            onPressed: () => _controller.selectDate(context),
                                            tooltip: 'Select date',
                                            padding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Type dropdown with improved styling
                                  _buildFilterSection(
                                    label: 'Type',
                                    child: Container(
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedType,
                                          icon: const Icon(Icons.keyboard_arrow_down),
                                          isExpanded: true,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                _selectedType = newValue;
                                              });
                                              _controller.fetchAnalyticsData();
                                            }
                                          },
                                          items: _typeOptions
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Search button
                                  Container(
                                    width: double.infinity,
                                    height: 50,
                                    margin: const EdgeInsets.only(top: 20, bottom: 20),
                                    child: ElevatedButton.icon(
                                      onPressed: _controller.fetchAnalyticsData,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        elevation: 2,
                                      ),
                                      icon: const Icon(Icons.search, size: 20),
                                      label: const Text(
                                        'Search',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Data header - Daily Analytics with counts
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.bar_chart, color: Colors.blue, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Daily Analytics',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _controller.getTotalCount(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Table with improved styling
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade300),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        // Table header
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                          ),
                                          child: Table(
                                            border: TableBorder.symmetric(
                                              inside: BorderSide(color: Colors.grey.shade300),
                                            ),
                                            columnWidths: const {
                                              0: FlexColumnWidth(0.5),
                                              1: FlexColumnWidth(1),
                                              2: FlexColumnWidth(2),
                                            },
                                            children: [
                                              TableRow(
                                                children: [
                                                  _buildTableHeaderCell('#'),
                                                  _buildTableHeaderCell('E ID'),
                                                  _buildTableHeaderCell('Name'),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Table content
                                        Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                            ),
                                          ),
                                          child: Table(
                                            border: TableBorder.symmetric(
                                              inside: BorderSide(color: Colors.grey.shade300),
                                            ),
                                            columnWidths: const {
                                              0: FlexColumnWidth(0.5),
                                              1: FlexColumnWidth(1),
                                              2: FlexColumnWidth(2),
                                            },
                                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                            children: _buildTableRows(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Helper method to build consistent filter sections
  Widget _buildFilterSection({required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: child),
        ],
      ),
    );
  }

  List<TableRow> _buildTableRows() {
    final List<TableRow> rows = [];

    // Office Help header
    rows.add(
      TableRow(
        children: [
          Container(),
          Container(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              'Office Help',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );

    // First two rows
    rows.add(
      TableRow(
        children: [
          _buildTableCell('1'),
          _buildTableCell('5345'),
          _buildTableCell('JOY BUENCAMINO', bold: true),
        ],
      ),
    );

    rows.add(
      TableRow(
        children: [
          _buildTableCell('2'),
          _buildTableCell('42921'),
          _buildTableCell('ROOPKARAN KAUR DHILLON', bold: true),
        ],
      ),
    );

    // Door Monitor header
    rows.add(
      TableRow(
        children: [
          Container(),
          Container(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              'Door Monitor',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );

    // Second two rows
    rows.add(
      TableRow(
        children: [
          _buildTableCell('3'),
          _buildTableCell('44382'),
          _buildTableCell('SHARON PILA', bold: true),
        ],
      ),
    );

    rows.add(
      TableRow(
        children: [
          _buildTableCell('4'),
          _buildTableCell('26670'),
          _buildTableCell('MICHELLE MONTIEL', bold: true),
        ],
      ),
    );

    // Office Help header again
    rows.add(
      TableRow(
        children: [
          Container(),
          Container(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              'Office Help',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );

    // Third set of rows
    rows.add(
      TableRow(
        children: [
          _buildTableCell('5'),
          _buildTableCell('30482'),
          _buildTableCell('NORELYN ESPIRITU', bold: true),
        ],
      ),
    );

    rows.add(
      TableRow(
        children: [
          _buildTableCell('1'),
          _buildTableCell('14476'),
          _buildTableCell('HIREN PANCHAL', bold: true),
        ],
      ),
    );

    // Door Monitor header again
    rows.add(
      TableRow(
        children: [
          Container(),
          Container(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              'Door Monitor',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );

    // Last two rows
    rows.add(
      TableRow(
        children: [
          _buildTableCell('2'),
          _buildTableCell('1638'),
          _buildTableCell('REGENOLD CHRISTIAN', bold: true),
        ],
      ),
    );

    rows.add(
      TableRow(
        children: [
          _buildTableCell('3'),
          _buildTableCell('47007'),
          _buildTableCell('SHUBHAM KHOSLA', bold: true),
        ],
      ),
    );

    return rows;
  }

  Widget _buildTableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _controller.fetchAnalyticsData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}