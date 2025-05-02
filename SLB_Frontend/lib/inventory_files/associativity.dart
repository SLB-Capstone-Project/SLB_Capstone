import 'package:flutter/material.dart';
//import 'package:quiver/collection.dart';
import 'package:provider/provider.dart';
import 'provider.dart';

class SPartList extends StatefulWidget {
  final int? product;
  final List<int> partList;
  SPartList({super.key, required this.product, required this.partList,});

  @override
  _SPartListState createState() => _SPartListState();
}

class _SPartListState extends State<SPartList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parts for Product ${widget.product}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SizedBox(
              height: 200,
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: widget.partList.length,
                itemBuilder: (BuildContext context, int index) {
                    return Consumer<UserProducts>( 
                      builder: (context, products, child) {
                        return ListTile(
                          leading: Text(widget.partList[index].toString()),
                          onTap: () {
                              int part = widget.partList[index];
                              List<int>? partIdList = products.getPartIdList(widget.product ?? 0, part);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PartList(partList: partIdList ?? [])),
                              );
                            }
                        );
                      },
                    );
                },
                separatorBuilder: (BuildContext context, int index) => const Divider(),
              ),
            ),
          ), 
        ]
      )
    );
  }
}

class PartList extends StatefulWidget {
  final List<int> partList;
  PartList({super.key, required this.partList});

  @override
  _PartListState createState() => _PartListState();
}

class _PartListState extends State<PartList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Part ID'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SizedBox(
              height: 200,
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: widget.partList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: Text(widget.partList[index].toString()),
                    onTap: () {
                      int part = widget.partList[index];
                      print(part);
                      }
                    //onTap: () => {remove_index(index)},
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const Divider(),
              ),
            ),
          ), 
        ]
      )
    );
  }
}