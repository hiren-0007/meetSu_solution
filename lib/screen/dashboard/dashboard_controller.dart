import 'dart:io';
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
  static const Duration _autoScrollInterval = Duration(seconds: 5);
  static const Duration _apiTimeout = Duration(seconds: 30);
  static const Duration _locationTimeout = Duration(seconds: 10);
  static const String _fallbackBaseUrl =
      "https://meetsusolutions.com/frontend/web/site/ads?id=";

  final ApiService _apiService;

  String? _cachedToken;
  DateTime? _lastWeatherFetch;
  DateTime? _lastQuoteFetch;
  DateTime? _lastAdsFetch;
  static const Duration _cacheValidityDuration = Duration(minutes: 15);

  final ValueNotifier<String> temperature = ValueNotifier<String>("Loading...");
  final ValueNotifier<String> date =
      ValueNotifier<String>(DateFormat("MMM dd, yyyy").format(DateTime.now()));

  final ValueNotifier<String> quote = ValueNotifier<String>(
      "Just trust yourself, then you will know how to live.");
  final ValueNotifier<String> quoteAuthor = ValueNotifier<String>("Goethe");
  final ValueNotifier<String> iconLink = ValueNotifier<String>("");

  final ValueNotifier<List<Ads>> adItems = ValueNotifier<List<Ads>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isSharing = ValueNotifier<bool>(false);

  final ValueNotifier<WeatherResponseModel?> getWeatherData =
      ValueNotifier<WeatherResponseModel?>(null);

  Timer? _autoScrollTimer;
  PageController? _pageController;
  Function(int)? _onIndexChanged;
  int _currentAdIndex = 0;

  final ValueNotifier<List<String>> benefits = ValueNotifier<List<String>>([
    "You will able to clock in and clock out for your time attendance.",
    "You will get all updates about your shifts and upcoming payrolls.",
    "Real-time notifications for schedule changes and important updates.",
    "Easy access to payroll information and work history."
  ]);

  DashboardController({ApiService? apiService})
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

  void startAutoScrollWithPageController(
      PageController pageController, Function(int) onIndexChanged) {
    _pageController = pageController;
    _onIndexChanged = onIndexChanged;
    _currentAdIndex = 0; // Start from first item
    _setupAutoScroll();
  }

  void updateCurrentIndex(int index) {
    _currentAdIndex = index;
  }

  void _setupAutoScroll() {
    _autoScrollTimer?.cancel();

    if (adItems.value.isEmpty || _pageController == null) return;

    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (timer) {
      if (adItems.value.isNotEmpty &&
          _pageController != null &&
          _pageController!.hasClients) {
        // Calculate next index (loop back to 0 after last item)
        _currentAdIndex = (_currentAdIndex + 1) % adItems.value.length;

        // Get current page and calculate next page for infinite scroll
        final currentPage = _pageController!.page?.round() ?? 0;
        final currentRealIndex = currentPage % adItems.value.length;

        int targetPage;
        if (_currentAdIndex == 0 &&
            currentRealIndex == adItems.value.length - 1) {
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

      _updateCurrentDate();
      await Future.wait([
        _fetchWeatherData(),
        _fetchQuoteData(),
        _fetchAdsData(),
      ]);
      if (adItems.value.isNotEmpty) {
        // Don't setup auto scroll here - will be done when PageController is ready
        _currentAdIndex = 0; // Reset to first item
      }
    } catch (error) {
      _setErrorMessage("Failed to load dashboard data");
    } finally {
      isLoading.value = false;
    }
  }

  void _updateCurrentDate() {
    date.value = DateFormat("MMM dd, yyyy").format(DateTime.now());
  }

  void setCurrentIndex(int index) {
    if (index >= 0 &&
        index < adItems.value.length &&
        currentIndex.value != index) {
      currentIndex.value = index;
    }
  }

  Future<void> _fetchQuoteData() async {
    try {
      if (_lastQuoteFetch != null &&
          DateTime.now().difference(_lastQuoteFetch!) <
              _cacheValidityDuration) {
        return;
      }
      final response = await _apiService.getQuote().timeout(_apiTimeout);
      final quoteText = response['quoteText']?.toString().trim();
      final authorText = response['quoteAuthor']?.toString().trim();

      quote.value = quoteText?.isNotEmpty == true
          ? quoteText!
          : "Just trust yourself, then you will know how to live.";

      quoteAuthor.value =
          authorText?.isNotEmpty == true ? authorText! : "Goethe";

      _lastQuoteFetch = DateTime.now();
    } catch (e) {
      debugPrint("❌ Error fetching quote: $e");
    }
  }

  Future<void> _fetchAdsData() async {
    try {
      if (_lastAdsFetch != null &&
          DateTime.now().difference(_lastAdsFetch!) < _cacheValidityDuration) {
        return;
      }
      final token =
          _cachedToken ?? SharedPrefsService.instance.getAccessToken();
      if (token?.isEmpty != false) {
        throw Exception("No authentication token found");
      }
      if (_cachedToken != token) {
        _cachedToken = token;
      }

      _apiService.client.addAuthToken(token!);

      final response = await _apiService.getAdsOnly().timeout(_apiTimeout);
      await _processAdsResponse(response);
      _lastAdsFetch = DateTime.now();
    } catch (e) {
      debugPrint("❌ Error fetching ads data: $e");
      adItems.value = [];
    }
  }

  Future<void> _processAdsResponse(Map<String, dynamic> response) async {
    try {
      final adsResponse = AdsResponseModel.fromJson(response);

      if (adsResponse.success == true &&
          adsResponse.response?.ads?.isNotEmpty == true) {
        final List<Ads> processedAds = adsResponse.response!.ads!.map((ad) {
          String htmlDescription = ad.description ?? "";

          return Ads(
            adsId: ad.adsId ?? 0,
            subjectLine: ad.subjectLine?.isNotEmpty == true
                ? ad.subjectLine!
                : "No Subject",
            description: htmlDescription,
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
      } else {
        adItems.value = [];
        debugPrint("⚠️ No ads available or API returned error: ${adsResponse.message}");
      }
    } catch (e) {
      debugPrint("❌ Error processing ads response: $e");
      throw Exception("Failed to process ads data");
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
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
          DateTime.now().difference(_lastWeatherFetch!) <
              _cacheValidityDuration) {
        return;
      }

      final position = await _getCurrentLocation();
      if (position == null) {
        temperature.value = "25°C";
        return;
      }

      final latitude = position.latitude.toStringAsFixed(6);
      final longitude = position.longitude.toStringAsFixed(6);

      await _fetchWeatherWithCoordinates(latitude, longitude);
      _lastWeatherFetch = DateTime.now();
    } catch (e) {
      debugPrint("❌ Error in weather fetch flow: $e");
      temperature.value = "25°C";
    }
  }

  Future<void> _fetchWeatherWithCoordinates(
      String latitude, String longitude) async {
    try {
      final token =
          _cachedToken ?? SharedPrefsService.instance.getAccessToken();
      if (token?.isEmpty != false) {
        return;
      }

      _apiService.client.addAuthToken(token!);

      final locationData = {
        'latitude': latitude,
        'longitude': longitude,
      };

      final response =
          await _apiService.getWeather(locationData).timeout(_apiTimeout);

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

        getWeatherData.value =
            WeatherResponseModel.fromJson({'temperature': tempString});
      } else {
        temperature.value = "25°C";
      }
    } catch (e) {
      debugPrint("❌ Error processing weather response: $e");
      temperature.value = "25°C";
    }
  }

  Future<void> refreshDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      _lastWeatherFetch = null;
      _lastQuoteFetch = null;
      _lastAdsFetch = null;

      _updateCurrentDate();

      await Future.wait([
        _fetchWeatherData(),
        _fetchQuoteData(),
        _fetchAdsData(),
      ]);

      _currentAdIndex = 0;
      currentIndex.value = 0;
    } catch (e) {
      debugPrint("❌ Error refreshing dashboard data: $e");
      _setErrorMessage("Failed to refresh data");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> shareAd(BuildContext context, Ads ad) async {
    if (isSharing.value) return;

    try {
      isSharing.value = true;

      final shareLink = await _getAdShareLink(ad);
      final shareText = _buildAdShareText(ad, shareLink);

      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: ad.subjectLine ?? 'Advertisement',
        ),
      );

      if (context.mounted) {
        _showShareSuccess(context);
      }
    } catch (e) {
      debugPrint("❌ Error during ad sharing: $e");

      if (context.mounted) {
        await _handleAdShareError(context, ad);
      }
    } finally {
      isSharing.value = false;
    }
  }

  Future<void> shareAdWithRichContent(
    BuildContext context,
    Ads ad,
    String shareText,
    String? imageUrl,
  ) async {
    if (isSharing.value) return;

    try {
      isSharing.value = true;

      if (Platform.isIOS) {
        await _shareForIOS(shareText, imageUrl);
      } else {
        await _shareForAndroid(shareText, imageUrl);
      }

      if (context.mounted) {
        _showShareSuccess(context);
      }
    } catch (e) {
      debugPrint("❌ Error during rich content sharing: $e");

      if (context.mounted) {
        // Fallback to original sharing method
        await shareAd(context, ad);
      }
    } finally {
      isSharing.value = false;
    }
  }

  Future<void> _shareForIOS(String text, String? imageUrl) async {
    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final enhancedText = '''
$text

📸 Ad Image: $imageUrl

📱 Download our app for more opportunities!
      ''';

        await SharePlus.instance.share(
          ShareParams(
            text: enhancedText,
            subject: 'Advertisement - MeetSu Solutions',
          ),
        );
      } else {
        await SharePlus.instance.share(
          ShareParams(
            text: text,
            subject: 'Advertisement - MeetSu Solutions',
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ iOS sharing error: $e");
      await SharePlus.instance.share(
        ShareParams(text: text),
      );
    }
  }

  Future<void> _shareForAndroid(String text, String? imageUrl) async {
    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final enhancedText = '''
$text

🖼️ View Ad Image: $imageUrl

📲 Get the MeetSu Solutions app for instant updates!
      ''';

        await SharePlus.instance.share(
          ShareParams(
            text: enhancedText,
            subject: 'Advertisement - MeetSu Solutions',
          ),
        );
      } else {
        await SharePlus.instance.share(
          ShareParams(
            text: text,
            subject: 'Advertisement - MeetSu Solutions',
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ Android sharing error: $e");
      await SharePlus.instance.share(
        ShareParams(text: text),
      );
    }
  }

  Future<void> shareAdWithCustomDialog(
    BuildContext context,
    Ads ad,
  ) async {
    if (isSharing.value) return;

    try {
      isSharing.value = true;

      final String shareContent = _buildUnifiedShareContent(ad);
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AdShareOptionsBottomSheet(
          shareContent: shareContent,
          imageUrl: ad.imageUrl,
          adTitle: ad.subjectLine ?? 'Advertisement',
          onShare: (platform) async {
            Navigator.pop(context);
            await _shareOnSpecificPlatform(platform, shareContent, ad.imageUrl);
          },
        ),
      );
    } catch (e) {
      debugPrint("❌ Custom sharing error: $e");
      await shareAd(context, ad);
    } finally {
      isSharing.value = false;
    }
  }

  String _buildUnifiedShareContent(Ads ad) {
    final shareLink = _getFallbackAdShareLink(ad);

    return '''
🎯 ${ad.subjectLine ?? "Advertisement"}

📍 Location: ${ad.place ?? "Not specified"}
💰 Amount: ${ad.amount ?? "Negotiable"}
📅 Date: ${ad.date ?? "Not specified"}

📝 Description:
${ad.description ?? "No description available"}

🔗 View Now: $shareLink

#Advertisement #Opportunity #MeetsuSolutions
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
          await SharePlus.instance.share(
            ShareParams(
              text: content,
              subject: 'Advertisement - MeetSu Solutions',
            ),
          );
          break;
      }
    } catch (e) {
      debugPrint("❌ Platform-specific sharing error: $e");
      await SharePlus.instance.share(
        ShareParams(text: content),
      );
    }
  }

  Future<void> _shareToWhatsApp(String text, String? imageUrl) async {
    try {
      String whatsappText = text;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        whatsappText = '''
$text

📸 $imageUrl
      ''';
      }

      await SharePlus.instance.share(
        ShareParams(
          text: whatsappText,
          subject: 'Advertisement - MeetSu Solutions',
        ),
      );
    } catch (e) {
      debugPrint("❌ WhatsApp sharing error: $e");
      await SharePlus.instance.share(
        ShareParams(text: text),
      );
    }
  }

  Future<void> _shareToTelegram(String text, String? imageUrl) async {
    try {
      String telegramText = text;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        telegramText = '''
$text

🖼️ Image: $imageUrl
      ''';
      }

      await SharePlus.instance.share(
        ShareParams(
          text: telegramText,
          subject: 'Advertisement - MeetSu Solutions',
        ),
      );
    } catch (e) {
      debugPrint("❌ Telegram sharing error: $e");
      await SharePlus.instance.share(
        ShareParams(text: text),
      );
    }
  }

  Future<void> _shareToEmail(String text, String? imageUrl) async {
    try {
      final emailText = imageUrl != null && imageUrl.isNotEmpty
          ? '$text\n\nAd Image: $imageUrl'
          : text;

      await SharePlus.instance.share(
        ShareParams(
          text: emailText,
          subject: 'Advertisement - MeetSu Solutions',
        ),
      );
    } catch (e) {
      debugPrint("❌ Email sharing error: $e");
      await SharePlus.instance.share(
        ShareParams(text: text),
      );
    }
  }

  Future<void> _shareToSMS(String text) async {
    try {
      final smsText = text.length > 160 ? '${text.substring(0, 157)}...' : text;

      await SharePlus.instance.share(
        ShareParams(
          text: smsText,
          subject: 'Advertisement - MeetSu Solutions',
        ),
      );
    } catch (e) {
      debugPrint("❌ SMS sharing error: $e");
      await SharePlus.instance.share(
        ShareParams(text: text),
      );
    }
  }

  Future<String> _getAdShareLink(Ads ad) async {
    try {
      final token =
          _cachedToken ?? SharedPrefsService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

      _apiService.client.addAuthToken(token);

      final requestData = {
        'id': ad.adsId.toString(),
        'job_or_ad': '2', // 2 for ads
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
        : ad.subjectLine ?? 'Advertisement';

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

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: ad.subjectLine ?? 'Advertisement',
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Shared with fallback link"),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ Error in fallback sharing: $e");
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
  }

  void downloadFromAppStore(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirecting to App Store...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void pauseAutoScroll() {
    _autoScrollTimer?.cancel();
    debugPrint("⏸️ Auto-scroll paused");
  }

  void resumeAutoScroll() {
    if (_autoScrollTimer?.isActive != true && adItems.value.isNotEmpty) {
      _setupAutoScroll();
    }
  }

  Future<void> retryFetch() async {
    _cachedToken = null;
    _lastWeatherFetch = null;
    _lastQuoteFetch = null;
    _lastAdsFetch = null;
    _cacheAuthToken();
    await _initialize();
  }

  void dispose() {
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
  }
}

class AdShareOptionsBottomSheet extends StatelessWidget {
  final String shareContent;
  final String? imageUrl;
  final String adTitle;
  final Function(String) onShare;

  const AdShareOptionsBottomSheet({
    Key? key,
    required this.shareContent,
    this.imageUrl,
    required this.adTitle,
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
                  'Share "$adTitle"',
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
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
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
