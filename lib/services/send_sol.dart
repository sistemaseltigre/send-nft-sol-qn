import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:solana/solana.dart' as solana;

Future<String> send_sol(String address, double ammount) async {
  final storage = FlutterSecureStorage();
  String? rpcUrl;
  final network = await storage.read(key: "network");

  if (network == "mainnet") {
    rpcUrl = await storage.read(key: "mainnetRpc");
  } else if (network == "devnet") {
    rpcUrl = await storage.read(key: "devnetRpc");
  }

  String wsUrl = rpcUrl!.replaceFirst('https', 'wss');
  final client = solana.SolanaClient(
    rpcUrl: Uri.parse(rpcUrl),
    websocketUrl: Uri.parse(wsUrl),
  );

  final mainWalletKey = await storage.read(key: 'mnemonic');

  final mainWalletSolana = await solana.Ed25519HDKeyPair.fromMnemonic(
    mainWalletKey!,
  );

  final destinationAddress = solana.Ed25519HDPublicKey.fromBase58(address);

  int labAmmount = (ammount * solana.lamportsPerSol).toInt();

  final instruction = solana.SystemInstruction.transfer(
      fundingAccount: mainWalletSolana.publicKey,
      recipientAccount: destinationAddress,
      lamports: labAmmount);

  final message = solana.Message(instructions: [instruction]);

  final result = await client.sendAndConfirmTransaction(
    message: message,
    signers: [mainWalletSolana],
    commitment: solana.Commitment.confirmed,
  );

  return result;
}
