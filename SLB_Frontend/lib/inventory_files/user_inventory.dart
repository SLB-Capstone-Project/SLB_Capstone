import 'package:flutter/material.dart';
import 'windows/productList.dart';
import 'windows/partIdList.dart';
import 'windows/partList.dart';
//mport 'http_functions.dart' as http_funct;
//import 'associativity.dart';
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
    Tab(text: 'PartIDs'),
  ];

  //List<String> part_arr = [];
 
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          ProductList(),
          PartList(product:0, specific:false),
          PartIdList(product:0, part:0, specific:false),
        ],
      ),
    );
  }
}
