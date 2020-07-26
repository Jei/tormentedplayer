import 'package:audio_service/audio_service.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tormentedplayer/resources/radio.dart';
import 'package:tormentedplayer/services/audio.dart';

class MockAudioClient extends Mock implements AudioClient {}

main() {
  // resources/radio.dart
  group('Radio', () {
    group('start', () {
      test('Starts the audio client if it\'s inactive', () {
        final client = MockAudioClient();
        final radio = Radio(client);

        when(client.playbackState).thenReturn(PlaybackState(
          processingState: AudioProcessingState.none,
          actions: null,
          playing: false,
        ));

        radio.start();
        verify(client.start());
      });

      test('Starts the audio client if it\'s stopped', () {
        final client = MockAudioClient();
        final radio = Radio(client);

        when(client.playbackState).thenReturn(PlaybackState(
          processingState: AudioProcessingState.stopped,
          actions: null,
          playing: false,
        ));

        radio.start();
        verify(client.start());
      });

      test('Starts the audio client if it\'s in an error state', () {
        final client = MockAudioClient();
        final radio = Radio(client);

        when(client.playbackState).thenReturn(PlaybackState(
          processingState: AudioProcessingState.error,
          actions: null,
          playing: false,
        ));

        radio.start();
        verify(client.start());
      });

      test('Plays audio if the audio client paused', () {
        final client = MockAudioClient();
        final radio = Radio(client);

        when(client.playbackState).thenReturn(PlaybackState(
          processingState: AudioProcessingState.ready,
          actions: null,
          playing: false,
        ));

        radio.start();
        verify(client.play());
      });
    });
  });
}
