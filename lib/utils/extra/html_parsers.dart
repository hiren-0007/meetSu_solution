import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class HtmlParsers {
  /// Converts HTML string to plain text using the html package
  static String htmlToText(String? htmlString) {
    if (htmlString == null || htmlString.isEmpty) {
      return "No description available";
    }

    try {
      // Parse the HTML string into a Document
      Document document = parse(htmlString);

      // Extract text content from the body
      String text = document.body?.text ?? "";

      // Clean up whitespace
      text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

      return text;
    } catch (e) {
      // Fallback method in case parsing fails
      return _fallbackHtmlToText(htmlString);
    }
  }

  /// Fallback method that uses RegExp to strip HTML tags
  static String _fallbackHtmlToText(String htmlString) {
    // Remove HTML tags
    String plainText = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');

    // Decode common HTML entities
    plainText = plainText
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');

    // Clean up whitespace
    plainText = plainText.replaceAll(RegExp(r'\s+'), ' ').trim();

    return plainText;
  }
}