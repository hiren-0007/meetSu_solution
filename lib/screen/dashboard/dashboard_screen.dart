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
  int _currentAdIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
    WidgetsBinding.instance.addObserver(this);
    _setupListeners();
  }

  void _setupListeners() {
    _controller.adItems.addListener(_onAdItemsChanged);
  }

  void _onAdItemsChanged() {
    final ads = _controller.adItems.value;
    if (ads.isNotEmpty && mounted) {
      if (_pageController == null) {
        final middleIndex = ads.length * 500; // Start from middle for infinite scroll
        _pageController = PageController(initialPage: middleIndex);
        _currentAdIndex = 0;
        _startAutoScroll();
      }
    }
  }

  void _startAutoScroll() {
    if (_controller.adItems.value.isNotEmpty) {
      _controller.startAutoScrollWithPageController(_pageController!, (index) {
        if (mounted) {
          setState(() {
            _currentAdIndex = index;
          });
        }
      });
    }
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
    _controller.adItems.removeListener(_onAdItemsChanged);
    _pageController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool get isSmallMobile => MediaQuery.of(context).size.width < 400;
  bool get isMobile => MediaQuery.of(context).size.width < 600;
  bool get isTablet => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;
  bool get isDesktop => MediaQuery.of(context).size.width >= 1200;
  bool get isLargeDesktop => MediaQuery.of(context).size.width >= 1600;

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  double get horizontalPadding {
    if (isSmallMobile) return 8;
    if (isMobile) return 12;
    if (isTablet) return 16;
    if (isDesktop) return 20;
    return 24;
  }

  double get verticalSpacing {
    if (isSmallMobile) return 4;
    if (isMobile) return 6;
    if (isTablet) return 8;
    if (isDesktop) return 10;
    return 12;
  }

  double get cardBorderRadius {
    if (isSmallMobile) return 8;
    if (isMobile) return 12;
    if (isTablet) return 14;
    return 16;
  }

  double get fontSizeSmall {
    if (isSmallMobile) return 10;
    if (isMobile) return 11;
    if (isTablet) return 12;
    if (isDesktop) return 13;
    return 14;
  }

  double get fontSizeMedium {
    if (isSmallMobile) return 12;
    if (isMobile) return 13;
    if (isTablet) return 14;
    if (isDesktop) return 15;
    return 16;
  }

  double get fontSizeLarge {
    if (isSmallMobile) return 14;
    if (isMobile) return 15;
    if (isTablet) return 16;
    if (isDesktop) return 17;
    return 18;
  }

  double get fontSizeXLarge {
    if (isSmallMobile) return 16;
    if (isMobile) return 17;
    if (isTablet) return 18;
    if (isDesktop) return 19;
    return 20;
  }

  double get imageHeight {
    if (isSmallMobile) return 160;
    if (isMobile) return 180;
    if (isTablet) return 200;
    if (isDesktop) return 220;
    return 240;
  }

  double get headerIconSize {
    if (isSmallMobile) return 16;
    if (isMobile) return 18;
    if (isTablet) return 20;
    if (isDesktop) return 22;
    return 24;
  }

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

  Widget _buildTabletLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRefreshableHeader(),
        _buildSectionTitle(),
        Expanded(
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: screenWidth * 0.85,
                minWidth: 600,
              ),
              child: _buildMainContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    final sidebarWidth = isLargeDesktop ? 450.0 : 400.0;

    return Row(
      children: [
        Container(
          width: sidebarWidth,
          child: Column(
            children: [
              _buildRefreshableHeader(),
              _buildSectionTitle(),
            ],
          ),
        ),

        // Main content area
        Expanded(
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isLargeDesktop ? 1200 : 900,
                minWidth: 600,
              ),
              child: _buildMainContent(),
            ),
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
            color: AppTheme.primaryColor.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wb_sunny,
                color: Colors.white,
                size: headerIconSize,
              ),
              SizedBox(width: 4),
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
                            fontSize: fontSizeSmall,
                            fontWeight: FontWeight.w600,
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

          Text(
            "Quote of the day",
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSizeMedium,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSizeSmall,
                  fontStyle: FontStyle.italic,
                  height: 1.3,
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
                    fontSize: fontSizeSmall - 1,
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
      margin: EdgeInsets.fromLTRB(
          horizontalPadding,
          verticalSpacing / 4,
          horizontalPadding,
          0
      ),
      child: Text(
        "Advertisements",
        style: TextStyle(
          fontSize: fontSizeXLarge,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimaryColor,
        ),
        textAlign: isDesktop ? TextAlign.center : TextAlign.left,
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
    final loadingHeight = isSmallMobile ? 300.0 : isMobile ? 350.0 : isTablet ? 450.0 : 500.0;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: loadingHeight,
        margin: EdgeInsets.all(horizontalPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: isDesktop ? 15 : 10,
              offset: Offset(0, isDesktop ? 4 : 3),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: isSmallMobile ? 40 : isMobile ? 45 : isTablet ? 55 : 65,
                height: isSmallMobile ? 40 : isMobile ? 45 : isTablet ? 55 : 65,
                child: CircularProgressIndicator(
                  strokeWidth: isDesktop ? 4 : 3,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: verticalSpacing * 2),
              Text(
                "Loading advertisements...",
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: fontSizeMedium,
                  fontWeight: FontWeight.w500,
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
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: isDesktop ? 15 : 10,
              offset: Offset(0, isDesktop ? 4 : 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isSmallMobile ? 48 : isMobile ? 55 : isTablet ? 65 : 75,
              color: Colors.red.shade400,
            ),
            SizedBox(height: verticalSpacing * 2),
            Text(
              errorMessage,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: fontSizeMedium,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: verticalSpacing * 2),
            ElevatedButton.icon(
              onPressed: _controller.retryFetch,
              icon: Icon(Icons.refresh, size: fontSizeMedium + 2),
              label: Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding * 1.5,
                  vertical: verticalSpacing + (isDesktop ? 4 : 2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(cardBorderRadius / 2),
                ),
                textStyle: TextStyle(
                  fontSize: fontSizeMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated _buildAdsPageView with infinite scroll logic similar to JobOpeningScreen
  Widget _buildAdsPageView(List<Ads> adItems) {
    return PageView.builder(
      controller: _pageController,
      itemCount: adItems.length * 1000, // Infinite scroll
      onPageChanged: (index) {
        final realIndex = index % adItems.length;
        setState(() {
          _currentAdIndex = realIndex;
        });
        _controller.updateCurrentIndex(realIndex);
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
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAdImage(ad),
          _buildAdHeader(ad),
          _buildAdDetails(ad),
          Divider(
            height: 1,
            color: Colors.grey.shade200,
            thickness: 0.5,
          ),
          _buildAdDescription(ad),
        ],
      ),
    );
  }

  Widget _buildAdImage(Ads ad) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(cardBorderRadius)),
      child: ad.imageUrl?.isNotEmpty == true
          ? Container(
        width: double.infinity,
        height: imageHeight,
        child: Image.network(
          ad.imageUrl!,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: imageHeight,
              alignment: Alignment.center,
              color: Colors.grey.shade50,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: isDesktop ? 4 : 3,
                color: AppTheme.primaryColor,
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
            AppTheme.primaryColor.withOpacity(0.25),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign,
              size: height * 0.25,
              color: AppTheme.primaryColor.withOpacity(0.7),
            ),
            SizedBox(height: verticalSpacing),
            Text(
              "Image not available",
              style: TextStyle(
                color: AppTheme.primaryColor.withOpacity(0.8),
                fontSize: fontSizeSmall,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdHeader(Ads ad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          verticalSpacing,
          horizontalPadding,
          verticalSpacing / 2
      ),
      child: Text(
        ad.subjectLine ?? "No Subject",
        style: TextStyle(
          fontSize: fontSizeLarge,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimaryColor,
          height: 1.2,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildAdDetails(Ads ad) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  "Date: ${ad.date ?? "Unknown"}",
                  style: TextStyle(
                    fontSize: fontSizeSmall,
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text(
                  "Amount:" "${ad.amount ?? '0.00'}",
                  style: TextStyle(
                    fontSize: fontSizeSmall,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),

          SizedBox(height: verticalSpacing / 2),

          Row(
            children: [
              Expanded(
                child: Text(
                  "Place: ${ad.place ?? "Unknown"}",
                  style: TextStyle(
                    fontSize: fontSizeSmall,
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
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
                  fontSize: fontSizeSmall,
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
              fontSize: fontSizeSmall - 1,
              height: 1.3,
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
            borderRadius: BorderRadius.circular(cardBorderRadius / 2),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallMobile ? 10 : isMobile ? 12 : isTablet ? 14 : 16,
                vertical: isSmallMobile ? 6 : isMobile ? 8 : isTablet ? 10 : 12,
              ),
              decoration: BoxDecoration(
                color: isSharing ? Colors.grey : AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(cardBorderRadius / 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: isDesktop ? 8 : 6,
                    offset: Offset(0, isDesktop ? 3 : 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSharing)
                    SizedBox(
                      width: fontSizeMedium,
                      height: fontSizeMedium,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    Icon(
                      Icons.share,
                      color: Colors.white,
                      size: fontSizeMedium,
                    ),
                  SizedBox(width: 6),
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
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
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
          Divider(height: 1, color: Colors.grey.shade200),
          _buildAppDownloadDescription(),
          _buildAppDownloadBenefits(),
          _buildAppDownloadFeatures(),
        ],
      ),
    );
  }

  Widget _buildAppDownloadFeatures() {
    return Container(
      margin: EdgeInsets.all(horizontalPadding),
      padding: EdgeInsets.all(verticalSpacing),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(cardBorderRadius / 2),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars,
                size: fontSizeSmall,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: 6),
              Text(
                "App Features",
                style: TextStyle(
                  fontSize: fontSizeSmall,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: verticalSpacing / 2),
          Row(
            children: [
              Expanded(
                child: _buildFeatureItem(Icons.access_time, "Time Tracking"),
              ),
              Expanded(
                child: _buildFeatureItem(Icons.notifications, "Push Alerts"),
              ),
            ],
          ),
          SizedBox(height: verticalSpacing / 2),
          Row(
            children: [
              Expanded(
                child: _buildFeatureItem(Icons.payment, "Payroll Info"),
              ),
              Expanded(
                child: _buildFeatureItem(Icons.schedule, "Shift Updates"),
              ),
            ],
          ),
          SizedBox(height: verticalSpacing),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding / 2,
              vertical: verticalSpacing / 2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(cardBorderRadius / 3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download,
                  size: fontSizeSmall,
                  color: Colors.white,
                ),
                SizedBox(width: 6),
                Text(
                  "Free Download • No Subscription Required",
                  style: TextStyle(
                    fontSize: fontSizeSmall - 1,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title) {
    return Row(
      children: [
        Icon(
          icon,
          size: fontSizeSmall - 1,
          color: AppTheme.primaryColor,
        ),
        SizedBox(width: 4),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSizeSmall - 1,
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadButton({
    required VoidCallback onTap,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final buttonHeight = isSmallMobile ? 50.0 : isMobile ? 55.0 : isTablet ? 60.0 : 65.0;
    final iconSize = isSmallMobile ? 20.0 : isMobile ? 22.0 : isTablet ? 24.0 : 28.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardBorderRadius / 2),
        child: Container(
          height: buttonHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(cardBorderRadius / 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: isDesktop ? 10 : 8,
                offset: Offset(0, isDesktop ? 4 : 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: iconSize),
              SizedBox(width: verticalSpacing + 2),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSizeMedium,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
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
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding + (isDesktop ? 8 : 4)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: isDesktop ? 2 : 3,
                child: ValueListenableBuilder<String>(
                  valueListenable: _controller.date,
                  builder: (context, date, _) {
                    return Text(
                      "Date: $date",
                      style: TextStyle(
                        fontSize: fontSizeSmall,
                        color: AppTheme.textPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
              SizedBox(width: isDesktop ? 12 : 8),
              Expanded(
                flex: isDesktop ? 2 : 2,
                child: Text(
                  "Amount: \$0.00",
                  style: TextStyle(
                    fontSize: fontSizeSmall,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: verticalSpacing),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding + (isDesktop ? 8 : 4)),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Place: App Store and Play Store",
                  style: TextStyle(
                    fontSize: fontSizeSmall,
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
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
      padding: EdgeInsets.all(horizontalPadding + (isDesktop ? 8 : 4)),
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
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallMobile ? 10 : 12,
                    vertical: isSmallMobile ? 6 : 8
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(cardBorderRadius / 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.share,
                      color: Colors.grey.shade600,
                      size: fontSizeMedium,
                    ),
                    SizedBox(width: 6),
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
              height: 1.5,
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
          padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding + (isDesktop ? 8 : 4),
              vertical: verticalSpacing + (isDesktop ? 8 : 4)
          ),
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
          padding: EdgeInsets.fromLTRB(
              horizontalPadding + (isDesktop ? 8 : 4),
              0,
              horizontalPadding + (isDesktop ? 8 : 4),
              horizontalPadding + (isDesktop ? 8 : 4)
          ),
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
                          margin: EdgeInsets.only(top: isDesktop ? 10 : 8),
                          width: isDesktop ? 10 : 8,
                          height: isDesktop ? 10 : 8,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(isDesktop ? 5 : 4),
                          ),
                        ),
                        SizedBox(width: isDesktop ? 16 : 12),
                        Expanded(
                          child: Text(
                            benefit,
                            style: TextStyle(
                              fontSize: fontSizeSmall,
                              color: AppTheme.textPrimaryColor,
                              height: 1.5,
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