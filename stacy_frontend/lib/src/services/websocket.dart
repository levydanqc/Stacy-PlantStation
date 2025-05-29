class Controller {
  Controller._privateConstructor();

  factory Controller() => _singleton;

  static final Controller _singleton = Controller._privateConstructor();

  late Function setState;

  void initSetState(initSetState) => setState = initSetState;
}
