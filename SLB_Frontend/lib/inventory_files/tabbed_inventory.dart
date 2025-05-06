import 'package:flutter/material.dart';
import 'tabbed_inventory.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../globals.dart' as global;

Future<List<String>> getParts() async {
  List<String> string_arr = [];
  final String sendUrl = 'http://4.227.176.4:8081/api/components';
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

Future<List<String>> getProducts() async {
  List<String> string_arr = [];
  final String sendUrl = 'http://4.227.176.4:8081/api/categories';
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
      string_arr.add("Product ID: ${temp[i]['productId']} \n"
       "Number Available: ${temp[i]['numberPartInStock']} \n"
       "Number Checked Out: ${temp[i]['numberPartCheckOut']}");
      //print(temp[i]);
    }
  }
  else {
    print(response.statusCode);
    throw Exception('Unable to connect');
  }
  return string_arr;
}

Future<void> deleteProduct(int id) async {
  List<String> string_arr = [];
  final uri = Uri.http('4.227.176.4:8081', '/api/categories', {'id': 1});
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

Future<void> addProduct(int id, String name) async {
  List<String> string_arr = [];
  //final uri = Uri.http('172.191.111.81:8081', '/api/categories', {'id': 1});
  final uri = Uri.http('4.227.176.4:8081', '/api/categories');
  //final String sendUrl = 'http://172.191.111.81:8081/api/categories/';
  String token = global.token;
  //print(token);
  final response = await http.post(  
    //Uri.parse(uri),
    uri,
    headers: {
      'Authorization': token,
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "productId": id,
      "productName": name,
      "numberPartCheckOut": 0,
      "numberPartInStock": 0,
      "totalCost": 0
    })
  );
  if(response.statusCode == 200) {
    /*List temp =  jsonDecode(response.body);
    for(int i = 0; i < temp.length; i++) {
      string_arr.add("Product ID: ${temp[i]['productId']} \n"
       "Number Available: ${temp[i]['numberPartInStock']} \n"
       "Number Checked Out: ${temp[i]['numberPartCheckOut']}");
      //print(temp[i]);
    }*/
  }
  else {
    print(response.statusCode);
    throw Exception('Unable to connect');
  }
}

class TabbedInventory extends StatefulWidget {
  const TabbedInventory({ super.key });
  @override
  State<TabbedInventory> createState() => _TabbedInventoryState();
}

class _TabbedInventoryState extends State<TabbedInventory> with SingleTickerProviderStateMixin {
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Products'),
    Tab(text: 'Parts'),
  ];

  List<String> part_arr = [];
  List<String> product_arr = [];
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
    getProducts().then((List<String> result) {
      product_arr = result;
      setState(() {});
    });

    getParts().then((List<String> result) {
      part_arr = result;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }  

  void remove_index(int index) {
    product_arr.removeAt(index);
    //deleteProduct(1);
    //addProduct(10, "shoe");
    setState(() {});
  }

   void remove_part_index(int index) {
    part_arr.removeAt(index);
    //deleteProduct(1);
    //addProduct(10, "shoe");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory'),
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [ 
          Container(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: product_arr.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: Text(product_arr[index]),
                  onTap: () => {remove_index(index)},
                  );
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(),
            ),
          ),
          Container (  
            //child: Column( 
            child: ListView.separated(  
              padding: const EdgeInsets.all(8),
              itemCount: part_arr.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: Text(part_arr[index]),
                  onTap: () => {remove_part_index(index)},
                  );
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(),
            ),
          ),
        ],
      ),
    );
  }
}


class InventoryTile extends StatefulWidget {
  final String tileString;
  const InventoryTile({super.key, required this.tileString});

  @override
  State<InventoryTile> createState() => _InventoryTileState();
}

class _InventoryTileState extends State<InventoryTile> {
  //final String tileString;
  bool logout = false;

  @override
  Widget build(BuildContext context) {
    return Container (
      child: Card(
        //height: 50,
        //color: Colors.amber[colorCodes[index]],
        clipBehavior: Clip.hardEdge,
        child: InkWell( 
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            logout = !logout;
            setState(() {});
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(widget.tileString),
              //Text('Entry ${history_arr[index]}'),
              logout ? FloatingActionButton(  
                onPressed: () {
                  //sendData(widget.tileString);
                },
                child: Text('Checkout'),
              ) : Container(),
            ]
          ),
        ),
      )
    );
  }
}
