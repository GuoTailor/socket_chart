import 'dart:ui';

import 'package:dio/dio.dart';

class Const {
  static const id = 'id';
  static const username = 'username';
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
    return code == 200 || code == 500;
  },
);
final Dio dio = Dio(options);
