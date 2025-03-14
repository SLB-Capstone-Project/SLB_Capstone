import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<String>> getData() async {
    List<String> string_arr = [];
    final response = await http.get(  
      Uri.parse('http://ptsv3.com/t/afeafaefaef/post/')
    );
    if(response.statusCode == 200) {
      string_arr = response.body.split('\n');
      //print(string_arr.length);
      //print(string_arr[3]);
    }
    else {
      throw Exception('Unable to connect');
    }
    //setState(() {});
    return string_arr;
  }

Future<void> sendData(String data) async {
  //const string = 'temp temp temp';
  final response = await http.post(  
    Uri.parse('http://ptsv3.com/t/afeafaefaef/post/'),
    body: data,
  );
  if(response.statusCode != 200) {
    throw Exception('Unable to connect');
  }
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<String> history_arr = [];
  bool logout = false;

  @override 
  void initState() {
    super.initState();
    getData().then((List<String> result) {
      history_arr = result;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(  
      child: Column ( 
        children: [
          Container(  
            alignment: Alignment.center,
            height: 500,
            width: 500,
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: history_arr.length,
              itemBuilder: (BuildContext context, int index) {
                return InventoryTile(tileString: history_arr[index]);
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(),
            ),
          ),
          //FloatingActionButton(
          //  heroTag: null,  
           // onPressed: () async {
            //  history_arr = await getData();
             // setState(() {});
            //},
            //child: Text("get Data"),
         // ),
          //FloatingActionButton(  
         //  heroTag: null,
          //  onPressed: () {
              //sendData();
           // },
           // child: Text('Send Data')
         // )
        ]
      )
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
      height: 75,
      width: 500,
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
                  sendData(widget.tileString);
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