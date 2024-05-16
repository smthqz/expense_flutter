import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_flutter_app/data/expense_data.dart';
import 'package:expense_flutter_app/models/account_item.dart';
import 'package:expense_flutter_app/components/account_tile.dart';
import 'package:expense_flutter_app/pages/add_account_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding:
            const EdgeInsets.only(top: 40, left: 24, right: 24, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Счета',
              style: TextStyle(
                color: Colors.black,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            // Список карточек счетов с отступом снизу
            Expanded(
              child: Consumer<ExpenseData>(
                builder: (context, expenseData, child) {
                  List<Account> accountList = expenseData.accountList;
                  if (accountList.isEmpty) {
                    return Center(
                      child: Text('Счета отсутствуют'),
                    );
                  }
                  return ListView.builder(
                    itemCount: accountList.length,
                    itemBuilder: (context, index) {
                      Account account = accountList[index];
                      return Column(
                        children: [
                          AccountTile(
                            accountName: account.name,
                            accountBalance: account.balance,
                          ),
                          SizedBox(
                            height: 16,
                          ) // Отступ между карточками
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            // Кнопка "Добавить счет" с отступом сверху
            ElevatedButton(
              onPressed: () {
                // Действие при нажатии кнопки
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddAccountPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A86FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Добавить счет',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
