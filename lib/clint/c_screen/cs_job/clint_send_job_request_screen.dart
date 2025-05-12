import 'package:flutter/material.dart';
import 'package:meetsu_solutions/clint/c_screen/cs_job/clint_send_job_request_controller.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class ClintSendJobRequestScreen extends StatefulWidget {
  const ClintSendJobRequestScreen({super.key});

  @override
  State<ClintSendJobRequestScreen> createState() => _ClintSendJobRequestScreenState();
}

class _ClintSendJobRequestScreenState extends State<ClintSendJobRequestScreen> {
  final ClintSendJobRequestController _controller = ClintSendJobRequestController();
  final TextEditingController _dateController = TextEditingController();

  // Lists to manage multiple position rows
  final List<TextEditingController> _personsControllers = [];
  final List<String?> _selectedPositions = [];
  final List<String?> _selectedTypes = [];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('MMM dd, yyyy').format(DateTime.now());

    // Add initial position row
    _addPositionRow();
  }

  void _addPositionRow() {
    setState(() {
      _personsControllers.add(TextEditingController());
      _selectedPositions.add(null);
      _selectedTypes.add(null);
    });
  }

  void _removePositionRow(int index) {
    if (_personsControllers.length <= 1) {
      // Don't remove if it's the last row
      return;
    }

    setState(() {
      _personsControllers[index].dispose();
      _personsControllers.removeAt(index);
      _selectedPositions.removeAt(index);
      _selectedTypes.removeAt(index);
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    for (var controller in _personsControllers) {
      controller.dispose();
    }
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
              height: MediaQuery.of(context).size.height * 0.15,
              decoration: AppTheme.headerClintContainerDecoration,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo in left corner
                      Container(
                        height: 35,
                        width: 35,
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

                      // Title in center
                      const Text(
                        'Send Job Request',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Username in right corner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          SharedPrefsService.instance.getUsername(),
                          style: TextStyle(
                            color: AppTheme.primaryClintColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content
          Positioned(
            top: MediaQuery.of(context).size.height * 0.16,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.mediumBorderRadius),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.mediumBorderRadius),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryClintGradient,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.work_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            const Text(
                              'Job Request Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAddMoreButton(),
                            const SizedBox(height: 20),
                            // Shift and Date section
                            _buildShiftField(),
                            const SizedBox(height: 16),
                            _buildDateField(),
                            const SizedBox(height: 24),

                            // Multiple position rows
                            ..._buildPositionRows(),

                            const SizedBox(height: 24),
                            _buildSendButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPositionRows() {
    final List<Widget> rows = [];

    for (int i = 0; i < _personsControllers.length; i++) {
      // Only add a divider after the first row
      if (i > 0) {
        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              height: 1,
              color: Colors.grey.shade200,
            ),
          ),
        );
      }

      rows.add(
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryClintColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Position ${i + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_personsControllers.length > 1)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _removePositionRow(i),
                      tooltip: 'Remove',
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Position field
              _buildPositionField(i),
              const SizedBox(height: 16),

              // No Of Persons field
              _buildNoOfPersonsField(i),
              const SizedBox(height: 16),

              // Type field
              _buildTypeField(i),
            ],
          ),
        ),
      );
    }

    return rows;
  }

  Widget _buildAddMoreButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: TextButton.icon(
        onPressed: _addPositionRow,
        icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryClintColor),
        label: const Text(
          'Add Position',
          style: TextStyle(
            color: AppTheme.primaryClintColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppTheme.primaryClintColor.withOpacity(0.5)),
          ),
          backgroundColor: AppTheme.primaryClintColor.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildShiftField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Shift', isRequired: true),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ValueListenableBuilder<List<String>>(
            valueListenable: _controller.shiftOptions,
            builder: (context, shiftOptions, _) {
              return DropdownButtonFormField<String>(
                value: _controller.selectedShift.value,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.access_time,
                    color: AppTheme.primaryClintColor,
                  ),
                ),
                items: shiftOptions.map((String shift) {
                  return DropdownMenuItem<String>(
                    value: shift,
                    child: Text(shift),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    _controller.selectedShift.value = value;
                  }
                },
                hint: const Text('Select Shift'),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryClintColor),
                dropdownColor: Colors.white,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Date', isRequired: true),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: TextField(
            controller: _dateController,
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.calendar_today,
                color: AppTheme.primaryClintColor,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      _dateController.clear();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month, color: AppTheme.primaryClintColor),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryClintColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dateController.text = DateFormat('MMM dd, yyyy').format(picked);
      _controller.setSelectedDate(picked);
    }
  }

  Widget _buildPositionField(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Position', isRequired: true),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: ValueListenableBuilder<List<String>>(
            valueListenable: _controller.positionOptions,
            builder: (context, positionOptions, _) {
              return DropdownButtonFormField<String>(
                value: _selectedPositions[index],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.work,
                    color: AppTheme.primaryClintColor,
                  ),
                ),
                items: positionOptions.map((String position) {
                  return DropdownMenuItem<String>(
                    value: position,
                    child: Text(position),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedPositions[index] = value;
                  });
                },
                hint: const Text('Select Position'),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryClintColor),
                dropdownColor: Colors.white,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoOfPersonsField(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('No Of Persons', isRequired: true),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: TextField(
            controller: _personsControllers[index],
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.people,
                color: AppTheme.primaryClintColor,
              ),
              hintText: 'Enter number of persons',
            ),
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeField(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Type', isRequired: true),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: ValueListenableBuilder<List<String>>(
            valueListenable: _controller.typeOptions,
            builder: (context, typeOptions, _) {
              return DropdownButtonFormField<String>(
                value: _selectedTypes[index],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.category,
                    color: AppTheme.primaryClintColor,
                  ),
                ),
                items: typeOptions.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedTypes[index] = value;
                  });
                },
                hint: const Text('Select Type'),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryClintColor),
                dropdownColor: Colors.white,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.errorColor,
            ),
          ),
      ],
    );
  }

  Widget _buildSendButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.isLoading,
      builder: (context, isLoading, _) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : () => _sendJobRequests(),
            icon: isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.send),
            label: Text(isLoading ? 'Sending...' : 'SEND REQUEST'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryClintColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
            ),
          ),
        );
      },
    );
  }

  void _sendJobRequests() {
    // Validate form
    if (_controller.selectedShift.value == null) {
      _showErrorMessage('Please select a shift');
      return;
    }

    if (_dateController.text.isEmpty) {
      _showErrorMessage('Please select a date');
      return;
    }

    // Prepare job requests from all position rows
    final List<Map<String, dynamic>> requests = [];
    bool hasError = false;

    for (int i = 0; i < _personsControllers.length; i++) {
      // Skip empty rows
      if (_selectedPositions[i] == null &&
          _personsControllers[i].text.isEmpty &&
          _selectedTypes[i] == null) {
        continue;
      }

      // Validate position row
      if (_selectedPositions[i] == null) {
        _showErrorMessage('Please select a position for row ${i + 1}');
        hasError = true;
        break;
      }

      if (_personsControllers[i].text.isEmpty) {
        _showErrorMessage('Please enter number of persons for row ${i + 1}');
        hasError = true;
        break;
      }

      if (_selectedTypes[i] == null) {
        _showErrorMessage('Please select a type for row ${i + 1}');
        hasError = true;
        break;
      }

      // Add valid request
      requests.add({
        'shift': _controller.selectedShift.value,
        'date': _controller.selectedDate.value,
        'position': _selectedPositions[i],
        'numberOfPersons': int.parse(_personsControllers[i].text),
        'type': _selectedTypes[i],
      });
    }

    if (hasError) {
      return;
    }

    if (requests.isEmpty) {
      _showErrorMessage('Please add at least one valid position request');
      return;
    }

    // Send all job requests
    _controller.jobRequests.value = requests;
    _controller.sendJobRequest().then((_) {
      if (_controller.errorMessage.value == null) {
        _showSuccessMessage('Job requests sent successfully!');

        // Reset form
        setState(() {
          _controller.selectedShift.value = null;
          _dateController.text = DateFormat('MMM dd, yyyy').format(DateTime.now());

          // Clear all position rows except first
          for (int i = _personsControllers.length - 1; i > 0; i--) {
            _personsControllers[i].dispose();
            _personsControllers.removeAt(i);
            _selectedPositions.removeAt(i);
            _selectedTypes.removeAt(i);
          }

          // Clear first row
          _personsControllers[0].clear();
          _selectedPositions[0] = null;
          _selectedTypes[0] = null;
        });
      } else {
        _showErrorMessage(_controller.errorMessage.value!);
      }
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}