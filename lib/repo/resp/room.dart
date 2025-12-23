class RoomInfo {
  final String id;
  final String name;
  final String topic;
  final String avatarUrl;
  final int memberCount;

  RoomInfo({
    required this.id,
    required this.name,
    this.topic = '',
    this.avatarUrl = '',
    this.memberCount = 0,
  });

  factory RoomInfo.fromJson(Map<String, dynamic> json) => RoomInfo(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    topic: json['topic'] as String? ?? '',
    avatarUrl: json['avatarUrl'] as String? ?? '',
    memberCount: json['memberCount'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'topic': topic,
    'avatarUrl': avatarUrl,
    'memberCount': memberCount,
  };
}
