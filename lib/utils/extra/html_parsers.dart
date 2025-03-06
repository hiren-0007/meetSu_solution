import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class HtmlParsers {
  static String htmlToText(String? htmlString) {
    if (htmlString == null || htmlString.isEmpty) {
      return "No description available";
    }

    try {
      Document document = parse(htmlString);

      String text = document.body?.text ?? "";

      text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

      return text;
    } catch (e) {
      return _fallbackHtmlToText(htmlString);
    }
  }

  static String _fallbackHtmlToText(String htmlString) {
    String plainText = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');

    plainText = plainText
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');

    plainText = plainText.replaceAll(RegExp(r'\s+'), ' ').trim();

    return plainText;
  }
}