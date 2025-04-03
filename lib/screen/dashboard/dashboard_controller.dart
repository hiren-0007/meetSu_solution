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
  final ApiService _apiService;

  final ValueNotifier<String> temperature = ValueNotifier<String>("33.22°C");
  final ValueNotifier<String> date = ValueNotifier<String>("Feb 27, 2025");
  final ValueNotifier<String> quote = ValueNotifier<String>(
      "Just trust yourself, then you will know how to live.");
  final ValueNotifier<String> quoteAuthor = ValueNotifier<String>("Goethe");
  final ValueNotifier<String> iconLink = ValueNotifier<String>("");

  final ValueNotifier<List<AdItem>> adItems = ValueNotifier<List<AdItem>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  final ValueNotifier<WeatherResponseModel?> getWeatherData =
      ValueNotifier<WeatherResponseModel?>(null);

  Timer? _autoScrollTimer;

  final ValueNotifier<List<String>> benefits = ValueNotifier<List<String>>([
    "You will able to clock in and clock out for your time attendance.",
    "You will get all updates about your shifts and upcoming payrolls."
  ]);

  DashboardController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    initialize();
  }

  void initialize() {
    isLoading.value = true;

    final token = SharedPrefsService.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _apiService.client.addAuthToken(token);
    }

    debugPrint("🔄 Initializing Dashboard...");

    Future.wait([
      fetchWeatherData(),
      fetchQuoteData(),
      fetchAdsData(),
    ]).then((_) {
      isLoading.value = false;
      debugPrint("✅ Dashboard fully initialized");
    }).catchError((error) {
      isLoading.value = false;
      debugPrint("❌ Error during initialization: $error");
    });

    _setupAutoScroll();
  }

  void _setupAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (adItems.value.isNotEmpty) {
        int nextIndex = (currentIndex.value + 1) % adItems.value.length;
        setCurrentIndex(nextIndex);
      }
    });
  }

  void setCurrentIndex(int index) {
    currentIndex.value = index;
  }

  Future<void> fetchWeatherData() async {
    try {
      debugPrint("🌤️ Fetching weather data...");

      Map<String, dynamic>? locationData;
      try {
        locationData = await _apiService.getWeatherLocation();
        debugPrint("📍 Location data: ${jsonEncode(locationData)}");
      } catch (e) {
        debugPrint("⚠️ Could not fetch location data: $e");
      }

      double? lat, long;
      if (locationData != null &&
          locationData['success'] == true &&
          locationData['response'] != null) {
        final response = locationData['response'];

        debugPrint("📍 Raw lat value: ${response['lat']}");
        debugPrint("📍 Raw long value: ${response['long']}");

        try {
          lat = double.tryParse("${response['lat']}");
          long = double.tryParse("${response['long']}");
          debugPrint("📍 Parsed coordinates: lat=$lat, long=$long");
        } catch (e) {
          debugPrint("❌ Error parsing coordinates: $e");
        }
      }

      if (lat == null || long == null) {
        debugPrint("⚠️ No valid coordinates found, using defaults");
        lat = 43.595336;
        long = -79.648579;
      }

      Map<String, String> params = {
        'lat': lat.toString(),
        'long': long.toString(),
      };
      debugPrint("📍 Sending parameters: $params");

      final baseUrl = 'https://meetsusolutions.com/api/web/';
      final endpoint = 'flutter/weather';
      final uri =
          Uri.parse('$baseUrl$endpoint').replace(queryParameters: params);
      debugPrint("🔍 Final URL being called: $uri");

      final response = await _apiService.getWeather();
      debugPrint("📥 Weather API Response: ${jsonEncode(response)}");

      if (response['success'] == true && response['response'] != null) {
      } else {
        debugPrint("❌ Invalid weather response format: $response");

        try {
          temperature.value = "21°C";
          date.value = DateFormat("MMM dd, yyyy").format(DateTime.now());
          iconLink.value =
              "https://weather.hereapi.com/static/weather/icon/1.png";

          final weather = WeatherResponseModel(
              temperature: temperature.value,
              date: date.value,
              icon: iconLink.value);

          getWeatherData.value = weather;
          debugPrint("⚠️ Using fallback weather data as API failed");
        } catch (e) {
          debugPrint("❌ Error setting fallback weather: $e");
        }
      }
    } catch (e) {
      debugPrint("❌ Weather API Error: $e");
      errorMessage.value = "Failed to load weather data: ${e.toString()}";
    }
  }

  Future<void> fetchQuoteData() async {
    try {
      debugPrint("📝 Fetching quote data...");

      final response = await _apiService.getQuote();
      debugPrint("📥 Quote API Response: ${jsonEncode(response)}");

      if (response != null) {
        quote.value = response['quoteText']?.trim() ??
            "Just trust yourself, then you will know how to live.";
        quoteAuthor.value = response['quoteAuthor']?.trim() ?? "Goethe";

        if (quoteAuthor.value.isEmpty) {
          quoteAuthor.value = "Unknown";
        }

        debugPrint("✅ Quote Updated: ${quote.value} - ${quoteAuthor.value}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching quote: $e");
    }
  }

  Future<void> fetchAdsData() async {
    try {
      debugPrint("📢 Fetching ads data...");

      final token = SharedPrefsService.instance.getAccessToken();
      debugPrint(
          "🔑 Auth Token for Ads: ${token != null ? (token.length > 10 ? '${token.substring(0, 10)}...' : token) : 'null'}");

      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

      _apiService.client.addAuthToken(token);

      final response = await _apiService.getJobAndAds();
      debugPrint("📥 Received response for Ads");

      final adsResponse = JobAndAdsResponseModel.fromJson(response);

      if (adsResponse.success == true &&
          adsResponse.response != null &&
          adsResponse.response!.ads != null &&
          adsResponse.response!.ads!.isNotEmpty) {
        final List<AdItem> ads = adsResponse.response!.ads!.map((ad) {
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

        adItems.value = ads;
        debugPrint("✅ Loaded ${ads.length} ads");
      } else {
        adItems.value = [];
        debugPrint(
            "No ads available or API returned an error: ${adsResponse.message}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching ads data: $e");
      adItems.value = [];
    }
  }

  void shareAd(BuildContext context, AdItem ad) {
    final String shareText = ad.shareDescription.isNotEmpty
        ? ad.shareDescription
        : "Check out this ad: ${ad.subjectLine}\n\nhttps://meetsusolutions.com/franciso/web/site/ads?id=${ad.id}";

    Share.share(
      shareText,
      subject: ad.subjectLine,
    );
  }

  void downloadFromPlayStore(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirecting to Play Store...'),
        backgroundColor: Colors.blue,
      ),
    );
    debugPrint("Downloading from Play Store");
  }

  void downloadFromAppStore(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirecting to App Store...'),
        backgroundColor: Colors.blue,
      ),
    );
    debugPrint("Downloading from App Store");
  }

  Future<void> refreshDashboardData() async {
    isLoading.value = true;

    try {
      await Future.wait([
        fetchWeatherData(),
        fetchQuoteData(),
        fetchAdsData(),
      ]);

      debugPrint("✅ Dashboard data refreshed");
    } catch (e) {
      debugPrint("❌ Error refreshing dashboard data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    temperature.dispose();
    date.dispose();
    quote.dispose();
    quoteAuthor.dispose();
    iconLink.dispose();
    adItems.dispose();
    isLoading.dispose();
    currentIndex.dispose();
    benefits.dispose();
    errorMessage.dispose();
    _autoScrollTimer?.cancel();
  }
}
