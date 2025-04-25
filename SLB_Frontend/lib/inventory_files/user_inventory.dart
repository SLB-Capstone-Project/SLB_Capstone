import 'package:flutter/material.dart';
import 'package:quiver/collection.dart';
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
  List<String> part_id_arr = [];
  List<String> part_arr = [];
  List<int?> product_arr = [];

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> parts = [];
  var productmap = Multimap<String, String>(); //maps products to part ID
  var partmap = Multimap<int, int>(); //maps part ID to part

  //var part_to_id = Multimap<List<int>, int>(); //maps products and parts to partId's

  var product_to_part = Map<int?, List<int>>(); //map product to parts
  var part_to_id = Map<List<int?>, List<int>>(); //map product and part to partId
  late TabController _tabController;

  //note: products correspond to multiple parts(part numbers)
  //note: parts correspond to multiple part ids
  
  //a bunch of getter functions
  int? get_product(int index) {
    return product_arr[index];
  }

  List<int>? get_parts_from_product(int? key) {
    return product_to_part[key];
  }
  /*int get_part(int index) {
    return part_arr[index];
  }*/
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
    http_funct.getUserProducts().then((List result) {
      //result contains a list of parts 
      for(int i = 0; i < result.length; i++) {
        int? productId = result[i]['productId'];
        int part = result[i]['partNumber'];
        int partId = result[i]['partId'];
        product_to_part.update(productId, (value) => value + [part], ifAbsent: () => [part]);
        part_to_id.update([productId, part], (value) => value + [partId], ifAbsent: () => [partId]);
        /*product_to_part.add(result[i]['productId'], result[i]['partNumber']);
        part_to_id.add([result[i]['productId'], result[i]['partNumber']], result[i]['partId']);
        products.add({
          'productId': result[i]['productId']
        });
        parts.add({
          'partId': result[i]['part']
        });
        productmap.add("Product ID: ${result[i]['productId']} "
          "ProductName: ${result[i]['productName']}", 
          "Part ID: ${result[i]['partId']} \n"
        "partName: ${result[i]['partName']}");
        //partmap.add(int.parse(result[i]['partId']), int.parse(result[i]['partId'].toString().substring(3)));
        product_arr.add("Product ID: ${result[i]['productId']} \n"
          "ProductName: ${result[i]['productName']}");
        part_arr.add("Part ID: ${result[i]['partId']} \n"
        "partName: ${result[i]['partName']}");*/ 
      }
      product_arr = product_to_part.keys.toList();
      //print(part_to_id);
      //print(part_to_id.keys);
      //print(product_arr);
      //print(product_arr.length);
  
      //print(productmap.toString());
      //print(productmap["Product ID: 1 "
      //    "ProductName: Laptop"]);
      //create new multimap to make multiple parts to a product
      setState(() {});
    });
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
          Container(
            color: const Color.fromRGBO(10, 10, 10, 1),
            child: Column (
              children: [
                InventoryWindow(inventoryList: product_arr, funct: get_product, funct2: get_parts_from_product),
                //TextField(  

                //),           
                /*Expanded(
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
                ),*/
              ]
            ),
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


class InventoryWindow extends StatelessWidget {
  Function funct;
  Function funct2;
  final List<int?> inventoryList;

  InventoryWindow({super.key, required this.inventoryList, required this.funct, required this.funct2});

  void check_inventoryList() {
    print(inventoryList);
    print(inventoryList.length);
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                  //return InventoryCard(tileString: inventoryList[index]);
                  return Card( 
                    child: ListTile(  
                      /*leading: CircleAvatar( 
                        foregroundColor: const Color.fromRGBO(240, 240, 240, 1),
                        backgroundColor: const Color.fromRGBO(60, 61, 55, 1),
                        child: Text(
                          formattedText[0].substring(0, 3),
                          //selectionColor: Color.fromRGBO(240, 240, 240, 1),
                        ),
                      ),*/
                      tileColor:const Color.fromRGBO(22, 22, 30, 1),
                      title: Text("Product ID: ${funct(index)}"),
                      //subtitle: Text(formattedText[1]),
                      textColor: const Color.fromRGBO(240, 240, 240, 1),
                      onTap: () {
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
                      }
                      
                    ),
                  );
                }, 
                childCount: inventoryList.length,
              ),
              
            ),
          ],
        )
      //),]
    );
  }
}

/*class InventoryCard extends StatefulWidget {
  final int? tileString;
  bool hidden = true;
  InventoryCard({super.key, required this.tileString});
  @override
  State<InventoryCard> createState() => _inventoryCardState();

}

class _inventoryCardState extends State<InventoryCard> {
  late List<String> formattedText = [
    /*widget.tileString.substring(widget.tileString.indexOf('Part ID') + 'Part ID'.length, widget.tileString.indexOf('Action')).trim(),
    widget.tileString.substring(widget.tileString.indexOf('Action:') + 'Action:'.length, widget.tileString.indexOf('Time')).trim(),*/
  ];
  
  Widget buildContainer() {
    return Container();
  }
  @override 
  /*void initState() {
    print(widget.tileString);
  }*/
  @override
  Widget build(BuildContext context) {
    return Card( 
      child: ListTile(  
        /*leading: CircleAvatar( 
          foregroundColor: const Color.fromRGBO(240, 240, 240, 1),
          backgroundColor: const Color.fromRGBO(60, 61, 55, 1),
          child: Text(
            formattedText[0].substring(0, 3),
            //selectionColor: Color.fromRGBO(240, 240, 240, 1),
          ),
        ),*/
        tileColor:const Color.fromRGBO(22, 22, 30, 1),
        title: Text("Product ID: ${widget.tileString}"),
        //subtitle: Text(formattedText[1]),
        textColor: const Color.fromRGBO(240, 240, 240, 1),
        onTap: () {
          /*widget.hidden = !widget.hidden;
          print(widget.hidden);
          /*if(widget.hidden == false) {
            return buildContainer();
          }*/
          setState() {}; */
          String temp = product_arr[index].replaceAll("\n", "");
          List<String> productList = productmap[temp].toList();
          print(productList);
          //print(temp);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductList(productList: productList)),
          );
        }
        
      ),
    );
  }
}*/

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