enum AppLifecycleSignal { resumed, inactive, paused, detached }

abstract interface class PlatformLifecycleService {
  Stream<AppLifecycleSignal> get signals;
}
