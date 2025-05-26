import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meetsu_solutions/model/quiz/get_quiz_response_model.dart';
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
  final ValueNotifier<int> durationSeconds = ValueNotifier<int>(1200); // 20 minutes default

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

      final quizDataResponse = await _apiService.getQuiz();
      debugPrint("📥 Quiz API Response: $quizDataResponse");

      // Parse the response using the model
      final quizResponse = GetQuizResponseModel.fromJson(quizDataResponse);

      // Check if quiz data is valid
      if (quizResponse.quiz != null) {
        final quiz = quizResponse.quiz!;

        // Extract quiz data using the model
        quizId.value = quiz.id ?? 0;
        question.value = quiz.question ?? "";
        correctAnswer.value = quiz.answer ?? "";
        // Since API doesn't return 'taken' field, we'll manage it locally
        // quizTaken.value = false; // Always start as not taken

        // Extract duration from the response (in seconds)
        durationSeconds.value = quizResponse.duration ?? 1200; // Default 20 minutes = 1200 seconds

        debugPrint("✅ Quiz data loaded:");
        debugPrint("   ID: ${quizId.value}");
        debugPrint("   Question: ${question.value}");
        debugPrint("   Duration: ${durationSeconds.value} seconds");
        debugPrint("   Already taken: ${quizTaken.value}");
        debugPrint("   Quiz status: ${quiz.status}");

        // Start timer since quiz is available
        if (!quizTaken.value) {
          startQuizTimer();
          debugPrint("⏰ Quiz timer started for ${durationSeconds.value} seconds");
        }

        // Return whether the quiz should be shown (based on 'show' field)
        final shouldShow = (quizResponse.show ?? 0) == 1;
        debugPrint("🎯 Should show quiz: $shouldShow");

        return shouldShow;
      } else {
        errorMessage.value = "No quiz data available";
        debugPrint("❌ No quiz data found in response");
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
    if (_quizTimer != null) {
      _quizTimer!.cancel();
      debugPrint("⏰ Quiz timer stopped - answer submitted");
    }

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

      // Clear the answer field after successful submission
      answerController.clear();

      return response;
    } catch (e) {
      errorMessage.value = "Failed to submit answer: ${e.toString()}";
      debugPrint("❌ Error submitting answer: $e");
      return {
        'success': false,
        'message': 'Failed to submit answer. Please try again.'
      };
    } finally {
      isLoading.value = false;
    }
  }

  void startQuizTimer() {
    // Set initial time in seconds (duration is already in seconds)
    remainingSeconds.value = durationSeconds.value;

    // Cancel any existing timer
    _quizTimer?.cancel();

    // Start new timer
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        // Time's up - cancel timer
        _quizTimer?.cancel();
        debugPrint("⏰ Quiz time expired!");
      }
    });
  }

  void stopTimer() {
    _quizTimer?.cancel();
    debugPrint("⏰ Quiz timer stopped manually");
  }

  String get formattedTime {
    final minutes = (remainingSeconds.value / 60).floor();
    final seconds = remainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Helper method to check if time is running low (less than 5 minutes)
  bool get isTimeRunningLow {
    return remainingSeconds.value < 300; // 5 minutes in seconds
  }

  // Helper method to check if time is critical (less than 1 minute)
  bool get isTimeCritical {
    return remainingSeconds.value < 60; // 1 minute in seconds
  }

  void dispose() {
    debugPrint("🧹 Disposing QuizController resources");

    // Cancel timer
    _quizTimer?.cancel();

    // Dispose ValueNotifiers
    isLoading.dispose();
    errorMessage.dispose();
    quizId.dispose();
    question.dispose();
    correctAnswer.dispose();
    quizTaken.dispose();
    durationSeconds.dispose();
    remainingSeconds.dispose();

    // Dispose TextEditingController
    answerController.dispose();

    debugPrint("✅ QuizController disposed successfully");
  }
}