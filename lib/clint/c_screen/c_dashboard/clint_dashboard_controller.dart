import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:meetsu_solutions/model/job&ads/ads/ads_response_model.dart';
import 'package:meetsu_solutions/model/weather/weather_response_model.dart';
import 'dart:async';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/utils/extra/html_parsers.dart';
import 'package:share_plus/share_plus.dart';


class ClientDashboardController {
  static const Duration _autoScrollInterval = Duration(seconds: 5);
  static const Duration _apiTimeout = Duration(seconds: 30);
  static const Duration _locationTimeout = Duration(seconds: 10);
  static const String _fallbackBaseUrl =
      "https://meetsusolutions.com/frontend/web/site/ads?id=";

  final ApiService _apiService;

  // Cache management
  String? _cachedToken;
  DateTime? _lastWeatherFetch;
  DateTime? _lastQuoteFetch;
  DateTime? _lastAdsFetch;
  static const Duration _cacheValidityDuration = Duration(minutes: 15);

  // Weather & Date ValueNotifiers
  final ValueNotifier<String> temperature = ValueNotifier<String>("Loading...");
  final ValueNotifier<String> date = ValueNotifier<String>(
      DateFormat("MMM dd, yyyy").format(DateTime.now())
  );

  // Quote ValueNotifiers
  final ValueNotifier<String> quote = ValueNotifier<String>(
      "Success is not the key to happiness. Happiness is the key to success."
  );
  final ValueNotifier<String> quoteAuthor = ValueNotifier<String>("Albert Schweitzer");
  final ValueNotifier<String> iconLink = ValueNotifier<String>("");

  // Ads ValueNotifiers
  final ValueNotifier<List<Ads>> adItems = ValueNotifier<List<Ads>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isSharing = ValueNotifier<bool>(false);
  final ValueNotifier<bool> hasData = ValueNotifier<bool>(false);

  // Weather data
  final ValueNotifier<WeatherResponseModel?> getWeatherData =
  ValueNotifier<WeatherResponseModel?>(null);

  // Auto-scroll timer and PageController management
  Timer? _autoScrollTimer;
  PageController? _pageController;
  Function(int)? _onIndexChanged;
  int _currentAdIndex = 0;

  // Client-specific benefits
  final ValueNotifier<List<String>> benefits = ValueNotifier<List<String>>([
    "Manage your workforce efficiently with real-time tracking.",
    "Monitor employee attendance and productivity seamlessly.",
    "Get detailed analytics and reports for better decision making.",
    "Access comprehensive dashboard for all your business operations."
  ]);

  ClientDashboardController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    _initializeController();
  }

  void _initializeController() {
    _cacheAuthToken();
    _initialize();
  }

  void _cacheAuthToken() {
    _cachedToken = SharedPrefsService.instance.getAccessToken();
  }

  // Auto-scroll setup
  void startAutoScrollWithPageController(PageController pageController, Function(int) onIndexChanged) {
    _pageController = pageController;
    _onIndexChanged = onIndexChanged;
    _currentAdIndex = 0;
    _setupAutoScroll();
  }

  void updateCurrentIndex(int index) {
    _currentAdIndex = index;
  }

  void _setupAutoScroll() {
    _autoScrollTimer?.cancel();

    if (adItems.value.isEmpty || _pageController == null) return;

    debugPrint("🔄 Starting auto-scroll for ${adItems.value.length} ads");

    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (timer) {
      if (adItems.value.isNotEmpty && _pageController != null && _pageController!.hasClients) {

        _currentAdIndex = (_currentAdIndex + 1) % adItems.value.length;

        final currentPage = _pageController!.page?.round() ?? 0;
        final currentRealIndex = currentPage % adItems.value.length;

        int targetPage;
        if (_currentAdIndex == 0 && currentRealIndex == adItems.value.length - 1) {
          targetPage = currentPage + 1;
        } else {
          targetPage = currentPage + 1;
        }

        _pageController!.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        _onIndexChanged?.call(_currentAdIndex);
      }
    });
  }

  Future<void> _initialize() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final token = _cachedToken;
      if (token?.isNotEmpty == true) {
        _apiService.client.addAuthToken(token!);
      }

      debugPrint("🔄 Initializing Client Dashboard...");

      _updateCurrentDate();

      await Future.wait([
        _fetchWeatherData(),
        _fetchQuoteData(),
        _fetchAdsData(),
      ]);

      debugPrint("✅ Client Dashboard fully initialized");

      if (adItems.value.isNotEmpty) {
        hasData.value = true;
        _currentAdIndex = 0;
      } else {
        hasData.value = false;
      }
    } catch (error) {
      debugPrint("❌ Error during initialization: $error");
      _setErrorMessage("Failed to load dashboard data");
      hasData.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void _updateCurrentDate() {
    date.value = DateFormat("MMM dd, yyyy").format(DateTime.now());
  }

  void setCurrentIndex(int index) {
    if (index >= 0 && index < adItems.value.length && currentIndex.value != index) {
      currentIndex.value = index;
    }
  }

  Future<void> _fetchQuoteData() async {
    try {
      if (_lastQuoteFetch != null &&
          DateTime.now().difference(_lastQuoteFetch!) < _cacheValidityDuration) {
        debugPrint("📝 Using cached quote data");
        return;
      }

      debugPrint("📝 Fetching quote data...");

      final response = await _apiService.getQuote().timeout(_apiTimeout);
      debugPrint("📥 Quote API Response received");

      final quoteText = response['quoteText']?.toString().trim();
      final authorText = response['quoteAuthor']?.toString().trim();

      quote.value = quoteText?.isNotEmpty == true
          ? quoteText!
          : "Success is not the key to happiness. Happiness is the key to success.";

      quoteAuthor.value = authorText?.isNotEmpty == true
          ? authorText!
          : "Albert Schweitzer";

      _lastQuoteFetch = DateTime.now();
      debugPrint("✅ Quote Updated: ${quote.value} - ${quoteAuthor.value}");
        } catch (e) {
      debugPrint("❌ Error fetching quote: $e");
    }
  }

  Future<void> _fetchAdsData() async {
    try {
      if (_lastAdsFetch != null &&
          DateTime.now().difference(_lastAdsFetch!) < _cacheValidityDuration) {
        debugPrint("📢 Using cached ads data");
        return;
      }

      debugPrint("📢 Fetching ads data for client...");

      final token = _cachedToken ?? SharedPrefsService.instance.getAccessToken();
      if (token?.isEmpty != false) {
        throw Exception("No authentication token found");
      }

      if (_cachedToken != token) {
        _cachedToken = token;
      }

      _apiService.client.addAuthToken(token!);

      final response = await _apiService.getAdsOnly().timeout(_apiTimeout);
      debugPrint("📥 Received response for Client Ads");

      await _processAdsResponse(response);
      _lastAdsFetch = DateTime.now();

    } catch (e) {
      debugPrint("❌ Error fetching ads data: $e");
      adItems.value = [];
      hasData.value = false;
    }
  }

  Future<void> _processAdsResponse(Map<String, dynamic> response) async {
    try {
      final adsResponse = AdsResponseModel.fromJson(response);

      if (adsResponse.success == true &&
          adsResponse.response?.ads?.isNotEmpty == true) {

        final List<Ads> processedAds = adsResponse.response!.ads!.map((ad) {
          String plainDescription = HtmlParsers.htmlToText(ad.description ?? "");

          return Ads(
            adsId: ad.adsId ?? 0,
            subjectLine: ad.subjectLine?.isNotEmpty == true
                ? ad.subjectLine!
                : "No Subject",
            description: plainDescription.isNotEmpty
                ? plainDescription
                : "No description available",
            shareDescription: ad.shareDescription ?? "",
            date: ad.date?.isNotEmpty == true ? ad.date! : "Unknown Date",
            place: ad.place?.isNotEmpty == true ? ad.place! : "Unknown Place",
            amount: ad.amount?.isNotEmpty == true ? ad.amount! : "0.00",
            imageUrl: ad.imageUrl ?? "",
            status: ad.status?.isNotEmpty == true ? ad.status! : "OFF",
            onlyImage: ad.onlyImage ?? "",
          );
        }).toList();

        adItems.value = processedAds;
        currentIndex.value = 0;
        _currentAdIndex = 0;
        hasData.value = true;
        debugPrint("✅ Loaded ${processedAds.length} client ads");
      } else {
        adItems.value = [];
        hasData.value = false;
        debugPrint("⚠️ No client ads available or API returned error: ${adsResponse.message}");
      }
    } catch (e) {
      debugPrint("❌ Error processing client ads response: $e");
      hasData.value = false;
      throw Exception("Failed to process ads data");
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('🌍 Location services are disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('🌍 Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('🌍 Location permissions are permanently denied');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: _locationTimeout,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (e2) {
        debugPrint('❌ Error getting last known position: $e2');
        return null;
      }
    }
  }

  Future<void> _fetchWeatherData() async {
    try {
      if (_lastWeatherFetch != null &&
          DateTime.now().difference(_lastWeatherFetch!) < _cacheValidityDuration) {
        debugPrint("🌤️ Using cached weather data");
        return;
      }

      debugPrint("🌤️ Fetching weather data for client...");

      final position = await _getCurrentLocation();
      if (position == null) {
        debugPrint("❌ Unable to get location. Using default temperature.");
        temperature.value = "25°C";
        return;
      }

      final latitude = position.latitude.toStringAsFixed(6);
      final longitude = position.longitude.toStringAsFixed(6);

      debugPrint("📍 Got location: Lat: $latitude, Long: $longitude");

      await _fetchWeatherWithCoordinates(latitude, longitude);
      _lastWeatherFetch = DateTime.now();

    } catch (e) {
      debugPrint("❌ Error in weather fetch flow: $e");
      temperature.value = "25°C";
    }
  }

  Future<void> _fetchWeatherWithCoordinates(String latitude, String longitude) async {
    try {
      final token = _cachedToken ?? SharedPrefsService.instance.getAccessToken();
      if (token?.isEmpty != false) {
        debugPrint("❌ No authentication token found for weather API");
        return;
      }

      _apiService.client.addAuthToken(token!);

      final locationData = {
        'latitude': latitude,
        'longitude': longitude,
      };

      final response = await _apiService.showClientWeather(locationData).timeout(_apiTimeout);
      debugPrint("📥 Weather API Response received");

      await _processWeatherResponse(response);

    } catch (e) {
      debugPrint("❌ Error fetching weather: $e");
      temperature.value = "25°C";
    }
  }

  Future<void> _processWeatherResponse(Map<String, dynamic> response) async {
    try {
      if (response.containsKey('temperature')) {
        final temp = response['temperature'];
        String tempString;

        if (temp is num) {
          tempString = temp.toStringAsFixed(1);
        } else {
          tempString = temp.toString();
        }

        temperature.value = "${tempString}°C";

        getWeatherData.value = WeatherResponseModel.fromJson({
          'temperature': tempString
        });

        debugPrint("✅ Weather Updated: ${temperature.value}");
      } else {
        debugPrint("⚠️ Weather API response missing temperature");
        temperature.value = "25°C";
      }
    } catch (e) {
      debugPrint("❌ Error processing weather response: $e");
      temperature.value = "25°C";
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      _lastWeatherFetch = null;
      _lastQuoteFetch = null;
      _lastAdsFetch = null;

      debugPrint("🔄 Refreshing client dashboard data...");

      _updateCurrentDate();

      await Future.wait([
        _fetchWeatherData(),
        _fetchQuoteData(),
        _fetchAdsData(),
      ]);

      _currentAdIndex = 0;
      currentIndex.value = 0;

      debugPrint("✅ Client dashboard data refreshed");
    } catch (e) {
      debugPrint("❌ Error refreshing client dashboard data: $e");
      _setErrorMessage("Failed to refresh data");
      hasData.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> shareAd(BuildContext context, Ads ad) async {
    if (isSharing.value) return;

    try {
      isSharing.value = true;
      debugPrint("🔄 Sharing client ad: ${ad.subjectLine} (ID: ${ad.adsId})");

      final shareLink = await _getAdShareLink(ad);
      final shareText = _buildAdShareText(ad, shareLink);

      await Share.share(shareText, subject: ad.subjectLine ?? 'Client Advertisement');
      debugPrint("✅ Client ad shared successfully");

      if (context.mounted) {
        _showShareSuccess(context);
      }
    } catch (e) {
      debugPrint("❌ Error during client ad sharing: $e");

      if (context.mounted) {
        await _handleAdShareError(context, ad);
      }
    } finally {
      isSharing.value = false;
    }
  }

  Future<String> _getAdShareLink(Ads ad) async {
    try {
      final token = _cachedToken ?? SharedPrefsService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

      _apiService.client.addAuthToken(token);

      final requestData = {
        'id': ad.adsId.toString(),
        'job_or_ad': '2',
        'medium': 'Whatsapp'
      };

      final response = await _apiService.getJobShare(requestData);
      return _extractAdShareLink(response, ad);
    } catch (e) {
      debugPrint("⚠️ Failed to get share link from API: $e");
      return _getFallbackAdShareLink(ad);
    }
  }

  String _extractAdShareLink(Map<String, dynamic> response, Ads ad) {
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
        !shareLink.contains("ads?id=") &&
        shareLink.contains("ads-view?refid=")) {
      shareLink = "$_fallbackBaseUrl${ad.adsId}";
    }

    if (shareLink.isEmpty) {
      throw Exception("Empty share link received from API");
    }

    return shareLink;
  }

  String _getFallbackAdShareLink(Ads ad) {
    return "$_fallbackBaseUrl${ad.adsId}";
  }

  String _buildAdShareText(Ads ad, String shareLink) {
    final description = ad.shareDescription?.isNotEmpty == true
        ? ad.shareDescription!
        : ad.subjectLine ?? 'Client Advertisement';

    return "$description\n$shareLink";
  }

  void _showShareSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ad shared successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleAdShareError(BuildContext context, Ads ad) async {
    final fallbackLink = _getFallbackAdShareLink(ad);
    final shareText = _buildAdShareText(ad, fallbackLink);

    await Share.share(shareText, subject: ad.subjectLine ?? 'Client Advertisement');

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

  void _setErrorMessage(String message) {
    errorMessage.value = message;
    Future.delayed(const Duration(seconds: 5), () {
      if (errorMessage.value == message) {
        errorMessage.value = null;
      }
    });
  }

  void downloadFromPlayStore(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirecting to Play Store...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
    debugPrint("📱 Client downloading from Play Store");
  }

  void downloadFromAppStore(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirecting to App Store...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
    debugPrint("📱 Client downloading from App Store");
  }

  void pauseAutoScroll() {
    _autoScrollTimer?.cancel();
    debugPrint("⏸️ Client auto-scroll paused");
  }

  void resumeAutoScroll() {
    if (_autoScrollTimer?.isActive != true && adItems.value.isNotEmpty) {
      _setupAutoScroll();
      debugPrint("▶️ Client auto-scroll resumed");
    }
  }

  Future<void> retryFetch() async {
    debugPrint("🔄 Retrying client dashboard data fetch");
    _cachedToken = null;
    _lastWeatherFetch = null;
    _lastQuoteFetch = null;
    _lastAdsFetch = null;
    _cacheAuthToken();
    await _initialize();
  }

  void dispose() {
    debugPrint("🧹 Disposing ClientDashboardController resources");
    _autoScrollTimer?.cancel();

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
    getWeatherData.dispose();
    hasData.dispose();
  }
}