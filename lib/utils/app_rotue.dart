import 'routes.dart';
import '../screens/dashboard_screen.dart';
import '../screens/transactions_screen.dart';
import '../screens/real_time_prices_screen.dart';
import '../screens/settings_screen.dart';

class AppRoute {
  AppRoute._();

  static final routes = {
    Routes.dashboard: () => const DashboardScreen(),
    Routes.transactions: () => const TransactionsScreen(),
    Routes.realTimePrices: () => const RealTimePricesScreen(),
    Routes.settings: () => const SettingsScreen(),
  };
}
