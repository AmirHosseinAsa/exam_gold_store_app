import 'package:exam_gold_store_app/widgets/widget_custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/constants.dart';
import '../helpers/database_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _showDeleteConfirmDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cCardBackground,
          title: const Text('حذف تمام داده‌ها', style: TextStyle(color: cTextPrimary)),
          content: const Text(
            'آیا مطمئن هستید که می‌خواهید تمام تراکنش‌ها را حذف کنید؟\nاین عمل قابل بازگشت نیست.',
            style: TextStyle(color: cTextSecondary),
            textDirection: TextDirection.rtl,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('انصراف', style: TextStyle(color: cTextSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await DatabaseHelper.deleteAllData();
                  Navigator.of(context).pop();
                  Get.snackbar(
                    'موفق',
                    'تمام داده‌ها با موفقیت حذف شدند',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    messageText: Text(
                      'تمام داده‌ها با موفقیت حذف شدند',
                      style: TextStyle(color: Colors.white),
                      textDirection: TextDirection.rtl,
                    ),
                    titleText: Text(
                      'موفق',
                      style: TextStyle(color: Colors.white),
                      textDirection: TextDirection.rtl,
                    ),
                  );
                } catch (e) {
                  Get.snackbar(
                    'خطا',
                    'خطا در حذف داده‌ها',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    messageText: Text(
                      'خطا در حذف داده‌ها',
                      style: TextStyle(color: Colors.white),
                      textDirection: TextDirection.rtl,
                    ),
                    titleText: Text(
                      'خطا',
                      style: TextStyle(color: Colors.white),
                      textDirection: TextDirection.rtl,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
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
          WidgetCustomAppbar(isLoading: false, doWhenPressed: () {}, appBarTitle: 'تنظیمات', showIcon: false),
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cCardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cBorderColor),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.person, color: cPrimaryColor, size: 48),
                          SizedBox(height: 16),
                          Text(
                            'برنامه نویس امیرحسین آسا',
                            style: TextStyle(
                              color: cTextPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.email, color: cTextSecondary, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'amirhossein.asa.pro@gmail.com',
                                style: TextStyle(
                                  color: cTextSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cCardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cBorderColor),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.delete_forever, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          const Text(
                            'حذف تمام داده‌ها',
                            style: TextStyle(
                              color: cTextPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'تمام تراکنش‌ها و اطلاعات ذخیره شده حذف خواهند شد',
                            style: TextStyle(
                                color: cTextSecondary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _showDeleteConfirmDialog(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'حذف تمام داده‌ها',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 