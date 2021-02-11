import 'package:flutter/material.dart';

class UserInputView extends StatefulWidget {
  @override
  _UserInputViewState createState() => _UserInputViewState();
}

class _UserInputViewState extends State<UserInputView> {
  void _onSubmit() {}
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
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: ListView(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(5.0),
                      child: TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), labelText: "Server"),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(5.0),
                      child: TextField(
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
      ),
    );
  }
}
