import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewHandler {
  final Function getAccessToken;

  PdfViewHandler({
    required this.getAccessToken,
  });

  // Method 1: View PDF using Syncfusion PDF viewer
  Future<void> viewPdfWithSyncfusion(BuildContext context, String url) async {
    debugPrint('Syncfusion PDF viewer call');
    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Document Viewer'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () async {
                    await Share.share(url, subject: 'Training Document');
                  },
                ),
              ],
            ),
            body: SfPdfViewer.network(
              url,
              canShowPaginationDialog: true,
              enableDoubleTapZooming: true,
              // Add headers if API requires authentication
              headers: <String, String>{
                'Authorization': 'Bearer ${getAccessToken()}',
              },
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                debugPrint('PDF load failed: ${details.error}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to load PDF: ${details.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error viewing PDF document: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Method 2: Download and show PDF locally
  Future<void> downloadAndShowPDF(BuildContext context, String url) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Downloading document..."),
              ],
            ),
          );
        },
      );

      // Get directory for storing downloaded file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = url.split('/').last;
      final filePath = '${directory.path}/$fileName';

      // Check if file already exists
      final file = File(filePath);
      if (await file.exists()) {
        // File already downloaded, close dialog and open
        if (context.mounted) Navigator.pop(context);
        _openDownloadedPDF(context, filePath);
        return;
      }

      // Download file
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);

        // Close dialog and open file
        if (context.mounted) Navigator.pop(context);
        _openDownloadedPDF(context, filePath);
      } else {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to download document: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper method to open downloaded PDF
  void _openDownloadedPDF(BuildContext context, String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Document Viewer'),
          ),
          body: SfPdfViewer.file(
            File(filePath),
            canShowPaginationDialog: true,
            enableDoubleTapZooming: true,
          ),
        ),
      ),
    );
  }

  // Method 3: View PDF using cached_pdfview package
  Future<void> viewPdfWithCachedViewer(BuildContext context, String url) async {
    debugPrint('Cached PDF viewer call');
    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Document Viewer'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () async {
                    await Share.share(url, subject: 'Training Document');
                  },
                ),
              ],
            ),
            body: const PDF(
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: true,
              pageFling: true,
            ).cachedFromUrl(
              url,
              placeholder: (progress) => Center(
                child: CircularProgressIndicator(
                  value: progress / 100,
                ),
              ),
              errorWidget: (error) => Center(
                child: Text('Error loading PDF: $error'),
              ),
              headers: {
                'Authorization': 'Bearer ${getAccessToken()}',
              },
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error viewing PDF document: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}