import 'package:find_a_friend/messages/basic.pb.dart';
import 'package:find_a_friend/pages/compass.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';


class PartyPage extends StatefulWidget {
  final String partyId;
  const PartyPage({super.key, required this.partyId});
  @override
  State<PartyPage> createState() => _PartyPageState();
}


class _PartyPageState extends State<PartyPage> {
  String ticket = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.partyId),
        actions: [
          IconButton(icon: const Icon(Icons.qr_code), onPressed: () {
          // Requests Ticket to backend
          DocumentTicketRequest(documentId: widget.partyId).sendSignalToRust();
          debugPrint("DocId ---> ${widget.partyId}");
          showDialog(context: context, builder: (BuildContext context) => Dialog(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // waits for the ticket response to create QrCode
                    (ticket == "")?
                      StreamBuilder(
                        stream: DocumentTicketResponse.rustSignalStream, // GENERATED
                        builder: (context, snapshot) {
                          final rustSignal = snapshot.data;
                          if (rustSignal == null) {
                            return const Text("Computing QRCode");
                          }
                          ticket = rustSignal.message.ticket;
                          return QrImageView(
                            data: rustSignal.message.ticket,
                            version: QrVersions.auto,
                            size: 200.0,
                          );
                        }
                    ):QrImageView(
                            data: ticket,
                            version: QrVersions.auto,
                            size: 200.0,
                          ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            )
          );
          })],
      ),
      body: /*Column(
        children: [
          ListView(
            children: const [
              ListTile(leading: Icon(Icons.circle,color: Colors.redAccent), title:  Text("User"))
            ],
          ),
          Divider(),*/
        Column(children: [
          Card(child: ListTile(),),
          Divider(),
          Card(child: CompassScreen()),
        ],)
        //],
      //)

    );
  }
}
