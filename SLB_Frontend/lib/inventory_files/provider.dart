import 'dart:collection';

import 'package:flutter/material.dart';
import 'http_functions.dart' as http_funct;
import 'dart:core';


class UserProducts extends ChangeNotifier {
  List<String> part_id_arr = [];
  List<String> part_arr = [];
  List<int> products = [];

  //var part = Map<int, List<Map<String, dynamic>>>; //maps part to part information
  var partInfo = Map<int, List<Map<String, int>>>(); //maps the information associated to each partId
  //List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> parts = [];
  List<Map<String, dynamic>> partId = [];

  var productToPart = <int, Set<int>>{}; //map product to parts
  var partToId = <String, Set<int>>{}; //map product and part to partId

  //UnmodifiableListView<int> get getProduct => UnmodifiableListView(products);
  UnmodifiableListView<String> get getPart => UnmodifiableListView(part_arr);
  UnmodifiableListView<String> get getPartId => UnmodifiableListView(part_id_arr);

  int get getProductLength => products.length;

  void updateInventory() {
    //print("Called from homepage");
    var temp_product = <int>{};
    http_funct.getUserProducts().then((List result) {
      //print("Result ${result}");
      for(int i = 0; i < result.length; i++) {
        int productId = result[i]['productId'];
        int part = result[i]['partNumber'];
        int partId = result[i]['partId'];
        temp_product.add(productId);
        var temp_partId = {
          'id': partId,
          //'partName': partName,
        };
        partInfo.update(partId, (value) => value + [temp_partId], ifAbsent: () => [temp_partId]);

        productToPart.update(productId, (value) => (value.toList() + [part]).toSet(), ifAbsent: () => {part});
        partToId.update("$productId $part", (value) => (value.toList() + [partId]).toSet(), ifAbsent: () => {partId});
      }
      //product_arr = productToPart.keys.toList();
      products = temp_product.toList();
      products.sort();
     });
     notifyListeners();
     //print(productToPart);
  }

  /*List<int> getAllProducts() {
    return products;
  }*/

  int getProduct(int index) {
    return products[index];
  }

  List<int>? getPartList(int product) {
    List<int>? partList = productToPart[product]?.toList() ?? []; //gets list of parts corresponding to given product
    return partList;
  }

  List<int>? getPartIdList(int product, int part) {
    List<int>? partIdList = partToId["$product $part"]?.toList() ?? []; //gets list of partId's corresponding to given product 
    return partIdList;
  }
}