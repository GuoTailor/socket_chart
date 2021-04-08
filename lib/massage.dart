class Massage {
  final int userId;
  final int msgType;
  final String content;
  final String path;
  final String name;
  final String avatar;
  final int date;
  final int roomId;

  Massage(this.userId, this.msgType, this.content, this.path, this.name, this.avatar, this.roomId, this.date);

  Massage.fromJson(Map<String, dynamic> json)
      : userId = json['userId'],
        msgType = json['msgType'],
        content = json['content'],
        path = json['path'],
        name = json['name'],
        avatar = json['avatar'],
        date = json['date'],
        roomId = json['roomId'];

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'msgType': msgType,
        'content': content,
        'path': path,
        'avatar': avatar,
        'name': name,
        'date': date,
        'roomId': roomId,
      };
}
