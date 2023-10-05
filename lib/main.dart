import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:solana/solana.dart';
import 'package:web3_login/pages/config.dart';
import 'package:web3_login/pages/create_nft.dart';
import 'package:web3_login/pages/generatePhrase.dart';
import 'package:web3_login/pages/home.dart';
import 'package:web3_login/pages/inputPhrase.dart';
import 'package:web3_login/pages/login.dart';
import 'package:web3_login/pages/setupAccount.dart';
import 'package:web3_login/pages/setupPassword.dart';
import 'package:web3_login/pages/show_nft_page.dart';

import 'models/NFT.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(routes: <GoRoute>[
  GoRoute(
      path: '/',
      builder: (context, state) {
        return const LoginScreen();
      }),
  GoRoute(
      path: '/setup',
      builder: (context, state) {
        return const SetUpScreen();
      }),
  GoRoute(
      path: '/inputPhrase',
      builder: (context, state) {
        return const InputPhraseScreen();
      }),
  GoRoute(
      path: '/generatePhrase',
      builder: (context, state) {
        return const GeneratePhraseScreen();
      }),
  GoRoute(
      path: '/passwordSetup/:mnemonic',
      builder: (context, state) {
        return SetupPasswordScreen(mnemonic: state.pathParameters["mnemonic"]);
      }),
  GoRoute(
      path: '/home',
      builder: (context, state) {
        return const HomeScreen();
      }),
  GoRoute(
      path: '/createNft',
      builder: (context, state) {
        SolanaClient client = state.extra as SolanaClient;
        return CreateNftPage(client: client);
      }),
  GoRoute(
      path: '/config',
      builder: (context, state) {
        return const ConfigPage();
      }),
  GoRoute(
      path: '/showNft',
      builder: (context, state) {
        NFT nft = state.extra as NFT;
        return ShowNftPage(nft: nft);
      }),
]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData.dark().copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey[500],
        )),
        primaryColor: Colors.grey[900],
        scaffoldBackgroundColor: Colors.grey[850],
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
