import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'const.dart';

class AddRoomDialog {
  Future<bool> show(BuildContext context1, int userId) async {
    String roomName;
    String description;
    return showDialog<bool>(
      barrierDismissible: false,
      context: context1,
      builder: (context) {
        return AlertDialog(
          title: Text("添加房间"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(
                  hintText: '房间的名字',
                  labelText: '房间名',
                ),
                onChanged: (text) {
                  roomName = text;
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  hintText: '房间的描述',
                  labelText: '描述',
                ),
                onChanged: (text) {
                  description = text;
                },
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("取消"),
              onPressed: Navigator.of(context).pop, // 关闭对话框
            ),
            TextButton(
              child: Text("添加"),
              onPressed: () async {
                print(roomName + " " + description);
                var result = await dio.put("/room/create", queryParameters: {
                  'userId': userId,
                  'name': roomName,
                  'description': description
                });
                print(result);
                if (result.statusCode == 200) {
                  print(result.statusCode);
                  Toast.show(context: context, message: "创建成功!");
                  Navigator.of(context).pop();
                } else {
                  Toast.show(context: context, message: "创建失败!");
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class EliminateRoomDialog {
  Future<bool> show(BuildContext context1, int userId, int roomId) async {
    return showDialog<bool>(
      barrierDismissible: false,
      context: context1,
      builder: (context) {
        return AlertDialog(
          title: Text("删除房间"),
          actions: <Widget>[
            TextButton(
              child: Text("取消"),
              onPressed: Navigator.of(context).pop, // 关闭对话框
            ),
            TextButton(
                child: Text("确定"),
                onPressed: () async {
                  var result = await dio.get("/room/delete",
                      queryParameters: {'userId': userId, 'roomId': roomId});
                  if (result.statusCode == 200) {
                    Toast.show(context: context, message: "删除成功");
                  } else {
                    Toast.show(context: context, message: "删除失败");
                  }
                  Navigator.of(context).pop(); // 关闭对话框
                }),
          ],
        );
      },
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final SharedPreferences prefs;

  CustomSearchDelegate(this.prefs);

  var isAdd = false;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: '返回',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, isAdd);
      },
    );
  }

  Future _fetchPosts() async {
    print(query);
    var response =
        await dio.get("/room/search", queryParameters: {"name": query});
    print(response.data);
    if (response.statusCode == 200) {
      var list = prefs.getStringList(Const.search) ?? [];
      list.insert(0, query);
      while (list.length > 10) {
        list.removeLast();
      }
      prefs.setStringList(Const.search, list.toSet().toList());
      return response.data;
    }
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text('请输入关键字'));
    }

    return FutureBuilder(
      future: _fetchPosts(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final post = snapshot.data;

          return ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(post[index]['name'], maxLines: 1),
                subtitle: Text(post[index]['description'], maxLines: 3),
                onTap: () async {
                  var userId = prefs.getInt('id') ?? -1;
                  var response = await dio.put("/room/join", queryParameters: {
                    "userId": userId,
                    "roomId": post[index]['id']
                  });
                  isAdd = response.statusCode == 200;
                  return showDialog<bool>(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                            "添加房间 ${post[index]['name']} ${response.data}"),
                      );
                    },
                  );
                },
              );
            },
            itemCount: post.length,
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var list = prefs.getStringList(Const.search) ?? [];
    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(list[index]),
          onTap: () {
            query = list[index];
          },
        );
      },
      itemCount: list.length,
    );
  }
}

class Toast {
  static void show({@required BuildContext context, @required String message}) {
    //1、创建 overlayEntry
    OverlayEntry overlayEntry = new OverlayEntry(builder: (context) {
      return new Positioned(
          top: MediaQuery.of(context).size.height * 0.8,
          child: new Material(
            color: Colors.transparent,
            child: new Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: new Center(
                child: new Card(
                  child: new Padding(
                    padding: EdgeInsets.all(8),
                    child: new Text(message),
                  ),
                  color: Colors.grey.withOpacity(1),
                ),
              ),
            ),
          ));
    });

    //插入到 Overlay中显示 OverlayEntry
    Overlay.of(context).insert(overlayEntry);

    //延时两秒，移除 OverlayEntry
    new Future.delayed(Duration(seconds: 2)).then((value) {
      overlayEntry.remove();
    });
  }
}
