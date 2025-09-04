import 'package:flutter/material.dart';
import 'package:meetsu_solutions/model/job&ads/job/job_opening_response_model.dart';
import 'dart:async';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:share_plus/share_plus.dart';

class JobOpeningController {
  static const Duration _autoScrollInterval = Duration(seconds: 5);
  static const String _fallbackBaseUrl =
      "https://meetsusolutions.com/frontend/web/site/job?id=";

  final ApiService _apiService;

  final ValueNotifier<List<Jobs>> jobOpenings = ValueNotifier<List<Jobs>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isSharing = ValueNotifier<bool>(false);

  Timer? _autoScrollTimer;
  String? _cachedToken;
  PageController? _pageController;
  Function(int)? _onIndexChanged;
  int _currentIndex = 0;

  JobOpeningController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    _initializeController();
  }

  void _initializeController() {
    _cacheAuthToken();
    fetchJobOpenings();
  }

  void _cacheAuthToken() {
    _cachedToken = SharedPrefsService.instance.getAccessToken();
  }

  void startAutoScrollWithPageController(
      PageController pageController, Function(int) onIndexChanged) {
    _pageController = pageController;
    _onIndexChanged = onIndexChanged;
    _currentIndex = 0;
    _setupAutoScroll();
  }

  void updateCurrentIndex(int index) {
    _currentIndex = index;
  }

  void _setupAutoScroll() {
    _autoScrollTimer?.cancel();

    if (jobOpenings.value.isEmpty || _pageController == null) return;

    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (timer) {
      if (jobOpenings.value.isNotEmpty &&
          _pageController != null &&
          _pageController!.hasClients) {
        _currentIndex = (_currentIndex + 1) % jobOpenings.value.length;

        final currentPage = _pageController!.page?.round() ?? 0;
        final currentRealIndex = currentPage % jobOpenings.value.length;

        int targetPage;
        if (_currentIndex == 0 &&
            currentRealIndex == jobOpenings.value.length - 1) {
          targetPage = currentPage + 1;
        } else {
          targetPage = currentPage + 1;
        }

        _pageController!.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        _onIndexChanged?.call(_currentIndex);
      }
    });
  }

  Future<void> fetchJobOpenings() async {
    try {
      isLoading.value = true;

      final token =
          _cachedToken ?? SharedPrefsService.instance.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

      if (_cachedToken != token) {
        _cachedToken = token;
      }

      _apiService.client.addAuthToken(token);

      final response = await _apiService.getJobsOnly();
      await _processJobResponse(response);
    } catch (e) {
      _handleFetchError();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _processJobResponse(Map<String, dynamic> response) async {
    final jobsResponse = JobOpeningResponseModel.fromJson(response);

    if (jobsResponse.success == true &&
        jobsResponse.response?.jobs?.isNotEmpty == true) {
      jobOpenings.value = jobsResponse.response!.jobs!;
      _currentIndex = 0;
    } else {
      jobOpenings.value = [];
    }
  }

  void _handleFetchError() {
    jobOpenings.value = [];
  }

  Future<void> shareJob(BuildContext context, Jobs job) async {
    if (isSharing.value) return;

    try {
      isSharing.value = true;

      final shareLink = await _getShareLink(job);
      final shareText = _buildShareText(job, shareLink);

      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: job.jobPosition ?? 'Job Opening',
        ),
      );

      if (context.mounted) {
        _showShareSuccess(context);
      }
    } catch (e) {
      if (context.mounted) {
        await _handleShareError(context, job);
      }
    } finally {
      isSharing.value = false;
    }
  }

  Future<String> _getShareLink(Jobs job) async {
    try {
      final token =
          _cachedToken ?? SharedPrefsService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

      _apiService.client.addAuthToken(token);

      final requestData = {
        'id': job.jobId.toString(),
        'job_or_ad': '1',
        'medium': 'Whatsapp'
      };

      final response = await _apiService.getJobShare(requestData);
      return _extractShareLink(response, job);
    } catch (e) {
      return _getFallbackShareLink(job);
    }
  }

  String _extractShareLink(Map<String, dynamic> response, Jobs job) {
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to generate share link');
    }

    String shareLink = "";

    if (response['response']?['link'] != null) {
      shareLink = response['response']['link'];
    } else if (response['link'] != null) {
      shareLink = response['link'];
    }

    if (shareLink.isNotEmpty &&
        !shareLink.contains("job?id=") &&
        shareLink.contains("job-view?refid=")) {
      shareLink = "$_fallbackBaseUrl${job.jobId}";
    }

    if (shareLink.isEmpty) {
      throw Exception("Empty share link received from API");
    }

    return shareLink;
  }

  String _getFallbackShareLink(Jobs job) {
    return "$_fallbackBaseUrl${job.jobId}";
  }

  String _buildShareText(Jobs job, String shareLink) {
    final description = job.shareDescription?.isNotEmpty == true
        ? job.shareDescription!
        : job.jobPosition ?? 'Job Opening';

    return "$description\n$shareLink";
  }

  void _showShareSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Job shared successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleShareError(BuildContext context, Jobs job) async {
    final fallbackLink = _getFallbackShareLink(job);
    final shareText = _buildShareText(job, fallbackLink);

    await SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: job.jobPosition ?? 'Job Opening',
      ),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Shared with fallback link"),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void retryFetch() {
    _cacheAuthToken();
    fetchJobOpenings();
  }

  void pauseAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  void resumeAutoScroll() {
    if (_autoScrollTimer?.isActive != true && jobOpenings.value.isNotEmpty) {
      _setupAutoScroll();
    }
  }

  void dispose() {
    _autoScrollTimer?.cancel();
    jobOpenings.dispose();
    isLoading.dispose();
    isSharing.dispose();
  }
}