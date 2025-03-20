import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/test/test_screen.dart';
import 'package:meetsu_solutions/utils/extra/pdf_viewer_screen_assigned_screen.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreenAssignedScreen extends StatefulWidget {
  final String pdfUrl;
  final Map<String, dynamic>? trainingData;

  const PdfViewerScreenAssignedScreen({
    super.key,
    required this.pdfUrl,
    this.trainingData
  });

  @override
  State<PdfViewerScreenAssignedScreen> createState() => _PdfViewerScreenAssignedScreenState();
}

class _PdfViewerScreenAssignedScreenState extends State<PdfViewerScreenAssignedScreen> {
  late PdfViewerController _pdfViewerController;
  bool _isLastPage = false;
  bool _isCheckboxChecked = false;
  int _totalPages = 0;
  int _currentPage = 0;
  bool _showConfirmation = false;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowTestOption =
        widget.trainingData != null &&
            widget.trainingData!['give_test'] == 1;

    return Scaffold(
      appBar: AppBar(title: const Text("PDF Viewer")),
      body: Stack(
        children: [
          SfPdfViewer.network(
            widget.pdfUrl,
            controller: _pdfViewerController,
            onPageChanged: (PdfPageChangedDetails details) {
              setState(() {
                _currentPage = details.newPageNumber;
                // Check if this is the last page by comparing with the total pages
                // that we got from onDocumentLoaded
                _isLastPage = _currentPage == _totalPages;

                // Only show the confirmation when we're on the last page
                // and give_test is 1
                _showConfirmation = _isLastPage && shouldShowTestOption;
              });
              debugPrint('Page changed: Current page $_currentPage, Total pages $_totalPages, Is last page: $_isLastPage');
            },
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              setState(() {
                _totalPages = details.document.pages.count;
                debugPrint('PDF loaded with $_totalPages pages');
              });
            },
          ),
          if (_showConfirmation)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _isCheckboxChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              _isCheckboxChecked = value ?? false;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'I have read and understand the training',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isCheckboxChecked
                          ? () {
                        // Navigate to the test screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestScreen(
                              trainingData: widget.trainingData!,
                            ),
                          ),
                        );
                      }
                          : null, // Disable if not checked
                      child: const Text('Okay'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }
}
