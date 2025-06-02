import 'package:exam_gold_store_app/services/export_data_service.dart';
import 'package:exam_gold_store_app/services/web_scraper_service.dart';
import 'package:exam_gold_store_app/models/transaction.dart';
import 'package:exam_gold_store_app/helpers/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../utils/constants.dart';
import 'package:shamsi_date/shamsi_date.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, Map<String, dynamic>> inventorySummary = {};
  List<Transaction> inventoryItems = [];
  Map<String, double> dateRangeProfitLoss = {};
  bool isLoading = true;

  Jalali startDate = Jalali.now().addDays(-30);
  Jalali endDate = Jalali.now();
  String startDateGregorian = '';
  String endDateGregorian = '';

  @override
  void initState() {
    super.initState();
    _updateDateRange();
    _loadInitialData();
  }

  void _updateDateRange() {
    startDateGregorian = PersianDateHelper.jalaliToGregorian(startDate);
    endDateGregorian = PersianDateHelper.jalaliToGregorian(endDate);
  }

  Future<void> _loadInitialData() async {
    if (currentLivePrices.isEmpty) await _loadLivePrices();
    await _loadInventoryData();
  }

  Future<void> _loadLivePrices() async {
    final goldPrices = await WebScraperService.fetchGoldPrices();
    if (!currentLivePrices.isEmpty) {
      return;
    }
    updateLivePrices(goldPrices);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadInventoryData() async {
    setState(() => isLoading = true);

    try {
      final summary = await DatabaseHelper.getInventorySummary();
      final itemsData = await DatabaseHelper.getInventoryItems();
      final items = itemsData.map((item) => Transaction.fromMap(item)).toList();
      final dateRangeAnalysis =
          await DatabaseHelper.getProfitLossAnalysisByDateRange(
            startDateGregorian,
            endDateGregorian,
          );

      setState(() {
        inventorySummary = summary;
        inventoryItems = items;
        dateRangeProfitLoss = dateRangeAnalysis;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading inventory: $e');
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final selectedDate = isStart ? startDate : endDate;

    await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(isStart ? 'انتخاب تاریخ شروع' : 'انتخاب تاریخ پایان'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: _buildPersianDatePicker(selectedDate, (newDate) {
              setState(() {
                if (isStart) {
                  startDate = newDate;
                } else {
                  endDate = newDate;
                }
              });
            }),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('تایید'),
            ),
          ],
        ),
      ),
    );

    _updateDateRange();
    await _loadInventoryData();
  }

  Widget _buildPersianDatePicker(
    Jalali initialDate,
    Function(Jalali) onDateChanged,
  ) {
    Jalali selectedDate = initialDate;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    setState(() {
                      selectedDate = Jalali(
                        selectedDate.year - 1,
                        selectedDate.month,
                        selectedDate.day,
                      );
                      onDateChanged(selectedDate);
                    });
                  },
                ),
                Text(
                  '${selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    setState(() {
                      selectedDate = Jalali(
                        selectedDate.year + 1,
                        selectedDate.month,
                        selectedDate.day,
                      );
                      onDateChanged(selectedDate);
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final monthNames = [
                    'فروردین',
                    'اردیبهشت',
                    'خرداد',
                    'تیر',
                    'مرداد',
                    'شهریور',
                    'مهر',
                    'آبان',
                    'آذر',
                    'دی',
                    'بهمن',
                    'اسفند',
                  ];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        int day = selectedDate.day;
                        int maxDay = Jalali(
                          selectedDate.year,
                          index + 1,
                          1,
                        ).monthLength;
                        if (day > maxDay) day = maxDay;

                        selectedDate = Jalali(
                          selectedDate.year,
                          index + 1,
                          day,
                        );
                        onDateChanged(selectedDate);
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: selectedDate.month == index + 1
                            ? cPrimaryColor
                            : cCardBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          monthNames[index],
                          style: TextStyle(
                            color: selectedDate.month == index + 1
                                ? Colors.black
                                : cTextPrimary,
                            fontWeight: selectedDate.month == index + 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Text(
              'روز: ${selectedDate.day}',
              style: const TextStyle(fontSize: 16),
            ),
            Slider(
              value: selectedDate.day.toDouble(),
              min: 1,
              max: selectedDate.monthLength.toDouble(),
              divisions: selectedDate.monthLength - 1,
              onChanged: (value) {
                setState(() {
                  selectedDate = Jalali(
                    selectedDate.year,
                    selectedDate.month,
                    value.toInt(),
                  );
                  onDateChanged(selectedDate);
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cBackgroundColor,
      child: Column(
        children: [
          Container(
            color: cCardBackground,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
             Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'موجودی انبار',
                  style: TextStyle(
                    color: cTextPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child:       Positioned(
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : _showExportDialog,
                        icon: const Icon(
                          Icons.file_download,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'خروجی گزارش',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cPrimaryColor.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: cTextPrimary,
                          ),
                          onPressed: isLoading ? null : _loadLivePrices,
                        ),
                      ),
                    ],
                  ),
                ),
                ),
         
              ],
             ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDateButton(
                      'از تاریخ',
                      startDate,
                      () => _selectDate(true),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.arrow_forward, color: cTextSecondary),
                    const SizedBox(width: 16),
                    _buildDateButton(
                      'تا تاریخ',
                      endDate,
                      () => _selectDate(false),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: isLoading ? loadingIndicator : _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildDateButton(String label, Jalali date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: cCardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cBorderColor),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(color: cTextSecondary, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.formatter.yyyy}/${date.formatter.mm}/${date.formatter.dd}',
              style: const TextStyle(
                color: cTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (inventoryItems.isEmpty) {
      return Center(
        child: Text(
          'انبار خالی است',
          style: TextStyle(fontSize: 16, color: cTextSecondary),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeProfitLossCards(),
          const SizedBox(height: 20),
          if (inventorySummary.isNotEmpty) _buildInventorySummary(),
        ],
      ),
    );
  }

  Widget _buildDateRangeProfitLossCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'کل خرید',
                NumberFormat(
                  '#,###',
                ).format(dateRangeProfitLoss['totalPurchases'] ?? 0),
                'تومان',
                Icons.shopping_cart,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'کل فروش',
                NumberFormat(
                  '#,###',
                ).format(dateRangeProfitLoss['totalSales'] ?? 0),
                'تومان',
                Icons.sell,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'ارزش فعلی خریدها',
                NumberFormat(
                  '#,###',
                ).format(dateRangeProfitLoss['currentValueOfPurchases'] ?? 0),
                'تومان',
                Icons.trending_up,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'سود/زیان',
                NumberFormat(
                  '#,###',
                ).format(dateRangeProfitLoss['profitLoss'] ?? 0),
                'تومان (${(dateRangeProfitLoss['profitPercent'] ?? 0).toStringAsFixed(1)}%)',
                Icons.analytics,
                (dateRangeProfitLoss['profitLoss'] ?? 0) >= 0
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInventorySummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'خلاصه موجودی بر اساس نوع کالا',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...inventorySummary.entries.map(
          (entry) => _buildInventoryTypeCard(entry),
        ),
      ],
    );
  }

  Widget _buildInventoryTypeCard(MapEntry<String, Map<String, dynamic>> entry) {
    final itemType = entry.key;
    final data = entry.value;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مقدار کل: ${data['totalQuantity']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: cTextSecondary,
                        ),
                      ),
                      Text(
                        'متوسط قیمت: ${NumberFormat('#,###').format(data['avgUnitPrice'])}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: cTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'ارزش: ${NumberFormat('#,###').format(data['totalValue'])} تومان',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: cPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  itemType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cTextPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${data['itemCount']} آیتم',
                    style: const TextStyle(
                      fontSize: 12,
                      color: cPrimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSummaryCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: cTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(fontSize: 12, color: cTextSecondary),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('انتخاب نوع خروجی'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('فایل PDF'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  ExportDataService.exportToPDF(context, startDateGregorian, endDateGregorian, dateRangeProfitLoss);
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('فایل CSV'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  ExportDataService.exportToCSV(context, startDateGregorian, endDateGregorian, dateRangeProfitLoss);
                },
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('انصراف'),
            ),
          ],
        ),
      ),
    );
  }


}
