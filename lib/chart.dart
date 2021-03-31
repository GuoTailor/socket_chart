import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_chart/add_room.dart';
import 'package:socket_chart/msg_model.dart';

import 'WebSocketUtility.dart';
import 'const.dart';
import 'full_photo.dart';
import 'loading.dart';
import 'login.dart';
import 'massage.dart';

class Chart extends StatefulWidget {
  final int id;

  const Chart(this.id);

  @override
  _ChartState createState() {
    return _ChartState(id);
  }
}

class _ChartState extends State<Chart> {
  final int id;
  int index = 0;
  int roomId;
  var items = <dynamic>[];
  String title = "";
  String peerAvatar = Const.baseUrl + "/pic1.jpg";
  SharedPreferences prefs;

  _ChartState(this.id);

  @override
  Widget build(BuildContext context) {
    return listView();
  }

  @override
  void initState() {
    super.initState();
    getAllRoom();
  }

  void getAllRoom() async {
    prefs = await SharedPreferences.getInstance();
    var response = await dio.get("/room/find", queryParameters: {"id": id});
    if (response.statusCode == 200) {
      var result = response.data;
      print(result);
      setState(() {
        items = result;
        roomId = result[index]['id'];
        title = result[index]['name'];
      });
    }
  }

  void onTop(int index) {
    setState(() {
      this.index = index;
      roomId = items[index]['id'];
      peerAvatar = Const.baseUrl + "/pic1.jpg";
      title = items[index]['name'];
    });
  }

  selectView(IconData icon, String text, String id) {
    return new PopupMenuItem<String>(
        value: id,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Icon(icon, color: Colors.blue),
            new Text(text),
          ],
        ));
  }

  Widget listView() {
    var list = MaterialApp(
      theme: new ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        buttonColor: Color(0xffe0e0e0),
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: new AppBar(
            title: new Text(title),
            leading: IconButton(
                icon: new Icon(Icons.group_add),
                tooltip: '添加群组',
                onPressed: () async {
                  var result = showSearch(
                      context: context, delegate: CustomSearchDelegate(prefs));
                  print(await result);
                  getAllRoom();
                }),
            centerTitle: true,
            actions: <Widget>[
              new PopupMenuButton<String>(
                itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                  this.selectView(Icons.message, '发起群聊', 'A'),
                  this.selectView(Icons.exit_to_app_outlined, '退出房间', 'B'),
                  this.selectView(Icons.exit_to_app_outlined, '退出登录', 'C'),
                ],
                onSelected: (String action) async {
                  // 点击选项的时候
                  switch (action) {
                    case 'A':
                      //var result = await dio.put("/room/create", queryParameters: {});
                      await AddRoomDialog().show(context, id);
                      getAllRoom();
                      break;
                    case 'B':
                      var result = await dio.get("/room/remove",
                          queryParameters: {
                            "userId": id,
                            "roomId": roomId
                          });
                      if (result.statusCode == 200) {
                        setState(() {
                          index--;
                        });
                        getAllRoom();
                      } else {
                        print(result.data);
                      }
                      break;
                    case 'C':
                      WebSocketUtility().closeSocket();
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new MyApp()),
                      );
                      break;
                  }
                },
              ),
            ],
          ),
          body: Row(children: [
            Container(
                width: 280,
                child: ListView.separated(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: (event) async {
                          if (event.buttons == 2) {
                            await EliminateRoomDialog().show(context, id, roomId);
                            getAllRoom();
                          }
                        },
                        child: ListTile(
                          onTap: () {
                            onTop(index);
                          },
                          tileColor: index == this.index ? Color(0xffe8e8e8) : null,
                          title: Text(
                            '${items[index]['name']}',
                            style: TextStyle(fontSize: 20.0, fontFamily: 'Roboto'),
                          ),
                        )
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                )),
            ChatScreen(roomId: roomId, peerAvatar: peerAvatar)
          ])),
    );

    return list;
  }
}

class ChatScreen extends StatefulWidget {
  final int roomId;
  final String peerAvatar;

  ChatScreen({Key key, @required this.roomId, @required this.peerAvatar})
      : super(key: key);

  @override
  State createState() {
    return ChatScreenState();
  }
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key});

  int id;
  String username;

  int _limit = 20;
  final int _limitIncrement = 20;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  String imageUrl;
  bool isConnect = false;
  WebSocketUtility channel = WebSocketUtility();
  MsgNotifier notifier = MsgNotifier();

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        print("reach the bottom");
        _limit += _limitIncrement;
      });
    }
    if (listScrollController.offset <=
            listScrollController.position.minScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        print("reach the top");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    listScrollController.addListener(_scrollListener);
    isLoading = false;
    imageUrl = '';
    readLocal();
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getInt(Const.id) ?? -1;
    username = prefs.getString(Const.username);
    print(id);

    channel.initWebSocket(
        onOpen: () {
          WebSocketUtility().initHeartBeat();
          setState(() {
            isConnect = true;
          });
        },
        onMessage: (data) {
          print("接受 " + data.toString());
          if (data['order'] == 0) {
            notifier.insert(widget.roomId, 0, Massage.fromJson(data['data']));
          } else if (data['order'] == -10) {
            WebSocketUtility().closeSocket();
            Toast.show(context: context, message: data['data']['msg'] ?? "");
            Navigator.pop(context);
            Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new MyApp()),
            );
          }
        },
        onError: (e) {
          print("error " + e);
          setState(() {
            isConnect = false;
          });
        },
        onDone: () {
          setState(() {
            isConnect = false;
          });
          print("关闭");
        },
        path: "/room?id=$id&username=$username&roomId=${widget.roomId}");
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content != '') {
      textEditingController.clear();
      var message = Massage(this.id, 0, content, '/msg', widget.roomId,
          DateTime.now().millisecondsSinceEpoch);

      setState(() {
        notifier.insert(widget.roomId, 0, message);
      });
      var sndMsg = {'order': 0, 'req': 1, 'data': message.toJson()};
      channel.sendMessage(jsonEncode(sndMsg));
    }
  }

  Widget buildItem(int index, Massage message) {
    bool isLeft = isMessageLeft(index);
    var avatar = Material(
      child: CachedNetworkImage(
        placeholder: (context, url) => Container(
          child: CircularProgressIndicator(
            strokeWidth: 1.0,
            valueColor: AlwaysStoppedAnimation<Color>(Const.themeColor),
          ),
          width: 35.0,
          height: 35.0,
          padding: EdgeInsets.all(10.0),
        ),
        imageUrl: widget.peerAvatar,
        width: 35.0,
        height: 35.0,
        fit: BoxFit.cover,
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(18.0),
      ),
      clipBehavior: Clip.hardEdge,
    );
    var content = message.msgType == 0
        ? Container(
            child: SelectableText(
              message.content,
              style: TextStyle(color: Colors.white),
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(
                color: isLeft ? Const.primaryColor : Const.greyColor2,
                borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
          )
        : Container(
            child: TextButton(
              child: Material(
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Const.themeColor),
                    ),
                    width: 200.0,
                    height: 200.0,
                    padding: EdgeInsets.all(70.0),
                    decoration: BoxDecoration(
                      color: Const.greyColor2,
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Material(
                    child: Image.asset(
                      'images/img_not_available.jpeg',
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
                  imageUrl: message.path,
                  width: 200.0,
                  height: 200.0,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                clipBehavior: Clip.hardEdge,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FullPhoto(url: message.path)));
              },
            ),
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
          );
    var time = Container(
      child: Text(
        DateFormat('M/dd kk:mm:ss')
            .format(DateTime.fromMillisecondsSinceEpoch(message.date)),
        style: TextStyle(
            color: Const.greyColor,
            fontSize: 12.0,
            fontStyle: FontStyle.italic),
      ),
      margin: EdgeInsets.only(left: 50.0, right: 50.0, top: 5.0, bottom: 5.0),
    );
    return Container(
      child: Column(
        children: [
          isLeft
              ? Row(
                  children: [
                    avatar,
                    content,
                  ],
                  mainAxisAlignment: MainAxisAlignment.start,
                )
              : Row(children: [
                  content,
                  avatar,
                ], mainAxisAlignment: MainAxisAlignment.end),
          time
        ],
        crossAxisAlignment:
            isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      ),
    );
  }

  bool isMessageLeft(int index) =>
      (index >= 0 && notifier.getItems(widget.roomId)[index].id != id);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          // In this sample app, CatalogModel never changes, so a simple Provider
          // is sufficient.
          Provider(create: (context) => channel),
          // CartModel is implemented as a ChangeNotifier, which calls for the use
          // of ChangeNotifierProvider. Moreover, CartModel depends
          // on CatalogModel, so a ProxyProvider is needed.
          ChangeNotifierProxyProvider<WebSocketUtility, MsgNotifier>(
            create: (context) => notifier,
            update: (context, socket, notifier) {
              channel = socket;
              this.notifier = notifier;
              return notifier;
            },
          ),
        ],
        child: Container(
          color: Color(0xffe8e8e8),
          width: 984,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  // List of messages
                  buildListMessage(),
                  // Input content
                  buildInput(),
                ],
              ),
              // Loading
              buildLoading()
            ],
          ),
        ));
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const Loading() : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                maxLength: 255,
                maxLines: 4,
                minLines: 3,
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, 0);
                },
                style: TextStyle(color: Const.primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Const.greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),
          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: Const.primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      height: 100.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Const.greyColor2, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget getList(List<Massage> list) {
    if (!isConnect) {
      return Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Const.themeColor)));
    } else {
      return ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemBuilder: (context, index) => buildItem(index, list[index]),
        itemCount: list.length,
        reverse: true,
        controller: listScrollController,
      );
    }
  }

  Widget buildListMessage() {
    return Flexible(
      child: Consumer<MsgNotifier>(
        builder: (context, notifier, child) {
          return getList(notifier.getItems(widget.roomId));
        },
      ),
    );
  }
}
