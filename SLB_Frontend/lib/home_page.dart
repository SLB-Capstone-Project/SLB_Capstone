import 'package:flutter/material.dart';
import 'package:namer_app/data_analysis.dart';
import 'package:namer_app/login_files/login_screen.dart';
//import 'inventory.dart';
//import 'tabbed_inventory.dart';
import 'checkin_files/checkin_page.dart';
import 'inventory_files/user_inventory.dart';
import 'admin/admin_main.dart';
//import 'package:http/http.dart' as http;
import 'globals.dart' as global;
import 'inventory_files/http_functions.dart' as http_funct;
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DataAnalysis()),
                );
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
      body: Center( 
        child: Column(  
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [  
            //Column(
             // children: [
            //SizedBox(height:30),
            Container( 
              //margin: EdgeInsets.symmetric(horizontal: 25),
              alignment: Alignment.centerLeft,
              color: const Color.fromRGBO(10, 10, 10, 1),
              padding: EdgeInsets.all(20),
              child: Text(
                'Recent Activity',
                style: TextStyle(  
                  color: const Color.fromRGBO(240, 240, 240, 1),
                  fontSize: 20,
                ),
              ),
            ),
            //SizedBox(height:15),
            HistoryWindow(historyList: global.historyList),
            //SizedBox(height:50),
            Container( 
              //margin: EdgeInsets.symmetric(horizontal: 25),
              alignment: Alignment.centerLeft,
              color: Colors.black,
              padding: EdgeInsets.all(20),
              child: Text(
                'Notications',
                style: TextStyle(  
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            Container( 
              //margin: EdgeInsets.symmetric(horizontal: 25),
              alignment: Alignment.centerLeft,
              color: Colors.black,
              //padding: EdgeInsets.all(20),
              child: Text(
                'None for now',
                style: TextStyle(  
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryWindow extends StatelessWidget {
  final List<String> historyList;

  const HistoryWindow({super.key, required this.historyList});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: Container( 
        //color: const Color.fromRGBO(60, 61, 55, 1),
        height:300,
        width:350,
        /*decoration: BoxDecoration(  
          color: Colors.brown,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            width: 20,
          ),
        ),*/   
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                  return HistoryCard(tileString: historyList[index]);
                }, 
                childCount: historyList.length,
              ),
            ),
          ],
        )
      ),
    );
  }
}

class HistoryCard extends StatefulWidget {
  final String tileString;
  const HistoryCard({super.key, required this.tileString});
  @override
  State<HistoryCard> createState() => _historyCardState();

}

class _historyCardState extends State<HistoryCard> {
  late List<String> formattedText = [
    widget.tileString.substring(widget.tileString.indexOf('Part ID') + 'Part ID'.length, widget.tileString.indexOf('Action')).trim(),
    widget.tileString.substring(widget.tileString.indexOf('Action:') + 'Action:'.length, widget.tileString.indexOf('Time')).trim(),
  ];
  
  @override 
  /*void initState() {
    print(widget.tileString);
  }*/
  @override
  Widget build(BuildContext context) {
    return Card( 
      child: ListTile(  
        leading: CircleAvatar( 
          foregroundColor: const Color.fromRGBO(240, 240, 240, 1),
          backgroundColor: const Color.fromRGBO(60, 61, 55, 1),
          child: Text(
            formattedText[0].substring(0, 3),
            //selectionColor: Color.fromRGBO(240, 240, 240, 1),
          ),
        ),
        tileColor:const Color.fromRGBO(22, 22, 30, 1),
        title: Text("Part ID: ${formattedText[0]}"),
        subtitle: Text(formattedText[1]),
        textColor: const Color.fromRGBO(240, 240, 240, 1),
        onTap: () {}
        
      ),
    );
  }
}
