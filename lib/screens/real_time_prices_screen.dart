import 'package:exam_gold_store_app/widgets/widget_custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../services/web_scraper_service.dart';
import '../models/price_data.dart';
import 'package:url_launcher/url_launcher.dart';

class RealTimePricesScreen extends StatefulWidget {
  const RealTimePricesScreen({super.key});

  @override
  State<RealTimePricesScreen> createState() => _RealTimePricesScreenState();
}

class _RealTimePricesScreenState extends State<RealTimePricesScreen> {
  bool isLoading = true;
  Map<String, PriceData> prices = {};
  String errorMessage = "";
  String lastUpdated = "";

  @override
  void initState() {
    super.initState();
    fetchPrices();
  }

  Future<void> fetchPrices() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final goldPrices = await WebScraperService.fetchGoldPrices();

      updateLivePrices(goldPrices);

      setState(() {
        prices = goldPrices;
        isLoading = false;
        lastUpdated = DateTime.now().toString().substring(0, 16);
      });
    } catch (e) {
      setState(() {
        errorMessage = "خطا در دریافت قیمت‌ها: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cBackgroundColor,
      child: Column(
        children: [
          WidgetCustomAppbar(
            isLoading: isLoading,
            doWhenPressed: fetchPrices,
            appBarTitle: 'قیمت‌های لحظه‌ای',
            showIcon: !isLoading,
          ),
          Expanded(
            child: isLoading
                ? Center(child: loadingIndicator)
                : _liveGoldPriceContent(),
          ),
        ],
      ),
    );
  }

  Widget _liveGoldPriceContent() {
    if (prices.isEmpty)
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 70),
            Text(
              "!خطا در دریافت اطلاعات",
              style: TextStyle(fontSize: 16, color: cTextSecondary),
            ),
          ],
        ),
      );

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _goldLivePriceCardWidget(
                  '🥇 طلای 18 عیار',
                  prices['gold18Ayar'] ?? PriceData(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _goldLivePriceCardWidget(
                  '🪙 سکه امامی',
                  prices['emamiCoin'] ?? PriceData(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _goldLivePriceCardWidget(
                  '🪙 نیم آزادی',
                  prices['halfAzadi'] ?? PriceData(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _goldLivePriceCardWidget(
                  '🪙 سکه جرمی',
                  prices['gerami'] ?? PriceData(),
                ),
              ),
            ],
          ),

          const Spacer(),
          Column(
            children: [
              if (errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 12),

              if (lastUpdated.isNotEmpty)
                Text(
                  'آخرین بروزرسانی: $lastUpdated',
                  style: const TextStyle(color: cTextSecondary, fontSize: 11),
                ),
              const SizedBox(height: 5),
              InkWell(
                onTap: () {
                  launchUrl(Uri.parse(goldPriceWebUrl));
                },
                child: Text(
                  ' ${goldPriceWebUrl.replaceAll('https://', '')} : منبع',
                  style: const TextStyle(
                    color: Color.fromARGB(201, 221, 196, 9),
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _goldLivePriceCardWidget(String title, PriceData priceData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (priceData.isIncreasing)
            const Icon(Icons.trending_up, color: Colors.green, size: 20),
          if (priceData.isDecreasing)
            const Icon(Icons.trending_down, color: Colors.red, size: 20),
          if (priceData.changePercentage.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              priceData.changePercentage,
              style: TextStyle(
                color: priceData.isDecreasing
                    ? Colors.red
                    : priceData.isIncreasing
                    ? Colors.green
                    : cTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: cPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              priceData.currentPrice.isNotEmpty
                  ? '${NumberFormat('#,###').format(double.parse(priceData.currentPrice))} تومان'
                  : 'در حال دریافت...',
              style: const TextStyle(
                color: cTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
