import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
        final middleIndex = ads.length * 500;
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

  // Responsive breakpoints
  bool get isSmallMobile => MediaQuery.of(context).size.width < 400;
  bool get isMobile => MediaQuery.of(context).size.width < 600;
  bool get isTablet => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;
  bool get isDesktop => MediaQuery.of(context).size.width >= 1200;

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  double get horizontalPadding {
    if (isSmallMobile) return 16;
    if (isMobile) return 16;
    if (isTablet) return 20;
    return 24;
  }

  double get cardPadding {
    if (isSmallMobile) return 16;
    if (isMobile) return 16;
    return 20;
  }

  double get verticalSpacing {
    if (isSmallMobile) return 12;
    if (isMobile) return 12;
    return 16;
  }

  double get cardBorderRadius => 12;

  double get fontSizeSmall {
    if (isSmallMobile) return 12;
    if (isMobile) return 12;
    return 13;
  }

  double get fontSizeMedium {
    if (isSmallMobile) return 14;
    if (isMobile) return 14;
    return 15;
  }

  double get fontSizeLarge {
    if (isSmallMobile) return 16;
    if (isMobile) return 16;
    return 18;
  }

  double get imageHeight {
    if (isSmallMobile) return 200;
    if (isMobile) return 220;
    return 240;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ConnectivityWidget(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildCompactHeader(),
              Expanded(child: _buildMainContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      margin: EdgeInsets.fromLTRB(horizontalPadding, horizontalPadding, horizontalPadding, 8),
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
      child: RefreshIndicator(
        onRefresh: _controller.refreshDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              children: [
                // Weather and Date Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wb_sunny, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
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

                // Quote Section
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

                SizedBox(height: verticalSpacing),

                // Section Title
                Text(
                  "Advertisements",
                  style: TextStyle(
                    fontSize: fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: verticalSpacing),
        padding: EdgeInsets.all(cardPadding * 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: verticalSpacing),
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
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: verticalSpacing),
        padding: EdgeInsets.all(cardPadding * 1.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            SizedBox(height: verticalSpacing),
            Text(
              errorMessage,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: fontSizeMedium,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: verticalSpacing * 1.5),
            ElevatedButton.icon(
              onPressed: _controller.retryFetch,
              icon: Icon(Icons.refresh, size: fontSizeMedium + 2),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: cardPadding,
                  vertical: verticalSpacing,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(cardBorderRadius / 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdsPageView(List<Ads> adItems) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification) {
          _controller.pauseAutoScroll();
        } else if (notification is ScrollEndNotification ||
            notification is UserScrollNotification && notification.direction == ScrollDirection.idle) {
          _controller.resumeAutoScroll();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: _controller.refreshDashboardData,
        child: PageView.builder(
          controller: _pageController,
          itemCount: adItems.length * 1000,
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
        ),
      ),
    );
  }

  Widget _buildAdCard(Ads ad) {
    return Container(
      margin: EdgeInsets.only(bottom: verticalSpacing),
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
        children: [
          _buildAdImage(ad),
          _buildAdContent(ad),
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
        color: Colors.grey.shade50,
        child: Image.network(
          ad.imageUrl!,
          fit: BoxFit.contain,
          width: double.infinity,
          height: imageHeight,
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
                strokeWidth: 3,
                color: AppTheme.primaryColor,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
        ),
      )
          : _buildFallbackImage(),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      height: imageHeight,
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
              size: imageHeight * 0.25,
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

  Widget _buildAdContent(Ads ad) {
    return Padding(
      padding: EdgeInsets.all(cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
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

          SizedBox(height: verticalSpacing),

          // Details Row
          Row(
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
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text(
                  "Salary: ${ad.amount ?? '0.00'}",
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

          // Location
          Text(
            "Location: ${ad.place ?? "Unknown"}",
            style: TextStyle(
              fontSize: fontSizeSmall,
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: verticalSpacing),

          // Divider
          Divider(
            height: 1,
            color: Colors.grey.shade200,
            thickness: 0.5,
          ),

          SizedBox(height: verticalSpacing),

          // Description Section
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
                horizontal: isSmallMobile ? 10 : 12,
                vertical: isSmallMobile ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: isSharing ? Colors.grey : AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(cardBorderRadius / 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
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
                  const SizedBox(width: 6),
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
      child: Container(
        margin: EdgeInsets.only(bottom: verticalSpacing),
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
              padding: EdgeInsets.all(cardPadding),
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
              padding: EdgeInsets.all(cardPadding),
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
      ),
    );
  }

  Widget _buildDownloadButton({
    required VoidCallback onTap,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final buttonHeight = isSmallMobile ? 50.0 : 55.0;

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
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              SizedBox(width: verticalSpacing),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: cardPadding),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
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
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
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

          SizedBox(height: verticalSpacing),

          Row(
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
        ],
      ),
    );
  }

  Widget _buildAppDownloadDescription() {
    return Padding(
      padding: EdgeInsets.all(cardPadding),
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
                    const SizedBox(width: 6),
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
            horizontal: cardPadding,
            vertical: verticalSpacing,
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
            cardPadding,
            0,
            cardPadding,
            cardPadding,
          ),
          child: ValueListenableBuilder<List<String>>(
            valueListenable: _controller.benefits,
            builder: (context, benefits, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: benefits.asMap().entries.map((entry) {
                  final benefit = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: verticalSpacing),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(width: 12),
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

  Widget _buildAppDownloadFeatures() {
    return Container(
      margin: EdgeInsets.all(cardPadding),
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
              const SizedBox(width: 6),
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
              horizontal: cardPadding / 2,
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
                const SizedBox(width: 6),
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
        const SizedBox(width: 4),
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
}