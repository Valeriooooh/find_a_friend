import 'package:find_a_friend/routes/router_config.dart';
import 'package:flutter/material.dart';
import 'package:rinf/rinf.dart';
import './messages/generated.dart';

void main() async {
  await initializeRust(assignRustSignal);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        title: 'Find-A-Friend',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        routeInformationParser: MyAppRouter().router.routeInformationParser,
        routerDelegate: MyAppRouter().router.routerDelegate);
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   Iterable<ListTile> _listTiles = [];
//   void _addNewItem() {
//     setState(() {
//       DocumentCreateRequest().sendSignalToRust();
//       var _ = StreamBuilder(
//           stream: DocumentCreateResponse.rustSignalStream, // GENERATED
//           builder: (context, snapshot) {
//             final rustSignal = snapshot.data;
//             if (rustSignal == null) {
//               return Text("Not created Yet");
//             }
//             return Text(rustSignal.message.ticket);
//           });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     DocumentListRequest().sendSignalToRust();
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//         actions: [IconButton(icon: const Icon(Icons.camera), onPressed: () {})],
//       ),
//       body: StreamBuilder(
//           stream: DocumentListResponse.rustSignalStream, // GENERATED
//           builder: (context, snapshot) {
//             final rustSignal = snapshot.data;
//             if (rustSignal == null) {
//               return ListView(children: []);
//             }
//             _listTiles = rustSignal.message.document
//                 .map((e) => {
//                       ListTile(
//                           leading:
//                               const Icon(color: Colors.lightBlue, Icons.radar),
//                           title: Text(e),
//                           onTap: () {}, //opens with goRouter to file
//                           onLongPress: () {} // should show a delete screen
//                           )
//                     })
//                 .map((e) => e.toList())
//                 .map((e) => e.first);
//             return ListView(
//               children: _listTiles.toList(),
//             );
//           }),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _addNewItem,
//       ),
//     );
//   }
// }
