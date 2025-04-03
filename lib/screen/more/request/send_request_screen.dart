import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/more/request/send_request_controller.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

class SendRequestScreen extends StatefulWidget {
  const SendRequestScreen({super.key});

  @override
  State<SendRequestScreen> createState() => _SendRequestScreenState();
}

class _SendRequestScreenState extends State<SendRequestScreen> {
  late final SendRequestController _controller;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    final apiService = ApiService(apiClient);
    _controller = SendRequestController(apiService);
    _controller.initialize();
  }

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
              top: 0,
              left: 0,
              right: 0,
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
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: AppTheme.appIconDecoration,
                            child: const Icon(
                              Icons.arrow_back,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              "Send Request",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  SizedBox(height: AppTheme.smallSpacing),
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
                          // Form title
                          const Text(
                            "Request Details",
                            style: AppTheme.headerStyle,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Please fill in the details for your request",
                            style: AppTheme.smallTextStyle,
                          ),
                          SizedBox(height: AppTheme.contentSpacing),

                          // Form fields
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: _controller.reasonController,
                                    decoration: AppTheme.getInputDecoration(
                                      labelText: "Reason",
                                      prefixIcon: Icons.description,
                                    ),
                                    maxLines: 3,
                                  ),
                                  SizedBox(height: AppTheme.contentSpacing),
                                  InkWell(
                                    onTap: () =>
                                        _controller.selectDate(context),
                                    child: ValueListenableBuilder<DateTime>(
                                      valueListenable: _controller.selectedDate,
                                      builder: (context, date, _) {
                                        return InputDecorator(
                                          decoration:
                                              AppTheme.getInputDecoration(
                                            labelText: "Date",
                                            prefixIcon: Icons.calendar_today,
                                            suffixIcon: const Icon(
                                              Icons.arrow_drop_down,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                          child: Text(
                                            _controller.formatDate(date),
                                            style: AppTheme.inputTextStyle,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: AppTheme.contentSpacing),
                                  SizedBox(height: AppTheme.largeSpacing),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.smallBorderRadius),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.history,
                                              color: AppTheme.primaryColor,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              "Records",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    AppTheme.textPrimaryColor,
                                              ),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.refresh,
                                                color: AppTheme.primaryColor,
                                              ),
                                              onPressed:
                                                  _controller.refreshRecords,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        ValueListenableBuilder<
                                            List<RequestRecord>>(
                                          valueListenable: _controller.records,
                                          builder: (context, records, _) {
                                            if (records.isEmpty) {
                                              return const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child:
                                                      Text("No records found"),
                                                ),
                                              );
                                            }

                                            return SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: DataTable(
                                                columnSpacing: 20,
                                                headingRowColor:
                                                    MaterialStateProperty.all(
                                                  Colors.grey[200],
                                                ),
                                                columns: const [
                                                  DataColumn(
                                                      label: Text("Actions")),
                                                  DataColumn(
                                                      label: Text("Amount")),
                                                  DataColumn(
                                                      label: Text("Reason")),
                                                ],
                                                rows: records.map((record) {
                                                  return DataRow(
                                                    cells: [
                                                      DataCell(IconButton(
                                                        icon: const Icon(
                                                            Icons.download,
                                                            color: AppTheme
                                                                .primaryColor,
                                                            size: 20),
                                                        onPressed: () =>
                                                            _controller
                                                                .downloadRecord(
                                                                    record),
                                                      )),
                                                      DataCell(Text(record
                                                          .amount
                                                          .toString())),
                                                      DataCell(
                                                          Text(record.reason)),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: AppTheme.contentSpacing),

                          ValueListenableBuilder<bool>(
                            valueListenable: _controller.isLoading,
                            builder: (context, isLoading, child) {
                              return ElevatedButton(
                                style: AppTheme.primaryButtonStyle,
                                onPressed: isLoading
                                    ? null
                                    : () =>
                                        _controller.showRequestDialog(context),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "Add Request",
                                        style: AppTheme.buttonTextStyle,
                                      ),
                              );
                            },
                          ),

                          ValueListenableBuilder<String?>(
                            valueListenable: _controller.errorMessage,
                            builder: (context, error, _) {
                              if (error == null) return const SizedBox.shrink();

                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  error,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppTheme.contentSpacing),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
