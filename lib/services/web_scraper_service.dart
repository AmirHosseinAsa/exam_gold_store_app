import 'package:exam_gold_store_app/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import '../models/price_data.dart';

class WebScraperService {
  static const Map<String, String> headers = {
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
  };

  static Future<Map<String, PriceData>> fetchGoldPrices() async {
    Map<String, PriceData> goldPrices = {};

    try {
      final response = await http.get(
        Uri.parse(goldPriceWebUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final document = html.parse(response.body);
        final goldItems = document.querySelectorAll('.body.cpt');

        for (var item in goldItems) {
          final titleElement = item.querySelector('.title .persian strong');
          if (titleElement != null) {
            final title = titleElement.text.trim();
            final cells = item.querySelectorAll('.cell');

            if (cells.length >= 3) {
              String currentPrice = cells[0].text.trim();
              String changeAmount = cells[2].text.trim();

              currentPrice = currentPrice.replaceAll(',', '');
              currentPrice = currentPrice.substring(0, currentPrice.length - 1);

              final smallElement = cells[2].querySelector('small');
              String changePercentage = '';
              bool isIncreasing = false;
              bool isDecreasing = false;

              if (smallElement != null) {
                changePercentage = smallElement.text.trim();
                String color = smallElement.attributes['style'] ?? '';
                isDecreasing =
                    color.contains('#ff5722') ||
                    changePercentage.startsWith('%-');
                isIncreasing =
                    color.contains('#4caf50') ||
                    (!isDecreasing && changePercentage.startsWith('%'));
              }

              String key = _getKeyByTitle(title);

              if (key.isNotEmpty) {
                goldPrices[key] = PriceData(
                  currentPrice: '$currentPrice',
                  changeAmount: changeAmount,
                  changePercentage: changePercentage,
                  isIncreasing: isIncreasing,
                  isDecreasing: isDecreasing,
                );
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching gold prices: $e');
    }

    return goldPrices;
  }

  static String _getKeyByTitle(String title) {
    switch (title.toLowerCase()) {
      case '18 ayar':
        return 'gold18Ayar';
      case 'emami':
        return 'emamiCoin';
      case '½ azadi':
        return 'halfAzadi';
      case 'gerami':
        return 'gerami';
      default:
        return '';
    }
  }
}
