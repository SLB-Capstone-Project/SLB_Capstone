import 'package:flutter/material.dart';


class MyTabbedPage extends StatefulWidget {
  const MyTabbedPage({ super.key });
  @override
  State<MyTabbedPage> createState() => _MyTabbedPageState();
}

class _MyTabbedPageState extends State<MyTabbedPage> with SingleTickerProviderStateMixin {
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'All Parts'),
    Tab(text: 'Products'),
  ];

  List<String> part_arr = ['part 1', 'part 2', 'part 3', 'part 4'];
  List<String> product_arr = ['product 1', 'product 2'];
  
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
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [ 
          //myTabs.map((Tab tab) {
          //final String label = tab.text!.toLowerCase();
          Container(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: part_arr.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(leading: Text(part_arr[index]));
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(),
            ),
          ),
          Container (  
            child: ListView.separated(  
              padding: const EdgeInsets.all(8),
              itemCount: product_arr.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(leading: Text(product_arr[index]));
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(),
            ),
          ),
        ],
      ),
    );
  }
}