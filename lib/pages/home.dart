import 'package:find_a_friend/messages/basic.pb.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String title = "Find-A-Friend";

  Iterable<ListTile> _listTiles = [];

  void _addNewItem() {
    DocumentCreateRequest().sendSignalToRust();
    var _ = StreamBuilder(
        stream: DocumentCreateResponse.rustSignalStream, // GENERATED
        builder: (context, snapshot) {
          final rustSignal = snapshot.data;
          if (rustSignal == null) {
            return const Text("Not created Yet");
          }
          return Text(rustSignal.message.ticket);
        });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    DocumentListRequest().sendSignalToRust();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        actions: [IconButton(icon: const Icon(Icons.camera), onPressed: () {})],
      ),
      body: StreamBuilder(
          stream: DocumentListResponse.rustSignalStream, // GENERATED
          builder: (context, snapshot) {
            final rustSignal = snapshot.data;
            if (rustSignal == null) {
              return ListView(children: const []);
            }
            _listTiles = rustSignal.message.document
                .map((e) => {
                      ListTile(
                          leading:
                              const Icon(color: Colors.lightBlue, Icons.radar),
                          title: Text((e.docName == "")?"No Party Name": e.docName ),
                          onTap: () {
                            context.push("/party/${e.document.toString()}");
                          }, //opens with goRouter to file
                          onLongPress: () {} // should show a delete screen
                          )
                    })
                .map((e) => e.toList())
                .map((e) => e.first);
            return ListView(
              children: _listTiles.toList(),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}
