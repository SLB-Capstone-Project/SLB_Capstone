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
    /*return Scaffold(
      appBar: AppBar(
        title: Text('Inventory'),
        backgroundColor: const Color.fromRGBO(38, 38, 50, 1),
        toolbarHeight: 56.0,
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
      /*bottom: TabBar(
        labelColor: const Color.fromRGBO(240, 240, 240, 1),
        unselectedLabelColor: const Color.fromRGBO(240, 240, 240, 1),
          controller: _tabController,
          tabs: myTabs,
        ),*/
      ),
      body: */
    return Material( 
      color: const Color.fromRGBO(10, 10, 10, 1),
      child: Column( 
      children: [
        Expanded(
          //height: 500,
          child: TabBarView(
          controller: _tabController,
          children: [ 
            ProductList(),
            //PartList(product:0, specific:false),
            PartList(product: null, specific: false),
            PartIdList(product: null, part: null, specific:false),
            //PartIdList(specific:false),
          ],
        )),
        navBar()
      ]
    ));
  }

  Widget navBar() {
    return 
    Container( 
      color: const Color.fromRGBO(10, 10, 10, 1),
      child: Container(  
      height: 48,
      decoration: BoxDecoration( 
        borderRadius: BorderRadius.horizontal(  
          right: Radius.circular(16),
          left: Radius.circular(16),
        ),
        color: const Color.fromRGBO(38, 38, 50, 1),
      ),
      //color: const Color.fromRGBO(100, 100, 100, 1),
      margin: EdgeInsets.all(32.0),
      child: TabBar(  
        controller: _tabController,
        tabs: myTabs,
        labelColor: const Color.fromRGBO(240, 240, 240, 1),
        unselectedLabelColor: const Color.fromRGBO(240, 240, 240, 1),
        dividerColor: Colors.transparent,
      )
    ));
  }
}
