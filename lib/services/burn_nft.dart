import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3_login/models/NFT.dart';
import 'package:solana/solana.dart' as solana;

Future<String> burn_nft(NFT nft) async {
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

  final tokenMintAddress =
      solana.Ed25519HDPublicKey.fromBase58(nft.tokenAddress!);

  final tokenProgramId =
      solana.Ed25519HDPublicKey.fromBase58(solana.TokenProgram.programId);
  final ataProgramId = solana.Ed25519HDPublicKey.fromBase58(
      solana.AssociatedTokenAccountProgram.programId);

  final aTokenAccount = await solana.Ed25519HDPublicKey.findProgramAddress(
    seeds: [
      mainWalletSolana.publicKey.bytes,
      tokenProgramId.bytes,
      tokenMintAddress.bytes,
    ],
    programId: ataProgramId,
  );

  final instruction = solana.TokenInstruction.burnChecked(
      amount: 1,
      decimals: 0,
      accountToBurnFrom: aTokenAccount,
      mint: tokenMintAddress,
      owner: mainWalletSolana.publicKey);

  final message = solana.Message(instructions: [instruction]);
  final result = await client.sendAndConfirmTransaction(
    message: message,
    signers: [mainWalletSolana],
    commitment: solana.Commitment.confirmed,
  );
  return result;
}
