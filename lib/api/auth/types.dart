/// 用户信息模型
class UserInfo {
  final int id;
  final String name;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserInfo({
    required this.id,
    required this.name,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['ID'] ?? 0,
      name: json['name'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      createdAt:
          DateTime.parse(json['CreatedAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['UpdatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'name': name,
      'balance': balance,
      'CreatedAt': createdAt.toIso8601String(),
      'UpdatedAt': updatedAt.toIso8601String(),
    };
  }
}
