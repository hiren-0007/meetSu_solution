import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/screen/more/more_controller.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> with TickerProviderStateMixin {
  late final MoreController _controller;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = MoreController();
    _initializeAnimations();
    _controller.fetchCheckInButtonStatus();
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

  // Get responsive dimensions based on screen size
  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;
  bool get isSmallScreen => screenHeight < 700;
  bool get isLargeScreen => screenHeight > 900;

  // Responsive values
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

  double get menuItemHeight {
    if (isSmallScreen) return 56;
    if (isLargeScreen) return 72;
    return 64;
  }

  double get menuFontSize {
    if (isSmallScreen) return 14;
    if (isLargeScreen) return 18;
    return 16;
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
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    _buildHeaderIcon(),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    _buildLoadingIndicator(),
                    _buildErrorMessage(),
                    Expanded(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildMenuCard(),
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
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              blurRadius: isSmallScreen ? 12 : 16,
              offset: Offset(0, isSmallScreen ? 4 : 6),
            ),
          ],
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
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: isSmallScreen ? 8 : 12,
              spreadRadius: isSmallScreen ? 1 : 2,
              offset: Offset(0, isSmallScreen ? 3 : 4),
            ),
          ],
        ),
        // child: Icon(
        //   Icons.menu,
        //   color: AppTheme.primaryColor,
        //   size: iconSize,
        // ),
        child: Image.asset(
          'assets/images/logo.png',
          height: iconSize,
          width: iconSize,
        ),

      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.isLoading,
      builder: (context, isLoading, child) {
        if (!isLoading) return const SizedBox.shrink();

        return Center(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12),
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 8 : 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: isSmallScreen ? 16 : 20,
                  height: isSmallScreen ? 16 : 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Text(
                  "Loading...",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage() {
    return ValueListenableBuilder<String?>(
      valueListenable: _controller.errorMessage,
      builder: (context, errorMsg, child) {
        if (errorMsg == null ||
            errorMsg.isEmpty ||
            errorMsg.contains('Unauthorized')) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isSmallScreen ? 6 : 8,
          ),
          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade600,
                size: isSmallScreen ? 16 : 18,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: Text(
                  errorMsg,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: isSmallScreen ? 11 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _controller.errorMessage.value = null,
                child: Icon(
                  Icons.close,
                  color: Colors.red.shade600,
                  size: isSmallScreen ? 14 : 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuCard() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      decoration: AppTheme.cardDecoration.copyWith(
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: isSmallScreen ? 12 : 16,
            spreadRadius: isSmallScreen ? 2 : 3,
            offset: Offset(0, isSmallScreen ? 4 : 6),
          ),
        ],
      ),
      child: _buildMenuList(),
    );
  }

  Widget _buildMenuHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.08),
            AppTheme.primaryColor.withValues(alpha: 0.04),
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
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
            ),
            child: Icon(
              Icons.settings,
              color: AppTheme.primaryColor,
              size: isSmallScreen ? 18 : 20,
            ),
          ),
          SizedBox(width: isSmallScreen ? 10 : 14),
          Text(
            "Menu Options",
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList() {
    return ValueListenableBuilder<List<MenuItem>>(
      valueListenable: _controller.menuItemsNotifier,
      builder: (context, menuItems, child) {
        if (menuItems.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          itemCount: menuItems.length,
          separatorBuilder: (context, index) => SizedBox(height: isSmallScreen ? 8 : 10),
          itemBuilder: (context, index) {
            final menuItem = menuItems[index];
            return _buildMenuItem(menuItem, index);
          },
        );
      },
    );
  }

  Widget _buildMenuItem(MenuItem menuItem, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 80)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 15),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        height: menuItemHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
              _controller.navigateTo(context, menuItem.route);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 8 : 12,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                    decoration: BoxDecoration(
                      color: menuItem.iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                    ),
                    child: Icon(
                      menuItem.icon,
                      color: menuItem.iconColor,
                      size: isSmallScreen ? 18 : 22,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Expanded(
                    child: Text(
                      menuItem.title,
                      style: TextStyle(
                        fontSize: menuFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: isSmallScreen ? 14 : 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
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
                Icons.menu_open,
                size: isSmallScreen ? 32 : 40,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              "No Menu Items",
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              "Please try refreshing the page",
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}