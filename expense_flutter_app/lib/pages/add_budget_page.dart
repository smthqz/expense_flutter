import 'package:expense_flutter_app/data/hive_budget.dart';
import 'package:expense_flutter_app/models/budget_item.dart';
import 'package:flutter/material.dart';

class AddBudget extends StatefulWidget {
  const AddBudget({super.key});

  @override
  _AddBudgetState createState() => _AddBudgetState();
}

class _AddBudgetState extends State<AddBudget> {
  final TextEditingController _controller = TextEditingController();
  String? selectedPeriod; // Для хранения выбранного периода
  final List<String> periods = [
    '7 дней',
    'Месяц',
    '6 месяцев',
    'Год'
  ]; // Список периодов

  DateTime calculatePeriodEndDate(String period) {
    DateTime now = DateTime.now();
    switch (period) {
      case '7 дней':
        return now.add(Duration(days: 7));
      case 'Месяц':
        return DateTime(now.year, now.month + 1, now.day);
      case '6 месяцев':
        return DateTime(now.year, now.month + 6, now.day);
      case 'Год':
        return DateTime(now.year + 1, now.month, now.day);
      default:
        return now; // В случае, если период не определен, возвращаем текущую дату
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Убедимся, что бокс открыт перед использованием
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Бюджет',
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leadingWidth: 56,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 30),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              maxLength: 10,
              controller: _controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Введите сумму бюджета',
                labelStyle: const TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF8393A5)),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20), // Отступ
            const Text(
              'Выберите период',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedPeriod,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              underline: Container(
                height: 1,
                color: Color(0xFF8393A5),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedPeriod = newValue;
                });
              },
              items: periods.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const Spacer(), // Используем Spacer для того, чтобы кнопка была внизу
            ElevatedButton(
              onPressed: () async {
                if (_controller.text.isEmpty || selectedPeriod == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Пожалуйста, заполните все поля')));
                  return;
                }
                // Получаем сумму и период
                double amount = double.tryParse(_controller.text) ?? 0;
                DateTime now = DateTime.now();
                DateTime periodEndDate =
                    calculatePeriodEndDate(selectedPeriod!);

                // Создаем новый BudgetItem
                BudgetItem newBudget = BudgetItem(
                    amount: amount,
                    startDate: now,
                    endDate: periodEndDate,
                    originalAmount: amount);

                await HiveDataBase.saveBudgetData(newBudget);
                // Очистка поля ввода и сброс выбранного периода
                _controller.clear();
                setState(() {
                  selectedPeriod = null;
                });

                // Оповещение пользователя
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Бюджет сохранен'),
                    duration: Duration(
                        seconds: 2), // продолжительность отображения
                    behavior: SnackBarBehavior
                        .floating, // поведение снекбара
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10),
                    ),
                  ),
                );
                Navigator.pop(context, newBudget);
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xFF3A86FF)),
                minimumSize:
                    MaterialStateProperty.all(const Size(double.infinity, 50)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              child: const Text(
                'Сохранить бюджет',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 30), // Добавим немного отступа внизу
          ],
        ),
      ),
    );
  }
}
