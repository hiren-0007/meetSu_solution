import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meetsu_solutions/model/job&ads/ads/ads_response_model.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/screen/dashboard/dashboard_controller.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

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
    debugPrint('_currentAdIndex : $_currentAdIndex');
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

  // Responsive values - optimized for clean layout
  bool get isSmallMobile => MediaQuery.of(context).size.width < 400;
  bool get isMobile => MediaQuery.of(context).size.width < 600;

  double get horizontalPadding => 16;
  double get cardPadding => 16;
  double get smallSpacing => 4;
  double get mediumSpacing => 8;
  double get largeSpacing => 12;

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
      margin: EdgeInsets.all(horizontalPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          children: [
            // Weather and Date
            ValueListenableBuilder<String>(
              valueListenable: _controller.temperature,
              builder: (context, temperature, _) {
                return ValueListenableBuilder<String>(
                  valueListenable: _controller.date,
                  builder: (context, date, _) {
                    return Text(
                      "$temperature • $date",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                );
              },
            ),

            SizedBox(height: largeSpacing),

            // Quote Section
            const Text(
              "Quote of the day",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: mediumSpacing),

            ValueListenableBuilder<String>(
              valueListenable: _controller.quote,
              builder: (context, quote, _) {
                return Text(
                  '"$quote"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    height: 1.3,
                  ),
                );
              },
            ),

            SizedBox(height: mediumSpacing),

            ValueListenableBuilder<String>(
              valueListenable: _controller.quoteAuthor,
              builder: (context, author, _) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "- $author",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ],
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
        padding: EdgeInsets.all(cardPadding * 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: largeSpacing),
            const Text(
              "Loading advertisements...",
              style: TextStyle(
                fontSize: 14,
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
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.red.shade400,
            ),
            SizedBox(height: largeSpacing),
            Text(
              errorMessage,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: largeSpacing),
            ElevatedButton.icon(
              onPressed: _controller.retryFetch,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: cardPadding,
                  vertical: mediumSpacing,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
      margin: EdgeInsets.only(bottom: mediumSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
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
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: ad.imageUrl?.isNotEmpty == true
            ? Image.network(
          ad.imageUrl!,
          fit: BoxFit.contain, // cover के बजाय contain use करें
          width: double.infinity,
          height: 200,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              alignment: Alignment.center,
              color: Colors.grey.shade50,
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Loading image...",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
        )
            : _buildFallbackImage(),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.primaryColor.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 32,
                color: AppTheme.primaryColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Image not available",
              style: TextStyle(
                color: AppTheme.primaryColor.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Advertisement content below",
              style: TextStyle(
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
                fontSize: 12,
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: mediumSpacing),

          // Date and Amount
          Row(
            children: [
              Expanded(
                child: Text(
                  "Date: ${ad.date ?? "Unknown"}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "Amount: ${ad.amount ?? '0.00'}",
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: smallSpacing),

          // Location
          Text(
            "Location: ${ad.place ?? "Unknown"}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: mediumSpacing),

          // Description Header with Share Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Description:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              _buildShareButton(ad),
            ],
          ),

          SizedBox(height: smallSpacing),

          // Improved Description Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Html(
                  data: ad.description ?? "<p>No description available</p>",
                  style: {
                    "body": Style(
                      fontSize: FontSize(13),
                      lineHeight: const LineHeight(1.4),
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                    ),
                    "p": Style(
                      fontSize: FontSize(13),
                      lineHeight: const LineHeight(1.4),
                      margin: Margins.only(bottom: 8),
                      textAlign: TextAlign.center,
                    ),
                    "strong": Style(fontWeight: FontWeight.bold),
                    "span": Style(fontSize: FontSize(13)),
                    "br": Style(fontSize: FontSize(13)),
                    "ol": Style(
                      margin: Margins.only(left: 20, bottom: 12, top: 8),
                      fontSize: FontSize(13),
                      listStyleType: ListStyleType.decimal,
                      listStylePosition: ListStylePosition.outside,
                    ),
                    "ul": Style(
                      margin: Margins.only(left: 20, bottom: 12, top: 8),
                      fontSize: FontSize(13),
                      listStyleType: ListStyleType.disc,
                    ),
                    "li": Style(
                      fontSize: FontSize(13),
                      lineHeight: const LineHeight(1.5),
                      margin: Margins.only(bottom: 8),
                      padding: HtmlPaddings.only(left: 4),
                      display: Display.listItem,
                    ),
                    "a": Style(
                      color: Colors.blue,
                      textDecoration: TextDecoration.underline,
                      fontSize: FontSize(13),
                      fontWeight: FontWeight.w500,
                    ),
                    "img": Style(
                      width: Width(constraints.maxWidth - 24),
                      height: Height.auto(),
                      margin: Margins.symmetric(vertical: 8),
                      alignment: Alignment.center,
                    ),
                    "table": Style(
                      width: Width(constraints.maxWidth - 24),
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                      margin: Margins.symmetric(vertical: 12),
                      backgroundColor: Colors.grey.shade50,
                    ),
                    "td": Style(
                      padding: HtmlPaddings.all(8),
                      border: Border.all(color: Colors.grey.shade300),
                      fontSize: FontSize(13),
                      textAlign: TextAlign.center,
                    ),
                    "th": Style(
                      padding: HtmlPaddings.all(8),
                      border: Border.all(color: Colors.grey.shade300),
                      fontSize: FontSize(13),
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    "caption": Style(
                      fontSize: FontSize(14),
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                      margin: Margins.only(bottom: 8),
                    ),
                  },
                  onLinkTap: (url, attributes, element) {
                    _launchURL(url);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String? url) async {
    if (url == null || url.isEmpty) return;

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error opening URL: $e");
    }
  }

  Widget _buildShareButton(Ads ad) {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.isSharing,
      builder: (context, isSharing, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isSharing ? null : () => _controller.shareAd(context, ad),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSharing ? Colors.grey : AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSharing)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 14,
                    ),
                  const SizedBox(width: 4),
                  Text(
                    isSharing ? "Sharing..." : "Share",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(cardPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.8)],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Text(
                "Download MEETsu Solution App",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Download Buttons
            Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                children: [
                  _buildDownloadButton(
                    onTap: () => _controller.downloadFromPlayStore(context),
                    label: "Get it on Google Play",
                    icon: Icons.android,
                    color: Colors.green,
                  ),
                  SizedBox(height: largeSpacing),
                  _buildDownloadButton(
                    onTap: () => _controller.downloadFromAppStore(context),
                    label: "Download on the App Store",
                    icon: Icons.apple,
                    color: Colors.black,
                  ),
                ],
              ),
            ),

            // App Info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: cardPadding),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<String>(
                          valueListenable: _controller.date,
                          builder: (context, date, _) {
                            return Text(
                              "Date: $date",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ),
                      Text(
                        "Amount: \$0.00",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: smallSpacing),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Status: ON",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: largeSpacing),

            // Description
            Padding(
              padding: EdgeInsets.symmetric(horizontal: cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Description:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.share, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              "Share",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: smallSpacing),
                  const Text(
                    "Also, share with your co-worker to do the same • Benefits:",
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),

            SizedBox(height: largeSpacing),

            // Benefits List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: cardPadding),
              child: ValueListenableBuilder<List<String>>(
                valueListenable: _controller.benefits,
                builder: (context, benefits, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: benefits.map((benefit) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: smallSpacing),
                        child: Text(
                          "• $benefit",
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            SizedBox(height: cardPadding),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              SizedBox(width: mediumSpacing),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}