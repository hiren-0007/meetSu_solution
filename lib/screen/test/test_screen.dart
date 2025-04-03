import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/test/test_controller.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';
import 'package:meetsu_solutions/model/test/test_response_model.dart';

class TestScreen extends StatefulWidget {
  final Map<String, dynamic> trainingData;

  const TestScreen({super.key, required this.trainingData});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late final TestController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TestController(widget.trainingData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.giveTest(context);
    });
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
        appBar: AppBar(
          title: Text("${widget.trainingData['title'] ?? 'Training Test'}"),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.15,
                decoration: AppTheme.headerContainerDecoration,
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(AppTheme.cardPadding),
                        decoration: AppTheme.cardDecoration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Load Test",
                              style: AppTheme.headerStyle,
                            ),
                            SizedBox(height: AppTheme.smallSpacing),
                            Text(
                              "Enter training ID to load test questions",
                              style: AppTheme.subHeaderStyle,
                            ),
                            SizedBox(height: AppTheme.largeSpacing),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Training ID: ${widget.trainingData['training_id']}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Title: ${widget.trainingData['title'] ?? 'N/A'}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            ValueListenableBuilder<String?>(
                              valueListenable: _controller.errorMessage,
                              builder: (context, errorMessage, _) {
                                return errorMessage != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          errorMessage,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              },
                            ),
                            SizedBox(height: AppTheme.largeSpacing - 10),
                            ValueListenableBuilder<bool>(
                              valueListenable: _controller.isLoading,
                              builder: (context, isLoading, _) {
                                return ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () async {
                                          await _controller.giveTest(context);
                                        },
                                  style: AppTheme.primaryButtonStyle,
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          "REFRESH TEST",
                                          style: AppTheme.buttonTextStyle,
                                        ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppTheme.largeSpacing),
                      ValueListenableBuilder<TestResponseModel?>(
                        valueListenable: _controller.testResponse,
                        builder: (context, testResponseModel, _) {
                          if (testResponseModel == null) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 40),
                                  CircularProgressIndicator(),
                                  SizedBox(height: 20),
                                  Text("Loading test questions..."),
                                ],
                              ),
                            );
                          }

                          if (testResponseModel.data == null ||
                              testResponseModel.data!.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(AppTheme.cardPadding),
                              decoration: AppTheme.cardDecoration,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.warning,
                                      color: Colors.orange, size: 48),
                                  SizedBox(height: 16),
                                  Text(
                                    "No test questions available",
                                    style: AppTheme.headerStyle,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "There are no questions available for this training.",
                                    textAlign: TextAlign.center,
                                    style: AppTheme.subHeaderStyle,
                                  ),
                                ],
                              ),
                            );
                          }

                          return Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(AppTheme.cardPadding),
                            decoration: AppTheme.cardDecoration,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Test Questions",
                                  style: AppTheme.headerStyle,
                                ),
                                const SizedBox(height: 10),
                                const Divider(),
                                const SizedBox(height: 10),
                                ...buildQuestionsWidgets(testResponseModel),
                                const SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: _controller.allQuestionsAnswered
                                        ? () => _controller
                                            .showSignatureDialog(context)
                                        : null,
                                    style: AppTheme.primaryButtonStyle,
                                    child: const Text(
                                      "Submit Test",
                                      style: AppTheme.buttonTextStyle,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildQuestionsWidgets(TestResponseModel testResponseModel) {
    final List<Widget> widgets = [];

    if (testResponseModel.data != null) {
      final List<Data> data = testResponseModel.data!;

      for (int i = 0; i < data.length; i++) {
        final questionData = data[i].questionData;
        final answers = data[i].answer;

        if (questionData != null) {
          widgets.add(
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Q${i + 1}: ${questionData.question ?? 'No question text'}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (questionData.image != null &&
                      questionData.image!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Image.network(
                        _getFullImageUrl(
                            data[i].imageUrl ?? questionData.image!),
                        errorBuilder: (context, error, stackTrace) =>
                            Text("Error loading image: ${error.toString()}"),
                      ),
                    ),
                  if (answers != null && answers.isNotEmpty)
                    ...answers.map((answer) {
                      final questionId = questionData.id.toString();
                      final answerId = answer.id.toString();

                      return RadioListTile<String>(
                        title: Text(answer.answer ?? 'No answer text'),
                        value: answerId,
                        groupValue: _controller.selectedAnswers[questionId],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _controller.selectAnswer(questionId, value);
                            });
                          }
                        },
                        dense: true,
                        activeColor: AppTheme.primaryColor,
                      );
                    }).toList(),
                ],
              ),
            ),
          );
        }
      }
    }

    if (widgets.isEmpty) {
      widgets.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "No questions could be loaded. Please try again.",
              style: TextStyle(
                color: Colors.red.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  String _getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    final baseUrl = 'https://meetsusolutions.com';
    final separator = imagePath.startsWith('/') ? '' : '/';
    return '$baseUrl$separator$imagePath';
  }
}
