import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';

class Const {
  static const userId = 'userId';
  static const username = 'username';
  static const avatarUrl = 'avatarUrl';
  static const search = 'search';
  static const themeColor = Color(0xfff5a623);
  static const primaryColor = Color(0xff203152);
  static const greyColor = Color(0xffaeaeae);
  static const greyColor2 = Color(0xff12b7f5);
  //static const baseUrl = "http://47.107.178.147:81";
  static const baseUrl = "http://localhost:80";
}


final BaseOptions options = BaseOptions(
  baseUrl: Const.baseUrl,
  connectTimeout: 5000,
  receiveTimeout: 3000,
  receiveDataWhenStatusError: true,
  validateStatus: (code) {
    return code == 200 || code == 500 || code == 400;
  },
);
final Dio dio = Dio(options);

Future<XFile> getImage() async {
  final XTypeGroup typeGroup = XTypeGroup(
    label: 'images',
    extensions: ['jpg', 'png'],
  );
  final List<XFile> files = await openFiles(acceptedTypeGroups: [typeGroup]);
  if (files.isEmpty) {
    // Operation was canceled by the user.
    return null;
  }
  return files[0];
}

Future<Response<T>> uploadFile<T>(XFile file) async {
  FormData formData = FormData.fromMap({
    "file": await MultipartFile.fromFile(file.path, filename: Uri.encodeComponent(file.name)),
  });
  return dio.post("/user/upload", data: formData);
}