import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/quiz/quiz_controller.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late QuizController _controller;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = QuizController();
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    final show = await _controller.fetchQuizData();

    if (!show && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No active quiz available at this time"),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _controller.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ValueListenableBuilder<String?>(
            valueListenable: _controller.errorMessage,
            builder: (context, errorMessage, child) {
              if (errorMessage != null && errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _loadQuizData();
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              }

              if (!_isDataLoaded) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return _buildQuizContent();
            },
          );
        },
      ),
    );
  }

  Widget _buildQuizContent() {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.quizTaken,
      builder: (context, quizTaken, child) {
        if (quizTaken) {
          return _buildQuizCompletedView();
        } else {
          return _buildActiveQuizView();
        }
      },
    );
  }

  Widget _buildActiveQuizView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Question:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable: _controller.remainingSeconds,
                        builder: (context, seconds, child) {
                          final timeColor =
                              seconds < 60 ? Colors.red : Colors.blue;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: timeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: timeColor),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.timer, size: 16, color: timeColor),
                                const SizedBox(width: 4),
                                Text(
                                  _controller.formattedTime,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: timeColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<String>(
                    valueListenable: _controller.question,
                    builder: (context, question, child) {
                      return Text(
                        question,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Your Answer:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller.answerController,
            decoration: InputDecoration(
              hintText: "Type your answer here",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_controller.answerController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Please enter your answer before submitting"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final response = await _controller.submitQuizAnswer();

                if (mounted) {
                  if (response.containsKey('message')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response['message']),
                        backgroundColor: response.containsKey('correct') &&
                                response['correct'] == true
                            ? Colors.green
                            : Colors.blue,
                      ),
                    );
                  }

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      title: Text(
                        response.containsKey('correct') &&
                                response['correct'] == true
                            ? "Correct Answer!"
                            : "Thank You",
                        style: TextStyle(
                          color: response.containsKey('correct') &&
                                  response['correct'] == true
                              ? Colors.green
                              : Colors.blue,
                        ),
                      ),
                      content: Text(response['message'] ??
                          "Your answer has been submitted."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {});
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Submit Answer",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "Note: You can only submit once, so double-check your answer!",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCompletedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              "You've already submitted your answer for this quiz!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Check back later for the results.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Back to Dashboard"),
            ),
          ],
        ),
      ),
    );
  }
}
