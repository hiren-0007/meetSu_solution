import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:meetsu_solutions/model/job&ads/ads/ads_response_model.dart';
import 'dart:async';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/utils/extra/html_parsers.dart';
import 'package:share_plus/share_plus.dart';

import '../../model/weather/weather_response_model.dart';

class DashboardController {
  final ApiService _apiService;

  final ValueNotifier<String> temperature = ValueNotifier<String>("33.22°C");
  final ValueNotifier<String> date = ValueNotifier<String>("Feb 27, 2025");
  final ValueNotifier<String> quote = ValueNotifier<String>(
      "Just trust yourself, then you will know how to live.");
  final ValueNotifier<String> quoteAuthor = ValueNotifier<String>("Goethe");
  final ValueNotifier<String> iconLink = ValueNotifier<String>("");

  final ValueNotifier<List<Ads>> adItems = ValueNotifier<List<Ads>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  // Add a loading indicator specifically for share operation
  final ValueNotifier<bool> isSharing = ValueNotifier<bool>(false);

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

    fetchWeatherData().then((_) {
      return Future.wait([
        fetchQuoteData(),
        fetchAdsData(),
      ]);
    }).then((_) {
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

      final response = await _apiService.getAdsOnly();
      debugPrint("📥 Received response for Ads");

      final adsResponse = AdsResponseModel.fromJson(response);

      if (adsResponse.success == true &&
          adsResponse.response != null &&
          adsResponse.response!.ads != null &&
          adsResponse.response!.ads!.isNotEmpty) {
        final List<Ads> ads = adsResponse.response!.ads!.map((ad) {
          String plainDescription = HtmlParsers.htmlToText(ad.description ?? "");

          return Ads(
            adsId: ad.adsId ?? 0,
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

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied');
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return await Geolocator.getLastKnownPosition();
    }
  }

  Future<void> fetchWeatherData() async {
    try {
      debugPrint("🌤️ Fetching weather data...");

      final position = await _getCurrentLocation();

      if (position == null) {
        debugPrint("❌ Unable to get location. Using default coordinates.");
        //fetchWeatherWithCoordinates("23.021582", "72.668335");
        return;
      }

      final latitude = position.latitude.toStringAsFixed(6);
      final longitude = position.longitude.toStringAsFixed(6);

      debugPrint("📍 Got location: Lat: $latitude, Long: $longitude");

      fetchWeatherWithCoordinates(latitude, longitude);

    } catch (e) {
      debugPrint("❌ Error in weather fetch flow: $e");
      date.value = DateFormat("MMM dd, yyyy").format(DateTime.now());
    }
  }

  Future<void> fetchWeatherWithCoordinates(String latitude, String longitude) async {
    try {
      final token = SharedPrefsService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        debugPrint("❌ No authentication token found for weather API");
        return;
      }

      _apiService.client.addAuthToken(token);

      final locationData = {
        'latitude': latitude,
        'longitude': longitude,
      };

      final response = await _apiService.getWeather(locationData);
      debugPrint("📥 Weather API Response: $response");

      if (response.containsKey('temperature')) {
        final temp = response['temperature'];
        final tempString = temp is double ? temp.toStringAsFixed(2) : temp.toString();

        temperature.value = "${tempString}°C";

        final modifiedResponse = Map<String, dynamic>.from(response);
        modifiedResponse['temperature'] = tempString;

        getWeatherData.value = WeatherResponseModel.fromJson(modifiedResponse);

        if (response.containsKey('icon') && response['icon'] != null) {
          iconLink.value = response['icon'];
        }

        debugPrint("✅ Weather Updated: ${temperature.value}");
      } else {
        debugPrint("⚠️ Weather API response missing temperature: $response");
      }

      date.value = DateFormat("MMM dd, yyyy").format(DateTime.now());

    } catch (e) {
      debugPrint("❌ Error fetching weather: $e");
      date.value = DateFormat("MMM dd, yyyy").format(DateTime.now());
    }
  }

  Future<void> shareAd(BuildContext context, Ads ad) async {
    try {
      isSharing.value = true;

      final Map<String, dynamic> shareData = {
        'id': ad.adsId.toString(),
        'job_or_ad': '2',
        'medium': 'Whatsapp',
      };

      debugPrint("🔄 Sharing ad: ${ad.subjectLine} (ID: ${ad.adsId})");
      debugPrint("📤 Share request data: $shareData");

      final response = await _apiService.getJobShare(shareData);
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
          final String shareText = ad.shareDescription?.isNotEmpty == true
              ? "${ad.shareDescription!}\n\n$shareLink"
              : "Check out this ad: ${ad.subjectLine ?? 'Untitled Ad'}\n\n$shareLink";

          await Share.share(
            shareText,
            subject: ad.subjectLine ?? 'Ad',
          );

          debugPrint("✅ Ad shared successfully");
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing: ${e.toString()}')),
      );

      debugPrint("❌ Exception during share operation: $e");
    } finally {
      isSharing.value = false;
    }
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
      await fetchWeatherData();

      await Future.wait([
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
    isSharing.dispose();
    _autoScrollTimer?.cancel();
  }
}