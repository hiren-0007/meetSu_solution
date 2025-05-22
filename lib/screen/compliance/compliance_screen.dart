import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/screen/compliance/compliance_controller.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

class ComplianceScreen extends StatefulWidget {
  const ComplianceScreen({super.key});

  @override
  State<ComplianceScreen> createState() => ComplianceScreenState();
}

class ComplianceScreenState extends State<ComplianceScreen>
    with TickerProviderStateMixin {
  late final ComplianceController _controller;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = ComplianceController();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Responsive dimensions
  double get screenHeight => MediaQuery.of(context).size.height;
  bool get isSmallScreen => screenHeight < 700;
  bool get isLargeScreen => screenHeight > 900;

  double get headerHeight {
    if (isSmallScreen) return screenHeight * 0.28;
    if (isLargeScreen) return screenHeight * 0.32;
    return screenHeight * 0.30;
  }

  double get titleFontSize {
    if (isSmallScreen) return 18;
    if (isLargeScreen) return 24;
    return 20;
  }

  double get iconSize {
    if (isSmallScreen) return 30;
    if (isLargeScreen) return 40;
    return 36;
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidget(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildHeaderIcon(),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    Expanded(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildContentCard(),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned(
      top: 8,
      left: 7,
      right: 7,
      child: Container(
        height: headerHeight,
        decoration: AppTheme.headerContainerDecoration.copyWith(
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.2),
              blurRadius: isSmallScreen ? 12 : 16,
              offset: Offset(0, isSmallScreen ? 4 : 6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: const Center(
        child: Text(
          "Compliance Reports",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: AppTheme.appIconDecoration.copyWith(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: isSmallScreen ? 8 : 12,
              spreadRadius: isSmallScreen ? 1 : 2,
              offset: Offset(0, isSmallScreen ? 3 : 4),
            ),
          ],
        ),
        child: Icon(
          Icons.policy_outlined,
          color: AppTheme.primaryColor,
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildContentCard() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      decoration: AppTheme.cardDecoration.copyWith(
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: isSmallScreen ? 12 : 16,
            spreadRadius: isSmallScreen ? 2 : 3,
            offset: Offset(0, isSmallScreen ? 4 : 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildContentHeader(),
          Expanded(child: _buildReportsList()),
        ],
      ),
    );
  }

  Widget _buildContentHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.08),
            AppTheme.primaryColor.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isSmallScreen ? 16 : 20),
          topRight: Radius.circular(isSmallScreen ? 16 : 20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
            ),
            child: Icon(
              Icons.description,
              color: AppTheme.primaryColor,
              size: isSmallScreen ? 18 : 20,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Available Reports",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "View compliance documents",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          _buildRefreshButton(),
        ],
      ),
    );
  }

  Widget _buildRefreshButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.isLoading,
      builder: (context, isLoading, _) {
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: isLoading
              ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryColor,
            ),
          )
              : InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              _controller.retryFetch();
            },
            child: Icon(
              Icons.refresh,
              color: AppTheme.primaryColor,
              size: 16,
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportsList() {
    return ValueListenableBuilder<bool>(
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

            return ValueListenableBuilder<List<ComplianceReport>>(
              valueListenable: _controller.reports,
              builder: (context, reports, _) {
                if (reports.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildReportsListView(reports);
              },
            );
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
            width: isSmallScreen ? 32 : 40,
            height: isSmallScreen ? 32 : 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            "Loading compliance reports...",
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: isSmallScreen ? 32 : 40,
                color: Colors.red.shade400,
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              "Something went wrong",
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                color: Colors.red.shade600,
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _controller.retryFetch();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : 24,
                  vertical: isSmallScreen ? 10 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(Icons.refresh, size: isSmallScreen ? 16 : 18),
              label: Text(
                "Retry",
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_outlined,
                size: isSmallScreen ? 32 : 40,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              "No Reports Available",
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              "No compliance reports found",
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsListView(List<ComplianceReport> reports) {
    return ListView.separated(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      itemCount: reports.length,
      separatorBuilder: (context, index) => SizedBox(height: isSmallScreen ? 8 : 10),
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildReportItem(report, index);
      },
    );
  }

  Widget _buildReportItem(ComplianceReport report, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: isSmallScreen ? 4 : 6,
              offset: Offset(0, isSmallScreen ? 1 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            onTap: () {
              HapticFeedback.lightImpact();
              _controller.showPdf(report, context);
            },
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: AppTheme.primaryColor,
                      size: isSmallScreen ? 18 : 22,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.name,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Tap to view document",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.remove_red_eye_outlined,
                      color: Colors.green.shade600,
                      size: isSmallScreen ? 16 : 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}