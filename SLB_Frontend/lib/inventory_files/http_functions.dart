
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../globals.dart' as global;

Future<List<String>> getUserParts() async {
  List<String> string_arr = [];
  final String sendUrl = 'http://172.191.111.81:8081/api/components/borrowed';
  String token = global.token;
  final response = await http.get(  
    Uri.parse(sendUrl),
    headers: {
      'Authorization': token,
      'Content-Type': 'application/json',
    }
  );
  if(response.statusCode == 200) {
    List temp =  jsonDecode(response.body);
    for(int i = 0; i < temp.length; i++) {
      string_arr.add("Part ID: ${temp[i]['partId']} \n Status: ${temp[i]['status']}");
      //print(temp[i]);
    }
  }
  else {
    print(response.statusCode);
    throw Exception('Unable to connect');
  }
  return string_arr;
}

Future<List> getUserProducts() async {
  List items = [];
  print("getting user products");
  final String sendUrl = 'http://4.227.176.4:8081/api/components/borrowed';
  final response = await http.get(  
    Uri.parse(sendUrl),
    //uri,
    headers: {
      'Authorization': global.token,
      'Content-Type': 'application/json',
    }
  );
  if(response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    items = responseBody['data'];
    //print(items);
  }
  else {
    print(response.statusCode);
    print(response.body);
    //throw Exception('Unable to connect');
  }
  /*items = [
    {'productId': 1, 'partNumber': 01, 'partId': 00},
    {'productId': 1, 'partNumber': 01, 'partId': 01},
    {'productId': 1, 'partNumber': 02, 'partId': 00},
    {'productId': 1, 'partNumber': 02, 'partId': 01},
    {'productId': 1, 'partNumber': 03, 'partId': 00},
    {'productId': 1, 'partNumber': 03, 'partId': 01},
    {'productId': 1, 'partNumber': 03, 'partId': 02},
    {'productId': 1, 'partNumber': 03, 'partId': 03},
    {'productId': 2, 'partNumber': 00, 'partId': 03},
    {'productId': 2, 'partNumber': 04, 'partId': 03},
    //{'productId': 1, 'partNumber': 04, 'partId': 03},
  ];*/
  return items;
}

Future<List> getUserHistory() async {
  List items = [];
  print("getting user history");
  /*final String sendUrl = 'http://172.191.111.81:8081/api/activities';
  final response = await http.get(  
    Uri.parse(sendUrl),
    headers: {
      'Authorization': global.token,
      'Content-Type': 'application/json',
    }
  );
  if(response.statusCode == 200) {
    //print(response.body);
    final responseBody = jsonDecode(response.body);
    items = responseBody['data'];
    for(int i = 0; i <   items.length; i++) {
      global.historyList.insert(0, "Product ID: ${items[i]['productId']}"
        "Part ID ${items[i]['partId']}"
        "Action: ${items[i]['action']}"
        "Time : ${items[i]['operateTime']}");
    }
  }
  else {
    print(response.statusCode);
    print(response.body);
    //throw Exception('Unable to connect');
  }*/
  return items;
}