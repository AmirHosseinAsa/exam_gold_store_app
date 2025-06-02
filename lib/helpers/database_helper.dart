import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'gold_store.db';
  static const int _databaseVersion = 3;

  static Future<void> initialize() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        itemType TEXT NOT NULL,
        quantity REAL NOT NULL,
        unitPrice REAL NOT NULL,
        totalPrice REAL NOT NULL,
        customerName TEXT NOT NULL,
        customerPhone TEXT,
        date TEXT NOT NULL,
        description TEXT,
        isInStoreNow INTEGER DEFAULT 1,
        soldFromTransactionId INTEGER
      )
    ''');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE transactions ADD COLUMN isInStoreNow INTEGER DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE transactions ADD COLUMN soldFromTransactionId INTEGER',
      );
    }
  }

  static Future<List<Map<String, dynamic>>> getInventoryItems() async {
    final db = await database;
    return await db.query(
      'transactions',
      where: 'type = ? AND isInStoreNow = ?',
      whereArgs: ['buy', 1],
      orderBy: 'date ASC',
    );
  }

  static Future<Map<String, Map<String, dynamic>>> getInventorySummary() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT itemType, 
             SUM(quantity) as totalQuantity, 
             AVG(unitPrice) as avgUnitPrice, 
             SUM(totalPrice) as totalValue, 
             COUNT(*) as itemCount
      FROM transactions 
      WHERE type = 'buy' AND isInStoreNow = 1 
      GROUP BY itemType
    ''');

    Map<String, Map<String, dynamic>> summary = {};
    for (var row in result) {
      summary[row['itemType'] as String] = {
        'totalQuantity': row['totalQuantity'] as double,
        'avgUnitPrice': row['avgUnitPrice'] as double,
        'totalValue': row['totalValue'] as double,
        'itemCount': row['itemCount'] as int,
      };
    }
    return summary;
  }

  static Future<void> markItemAsSold(int transactionId) async {
    final db = await database;
    await db.update(
      'transactions',
      {'isInStoreNow': 0},
      where: 'id = ?',
      whereArgs: [transactionId],
    );
  }

  static Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('transactions');
  }

  static Future<List<Map<String, dynamic>>> getTransactionsByDateRange(
    String startDate,
    String endDate,
  ) async {
    final db = await database;
    return await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC',
    );
  }

  static Future<Map<String, double>> getProfitLossAnalysisByDateRange(
    String startDate,
    String endDate,
  ) async {
    final db = await database;

    final purchasesResult = await db.rawQuery(
      '''
      SELECT SUM(totalPrice) as totalPurchases 
      FROM transactions 
      WHERE type = 'buy' AND date >= ? AND date <= ?
    ''',
      [startDate, endDate],
    );

    final salesResult = await db.rawQuery(
      '''
      SELECT SUM(totalPrice) as totalSales 
      FROM transactions 
      WHERE type = 'sell' AND date >= ? AND date <= ?
    ''',
      [startDate, endDate],
    );

    final purchaseItems = await db.query(
      'transactions',
      where: 'type = ? AND date >= ? AND date <= ?',
      whereArgs: ['buy', startDate, endDate],
    );

    double totalPurchases =
        (purchasesResult.first['totalPurchases'] as double?) ?? 0.0;
    double totalSales = (salesResult.first['totalSales'] as double?) ?? 0.0;
    double currentValueOfPurchases = 0.0;

    for (var item in purchaseItems) {
      final quantity = (item['quantity'] as num).toDouble();
      final itemType = item['itemType'] as String;
      final purchaseCost = (item['totalPrice'] as num).toDouble();

      final currentPrice = getLivePriceForProduct(itemType);
      if (currentPrice > 0) {
        currentValueOfPurchases += quantity * currentPrice;
      } else {
        currentValueOfPurchases += purchaseCost;
      }
    }

    double profitLoss = currentValueOfPurchases - totalPurchases + totalSales;
    double profitPercent = totalPurchases > 0
        ? (profitLoss / totalPurchases * 100)
        : 0;

    return {
      'totalPurchases': totalPurchases,
      'currentValueOfPurchases': currentValueOfPurchases,
      'totalSales': totalSales,
      'profitLoss': profitLoss,
      'profitPercent': profitPercent,
    };
  }
}
