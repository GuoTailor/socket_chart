import 'dart:collection';

import 'package:flutter/cupertino.dart';

import 'massage.dart';

class MsgNotifier extends ChangeNotifier {

  HashMap<int, List<Massage>> _mapMessage = HashMap();

  void add(int roomId, Massage msg) {
    var list = _mapMessage[roomId];
    if(list == null) {
      list = [];
      _mapMessage[roomId] = list;
    }
    list.add(msg);
    notifyListeners();
  }

  void insert(int roomId, int index, Massage msg) {
    var list = _mapMessage[roomId];
    if(list == null) {
      list = [];
      _mapMessage[roomId] = list;
    }
    list.insert(index, msg);
    notifyListeners();
  }

  List<Massage> getItems(int roomId) {
    var list = _mapMessage[roomId];
    if(list == null) {
      list = [];
      _mapMessage[roomId] = list;
    }
    return list;
  }

}