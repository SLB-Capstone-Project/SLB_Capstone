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

  List<String> history_arr = ['product 1', 'product 2', 'product 3', 'product 4'];
  
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
        children: myTabs.map((Tab tab) {
          final String label = tab.text!.toLowerCase();
          return Center(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: history_arr.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(leading: Text(history_arr[index]));
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(),
            ),
          );
        }).toList(),
      ),
    );
  }
}