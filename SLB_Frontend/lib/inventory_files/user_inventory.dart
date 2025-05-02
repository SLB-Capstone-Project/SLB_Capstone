import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider.dart';
//mport 'http_functions.dart' as http_funct;
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
          Container(
            color: const Color.fromRGBO(10, 10, 10, 1),
            child: Column (
              children: [
                InventoryWindow(),
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
  const InventoryWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                  int productId = Provider.of<UserProducts>(context, listen: false).getProduct(index); 
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
                      title: Text("Product ID: $productId"),
                      //subtitle: Text(formattedText[1]),
                      textColor: const Color.fromRGBO(240, 240, 240, 1),
                      onTap: () {
                        List<int> partList = Provider.of<UserProducts>(context, listen: false).getPartList(productId) ?? [];
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SPartList(product: productId, partList: partList)),
                        );
                      }
                    ),
                  );
                }, 
                childCount: Provider.of<UserProducts>(context, listen: false).getProductLength,
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