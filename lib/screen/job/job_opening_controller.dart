import 'package:flutter/material.dart';
import 'package:meetsu_solutions/model/job&ads/job/job_opening_response_model.dart';
import 'dart:async';
import 'dart:io';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:share_plus/share_plus.dart';

class JobOpeningController {
  static const Duration _autoScrollInterval = Duration(seconds: 5);
  static const String _fallbackBaseUrl =
      "https://meetsusolutions.com/frontend/web/site/job?id=";

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
  void startAutoScrollWithPageController(
      PageController pageController, Function(int) onIndexChanged) {
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
      if (jobOpenings.value.isNotEmpty &&
          _pageController != null &&
          _pageController!.hasClients) {
        // Calculate next index (loop back to 0 after last item)
        _currentIndex = (_currentIndex + 1) % jobOpenings.value.length;

        // Get current page and calculate next page for infinite scroll
        final currentPage = _pageController!.page?.round() ?? 0;
        final currentRealIndex = currentPage % jobOpenings.value.length;

        int targetPage;
        if (_currentIndex == 0 &&
            currentRealIndex == jobOpenings.value.length - 1) {
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
      debugPrint(
          "⚠️ No jobs available or API returned an error: ${jobsResponse.message}");
    }
  }

  String _generateScrollPattern() {
    if (jobOpenings.value.isEmpty) return "No jobs available";

    final jobCount = jobOpenings.value.length;
    final pattern =
        List.generate(jobCount * 2, (index) => (index % jobCount) + 1);
    return pattern.take(jobCount * 2).join(',');
  }

  void _handleFetchError() {
    jobOpenings.value = [];
  }

  // Original shareJob method - maintained for backward compatibility
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

  // Enhanced sharing method with rich content support
  Future<void> shareJobWithRichContent(
    BuildContext context,
    Jobs job,
    String shareText,
    String? imageUrl,
  ) async {
    if (isSharing.value) return;

    try {
      isSharing.value = true;
      debugPrint(
          "🔄 Sharing job with rich content: ${job.jobPosition} (ID: ${job.jobId})");

      if (Platform.isIOS) {
        // iOS के लिए rich sharing
        await _shareForIOS(shareText, imageUrl);
      } else {
        // Android के लिए rich sharing
        await _shareForAndroid(shareText, imageUrl);
      }

      debugPrint("✅ Job shared successfully with rich content");

      if (context.mounted) {
        _showShareSuccess(context);
      }
    } catch (e) {
      debugPrint("❌ Error during rich content sharing: $e");

      if (context.mounted) {
        // Fallback to original sharing method
        await shareJob(context, job);
      }
    } finally {
      isSharing.value = false;
    }
  }

  Future<void> _shareForIOS(String text, String? imageUrl) async {
    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        // iOS में enhanced text के साथ share करने के लिए
        final enhancedText = '''
$text

📸 Job Image: $imageUrl

📱 Download our app for more opportunities!
        ''';

        await Share.share(
          enhancedText,
          subject: 'Job Opening - MeetSu Solutions',
        );
      } else {
        await Share.share(
          text,
          subject: 'Job Opening - MeetSu Solutions',
        );
      }
    } catch (e) {
      debugPrint("❌ iOS sharing error: $e");
      await Share.share(text);
    }
  }

  Future<void> _shareForAndroid(String text, String? imageUrl) async {
    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        // Android में rich preview के लिए enhanced format
        final enhancedText = '''
$text

🖼️ View Job Image: $imageUrl

📲 Get the MeetSu Solutions app for instant job updates!
        ''';

        await Share.share(
          enhancedText,
          subject: 'Job Opening - MeetSu Solutions',
        );
      } else {
        await Share.share(
          text,
          subject: 'Job Opening - MeetSu Solutions',
        );
      }
    } catch (e) {
      debugPrint("❌ Android sharing error: $e");
      await Share.share(text);
    }
  }

  // Custom share dialog method
  Future<void> shareJobWithCustomDialog(
    BuildContext context,
    Jobs job,
  ) async {
    if (isSharing.value) return;

    try {
      isSharing.value = true;
      debugPrint("🔄 Opening custom share dialog for: ${job.jobPosition}");

      final String shareContent = _buildUnifiedShareContent(job);

      // Custom share options के साथ
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ShareOptionsBottomSheet(
          shareContent: shareContent,
          imageUrl: job.imageUrl,
          jobTitle: job.jobPosition ?? 'Job Opening',
          onShare: (platform) async {
            Navigator.pop(context);
            await _shareOnSpecificPlatform(
                platform, shareContent, job.imageUrl);
          },
        ),
      );
    } catch (e) {
      debugPrint("❌ Custom sharing error: $e");
      await shareJob(context, job); // Fallback
    } finally {
      isSharing.value = false;
    }
  }

  String _buildUnifiedShareContent(Jobs job) {
    final shareLink = _getFallbackShareLink(job);

    return '''
🎯 ${job.jobPosition ?? "Job Opening"}

📍 Location: ${job.location ?? "Not specified"}
💰 Salary: ${job.salary ?? "Negotiable"}
📅 Date: ${job.positionDate ?? "Not specified"}

📝 Description:
${job.positionDescription ?? "No description available"}

🔗 Apply Now: $shareLink

#JobOpening #Career #MeetsuSolutions
    ''';
  }

  Future<void> _shareOnSpecificPlatform(
    String platform,
    String content,
    String? imageUrl,
  ) async {
    try {
      switch (platform) {
        case 'whatsapp':
          await _shareToWhatsApp(content, imageUrl);
          break;
        case 'telegram':
          await _shareToTelegram(content, imageUrl);
          break;
        case 'email':
          await _shareToEmail(content, imageUrl);
          break;
        case 'sms':
          await _shareToSMS(content);
          break;
        case 'general':
        default:
          await Share.share(content);
          break;
      }
    } catch (e) {
      debugPrint("❌ Platform-specific sharing error: $e");
      await Share.share(content); // Fallback
    }
  }

  Future<void> _shareToWhatsApp(String text, String? imageUrl) async {
    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final whatsappText = '''
$text

📸 $imageUrl
        ''';
        await Share.share(whatsappText);
      } else {
        await Share.share(text);
      }
    } catch (e) {
      debugPrint("❌ WhatsApp sharing error: $e");
      await Share.share(text);
    }
  }

  Future<void> _shareToTelegram(String text, String? imageUrl) async {
    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final telegramText = '''
$text

🖼️ Image: $imageUrl
        ''';
        await Share.share(telegramText);
      } else {
        await Share.share(text);
      }
    } catch (e) {
      debugPrint("❌ Telegram sharing error: $e");
      await Share.share(text);
    }
  }

  Future<void> _shareToEmail(String text, String? imageUrl) async {
    try {
      final emailText = imageUrl != null && imageUrl.isNotEmpty
          ? '$text\n\nJob Image: $imageUrl'
          : text;

      await Share.share(
        emailText,
        subject: 'Job Opening - MeetSu Solutions',
      );
    } catch (e) {
      debugPrint("❌ Email sharing error: $e");
      await Share.share(text);
    }
  }

  Future<void> _shareToSMS(String text) async {
    try {
      final smsText = text.length > 160 ? '${text.substring(0, 157)}...' : text;

      await Share.share(smsText);
    } catch (e) {
      debugPrint("❌ SMS sharing error: $e");
      await Share.share(text);
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

// Custom Share Options Widget
class ShareOptionsBottomSheet extends StatelessWidget {
  final String shareContent;
  final String? imageUrl;
  final String jobTitle;
  final Function(String) onShare;

  const ShareOptionsBottomSheet({
    Key? key,
    required this.shareContent,
    this.imageUrl,
    required this.jobTitle,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Share "$jobTitle"',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 20),

                // Share options grid
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    _buildShareOption(
                      'WhatsApp',
                      Icons.chat,
                      Colors.green,
                      () => onShare('whatsapp'),
                    ),
                    _buildShareOption(
                      'Telegram',
                      Icons.send,
                      Colors.blue,
                      () => onShare('telegram'),
                    ),
                    _buildShareOption(
                      'Email',
                      Icons.email,
                      Colors.red,
                      () => onShare('email'),
                    ),
                    _buildShareOption(
                      'SMS',
                      Icons.sms,
                      Colors.orange,
                      () => onShare('sms'),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // More options button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => onShare('general'),
                    icon: Icon(Icons.share),
                    label: Text('More Options'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.grey.shade800,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
