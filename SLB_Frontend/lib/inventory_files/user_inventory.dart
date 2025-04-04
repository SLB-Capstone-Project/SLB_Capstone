import 'package:flutter/material.dart';
import 'tabbed_inventory.dart';
import 'http_functions.dart' as http_funct;
import 'dart:convert';
import 'dart:io';
//import '../globals.dart' as global;

class UserInventory extends StatefulWidget {
  const UserInventory({ super.key });
  @override
  State<UserInventory> createState() => _UserInventoryState();
}

class _UserInventoryState extends State<UserInventory> with SingleTickerProviderStateMixin {
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
    http_funct.getUserProducts().then((List result) {
      //result contains a list of parts 
      print(result[0]);
      for(int i = 0; i < result.length; i++) {
        product_arr.add("Product ID: ${result[i]['productId']} \n"
          "ProductName: ${result[i]['productName']}");
       part_arr.add( "Part ID: ${result[i]['partId']} \n"
        "partName: ${result[i]['partName']}");
      }
      product_arr = product_arr.toSet().toList();
      setState(() {});
    });

    /*http_funct.getParts().then((List<String> result) {
      part_arr = result;
      setState(() {});
    });*/
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
          Column (
            children: [
              TextField(  

              ),
              /*FloatingActionButton( 
                child: Text("Borrow product"),
                onPressed: () {
                  http_funct.borrowProduct();
                }
              ),
              FloatingActionButton( 
                child: Text("Return product"),
                onPressed: () {
                  //http_funct.returnProduct();
                }
              ),*/
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: product_arr.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: Text(product_arr[index]),
                        //onTap: () => {remove_index(index)},
                        );
                    },
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                  ),
                ),
              ),
            ]
          ),
          Column (
            children: [
              TextField(  

              ),
              /*FloatingActionButton( 
                child: Text("Borrow product"),
                onPressed: () {
                  http_funct.borrowProduct();
                }
              ),
              FloatingActionButton( 
                child: Text("Return product"),
                onPressed: () {
                  //http_funct.returnProduct();
                }
              ),*/
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: part_arr.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: Text(part_arr[index]),
                        //onTap: () => {remove_index(index)},
                        );
                    },
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                  ),
                ),
              ),
            ]
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