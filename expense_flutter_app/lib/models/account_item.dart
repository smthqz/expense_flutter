
import 'package:hive/hive.dart';

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final int typeId = 1; // Уникальный идентификатор типа

  @override
  Account read(BinaryReader reader) {
    return Account(
      name: reader.readString(),
      balance: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer.writeString(obj.name);
    writer.writeDouble(obj.balance);
  }
}



class Account {
  String name;
  double balance;

  Account({required this.name, required this.balance,});
}