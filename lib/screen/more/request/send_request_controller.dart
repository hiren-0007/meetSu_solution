import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';

class SendRequestController {
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final ValueNotifier<List<Offset?>> signaturePoints =
      ValueNotifier<List<Offset?>>([]);
  final ValueNotifier<bool> isTypedSignature = ValueNotifier<bool>(true);
  final TextEditingController signatureController = TextEditingController();

  final ValueNotifier<DateTime> selectedDate =
      ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<List<RequestRecord>> records =
      ValueNotifier<List<RequestRecord>>([]);

  final DateFormat _dateFormat = DateFormat('MMM-dd-yyyy');

  final ApiService _apiService;

  SendRequestController(this._apiService);

  void initialize() {
    refreshRecords();
  }

  String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

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

  void refreshRecords() {
    isLoading.value = true;

    Future.delayed(const Duration(seconds: 1), () {
      records.value = [
        RequestRecord(
          id: "1",
          amount: 100.00,
          reason: "this is test",
          date: DateTime.now(),
        ),
      ];

      isLoading.value = false;
    });
  }

  void downloadRecord(RequestRecord record) {
    debugPrint("Downloading record: ${record.id}");
  }

  void showRequestDialog(BuildContext context) {
    errorMessage.value = null;

    if (reasonController.text.isEmpty) {
      errorMessage.value = "Please enter a reason for your request";
      return;
    }

    amountController.clear();
    nameController.clear();
    signatureController.clear();
    signaturePoints.value = [];

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
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                          enabled: false,
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
                          onTap: () {
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              if (MediaQuery.of(context).viewInsets.bottom >
                                  0) {}
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
                        const Text(
                          "Review your signature",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ValueListenableBuilder<bool>(
                            valueListenable: isTypedSignature,
                            builder: (context, isTyped, _) {
                              if (isTyped) {
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                    'https://placeholder.com/wp-content/uploads/2018/10/placeholder.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        isTypedSignature.value = true;
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
                                  ElevatedButton(
                                    onPressed: () {
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
                        Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  'https://placeholder.com/wp-content/uploads/2018/10/placeholder.png'),
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
                        Container(
                          padding: const EdgeInsets.only(top: 12, bottom: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();

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
                              ElevatedButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();

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

                                  Navigator.pop(context);

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

  Future<File?> getSignatureAsFile() async {
    try {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final size = const Size(300, 150);

      if (isTypedSignature.value) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: signatureController.text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontFamily: 'Signature',
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        textPainter.layout(maxWidth: size.width);

        final bgPaint = Paint()..color = Colors.white;
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

        textPainter.paint(
            canvas,
            Offset((size.width - textPainter.width) / 2,
                (size.height - textPainter.height) / 2));
      } else {
        final paint = Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 3.0;

        final bgPaint = Paint()..color = Colors.white;
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

        for (int i = 0; i < signaturePoints.value.length - 1; i++) {
          if (signaturePoints.value[i] != null &&
              signaturePoints.value[i + 1] != null) {
            canvas.drawLine(signaturePoints.value[i]!,
                signaturePoints.value[i + 1]!, paint);
          } else if (signaturePoints.value[i] != null &&
              signaturePoints.value[i + 1] == null) {
            canvas.drawPoints(
                PointMode.points, [signaturePoints.value[i]!], paint);
          }
        }
      }

      final picture = recorder.endRecording();
      final img =
          await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await img.toByteData(format: ImageByteFormat.png);

      if (byteData == null) return null;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/signature.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file;
    } catch (e) {
      debugPrint("Error creating signature file: $e");
      return null;
    }
  }

  Future<void> submitRequestWithSignature(BuildContext context) async {
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

    isLoading.value = true;

    try {
      final token = SharedPrefsService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        errorMessage.value =
            "No authentication token found. Please log in again.";
        isLoading.value = false;
        return;
      }

      _apiService.client.addAuthToken(token);

      final signatureFile = await getSignatureAsFile();
      if (signatureFile == null) {
        errorMessage.value = "Failed to create signature file";
        isLoading.value = false;
        return;
      }

      final Map<String, dynamic> requestData = {
        'amount': amount.toString(),
        'reason': reasonController.text,
      };

      final response = await _apiService.addDeductionWithSignature(
          requestData, signatureFile, 'sign_name');

      isLoading.value = false;

      if (response['success'] == true || response['status'] == 'success') {
        final newRecord = RequestRecord(
          id: response['id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          amount: amount,
          reason: reasonController.text,
          date: selectedDate.value,
        );

        records.value = [newRecord, ...records.value];

        reasonController.clear();
        selectedDate.value = DateTime.now();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Request submitted successfully"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final message = response['message'] ??
            response['Message'] ??
            'Unknown error occurred';
        errorMessage.value = message;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: $message"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      isLoading.value = false;

      String errorMsg;
      if (e.toString().contains("Connection closed") ||
          e.toString().contains("SocketException") ||
          e.toString().contains("Connection refused") ||
          e.toString().contains("Connection timeout")) {
        errorMsg =
            "Network connection error. Please check your internet and try again.";
      } else if (e.toString().contains("Unauthorized") ||
          e.toString().contains("401")) {
        errorMsg = "Your session has expired. Please log in again.";
      } else {
        errorMsg = "Failed to submit request: ${e.toString()}";
      }

      errorMessage.value = errorMsg;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $errorMsg"),
            backgroundColor: Colors.red,
          ),
        );
      }

      debugPrint("❌ Error submitting request: $e");
    }
  }

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
