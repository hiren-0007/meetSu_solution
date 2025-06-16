import 'package:flutter/material.dart';
import 'package:meetsu_solutions/clint/c_screen/cs_job/clint_send_job_request_controller.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class ClintSendJobRequestScreen extends StatefulWidget {
  const ClintSendJobRequestScreen({super.key});

  @override
  State<ClintSendJobRequestScreen> createState() =>
      _ClintSendJobRequestScreenState();
}

class _ClintSendJobRequestScreenState extends State<ClintSendJobRequestScreen> {
  final ClintSendJobRequestController _controller = ClintSendJobRequestController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _personsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('MMM dd, yyyy').format(DateTime.now());
  }

  @override
  void dispose() {
    _dateController.dispose();
    _personsController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
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
                      // Logo
                      Container(
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
                      ),

                      // Title
                      const Text(
                        'MEETsu Solutions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Username
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
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _controller.hasData,
                    builder: (context, hasData, _) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: _controller.isLoading,
                        builder: (context, isLoading, _) {
                          if (isLoading && !hasData) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(50.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          return ListView(
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
                                    SizedBox(width: 10),
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
                                    _buildShiftField(),
                                    const SizedBox(height: 14),
                                    _buildDateField(),
                                    const SizedBox(height: 14),
                                    _buildPositionField(),
                                    const SizedBox(height: 14),
                                    _buildNoOfPersonsField(),
                                    const SizedBox(height: 14),
                                    _buildTypeField(),
                                    const SizedBox(height: 30),
                                    _buildSendButton(),
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
            ),
          ),
        ],
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
          child: ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: _controller.shiftOptions,
            builder: (context, shiftOptions, _) {
              return ValueListenableBuilder<String?>(
                valueListenable: _controller.selectedShift,
                builder: (context, selectedShift, _) {
                  return DropdownButtonFormField<String>(
                    value: selectedShift,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.access_time,
                        color: AppTheme.primaryClintColor,
                      ),
                    ),
                    items: shiftOptions.map((Map<String, dynamic> shift) {
                      return DropdownMenuItem<String>(
                        value: shift['id'],
                        child: Text(shift['display'] ?? shift['name']),
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
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_month, color: AppTheme.primaryClintColor),
                onPressed: () => _selectDate(context),
              ),
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPositionField() {
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
          child: ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: _controller.positionOptions,
            builder: (context, positionOptions, _) {
              return ValueListenableBuilder<String?>(
                valueListenable: _controller.selectedPosition,
                builder: (context, selectedPosition, _) {
                  return DropdownButtonFormField<String>(
                    value: selectedPosition,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.work,
                        color: AppTheme.primaryClintColor,
                      ),
                    ),
                    items: positionOptions.map((Map<String, dynamic> position) {
                      return DropdownMenuItem<String>(
                        value: position['id'],
                        child: Text(position['display'] ?? position['name']),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      _controller.selectedPosition.value = value;
                    },
                    hint: const Text('Select Position'),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryClintColor),
                    dropdownColor: Colors.white,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoOfPersonsField() {
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
            controller: _personsController,
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
            style: const TextStyle(fontSize: 16),
            onChanged: (value) {
              if (value.isNotEmpty) {
                _controller.setNumberOfPersons(int.tryParse(value) ?? 0);
              } else {
                _controller.setNumberOfPersons(0);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTypeField() {
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
              return ValueListenableBuilder<String?>(
                valueListenable: _controller.selectedType,
                builder: (context, selectedType, _) {
                  return DropdownButtonFormField<String>(
                    value: selectedType,
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
                      _controller.selectedType.value = value;
                    },
                    hint: const Text('Select Type'),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryClintColor),
                    dropdownColor: Colors.white,
                  );
                },
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
            onPressed: isLoading ? null : () => _sendJobRequest(),
            icon: isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.send, color: Colors.white),
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

  void _sendJobRequest() {
    // Validate form
    if (_controller.selectedShift.value == null) {
      _showErrorMessage('Please select a shift');
      return;
    }

    if (_dateController.text.isEmpty) {
      _showErrorMessage('Please select a date');
      return;
    }

    if (_controller.selectedPosition.value == null) {
      _showErrorMessage('Please select a position');
      return;
    }

    if (_personsController.text.isEmpty || _controller.numberOfPersons.value <= 0) {
      _showErrorMessage('Please enter number of persons');
      return;
    }

    if (_controller.selectedType.value == null) {
      _showErrorMessage('Please select a type');
      return;
    }

    // Send job request
    _controller.sendJobRequest().then((_) {
      if (_controller.errorMessage.value == null) {
        _showSuccessMessage('Job request sent successfully!');

        // Reset form
        setState(() {
          _controller.selectedShift.value = null;
          _controller.selectedPosition.value = null;
          _controller.selectedType.value = null;
          _personsController.clear();
          _dateController.text = DateFormat('MMM dd, yyyy').format(DateTime.now());
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