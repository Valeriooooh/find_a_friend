import 'package:flutter/material.dart';
import 'package:rinf/rinf.dart';
import './messages/generated.dart';
import 'package:find_a_friend/messages/basic.pb.dart';

void main() async {
  await initializeRust(assignRustSignal);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find-A-Friend',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Find-A-Friend'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<StatelessWidget> _listTiles = [];
  void _addNewItem() {
    setState(() {
      DocumentCreateRequest().sendSignalToRust();
      var _ = StreamBuilder(
          stream: DocumentCreateResponse.rustSignalStream, // GENERATED
          builder: (context, snapshot) {
            final rustSignal = snapshot.data;
            if (rustSignal == null) {
              return Text("Not created Yet");
            }
            return Text(rustSignal.message.ticket);
          });
      //
      _listTiles.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    DocumentListRequest().sendSignalToRust();
    var a = StreamBuilder(
      stream: DocumentListResponse.rustSignalStream, // GENERATED
      builder: (context, snapshot) {
        var titles;
        final rustSignal = snapshot.data;
        var temp;
        if (rustSignal == null) {
          temp = [];
          _listTiles = temp;
          return temp;
        }
        titles = rustSignal.message.document;
        debugPrint("----> $titles");
        for (var title in titles) {
          temp.add(ListTile(
            leading: const Icon(color: Colors.blue, Icons.radar),
            title: Text("$title"),
          ));
        }
        _listTiles = temp;
        return temp;
      },
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _listTiles.length,
        itemBuilder: (context, index) {
          return _listTiles[index];
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewItem,
        tooltip: "hello",
      ),
      //       StreamBuilder(
      //         stream: Incred.rustSignalStream, // GENERATED
      //         builder: (context, snapshot) {
      //           final rustSignal = snapshot.data;
      //           if (rustSignal == null) {
      //             return const Text('0');
      //           }
      //           final myTreasureOutput = rustSignal.message;
      //           _counter = myTreasureOutput.number;
      //           return Text('$_counter');
      //         },
      //      )
    );
  }
}
