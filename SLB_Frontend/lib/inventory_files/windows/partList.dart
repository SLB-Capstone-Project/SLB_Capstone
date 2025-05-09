import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'partIdList.dart';
import '../provider.dart';

class PartList extends StatelessWidget {
  final int? product;
  final bool specific;
  const PartList({super.key, required this.product, required this.specific});

  @override
  Widget build(BuildContext context) {
    List<String> partList; 
    if(specific) {
      partList = Provider.of<UserProducts>(context, listen: false).getPartList(product ?? 0) ?? [];
    }
    else {
      partList = Provider.of<UserProducts>(context, listen: false).getAllParts;
    }
    return Material(child: Container(
      color: const Color.fromRGBO(10, 10, 10, 1),
      child: Column (
        children: [
          AppBar(
            title: Text('Inventory'),
            backgroundColor: const Color.fromRGBO(38, 38, 50, 1),
            toolbarHeight: 56.0,
            titleTextStyle: const TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
              color:  Color.fromRGBO(240, 240, 240, 1),
            ),
            leading: BackButton(  
              //icon: const Icon(Icons.home),
              color: const Color.fromRGBO(240, 240, 240, 1),
              onPressed: () {
                Navigator.pop(context);
              }
            ),
          ),
          Flexible(
            child: Padding(padding: EdgeInsets.all(16.0), child: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                      List<String> temp = partList[index].split(' ');
                      int product = int.parse(temp[0]);
                      int part = int.parse(temp[1]);
                      int numIds = Provider.of<UserProducts>(context, listen: false).getNumPartIds(partList[index]);
                      /*return Card( 
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
                          title: Text("Part ID: $partId"),
                          //subtitle: Text(formattedText[1]),
                          textColor: const Color.fromRGBO(240, 240, 240, 1),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => PartIdList(product: product, part: partId, specific:true)),
                            );
                          }
                        ),
                      );*/
                      return Padding(
                          padding: EdgeInsets.only( 
                            bottom: 16.0
                          ),
                          child: Container( 
                          height: 64.0,
                          width: double.infinity,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0), color:const Color.fromRGBO(22, 22, 30, 1)),
                          //color: const Color.fromRGBO(22, 22, 30, 1),
                          child: Row(  
                            children: [  
                              Padding(  
                                padding: EdgeInsets.all(12.0),
                                child: Container( 
                                  height: double.infinity,
                                  width: 50,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0), color: const Color.fromRGBO(38, 38, 50, 1)),
                                  //color: const Color.fromRGBO(38, 38, 50, 1),
                                  child: Align( 
                                    alignment: Alignment.center,
                                    child: Text(  
                                  style: TextStyle(fontFamily: 'RobotoMono', fontSize: 18, fontWeight: FontWeight.bold, color: const Color.fromRGBO(240, 240, 240, 1)), 
                                  "$product$part"
                                  ))
                                  
                                ),
                              ),
                              Padding( 
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Column(  
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [  
                                  Text(  
                                    style: TextStyle(fontFamily: 'RobotoMono', fontSize: 16, color: const Color.fromRGBO(240, 240, 240, 1)), 
                                    "Part Name $index"
                                  ),
                                  Text(  
                                    style: TextStyle(fontFamily: 'RobotoMono', fontSize: 12, color: const Color.fromRGBO(240, 240, 240, 1)), 
                                    "$numIds partIds"
                                  )
                                ]
                              )),
                              Spacer(),
                              Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: RichText(
                                    text: TextSpan( 
                                      text: "View All",
                                      style: TextStyle(
                                        fontSize: 12, 
                                        color: const Color.fromRGBO(240, 240, 240, 1)
                                      ),
                                      recognizer: TapGestureRecognizer()..onTap = () {
                                        Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => PartIdList(product: product, part: part, specific:true)),
                                        );
                                      }
                                    ),
                                  )
                                )
                              )

                            ]
                          )
                          )
                      );
                    }, 
                    childCount: partList.length,
                  ),       
                ),
              ],
            ))
          )
        ]
      )
    ));
  }
}

