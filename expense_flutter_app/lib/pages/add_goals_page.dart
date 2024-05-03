import 'package:expense_flutter_app/data/expense_data.dart';
import 'package:expense_flutter_app/data/hive_goals.dart';
import 'package:expense_flutter_app/models/goal_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddGoalsPage extends StatefulWidget {
  const AddGoalsPage({Key? key});

  @override
  State<AddGoalsPage> createState() => _AddGoalsPageState();
}

class _AddGoalsPageState extends State<AddGoalsPage> {
  TextEditingController _goalNameController = TextEditingController();
  TextEditingController _goalAmountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveGoal() async {
    GoalItem goal = GoalItem(
      name: _goalNameController.text,
      goalAmount: double.parse(_goalAmountController.text),
      savedAmount: 0.0,
      goalDate: _selectedDate,
    );
    if (_goalNameController.text.isEmpty ||
        _goalAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Заполните все поля'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    await HiveGoalDatabase.saveGoalData(goal);
    Provider.of<ExpenseData>(context, listen: false).loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Цель сохранена'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior
                        .floating, 
        shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // Установите скругленные углы
                    ),
      ),
    );
    Navigator.pop(context, goal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Добавляем этот параметр
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Цели',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700),
        ),
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _goalNameController,
              decoration: InputDecoration(
                labelText: 'Название цели',
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
            const SizedBox(height: 20),
            TextField(
              controller: _goalAmountController,
              decoration: InputDecoration(
                labelText: 'Сумма цели',
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
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Row(
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text(
                  'Дата цели:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
                const Icon(Icons.edit_calendar, color: Colors.blue),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveGoal,
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xFF3A86FF)),
                minimumSize:
                    MaterialStateProperty.all(const Size(double.infinity, 50)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              child: const Text(
                'Сохранить цель',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
