import 'package:flutter/material.dart';
import 'dart:math';
//import 'package:namer_app/data_analysis.dart';
import 'package:flutter/gestures.dart';
import 'package:namer_app/login_files/login_screen.dart';
//import 'inventory.dart';
//import 'tabbed_inventory.dart';
import '../checkin_files/checkin_page.dart';
import '../inventory_files/user_inventory.dart';
import 'package:provider/provider.dart';
import '../admin/admin_main.dart';
//import 'package:http/http.dart' as http;
import '../globals.dart' as global;
import '../inventory_files/http_functions.dart' as http_funct;
import '../inventory_files/provider.dart' as inventory_provider;
import 'provider.dart' as history_provider;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override 
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  /*List<String> historyList = <String>['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5', 'Item 6', 'Item 7', 'Item 8', 'Item 9', 'Item 10'];*/
  //List<String> historyList = [];

  @override
  void initState() {
    super.initState();
    http_funct.getUserHistory().then((List result) {
      //result contains a list of parts 
      //print(result[0]);
      /*for(int i = 0; i <   result.length; i++) {
        global.historyList.insert(0, "Product ID: ${result[i]['productId']} \n"
          "Part ID ${result[i]['partId']} \n"
          "Action: ${result[i]['action']} \n"
          "Time : ${result[i]['operateTime']}");
      }*/
      //product_arr = product_arr.toSet().toList();
      setState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: const Color.fromRGBO(10, 10, 10, 1),
      //labelColor: const Color.fromRGBO(240, 240, 240, 1),
      appBar: AppBar(
        title: Text('Home Page'),
        backgroundColor: Colors.brown,
        toolbarHeight: 60.0,
        titleTextStyle: const TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromRGBO(10, 10, 10, 1),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 120, // Smaller height
              color: Colors.brown,
              child: Padding(
                padding: EdgeInsets.only(top: 80, left: 16), // Top + left padding
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            ListTile(
              leading: Icon(Icons.inventory, color: Colors.white),
              title: Text('Inventory', style: TextStyle(color: Colors.white)),
              onTap: () {
                Provider.of<inventory_provider.UserProducts>(context, listen: false).updateInventory();
                Navigator.pop(context); // Close the drawer first
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserInventory()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.admin_panel_settings, color: Colors.white),
              title: Text('Admin', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManagementSelectionPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.scanner, color: Colors.white),
              title: Text('Scanner', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CheckInPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.data_array_rounded, color: Colors.white),
              title: Text('Data', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                /*Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DataAnalysis()),
                );*/
              },
            ),
            ListTile(
              leading: Icon(Icons.logout_rounded, color: Colors.white),
              title: Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [ 
          HomePageList(),
          ]
        ),
    );
  }


  /*Widget navBar() {
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
  }*/
}

class HomePageList extends StatelessWidget {
  List<Map<String, String>> homePageList = [
    {'title': 'Recent Activity', 'card_name': 'history'},
    {'title': 'Inventory', 'card_name': 'inventory'},
    {'title': 'Notifications', 'card_name': 'notifications'},
    ];
  
  /*Map<String, List<dynamic>> map = [

  ];*/
  /*List<Map<String, String>> userHistory = [
    {'title': 'History 1', },
    {'title': 'History 2', },
       {'title': 'History 1', },
    {'title': 'History 2', },
       {'title': 'History 1', },
    {'title': 'History 2', },
       {'title': 'History 1', },
    {'title': 'History 2', },
  ];*/

  /*List<Map<String,String>> notifications = [
    {'title': 'notification 1'},
    {'title': 'notification 2'},
  ];*/
  
  HomePageList({super.key});

  /*void check_inventoryList() {
    print(inventoryList);
    print(inventoryList.length);
  }*/

  @override
  Widget build(BuildContext context) {
    //return Padding(
      //padding: EdgeInsets.all(8.0),
    return Flexible(
        child: Padding(
          padding: EdgeInsets.all(8.0),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                  //return InventoryCard(tileString: inventoryList[index]);
                  var card_name = homePageList[index]['card_name'];
                  List list = [];
                  if(card_name == 'history') {
                    list = Provider.of<history_provider.UserHistory>(context, listen: false).getAllHistory;
                  }
                  else if(card_name == 'notifications') {
                    //list = notifications;
                  }
                  if(card_name == 'inventory') {
                    return inventoryTile();
                  }
                  else {
                    return Card(
                      color: const Color.fromRGBO(22, 22, 30, 1),
                      child: Column( 
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                              style: TextStyle(fontSize: 18, color: const Color.fromRGBO(240, 240, 240, 1)),
                              homePageList[index]['title'] ?? ""
                              ),
                            )
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: SizedBox(
                                height: min(56*list.length.toDouble() + 8, 56*3+8),
                                child: ListView.builder(
                                  //padding: const EdgeInsets.all(8.0),
                                  itemCount: list.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Card(
                                      color:const Color.fromRGBO(30, 30, 38, 1),
                                      child: ListTile(  
                                        //tileColor: const Color.fromRGBO(30, 30, 38, 1),
                                        title: Text(style: TextStyle(color: const Color.fromRGBO(240, 240, 240, 1)),
                                          list[index]['part'].toString()),
                                        leading: Text(style: TextStyle(color: const Color.fromRGBO(240, 240, 240, 1)),
                                          list[index]['action'].toString()),
                                        subtitle: Text(style: TextStyle(color: const Color.fromRGBO(240, 240, 240, 1)),
                                          list[index]['time'].toString()),
                                      )
                                    );
                                  },
                                ),
                              )
                            )
                          )
                          /*ListTile(  
                          /*leading: CircleAvatar( 
                            foregroundColor: const Color.fromRGBO(240, 240, 240, 1),
                            backgroundColor: const Color.fromRGBO(60, 61, 55, 1),
                            child: Text(
                              formattedText[0].substring(0, 3),
                              //selectionColor: Color.fromRGBO(240, 240, 240, 1),
                            ),
                          ),*/
                          tileColor:const Color.fromRGBO(22, 22, 30, 1),
                          //title: Text(homePageList[index]['title'] ?? ""),
                          //subtitle: Text(formattedText[1]),
                          textColor: const Color.fromRGBO(240, 240, 240, 1),
                          /*onTap: () {
                            /*widget.hidden = !widget.hidden;
                            print(widget.hidden);
                            /*if(widget.hidden == false) {
                              return buildContainer();
                            }*/
                            setState() {}; */
                            //String temp = product_arr[index].replaceAll("\n", "");
                            int? product = funct(index);
                            List<int> parts = funct2(product);
                            //print(parts);
                            //print(temp);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProductList(product: product, partList: parts)),
                            );
                          }*/
                          
                          ),*/
                        ]
                      )
                    );
                  }
                }, 
                childCount: homePageList.length,
              ),
            ),
          ],
        )
        )
    );
  }
}

class inventoryTile extends StatefulWidget {
  inventoryTile({super.key});

  @override
  State<inventoryTile> createState() => inventoryTileState();
}

class inventoryTileState extends State<inventoryTile> {
  @override
  Widget build(BuildContext context) {
    return Container(  
      child: Column(  
        children: [
          //Container( 
          Padding( 
            padding: EdgeInsets.all(12.0),
            child: Row(  
              crossAxisAlignment: CrossAxisAlignment.baseline, // <--
              textBaseline: TextBaseline.alphabetic, 
            children: [
                Text(
                  style: TextStyle(fontSize: 18, color: const Color.fromRGBO(240, 240, 240, 1)),
                  "Inventory",
                  ),
                Spacer(), 
                RichText(
                  text: TextSpan( 
                    text: "View All",
                    style: TextStyle(
                      fontSize: 12, 
                      color: const Color.fromRGBO(240, 240, 240, 1)
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {
                      Provider.of<inventory_provider.UserProducts>(context, listen: false).updateInventory();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserInventory()),
                      );
                    }
                  ),
                )
            ]
          )),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(  
              children: [
                Expanded(  
                  child: Container(  
                    height: 216,
                    color: const Color.fromRGBO(10, 10, 10, 1),
                    child: Card(  
                      color: const Color.fromRGBO(22, 22, 30, 1),
                      child: Align( 
                        alignment: Alignment.center,
                        child: Text(style: TextStyle(fontSize: 12, color: const Color.fromRGBO(240, 240, 240, 1)),
                      "Products")),
                      //nSelected:
                    )
                  )
                ),
                VerticalDivider(  width: 16.0, ),
                Expanded(  
                  child: Column (  
                    children: [
                      SizedBox(  
                        height: 100,
                        width: double.infinity,
                        //color: const Color.fromRGBO(10, 10, 10, 1),
                        child: Card (  
                          color:const Color.fromRGBO(22, 22, 30, 1),
                          child: Align( 
                            alignment: Alignment.center,
                            child: Text(style: TextStyle(fontSize: 12, color: const Color.fromRGBO(240, 240, 240, 1)),
                            "Parts"
                          )),
                        )
                      ),
                      Divider( height: 16.0, color: const Color.fromRGBO(10, 10, 10, 1),),
                      SizedBox(  
                        height:100,
                        width: double.infinity,
                        //:const Color.fromRGBO(30, 30, 38, 1),
                        child: Card(  
                          color:const Color.fromRGBO(22, 22, 30, 1),
                          child: Align( 
                            alignment: Alignment.center,
                            child: Text(style: TextStyle(fontSize: 12, color: const Color.fromRGBO(240, 240, 240, 1)),
                            "Part Numbers"
                          )),
                        )
                      ),
                    ]
                  )
                )
              ]
            )
          )
        ]
    )
    );
  }
}