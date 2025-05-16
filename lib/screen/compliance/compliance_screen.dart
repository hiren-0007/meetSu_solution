import 'package:flutter/material.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/screen/compliance/compliance_controller.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

class ComplianceScreen extends StatefulWidget {
  const ComplianceScreen({super.key});

  @override
  State<ComplianceScreen> createState() => ComplianceScreenState();
}

class ComplianceScreenState extends State<ComplianceScreen> {
  final ComplianceController _controller = ComplianceController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidget(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Stack(
          children: [
            Positioned(
              top: 8,
              left: 7,
              right: 7,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: AppTheme.headerContainerDecoration,
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(AppTheme.screenPadding),
                    child: Center(
                      child: const Text(
                        "Compliance Reports",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: AppTheme.appIconDecoration,
                      child: const Icon(
                        Icons.policy_outlined,
                        color: AppTheme.primaryColor,
                        size: 40,
                      ),
                    ),
                  ),
                  SizedBox(height: AppTheme.largeSpacing),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(
                        horizontal: AppTheme.screenPadding,
                      ),
                      padding: EdgeInsets.all(AppTheme.cardPadding),
                      decoration: AppTheme.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          const Text(
                            "Available Reports",
                            style: AppTheme.headerStyle,
                          ),
                          SizedBox(height: AppTheme.miniSpacing),
                          Text(
                            "View compliance documents",
                            style: AppTheme.subHeaderStyle,
                          ),

                          SizedBox(height: AppTheme.mediumSpacing),

                          ValueListenableBuilder<String?>(
                            valueListenable: _controller.errorMessage,
                            builder: (context, errorMessage, _) {
                              return errorMessage != null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          errorMessage,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () =>
                                              _controller.retryFetch(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppTheme.primaryColor,
                                          ),
                                          child: const Text(
                                            "Retry",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    )
                                  : const SizedBox.shrink();
                            },
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
                                  return ValueListenableBuilder<
                                      List<ComplianceReport>>(
                                    valueListenable: _controller.reports,
                                    builder: (context, reports, _) {
                                      if (reports.isEmpty) {
                                        return const Center(
                                          child: Text(
                                            "No compliance reports available",
                                            style: TextStyle(
                                              color:
                                                  AppTheme.textSecondaryColor,
                                              fontSize: 16,
                                            ),
                                          ),
                                        );
                                      }

                                      return ListView.separated(
                                        itemCount: reports.length,
                                        separatorBuilder: (context, index) =>
                                            const Divider(),
                                        itemBuilder: (context, index) {
                                          final report = reports[index];
                                          return ListTile(
                                            title: Text(
                                              report.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            leading: const Icon(
                                              Icons.description_outlined,
                                              color: AppTheme.primaryColor,
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(
                                                Icons.remove_red_eye_outlined,
                                                color: AppTheme.primaryColor,
                                              ),
                                              onPressed: () =>
                                                  _controller.showPdf(
                                                report,
                                                context,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppTheme.largeSpacing),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
