import 'package:flutter/material.dart';
import 'camera_page.dart';
//import 'login_files/login_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override 
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<String> historyList = <String>['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5', 'Item 6', 'Item 7', 'Item 8', 'Item 9', 'Item 10'];

  void check_in(String text) {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    //final dateFormatter = DateFormat('yyyy-MM-dd');
    //final formattedDate = dateFormatter.format(time);
    //print(formattedDate);
    setState(() {
      //historyList.add('Checked in: $text \n Date: $formattedDate');
      historyList.add('Checked in: $text \n Date:');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Home Page'),
        backgroundColor: Colors.brown,
        toolbarHeight: 60.0,
        titleTextStyle: const TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        leading: IconButton(  
          icon: const Icon(Icons.menu),
          color: Colors.white,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Inventory()));
          }
        ),
      ),
      drawer: Drawer(  
        child: Text('Temp'),
      ),
      body: Center(  
        child: Column(  
          
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [  
            //Column(
             // children: [
            SizedBox(height:30),
            Container( 
              margin: EdgeInsets.symmetric(horizontal: 25),
              alignment: Alignment.centerLeft,
              color: Colors.black,
              //padding: EdgeInsets.all(20),
              child: Text(
                'Recent Activity',
                style: TextStyle(  
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(height:15),
            HistoryWindow(historyList: historyList),
            SizedBox(height:50),
            Row( 
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [ 
                SizedBox( 
                  width: 100,
                  height: 50,
                  child: FloatingActionButton(  
                    heroTag: null,
                    onPressed: () { Navigator.pop(context); },
                    child: Text('Logout'),
                  ),
                ),
                SizedBox ( 
                  width: 100,
                  height: 50,
                  child: FloatingActionButton(
                    onPressed: () {
                      //check_in('Item');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CheckInPage()),
                      );
                    },
                    child: Text('Check In'),
                  ),
                ),
              ],
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
      borderRadius: BorderRadius.circular(20),
      child: Container( 
        height:500,
        width:350,
        /*decoration: BoxDecoration(  
          color: Colors.brown,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            width: 20,
          ),
        ),*/
        child: CustomScrollView(
          clipBehavior: Clip.hardEdge,
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

class HistoryCard extends StatelessWidget {
  final tileString;
  final date;
  const HistoryCard({super.key, required this.tileString, this.date});

  @override
  Widget build(BuildContext context) {
    //return ClipRRect (  
    //  borderRadius: BorderRadius.circular(20.0),
    return Container( 
      height: 60,
      //padding: EdgeInsets.all(8.0),
      //width: 300,
      child: Card.outlined(  
        //margin: EdgeInsets.zero,
        color: Colors.black,
        child: Container(  
          padding: EdgeInsets.all(8.0),
          child: Row( 
            children: [  
              //Text('Check in'),
              Text(
                tileString, 
                style: TextStyle(  
                  color: Colors.white,
                  
                ),
              ),
              //Text('Date: $date')
            ],
          ),
        ),
      )
    );
    //);
  }
}

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => InventoryState();
}

class InventoryState extends State<Inventory> {
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
          color: Colors.white,
        ),
        leading: IconButton(  
          icon: const Icon(Icons.home),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          }
        ),
      ),
      body: Container (  
        color: Colors.black,
      ),
    );
  }
}