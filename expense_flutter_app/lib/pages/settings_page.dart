import 'package:expense_flutter_app/data/expense_data.dart';
import 'package:expense_flutter_app/data/hive_database.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedCurrency = 'RUB'; // Инициализируем текущую выбранную валюту

  @override
  Widget build(BuildContext context) {
    ExpenseData expenseData = Provider.of<ExpenseData>(context);
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Настройки',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 21,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                showBarModalBottomSheet(
                  context: context,
                  builder: (context) {
                    double screenHeight = MediaQuery.of(context).size.height;
                    double height = screenHeight * 0.3;
                    return Padding(
                      padding:
                          const EdgeInsets.only(top: 24, left: 16, right: 16),
                      child: SizedBox(
                        height: height,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                Provider.of<ExpenseData>(context, listen: false)
                                    .updateCurrency('RUB');
                                Provider.of<ExpenseData>(context, listen: false)
                                    .saveSelectedCurrency('RUB');
                                Navigator.pop(
                                    context); // Передача выбранной валюты назад
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Российский рубль ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black, // Цвет текста
                                          ),
                                        ),
                                        TextSpan(
                                          text: '(RUB)',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(
                                                0xFF8393A5), // Цвет текста
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  if (expenseData.selectedCurrency == 'RUB')
                                    Icon(Icons.check)
                                  else
                                    Icon(Icons.check,
                                        color: Colors.transparent),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            const Divider(
                              color: Color(0xFF8393A5),
                              thickness: 0.2,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            InkWell(
                              onTap: () {
                                Provider.of<ExpenseData>(context, listen: false)
                                    .updateCurrency('USD');
                                Provider.of<ExpenseData>(context, listen: false)
                                    .saveSelectedCurrency('USD');
                                Navigator.pop(
                                    context); // Передача выбранной валюты назад
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Доллар ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black, // Цвет текста
                                          ),
                                        ),
                                        TextSpan(
                                          text: '(USD)',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(
                                                0xFF8393A5), // Цвет текста
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  if (expenseData.selectedCurrency == 'USD')
                                    Icon(Icons.check)
                                  else
                                    Icon(Icons.check,
                                        color: Colors.transparent),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            const Divider(
                              color: Color(0xFF8393A5),
                              thickness: 0.2,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            InkWell(
                              onTap: () {
                                Provider.of<ExpenseData>(context, listen: false)
                                    .updateCurrency('EUR');
                                Provider.of<ExpenseData>(context, listen: false)
                                    .saveSelectedCurrency('EUR');
                                Navigator.pop(
                                    context); // Передача выбранной валюты назад
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Евро ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black, // Цвет текста
                                          ),
                                        ),
                                        TextSpan(
                                          text: '(EUR)',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(
                                                0xFF8393A5), // Цвет текста
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  if (expenseData.selectedCurrency == 'EUR')
                                    Icon(Icons.check)
                                  else
                                    Icon(Icons.check,
                                        color: Colors.transparent),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Основная валюта:',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        expenseData.selectedCurrency,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8,
            ),
            const Divider(
              color: Color(0xFF8393A5),
              thickness: 0.2,
            ),
            SizedBox(
              height: 8,
            ),
            InkWell(
              onTap: () {
                showDialog(context: context, builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Удаление данных'),
                    content: Text("Все операции, бюджет и цели будут удалены."),
                    actions: [
                        TextButton(
                          onPressed: () {
                            Provider.of<ExpenseData>(context, listen: false).clearAllData();
                            Navigator.of(context).pop();
                          }, 
                          child: Text('Удалить', style: TextStyle(color: Colors.red),)),
                          TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        }, 
                        child: Text('Отмена')),
                    ],
                  );
                });
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Начать всё сначала',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Row(
                    children: [
                      Text(
                        'Все операции, бюджет и цели будут удалены.',
                        style: TextStyle(color: const Color(0xFF8393A5)),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
