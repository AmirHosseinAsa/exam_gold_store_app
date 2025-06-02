import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shamsi_date/shamsi_date.dart';

final win = appWindow;
const String VERSION = 'نسخه ۱.۰.۰';
const String DEVELOPER_EMAIL = 'Amirhossein.asa.pro@gmail.com';
const String goldPriceWebUrl = 'https://alanchand.com/en/gold-price';


const Color cPrimaryColor = Color(0xFFFFD100);
const Color cAccentColor = Color(0xFFFFEE32);
const Color cBackgroundColor = Color(0xFF202020);
const Color cSurfaceColor = Color(0xFF333533);
const Color cTextPrimary = Color.fromARGB(255, 255, 255, 255);
const Color cTextSecondary = Color(0xFFB0B0B0);

const Color cSidebarStart = Color(0xFF2A2A2A);
const Color cSidebarEnd = Color(0xFF333533);

const Color cCardBackground = Color(0xFF2C2C2C);
const Color cBorderColor = Color(0xFF404040);

var loadingIndicator = LoadingAnimationWidget.inkDrop(
  color: cPrimaryColor,
  size: 50,
);

class PersianDateHelper {
  static String jalaliToGregorian(Jalali jalali) {
    final gregorian = jalali.toDateTime();
    return '${gregorian.year}-${gregorian.month.toString().padLeft(2, '0')}-${gregorian.day.toString().padLeft(2, '0')}';
  }

  static String gregorianToPersian(String gregorianDate) {
    try {
      final parts = gregorianDate.split('-');
      final gregorian = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final jalali = Jalali.fromDateTime(gregorian);
      final f = jalali.formatter;
      return '${f.yyyy}/${f.mm}/${f.dd}';
    } catch (e) {
      return gregorianDate;
    }
  }

  static String getCurrentGregorianDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String getCurrentPersianDate() {
    final now = Jalali.now();
    final f = now.formatter;
    return '${f.yyyy}/${f.mm}/${f.dd}';
  }

  static Jalali createJalaliFromDayMonth(int day, int month) {
    final currentYear = Jalali.now().year;
    return Jalali(currentYear, month, day);
  }
}

const List<String> kProductTypes = [
  'طلای 18 عیار',
  'سکه امامی',
  'نیم آزادی',
  'سکه جرمی',
];

const Map<String, String> kProductToPriceKey = {
  'طلای 18 عیار': 'gold18Ayar',
  'سکه امامی': 'emamiCoin',
  'نیم آزادی': 'halfAzadi',
  'سکه جرمی': 'gerami',
};

Map<String, double> currentLivePrices = {};

double getLivePriceForProduct(String productType) {
  final priceKey = kProductToPriceKey[productType];
  if (priceKey != null && currentLivePrices.containsKey(priceKey)) {
    return currentLivePrices[priceKey]!;
  }
  return 0.0;
}

void updateLivePrices(Map<String, dynamic> prices) {
  currentLivePrices.clear();
  prices.forEach((key, priceData) {
    if (priceData != null && priceData.currentPrice != null) {
      String priceStr = priceData.currentPrice
          .toString()
          .replaceAll('تومان', '')
          .replaceAll(',', '')
          .trim();
      try {
        double price = double.parse(priceStr);
        currentLivePrices[key] = price;
      } catch (e) {
        currentLivePrices[key] = 0.0;
      }
    }
  });
}
