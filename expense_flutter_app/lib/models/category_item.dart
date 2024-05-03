class ExpenseCategory {
  final String id;
  final String name;

  ExpenseCategory({required this.id, required this.name});
}

List<ExpenseCategory> categories = [
  ExpenseCategory(id: '1', name: 'Еда'),
  ExpenseCategory(id: '2', name: 'Транспорт'),
  ExpenseCategory(id: '3', name: 'Жилье'),
  ExpenseCategory(id: '4', name: 'Развлечения'),
  ExpenseCategory(id: '5', name: 'Здоровье'),
];