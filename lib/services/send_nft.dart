import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3_login/models/NFT.dart';
import 'package:solana/solana.dart' as solana;

Future<String> send_nft(NFT nft, String address) async {
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

  final sourceAta = await solana.Ed25519HDPublicKey.findProgramAddress(
    seeds: [
      mainWalletSolana.publicKey.bytes,
      tokenProgramId.bytes,
      tokenMintAddress.bytes,
    ],
    programId: ataProgramId,
  );

  final destinationAddress = solana.Ed25519HDPublicKey.fromBase58(address);

  final getATA = await client.getAssociatedTokenAccount(
      owner: destinationAddress, mint: tokenMintAddress);

  solana.Ed25519HDPublicKey destinationAta;

  if (getATA == null) {
    destinationAta = await solana.Ed25519HDPublicKey.findProgramAddress(
      seeds: [
        destinationAddress.bytes,
        tokenProgramId.bytes,
        tokenMintAddress.bytes,
      ],
      programId: ataProgramId,
    );

    final createAccountInstruction =
        solana.AssociatedTokenAccountInstruction.createAccount(
            funder: mainWalletSolana.publicKey,
            address: destinationAta,
            owner: destinationAddress,
            mint: tokenMintAddress);

    final createAccountMesagge =
        solana.Message(instructions: [createAccountInstruction]);

    await client.sendAndConfirmTransaction(
      message: createAccountMesagge,
      signers: [mainWalletSolana],
      commitment: solana.Commitment.confirmed,
    );
  } else {
    destinationAta = solana.Ed25519HDPublicKey.fromBase58(getATA.pubkey);
  }

  final instruction = solana.TokenInstruction.transferChecked(
      amount: 1,
      decimals: 0,
      source: sourceAta,
      destination: destinationAta,
      mint: tokenMintAddress,
      signers: [mainWalletSolana.publicKey],
      owner: mainWalletSolana.publicKey);

  final message = solana.Message(instructions: [instruction]);
  final result = await client.sendAndConfirmTransaction(
    message: message,
    signers: [mainWalletSolana],
    commitment: solana.Commitment.confirmed,
  );
  return result;
}
