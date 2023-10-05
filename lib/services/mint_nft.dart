import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:math';
import 'package:solana/solana.dart' as solana;
import 'package:solana/anchor.dart' as solana_anchor;
import 'package:solana/encoder.dart' as solana_encoder;
import 'package:solana_common/utils/buffer.dart' as solana_buffer;
import '../anchor_types/nft_parameters.dart' as anchor_types;

Future<String> createNft(
    solana.SolanaClient client, String CID, String name, String symbol) async {
  const storage = FlutterSecureStorage();

  final mainWalletKey = await storage.read(key: 'mnemonic');

  final mainWalletSolana = await solana.Ed25519HDKeyPair.fromMnemonic(
    mainWalletKey!,
  );

  const programId = 'AHKQL2jNekU1VfCH23Zjjc799GJdL3qHEtimBen1LEv';

  final programIdPublicKey = solana.Ed25519HDPublicKey.fromBase58(programId);

  int id = Random().nextInt(999999999);

  final nftMintPda = await solana.Ed25519HDPublicKey.findProgramAddress(
      programId: programIdPublicKey,
      seeds: [
        solana_buffer.Buffer.fromString("mint"),
        solana_buffer.Buffer.fromInt64(id),
      ]);

  final ataProgramId = solana.Ed25519HDPublicKey.fromBase58(
      solana.AssociatedTokenAccountProgram.programId);

  final systemProgramId =
      solana.Ed25519HDPublicKey.fromBase58(solana.SystemProgram.programId);
  final tokenProgramId =
      solana.Ed25519HDPublicKey.fromBase58(solana.TokenProgram.programId);

  final rentProgramId = solana.Ed25519HDPublicKey.fromBase58(
      "SysvarRent111111111111111111111111111111111");

  const metaplexProgramId = 'metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s';
  final metaplexProgramIdPublicKey =
      solana.Ed25519HDPublicKey.fromBase58(metaplexProgramId);

  final aTokenAccount = await solana.Ed25519HDPublicKey.findProgramAddress(
    seeds: [
      mainWalletSolana.publicKey.bytes,
      tokenProgramId.bytes,
      nftMintPda.bytes,
    ],
    programId: ataProgramId,
  );

  final masterEditionAccountPda =
      await solana.Ed25519HDPublicKey.findProgramAddress(
    seeds: [
      solana_buffer.Buffer.fromString("metadata"),
      metaplexProgramIdPublicKey.bytes,
      nftMintPda.bytes,
      solana_buffer.Buffer.fromString("edition"),
    ],
    programId: metaplexProgramIdPublicKey,
  );
  final nftMetadataPda = await solana.Ed25519HDPublicKey.findProgramAddress(
    seeds: [
      solana_buffer.Buffer.fromString("metadata"),
      metaplexProgramIdPublicKey.bytes,
      nftMintPda.bytes,
    ],
    programId: metaplexProgramIdPublicKey,
  );

  final instructions = [
    await solana_anchor.AnchorInstruction.forMethod(
      programId: programIdPublicKey,
      method: 'create_single_nft',
      arguments: solana_encoder.ByteArray(anchor_types.NftArguments(
              id: BigInt.from(id),
              name: name,
              symbol: symbol,
              uri: "https://quicknode.myfilebase.com/ipfs/$CID/",
              price: BigInt.from(1),
              cant: BigInt.from(1))
          .toBorsh()
          .toList()),
      accounts: <solana_encoder.AccountMeta>[
        solana_encoder.AccountMeta.writeable(
            pubKey: mainWalletSolana.publicKey, isSigner: true),
        solana_encoder.AccountMeta.writeable(
            pubKey: mainWalletSolana.publicKey, isSigner: true),
        solana_encoder.AccountMeta.writeable(
            pubKey: nftMintPda, isSigner: false),
        solana_encoder.AccountMeta.writeable(
            pubKey: aTokenAccount, isSigner: false),
        solana_encoder.AccountMeta.readonly(
            pubKey: ataProgramId, isSigner: false),
        solana_encoder.AccountMeta.readonly(
            pubKey: rentProgramId, isSigner: false),
        solana_encoder.AccountMeta.readonly(
            pubKey: systemProgramId, isSigner: false),
        solana_encoder.AccountMeta.readonly(
            pubKey: tokenProgramId, isSigner: false),
        solana_encoder.AccountMeta.readonly(
            pubKey: metaplexProgramIdPublicKey, isSigner: false),
        solana_encoder.AccountMeta.writeable(
            pubKey: masterEditionAccountPda, isSigner: false),
        solana_encoder.AccountMeta.writeable(
            pubKey: nftMetadataPda, isSigner: false),
      ],
      namespace: 'global',
    ),
  ];
  final message = solana.Message(instructions: instructions);
  final signature = await client.sendAndConfirmTransaction(
    message: message,
    signers: [mainWalletSolana],
    commitment: solana.Commitment.confirmed,
  );
  return 'Tx successful with hash: $signature';
}
