import 'package:audio_service/audio_service.dart';
import 'package:tormentedplayer/services/audio.dart';

class RadioBloc {
  static RadioPlaybackState _basicToRadioPlaybackState(
      BasicPlaybackState state) {
    switch (state) {
      case BasicPlaybackState.error:
        return RadioPlaybackState.error;
      case BasicPlaybackState.stopped:
        return RadioPlaybackState.stopped;
      case BasicPlaybackState.paused:
        return RadioPlaybackState.paused;
      case BasicPlaybackState.playing:
        return RadioPlaybackState.playing;
      case BasicPlaybackState.buffering:
        return RadioPlaybackState.buffering;
      case BasicPlaybackState.connecting:
        return RadioPlaybackState.connecting;
      case BasicPlaybackState.fastForwarding:
      case BasicPlaybackState.rewinding:
      case BasicPlaybackState.skippingToPrevious:
      case BasicPlaybackState.skippingToNext:
      case BasicPlaybackState.skippingToQueueItem:
        throw Exception('Unsupported AudioService state');
      default:
        return RadioPlaybackState.none;
    }
  }

  static Stream<RadioPlaybackState> get playbackStateStream =>
      AudioService.playbackStateStream
          .map((state) => _basicToRadioPlaybackState(state?.basicState));

  static start() {
    RadioPlaybackState state =
        _basicToRadioPlaybackState(AudioService.playbackState?.basicState);

    // TODO handle BasicPlaybackState.error case differently
    switch (state) {
      case RadioPlaybackState.paused:
        AudioService.play();
        break;
      case RadioPlaybackState.none:
      case RadioPlaybackState.stopped:
      case RadioPlaybackState.error:
        AudioService.start(
          backgroundTaskEntrypoint: audioPlayerTaskEntryPoint,
          androidNotificationChannelName: 'Tormented Player',
          notificationColor: 0xFF2196f3,
          androidNotificationIcon: 'drawable/ic_notification_radio',
          enableQueue: false,
          androidStopForegroundOnPause: true,
        );
        break;
      default:
        break;
    }
  }

  static stop() {
    AudioService.stop();
  }

  static connect() {
    AudioService.connect();
  }

  static disconnect() {
    AudioService.disconnect();
  }
}

enum RadioPlaybackState {
  none,
  stopped,
  paused,
  playing,
  buffering,
  error,
  connecting,
}
