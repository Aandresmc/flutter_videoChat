import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:videollamada/src/models/User.model.dart';
import 'package:mobx/mobx.dart';
part 'chat.store.g.dart';

class ChatStore = _ChatStore with _$ChatStore;

abstract class _ChatStore with Store {
  
  final requestJoinRoom = { 'idCoach': "18", 'hash': "124",'idCoach': "18", 'coach': "Sofia Rodriguez", 'idPaciente': '86586', 'paciente': 'Andres Mora Castro', 'soyPaciente': true };

  @observable
  ObservableList<UserChat> messages = ObservableList<UserChat>();

  @observable
  IO.Socket _socket = IO.io('http://192.168.1.67:3001/chat', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': true,
    'extraHeaders': { 'hash' : "124", 'soyPaciente' : true} // optional
  });

  final String _me = 'Andresmc';
  @computed
  String get me => _me;

  @observable
  bool _chatIniciado = false;
  @computed
  bool get chatInit => _chatIniciado;

  @observable
  bool _newMessage = false;
  @computed
  bool get newMessage => _newMessage;

  @observable
  bool hiddenSend = false;
  

 @action
  hiddenBtnSend(bool state) {
    hiddenSend = state;
  }

  @action
  sendMessage(json) {
    _socket.emit('sendMessage', json);
  }

  @action
  joinChat() {
    // inicio chat
    _socket.on('chatInit', (status) => _chatIniciado = status);

    // mensaje bienvenida
    _socket.on('welcome', (message) {
      UserChat data = UserChat.fromJson(message);
      messages.add(data);
    });

    //mensajes
    _socket.on('message', (message) {
      UserChat data = UserChat.fromJson(message);
      messages.add(data);
    });

    // error al unirse al chat
    _socket.on('end', (status) => print('message server: $status'));

    //usuarios eliminados
    _socket.on(
        'deleteUser', (deleteUser) => print('message server: $deleteUser'));

    listenStatusSocket();
  }

  listenStatusSocket() {
    _socket.on('connect', (_) {
      print('status connect');
      _socket.emit('joinRoom', requestJoinRoom);
    });

    _socket.on('connecting', (status) => print('connecting: $status'));
    _socket.on('connect_error', (error) => print('error Connect: $error'));

    _socket.on('connect_timeout', (status) {
      print('connect_timeout: $status');
      print('volviendo a conectar ...');
      _socket.io
        ..disconnect()
        ..connect(); // reconectar manualmente
    });

    _socket.on('disconnect', (_) => print('status disconnect'));
  }
}
