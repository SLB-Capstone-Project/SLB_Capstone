import 'dart:convert';
import 'package:http/http.dart' as http;
import '../globals.dart' as global;

Future<List> getUserHistory() async {
  List items = [];
  print("getting user history");
  final String sendUrl = 'http://4.227.176.4:8081/api/activities';
  final response = await http.get(  
    Uri.parse(sendUrl),
    headers: {
      'Authorization': global.token,
      'Content-Type': 'application/json',
    }
  );
  if(response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    items = responseBody['data'];
    //print(responseBody);
  }
  else {
    print(response.statusCode);
    print(response.body);
    //throw Exception('Unable to connect');
  }
  return items;
}