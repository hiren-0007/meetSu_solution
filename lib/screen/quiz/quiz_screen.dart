import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/quiz/quiz_controller.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';

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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Quiz Challenge",
          style: AppTheme.titleStyle,
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.white),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _controller.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                  SizedBox(height: AppTheme.mediumSpacing),
                  Text(
                    "Loading quiz...",
                    style: TextStyle(
                      fontSize: AppTheme.textSizeRegular,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ValueListenableBuilder<String?>(
            valueListenable: _controller.errorMessage,
            builder: (context, errorMessage, child) {
              if (errorMessage != null && errorMessage.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.mediumSpacing),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.mediumSpacing),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline,
                            color: AppTheme.errorColor,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: AppTheme.mediumSpacing),
                        Text(
                          "Oops! Something went wrong",
                          style: TextStyle(
                            fontSize: AppTheme.textSizeMedium,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: AppTheme.extraSmallSpacing),
                        Text(
                          errorMessage,
                          style: TextStyle(
                            fontSize: AppTheme.textSizeRegular,
                            color: AppTheme.textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.mediumSpacing),
                        ElevatedButton.icon(
                          onPressed: () => _loadQuizData(),
                          icon: const Icon(Icons.refresh),
                          label: const Text("Try Again"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: AppTheme.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.mediumSpacing,
                              vertical: AppTheme.smallSpacing,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.extraSmallBorderRadius),
                            ),
                          ),
                        ),
                      ],
                    ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.contentSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timer Card
          ValueListenableBuilder<int>(
            valueListenable: _controller.remainingSeconds,
            builder: (context, seconds, child) {
              final timeColor = seconds < 300 ? AppTheme.errorColor : AppTheme.primaryColor;
              final progress = seconds / _controller.durationSeconds.value;

              return Container(
                margin: const EdgeInsets.only(bottom: AppTheme.mediumSpacing),
                padding: const EdgeInsets.all(AppTheme.contentSpacing),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [timeColor.withOpacity(0.1), timeColor.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.smallBorderRadius),
                  border: Border.all(color: timeColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: timeColor,
                          size: AppTheme.mediumIconSize,
                        ),
                        const SizedBox(width: AppTheme.extraSmallSpacing),
                        Text(
                          "Time Remaining",
                          style: TextStyle(
                            fontSize: AppTheme.textSizeRegular,
                            fontWeight: FontWeight.w600,
                            color: timeColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.smallSpacing),
                    Text(
                      _controller.formattedTime,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: timeColor,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: AppTheme.smallSpacing),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.extraSmallBorderRadius),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppTheme.textSecondaryColor.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(timeColor),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Question Card
          Container(
            margin: const EdgeInsets.only(bottom: AppTheme.mediumSpacing),
            padding: const EdgeInsets.all(AppTheme.mediumSpacing),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.extraSmallSpacing),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.extraSmallBorderRadius),
                      ),
                      child: Icon(
                        Icons.quiz_outlined,
                        color: AppTheme.primaryColor,
                        size: AppTheme.smallIconSize,
                      ),
                    ),
                    const SizedBox(width: AppTheme.smallSpacing),
                    Text(
                      "Question",
                      style: TextStyle(
                        fontSize: AppTheme.titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.contentSpacing),
                ValueListenableBuilder<String>(
                  valueListenable: _controller.question,
                  builder: (context, question, child) {
                    return Text(
                      question,
                      style: const TextStyle(
                        fontSize: AppTheme.textSizeRegular,
                        height: 1.5,
                        color: AppTheme.textPrimaryColor,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Answer Section
          Container(
            padding: const EdgeInsets.all(AppTheme.mediumSpacing),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.extraSmallSpacing),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.extraSmallBorderRadius),
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        color: AppTheme.successColor,
                        size: AppTheme.smallIconSize,
                      ),
                    ),
                    const SizedBox(width: AppTheme.smallSpacing),
                    Text(
                      "Your Answer",
                      style: TextStyle(
                        fontSize: AppTheme.titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.contentSpacing),
                TextField(
                  controller: _controller.answerController,
                  decoration: InputDecoration(
                    hintText: "Type your answer here...",
                    hintStyle: TextStyle(color: AppTheme.textSecondaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.smallBorderRadius),
                      borderSide: BorderSide(color: AppTheme.textSecondaryColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.smallBorderRadius),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.textFieldPadding,
                        vertical: AppTheme.inputVerticalPadding
                    ),
                  ),
                  maxLines: 2,
                  minLines: 1,
                  style: const TextStyle(fontSize: AppTheme.textSizeRegular),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    FocusScope.of(context).unfocus();
                  },
                ),
                const SizedBox(height: AppTheme.mediumSpacing),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _submitAnswer(),
                    style: AppTheme.primaryButtonStyle,
                    child: const Text(
                      "Submit Answer",
                      style: AppTheme.buttonTextStyle,
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.mediumSpacing),

                // Warning Note
                Container(
                  padding: const EdgeInsets.all(AppTheme.smallSpacing),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.extraSmallBorderRadius),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: Colors.amber,
                        size: AppTheme.smallIconSize,
                      ),
                      SizedBox(width: AppTheme.extraSmallSpacing),
                      Expanded(
                        child: Text(
                          "You can only submit once, so double-check your answer!",
                          style: TextStyle(
                            fontSize: AppTheme.textSizeExtraSmall,
                            color: Colors.amber,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCompletedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.mediumSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: AppTheme.successColor,
                size: 80,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Quiz Completed!",
              style: TextStyle(
                fontSize: AppTheme.textSizeMediumLarge,
                fontWeight: FontWeight.bold,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(height: AppTheme.mediumSpacing),
            Text(
              "You've already submitted your answer for this quiz!",
              style: TextStyle(
                fontSize: AppTheme.textSizeRegular,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.extraSmallSpacing),
            Text(
              "Check back later for the results.",
              style: TextStyle(
                fontSize: AppTheme.textSizeExtraSmall,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back to Dashboard"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.mediumSpacing,
                  vertical: AppTheme.smallSpacing,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.extraSmallBorderRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitAnswer() async {
    // Validate answer
    if (_controller.answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your answer before submitting"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.smallBorderRadius),
        ),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppTheme.primaryColor),
            SizedBox(width: AppTheme.extraSmallSpacing),
            Text("Confirm Submission"),
          ],
        ),
        content: const Text(
          "Are you sure you want to submit your answer? You can only submit once.",
          style: TextStyle(fontSize: AppTheme.textSizeRegular),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.white,
            ),
            child: const Text("Submit"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Call submit API
    final response = await _controller.submitQuizAnswer();

    // Stop timer
    _controller.stopTimer();

    // Mark quiz as taken
    _controller.quizTaken.value = true;

    // Show response
    if (mounted) {
      if (response.containsKey('message')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: response.containsKey('correct') &&
                response['correct'] == true
                ? AppTheme.successColor
                : AppTheme.primaryColor,
          ),
        );
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.smallBorderRadius),
          ),
          title: Row(
            children: [
              Icon(
                response.containsKey('correct') && response['correct'] == true
                    ? Icons.check_circle
                    : Icons.info,
                color: response.containsKey('correct') && response['correct'] == true
                    ? AppTheme.successColor
                    : AppTheme.primaryColor,
              ),
              const SizedBox(width: AppTheme.extraSmallSpacing),
              Text(
                response.containsKey('correct') && response['correct'] == true
                    ? "Correct Answer!"
                    : "Thank You",
                style: TextStyle(
                  color: response.containsKey('correct') && response['correct'] == true
                      ? AppTheme.successColor
                      : AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          content: Text(
            response['message'] ?? "Your answer has been submitted.",
            style: const TextStyle(fontSize: AppTheme.textSizeRegular),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {});
              },
              child: const Text(
                "OK",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }
}