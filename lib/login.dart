import 'dart:convert';

/// Flutter code sample for TextFormField
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_chart/register.dart';

import 'chart.dart';
import 'const.dart';
import 'loading.dart';

void main() => runApp(MyApp());

/// This is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  String info = "";
  bool isLoading = false;
  String username;
  String password;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString(Const.username);
    });
  }

  Widget build(BuildContext context) {
    var input = Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        // Pressing space in the field will now move to the next field.
        LogicalKeySet(LogicalKeyboardKey.enter): const NextFocusIntent(),
      },
      child: FocusTraversalGroup(
        child: Form(
          autovalidateMode: AutovalidateMode.always,
          onChanged: () {
            Form.of(primaryFocus.context).save();
          },
          child: Wrap(
            direction: Axis.vertical,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints.tight(const Size(200, 80)),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: '你的账号?',
                      labelText: 'Name *',
                    ),
                    onSaved: (String value) {
                      username = value;
                    },
                    validator: (String value) {
                      return value.trim().length == 0 ? '请输入账号' : null;
                    },
                    controller: TextEditingController.fromValue(
                        TextEditingValue(text: username ?? "")),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints.tight(const Size(200, 80)),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.lock),
                      hintText: '你的密码?',
                      labelText: 'Password *',
                    ),
                    obscureText: true,
                    onSaved: (String value) {
                      password = value;
                    },
                    validator: (String value) {
                      return value.trim().length < 6 ? '请输入密码' : null;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    var button = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () async {
            setState(() {
              isLoading = true;
            });

            var prefs = await SharedPreferences.getInstance();
            var response;
            try {
              response = await dio.post("/user/login",
                  data: jsonEncode(<String, String>{
                    'username': username,
                    'password': password
                  }));
            } catch (e) {
              setState(() {
                isLoading = false;
                info = "网络错误";
              });
            }
            if (response.statusCode == 200) {
              var user = response.data;
              var id = user['id'];
              print(user);
              setState(() {
                isLoading = false;
                info = "登录成功";
              });
              prefs.setInt(Const.id, id);
              prefs.setString(Const.username, user['username']);
              prefs.setString(Const.avatarUrl, user['avatarUrl']);
              Navigator.pop(context);
              Navigator.push(
                context,
                new MaterialPageRoute(builder: (context) => new Chart(id)),
              );
            } else {
              print(response.data);
              setState(() {
                isLoading = false;
                info = "登录失败，用户名或密码错误";
              });
            }
          },
          child: new Text('登录'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => new ChatSettings()),
            );
          },
          child: new Text('注册'),
        ),
      ],
    );
    return Material(
      child: Card(
        elevation: 8,
        margin: EdgeInsets.only(left: 300, top: 20, right: 300, bottom: 20),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text(
            "Socket 聊天室",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              fontSize: 30,
            ),
          ),
          input,
          Stack(children: [
            Positioned(
              child: isLoading
                  ? const Loading()
                  : Text(
                      info,
                      style: TextStyle(color: Colors.red),
                    ),
            )
          ]),
          button,
        ]),
      ),
    );
  }
}
