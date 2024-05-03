class BudgetItem {
  double amount;
  final DateTime startDate;
  final DateTime endDate;
  double originalAmount;

  BudgetItem({
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.originalAmount
  }) {
    originalAmount = amount;
  }
}
