import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meetsu_solutions/model/job&ads/ads/ads_response_model.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/clint/c_screen/c_dashboard/clint_dashboard_controller.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {

  late final ClientDashboardController _controller;
  PageController? _pageController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = ClientDashboardController();
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
        _startAutoScroll();
      }
    }
  }

  void _startAutoScroll() {
    if (_controller.adItems.value.isNotEmpty) {
      _controller.startAutoScrollWithPageController(_pageController!, (index) {
        if (mounted) {
          setState(() {
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
  bool get isSmallMobile =>
      MediaQuery
          .of(context)
          .size
          .width < 400;

  bool get isMobile =>
      MediaQuery
          .of(context)
          .size
          .width < 600;

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
        body: Stack(
          children: [
            // Blue gradient header - same as Send Job Request
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.15,
                decoration: AppTheme.headerClintContainerDecoration,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo
                        Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        // Title
                        const Text(
                          'MEETsu Solutions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        // Username
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            SharedPrefsService.instance.getUsername(),
                            style: TextStyle(
                              color: AppTheme.primaryClintColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Positioned(
              top: MediaQuery.of(context).size.height * 0.16,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: RefreshIndicator(
                  onRefresh: _controller.fetchDashboardData,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _controller.isLoading,
                    builder: (context, isLoading, child) {
                      if (isLoading) {
                        return _buildLoadingState();
                      }

                      return ValueListenableBuilder<String?>(
                        valueListenable: _controller.errorMessage,
                        builder: (context, errorMessage, child) {
                          if (errorMessage != null) {
                            return _buildErrorState(errorMessage);
                          }

                          return ValueListenableBuilder<bool>(
                            valueListenable: _controller.hasData,
                            builder: (context, hasData, child) {
                              if (!hasData) {
                                return _buildNoDataView();
                              }

                              return _buildDashboardWithContent();
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _controller.fetchDashboardData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryClintColor,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_customize_outlined,
            size: 80,
            color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 20),
          const Text(
            "Data Not Found",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              "No dashboard data is available at the moment. Please check back later.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _controller.fetchDashboardData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryClintColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardWithContent() {
    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        children: [
          _buildCompactHeader(),
          const SizedBox(height: 16),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryClintGradient, // Using same gradient as Send Job Request
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryClintColor.withValues(alpha: 0.3),
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

            SizedBox(height: largeSpacing),

            // Advertisements Title
            const Text(
              "Client Advertisements",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return ValueListenableBuilder<List<Ads>>(
      valueListenable: _controller.adItems,
      builder: (context, adItems, _) {
        if (adItems.isEmpty) {
          return _buildAppDownloadSection();
        }
        return _buildAdsPageView(adItems);
      },
    );
  }

  Widget _buildAdsPageView(List<Ads> adItems) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification) {
          _controller.pauseAutoScroll();
        } else if (notification is ScrollEndNotification ||
            notification is UserScrollNotification &&
                notification.direction == ScrollDirection.idle) {
          _controller.resumeAutoScroll();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: _controller.fetchDashboardData,
        child: PageView.builder(
          controller: _pageController,
          itemCount: adItems.length * 1000,
          onPageChanged: (index) {
            final realIndex = index % adItems.length;
            setState(() {
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
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: ad.imageUrl?.isNotEmpty == true
          ? SizedBox(
        width: double.infinity,
        height: 200,
        child: Image.network(
          ad.imageUrl!,
          fit: BoxFit.contain,
          width: double.infinity,
          height: 200,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              alignment: Alignment.center,
              color: Colors.grey.shade50,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: AppTheme.primaryClintColor,
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
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryClintColor.withValues(alpha: 0.1),
            AppTheme.primaryClintColor.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign,
              size: 40,
              color: AppTheme.primaryClintColor.withValues(alpha: 0.7),
            ),
            SizedBox(height: mediumSpacing),
            Text(
              "Image not available",
              style: TextStyle(
                color: AppTheme.primaryClintColor.withValues(alpha: 0.7),
                fontSize: 14,
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: mediumSpacing),

          // Date and Salary
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
                "Salary: ${ad.amount ?? '0.00'}",
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.primaryClintColor,
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

          // Description Text
          Text(
            ad.description ?? "No description available",
            style: const TextStyle(
              fontSize: 13,
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
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSharing ? Colors.grey : AppTheme.primaryClintColor,
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
                gradient: AppTheme.primaryClintGradient,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12)),
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
                          color: AppTheme.primaryClintColor,
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryClintColor,
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
                    "Also, share with your team members to do the same • Client Benefits:",
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