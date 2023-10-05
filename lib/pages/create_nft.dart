import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:solana/solana.dart';

import '../services/mint_nft.dart';
import '../services/upload_to_ipfs.dart';

class CreateNftPage extends StatefulWidget {
  final SolanaClient client;
  const CreateNftPage({super.key, required this.client});

  @override
  State<CreateNftPage> createState() => _CreateNftPageState();
}

class _CreateNftPageState extends State<CreateNftPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _imageFile;

  final nameController = TextEditingController();
  final symbolController = TextEditingController();
  final descriptionController = TextEditingController();

  bool _uploadingImage = false;
  bool _imageUploaded = false;
  bool _uploadingJson = false;
  bool _jsonUploaded = false;
  bool _mintingNft = false;
  bool _nftMinted = false;
  String imageUrl = "";
  String cid = "";
  String mintNftResult = "";

  void _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  _uploadImage() async {
    final uploadImageResult = await uploadToIPFS(_imageFile!);

    if (uploadImageResult != null) {
      imageUrl = uploadImageResult;
      setState(() {
        _imageUploaded = true;
        _uploadingJson = true;
      });
      _uploadJson();
    }
  }

  _uploadJson() async {
    Map<String, dynamic> data = {
      'name': nameController.text,
      'symbol': symbolController.text,
      'description': descriptionController.text,
      'image': 'https://quicknode.myfilebase.com/ipfs/$imageUrl',
      "attributes": [],
      "properties": {
        "creators": [],
        "files": [
          {"type": "image/png", "uri": "ipfs://$imageUrl/"}
        ]
      },
      "collection": {}
    };

    String json = jsonEncode(data);

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${nameController.text}.json');
    await file.writeAsString(json);

    final uploadJsonResult = await uploadToIPFS(file);

    if (uploadJsonResult != null) {
      cid = uploadJsonResult;

      setState(() {
        _jsonUploaded = true;
        _mintingNft = true;
      });
      _createNft();
    }
  }

  _createNft() async {
    mintNftResult = await createNft(
        widget.client, cid, nameController.text, symbolController.text);

    setState(() {
      _nftMinted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Mint NFT')),
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
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(children: [
              SizedBox(
                width: 200,
                height: 200,
                child: _imageFile != null
                    ? Image.file(_imageFile!)
                    : const Placeholder(),
              ),
              TextButton(
                  onPressed: _pickImage, child: const Text('Choose Image')),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: symbolController,
                decoration: const InputDecoration(labelText: 'Symbol'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a symbol';
                  }
                  return null;
                },
              ),
              TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  }),
              ElevatedButton(
                onPressed: () {
                  if (!_nftMinted) {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    setState(() {
                      _uploadingImage = true;
                    });
                    _uploadImage();
                  } else {
                    GoRouter.of(context).go("/home");
                  }
                },
                child:
                    _nftMinted ? const Text('Accept') : const Text('Mint NFT'),
              ),
              if (_uploadingImage)
                _imageUploaded
                    ? const Row(
                        children: [
                          Icon(Icons.check, color: Colors.green),
                          Text("Image Uploaded")
                        ],
                      )
                    : const Row(
                        children: [
                          SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator()),
                          Text("Uploading Images")
                        ],
                      ),
              if (_uploadingJson)
                _jsonUploaded
                    ? const Row(
                        children: [
                          Icon(Icons.check, color: Colors.green),
                          Text("json Uploaded")
                        ],
                      )
                    : const Row(
                        children: [
                          SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator()),
                          Text("Uploading Json")
                        ],
                      ),
              if (_mintingNft)
                _nftMinted
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          Icon(Icons.check, color: Colors.green),
                          Text(mintNftResult)
                        ]),
                      )
                    : const Row(
                        children: [
                          SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator()),
                          Text("Minting NFT...")
                        ],
                      )
            ]),
          ),
        ));
  }
}
