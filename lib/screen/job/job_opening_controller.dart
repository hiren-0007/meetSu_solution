import 'package:flutter/material.dart';
import 'package:meetsu_solutions/model/job&ads/job/job_opening_response_model.dart';
import 'dart:async';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:share_plus/share_plus.dart';

class JobOpeningController {
  static const Duration _autoScrollInterval = Duration(seconds: 5);
  static const Duration _animationDuration = Duration(milliseconds: 300);
  static const String _fallbackBaseUrl = "https://meetsusolutions.com/frontend/web/site/job?id=";

  final ApiService _apiService;

  // ValueNotifiers for reactive UI updates
  final ValueNotifier<List<Jobs>> jobOpenings = ValueNotifier<List<Jobs>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);
  final ValueNotifier<bool> isSharing = ValueNotifier<bool>(false);

  Timer? _autoScrollTimer;
  String? _cachedToken;

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

  // Auto-scroll functionality
  void _setupAutoScroll() {
    _autoScrollTimer?.cancel();

    if (jobOpenings.value.isEmpty) return;

    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (timer) {
      if (jobOpenings.value.isNotEmpty) {
        final nextIndex = (currentIndex.value + 1) % jobOpenings.value.length;
        setCurrentIndex(nextIndex);
      }
    });
  }

  void setCurrentIndex(int index) {
    if (index >= 0 && index < jobOpenings.value.length && currentIndex.value != index) {
      currentIndex.value = index;
    }
  }

  Future<void> fetchJobOpenings() async {
    try {
      isLoading.value = true;
      debugPrint("🔄 Fetching job openings...");

      // Use cached token or refresh if needed
      final token = _cachedToken ?? SharedPrefsService.instance.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

      // Update cached token if it changed
      if (_cachedToken != token) {
        _cachedToken = token;
      }

      _apiService.client.addAuthToken(token);

      final response = await _apiService.getJobsOnly();
      debugPrint("📥 Received response for Jobs");

      await _processJobResponse(response);
    } catch (e) {
      debugPrint("❌ Error fetching job openings: $e");
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
      debugPrint("✅ Loaded ${jobOpenings.value.length} job openings");

      currentIndex.value = 0;
      _setupAutoScroll();
    } else {
      jobOpenings.value = [];
      debugPrint("⚠️ No jobs available or API returned an error: ${jobsResponse.message}");
    }
  }

  void _handleFetchError() {
    jobOpenings.value = [];
    // Optionally, you could implement retry logic here
  }

  Future<void> shareJob(BuildContext context, Jobs job) async {
    if (isSharing.value) return; // Prevent multiple simultaneous shares

    try {
      isSharing.value = true;
      debugPrint("🔄 Sharing job: ${job.jobPosition} (ID: ${job.jobId})");

      final shareLink = await _getShareLink(job);
      final shareText = _buildShareText(job, shareLink);

      await Share.share(shareText, subject: job.jobPosition ?? 'Job Opening');
      debugPrint("✅ Job shared successfully");

      if (context.mounted) {
        _showShareSuccess(context);
      }
    } catch (e) {
      debugPrint("❌ Error during job sharing: $e");

      if (context.mounted) {
        await _handleShareError(context, job);
      }
    } finally {
      isSharing.value = false;
    }
  }

  Future<String> _getShareLink(Jobs job) async {
    try {
      final token = _cachedToken ?? SharedPrefsService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

      _apiService.client.addAuthToken(token);

      final requestData = {
        'id': job.jobId.toString(),
        'job_or_ad': '1',
        'medium': 'Whatsapp'
      };

      debugPrint("📤 Share request data: $requestData");

      final response = await _apiService.getJobShare(requestData);
      debugPrint("📥 Share API Response: $response");

      return _extractShareLink(response, job);
    } catch (e) {
      debugPrint("⚠️ Failed to get share link from API: $e");
      return _getFallbackShareLink(job);
    }
  }

  String _extractShareLink(Map<String, dynamic> response, Jobs job) {
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to generate share link');
    }

    String shareLink = "";

    // Try different response structures
    if (response['response']?['link'] != null) {
      shareLink = response['response']['link'];
    } else if (response['link'] != null) {
      shareLink = response['link'];
    }

    // Reformat link if necessary
    if (shareLink.isNotEmpty &&
        !shareLink.contains("job?id=") &&
        shareLink.contains("job-view?refid=")) {
      shareLink = "$_fallbackBaseUrl${job.jobId}";
      debugPrint("🔧 Reformatted share link: $shareLink");
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

    await Share.share(shareText, subject: job.jobPosition ?? 'Job Opening');

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

  List<String> getRequirements(Jobs job) {
    if (job.positionDescription?.isEmpty != false) {
      return ["No specific requirements listed"];
    }

    final requirements = job.positionDescription!
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return requirements.isEmpty ? ["No specific requirements listed"] : requirements;
  }

  // Control methods
  void retryFetch() {
    debugPrint("🔄 Retrying fetch for job openings");
    _cacheAuthToken(); // Refresh token cache
    fetchJobOpenings();
  }

  void pauseAutoScroll() {
    _autoScrollTimer?.cancel();
    debugPrint("⏸️ Auto-scroll paused");
  }

  void resumeAutoScroll() {
    if (_autoScrollTimer?.isActive != true && jobOpenings.value.isNotEmpty) {
      _setupAutoScroll();
      debugPrint("▶️ Auto-scroll resumed");
    }
  }

  void dispose() {
    debugPrint("🧹 Disposing JobOpeningController resources");
    _autoScrollTimer?.cancel();

    // Dispose ValueNotifiers
    jobOpenings.dispose();
    isLoading.dispose();
    currentIndex.dispose();
    isSharing.dispose();
  }
}