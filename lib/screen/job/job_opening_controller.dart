import 'package:flutter/material.dart';
import 'package:meetsu_solutions/model/job&ads/job_and_ads_response_model.dart';
import 'dart:async';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:share_plus/share_plus.dart';

class JobOpening {
  final int id;
  final String title;
  final String date;
  final String location;
  final int positions;
  final String salary;
  final String description;
  final List<String> requirements;
  final String imageUrl;
  final String shareDescription;

  JobOpening({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.positions,
    required this.salary,
    required this.description,
    required this.requirements,
    required this.imageUrl,
    required this.shareDescription,
  });
}

class JobOpeningController {
  final ApiService _apiService;

  final ValueNotifier<List<JobOpening>> jobOpenings =
      ValueNotifier<List<JobOpening>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);

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

      final token = SharedPrefsService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

      _apiService.client.addAuthToken(token);

      final response = await _apiService.getJobAndAds();

      final jobsResponse = JobAndAdsResponseModel.fromJson(response);

      if (jobsResponse.success == true &&
          jobsResponse.response != null &&
          jobsResponse.response!.jobs != null &&
          jobsResponse.response!.jobs!.isNotEmpty) {
        final List<JobOpening> jobs = jobsResponse.response!.jobs!.map((job) {
          List<String> requirements = [];

          if (job.positionDescription != null) {
            requirements = job.positionDescription!
                .split('\n')
                .where((line) => line.trim().isNotEmpty)
                .toList();
          }

          return JobOpening(
            id: job.jobId ?? 0,
            title: job.jobPosition ?? "Unknown Position",
            date: job.positionDate ?? "Unknown Date",
            location: job.location ?? "Unknown Location",
            positions: job.noOfPositions ?? 1,
            salary: job.salary ?? "N/A",
            description: job.positionDescription ?? "No description available",
            requirements: requirements.isEmpty
                ? ["No specific requirements listed"]
                : requirements,
            imageUrl: job.imageUrl ?? "",
            shareDescription: job.shareDescription ?? "",
          );
        }).toList();

        jobOpenings.value = jobs;
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

  void shareJob(BuildContext context, JobOpening job) {
    final String shareText = job.shareDescription.isNotEmpty
        ? job.shareDescription
        : "Check out this job opening: ${job.title}\n\nLocation: ${job.location}\nSalary: ${job.salary}\n\nhttps://meetsusolutions.com/franciso/web/site/jobs?id=${job.id}";

    Share.share(
      shareText,
      subject: job.title,
    );
  }

  void retryFetch() {
    fetchJobOpenings();
  }

  void dispose() {
    jobOpenings.dispose();
    isLoading.dispose();
    currentIndex.dispose();
    _autoScrollTimer?.cancel();
  }
}
