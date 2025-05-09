import 'dart:collection';

import 'package:flutter/material.dart';
import 'http_functions.dart' as http_funct;
import 'dart:core';


class UserHistory extends ChangeNotifier {
  List<Map<String, dynamic>> history = [];
  List<int> products = [];
  List<int> parts = [];
  List<String> actions = [];
  List<String> times = [];

  void getUserHistory() {
    http_funct.getUserHistory().then((List result) {
      for(int i = 0; i < result.length; i++) {
        int productId = result[i]['productId'];
        //int part = result[i]['partNumber'];
        int partId = result[i]['partId'];
        String? action = result[i]['action'];
        String? time = result[i]['operateTime'];
        products.add(productId);
        parts.add(partId);
        //actions.add(action);
        //times.add(time);
        history.add(  
          {
            'product': productId,
            'part': partId,
            'action': action,
            'time': time,
          }
        );
      }
     });
     notifyListeners();
  }

  /*List<int> getAllProducts() {
    return products;
  }*/

  int getProduct(int index) {
    return products[index];
  }

  /*int getParts(int index) {
    return parts[index];
  }*/

  UnmodifiableListView<int> get getAllProduct => UnmodifiableListView(products);
  UnmodifiableListView<int> get getAllParts => UnmodifiableListView(parts);
  UnmodifiableListView<String> get getAllActions => UnmodifiableListView(actions);
  UnmodifiableListView<String> get getAllTimes => UnmodifiableListView(times);

  UnmodifiableListView<Map<String, dynamic>> get getAllHistory => UnmodifiableListView(history);
}