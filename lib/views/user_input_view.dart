import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import '../config.dart';

class UserInputView extends StatefulWidget {
  @override
  _UserInputViewState createState() => _UserInputViewState();
}

class _UserInputViewState extends State<UserInputView> {
  final _serverTextController = TextEditingController();
  final _apiKeyTextController = TextEditingController();
  final storage = new LocalStorage(Config.IDENTIFIER_LOCALSTORAGE);

  void _onSubmit() {
    storage.setItem(Config.IDENTIFIER_API_KEY, _apiKeyTextController.text);
    storage.setItem(Config.IDENTIFIER_SERVER_URL, _serverTextController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configuration"),
      ),
      body: Container(
        child: Center(
          child: SizedBox(
            width: 400.0,
            child: ListView(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    child: TextField(
                      controller: _serverTextController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: "Server"),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    child: TextField(
                      controller: _apiKeyTextController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: "API Key"),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5.0),
                  child: ElevatedButton(
                    onPressed: _onSubmit,
                    child: Text("Save"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
