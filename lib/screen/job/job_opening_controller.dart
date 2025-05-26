import 'package:flutter/material.dart';
import 'package:meetsu_solutions/model/job&ads/job/job_opening_response_model.dart';
import 'dart:async';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:share_plus/share_plus.dart';

class JobOpeningController {
  static const Duration _autoScrollInterval = Duration(seconds: 5);
  static const String _fallbackBaseUrl = "https://meetsusolutions.com/frontend/web/site/job?id=";

  final ApiService _apiService;

  // ValueNotifiers for reactive UI updates
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

  // Simple auto-scroll setup - Fixed version with infinite scroll support
  void startAutoScrollWithPageController(PageController pageController, Function(int) onIndexChanged) {
    _pageController = pageController;
    _onIndexChanged = onIndexChanged;
    _currentIndex = 0; // Start from first item
    _setupAutoScroll();
  }

  // Add method to update current index from manual swipe
  void updateCurrentIndex(int index) {
    _currentIndex = index;
  }

  void _setupAutoScroll() {
    _autoScrollTimer?.cancel();

    if (jobOpenings.value.isEmpty || _pageController == null) return;

    debugPrint("🔄 Starting auto-scroll for ${jobOpenings.value.length} jobs");

    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (timer) {
      if (jobOpenings.value.isNotEmpty && _pageController != null && _pageController!.hasClients) {

        // Calculate next index (loop back to 0 after last item)
        _currentIndex = (_currentIndex + 1) % jobOpenings.value.length;


        // Get current page and calculate next page for infinite scroll
        final currentPage = _pageController!.page?.round() ?? 0;
        final currentRealIndex = currentPage % jobOpenings.value.length;

        int targetPage;
        if (_currentIndex == 0 && currentRealIndex == jobOpenings.value.length - 1) {
          // Moving from last to first - go to next group
          targetPage = currentPage + 1;
        } else {
          // Normal forward movement
          targetPage = currentPage + 1;
        }

        // Animate to next page smoothly
        _pageController!.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        // Notify UI about index change
        _onIndexChanged?.call(_currentIndex);
      }
    });
  }

  Future<void> fetchJobOpenings() async {
    try {
      isLoading.value = true;
      debugPrint("🔄 Fetching job openings...");

      final token = _cachedToken ?? SharedPrefsService.instance.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

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
      debugPrint("🔁 Auto-scroll pattern: ${_generateScrollPattern()}");

      _currentIndex = 0; // Reset to first item
    } else {
      jobOpenings.value = [];
      debugPrint("⚠️ No jobs available or API returned an error: ${jobsResponse.message}");
    }
  }

  String _generateScrollPattern() {
    if (jobOpenings.value.isEmpty) return "No jobs available";

    final jobCount = jobOpenings.value.length;
    final pattern = List.generate(jobCount * 2, (index) => (index % jobCount) + 1);
    return pattern.take(jobCount * 2).join(',');
  }

  void _handleFetchError() {
    jobOpenings.value = [];
  }

  Future<void> shareJob(BuildContext context, Jobs job) async {
    if (isSharing.value) return;

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

      final response = await _apiService.getJobShare(requestData);
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

  void retryFetch() {
    debugPrint("🔄 Retrying fetch for job openings");
    _cacheAuthToken();
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

    jobOpenings.dispose();
    isLoading.dispose();
    isSharing.dispose();
  }
}