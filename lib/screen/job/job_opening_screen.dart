import 'package:flutter/material.dart';
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
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _controller.currentIndex.addListener(_handleIndexChange);
  }

  void _handleIndexChange() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        _controller.currentIndex.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.currentIndex.removeListener(_handleIndexChange);
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
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Job Openings",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Explore available positions",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: _controller.isLoading,
                builder: (context, isLoading, _) {
                  if (isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return ValueListenableBuilder<List<JobOpening>>(
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
                          return Column(
                            children: [
                              Expanded(
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: jobOpenings.length,
                                  onPageChanged: (index) {
                                    _controller.setCurrentIndex(index);
                                  },
                                  itemBuilder: (context, index) {
                                    return _buildJobCard(jobOpenings[index]);
                                  },
                                ),
                              ),
                            ],
                          );
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

  Widget _buildJobCard(JobOpening job) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
              child: job.imageUrl.isNotEmpty
                  ? Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        minHeight: 150,
                        maxHeight: 250,
                      ),
                      child: Image.network(
                        job.imageUrl,
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
              job.title,
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
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      job.date,
                      style: const TextStyle(
                        color: AppTheme.textPrimaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Row(
                    children: [
                      const Text(
                        "Location: ",
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          job.location,
                          style: const TextStyle(
                            color: AppTheme.textPrimaryColor,
                            fontSize: 14,
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      "No. of Positions: ",
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      job.positions.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                        fontSize: 14,
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
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      job.salary,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
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
                        fontSize: 16,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    // Share button
                    GestureDetector(
                      onTap: () => _controller.shareJob(context, job),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
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
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Share",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  job.description,
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
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
                      itemCount: job.requirements.length,
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
                                  job.requirements[index],
                                  style: const TextStyle(
                                    color: AppTheme.textSecondaryColor,
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
