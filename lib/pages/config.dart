import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:solana/solana.dart';

enum Network {
  mainnet,
  devnet,
}

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  Network _network = Network.mainnet;
  final storage = const FlutterSecureStorage();
  TextEditingController mainnetRpcController = TextEditingController();
  TextEditingController devnetRpcController = TextEditingController();
  String? mainnetRpc;
  String? devnetRpc;

  @override
  void initState() {
    super.initState();

    _readRpc();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Network Configuration'),
        ),
        body: Column(
          children: [
            SwitchListTile(
              title: Text('Use Devnet'),
              value: _network == Network.devnet,
              onChanged: (value) {
                setState(() {
                  _network = value ? Network.devnet : Network.mainnet;
                });
              },
            ),
            TextFormField(
              controller: devnetRpcController,
              enabled: _network == Network.devnet,
              decoration: InputDecoration(labelText: 'Devnet RPC URL'),
              onChanged: (value) {
                setState(() {});
              },
            ),
            TextFormField(
              controller: mainnetRpcController,
              enabled: _network == Network.mainnet,
              decoration: InputDecoration(labelText: 'Mainnet RPC URL'),
              onChanged: (value) {
                setState(() {});
              },
            ),
            ListTile(
                trailing: Icon(Icons.arrow_forward),
                title: Text('Accept'),
                onTap: () async {
                  if (_network == Network.mainnet) {
                    if (mainnetRpcController.text == mainnetRpc) {
                      await storage.write(key: 'network', value: "mainnet");
                      GoRouter.of(context).go("/home");
                      return;
                    }
                  } else if (_network == Network.devnet) {
                    if (devnetRpcController.text == devnetRpc) {
                      await storage.write(key: 'network', value: "devnet");
                      GoRouter.of(context).go("/home");
                      return;
                    }
                  }
                  bool valid = await validateRpc(_network == Network.mainnet
                      ? mainnetRpcController.text
                      : devnetRpcController.text);
                  validateRpcDialog(context, valid);
                }),
          ],
        ));
  }

  Future<dynamic> validateRpcDialog(BuildContext context, bool valid) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Validation'),
            content: Text(valid
                ? 'Rpc for current network has changed successfully'
                : 'Rpc introduced is not valid for current network'),
            actions: [
              TextButton(
                onPressed: () {
                  if (!valid) {
                    _readRpc();
                    GoRouter.of(context).pop();
                  } else {
                    GoRouter.of(context).go("/home");
                  }
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  Future<bool> validateRpc(String? rpcUrl) async {
    String wsUrl = rpcUrl!.replaceFirst('https', 'wss');
    SolanaClient? client = SolanaClient(
      rpcUrl: Uri.parse(rpcUrl),
      websocketUrl: Uri.parse(wsUrl),
    );
    try {
      String health = await client.rpcClient.getHealth();
      var hash = await client.rpcClient.getGenesisHash();

      if (health == "ok") {
        if (_network == Network.mainnet) {
          bool vHash =
              await verifyhash(hash, "https://api.mainnet-beta.solana.com");
          if (vHash) {
            await storage.write(key: 'network', value: "mainnet");
            await storage.write(key: 'mainnetRpc', value: rpcUrl);
            return true;
          } else {
            return false;
          }
        } else if (_network == Network.devnet) {
          bool vHash = await verifyhash(hash, "https://api.devnet.solana.com");
          if (vHash) {
            await storage.write(key: 'network', value: "devnet");
            await storage.write(key: 'devnetRpc', value: rpcUrl);
            return true;
          } else {
            return false;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyhash(hash, rpcUrl) async {
    String wsUrl = rpcUrl!.replaceFirst('https', 'wss');
    SolanaClient? client = SolanaClient(
      rpcUrl: Uri.parse(rpcUrl),
      websocketUrl: Uri.parse(wsUrl),
    );
    String genesishash = await client.rpcClient.getGenesisHash();
    if (hash == genesishash) {
      return true;
    }
    return false;
  }

  _readRpc() async {
    final networkStored = await storage.read(key: "network");
    devnetRpc = await storage.read(key: "devnetRpc");
    mainnetRpc = await storage.read(key: "mainnetRpc");
    if (mainnetRpc != null) {
      setState(() {
        mainnetRpcController.text = mainnetRpc!;
      });
    }
    if (devnetRpc != null) {
      setState(() {
        devnetRpcController.text = devnetRpc!;
      });
    }

    if (networkStored == "devnet") {
      setState(() {
        _network = Network.devnet;
      });
    }
  }
}
