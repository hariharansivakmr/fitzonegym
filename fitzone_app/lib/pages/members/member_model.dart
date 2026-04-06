class MemberModel {
  final String name;
  final String mobile;
  final String plan;
  final double fees;
  final DateTime joinDate;
  final DateTime nextDueDate;
  final bool isPaid;

  MemberModel({
    required this.name,
    required this.mobile,
    required this.plan,
    required this.fees,
    required this.joinDate,
    required this.nextDueDate,
    required this.isPaid,
  });
}