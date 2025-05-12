import 'package:flutter/material.dart';
import 'package:meetsu_solutions/model/job&ads/job/job_opening_response_model.dart';
import 'dart:async';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:share_plus/share_plus.dart';

class JobOpeningController {
  final ApiService _apiService;

  final ValueNotifier<List<Jobs>> jobOpenings = ValueNotifier<List<Jobs>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);
  final ValueNotifier<bool> isSharing = ValueNotifier<bool>(false);

  Timer? _autoScrollTimer;

  JobOpeningController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    fetchJobOpenings();
    _setupAutoScroll();
  }

  void _setupAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (jobOpenings.value.isNotEmpty) {
        int nextIndex = (currentIndex.value + 1) % jobOpenings.value.length;
        setCurrentIndex(nextIndex);
      }
    });
  }

  void setCurrentIndex(int index) {
    currentIndex.value = index;
  }

  Future<void> fetchJobOpenings() async {
    try {
      isLoading.value = true;
      debugPrint("🔄 Fetching job openings...");

      final token = SharedPrefsService.instance.getAccessToken();
      debugPrint("🔑 Auth Token: ${token != null ? (token.length > 10 ? '${token.substring(0, 10)}...' : token) : 'null'}");

      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

      _apiService.client.addAuthToken(token);

      final response = await _apiService.getJobsOnly();
      debugPrint("📥 Received response for Jobs");

      final jobsResponse = JobOpeningResponseModel.fromJson(response);

      if (jobsResponse.success == true &&
          jobsResponse.response != null &&
          jobsResponse.response!.jobs != null &&
          jobsResponse.response!.jobs!.isNotEmpty) {

        jobOpenings.value = jobsResponse.response!.jobs!;
        debugPrint("✅ Loaded ${jobOpenings.value.length} job openings");
      } else {
        jobOpenings.value = [];
        debugPrint(
            "No jobs available or API returned an error: ${jobsResponse.message}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching job openings: $e");
      jobOpenings.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> shareJob(BuildContext context, Jobs job) async {
    try {
      isSharing.value = true;

      debugPrint("🔄 Sharing job: ${job.jobPosition} (ID: ${job.jobId})");

      final token = SharedPrefsService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

      _apiService.client.addAuthToken(token);

      Map<String, dynamic> requestData = {
        'id': job.jobId.toString(),
        'job_or_ad': '1',
        'medium': 'Whatsapp'
      };

      debugPrint("📤 Share request data: $requestData");

      final response = await _apiService.getJobShare(requestData);
      debugPrint("📥 Share API Response: $response");

      if (response['success'] == true) {
        String shareLink = "";

        if (response['response'] != null && response['response']['link'] != null) {
          shareLink = response['response']['link'];
          debugPrint("🔗 Share link received: $shareLink");
        } else if (response['link'] != null) {
          shareLink = response['link'];
          debugPrint("🔗 Share link received (alt path): $shareLink");
        }

        if (shareLink.isNotEmpty) {
          final String shareText = job.shareDescription?.isNotEmpty == true
              ? "${job.shareDescription!}\n\n$shareLink"
              : "Check out this Jobs: ${job.jobPosition ?? 'Untitled Jobs'}\n\n$shareLink";

          await Share.share(
            shareText,
            subject: job.jobPosition ?? 'Jobs',
          );

          debugPrint("✅ Job shared successfully");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to get share link')),
          );
          debugPrint("⚠️ No share link found in response");
        }
      } else {
        String errorMsg = response != null && response['message'] != null
            ? response['message']
            : 'Failed to generate share link';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );

        debugPrint("❌ Error in share API response: $errorMsg");
      }

      final String shareText = job.shareDescription?.isNotEmpty == true
          ? job.shareDescription!
          : "Check out this job opening: ${job.jobPosition ?? 'Job Opening'}\n\nLocation: ${job.location ?? 'Unknown Location'}\nSalary: ${job.salary ?? 'N/A'}\n\nhttps://meetsusolutions.com/frontend/web/site/jobs?id=${job.jobId ?? '0'}";

      await Share.share(shareText, subject: job.jobPosition ?? 'Job Opening');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Using default share text"),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint("❌ Error during job sharing: $e");

      final String shareText = job.shareDescription?.isNotEmpty == true
          ? job.shareDescription!
          : "Check out this job opening: ${job.jobPosition ?? 'Job Opening'}\n\nLocation: ${job.location ?? 'Unknown Location'}\nSalary: ${job.salary ?? 'N/A'}\n\nhttps://meetsusolutions.com/frontend/web/site/jobs?id=${job.jobId ?? '0'}";

      await Share.share(shareText, subject: job.jobPosition ?? 'Job Opening');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isSharing.value = false;
    }
  }

  List<String> getRequirements(Jobs job) {
    if (job.positionDescription == null || job.positionDescription!.isEmpty) {
      return ["No specific requirements listed"];
    }

    List<String> requirements = job.positionDescription!
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    return requirements.isEmpty ? ["No specific requirements listed"] : requirements;
  }

  void retryFetch() {
    fetchJobOpenings();
  }

  void dispose() {
    jobOpenings.dispose();
    isLoading.dispose();
    currentIndex.dispose();
    isSharing.dispose();
    _autoScrollTimer?.cancel();
  }
}