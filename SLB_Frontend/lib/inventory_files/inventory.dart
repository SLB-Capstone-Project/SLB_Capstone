import 'package:flutter/material.dart';
import 'tabbed_inventory.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../globals.dart' as global;

Future<List<String>> getData() async {
    List<String> string_arr = [];
    final String sendUrl = 'http://172.191.111.81:8081/api/categories';
    String token = global.token;
    print(token);
    final response = await http.get(  
      Uri.parse(sendUrl),
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      }
    );
    //print(response.statusCode);
    print(response.body);
    if(response.statusCode == 200) {
      List temp =  jsonDecode(response.body);
      print(temp);
      //string_arr = temp.cast<String>();
       for(int i = 0; i < temp.length; i++) {
        string_arr.add("Product ID: ${temp[i]['productId']} \n In Stock: ${temp[i]['numberPartCheckOut']}");
        print(temp[i]['productId']);
        print(temp[i]);
      }
      //print(temp[2]);
      //print(temp[3]);
  
      //string_arr = response.body.split('\n');
      //print(string_arr);
      //print(string_arr.length);
      //print(string_arr[3]);
    }
    else {
      print(response.statusCode);
      throw Exception('Unable to connect');
    }
    //setState(() {});
    return string_arr;
  }


Future<List<String>> getnameData() async {
    List<String> string_arr = [];
    final uri = Uri.http('172.191.111.81:8081', '/api/categories', {'name': 'Admin'});
    //final uri = Uri.http('172.191.111.81:8081', '/api/categories');
    String token = global.token;
    //print(token);
    final response = await http.get(  
      uri,
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      }
    );
    //print(response.statusCode);
    print(response.body);
    if(response.statusCode == 200) {
      List temp = List<String>.from(jsonDecode(response.body));
      print(temp.length);
      for(int i = 0; i < temp.length; i++) {
        print(temp[i]);
      }
  
      //string_arr = response.body.split('\n');
      //print(string_arr);
      //print(string_arr.length);
      //print(string_arr[3]);
    }
    else {
      print(response.statusCode);
      throw Exception('Unable to connect');
    }
    //setState(() {});
    return string_arr;
  }



Future<void> sendData(String data) async {
  //const string = 'temp temp temp';
  //Map<String, String> headers = {"Content-Type": "application/json"};
  final String sendUrl = 'http://172.191.111.81:8081/api/components';
  final response = await http.post(  
    //Uri.parse('http://ptsv3.com/t/afeafaefaef/post/'),
    Uri.parse(sendUrl),
    headers: {HttpHeaders.authorizationHeader: 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyTmFtZSI6IkFkbWluIiwiZXhwIjoxNzQzMTE1NTE2fQ.6hlGpXVCPyCZdaeueBm98fdFC5jbRgT6TOZJUg7XJ1Q', 'Content-Type': 'application/json'},
    body: jsonEncode({
      'productsId': 0, 
      'category': 0,
      'status': 'available'
    })
  );
  /*if(response.statusCode != 200) {
    print(response.statusCode);
    throw Exception('Unable to connect');
  }
  else {
    print(response.statusCode);
  }*/
  print(response.statusCode);
  print(response.body);

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
  /*void initState() {
    super.initState();
    getData().then((List<String> result) {
      history_arr = result;
      setState(() {});
    });
  }*/

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
          FloatingActionButton(  
            onPressed: () {
              //Navigator.push(context, MaterialPageRoute(builder: (context) => const MyTabbedPage()));
            },
            child: Text('tabbed inventory'),
          ),
          FloatingActionButton(
            heroTag: null,  
            onPressed: () async {
              history_arr = await getData();
              setState(() {});
            },
            child: Text("get Data"),
          ),
          FloatingActionButton(  
           heroTag: null,
            onPressed: () {
              sendData("temp");
            },
            child: Text('Send Data')
          ),
          FloatingActionButton(  
           heroTag: null,
            onPressed: () {
              getnameData();
            },
            child: Text('get name Data')
          )
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