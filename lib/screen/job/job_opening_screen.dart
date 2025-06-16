import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  int _currentJobIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = JobOpeningController();
    WidgetsBinding.instance.addObserver(this);
    _setupListeners();
  }

  void _setupListeners() {
    _controller.jobOpenings.addListener(_onJobItemsChanged);
  }

  void _onJobItemsChanged() {
    final jobs = _controller.jobOpenings.value;
    if (jobs.isNotEmpty && mounted) {
      if (_pageController == null) {
        final middleIndex = jobs.length * 500;
        _pageController = PageController(initialPage: middleIndex);
        _currentJobIndex = 0;
        _startAutoScroll();
      }
    }
  }

  void _startAutoScroll() {
    if (_controller.jobOpenings.value.isNotEmpty) {
      _controller.startAutoScrollWithPageController(_pageController!, (index) {
        if (mounted) {
          setState(() {
            _currentJobIndex = index;
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
    _controller.jobOpenings.removeListener(_onJobItemsChanged);
    _pageController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool get isMobile => MediaQuery.of(context).size.width < 600;
  bool get isTablet => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;
  bool get isDesktop => MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ConnectivityWidget(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
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

            return _buildJobPageView(jobOpenings);
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
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppTheme.primaryColor,
            ),
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

  Widget _buildJobPageView(List<Jobs> jobOpenings) {
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
      child: PageView.builder(
        controller: _pageController,
        itemCount: jobOpenings.length * 1000,
        onPageChanged: (index) {
          final realIndex = index % jobOpenings.length;
          setState(() {
            _currentJobIndex = realIndex;
          });
          _controller.updateCurrentIndex(realIndex);
        },
        itemBuilder: (context, index) {
          final realIndex = index % jobOpenings.length;
          return JobCard(
            job: jobOpenings[realIndex],
            controller: _controller,
            isMobile: isMobile,
            isTablet: isTablet,
            isDesktop: isDesktop,
            currentJobIndex: realIndex + 1,
            totalJobs: jobOpenings.length,
          );
        },
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final Jobs job;
  final JobOpeningController controller;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final int currentJobIndex;
  final int totalJobs;

  const JobCard({
    super.key,
    required this.job,
    required this.controller,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.currentJobIndex,
    required this.totalJobs,
  });

  double get cardMargin => isMobile ? 16 : isTablet ? 20 : 24;
  double get cardPadding => isMobile ? 16 : isTablet ? 20 : 24;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: cardMargin, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildJobImage(),
            _buildJobContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildJobImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: job.imageUrl?.isNotEmpty == true
          ? Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: isMobile ? 180 : isTablet ? 200 : 220,
          maxHeight: isMobile ? 280 : isTablet ? 320 : 360,
        ),
        child: Image.network(
          job.imageUrl!,
          fit: BoxFit.contain,
          width: double.infinity,
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
      height: isMobile ? 200 : isTablet ? 220 : 240,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 48,
              color: AppTheme.primaryColor.withOpacity(0.6),
            ),
            SizedBox(height: 8),
            Text(
              "Job Image",
              style: TextStyle(
                color: AppTheme.primaryColor.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobContent() {
    return Padding(
      padding: EdgeInsets.all(cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Job Title
          Text(
            job.jobPosition ?? "Unknown Position",
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 12),

          // Job Details Grid
          _buildJobDetailsGrid(),

          SizedBox(height: 16),

          // Description Section
          _buildDescriptionSection(),
        ],
      ),
    );
  }

  Widget _buildJobDetailsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // Date
            Expanded(
              child: _buildCompactDetailItem("Date:", job.positionDate ?? "Not specified"),
            ),
            SizedBox(width: 12),
            // Salary
            Expanded(
              child: _buildCompactDetailItem("Salary:", "${job.salary ?? 'N/A'}"),
            ),
          ],
        ),
        SizedBox(height: 12),
        // Location
        _buildCompactDetailItem("Location:", job.location ?? "Not specified"),
      ],
    );
  }

  Widget _buildCompactDetailItem(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: " $value",
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: label.contains("Salary") ? AppTheme.primaryColor : const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 18),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Description:",
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              _buildShareButton(),
            ],
          ),
          SizedBox(height: 12),
          Text(
            job.positionDescription ?? "No description available",
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: Colors.grey.shade800,
              height: 1.6,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.justify,
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
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 10 : 12,
                vertical: isMobile ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: isSharing ? Colors.grey.shade400 : AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: (isSharing ? Colors.grey : AppTheme.primaryColor).withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSharing)
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    Icon(
                      Icons.share_outlined,
                      color: Colors.white,
                      size: 12,
                    ),
                  SizedBox(width: 4),
                  Text(
                    isSharing ? "Sharing..." : "Share",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
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
}