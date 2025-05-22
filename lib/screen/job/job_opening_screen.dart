import 'package:flutter/material.dart';
import 'package:meetsu_solutions/model/job&ads/job/job_opening_response_model.dart';
import 'package:meetsu_solutions/screen/job/job_opening_controller.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

class JobOpeningScreen extends StatefulWidget {
  const JobOpeningScreen({super.key});

  @override
  State<JobOpeningScreen> createState() => _JobOpeningScreenState();
}

class _JobOpeningScreenState extends State<JobOpeningScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {

  late final JobOpeningController _controller;
  PageController? _pageController;
  static const int _virtualItemCount = 20000;
  static const int _initialPage = 10000;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = JobOpeningController();
    WidgetsBinding.instance.addObserver(this);
    _initializeListeners();
  }

  void _initializeListeners() {
    _controller.currentIndex.addListener(_handleIndexChange);
    _controller.jobOpenings.addListener(_handleJobItemsUpdate);
  }

  void _handleJobItemsUpdate() {
    if (!mounted) return;

    final jobOpenings = _controller.jobOpenings.value;
    if (jobOpenings.isNotEmpty && _pageController == null) {
      _initializePageController();
    }
  }

  void _initializePageController() {
    _pageController?.dispose();
    _pageController = PageController(initialPage: _initialPage);
  }

  void _handleIndexChange() {
    final pageController = _pageController;
    if (pageController == null ||
        !pageController.hasClients ||
        !mounted) return;

    final jobOpenings = _controller.jobOpenings.value;
    if (jobOpenings.isEmpty) return;

    final currentPage = pageController.page?.round() ?? 0;
    final jobItemsLength = jobOpenings.length;
    final currentIndex = currentPage % jobItemsLength;
    final targetIndex = _controller.currentIndex.value;

    if (currentIndex == jobItemsLength - 1 && targetIndex == 0) {
      final nextGroup = ((currentPage ~/ jobItemsLength) + 1) * jobItemsLength;
      _animateToPage(nextGroup);
      return;
    }

    final targetPage = (currentPage ~/ jobItemsLength) * jobItemsLength + targetIndex;
    _animateToPage(targetPage);
  }

  void _animateToPage(int page) {
    _pageController?.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
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
    _controller.currentIndex.removeListener(_handleIndexChange);
    _controller.jobOpenings.removeListener(_handleJobItemsUpdate);
    _pageController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Device type detection
  bool get isMobile => MediaQuery.of(context).size.width < 600;
  bool get isTablet => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;
  bool get isDesktop => MediaQuery.of(context).size.width >= 1200;

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
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.isLoading,
      builder: (context, isLoading, _) {
        if (isLoading) {
          return _buildLoadingState();
        }

        return ValueListenableBuilder<List<Jobs>>(
          valueListenable: _controller.jobOpenings,
          builder: (context, jobOpenings, _) {
            if (jobOpenings.isEmpty) {
              return _buildEmptyState();
            }

            // Different layouts for different devices
            if (isDesktop) {
              return _buildDesktopLayout(jobOpenings);
            } else if (isTablet) {
              return _buildTabletLayout(jobOpenings);
            } else {
              return _buildMobileLayout(jobOpenings);
            }
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: isMobile ? 40 : 60,
            height: isMobile ? 40 : 60,
            child: const CircularProgressIndicator(strokeWidth: 3),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Text(
            "Loading job openings...",
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 24 : 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: isMobile ? 64 : isTablet ? 80 : 100,
              color: AppTheme.textSecondaryColor,
            ),
            SizedBox(height: isMobile ? 16 : 24),
            Text(
              "No job openings available",
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: isMobile ? 16 : isTablet ? 18 : 20,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Text(
              "Check back later for new opportunities",
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: isMobile ? 12 : 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 24 : 32),
            ElevatedButton.icon(
              onPressed: _controller.retryFetch,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 32,
                  vertical: isMobile ? 12 : 16,
                ),
                textStyle: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mobile Layout - Full screen cards
  Widget _buildMobileLayout(List<Jobs> jobOpenings) {
    if (_pageController == null) _initializePageController();

    return PageView.builder(
      controller: _pageController,
      itemCount: _virtualItemCount,
      onPageChanged: (index) {
        final realIndex = index % jobOpenings.length;
        _controller.setCurrentIndex(realIndex);
      },
      itemBuilder: (context, index) {
        final realIndex = index % jobOpenings.length;
        return JobCard(
          key: ValueKey('job_${jobOpenings[realIndex].jobId}_$realIndex'),
          job: jobOpenings[realIndex],
          controller: _controller,
          deviceType: DeviceType.mobile,
        );
      },
    );
  }

  // Tablet Layout - Slightly larger cards with better spacing
  Widget _buildTabletLayout(List<Jobs> jobOpenings) {
    if (_pageController == null) _initializePageController();

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: PageView.builder(
          controller: _pageController,
          itemCount: _virtualItemCount,
          onPageChanged: (index) {
            final realIndex = index % jobOpenings.length;
            _controller.setCurrentIndex(realIndex);
          },
          itemBuilder: (context, index) {
            final realIndex = index % jobOpenings.length;
            return JobCard(
              key: ValueKey('job_${jobOpenings[realIndex].jobId}_$realIndex'),
              job: jobOpenings[realIndex],
              controller: _controller,
              deviceType: DeviceType.tablet,
            );
          },
        ),
      ),
    );
  }

  // Desktop Layout - Card in center with navigation
  Widget _buildDesktopLayout(List<Jobs> jobOpenings) {
    if (_pageController == null) _initializePageController();

    return Row(
      children: [
        // Left Navigation
        _buildNavigationButton(
          icon: Icons.chevron_left,
          onPressed: () => _navigateToJob(-1, jobOpenings.length),
        ),

        // Main Content
        Expanded(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _virtualItemCount,
                onPageChanged: (index) {
                  final realIndex = index % jobOpenings.length;
                  _controller.setCurrentIndex(realIndex);
                },
                itemBuilder: (context, index) {
                  final realIndex = index % jobOpenings.length;
                  return JobCard(
                    key: ValueKey('job_${jobOpenings[realIndex].jobId}_$realIndex'),
                    job: jobOpenings[realIndex],
                    controller: _controller,
                    deviceType: DeviceType.desktop,
                  );
                },
              ),
            ),
          ),
        ),

        // Right Navigation
        _buildNavigationButton(
          icon: Icons.chevron_right,
          onPressed: () => _navigateToJob(1, jobOpenings.length),
        ),
      ],
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 60,
      height: double.infinity,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToJob(int direction, int totalJobs) {
    final currentIndex = _controller.currentIndex.value;
    int newIndex;

    if (direction > 0) {
      newIndex = (currentIndex + 1) % totalJobs;
    } else {
      newIndex = (currentIndex - 1 + totalJobs) % totalJobs;
    }

    _controller.setCurrentIndex(newIndex);
  }
}

enum DeviceType { mobile, tablet, desktop }

// Enhanced JobCard with responsive design
class JobCard extends StatelessWidget {
  final Jobs job;
  final JobOpeningController controller;
  final DeviceType deviceType;

  const JobCard({
    super.key,
    required this.job,
    required this.controller,
    required this.deviceType,
  });

  // Responsive values based on device type
  double get cardMargin {
    switch (deviceType) {
      case DeviceType.mobile:
        return 16;
      case DeviceType.tablet:
        return 24;
      case DeviceType.desktop:
        return 32;
    }
  }

  double get cardPadding {
    switch (deviceType) {
      case DeviceType.mobile:
        return 16;
      case DeviceType.tablet:
        return 20;
      case DeviceType.desktop:
        return 24;
    }
  }

  double get imageHeight {
    switch (deviceType) {
      case DeviceType.mobile:
        return 180;
      case DeviceType.tablet:
        return 220;
      case DeviceType.desktop:
        return 260;
    }
  }

  double get titleFontSize {
    switch (deviceType) {
      case DeviceType.mobile:
        return 18;
      case DeviceType.tablet:
        return 22;
      case DeviceType.desktop:
        return 26;
    }
  }

  double get bodyFontSize {
    switch (deviceType) {
      case DeviceType.mobile:
        return 14;
      case DeviceType.tablet:
        return 15;
      case DeviceType.desktop:
        return 16;
    }
  }

  double get smallFontSize {
    switch (deviceType) {
      case DeviceType.mobile:
        return 12;
      case DeviceType.tablet:
        return 13;
      case DeviceType.desktop:
        return 14;
    }
  }

  @override
  Widget build(BuildContext context) {
    final requirements = controller.getRequirements(job);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: cardMargin, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJobImage(),
          _buildJobHeader(),
          _buildJobDetails(),
          const Divider(height: 1, thickness: 1),
          _buildDescription(),
          Expanded(
            child: _buildRequirements(requirements),
          ),
        ],
      ),
    );
  }

  Widget _buildJobImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: job.imageUrl?.isNotEmpty == true
          ? Container(
        width: double.infinity,
        height: imageHeight,
        child: Image.network(
          job.imageUrl!,
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
            AppTheme.primaryColor.withOpacity(0.2),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.work,
          size: imageHeight * 0.3,
          color: AppTheme.primaryColor.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildJobHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(cardPadding, cardPadding, cardPadding, 8),
      child: Text(
        job.jobPosition ?? "Unknown Position",
        style: TextStyle(
          fontSize: titleFontSize,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimaryColor,
          height: 1.2,
        ),
        maxLines: deviceType == DeviceType.mobile ? 2 : 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildJobDetails() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: cardPadding),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildDetailItem(Icons.date_range, "Date", job.positionDate ?? "Unknown")),
              Expanded(child: _buildDetailItem(Icons.location_on, "Location", job.location ?? "Unknown")),
            ],
          ),
          SizedBox(height: deviceType == DeviceType.mobile ? 8 : 12),
          Row(
            children: [
              Expanded(child: _buildDetailItem(Icons.people, "Positions", (job.noOfPositions ?? 1).toString())),
              Expanded(child: _buildDetailItem(Icons.attach_money, "Salary", job.salary ?? "N/A", isHighlighted: true)),
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
          size: smallFontSize + 2,
          color: isHighlighted ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: smallFontSize - 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                  color: isHighlighted ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
                  fontSize: smallFontSize,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
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
                  fontSize: bodyFontSize + 1,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              _buildShareButton(),
            ],
          ),
          SizedBox(height: deviceType == DeviceType.mobile ? 8 : 12),
          Text(
            job.positionDescription ?? "No description available",
            style: TextStyle(
              color: AppTheme.textPrimaryColor,
              fontSize: bodyFontSize,
              height: 1.4,
            ),
            maxLines: deviceType == DeviceType.mobile ? 3 : 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.isSharing,
      builder: (context, isSharing, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isSharing ? null : () => controller.shareJob(context, job),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: deviceType == DeviceType.mobile ? 12 : 16,
                vertical: deviceType == DeviceType.mobile ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: isSharing ? Colors.grey : AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSharing)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    Icon(
                      Icons.share,
                      color: Colors.white,
                      size: deviceType == DeviceType.mobile ? 16 : 18,
                    ),
                  const SizedBox(width: 6),
                  Text(
                    isSharing ? "Sharing..." : "Share",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: smallFontSize,
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

  Widget _buildRequirements(List<String> requirements) {
    return Padding(
      padding: EdgeInsets.fromLTRB(cardPadding, 0, cardPadding, cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Requirements:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: bodyFontSize + 1,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          SizedBox(height: deviceType == DeviceType.mobile ? 8 : 12),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: requirements.length,
              separatorBuilder: (context, index) => SizedBox(height: deviceType == DeviceType.mobile ? 6 : 8),
              itemBuilder: (context, index) {
                return Row(
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        requirements[index],
                        style: TextStyle(
                          color: AppTheme.textPrimaryColor,
                          fontSize: bodyFontSize,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}