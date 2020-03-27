import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:videollamada/di.dart' as di;
import 'package:videollamada/src/models/User.model.dart';
import 'package:bubble/bubble.dart';

class ChatCoach extends StatefulWidget {
  ChatCoach({Key key}) : super(key: key);

  @override
  _ChatCoachState createState() => _ChatCoachState();
}

class _ChatCoachState extends State<ChatCoach> {
  final TextEditingController _controllerTextField = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _chatStore = di.chatStore;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[infoTolbar(), getMessages(), inputMessage()],
    );
  }

  Widget infoTolbar() {
    return _chatStore.chatInit
        ? ElasticIn(
            duration: Duration(milliseconds: 1400),
            child: Container(
              margin: EdgeInsets.only(top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
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
            ),
          )
        : Container();
    // _chatStore.chatInit
  }

  Widget inputMessage() {
    return Observer(
      builder: (_) =>
         !_chatStore.hiddenSend ?  Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Scrollbar(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Colors.blue.shade200,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20))),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Scrollbar(
                        child: TextFormField(
                          scrollPadding: EdgeInsets.symmetric(vertical: 20),
                          maxLines: null,
                          controller: _controllerTextField,
                          style: TextStyle(
                              fontWeight: FontWeight.normal, color: Colors.black),
                          decoration: InputDecoration(
                            prefixIcon:
                                Icon(Icons.message, color: Colors.blueGrey),
                            filled: true,
                            fillColor: Colors.white70,
                            labelText: "Mensaje",
                            hintText: "Escribe ...",
                            labelStyle: TextStyle(color: Colors.blueGrey),
                            contentPadding:
                                EdgeInsets.fromLTRB(15, 15.0, 30.0, 15.0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(32.0)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: FloatingActionButton(
                      backgroundColor: Colors.blueAccent,
                      onPressed:
                          _controllerTextField.text.isEmpty ? null : _sendMessage,
                      child: Icon(Icons.send, color: Colors.white, size: 30),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ) :  Container()
    );
  }

  void _sendMessage() {
    if (_controllerTextField.text.isNotEmpty) {
      UserChat data =
          UserChat(message: _controllerTextField.text, userName: _chatStore.me);
      _chatStore.sendMessage(data.toJson());
      Timer(
          Duration(milliseconds: 1200),
          () => _scrollController
              .jumpTo(_scrollController.position.maxScrollExtent));
    }
    _controllerTextField.text = '';
  }

  Widget getMessages() {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 50),
      child: FractionallySizedBox(
        heightFactor: 0.78,
        alignment: Alignment.center,
        child: Observer(
          builder: (_) => _chatStore.hiddenSend ?
           FadeInLeft(
           child:  NotificationListener(
            child: ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: _chatStore.messages.length,
              padding: EdgeInsets.symmetric(horizontal: 15),
              itemBuilder: (_, index) {
                UserChat chat = _chatStore.messages[index];
                return Bubble(
                  nipWidth: 8,
                  elevation: 1,
                  padding: BubbleEdges.symmetric(vertical: 14),
                  margin: BubbleEdges.only(top: 10),
                  nip: me(chat.userName)
                      ? BubbleNip.rightTop
                      : BubbleNip.leftTop,
                  color: me(chat.userName)
                      ? Colors.blue.shade200
                      : Colors.grey.shade100,
                  child: Text(chat.message,
                      style: TextStyle(
                          color: me(chat.userName)
                              ? Colors.blueGrey
                              : Colors.black),
                      textAlign:
                          me(chat.userName) ? TextAlign.right : TextAlign.left),
                );
              },
            ),
            onNotification: (_) => _chatStore.hiddenBtnSend(false),
           ),
          ) :  Container()
        ),
      ),
    );
  }

  me(String userName) => userName == _chatStore.me;
}
