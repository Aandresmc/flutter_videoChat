import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:videollamada/src/models/User.model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:bubble/bubble.dart';

class ChatCoach extends StatefulWidget {
  final WebSocketChannel channel;

  const ChatCoach({Key key, @required this.channel})
      : assert(channel != null),
        super(key: key);

  @override
  _ChatCoachState createState() => _ChatCoachState();
}

class _ChatCoachState extends State<ChatCoach> {
  TextEditingController _controllerTextField = TextEditingController();
  final WebSocketChannel channel;
  List<UserChat> _messages = [];

  _ChatCoachState({this.channel}) {
    channel.stream.listen((data) {
      setState(() {
        print(data);
        // __messages.add(data);
      });
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    _controllerTextField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Stack(
          children: <Widget>[
            infoTolbar(),
            // getMessageList(),
            inputMessage()
          ],
        ),
      );

  ListView getMessageList() {
    List<Widget> listWidget = [];

    for (UserChat user in _messages) {
      listWidget.add(ListTile(
        title: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              user.message,
              style: TextStyle(fontSize: 22),
            ),
          ),
          color: Colors.teal[50],
          height: 60,
        ),
      ));
    }

    return ListView(children: listWidget);
  }

  Widget infoTolbar() {
    return FractionallySizedBox(
      heightFactor: 0.5,
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Bubble(
              color: Color.fromRGBO(212, 234, 244, 1.0),
              child: Text('CHAT',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.0)),
            ),
          ),
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: CircleAvatar(
                    backgroundColor: Colors.blue.shade400,
                    child: Text(
                      'CH',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Text(
                      'AM',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ]),
        ],
      ),
    );
  }

  Widget inputMessage() {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: TextFormField(
                controller: _controllerTextField,
                keyboardType: TextInputType.text,
                autofocus: true,
                style: TextStyle(
                    fontWeight: FontWeight.normal, color: Colors.black),
                decoration: InputDecoration(
                  labelText: "Mensaje",
                  hintText: "Mensaje",
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                ),
              ),
            ),
            FloatingActionButton(
              backgroundColor: Colors.blue[300],
              onPressed: _sendMessage,
              child: Icon(Icons.send, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_controllerTextField.text.isNotEmpty) {
      var obj = {"name": "other man", "msg": "${_controllerTextField.text}"};
      var data = json.encode(obj);
      channel.sink.add(data);
    }
    _controllerTextField.text = '';
  }
}
