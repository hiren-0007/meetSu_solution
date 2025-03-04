import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SendRequestController {
  // Text editing controllers for form fields
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  // Signature-related controllers
  final ValueNotifier<List<Offset?>> signaturePoints =
      ValueNotifier<List<Offset?>>([]);
  final ValueNotifier<bool> isTypedSignature = ValueNotifier<bool>(true);
  final TextEditingController signatureController = TextEditingController();

  // ValueNotifiers for reactive state management
  final ValueNotifier<DateTime> selectedDate =
      ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<List<RequestRecord>> records =
      ValueNotifier<List<RequestRecord>>([]);

  // Date formatter
  final DateFormat _dateFormat = DateFormat('MMM-dd-yyyy');

  // Initialize the controller
  void initialize() {
    // Fetch initial records
    refreshRecords();
  }

  // Format date for display
  String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  // Select date using date picker
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
    }
  }

  // Refresh records list
  void refreshRecords() {
    // Simulate fetching records from API or database
    // In a real app, this would be an async call to your service layer
    isLoading.value = true;

    // Simulate network delay
    Future.delayed(const Duration(seconds: 1), () {
      records.value = [
        RequestRecord(
          id: "1",
          amount: 100.00,
          reason: "this is test",
          date: DateTime.now(),
        ),
        // Add more sample records as needed
      ];

      isLoading.value = false;
    });
  }

  // Download record (placeholder function)
  void downloadRecord(RequestRecord record) {
    // In a real app, this would initiate a download or generate a PDF
    debugPrint("Downloading record: ${record.id}");

    // Could show a snackbar or toast notification
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text("Downloading record #${record.id}")),
    // );
  }

  // Show the request dialog
  void showRequestDialog(BuildContext context) {
    // Reset error message
    errorMessage.value = null;

    // Validate main form
    if (reasonController.text.isEmpty) {
      errorMessage.value = "Please enter a reason for your request";
      return;
    }

    // Reset dialog controllers
    amountController.clear();
    nameController.clear();
    signatureController.clear();
    signaturePoints.value = [];

    // Show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              // Set alignment to top to prevent keyboard from pushing it up
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0), // Deep blue background
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Deduction Amount field
                        const Text(
                          "Deduction Amount",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Enter Amount",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Reason field
                        const Text(
                          "Reason",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: ValueNotifier(reasonController).value,
                          enabled: false, // Use the reason from the main screen
                          decoration: InputDecoration(
                            hintText: "Enter Reason",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name field
                        const Text(
                          "Print Your name",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: nameController,
                          textInputAction: TextInputAction.done,
                          // Helps with keyboard handling
                          onTap: () {
                            // Optional: Scroll the dialog when the field is tapped
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              if (MediaQuery.of(context).viewInsets.bottom >
                                  0) {
                                // This helps with scrolling when keyboard appears
                              }
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Type Your Name Here",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Signature section
                        const Text(
                          "Review your signature",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Signature canvas
                        Container(
                          height: 120, // Reduced height to save space
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ValueListenableBuilder<bool>(
                            valueListenable: isTypedSignature,
                            builder: (context, isTyped, _) {
                              if (isTyped) {
                                // Show typed signature
                                return Center(
                                  child: Text(
                                    signatureController.text,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontFamily: 'Signature',
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              } else {
                                // Show drawn signature
                                return GestureDetector(
                                  onPanUpdate: (details) {
                                    setState(() {
                                      RenderBox renderBox = context
                                          .findRenderObject() as RenderBox;
                                      Offset localPosition =
                                          renderBox.globalToLocal(
                                              details.globalPosition);
                                      signaturePoints.value =
                                          List.from(signaturePoints.value)
                                            ..add(localPosition);
                                    });
                                  },
                                  onPanEnd: (details) {
                                    setState(() {
                                      signaturePoints.value =
                                          List.from(signaturePoints.value)
                                            ..add(null);
                                    });
                                  },
                                  child: CustomPaint(
                                    painter: SignaturePainter(
                                      points: signaturePoints.value,
                                    ),
                                    size: Size.infinite,
                                  ),
                                );
                              }
                            },
                          ),
                        ),

                        // Signature buttons with warning stripes background
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                    'https://placeholder.com/wp-content/uploads/2018/10/placeholder.png'),
                                // Replace with your warning stripes image
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Type button
                                  ElevatedButton(
                                    onPressed: () {
                                      // Hide keyboard first to prevent layout issues
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        isTypedSignature.value = true;
                                        // Show a dialog to enter typed signature
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                                "Type Your Signature"),
                                            content: TextField(
                                              controller: signatureController,
                                              decoration: const InputDecoration(
                                                hintText:
                                                    "Enter your signature",
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      "Type",
                                      style:
                                          TextStyle(color: Color(0xFF1565C0)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Draw button
                                  ElevatedButton(
                                    onPressed: () {
                                      // Hide keyboard first to prevent layout issues
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        isTypedSignature.value = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      "Draw",
                                      style:
                                          TextStyle(color: Color(0xFF1565C0)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Clear button
                        Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  'https://placeholder.com/wp-content/uploads/2018/10/placeholder.png'),
                              // Replace with your warning stripes image
                              fit: BoxFit.cover,
                            ),
                          ),
                          padding: const EdgeInsets.only(
                              left: 4, right: 4, bottom: 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (isTypedSignature.value) {
                                    signatureController.clear();
                                  } else {
                                    signaturePoints.value = [];
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Clear",
                                style: TextStyle(color: Color(0xFF1565C0)),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Buttons row (Create and Cancel)
                        Container(
                          padding: const EdgeInsets.only(top: 12, bottom: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Cancel button
                              ElevatedButton(
                                onPressed: () {
                                  // Hide keyboard first
                                  FocusScope.of(context).unfocus();

                                  // Close the dialog
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  minimumSize: const Size(100, 40),
                                ),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // Create button
                              ElevatedButton(
                                onPressed: () {
                                  // Hide keyboard first
                                  FocusScope.of(context).unfocus();

                                  // Validate dialog inputs
                                  if (amountController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("Please enter an amount")),
                                    );
                                    return;
                                  }

                                  if (nameController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("Please enter your name")),
                                    );
                                    return;
                                  }

                                  if (isTypedSignature.value &&
                                      signatureController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Please type your signature")),
                                    );
                                    return;
                                  }

                                  if (!isTypedSignature.value &&
                                      signaturePoints.value.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Please draw your signature")),
                                    );
                                    return;
                                  }

                                  // Close the dialog
                                  Navigator.pop(context);

                                  // Submit the request with the dialog data
                                  submitRequestWithSignature(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  minimumSize: const Size(100, 40),
                                ),
                                child: const Text(
                                  "Create",
                                  style: TextStyle(
                                    color: Color(0xFF1565C0),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Submit the request with signature data
  void submitRequestWithSignature(BuildContext context) {
    // Parse amount
    double? amount;
    try {
      amount = double.parse(amountController.text);
      if (amount <= 0) {
        errorMessage.value = "Amount must be greater than zero";
        return;
      }
    } catch (e) {
      errorMessage.value = "Please enter a valid amount";
      return;
    }

    // Show loading state
    isLoading.value = true;

    // Create request data
    final requestData = {
      'reason': reasonController.text,
      'date': _dateFormat.format(selectedDate.value),
      'amount': amount,
      'name': nameController.text,
      'hasSignature': true,
      'signatureType': isTypedSignature.value ? 'typed' : 'drawn',
    };

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      // In a real app, this would be a call to your API service
      debugPrint("Submitting request with signature: $requestData");

      // Reset form on success
      reasonController.clear();
      selectedDate.value = DateTime.now();

      // Add the new record to the list
      final newRecord = RequestRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount!,
        reason: requestData['reason'] as String,
        date: selectedDate.value,
      );

      records.value = [newRecord, ...records.value];

      // Hide loading state
      isLoading.value = false;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Request submitted successfully"),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  // Clean up resources
  void dispose() {
    reasonController.dispose();
    amountController.dispose();
    nameController.dispose();
    signatureController.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    selectedDate.dispose();
    records.dispose();
    signaturePoints.dispose();
    isTypedSignature.dispose();
  }
}

// Model class for request records
class RequestRecord {
  final String id;
  final double amount;
  final String reason;
  final DateTime date;

  RequestRecord({
    required this.id,
    required this.amount,
    required this.reason,
    required this.date,
  });
}

// Signature painter for drawing signatures
class SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(PointMode.points, [points[i]!], paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) =>
      oldDelegate.points != points;
}
