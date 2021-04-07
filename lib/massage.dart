class Massage {
  final int id;
  final int msgType;
  final String content;
  final String path;
  final String name;
  final String avatar;
  final int date;
  final int roomId;

  Massage(this.id, this.msgType, this.content, this.path, this.name, this.avatar, this.roomId, this.date);

  Massage.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        msgType = json['msgType'],
        content = json['content'],
        path = json['path'],
        name = json['name'],
        avatar = json['avatar'],
        date = json['date'],
        roomId = json['roomId'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'msgType': msgType,
        'content': content,
        'path': path,
        'avatar': avatar,
        'name': name,
        'date': date,
        'roomId': roomId,
      };
}
