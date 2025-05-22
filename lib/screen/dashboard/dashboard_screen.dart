import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meetsu_solutions/model/job&ads/ads/ads_response_model.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/screen/dashboard/dashboard_controller.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {

  late final DashboardController _controller;
  PageController? _pageController;
  int _realPage = 1000; // Start at a large number for infinite scroll

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
    WidgetsBinding.instance.addObserver(this);
    _initializePageController();
    _setupListeners();
  }

  void _initializePageController() {
    _pageController = PageController(initialPage: _realPage);
  }

  void _setupListeners() {
    _controller.adItems.addListener(_onAdItemsChanged);
    _controller.currentIndex.addListener(_onCurrentIndexChanged);
  }

  void _onAdItemsChanged() {
    if (_controller.adItems.value.isNotEmpty && mounted) {
      if (_pageController?.hasClients == true) {
        setState(() {
          _realPage = _pageController!.page!.round();
        });
      }
    }
  }

  void _onCurrentIndexChanged() {
    if (_pageController?.hasClients == true &&
        _controller.adItems.value.isNotEmpty &&
        mounted) {

      final adsLength = _controller.adItems.value.length;
      final targetIndex = _controller.currentIndex.value;
      final currentIndex = _realPage % adsLength;

      // Handle wrap-around from last to first
      if (currentIndex == adsLength - 1 && targetIndex == 0) {
        final nextGroup = (_realPage ~/ adsLength + 1) * adsLength;
        _animateToPage(nextGroup);
        _realPage = nextGroup;
        return;
      }

      // Normal navigation
      final baseGroup = (_realPage ~/ adsLength) * adsLength;
      final targetPage = baseGroup + targetIndex;

      if (_pageController!.page!.round() != targetPage) {
        _animateToPage(targetPage);
        _realPage = targetPage;
      }
    }
  }

  void _animateToPage(int page) {
    _pageController?.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _controller.pauseAutoScroll();
        break;
      case AppLifecycleState.resumed:
        _controller.resumeAutoScroll();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.currentIndex.removeListener(_onCurrentIndexChanged);
    _controller.adItems.removeListener(_onAdItemsChanged);
    _pageController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Device type detection
  bool get isMobile => MediaQuery.of(context).size.width < 600;
  bool get isTablet => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;
  bool get isDesktop => MediaQuery.of(context).size.width >= 1200;

  // Responsive values
  double get horizontalPadding => isMobile ? 16 : isTablet ? 24 : 32;
  double get verticalSpacing => isMobile ? 8 : isTablet ? 12 : 16;
  double get cardBorderRadius => isMobile ? 12 : 15;
  double get fontSizeSmall => isMobile ? 11 : isTablet ? 12 : 13;
  double get fontSizeMedium => isMobile ? 13 : isTablet ? 14 : 15;
  double get fontSizeLarge => isMobile ? 15 : isTablet ? 17 : 19;
  double get fontSizeXLarge => isMobile ? 17 : isTablet ? 19 : 21;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ConnectivityWidget(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: _buildResponsiveBody(),
        ),
      ),
    );
  }

  Widget _buildResponsiveBody() {
    if (isDesktop) {
      return _buildDesktopLayout();
    } else if (isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  // Mobile Layout (< 600px)
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRefreshableHeader(),
        _buildSectionTitle(),
        Expanded(child: _buildMainContent()),
      ],
    );
  }

  // Tablet Layout (600-1200px)
  Widget _buildTabletLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRefreshableHeader(),
        _buildSectionTitle(),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _buildMainContent(),
          ),
        ),
      ],
    );
  }

  // Desktop Layout (> 1200px)
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left sidebar for header
        Container(
          width: 400,
          child: Column(
            children: [
              _buildRefreshableHeader(),
              _buildSectionTitle(),
            ],
          ),
        ),

        // Main content area
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: _buildMainContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildRefreshableHeader() {
    return RefreshIndicator(
      onRefresh: _controller.refreshDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: _buildHeaderCard(),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(horizontalPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Weather and date row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wb_sunny,
                color: Colors.white,
                size: isMobile ? 20 : 24,
              ),
              SizedBox(width: verticalSpacing / 2),
              ValueListenableBuilder<String>(
                valueListenable: _controller.temperature,
                builder: (context, temperature, _) {
                  return ValueListenableBuilder<String>(
                    valueListenable: _controller.date,
                    builder: (context, date, _) {
                      return Flexible(
                        child: Text(
                          "$temperature • $date",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSizeMedium,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),

          SizedBox(height: verticalSpacing),

          // Quote section
          Text(
            "Quote of the day",
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSizeLarge,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: verticalSpacing / 2),

          ValueListenableBuilder<String>(
            valueListenable: _controller.quote,
            builder: (context, quote, _) {
              return Text(
                '"$quote"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSizeMedium,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              );
            },
          ),

          SizedBox(height: verticalSpacing / 2),

          ValueListenableBuilder<String>(
            valueListenable: _controller.quoteAuthor,
            builder: (context, author, _) {
              return Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "- $author",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSizeSmall,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(horizontalPadding, verticalSpacing / 2, horizontalPadding, verticalSpacing / 2),
      child: Text(
        "Advertisements",
        style: TextStyle(
          fontSize: fontSizeXLarge,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: _controller.refreshDashboardData,
      child: ValueListenableBuilder<bool>(
        valueListenable: _controller.isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return _buildLoadingState();
          }

          return ValueListenableBuilder<String?>(
            valueListenable: _controller.errorMessage,
            builder: (context, errorMessage, _) {
              if (errorMessage != null) {
                return _buildErrorState(errorMessage);
              }

              return ValueListenableBuilder<List<Ads>>(
                valueListenable: _controller.adItems,
                builder: (context, adItems, _) {
                  if (adItems.isEmpty) {
                    return _buildAppDownloadSection();
                  }
                  return _buildAdsPageView(adItems);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: isMobile ? 300 : 400,
        margin: EdgeInsets.all(horizontalPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: isMobile ? 40 : 60,
                height: isMobile ? 40 : 60,
                child: const CircularProgressIndicator(strokeWidth: 3),
              ),
              SizedBox(height: verticalSpacing * 2),
              Text(
                "Loading advertisements...",
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: fontSizeMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        margin: EdgeInsets.all(horizontalPadding),
        padding: EdgeInsets.all(horizontalPadding * 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isMobile ? 48 : 64,
              color: Colors.red.shade400,
            ),
            SizedBox(height: verticalSpacing * 2),
            Text(
              errorMessage,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: fontSizeMedium,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: verticalSpacing * 2),
            ElevatedButton.icon(
              onPressed: _controller.retryFetch,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding * 1.5,
                  vertical: verticalSpacing,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdsPageView(List<Ads> adItems) {
    return PageView.builder(
      controller: _pageController,
      itemCount: null, // Infinite scroll
      onPageChanged: (index) {
        _realPage = index;
        final realIndex = index % adItems.length;
        if (_controller.currentIndex.value != realIndex) {
          _controller.setCurrentIndex(realIndex);
        }
      },
      itemBuilder: (context, index) {
        final realIndex = index % adItems.length;
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: _buildAdCard(adItems[realIndex]),
        );
      },
    );
  }

  Widget _buildAdCard(Ads ad) {
    return Container(
      margin: EdgeInsets.all(horizontalPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAdImage(ad),
          _buildAdHeader(ad),
          _buildAdDetails(ad),
          const Divider(height: 1),
          _buildAdDescription(ad),
          SizedBox(height: verticalSpacing),
        ],
      ),
    );
  }

  Widget _buildAdImage(Ads ad) {
    final imageHeight = isMobile ? 200.0 : isTablet ? 250.0 : 300.0;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(cardBorderRadius)),
      child: ad.imageUrl?.isNotEmpty == true
          ? Container(
        width: double.infinity,
        height: imageHeight,
        child: Image.network(
          ad.imageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: imageHeight,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _buildFallbackImage(imageHeight),
        ),
      )
          : _buildFallbackImage(imageHeight),
    );
  }

  Widget _buildFallbackImage(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryColor.withOpacity(0.2),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.campaign,
          size: height * 0.3,
          color: AppTheme.primaryColor.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildAdHeader(Ads ad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, horizontalPadding, horizontalPadding, verticalSpacing),
      child: Text(
        ad.subjectLine ?? "No Subject",
        style: TextStyle(
          fontSize: fontSizeXLarge,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimaryColor,
          height: 1.2,
        ),
        maxLines: isMobile ? 2 : 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildAdDetails(Ads ad) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          // Date and Place row
          Row(
            children: [
              Expanded(child: _buildDetailItem(Icons.date_range, "Date", ad.date ?? "Unknown")),
              SizedBox(width: horizontalPadding),
              Expanded(child: _buildDetailItem(Icons.location_on, "Place", ad.place ?? "Unknown")),
            ],
          ),

          SizedBox(height: verticalSpacing),

          // Status and Amount row
          Row(
            children: [
              Expanded(child: _buildDetailItem(Icons.info, "Status", ad.status ?? "OFF")),
              SizedBox(width: horizontalPadding),
              Expanded(child: _buildDetailItem(Icons.attach_money, "Amount", "\$ ${ad.amount ?? '0.00'}", isHighlighted: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, {bool isHighlighted = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: fontSizeMedium + 2,
          color: isHighlighted ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
        ),
        SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: fontSizeSmall,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                  color: isHighlighted ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
                  fontSize: fontSizeSmall,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdDescription(Ads ad) {
    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Description:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSizeMedium,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              _buildShareButton(ad),
            ],
          ),

          SizedBox(height: verticalSpacing / 2),

          Text(
            ad.description ?? "No description available",
            style: TextStyle(
              color: AppTheme.textPrimaryColor,
              fontSize: fontSizeSmall,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(Ads ad) {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.isSharing,
      builder: (context, isSharing, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isSharing ? null : () => _controller.shareAd(context, ad),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 10 : 12,
                vertical: isMobile ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: isSharing ? Colors.grey : AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSharing)
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    Icon(
                      Icons.share,
                      color: Colors.white,
                      size: isMobile ? 14 : 16,
                    ),
                  SizedBox(width: 4),
                  Text(
                    isSharing ? "Sharing..." : "Share",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSizeSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppDownloadSection() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: _buildAppDownloadCard(),
    );
  }

  Widget _buildAppDownloadCard() {
    return Container(
      margin: EdgeInsets.all(horizontalPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(horizontalPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(cardBorderRadius)),
            ),
            child: Text(
              "Download MEETsu Solution App",
              style: TextStyle(
                fontSize: fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Download buttons
          Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              children: [
                SizedBox(height: verticalSpacing),
                _buildDownloadButton(
                  onTap: () => _controller.downloadFromPlayStore(context),
                  label: "Download from Play Store",
                  icon: Icons.android,
                  color: Colors.green,
                ),
                SizedBox(height: verticalSpacing),
                _buildDownloadButton(
                  onTap: () => _controller.downloadFromAppStore(context),
                  label: "Download from App Store",
                  icon: Icons.apple,
                  color: Colors.black,
                ),
              ],
            ),
          ),

          _buildAppDownloadInfo(),
          const Divider(height: 1),
          _buildAppDownloadDescription(),
          _buildAppDownloadBenefits(),
        ],
      ),
    );
  }

  Widget _buildDownloadButton({
    required VoidCallback onTap,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: isMobile ? 50 : 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: isMobile ? 20 : 24),
              SizedBox(width: verticalSpacing),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSizeMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppDownloadInfo() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Place: App Store and Play Store",
                  style: TextStyle(fontSize: fontSizeSmall),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ValueListenableBuilder<String>(
                valueListenable: _controller.date,
                builder: (context, date, _) {
                  return Text(
                    "Date: $date",
                    style: TextStyle(fontSize: fontSizeSmall),
                  );
                },
              ),
            ],
          ),
        ),

        SizedBox(height: verticalSpacing),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Status: ",
                    style: TextStyle(fontSize: fontSizeSmall),
                  ),
                  Text(
                    "ON",
                    style: TextStyle(
                      fontSize: fontSizeSmall,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              Text(
                "Amount: \$0.00",
                style: TextStyle(
                  fontSize: fontSizeSmall,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppDownloadDescription() {
    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Description:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSizeMedium,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              // Disabled share button for app download
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.share,
                      color: Colors.grey.shade600,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Share",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizeSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: verticalSpacing / 2),

          Text(
            "Also, share with your co-worker to do the same",
            style: TextStyle(
              fontSize: fontSizeSmall,
              color: AppTheme.textPrimaryColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppDownloadBenefits() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalSpacing),
          child: Text(
            "-: Benefits :-",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSizeMedium,
              color: AppTheme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, horizontalPadding),
          child: ValueListenableBuilder<List<String>>(
            valueListenable: _controller.benefits,
            builder: (context, benefits, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: benefits.asMap().entries.map((entry) {
                  final index = entry.key;
                  final benefit = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: verticalSpacing),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            benefit,
                            style: TextStyle(
                              fontSize: fontSizeSmall,
                              color: AppTheme.textPrimaryColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}