import 'dart:collection';

import 'package:flutter/material.dart';
import 'http_functions.dart' as http_funct;
import 'dart:core';


class UserProducts extends ChangeNotifier {
  List<int> products = [];
  List<String> parts = [];
  List<int> partIds = [];

  //var part = Map<int, List<Map<String, dynamic>>>; //maps part to part information
  var partInfo = Map<int, List<Map<String, int>>>(); //maps the information associated to each partId
  //List<Map<String, dynamic>> products = [];

  var productToPart = <int, Set<String>>{}; //map product to parts
  var partToId = <String, Set<int>>{}; //map product and part to partId

  int get getProductLength => products.length;
  int get getPartLength => parts.length;
  int get getPartIdLength => partIds.length;

  void updateInventory() {
    //print("Called from homepage");
    http_funct.getUserProducts().then((List result) {
      //print("Result ${result}");
      for(int i = 0; i < result.length; i++) {
        int productId = result[i]['productId'];
        int part = result[i]['partNumber'];
        int partId = result[i]['partId'];
        var temp_partId = {
          'id': partId,
          //'partName': partName,
        };
        //partInfo.update(partId, (value) => value + [temp_partId], ifAbsent: () => [temp_partId]);

        productToPart.update(productId, (value) => (value.toList() + ["$productId $part"]).toSet(), ifAbsent: () =>{"$productId $part"});
        partToId.update("$productId $part", (value) => (value.toList() + [partId]).toSet(), ifAbsent: () => {partId});

        products.add(productId);
        parts.add("$productId $part");
        partIds.add(int.parse("$productId$part$partId"));
      }
      products = products.toSet().toList();
      parts = parts.toSet().toList();
      partIds = partIds.toSet().toList();
     
      products.sort();
      parts.sort();
      partIds.sort();
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
  UnmodifiableListView<String> get getAllParts => UnmodifiableListView(parts);
  UnmodifiableListView<int> get getAllPartIds => UnmodifiableListView(partIds);

  List<String>? getPartList(int product) {
    List<String>? partList = productToPart[product]?.toList() ?? []; //gets list of parts for product
    return partList;
  }

  List<int>? getPartIdList(int product, int part) {
    List<int>? partIdList = partToId["$product $part"]?.toList() ?? []; //gets list of partId's for product/part  
    return partIdList;
  }

  int getNumParts(int product) {
    return productToPart[product]?.toList().length ?? 0;
  }

  int getNumPartIds(String productPart) {
    return partToId[productPart]?.toList().length ?? 0;
  }
}