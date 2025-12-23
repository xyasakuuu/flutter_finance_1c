import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  runApp(const MyFinanceApp());
}

enum SortType { dateNewest, dateOldest, amountIncome, amountExpense }

class MyFinanceApp extends StatelessWidget {
  const MyFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '1C:Кошелек',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFFFCC00),
        scaffoldBackgroundColor: const Color(0xFFFFF9C4),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFCC00),
          primary: const Color(0xFFD32F2F),
          secondary: const Color(0xFFFFCC00),
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.orange.shade200, width: 1),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFCC00),
          foregroundColor: Color(0xFFD32F2F),
          elevation: 4,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _commentController = TextEditingController();

  SortType _currentSortType = SortType.dateNewest;

  @override
  void initState() {
    super.initState();
    _refreshJournal();
  }

  Future<void> _refreshJournal() async {
    final data = await DBHelper.getAllTransactions();

    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  double get _totalBalance {
    return _transactions.fold(0.0, (sum, item) => sum + (item['amount'] as double));
  }


  List<Map<String, dynamic>> get _sortedTransactions {
    final sortedList = List<Map<String, dynamic>>.from(_transactions);

    sortedList.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      double amountA = a['amount'] as double;
      double amountB = b['amount'] as double;

      switch (_currentSortType) {
        case SortType.dateNewest:
          return dateB.compareTo(dateA);
        case SortType.dateOldest:
          return dateA.compareTo(dateB);
        case SortType.amountIncome:
          return amountB.compareTo(amountA);
        case SortType.amountExpense:
          return amountA.compareTo(amountB);
      }
    });
    return sortedList;
  }

  Future<void> _submitTransaction(bool isIncome) async {
    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text) ?? 0;
    final enteredComment = _commentController.text;

    if (enteredTitle.isEmpty || enteredAmount <= 0) return;

    if (!isIncome) {
      if (_totalBalance - enteredAmount < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ошибка: Недостаточно средств!'),
            backgroundColor: const Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }
    }

    await DBHelper.insertTransaction({
      'title': enteredTitle,
      'amount': isIncome ? enteredAmount : -enteredAmount,
      'date': DateTime.now().toIso8601String(), // Дату в строку
      'comment': enteredComment,
      'isIncome': isIncome ? 1 : 0, // Bool в int (SQLite не имеет Bool)
    });

    Navigator.of(context).pop();
    _titleController.clear();
    _amountController.clear();
    _commentController.clear();

    _refreshJournal();
  }

  Future<void> _deleteTransactionObj(Map<String, dynamic> tx) async {
    await DBHelper.deleteTransaction(tx['id']);
    _refreshJournal();
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFF9C4),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20, left: 20, right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Создание документа",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: const InputDecoration(labelText: 'Статья оборотов', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
                controller: _titleController,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(labelText: 'Сумма', border: OutlineInputBorder(), fillColor: Colors.white, filled: true, suffixText: '₸'),
                controller: _amountController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(labelText: 'Комментарий', border: OutlineInputBorder(), fillColor: Colors.white, filled: true, prefixIcon: Icon(Icons.comment, color: Colors.grey)),
                controller: _commentController,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _submitTransaction(false),
                    icon: const Icon(Icons.remove, color: Colors.white),
                    label: const Text('Расход', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _submitTransaction(true),
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text('Приход', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFCC00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _sortedTransactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('1С:Личные Деньги', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<SortType>(
            icon: const Icon(Icons.sort),
            onSelected: (SortType result) {
              setState(() { _currentSortType = result; });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortType>>[
              const PopupMenuItem<SortType>(value: SortType.dateNewest, child: Text('По дате (новые)')),
              const PopupMenuItem<SortType>(value: SortType.dateOldest, child: Text('По дате (старые)')),
              const PopupMenuDivider(),
              const PopupMenuItem<SortType>(value: SortType.amountIncome, child: Text('По приходу (Макс)')),
              const PopupMenuItem<SortType>(value: SortType.amountExpense, child: Text('По расходу (Макс)')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            width: double.infinity, margin: const EdgeInsets.all(15), padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFCC00),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD32F2F), width: 2),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))],
            ),
            child: Column(
              children: [
                const Text('Текущий остаток', style: TextStyle(color: Colors.black87)),
                Text('${_totalBalance.toStringAsFixed(0)} ₸', style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 40, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Expanded(
            child: displayList.isEmpty
                ? const Center(child: Text('Нет записей', style: TextStyle(color: Colors.grey, fontSize: 18)))
                : ListView.builder(
              itemCount: displayList.length,
              itemBuilder: (ctx, index) {
                final tx = displayList[index];
                final isInc = (tx['isIncome'] == 1);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isInc ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(isInc ? Icons.arrow_upward : Icons.arrow_downward, color: isInc ? Colors.green[800] : Colors.red[800]),
                    ),
                    title: Text(tx['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateTime.parse(tx['date']).toString().substring(0, 16)),
                        if (tx['comment'] != null && tx['comment'].toString().isNotEmpty)
                          Text("${tx['comment']}", style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${tx['amount'] > 0 ? '+' : ''}${tx['amount']} ₸', style: TextStyle(color: isInc ? Colors.green[800] : Colors.red[800], fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => _deleteTransactionObj(tx),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startAddNewTransaction(context),
        backgroundColor: const Color(0xFFD32F2F),
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text('Создать', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}