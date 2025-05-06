import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class QuizController {
  final ApiService _apiService;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  // Quiz data
  final ValueNotifier<int> quizId = ValueNotifier<int>(0);
  final ValueNotifier<String> question = ValueNotifier<String>("");
  final ValueNotifier<String> correctAnswer = ValueNotifier<String>("");
  final ValueNotifier<bool> quizTaken = ValueNotifier<bool>(false);
  final ValueNotifier<int> durationMinutes = ValueNotifier<int>(20);

  // User's answer
  final TextEditingController answerController = TextEditingController();

  // Timer for quiz
  Timer? _quizTimer;
  final ValueNotifier<int> remainingSeconds = ValueNotifier<int>(0);

  QuizController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    initialize();
  }

  void initialize() {
    final token = SharedPrefsService.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _apiService.client.addAuthToken(token);
    }

    debugPrint("🔄 Initializing Quiz Controller...");
  }

  Future<bool> fetchQuizData() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      debugPrint("🧩 Fetching quiz data...");

      final quizData = await _apiService.getQuiz();
      debugPrint("📥 Quiz API Response: $quizData");

      if (quizData.containsKey('quiz')) {
        final quiz = quizData['quiz'];
        quizId.value = quiz['id'] ?? 0;
        question.value = quiz['question'] ?? "";
        correctAnswer.value = quiz['answer'] ?? "";
        quizTaken.value = (quiz['taken'] == 1);

        if (quizData.containsKey('duration')) {
          durationMinutes.value = quizData['duration'] ?? 20;
        }

        debugPrint("✅ Quiz data loaded: ID=${quizId.value}, Question: ${question.value}");

        if (!quizTaken.value) {
          startQuizTimer();
        }

        return quizData['show'] == 1;
      } else {
        errorMessage.value = "Invalid quiz data received";
        debugPrint("❌ Invalid quiz data format");
        return false;
      }
    } catch (e) {
      errorMessage.value = "Failed to load quiz: ${e.toString()}";
      debugPrint("❌ Error fetching quiz data: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> submitQuizAnswer() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final answerData = {
        'question_id': quizId.value.toString(),
        'answer': answerController.text.trim(),
      };

      debugPrint("📤 Submitting quiz answer: $answerData");

      // Use the API service to submit the answer
      final response = await _apiService.submitQuizAnswer(answerData);

      debugPrint("📥 Submit answer response: $response");

      // Update quiz taken status based on response
      if (response.containsKey('correct') != null) {
        quizTaken.value = true;
      }

      return response;
    } catch (e) {
      errorMessage.value = "Failed to submit answer: ${e.toString()}";
      debugPrint("❌ Error submitting answer: $e");
      return {'success': false, 'message': e.toString()};
    } finally {
      isLoading.value = false;
    }
  }

  void startQuizTimer() {
    remainingSeconds.value = durationMinutes.value * 60;

    _quizTimer?.cancel();
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _quizTimer?.cancel();
      }
    });
  }

  String get formattedTime {
    final minutes = (remainingSeconds.value / 60).floor();
    final seconds = remainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void dispose() {
    debugPrint("🧹 Disposing QuizController resources");
    isLoading.dispose();
    errorMessage.dispose();
    quizId.dispose();
    question.dispose();
    correctAnswer.dispose();
    quizTaken.dispose();
    durationMinutes.dispose();
    remainingSeconds.dispose();
    answerController.dispose();
    _quizTimer?.cancel();
  }
}