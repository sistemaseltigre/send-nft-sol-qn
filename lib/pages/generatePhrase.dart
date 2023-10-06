import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:go_router/go_router.dart';

class GeneratePhraseScreen extends StatefulWidget {
  const GeneratePhraseScreen({super.key});

  @override
  State<GeneratePhraseScreen> createState() => _GeneratePhraseScreenState();
}

class _GeneratePhraseScreenState extends State<GeneratePhraseScreen> {
  String _mnemonic = "";
  Icon iconButton = const Icon(Icons.copy);
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _generateMnemonic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.tealAccent.shade700,
        title: const Text("Recovery Phrase"),
        elevation: 0.0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              color: Colors.orange[700],
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Important! Copy and save the recovery phrase in a secure location. This cannot be recovered later.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _mnemonic,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _mnemonic));
                      setState(() {
                        iconButton = const Icon(Icons.check);
                      });
                    },
                    icon: iconButton,
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _copied,
                    onChanged: (value) {
                      setState(() {
                        _copied = value!;
                      });
                    },
                  ),
                  const Text(
                    "I have stored the recovery phrase securely",
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _copied
                        ? Colors.purple.shade600
                        : Colors.tealAccent.shade700,
                    minimumSize: const Size(250, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                      20,
                    ))),
                onPressed: _copied
                    ? () {
                        GoRouter.of(context).go("/passwordSetup/$_mnemonic");
                      }
                    : () {
                        GoRouter.of(context).go("/");
                      },
                child: Text(
                  _copied ? 'Continue' : 'Go Back',
                  style: const TextStyle(fontSize: 17),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _generateMnemonic() async {
    String mnemonic = bip39.generateMnemonic();

    setState(() {
      _mnemonic = mnemonic;
    });
  }
}
