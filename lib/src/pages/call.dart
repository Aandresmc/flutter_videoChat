import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import '../utils/settings.dart';

class CallPage extends StatefulWidget {
  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage>
    with SingleTickerProviderStateMixin {
  AnimationController _animateController;
  List<User> _users = [];
  final List<Map<String, dynamic>> _infoChat = [];
  double _height, _width;
  bool muted = false;
  bool _showToolbar = true;
  bool _primaryVideo = false;
  AnimationController animation;

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _animateController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animateController.addListener(() {
      this.setState(() {});
    });

    // initialize agora sdk
    initialize();
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoChat.add({
          'info': 'APP_ID missing, please provide your APP_ID in settings.dart'
        });
        _infoChat.add({'info': 'Agora Engine is not starting'});
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    await AgoraRtcEngine.setParameters(
        '''{\"che.video.hightBitRateStreamParameter\":{\"width\":$_width,\"height\":$_height,\"frameRate\":30,\"bitRate\":100}}''');
    await AgoraRtcEngine.joinChannel(null, 'hashChannel', null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(APP_ID);
    await AgoraRtcEngine.enableVideo();
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _infoChat.add({'info': info});
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid, elapsed $elapsed';
        print('JOIN SUCCESS:' + info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _infoChat.add({'info': 'onLeaveChannel'});
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        print('USER JOIN :' + info);
        _users.add(User(id: uid, userName: uid.toString()));
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoChat.add({'info': info});
        _users.removeWhere((user) => user.id == uid);
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoChat.add({'info': info});
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    Widget primary, secondary;
    final views = _getRenderViews();
    if (views.length > 1) {
      primary = _primaryVideo ? views[1] : views[0];
      secondary = _primaryVideo ? views[0] : views[1];
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _showToolbar
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 150,
              actions: [
                Builder(
                  builder: (context) => Pulse(
                    infinite: !_users.isEmpty,
                    child: IconButton(
                      icon: Stack(
                        children: <Widget>[
                          Icon(Icons.chat),
                          Positioned(
                            top: -1.0,
                            right: -1.0,
                            child: Stack(
                              children: <Widget>[
                                !_users.isEmpty
                                    ? Icon(Icons.brightness_1,
                                        size: 12.0,
                                        color: Colors.purpleAccent.shade400)
                                    : Container(),
                              ],
                            ),
                          )
                        ],
                      ),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      tooltip: MaterialLocalizations.of(context)
                          .openAppDrawerTooltip,
                    ),
                  ),
                ),
              ],
            )
          : null,
      backgroundColor: Colors.black,
      endDrawer: _chat(),
      body: FadeIn(
        manualTrigger: !_showToolbar,
        controller: (controller) => _animateController = controller,
        duration: Duration(seconds: 1),
        child: GestureDetector(
          onDoubleTap: (() => setState(() => _showToolbar = !_showToolbar)),
          child: Center(
            child: views.length == 1
                ? Container(
                    child: Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Expanded(
                              child: Container(child: views[0]),
                            )
                          ],
                        ),
                        FadeInUp(
                            duration: Duration(milliseconds: 500),
                            child: _toolbar()),
                      ],
                    ),
                  )
                : Container(
                    child: Stack(
                      children: <Widget>[
                        Container(child: primary),
                        _smallVideo(secondary),
                        Visibility(
                          visible: _showToolbar,
                          child: FadeInUp(
                              duration: Duration(milliseconds: 500),
                              child: _toolbar()),
                        )
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [
      AgoraRenderWidget(0, local: true, preview: true),
    ];
    _users.forEach((User user) => list.add(AgoraRenderWidget(user.id)));
    return list;
  }

  Widget _smallVideo(view) {
    print('valor primary' + _primaryVideo.toString());
    return Positioned(
      height: _height * .28,
      width: _width * .32,
      right: 10,
      bottom: _showToolbar ? 90 : 20,
      child: GestureDetector(
        onLongPress: (() => setState(() => _primaryVideo = !_primaryVideo)),
        child: ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
            child: view),
      ),
    );
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic : Icons.mic_off,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Stack(
        children: <Widget>[
          FractionallySizedBox(
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
              )),
          ListView.builder(
            reverse: true,
            itemCount: _users.length,
            itemBuilder: (BuildContext context, int index) {
              if (_users.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 20,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                        child: Container(
                      alignment: Alignment.centerRight,
                      child: Bubble(
                        margin: BubbleEdges.only(top: 10),
                        nip: BubbleNip.rightTop,
                        color: Color.fromRGBO(225, 255, 199, 1.0),
                        child: Text(_users[index].userName,
                            textAlign: TextAlign.right),
                      ),
                    )
                        // Bubble(
                        //   margin: BubbleEdges.only(top: 10),
                        //   nip: BubbleNip.leftTop,
                        //   child: Text(_infoChat[index]),
                        // ),
                        )
                  ],
                ),
              );
            },
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      autofocus: true,
                      style: TextStyle(
                          fontWeight: FontWeight.normal, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: "Mensaje",
                        hintText: "Mensaje",
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32.0)),
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    backgroundColor: Colors.blue[300],
                    onPressed: () {},
                    child: Icon(Icons.send, color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chat() {
    return Drawer(child: _panel());
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    AgoraRtcEngine.switchCamera();
  }
}

class User {
  final int id;
  final String userName;

  User({this.id, this.userName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      userName: json['userName'],
    );
  }
}
