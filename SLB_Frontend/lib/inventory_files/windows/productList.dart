import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'partList.dart';
import '../provider.dart';
//mport 'http_functions.dart' as http_
class ProductList extends StatelessWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context) {

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
                        int product = Provider.of<UserProducts>(context, listen: false).getProduct(index);
                        int numParts = Provider.of<UserProducts>(context, listen: false).getNumParts(product);
                        return Padding(
                          padding: EdgeInsets.only( 
                            bottom: 16.0
                          ),
                          child: Container( 
                          height: 76.0,
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
                                  "$product"
                                  ))
                                  
                                ),
                              ),
                              Padding( 
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Column(  
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [  
                                  Text(  
                                    style: TextStyle(fontFamily: 'RobotoMono', fontSize: 18, color: const Color.fromRGBO(240, 240, 240, 1)), 
                                    "Product Name $index"
                                  ),
                                  Text(  
                                    style: TextStyle(fontFamily: 'RobotoMono', fontSize: 14, color: const Color.fromRGBO(240, 240, 240, 1)), 
                                    "$numParts parts"
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
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => PartList(product: product, specific:true)),
                                        );
                                      }
                                    ),
                                  )
                                )
                              )

                            ]
                          )
                          /*child: ListTile(  
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PartList(product: productId, specific:true)),
                              );
                            }
                          ),*/
                        ));
                      }, 
                      childCount: Provider.of<UserProducts>(context, listen: false).getProductLength,
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
