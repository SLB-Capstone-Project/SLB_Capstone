import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider.dart';


class PartIdList extends StatelessWidget {
  final bool specific;
  final int? product;
  final int? part;
  const PartIdList({super.key, required this.product, required this.part, required this.specific});

  @override
  Widget build(BuildContext context) {
    List<int> partIdList; 
    if(specific) {
      partIdList = Provider.of<UserProducts>(context, listen: false).getPartIdList(product ?? 0, part ?? 0) ?? [];
    }
    else {
      partIdList = Provider.of<UserProducts>(context, listen: false).getAllPartIds;
    }
    //List<int> partIds = Provider.of<UserProducts>(context, listen: false).getPartIds; 
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
              //icon: const IconButton.backButton,
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
                      int partId = partIdList[index];
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
                          // List<int> partList = Provider.of<UserProducts>(context, listen: false).getPartList(productId) ?? [];
                          // Navigator.push(
                          //   context,
                            //  MaterialPageRoute(builder: (context) => SPartList(product: productId, partList: partList)),
                            //);
                          }
                        ),
                      );*/
                      return Padding(
                          padding: EdgeInsets.only( 
                            bottom: 12.0
                          ),
                          child: Container( 
                          height: 48.0,
                          width: double.infinity,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0), color:const Color.fromRGBO(22, 22, 30, 1)),
                          //color: const Color.fromRGBO(22, 22, 30, 1),
                          child: Row(  
                            children: [  
                              Padding(  
                                padding: EdgeInsets.all(12.0),
                                child: Container( 
                                  height: double.infinity,
                                  width: 100,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0), color: const Color.fromRGBO(38, 38, 50, 1)),
                                  //color: const Color.fromRGBO(38, 38, 50, 1),
                                  child: Align( 
                                    alignment: Alignment.center,
                                    child: Text(  
                                  style: TextStyle(fontFamily: 'RobotoMono', fontSize: 14, fontWeight: FontWeight.bold, color: const Color.fromRGBO(240, 240, 240, 1)), 
                                  "$partId"
                                  ))
                                  
                                ),
                              ),
                              /*Padding( 
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(  
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [  
                                  Text(  
                                    style: TextStyle(fontFamily: 'RobotoMono', fontSize: 16, color: const Color.fromRGBO(240, 240, 240, 1)), 
                                    "Part Name $index"
                                  ),
                                  /*Text(  
                                    style: TextStyle(fontFamily: 'RobotoMono', fontSize: 12, color: const Color.fromRGBO(240, 240, 240, 1)), 
                                    " parts"
                                  )*/
                                ]
                              )),*/
                              Spacer(),
                              Align(
                                alignment: Alignment.topCenter,
                                /*child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: RichText(
                                    text: TextSpan( 
                                      text: "View All",
                                      style: TextStyle(
                                        fontSize: 12, 
                                        color: const Color.fromRGBO(240, 240, 240, 1)
                                      ),
                                      /*recognizer: TapGestureRecognizer()..onTap = () {
                                        Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => PartIdList(product: product, part: part, specific:true)),
                                        );
                                      }*/
                                    ),
                                  )
                                )*/
                              )

                            ]
                          )
                          )
                      );
                    }, 
                    childCount: partIdList.length,
                  ),                 
                ),
              ],
            )
          ))
        ]
      )
    ));
  }
}

