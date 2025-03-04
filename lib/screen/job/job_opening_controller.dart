import 'package:flutter/material.dart';
import 'package:meetsu_solutions/model/job&ads/job_and_ads_response_model.dart';
import 'dart:async';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

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
  // API Service
  final ApiService _apiService;

  // Observable states
  final ValueNotifier<List<JobOpening>> jobOpenings = ValueNotifier<List<JobOpening>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);

  // Timer for auto-scrolling
  Timer? _autoScrollTimer;

  // Constructor
  JobOpeningController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    // Fetch job openings when controller is initialized
    fetchJobOpenings();

    // Setup auto-scroll timer
    _setupAutoScroll();
  }

  // Set up auto-scrolling
  void _setupAutoScroll() {
    // Auto-scroll every 5 seconds
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (jobOpenings.value.isNotEmpty) {
        // Calculate next index
        int nextIndex = (currentIndex.value + 1) % jobOpenings.value.length;
        // Update current index
        setCurrentIndex(nextIndex);
      }
    });
  }

  // Set current index
  void setCurrentIndex(int index) {
    currentIndex.value = index;
  }

  // Fetch job openings from the API
  Future<void> fetchJobOpenings() async {
    try {
      isLoading.value = true;

      // Get user token from Shared Preferences
      final token = SharedPrefsService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

      // Add Authorization Token to API Client
      _apiService.client.addAuthToken(token);

      // Make API Call
      final response = await _apiService.getJobAndAds();

      // Convert Response to JobAndAdsResponseModel
      final jobsResponse = JobAndAdsResponseModel.fromJson(response);

      // Check if jobs data is available
      if (jobsResponse.success == true &&
          jobsResponse.response != null &&
          jobsResponse.response!.jobs != null &&
          jobsResponse.response!.jobs!.isNotEmpty) {

        // Convert API Jobs to our JobOpening model
        final List<JobOpening> jobs = jobsResponse.response!.jobs!.map((job) {
          // Parse requirements from description (assuming they're separated by line breaks)
          List<String> requirements = [];

          if (job.positionDescription != null) {
            // Split by line breaks and filter out empty lines
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
            requirements: requirements.isEmpty ? ["No specific requirements listed"] : requirements,
            imageUrl: job.imageUrl ?? "",
            shareDescription: job.shareDescription ?? "",
          );
        }).toList();

        // Update the job openings list
        jobOpenings.value = jobs;

      } else {
        // No jobs available
        jobOpenings.value = [];
        debugPrint("No jobs available or API returned an error: ${jobsResponse.message}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching job openings: $e");
      jobOpenings.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Share job
  void shareJob(BuildContext context, JobOpening job) {
    // In a real app, this would use a sharing plugin
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing job: ${job.title}'),
        backgroundColor: Colors.green,
      ),
    );
    debugPrint("Sharing job: ${job.title}");
    // Here you might want to use the job.shareDescription for sharing
  }


  // Retry fetching data
  void retryFetch() {
    fetchJobOpenings();
  }

  // Dispose resources
  void dispose() {
    jobOpenings.dispose();
    isLoading.dispose();
    currentIndex.dispose();
    _autoScrollTimer?.cancel();
  }
}