import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:web3_login/models/NFT.dart';

Future<List<NFT>> fetchNfts(String address) async {
  const storage = FlutterSecureStorage();
  String? url;
  final network = await storage.read(key: "network");
  if (network == "mainnet") {
    url = await storage.read(key: "mainnetRpc");
  } else if (network == "devnet") {
    url = await storage.read(key: "devnetRpc");
  }

  final headers = {
    'Content-Type': 'application/json',
    'x-qn-api-version': '1',
  };

  final body = json.encode({
    "id": 67,
    "jsonrpc": "2.0",
    "method": "qn_fetchNFTs",
    "params": {
      "wallet": address,
      "omitFields": [
        "provenance",
        "traits",
        "collectionName",
        "collectionAddress",
        "chain",
        "network",
        "creators"
      ],
      "page": 1,
      "perPage": 10
    }
  });

  final response =
      await http.post(Uri.parse(url!), headers: headers, body: body);

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final assetsData = jsonData?['result']?['assets'] as List<dynamic>? ?? [];
    final nfts = assetsData.map((data) => NFT.fromJson(data)).toList();

    return nfts;
  } else {
    throw Exception("Couldn't load NFTs");
  }
}
