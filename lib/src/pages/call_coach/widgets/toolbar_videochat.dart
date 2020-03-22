import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class ToolbarVideoChat extends StatefulWidget {
  @override
  _ToolbarVideoChatState createState() => _ToolbarVideoChatState();
}

class _ToolbarVideoChatState extends State<ToolbarVideoChat> {
  bool _muted = false;
  bool _offCam = false;
  bool _switchCamera = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(bottom: 20),
            child: RawMaterialButton(
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
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RawMaterialButton(
                onPressed: _onSwitchCamera,
                child: Icon(
                  Icons.switch_camera,
                  color: _switchCamera ? Colors.white : Colors.white30,
                  size: 28,
                ),
                shape: CircleBorder(),
                fillColor: _switchCamera ? Colors.white38 : null,
                padding: const EdgeInsets.all(18),
              ),
              RawMaterialButton(
                onPressed: () => _onToggleCamOff(),
                child: Icon(
                  Icons.videocam_off,
                  color: _offCam ? Colors.white : Colors.white38,
                  size: 28,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: _offCam ? Colors.white38 : null,
                padding: const EdgeInsets.all(18),
              ),
              RawMaterialButton(
                onPressed: _onToggleMute,
                child: Icon(
                  Icons.mic_off,
                  color: _muted ? Colors.white : Colors.white38,
                  size: 28,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: _muted ? Colors.white38 : null,
                padding: const EdgeInsets.all(18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onSwitchCamera() {
    setState(() => _switchCamera = !_switchCamera);
    AgoraRtcEngine.switchCamera();
  }

  void _onToggleMute() {
    setState(() => _muted = !_muted);
    AgoraRtcEngine.muteLocalAudioStream(_muted);
  }

  void _onToggleCamOff() {
    setState(() => _offCam = !_offCam);
    _offCam ? AgoraRtcEngine.disableVideo() : AgoraRtcEngine.enableVideo();
  }
}
