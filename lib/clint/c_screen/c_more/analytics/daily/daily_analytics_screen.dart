import 'package:flutter/material.dart';
import 'package:meetsu_solutions/clint/c_screen/c_more/analytics/daily/daily_analytics_controller.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

class DailyAnalyticsScreen extends StatefulWidget {
  const DailyAnalyticsScreen({super.key});

  @override
  State<DailyAnalyticsScreen> createState() => _DailyAnalyticsScreenState();
}

class _DailyAnalyticsScreenState extends State<DailyAnalyticsScreen> {
  late final DailyAnalyticsController _controller;
  late final double _screenHeight;
  late final double _screenWidth;

  @override
  void initState() {
    super.initState();
    _controller = DailyAnalyticsController();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidget(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Stack(
          children: [
            _buildGradientHeader(),
            SafeArea(
              child: Column(
                children: [
                  _buildCompactHeader(),
                  Expanded(
                    child: _buildMainContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: _screenHeight * 0.2,
        decoration: AppTheme.headerClintContainerDecoration,
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _screenWidth * 0.04,
        vertical: _screenHeight * 0.015,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBackButton(),
          _buildTitle(),
          _buildUserBadge(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      width: _screenWidth * 0.1,
      height: _screenWidth * 0.1,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.blue,
          size: _screenWidth * 0.05,
        ),
        onPressed: () => Navigator.of(context).pop(),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Daily Analytics',
      style: TextStyle(
        color: Colors.white,
        fontSize: _screenWidth * 0.05,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildUserBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _screenWidth * 0.025,
        vertical: _screenHeight * 0.008,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        SharedPrefsService.instance.getUsername(),
        style: TextStyle(
          color: Colors.black87,
          fontSize: _screenWidth * 0.028,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: _screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: _controller.isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) return _buildLoadingView();

          return ValueListenableBuilder<String?>(
            valueListenable: _controller.errorMessage,
            builder: (context, errorMessage, _) {
              if (errorMessage != null) {
                return _buildErrorView(errorMessage);
              }
              return _buildAnalyticsContent();
            },
          );
        },
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
            "Loading analytics data...",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: _screenWidth * 0.035,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_screenWidth * 0.04),
      child: Column(
        children: [
          _buildShiftFilter(),
          SizedBox(height: _screenHeight * 0.015),
          _buildDateFilter(),
          SizedBox(height: _screenHeight * 0.025),
          _buildSearchButton(),
          SizedBox(height: _screenHeight * 0.025),
          _buildAnalyticsHeader(),
          SizedBox(height: _screenHeight * 0.02),
          _buildAnalyticsTable(),
        ],
      ),
    );
  }

  Widget _buildShiftFilter() {
    return _FilterSection(
      label: 'Shift',
      child: ValueListenableBuilder<String>(
        valueListenable: _controller.selectedShift,
        builder: (context, selectedShift, _) {
          return _CustomDropdown(
            value: selectedShift,
            items: _controller.shifts,
            onChanged: _controller.updateShift,
            screenWidth: _screenWidth,
            screenHeight: _screenHeight,
          );
        },
      ),
    );
  }

  Widget _buildDateFilter() {
    return _FilterSection(
      label: 'Date',
      child: Row(
        children: [
          Expanded(
            child: _DateField(
              controller: _controller.dateController,
              onTap: () => _controller.selectDate(context),
              screenWidth: _screenWidth,
              screenHeight: _screenHeight,
            ),
          ),
          SizedBox(width: _screenWidth * 0.02),
          _ActionButton(
            icon: Icons.close,
            color: Colors.red,
            onPressed: _controller.clearDate,
            screenWidth: _screenWidth,
            screenHeight: _screenHeight,
          ),
          SizedBox(width: _screenWidth * 0.02),
          _ActionButton(
            icon: Icons.calendar_month,
            color: Colors.white,
            backgroundColor: Colors.blue,
            onPressed: () => _controller.selectDate(context),
            screenWidth: _screenWidth,
            screenHeight: _screenHeight,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: _screenHeight * 0.06,
      child: ElevatedButton.icon(
        onPressed: _controller.performSearch,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
        icon: Icon(Icons.search, size: _screenWidth * 0.045),
        label: Text(
          'Search',
          style: TextStyle(
            fontSize: _screenWidth * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsHeader() {
    return ValueListenableBuilder<int>(
      valueListenable: _controller.maleCount,
      builder: (context, maleCount, _) {
        return ValueListenableBuilder<int>(
          valueListenable: _controller.femaleCount,
          builder: (context, femaleCount, _) {
            return _AnalyticsHeaderCard(
              maleCount: maleCount,
              femaleCount: femaleCount,
              screenWidth: _screenWidth,
              screenHeight: _screenHeight,
            );
          },
        );
      },
    );
  }

  Widget _buildAnalyticsTable() {
    return ValueListenableBuilder<List<AnalyticsItem>>(
      valueListenable: _controller.analyticsItems,
      builder: (context, items, _) {
        if (items.isEmpty) {
          return _NoDataWidget(
            screenWidth: _screenWidth,
            screenHeight: _screenHeight,
          );
        }

        return ValueListenableBuilder<Map<String, List<AnalyticsItem>>>(
          valueListenable: _controller.groupedItems,
          builder: (context, groupedItems, _) {
            return _AnalyticsTable(
              groupedItems: groupedItems,
              screenWidth: _screenWidth,
              screenHeight: _screenHeight,
            );
          },
        );
      },
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return _ErrorView(
      errorMessage: errorMessage,
      onRetry: _controller.fetchAnalyticsData,
      screenWidth: _screenWidth,
      screenHeight: _screenHeight,
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String label;
  final Widget child;

  const _FilterSection({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.035,
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _CustomDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final double screenWidth;
  final double screenHeight;

  const _CustomDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight * 0.055,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: screenWidth * 0.05,
          ),
          isExpanded: true,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: Colors.black87,
          ),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onTap;
  final double screenWidth;
  final double screenHeight;

  const _DateField({
    required this.controller,
    required this.onTap,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight * 0.055,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        style: TextStyle(fontSize: screenWidth * 0.035),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03,
            vertical: screenHeight * 0.015,
          ),
          border: InputBorder.none,
          hintText: 'Select date',
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: screenWidth * 0.035,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final VoidCallback onPressed;
  final double screenWidth;
  final double screenHeight;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.backgroundColor,
    required this.onPressed,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenHeight * 0.055,
      height: screenHeight * 0.055,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: backgroundColor == null
            ? Border.all(color: Colors.grey.shade300)
            : null,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: screenWidth * 0.045,
          color: color,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _AnalyticsHeaderCard extends StatelessWidget {
  final int maleCount;
  final int femaleCount;
  final double screenWidth;
  final double screenHeight;

  const _AnalyticsHeaderCard({
    required this.maleCount,
    required this.femaleCount,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.02),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.bar_chart,
              color: Colors.blue,
              size: screenWidth * 0.05,
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Text(
            'Daily Analytics',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.025,
              vertical: screenHeight * 0.008,
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$maleCount + $femaleCount = ${maleCount + femaleCount}',
              style: TextStyle(
                fontSize: screenWidth * 0.032,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsTable extends StatelessWidget {
  final Map<String, List<AnalyticsItem>> groupedItems;
  final double screenWidth;
  final double screenHeight;

  const _AnalyticsTable({
    required this.groupedItems,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          _buildTableContent(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
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
              _TableHeaderCell(text: '#', screenWidth: screenWidth, screenHeight: screenHeight),
              _TableHeaderCell(text: 'E ID', screenWidth: screenWidth, screenHeight: screenHeight),
              _TableHeaderCell(text: 'Name', screenWidth: screenWidth, screenHeight: screenHeight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
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
    );
  }

  List<TableRow> _buildTableRows() {
    final List<TableRow> rows = [];
    int counter = 1;

    if (groupedItems.isEmpty) return rows;

    groupedItems.forEach((position, items) {
      if (position.isNotEmpty && position != 'No Position') {
        rows.add(
          TableRow(
            children: [
              Container(),
              Container(),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.008,
                  horizontal: screenWidth * 0.02,
                ),
                child: Text(
                  position,
                  style: TextStyle(
                    fontSize: screenWidth * 0.032,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      for (var item in items) {
        rows.add(
          TableRow(
            children: [
              _TableCell(text: counter.toString(), screenWidth: screenWidth, screenHeight: screenHeight),
              _TableCell(text: item.empId, screenWidth: screenWidth, screenHeight: screenHeight),
              _TableCell(text: item.name, bold: true, screenWidth: screenWidth, screenHeight: screenHeight),
            ],
          ),
        );
        counter++;
      }
    });

    return rows;
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;
  final double screenWidth;
  final double screenHeight;

  const _TableHeaderCell({
    required this.text,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.012,
        horizontal: screenWidth * 0.02,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: screenWidth * 0.035,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool bold;
  final double screenWidth;
  final double screenHeight;

  const _TableCell({
    required this.text,
    this.bold = false,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.012,
        horizontal: screenWidth * 0.02,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: screenWidth * 0.032,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _NoDataWidget extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const _NoDataWidget({
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.08),
      child: Column(
        children: [
          Icon(
            Icons.search_off_outlined,
            size: screenWidth * 0.12,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          SizedBox(height: screenHeight * 0.015),
          Text(
            "No data found for selected filters",
            style: TextStyle(
              color: Colors.grey,
              fontSize: screenWidth * 0.037,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          Text(
            "Try different date or shift",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: screenWidth * 0.032,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final double screenWidth;
  final double screenHeight;

  const _ErrorView({
    required this.errorMessage,
    required this.onRetry,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: screenWidth * 0.15,
            color: Colors.red.withValues(alpha: 0.5),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            "Error loading data",
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
            child: Text(
              errorMessage,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: screenWidth * 0.035,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.012,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Retry',
              style: TextStyle(fontSize: screenWidth * 0.035),
            ),
          ),
        ],
      ),
    );
  }
}