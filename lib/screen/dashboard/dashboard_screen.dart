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

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController _controller = DashboardController();
  late PageController _pageController;
  int _realPage = 1000; // Start at a large number to simulate infinite scroll

  String formatDate(String isoDate) {
    DateTime dateTime = DateTime.parse(isoDate);
    return DateFormat("MMM dd, yyyy").format(dateTime);
  }

  @override
  void initState() {
    super.initState();

    // Initialize with a large number to simulate infinite scroll
    _pageController = PageController(initialPage: _realPage);

    // Listen to job openings updates
    _controller.adItems.addListener(_onAdItemsChanged);

    // Listen to current index changes for auto-scroll
    _controller.currentIndex.addListener(_onCurrentIndexChanged);
  }

  void _onAdItemsChanged() {
    // When ad items are loaded, ensure the PageController is initialized correctly
    if (_controller.adItems.value.isNotEmpty && mounted) {
      if (_pageController.hasClients) {
        // If controller already has clients, just update the real page to stay consistent
        setState(() {
          _realPage = _pageController.page!.round();
        });
      } else {
        // Initialize the controller if it hasn't been initialized yet
        _pageController = PageController(initialPage: _realPage);
      }
    }
  }

  void _onCurrentIndexChanged() {
    // This handles the auto-scroll from the controller
    if (_pageController.hasClients && _controller.adItems.value.isNotEmpty && mounted) {
      // Get the current and target indexes
      final adsLength = _controller.adItems.value.length;
      final targetIndex = _controller.currentIndex.value;
      final currentIndex = _realPage % adsLength;

      // Special case: when going from last item to first item (e.g., from 5 to 0)
      if (currentIndex == adsLength - 1 && targetIndex == 0) {
        // Instead of going backward, we go forward to the next group of items
        final nextGroup = (_realPage ~/ adsLength + 1) * adsLength;
        _pageController.animateToPage(
          nextGroup,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _realPage = nextGroup;
        debugPrint("🔄 Moving forward to next cycle: $_realPage");
        return;
      }

      // Normal case: just go to the target index in the current group
      final baseGroup = (_realPage ~/ adsLength) * adsLength;
      final targetPage = baseGroup + targetIndex;

      if (_pageController.page!.round() != targetPage) {
        _pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _realPage = targetPage;
        debugPrint("🔄 Scrolling to page: $_realPage (index: $targetIndex)");
      }
    }
  }

  @override
  void dispose() {
    _controller.currentIndex.removeListener(_onCurrentIndexChanged);
    _controller.adItems.removeListener(_onAdItemsChanged);
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidget(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: RefreshIndicator(
          onRefresh: _controller.refreshDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  _buildAdvertisementSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [AppTheme.primaryShadow],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wb_sunny,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 2),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Quote of the day",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
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
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          ValueListenableBuilder<String>(
            valueListenable: _controller.quoteAuthor,
            builder: (context, author, _) {
              return Text(
                "- $author",
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvertisementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(20, 4, 16, 0.1),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Advertisements",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _controller.isLoading,
          builder: (context, isLoading, _) {
            if (isLoading) {
              return _buildLoadingIndicator();
            }

            return ValueListenableBuilder<List<Ads>>(
              valueListenable: _controller.adItems,
              builder: (context, adItems, _) {
                if (adItems.isEmpty) {
                  return _buildAppDownloadCard();
                }

                return _buildAdsPageView(adItems);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildAdsPageView(List<Ads> adItems) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 400,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: PageView.builder(
        controller: _pageController,
        itemCount: null, // Infinite pages
        onPageChanged: (index) {
          _realPage = index;
          // Calculate the actual index in our dataset
          final realIndex = index % adItems.length;

          // Only update controller if index actually changed
          if (_controller.currentIndex.value != realIndex) {
            _controller.setCurrentIndex(realIndex);
          }
        },
        itemBuilder: (context, index) {
          // Get the real item to show based on the infinite index
          final realIndex = index % adItems.length;
          return _buildAdCard(adItems[realIndex]);
        },
      ),
    );
  }

  Widget _buildAdCard(Ads ad) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAdImage(ad),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                ad.subjectLine!,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ),
            _buildDateAndPlace(ad),
            _buildStatusAndAmount(ad),
            const Divider(),
            _buildDescription(ad),
            _buildBenefits(),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildAdImage(Ads ad) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ad.imageUrl!.isNotEmpty
            ? Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 200,
            maxHeight: 300,
          ),
          child: Image.network(
            ad.imageUrl!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(Icons.campaign,
                    size: 50, color: Colors.grey),
              );
            },
          ),
        )
            : Container(
          height: 200,
          width: double.infinity,
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const Icon(Icons.campaign, size: 50, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildDateAndPlace(Ads ad) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                "Date: ",
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
              Text(
                ad.date!,
                style: const TextStyle(
                  color: AppTheme.textPrimaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Flexible(
            child: Row(
              children: [
                const Text(
                  "  Place: ",
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
                Flexible(
                  child: Text(
                    ad.place!,
                    style: const TextStyle(
                      color: AppTheme.textPrimaryColor,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusAndAmount(Ads ad) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                "Status: ",
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
              Text(
                ad.status!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                "Amount: ",
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
              Text(
                "\$${ad.amount}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Ads ad) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              // Share button
              GestureDetector(
                onTap: () => _controller.shareAd(context, ad),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 3),
                      Text(
                        "Share",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            ad.description!,
            style: const TextStyle(
              color: AppTheme.textPrimaryColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Benefits:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 2),
          ValueListenableBuilder<List<String>>(
            valueListenable: _controller.benefits,
            builder: (context, benefits, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: benefits.asMap().entries.map((entry) {
                  final index = entry.key;
                  final benefit = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${index + 1}. ",
                            style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(
                            benefit,
                            style: const TextStyle(
                              color: AppTheme.textPrimaryColor,
                              fontSize: 12,
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
        ],
      ),
    );
  }

  Widget _buildAppDownloadCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPlayStoreButton(),
                const SizedBox(height: 12),
                _buildAppStoreButton(),
              ],
            ),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Download MEETsu Solution App",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
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

  Widget _buildPlayStoreButton() {
    return GestureDetector(
      onTap: () => _controller.downloadFromPlayStore(context),
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Google_Play_Store_badge_EN.svg/1024px-Google_Play_Store_badge_EN.svg.png',
              height: 30,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.android, color: Colors.white);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppStoreButton() {
    return GestureDetector(
      onTap: () => _controller.downloadFromAppStore(context),
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Download_on_the_App_Store_Badge.svg/1200px-Download_on_the_App_Store_Badge.svg.png',
              height: 30,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.apple, color: Colors.white);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDownloadInfo() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Place: App Store and Play Store",
                style: TextStyle(fontSize: 12),
              ),
              ValueListenableBuilder<String>(
                valueListenable: _controller.date,
                builder: (context, date, _) {
                  return Text(
                    "Date: $date",
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text(
                    "Status: ",
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    "ON",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Text(
                "Amount: \$0.00",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppDownloadDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
              // Share button
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 3),
                      Text(
                        "Share",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            "Also, share with your co-worker to do the same",
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAppDownloadBenefits() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Center(
            child: Text(
              "-: Benefits: -",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ValueListenableBuilder<List<String>>(
            valueListenable: _controller.benefits,
            builder: (context, benefits, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: benefits.asMap().entries.map((entry) {
                  final index = entry.key;
                  final benefit = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${index + 1}. "),
                        Expanded(
                          child: Text(benefit),
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