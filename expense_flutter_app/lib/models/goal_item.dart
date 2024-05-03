import 'package:hive/hive.dart';

class AmountHistoryItem {
  final double amount;
  final DateTime date;

  AmountHistoryItem({required this.amount, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  // Метод для создания экземпляра AmountHistoryItem из Map
  factory AmountHistoryItem.fromMap(Map<String, dynamic> map) {
    return AmountHistoryItem(
      amount: map['amount'] as double,
      date: DateTime.parse(map['date'] as String),
    );
  }
}



// Адаптер для класса AmountHistoryItem
class AmountHistoryItemAdapter extends TypeAdapter<AmountHistoryItem> {
  @override
  final int typeId = 0; // Уникальный идентификатор типа для адаптера

  @override
  AmountHistoryItem read(BinaryReader reader) {
    // Прочитайте данные из бинарного потока и создайте объект AmountHistoryItem
    final amount = reader.readDouble();
    final date = DateTime.parse(reader.readString());
    return AmountHistoryItem(amount: amount, date: date);
  }

  @override
  void write(BinaryWriter writer, AmountHistoryItem obj) {
    // Запишите данные объекта AmountHistoryItem в бинарный поток
    writer.writeDouble(obj.amount);
    writer.writeString(obj.date.toIso8601String());
  }
}



class GoalItem {
  final String name;
  double goalAmount;
  double savedAmount;
  final DateTime goalDate;
  List<AmountHistoryItem> amountHistory;

  GoalItem({
    required this.name,
    required this.goalAmount,
    required this.savedAmount,
    required this.goalDate,
    List<AmountHistoryItem>? amountHistory,
  }) : this.amountHistory = amountHistory ?? [];

  void addSavedAmount(double additionalAmount) {
    savedAmount += additionalAmount;
    DateTime currentDate = DateTime.now();
    amountHistory.add(AmountHistoryItem(
      amount: additionalAmount,
      date: currentDate,
    ));
  }
}

