import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web3_login/models/NFT.dart';
import 'package:web3_login/services/burn_nft.dart';
import 'package:web3_login/services/send_nft.dart';

class ShowNftPage extends StatefulWidget {
  NFT nft;
  ShowNftPage({super.key, required this.nft});

  @override
  State<ShowNftPage> createState() => _ShowNftPageState();
}

class _ShowNftPageState extends State<ShowNftPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).go("/home");
        },
        backgroundColor: Colors.white.withOpacity(0.3),
        child: const Icon(
          Icons.arrow_back,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(
                child: Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.network(widget.nft.imageUrl ??
                        "https://placehold.co/600x400/png"),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 80),
                child: Text(
                  textAlign: TextAlign.end,
                  widget.nft.name!,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 80),
                child: Text(
                  widget.nft.description!,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                  onPressed: _showSendDialog,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Send NFT',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 40),
                      Icon(Icons.send),
                      SizedBox(width: 40),
                    ],
                  )),
              SizedBox(height: 16),
              TextButton(
                  onPressed: _showBurnDialog,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Burn NFT',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 40),
                      Text("🔥"),
                      SizedBox(width: 40),
                    ],
                  )),
            ],
          )),
    );
  }

  Future<void> _showSendDialog() async {
    TextEditingController destinationController = TextEditingController();
    String address;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Send NFT'),
          content: TextField(
            decoration: InputDecoration(labelText: 'Enter Destination Wallet'),
            controller: destinationController,
            onChanged: (value) {
              setState(() {});
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Send'),
              onPressed: () async {
                address = destinationController.text;
                await send_nft(widget.nft, address);
                GoRouter.of(context).go('/home');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showBurnDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: Text(
            "Are you sure you want to Burn this nft?",
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('BURN'),
              onPressed: () {
                burn_nft(widget.nft);
              },
            ),
          ],
        );
      },
    );
  }
}
