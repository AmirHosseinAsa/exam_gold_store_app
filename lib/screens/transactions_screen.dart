import 'package:exam_gold_store_app/widgets/widget_custom_appbar.dart';
import 'package:exam_gold_store_app/models/transaction.dart';
import 'package:exam_gold_store_app/helpers/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../utils/constants.dart';
import 'package:flutter/services.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Transaction> transactions = [];
  List<Transaction> availableForSale = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => isLoading = true);
    final db = await DatabaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'id DESC',
    );

    final availableItems = await DatabaseHelper.getInventoryItems();

    setState(() {
      transactions = List.generate(
        maps.length,
        (i) => Transaction.fromMap(maps[i]),
      );
      availableForSale = availableItems
          .map((item) => Transaction.fromMap(item))
          .toList();
      isLoading = false;
    });
  }

  Future<void> _addTransaction(Transaction transaction) async {
    final db = await DatabaseHelper.database;
    await db.insert('transactions', transaction.toMap());

    if (transaction.type == 'sell' &&
        transaction.soldFromTransactionId != null) {
      await DatabaseHelper.markItemAsSold(transaction.soldFromTransactionId!);
    }

    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cBackgroundColor,
      child: Column(
        children: [
          WidgetCustomAppbar(
            isLoading: isLoading,
            doWhenPressed: _loadTransactions,
            appBarTitle: 'مدیریت معاملات',
            showIcon: !isLoading,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: availableForSale.isEmpty
                        ? null
                        : () => _showSellDialog(),
                    icon: const Icon(Icons.sell, color: Colors.white),
                    label: const Text(
                      'ثبت فروش',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: availableForSale.isEmpty
                          ? Colors.grey
                          : Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showTransactionDialog('buy'),
                    icon: const Icon(
                      Icons.add_shopping_cart,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'ثبت خرید',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : transactions.isEmpty
                ? const Center(
                    child: Text(
                      'هیچ معاملهای ثبت نشده است',
                      style: TextStyle(fontSize: 16, color: cTextSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: transaction.type == 'buy'
                                  ? Colors.green
                                  : Colors.red,
                              child: Icon(
                                transaction.type == 'buy'
                                    ? Icons.add
                                    : Icons.remove,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              '${transaction.customerName} - ${transaction.itemType}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'مقدار: ${transaction.quantity} | قیمت واحد: ${NumberFormat('#,###').format(transaction.unitPrice)}',
                                ),
                                Text(
                                  'کل: ${NumberFormat('#,###').format(transaction.totalPrice)} تومان',
                                ),
                                Text(
                                  'تاریخ: ${PersianDateHelper.gregorianToPersian(transaction.date)}',
                                ),
                                if (transaction.description != null)
                                  Text('توضیحات: ${transaction.description}'),
                                if (transaction.type == 'sell' &&
                                    transaction.soldFromTransactionId != null)
                                  Text(
                                    'فروش از آیتم #${transaction.soldFromTransactionId}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: cTextSecondary,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                if (!transaction.isInStoreNow &&
                                    transaction.type == 'buy')
                                  const Text(
                                    'فروخته شده',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if((transaction.type == 'buy' &&  transaction.isInStoreNow) || (transaction.type == 'sell' && !transaction.isInStoreNow))
                                Text(
                                  transaction.type == 'buy' ? 'خرید' : 'فروش',
                                  style: TextStyle(
                                    color: transaction.type == 'buy'
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                if (transaction.type == 'buy')
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: transaction.isInStoreNow
                                          ? Colors.green
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      transaction.isInStoreNow
                                          ? 'موجود'
                                          : 'فروخته',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDialog(String type) {
    final formKey = GlobalKey<FormState>();
    final controllers = {
      'itemType': TextEditingController(),
      'quantity': TextEditingController(),
      'unitPrice': TextEditingController(),
      'customerName': TextEditingController(),
      'customerPhone': TextEditingController(),
      'description': TextEditingController(),
    };
    String selectedDate = PersianDateHelper.getCurrentGregorianDate();
    String displayDate = PersianDateHelper.getCurrentPersianDate();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text('ثبت خرید جدید'),
            content: SizedBox(
              width: 600,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'نوع کالا',
                        ),
                        items: kProductTypes
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          controllers['itemType']!.text = value ?? '';
                          if (value != null) {
                            final livePrice = getLivePriceForProduct(value);
                            if (livePrice > 0) {
                              controllers['unitPrice']!.text = livePrice
                                  .toStringAsFixed(0);
                            }
                            setDialogState(() {});
                          }
                        },
                        validator: (value) => value?.isEmpty == true
                            ? 'نوع کالا را انتخاب کنید'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controllers['quantity'],
                        decoration: const InputDecoration(labelText: 'مقدار'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            if (newValue.text.split('.').length > 2) {
                              return oldValue;
                            }
                            return newValue;
                          }),
                        ],
                        validator: (value) => value?.isEmpty == true
                            ? 'مقدار را وارد کنید'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controllers['unitPrice'],
                        decoration: const InputDecoration(
                          labelText: 'قیمت واحد (تومان)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty == true ? 'قیمت را وارد کنید' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controllers['customerName'],
                        decoration: const InputDecoration(
                          labelText: 'تامین‌کننده',
                        ),
                        validator: (value) =>
                            value?.isEmpty == true ? 'نام را وارد کنید' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controllers['customerPhone'],
                        decoration: const InputDecoration(
                          labelText: 'شماره تماس',
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: Text('تاریخ: $displayDate')),
                          IconButton(
                            onPressed: () => _showDayMonthPicker(context, (
                              newDate,
                            ) {
                              selectedDate = newDate;
                              displayDate =
                                  PersianDateHelper.gregorianToPersian(newDate);
                              setDialogState(() {});
                            }),
                            icon: const Icon(Icons.calendar_today),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controllers['description'],
                        decoration: const InputDecoration(
                          labelText: 'توضیحات (اختیاری)',
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final quantity = double.parse(
                      controllers['quantity']!.text,
                    );
                    final unitPrice = double.parse(
                      controllers['unitPrice']!.text,
                    );
                    final transaction = Transaction(
                      type: type,
                      itemType: controllers['itemType']!.text,
                      quantity: quantity,
                      unitPrice: unitPrice,
                      totalPrice: quantity * unitPrice,
                      customerName: controllers['customerName']!.text,
                      customerPhone: controllers['customerPhone']!.text.isEmpty
                          ? null
                          : controllers['customerPhone']!.text,
                      date: selectedDate,
                      description: controllers['description']!.text.isEmpty
                          ? null
                          : controllers['description']!.text,
                      isInStoreNow: true,
                    );
                    _addTransaction(transaction);
                    Navigator.pop(context);
                  }
                },
                child: const Text('ثبت خرید'),
              ),
                     TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('انصراف'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSellDialog() {
    Transaction? selectedItem;
    final formKey = GlobalKey<FormState>();
    final controllers = {
      'sellPrice': TextEditingController(),
      'customerName': TextEditingController(),
      'customerPhone': TextEditingController(),
      'description': TextEditingController(),
    };
    String selectedDate = PersianDateHelper.getCurrentGregorianDate();
    String displayDate = PersianDateHelper.getCurrentPersianDate();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('فروش از موجودی'),
            content: SizedBox(
              width: 600,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<Transaction>(
                        decoration: const InputDecoration(
                          labelText: 'انتخاب آیتم برای فروش',
                        ),
                        hint: const Text('آیتم مورد نظر را انتخاب کنید'),
                        items: availableForSale
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  '${item.itemType} - مقدار: ${item.quantity} - #${item.id}',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedItem = value;
                            if (value != null) {
                              final livePrice = getLivePriceForProduct(
                                value.itemType,
                              );
                              controllers['sellPrice']!.text = livePrice > 0
                                  ? livePrice.toStringAsFixed(0)
                                  : value.unitPrice.toString();
                            }
                          });
                        },
                        validator: (value) =>
                            value == null ? 'آیتم را انتخاب کنید' : null,
                      ),
                      if (selectedItem != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cPrimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'اطلاعات آیتم انتخابی:',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('نوع: ${selectedItem!.itemType}'),
                              Text('مقدار: ${selectedItem!.quantity}'),
                              Text(
                                'قیمت خرید: ${NumberFormat('#,###').format(selectedItem!.unitPrice)} تومان',
                              ),
                              Text(
                                'تاریخ خرید: ${PersianDateHelper.gregorianToPersian(selectedItem!.date)}',
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controllers['sellPrice'],
                        decoration: const InputDecoration(
                          labelText: 'قیمت فروش (تومان)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty == true
                            ? 'قیمت فروش را وارد کنید'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controllers['customerName'],
                        decoration: const InputDecoration(
                          labelText: 'نام مشتری',
                        ),
                        validator: (value) => value?.isEmpty == true
                            ? 'نام مشتری را وارد کنید'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controllers['customerPhone'],
                        decoration: const InputDecoration(
                          labelText: 'شماره تماس',
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: Text('تاریخ: $displayDate')),
                          IconButton(
                            onPressed: () => _showDayMonthPicker(context, (
                              newDate,
                            ) {
                              selectedDate = newDate;
                              displayDate =
                                  PersianDateHelper.gregorianToPersian(newDate);
                              setDialogState(() {});
                            }),
                            icon: const Icon(Icons.calendar_today),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controllers['description'],
                        decoration: const InputDecoration(
                          labelText: 'توضیحات (اختیاری)',
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
            
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate() &&
                      selectedItem != null) {
                    final sellPrice = double.parse(
                      controllers['sellPrice']!.text,
                    );
                    final saleTransaction = Transaction(
                      type: 'sell',
                      itemType: selectedItem!.itemType,
                      quantity: selectedItem!.quantity,
                      unitPrice: sellPrice,
                      totalPrice: selectedItem!.quantity * sellPrice,
                      customerName: controllers['customerName']!.text,
                      customerPhone: controllers['customerPhone']!.text.isEmpty
                          ? null
                          : controllers['customerPhone']!.text,
                      date: selectedDate,
                      description: controllers['description']!.text.isEmpty
                          ? null
                          : controllers['description']!.text,
                      isInStoreNow: false,
                      soldFromTransactionId: selectedItem!.id,
                    );
                    _addTransaction(saleTransaction);
                    Navigator.pop(context);
                  }
                },
                child: const Text('ثبت فروش'),
              ),
                TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('انصراف'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDayMonthPicker(
    BuildContext context,
    Function(String) onDateSelected,
  ) {
    final currentJalali = Jalali.now();
    int selectedMonth = currentJalali.month;
    int selectedDay = currentJalali.day;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: cSurfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'انتخاب روز و ماه - سال ${currentJalali.year}',
              style: const TextStyle(color: cTextPrimary, fontSize: 18),
            ),
            content: SizedBox(
              height: 400,
              width: 320,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: cPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cPrimaryColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'انتخاب ماه:',
                          style: TextStyle(
                            color: cTextPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: selectedMonth,
                          dropdownColor: cSurfaceColor,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: cPrimaryColor.withOpacity(0.5),
                              ),
                            ),
                            filled: true,
                            fillColor: cBackgroundColor,
                          ),
                          style: const TextStyle(color: cTextPrimary),
                          items: [
                            DropdownMenuItem(value: 1, child: Text('فروردین')),
                            DropdownMenuItem(value: 2, child: Text('اردیبهشت')),
                            DropdownMenuItem(value: 3, child: Text('خرداد')),
                            DropdownMenuItem(value: 4, child: Text('تیر')),
                            DropdownMenuItem(value: 5, child: Text('مرداد')),
                            DropdownMenuItem(value: 6, child: Text('شهریور')),
                            DropdownMenuItem(value: 7, child: Text('مهر')),
                            DropdownMenuItem(value: 8, child: Text('آبان')),
                            DropdownMenuItem(value: 9, child: Text('آذر')),
                            DropdownMenuItem(value: 10, child: Text('دی')),
                            DropdownMenuItem(value: 11, child: Text('بهمن')),
                            DropdownMenuItem(value: 12, child: Text('اسفند')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedMonth = value;
                                final maxDay = Jalali(
                                  currentJalali.year,
                                  selectedMonth,
                                  1,
                                ).monthLength;
                                if (selectedDay > maxDay) {
                                  selectedDay = maxDay;
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: cAccentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cAccentColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'انتخاب روز:',
                          style: TextStyle(
                            color: cTextPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 200,
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                ),
                            itemCount: Jalali(
                              currentJalali.year,
                              selectedMonth,
                              1,
                            ).monthLength,
                            itemBuilder: (context, index) {
                              final day = index + 1;
                              final isSelected = day == selectedDay;
                              return GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    selectedDay = day;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? cPrimaryColor
                                        : cBackgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? cPrimaryColor
                                          : cTextSecondary.withOpacity(0.3),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      day.toString(),
                                      style: TextStyle(
                                        color: isSelected
                                            ? cBackgroundColor
                                            : cTextPrimary,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: cTextSecondary),
                child: const Text('انصراف'),
              ),
              ElevatedButton(
                onPressed: () {
                  final selectedJalali = Jalali(
                    currentJalali.year,
                    selectedMonth,
                    selectedDay,
                  );
                  final gregorianDate = PersianDateHelper.jalaliToGregorian(
                    selectedJalali,
                  );
                  onDateSelected(gregorianDate);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cPrimaryColor,
                  foregroundColor: cBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'تأیید',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
