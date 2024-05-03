import 'package:expense_flutter_app/data/expense_data.dart';
import 'package:expense_flutter_app/data/hive_budget.dart';
import 'package:expense_flutter_app/models/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpenseDetail extends StatefulWidget {
  final ExpenseItem expense;
  final Function(ExpenseItem) onDelete;

  ExpenseDetail({
    Key? key,
    required this.expense,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<ExpenseDetail> createState() => _ExpenseDetailState();
}

class _ExpenseDetailState extends State<ExpenseDetail> {
  final TextEditingController _amountController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _dateController = TextEditingController();

  final TextEditingController _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<String> categories = [
    'Еда',
    'Транспорт',
    'Жилье',
    'Развлечения',
    'Здоровье',
    'Без категории'
  ];
    DateTime selectedMonth = Provider.of<ExpenseData>(context).selectedMonth;
    List<ExpenseItem> filteredExpenses = Provider.of<ExpenseData>(context)
        .getFilteredExpenseListByMonth(selectedMonth);
    String currencySymbol = Provider.of<ExpenseData>(context).currencySymbol;
    ExpenseData expenseData = Provider.of<ExpenseData>(context);
    int index = filteredExpenses.indexOf(widget.expense);
    if (expenseData.selectedCurrency == 'RUB') {
      currencySymbol = '₽';
    } else if (expenseData.selectedCurrency == 'USD') {
      currencySymbol = '\$';
    } else if (expenseData.selectedCurrency == 'EUR') {
      currencySymbol = '€';
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Детали расхода',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        automaticallyImplyLeading: false,
        leadingWidth: 56,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.black,
            size: 30,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              widget.onDelete(
                  widget.expense); // Передаем объект expense в onDelete
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 30,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        children: [
                          TextSpan(
                            text: 'Название: ',
                          ),
                          TextSpan(
                              text: '${widget.expense.name}',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        String newName = '';
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Новое название'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: _nameController,
                                    keyboardType: TextInputType.name,
                                    onChanged: (value) {
                                      newName =
                                          value; // Сохранить значение из поля ввода
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Введите новое название',
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    // Обновляем данные в провайдере
                                    expenseData.updateExpenseName(
                                        index, newName);
                                    expenseData.prepareData();
                                    setState(() {
                                      widget.expense.name = newName;
                                    });

                                    // Здесь можете использовать newName
                                    print('Новое название: $newName');

                                    Navigator.of(context)
                                        .pop(); // Закрыть диалог
                                  },
                                  child: Text('Сохранить'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Закрыть диалог
                                  },
                                  child: Text('Отмена'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
                child: Divider(
                  color: const Color(0xFF8393A5),
                  thickness: 0.2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        children: [
                          TextSpan(
                            text: 'Сумма: ',
                          ),
                          TextSpan(
                              text: '${widget.expense.amount} $currencySymbol',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        String newAmount = '';
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Новая сумма'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      newAmount =
                                          value; // Сохранить значение из поля ввода
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Введите новую сумму',
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    // Обновляем данные в провайдере
                                    expenseData.updateExpenseAmount(
                                        index, newAmount);
                                    expenseData.prepareData();
                                    setState(() {
                                      widget.expense.amount = newAmount;
                                    });

                                    // Здесь можете использовать newName
                                    print('Новое название: $newAmount');
                                    Navigator.of(context)
                                        .pop(); // Закрыть диалог
                                  },
                                  child: Text('Сохранить'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Закрыть диалог
                                  },
                                  child: Text('Отмена'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
                child: Divider(
                  color: const Color(0xFF8393A5),
                  thickness: 0.2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        children: [
                          TextSpan(
                            text: 'Дата: ',
                          ),
                          TextSpan(
                              text:
                                  '${widget.expense.dateTime.day}/${widget.expense.dateTime.month}/${widget.expense.dateTime.year}',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    InkWell(
                      // В методе onTap в вашем InkWell
                      onTap: () async {
                        // Показать DatePicker и получить выбранную дату
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: widget
                              .expense.dateTime, // Установить начальную дату
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (selectedDate != null) {
                          // Обновить дату расхода с помощью провайдера
                          expenseData.updateExpenseDate(index, selectedDate);
                          setState(() {
                            widget.expense.dateTime = selectedDate;
                          });
                        }
                      },

                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
                child: Divider(
                  color: const Color(0xFF8393A5),
                  thickness: 0.2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        children: [
                          TextSpan(
                            text: 'Категория: ',
                          ),
                          TextSpan(
                              text: '${widget.expense.category}',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              title: Text('Выберите категорию'),
                              children: categories.map((category) {
                                return ListTile(
                                  title: Text(category),
                                  onTap: () {
                                    // Обновить категорию расхода с помощью провайдера
                                    expenseData.updateExpenseCategory(
                                        index, category);
                                    setState(() {
                                      widget.expense.category = category;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                );
                              }).toList(),
                            );
                          },
                        );
                      },
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
