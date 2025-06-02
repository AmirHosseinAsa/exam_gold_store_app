import 'package:exam_gold_store_app/screens/dashboard_screen.dart';
import 'package:exam_gold_store_app/screens/transactions_screen.dart';
import 'package:exam_gold_store_app/screens/real_time_prices_screen.dart';
import 'package:exam_gold_store_app/screens/settings_screen.dart';
import 'package:exam_gold_store_app/utils/constants.dart';
import 'package:flutter/material.dart';
import '../utils/routes.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _currentRoute = Routes.dashboard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Container(color: cCardBackground, child: _buildContent()),
          ),
          Container(
            width: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [cSidebarStart, cSidebarEnd],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(-2, 0),
                ),
              ],
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cPrimaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: cPrimaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.star,
                            color: cPrimaryColor,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'مدیریت طلافروشی',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: cTextPrimary,
                          ),
                        ),
                        const Text(
                          VERSION,
                          style: TextStyle(fontSize: 14, color: cTextSecondary),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.dashboard,
                            title: 'داشبورد',
                            route: Routes.dashboard,
                          ),

                          const SizedBox(height: 8),
                          _buildMenuItem(
                            icon: Icons.receipt_long,
                            title: 'معاملات',
                            route: Routes.transactions,
                          ),
                          const SizedBox(height: 8),
                          _buildMenuItem(
                            icon: Icons.trending_up,
                            title: 'قیمت‌های لحظه‌ای',
                            route: Routes.realTimePrices,
                          ),

                          const Spacer(),

                          Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            color: cTextSecondary.withOpacity(0.3),
                          ),

                          _buildMenuItem(
                            icon: Icons.settings,
                            title: 'تنظیمات',
                            route: Routes.settings,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isSelected = _currentRoute == route;

    return GestureDetector(
      onTap: () {
          setState(() {
            _currentRoute = route;
          });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? cPrimaryColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: cPrimaryColor.withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? cPrimaryColor : cTextPrimary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? cPrimaryColor : cTextPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentRoute) {
      case Routes.transactions:
        return const TransactionsScreen();
      case Routes.realTimePrices:
        return const RealTimePricesScreen();
      case Routes.settings:
        return const SettingsScreen();
      case Routes.dashboard:
      default:
        return const DashboardScreen();
    }
  }

 
}
