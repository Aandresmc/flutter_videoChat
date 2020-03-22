import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:videollamada/src/pages/call_coach/ui/chat.dart';
import 'package:videollamada/src/pages/call_coach/widgets/toolbar_videochat.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'package:videollamada/src/utils/settings.dart';
import 'package:videollamada/src/models/User.model.dart';

class VideoCallPage extends StatefulWidget {
  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage>
    with SingleTickerProviderStateMixin {
  final WebSocketChannel _channel =
      IOWebSocketChannel.connect('ws://192.168.1.67:8080');
  AnimationController _animateController;
  List<UserAgora> _users = [];
  final List<Map<String, dynamic>> _infoChat = [];
  double _height, _width;
  bool muted = false;
  bool _showToolbar = true;
  bool _primaryVideo = false;

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
    _animateController.addListener(() => this.setState(() {}));

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
        _users.add(UserAgora(id: uid, userName: uid.toString()));
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
      primary = _primaryVideo ? views[0] : views[1];
      secondary = _primaryVideo ? views[1] : views[0];
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
                    infinite: _users.isNotEmpty,
                    child: IconButton(
                      icon: Stack(
                        children: <Widget>[
                          Icon(Icons.chat),
                          Positioned(
                            top: -1.0,
                            right: -1.0,
                            child: Stack(
                              children: <Widget>[
                                _users.isNotEmpty
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
      endDrawer: Drawer(
          child: ChatCoach(
        channel: _channel,
      )),
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
                            child: ToolbarVideoChat()),
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
                              child: ToolbarVideoChat()),
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
    _users.forEach((UserAgora user) => list.add(AgoraRenderWidget(user.id)));
    return list;
  }

  Widget _smallVideo(view) {
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
}
