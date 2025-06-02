import 'dart:io';
import 'dart:ui' as ui;

import 'package:csv/csv.dart';
import 'package:exam_gold_store_app/helpers/database_helper.dart';
import 'package:exam_gold_store_app/utils/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportDataService {
  static Future<void> exportToCSV(
    BuildContext context,
    String startDateGregorian,
    String endDateGregorian,
    Map<String, dynamic> dateRangeProfitLoss,
  ) async {
    try {
      final detailedItems = await DatabaseHelper.getTransactionsByDateRange(
        startDateGregorian,
        endDateGregorian,
      );

      List<List<dynamic>> rows = [];

      rows.add([
        'تاریخ',
        'نوع تراکنش',
        'نوع کالا',
        'مقدار',
        'قیمت واحد',
        'قیمت کل',
        'نام مشتری',
        'توضیحات',
      ]);

      for (var item in detailedItems) {
        rows.add([
          PersianDateHelper.gregorianToPersian(item['date']),
          item['type'] == 'buy' ? 'خرید' : 'فروش',
          item['itemType'],
          item['quantity'],
          item['unitPrice'],
          item['totalPrice'],
          item['customerName'],
          item['description'] ?? '',
        ]);
      }

      rows.add([]);
      rows.add(['خلاصه گزارش']);
      rows.add(['کل خرید', dateRangeProfitLoss['totalPurchases'] ?? 0]);
      rows.add(['کل فروش', dateRangeProfitLoss['totalSales'] ?? 0]);
      rows.add([
        'ارزش فعلی خریدها',
        dateRangeProfitLoss['currentValueOfPurchases'] ?? 0,
      ]);
      rows.add(['سود/زیان', dateRangeProfitLoss['profitLoss'] ?? 0]);
      rows.add([
        'درصد سود/زیان',
        '${(dateRangeProfitLoss['profitPercent'] ?? 0).toStringAsFixed(1)}%',
      ]);

      String csv = const ListToCsvConverter().convert(rows);

      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        final file = File(
          '$selectedDirectory/profit_loss_report_${DateTime.now().millisecondsSinceEpoch}.csv',
        );
        await file.writeAsString(csv);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فایل CSV با موفقیت ذخیره شد: ${file.path}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطا در تولید CSV: $e')));
    }
  }

  static Future<void> exportToPDF(
    BuildContext context,
    String startDate,
    String endDate,
    Map<String, dynamic> dateRangeProfitLoss,
  ) async {
    try {
      final fontData = await rootBundle.load(
        'assets/fonts/Vazirmatn-Regular.ttf',
      );
      final fontBoldData = await rootBundle.load(
        'assets/fonts/Vazirmatn-Bold.ttf',
      );
      final ttf = pw.Font.ttf(fontData);
      final ttfBold = pw.Font.ttf(fontBoldData);

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: ttf, bold: ttfBold),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'گزارش سود/زیان',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      font: ttfBold,
                    ),
                    textDirection: pw.TextDirection.rtl,
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              pw.Text(
                'از تاریخ: ${PersianDateHelper.gregorianToPersian(startDate)} تا تاریخ: ${PersianDateHelper.gregorianToPersian(endDate)}',
                style: pw.TextStyle(fontSize: 12, font: ttf),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                'تاریخ گزارش: ${PersianDateHelper.getCurrentPersianDate()}',
                style: pw.TextStyle(fontSize: 12, font: ttf),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.SizedBox(height: 20),

              pw.Text(
                'خلاصه سود/زیان',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  font: ttfBold,
                ),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.SizedBox(height: 10),

              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(3),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'شرح',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            font: ttfBold,
                          ),
                          textAlign: pw.TextAlign.center,
                          textDirection: pw.TextDirection.rtl,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'مبلغ (تومان)',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            font: ttfBold,
                          ),
                          textAlign: pw.TextAlign.center,
                          textDirection: pw.TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'کل خرید',
                          style: pw.TextStyle(font: ttf),
                          textDirection: pw.TextDirection.rtl,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          NumberFormat(
                            '#,###',
                          ).format(dateRangeProfitLoss['totalPurchases'] ?? 0),
                          style: pw.TextStyle(font: ttf),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'کل فروش',
                          style: pw.TextStyle(font: ttf),
                          textDirection: pw.TextDirection.rtl,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          NumberFormat(
                            '#,###',
                          ).format(dateRangeProfitLoss['totalSales'] ?? 0),
                          style: pw.TextStyle(font: ttf),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'ارزش فعلی خریدها',
                          style: pw.TextStyle(font: ttf),
                          textDirection: pw.TextDirection.rtl,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          NumberFormat('#,###').format(
                            dateRangeProfitLoss['currentValueOfPurchases'] ?? 0,
                          ),
                          style: pw.TextStyle(font: ttf),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'سود/زیان',
                          style: pw.TextStyle(
                            font: ttfBold,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textDirection: pw.TextDirection.rtl,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '${NumberFormat('#,###').format(dateRangeProfitLoss['profitLoss'] ?? 0)} (${(dateRangeProfitLoss['profitPercent'] ?? 0).toStringAsFixed(1)}%)',
                          style: pw.TextStyle(
                            font: ttfBold,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ];
          },
        ),
      );

      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        final file = File(
          '$selectedDirectory/profit_loss_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Text('فایل PDF با موفقیت ذخیره شد: ${file.path}'),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Text('خطا در تولید PDF: $e'),
          ),
        ),
      );
    }
  }
}
