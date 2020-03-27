import 'package:get_it/get_it.dart';
import 'package:videollamada/src/stores/chat/chat.store.dart';

final GetIt _locator = GetIt.instance;

void init() {
  try {
    _locator.registerSingleton<ChatStore>(ChatStore());
    _locator.isRegistered();
  } catch (e) {
    print(e);
  }
}

ChatStore get chatStore => _locator<ChatStore>();
