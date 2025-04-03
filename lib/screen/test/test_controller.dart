import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/model/test/test_response_model.dart';
import 'package:path_provider/path_provider.dart';

class TestController {
  final Map<String, dynamic> trainingData;

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<TestResponseModel?> testResponse =
      ValueNotifier<TestResponseModel?>(null);

  final Map<String, String> selectedAnswers = {};

  final ValueNotifier<List<Offset?>> signaturePoints =
      ValueNotifier<List<Offset?>>([]);
  final ValueNotifier<bool> isTypedSignature = ValueNotifier<bool>(true);
  final TextEditingController signatureController = TextEditingController();

  final ApiService _apiService;

  TestController(this.trainingData, {ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient());

  Future<bool> giveTest(BuildContext context) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      testResponse.value = null;

      final trainingId = trainingData['training_id'];

      if (trainingId == null) {
        errorMessage.value = "Training ID not found in training data";
        return false;
      }

      final token = SharedPrefsService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        errorMessage.value =
            "No authentication token found. Please login again.";
        return false;
      }

      _apiService.client.addAuthToken(token);

      final testRequest = {
        "training_id": trainingId,
      };

      final response = await _apiService.giveTest(testRequest);

      final testResponseData = TestResponseModel.fromJson(response);

      testResponse.value = testResponseData;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test data fetched successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      return true;
    } catch (e) {
      if (e is HttpException) {
        if (e.statusCode == 401) {
          errorMessage.value = "Unauthorized: Please login again";
        } else {
          errorMessage.value = "Server error: ${e.message}";
        }
      } else {
        errorMessage.value = "An error occurred: ${e.toString()}";
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void selectAnswer(String questionId, String answerId) {
    selectedAnswers[questionId] = answerId;
    debugPrint('Selected answer $answerId for question $questionId');
  }

  bool get allQuestionsAnswered {
    if (testResponse.value == null || testResponse.value!.data == null) {
      return false;
    }

    final List<Data> data = testResponse.value!.data!;
    final Set<String> questionIds = data
        .where((item) => item.questionData != null)
        .map((item) => item.questionData!.id.toString())
        .toSet();

    return questionIds.length == selectedAnswers.length;
  }

  void showSignatureDialog(BuildContext context) {
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
                          "Signature Required",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
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
                          height: 150,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                                        title:
                                            const Text("Type Your Signature"),
                                        content: TextField(
                                          controller: signatureController,
                                          decoration: const InputDecoration(
                                            hintText: "Enter your signature",
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
                                  style: TextStyle(color: Color(0xFF1565C0)),
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
                                  style: TextStyle(color: Color(0xFF1565C0)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
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
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  "Clear",
                                  style: TextStyle(color: Color(0xFF1565C0)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
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
                                if (isTypedSignature.value &&
                                    signatureController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Please type your signature")),
                                  );
                                  return;
                                }

                                if (!isTypedSignature.value &&
                                    signaturePoints.value.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Please draw your signature")),
                                  );
                                  return;
                                }

                                Navigator.pop(context);

                                submitTestAnswers(context);

                                Navigator.pushReplacementNamed(
                                    context, '/trainings');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                minimumSize: const Size(100, 40),
                              ),
                              child: const Text(
                                "Submit",
                                style: TextStyle(
                                  color: Color(0xFF1565C0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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

  Future<bool> submitTestAnswers(BuildContext context) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final token = SharedPrefsService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        errorMessage.value =
            "No authentication token found. Please login again.";
        return false;
      }

      _apiService.client.addAuthToken(token);

      final signatureFile = await getSignatureAsFile();
      if (signatureFile == null) {
        errorMessage.value = "Failed to create signature file";
        return false;
      }

      final requestData = {
        'training_id': trainingData['training_id'].toString(),
        'answer': jsonEncode(selectedAnswers),
      };

      debugPrint('Submitting test with data: $requestData');

      try {
        final response = await _apiService.submitTest(requestData,
            signatureFile: signatureFile);

        debugPrint('Test submission successful: $response');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Test submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
          Navigator.pop(context);
        }

        return true;
      } catch (e) {
        debugPrint('Error with API service, trying direct HTTP approach: $e');

        final uri = Uri.parse(
            'https://meetsusolutions.com/api/web/flutter/test-submit');
        final request = http.MultipartRequest('POST', uri);

        request.headers['Authorization'] = 'Bearer $token';

        request.fields['training_id'] = trainingData['training_id'].toString();
        request.fields['answer'] = jsonEncode(selectedAnswers);

        final fileStream = http.ByteStream(signatureFile.openRead());
        final fileLength = await signatureFile.length();

        final multipartFile = http.MultipartFile(
          'signature',
          fileStream,
          fileLength,
          filename: 'signature.png',
        );

        request.files.add(multipartFile);

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        debugPrint(
            'Direct HTTP response: ${response.statusCode} - ${response.body}');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Test submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context);
          Navigator.pop(context);
        }

        return true;
      }
    } catch (e) {
      debugPrint('Error submitting test: $e');
      errorMessage.value = "An error occurred: ${e.toString()}";
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
    testResponse.dispose();
    signaturePoints.dispose();
    isTypedSignature.dispose();
    signatureController.dispose();
  }
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
