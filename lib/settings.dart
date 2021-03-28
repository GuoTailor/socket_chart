import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_chart/const.dart';

import 'add_room.dart';

class ChatSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '注册',
          style: TextStyle(color: Const.primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController controllerNickname;
  TextEditingController controllerAboutMe;

  SharedPreferences prefs;

  int id;
  String username = '';
  String password = '';
  String photoUrl = '';

  bool isLoading = false;
  File avatarImageFile;

  final FocusNode focusNodeNickname = FocusNode();
  final FocusNode focusNodeAboutMe = FocusNode();

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getInt('id') ?? -1;
    username = prefs.getString('nickname') ?? '';
    password = prefs.getString('aboutMe') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';

    controllerNickname = TextEditingController(text: username);
    controllerAboutMe = TextEditingController(text: password);

    // Force refresh input
    setState(() {});
  }

  Future getImage() async {/*
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

    File image = File(pickedFile.path);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }*/
    //uploadFile();
  }

  Future<void> handleUpdateData() async {
    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();

    setState(() {
      isLoading = true;
    });
    var result = await dio.post("/user/register", data: jsonEncode(<String, String>{
      'username': username,
      'password': password
    }));
    if (result.statusCode == 200) {
      Navigator.of(context).pop();
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(title: Text("注册成功"),);
          }
      );
    } else {
      focusNodeNickname.requestFocus();
      focusNodeAboutMe.requestFocus();
      setState(() {
        isLoading = false;
      });
      Toast.show(context: context, message: "注册失败");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Avatar
              Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      (avatarImageFile == null)
                          ? (photoUrl != ''
                              ? Material(
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Const.themeColor),
                                      ),
                                      width: 90.0,
                                      height: 90.0,
                                      padding: EdgeInsets.all(20.0),
                                    ),
                                    imageUrl: photoUrl,
                                    width: 90.0,
                                    height: 90.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(45.0)),
                                  clipBehavior: Clip.hardEdge,
                                )
                              : Icon(
                                  Icons.account_circle,
                                  size: 90.0,
                                  color: Const.greyColor,
                                ))
                          : Material(
                              child: Image.file(
                                avatarImageFile,
                                width: 90.0,
                                height: 90.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(45.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: Const.primaryColor.withOpacity(0.5),
                        ),
                        onPressed: getImage,
                        padding: EdgeInsets.all(30.0),
                        splashColor: Colors.transparent,
                        highlightColor: Const.greyColor,
                        iconSize: 30.0,
                      ),
                    ],
                  ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20.0),
              ),

              // Input
              Column(
                children: <Widget>[
                  // Username
                  Container(
                    child: Text(
                      '用户名',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Const.primaryColor),
                    ),
                    margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                  ),
                  Container(
                    width: 200,
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: Const.primaryColor),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '用户名',
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Const.greyColor),
                        ),
                        controller: controllerNickname,
                        onChanged: (value) {
                          username = value;
                        },
                        focusNode: focusNodeNickname,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),

                  // About me
                  Container(
                    child: Text(
                      '密码',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Const.primaryColor),
                    ),
                    margin: EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                  ),
                  Container(
                    width: 200,
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: Const.primaryColor),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '...',
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Const.greyColor),
                        ),
                        controller: controllerAboutMe,
                        onChanged: (value) {
                          password = value;
                        },
                        focusNode: focusNodeAboutMe,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),

              // Button
              Container(
                child: ElevatedButton(
                  onPressed: handleUpdateData,
                  child: Text(
                    '注册',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
              ),
            ],
          ),
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
        ),

        // Loading
        Positioned(
          child: isLoading
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Const.themeColor)),
                  ),
                  color: Colors.white.withOpacity(0.8),
                )
              : Container(),
        ),
      ],
    );
  }
}
