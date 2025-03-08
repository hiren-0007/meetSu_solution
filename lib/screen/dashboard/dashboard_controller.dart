import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meetsu_solutions/model/job&ads/job_and_ads_response_model.dart';
import 'dart:async';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/utils/extra/html_parsers.dart';
import 'package:share_plus/share_plus.dart';

import '../../model/weather/weather_response_model.dart';

class AdItem {
  final int id;
  final String subjectLine;
  final String description;
  final String shareDescription;
  final String date;
  final String place;
  final String amount;
  final String imageUrl;
  final String status;
  final String onlyImage;

  AdItem({
    required this.id,
    required this.subjectLine,
    required this.description,
    required this.shareDescription,
    required this.date,
    required this.place,
    required this.amount,
    required this.imageUrl,
    required this.status,
    required this.onlyImage,
  });
}

class DashboardController {
  // API Service
  final ApiService _apiService;

  // Weather and Quote data
  final ValueNotifier<String> temperature = ValueNotifier<String>("33.22°C");
  final ValueNotifier<String> date = ValueNotifier<String>("Feb 27, 2025");
  final ValueNotifier<String> quote = ValueNotifier<String>("Just trust yourself, then you will know how to live.");
  final ValueNotifier<String> quoteAuthor = ValueNotifier<String>("Goethe");

  // Observable states for ads
  final ValueNotifier<List<AdItem>> adItems = ValueNotifier<List<AdItem>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);

  // Timer for auto-scrolling
  Timer? _autoScrollTimer;

  // Benefits list
  final ValueNotifier<List<String>> benefits = ValueNotifier<List<String>>([
    "You will able to clock in and clock out for your time attendance.",
    "You will get all updates about your shifts and upcoming payrolls."
  ]);

  // Constructor
  DashboardController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    // Fetch ads data when controller is initialized
    fetchAdsData();
    // fetchWeatherData();
    // Setup auto-scroll timer
    _setupAutoScroll();

  }

  // Set up auto-scrolling
  void _setupAutoScroll() {
    // Auto-scroll every 5 seconds
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (adItems.value.isNotEmpty) {
        // Calculate next index
        int nextIndex = (currentIndex.value + 1) % adItems.value.length;
        // Update current index
        setCurrentIndex(nextIndex);
      }
    });
  }

  // Set current index
  void setCurrentIndex(int index) {
    currentIndex.value = index;
  }

  // Fetch ads data from the API
  Future<void> fetchAdsData() async {
    try {
      isLoading.value = true;

      // Get user token from Shared Preferences
      final token = SharedPrefsService.instance.getAccessToken();
      debugPrint("🔑 Auth Token for Ads: ${token != null ? (token.length > 10 ? '${token.substring(0, 10)}...' : token) : 'null'}");

      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

      // Add Authorization Token to API Client
      _apiService.client.addAuthToken(token);

      // Make API Call
      final response = await _apiService.getJobAndAds();
      debugPrint("📥 Received response for Ads");

      // Convert Response to JobAndAdsResponseModel
      final adsResponse = JobAndAdsResponseModel.fromJson(response);

      // Check if ads data is available
      if (adsResponse.success == true &&
          adsResponse.response != null &&
          adsResponse.response!.ads != null &&
          adsResponse.response!.ads!.isNotEmpty) {

        // Convert API Ads to our AdItem model
        final List<AdItem> ads = adsResponse.response!.ads!.map((ad) {
          // Convert HTML description to plain text using the HtmlParser utility
          String plainDescription = HtmlParsers.htmlToText(ad.description);

          return AdItem(
            id: ad.adsId ?? 0,
            subjectLine: ad.subjectLine ?? "No Subject",
            description: plainDescription,
            shareDescription: ad.shareDescription ?? "",
            date: ad.date ?? "Unknown Date",
            place: ad.place ?? "Unknown Place",
            amount: ad.amount ?? "\$0.00",
            imageUrl: ad.imageUrl ?? "",
            status: ad.status ?? "OFF",
            onlyImage: ad.onlyImage ?? "",
          );
        }).toList();

        // Update the ads list
        adItems.value = ads;
        debugPrint("✅ Loaded ${ads.length} ads");

      } else {
        // No ads available
        adItems.value = [];
        debugPrint("No ads available or API returned an error: ${adsResponse.message}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching ads data: $e");
      adItems.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Share ad function
  void shareAd(BuildContext context, AdItem ad) {
    // Create the text content to share
    final String shareText = ad.shareDescription.isNotEmpty
        ? ad.shareDescription
        : "Check out this ad: ${ad.subjectLine}\n\nhttps://meetsusolutions.com/franciso/web/site/ads?id=${ad.id}";

    // Use the share_plus package to show the share dialog
    Share.share(
      shareText,
      subject: ad.subjectLine,
    );
  }

  // Download app function
  void downloadFromPlayStore(BuildContext context) {
    // Implement download functionality here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirecting to Play Store...'),
        backgroundColor: Colors.blue,
      ),
    );
    debugPrint("Downloading from Play Store");
  }

  void downloadFromAppStore(BuildContext context) {
    // Implement download functionality here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirecting to App Store...'),
        backgroundColor: Colors.blue,
      ),
    );
    debugPrint("Downloading from App Store");
  }

  // Refresh dashboard data
  Future<void> refreshDashboardData() async {
    // Get latest ads data from API
    await fetchAdsData();
    debugPrint("Dashboard data refreshed");
  }

  // Dispose resources
  void dispose() {
    temperature1.dispose();
    date.dispose();
    quote.dispose();
    quoteAuthor.dispose();
    adItems.dispose();
    isLoading.dispose();
    currentIndex.dispose();
    benefits.dispose();
    _autoScrollTimer?.cancel();
  }

  void initialize() {
    isLoading.value = true;

    // Fetch token
    final token = SharedPrefsService.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _apiService.client.addAuthToken(token);
    }

    debugPrint("🔄 Initializing Dashboard...");
    debugPrint("🔄 weather Dashboard...");
    // Ensure weather API call is made
    fetchWeatherData();
    // fetchAdsData();
  }

  // Profile data ValueNotifier
  final ValueNotifier<GetWeatherResponse?> getWeatherData = ValueNotifier<GetWeatherResponse?>(null);
  // ValueNotifiers for reactive state management
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  ValueNotifier<String> iconLink = ValueNotifier('');
  final ValueNotifier<String> temperature1 = ValueNotifier<String>("");
  final ValueNotifier<String> date1 = ValueNotifier<String>("");

  ValueNotifier<String> time = ValueNotifier('');
  // Fetch profile data from API
  // Future<void> fetchWeatherData() async {
  //   try {
  //     final response = await _apiService.getWeather();
  //     final jsonResponse = jsonDecode(response['temperature']); // Decode JSON string
  //
  //
  //     // Extract values
  //     String? iconLink = jsonResponse['iconLink'];
  //     double? temp = jsonResponse['temperature'];
  //     String? time = jsonResponse['time'];
  //
  //
  //     // Format time (e.g., "Mar 08, 2025")
  //     DateTime parsedTime = DateTime.parse(time ?? '');
  //     String formattedTime = DateFormat("MMM dd, yyyy").format(parsedTime);
  //
  //
  //     // Update ValueNotifiers
  //     iconLink = iconLink ?? '';
  //     temperature1.value = "${temp?.toStringAsFixed(1)}°C"; // 1 decimal place
  //     time = formattedTime;
  //     // Parse the profile response
  //     final weather = GetWeatherResponse.fromJson(response);
  //     // Update ValueNotifiers with weather data
  //     temperature1.value = weather.temperature ?? "N/A";
  //     date.value = weather.temperature ?? "Unknown Date";
  //     getWeatherData.value = weather;
  //     debugPrint("🔄 weather Dashboard...${getWeatherData.value.toString()}");
  //     debugPrint("🔄 weather Dashboard...${iconLink}");
  //     debugPrint("🔄 weather Dashboard...${temperature1.value}");
  //     debugPrint("🔄 weather Dashboard...${time}");
  //
  //     debugPrint("🔄 weather Dashboard...");
  //
  //     errorMessage.value = null;
  //   } catch (e) {
  //     errorMessage.value = "Failed to load profile data: ${e.toString()}";
  //
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  Future<void> fetchWeatherData() async {
    try {
      isLoading.value = true;

      final response = await _apiService.getWeather();
      debugPrint("📥 Raw Weather API Response: ${jsonEncode(response)}");

      if (response != null) {
        final weather = GetWeatherResponse.fromJson(response);

        // Validate extracted values
        debugPrint("🌡 Temperature: ${weather.temperature}");
        debugPrint("📅 Date: ${weather.date}");
        debugPrint("🌤 Icon: ${weather.icon}");

        temperature1.value = weather.temperature ?? "N/A";
        date.value = weather.date ?? "Unknown Date";
        iconLink.value = weather.icon ?? "";

        getWeatherData.value = weather;
        debugPrint("✅ Weather Data Updated");
      } else {
        errorMessage.value = "Failed to fetch weather data: Response is null";
      }
    } catch (e) {
      errorMessage.value = "❌ Error: ${e.toString()}";
      debugPrint("❌ Weather API Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

}