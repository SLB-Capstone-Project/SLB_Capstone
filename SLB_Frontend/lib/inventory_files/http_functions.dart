
import 'package:flutter/material.dart';
import 'tabbed_inventory.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../globals.dart' as global;

Future<List<String>> getUserParts() async {
  List<String> string_arr = [];
  final String sendUrl = 'http://172.191.111.81:8081/api/components';
  String token = global.token;
  print(token);
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

Future<List<String>> getUserProducts() async {
  List<String> string_arr = [];
  print("getting user products");
  //final uri = Uri.http('172.191.111.81:8081', '/api/categories', {'name': 'Bob Lin'});
  //print(uri);
  final String sendUrl = 'http://172.191.111.81:8081/api/components/borrowed';
  print(global.token);
  final response = await http.get(  
    Uri.parse(sendUrl),
    //uri,
    headers: {
      'Authorization': global.token,
      'Content-Type': 'application/json',
    }
  );
  if(response.statusCode == 200) {
    //print(response.body);
    final responseBody = jsonDecode(response.body);
    List items = responseBody['data'];
    print(items);
    //List temp =  jsonDecode(response.body);
    //print(items);
    for(int i = 0; i < items.length; i++) {
      string_arr.add("Product ID: ${items[i]['productId']} \n"
       "Part ID: ${items[i]['partId']} \n"
       "partName: ${items[i]['partName']}");
      //print(temp[i]);
    }
  }
  /*if(response.statusCode == 200) {
    //print(response.body);
    List temp =  jsonDecode(response.body);
    for(int i = 0; i < temp.length; i++) {
      string_arr.add("Product ID: ${temp[i]['productId']} \n"
       "Number Available: ${temp[i]['numberPartInStock']} \n"
       "Number Checked Out: ${temp[i]['numberPartCheckOut']}");
      //print(temp[i]);
    }
  }*/
  else {
    print(response.statusCode);
    print(response.body);
    //throw Exception('Unable to connect');
  }
  return string_arr;
}

Future<void> borrowProduct() async {
  print("borrowing product");
  final String uri = 'http://172.191.111.81:8081/api/activities/borrow';
  print(global.token);
  final response = await http.post(  
    Uri.parse(uri),
    headers: {
      'Authorization': global.token,
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "part_id": 104
    })
  );
  print(response.body);
  if(response.statusCode == 200) {
    print(response.body);
  }
}
/*Future<void> returnProduct(int id) async {
  final String uri = 'http://172.191.111.81:8081/api/activities/borrow';
  final response = await http.get(  
    Uri.parse(uri),
    //uri,
    headers: {
      //'name': 'Admin',
      'Authorization': global.token,
      'Content-Type': 'application/json',
    }
    body: {
      
    }
  );
  if(response.statusCode == 200) {
    //print(response.body);
    List temp =  jsonDecode(response.body);
    for(int i = 0; i < temp.length; i++) {
      string_arr.add("Product ID: ${temp[i]['productId']} \n"
       "Number Available: ${temp[i]['numberPartInStock']} \n"
       "Number Checked Out: ${temp[i]['numberPartCheckOut']}");
      //print(temp[i]);
    }
  }
  else {
    print(response.statusCode);
    print(response.body);
    //throw Exception('Unable to connect');
  }

}*/
Future<void> deleteProduct(int id) async {
  List<String> string_arr = [];
  final uri = Uri.http('172.191.111.81:8081', '/api/categories', {'id': 1});
  //final uri = Uri.http('172.191.111.81:8081', '/api/categories');
  //final String sendUrl = 'http://172.191.111.81:8081/api/categories/$id';
  String token = global.token;
  //print(token);
  /*final response = await http.delete(  
    //Uri.parse(uri),
    uri,
    headers: {
      'Authorization': token,
      'Content-Type': 'application/json',
    }
  );
  if(response.statusCode == 200) {
    List temp =  jsonDecode(response.body);
    for(int i = 0; i < temp.length; i++) {
      string_arr.add("Product ID: ${temp[i]['productId']} \n"
       "Number Available: ${temp[i]['numberPartInStock']} \n"
       "Number Checked Out: ${temp[i]['numberPartCheckOut']}");
      //print(temp[i]);
    }
  }
  else {
    print(response.statusCode);
    throw Exception('Unable to connect');
  }*/
  //return string_arr;
}