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

class _JobOpeningScreenState extends State<JobOpeningScreen> {
  final JobOpeningController _controller = JobOpeningController();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: _controller.jobOpenings.value.isNotEmpty ? 10000 : 0,
    );

    _controller.currentIndex.addListener(_handleIndexChange);
    _controller.jobOpenings.addListener(_handleJobItemsUpdate);
  }

  void _handleJobItemsUpdate() {
    if (mounted && _controller.jobOpenings.value.isNotEmpty) {
      _pageController = PageController(initialPage: 10000);
    }
  }

  void _handleIndexChange() {
    if (_pageController.hasClients &&
        _controller.jobOpenings.value.isNotEmpty &&
        mounted) {
      final currentPage = _pageController.page?.round() ?? 0;
      final jobItemsLength = _controller.jobOpenings.value.length;

      final currentIndex = currentPage % jobItemsLength;
      final targetIndex = _controller.currentIndex.value;

      if (currentIndex == jobItemsLength - 1 && targetIndex == 0) {
        final nextGroup = ((currentPage ~/ jobItemsLength) + 1) * jobItemsLength;
        _pageController.animateToPage(
          nextGroup,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        return;
      }

      final targetPage = (currentPage ~/ jobItemsLength) * jobItemsLength +
          _controller.currentIndex.value;

      _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.currentIndex.removeListener(_handleIndexChange);
    _controller.jobOpenings.removeListener(_handleJobItemsUpdate);
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidget(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: _controller.isLoading,
                builder: (context, isLoading, _) {
                  if (isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return ValueListenableBuilder<List<Jobs>>(
                      valueListenable: _controller.jobOpenings,
                      builder: (context, jobOpenings, _) {
                        if (jobOpenings.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "No job openings available",
                                  style: TextStyle(
                                    color: AppTheme.textSecondaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _controller.retryFetch(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                  ),
                                  child: const Text(
                                    "Retry",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return _buildJobPageView(jobOpenings);
                        }
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobPageView(List<Jobs> jobOpenings) {
    debugPrint("📊 Total job openings: ${jobOpenings.length}");
    return PageView.builder(
      controller: _pageController,
      itemCount: 20000,
      onPageChanged: (index) {
        final realIndex = index % jobOpenings.length;
        _controller.setCurrentIndex(realIndex);
      },
      itemBuilder: (context, index) {
        final realIndex = index % jobOpenings.length;
        return _buildJobCard(jobOpenings[realIndex]);
      },
    );
  }

  Widget _buildJobCard(Jobs job) {
    List<String> requirements = _controller.getRequirements(job);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: job.imageUrl != null && job.imageUrl!.isNotEmpty
                  ? Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  minHeight: 150,
                  maxHeight: 250,
                ),
                child: Image.network(
                  job.imageUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildFallbackImage();
                  },
                ),
              )
                  : _buildFallbackImage(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              job.jobPosition ?? "Unknown Position",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ),
          Padding(
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
                      job.positionDate ?? "Unknown",
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
                        "  Location: ",
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          job.location ?? "Unknown",
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
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      "No. of Positions: ",
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      (job.noOfPositions ?? 1).toString(),
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
                      "Salary: ",
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      job.salary ?? "N/A",
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
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
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
                        fontSize: 16,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _controller.isSharing,
                      builder: (context, isSharing, _) {
                        return GestureDetector(
                          onTap: isSharing ? null : () => _controller.shareJob(context, job),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSharing ? Colors.grey : AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSharing)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.share,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                const SizedBox(width: 4),
                                Text(
                                  isSharing ? "Sharing..." : "Share",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  job.positionDescription ?? "No description available",
                  style: const TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Requirements:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: requirements.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("• ",
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(
                                  requirements[index],
                                  style: const TextStyle(
                                    color: AppTheme.textPrimaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.work,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }
}