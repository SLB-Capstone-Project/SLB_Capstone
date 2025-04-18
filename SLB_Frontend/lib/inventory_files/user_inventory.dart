import 'package:flutter/material.dart';
import 'package:quiver/collection.dart';
import 'tabbed_inventory.dart';
import 'http_functions.dart' as http_funct;
import 'dart:convert';
import 'dart:io';
import 'associativity.dart';
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
  var productmap = Multimap<String, String>();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
    http_funct.getUserProducts().then((List result) {
      //result contains a list of parts 
      //print(result[0]);
      for(int i = 0; i < result.length; i++) {
        productmap.add("Product ID: ${result[i]['productId']} "
          "ProductName: ${result[i]['productName']}", 
          "Part ID: ${result[i]['partId']} \n"
        "partName: ${result[i]['partName']}");
        product_arr.add("Product ID: ${result[i]['productId']} \n"
          "ProductName: ${result[i]['productName']}");
        part_arr.add( "Part ID: ${result[i]['partId']} \n"
        "partName: ${result[i]['partName']}");
      }
      product_arr = product_arr.toSet().toList();
      print(productmap.toString());
      print(productmap["Product ID: 1 "
          "ProductName: Laptop"]);
      //create new multimap to make multiple parts to a product
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
        backgroundColor: Colors.brown,
        toolbarHeight: 60.0,
        titleTextStyle: const TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color:  Color.fromRGBO(240, 240, 240, 1),
        ),
        leading: IconButton(  
          icon: const Icon(Icons.home),
          color: const Color.fromRGBO(240, 240, 240, 1),
          onPressed: () {
            Navigator.pop(context);
          }
        ),
      bottom: TabBar(
        labelColor: const Color.fromRGBO(240, 240, 240, 1),
        unselectedLabelColor: const Color.fromRGBO(240, 240, 240, 1),
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [ 
          Column (
            children: [
              //TextField(  

              //),           
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: product_arr.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: Text(product_arr[index]),
                        //trailing: PopupMenuExample(),
                        /*Pop(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            PopupMenuExample();
                          }*/
                        
                        onTap: () {
                          String temp = product_arr[index].replaceAll("\n", "");
                          List<String> productList = productmap[temp].toList();
                          print(productList);
                          //print(temp);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProductList(productList: productList)),
                          );
                        }
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
              //TextField(  

              //),
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: part_arr.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: Text(part_arr[index]),
                        //trailing: Icon(Icons.more_vert),
                        
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
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CheckInPage()),
                  );*/
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

enum SampleItem { Parts, Data}

class PopupMenuExample extends StatefulWidget {
  const PopupMenuExample({super.key});

  @override
  State<PopupMenuExample> createState() => _PopupMenuExampleState();
}

class _PopupMenuExampleState extends State<PopupMenuExample> {
  SampleItem? selectedItem;

  @override
  Widget build(BuildContext context) {
    //return Scaffold(
    // appBar: AppBar(title: const Text('PopupMenuButton')),
     // body: Center(
       return PopupMenuButton<SampleItem>(
          initialValue: selectedItem,
          onSelected: (SampleItem item) {
            setState(() {
              selectedItem = item;
            });
          },
          itemBuilder:
              (BuildContext context) => <PopupMenuEntry<SampleItem>>[
                const PopupMenuItem<SampleItem>(value: SampleItem.Parts, child: Text('Parts')),
                const PopupMenuItem<SampleItem>(value: SampleItem.Data, child: Text('Data')),
                //const PopupMenuItem<SampleItem>(value: SampleItem.itemThree, child: Text('Item 3')),
              ],
        );
     // ),
    //);
  }
}