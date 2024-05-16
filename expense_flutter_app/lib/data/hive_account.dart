import 'package:expense_flutter_app/models/account_item.dart';
import 'package:hive/hive.dart';

class AccountDatabase {
  final String _boxName = 'accounts';

  Future<void> addAccount(Account account) async {
    final box = await Hive.openBox<Account>(_boxName);
    await box.add(account);
  }

  Future<List<Account>> getAccounts() async {
    final box = await Hive.openBox<Account>(_boxName);
    return box.values.toList();
  }

  Future<void> updateAccount(int index, Account updatedAccount) async {
    final box = await Hive.openBox<Account>(_boxName);
    await box.putAt(index, updatedAccount);
  }

  Future<void> deleteAccount(int index) async {
    final box = await Hive.openBox<Account>(_boxName);
    await box.deleteAt(index);
  }
}
