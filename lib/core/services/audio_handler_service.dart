import 'package:audio_service/audio_service.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class MixAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final PlayerController playerController;

  MixAudioHandler(this.playerController) {
    // 1. Listen to the waveform player and tell the Lock Screen what is happening
    playerController.onPlayerStateChanged.listen((state) {
      final isPlaying = state == PlayerState.playing;

      playbackState.add(
        playbackState.value.copyWith(
          playing: isPlaying,
          controls: [
            MediaControl.skipToPrevious,
            isPlaying ? MediaControl.pause : MediaControl.play,
            MediaControl.skipToNext,
          ],
          systemActions: const {MediaAction.seek},
          processingState: AudioProcessingState.ready,
        ),
      );
    });
  }

  // 2. When the user taps PLAY on the lock screen
  @override
  Future<void> play() async => await playerController.startPlayer();

  // 3. When the user taps PAUSE on the lock screen
  @override
  Future<void> pause() async => await playerController.pausePlayer();

  @override
  Future<void> stop() async => await playerController.stopPlayer();

  //4.  When they tap SKIP NEXT on the lock screen or AirPods
  @override
  Future<void> skipToNext() async {
    // We update the customState value to trigger the UI listener!
    customState.add('skipNext_triggered');

    // Reset it immediately so they can skip again later
    await Future.delayed(const Duration(milliseconds: 100));
    customState.add('');
  }

  // 5. Update the Lock Screen text (Title, App Name, and Image!)
  void updateMetadata({required String trackTitle, String? imageUrl}) {
    mediaItem.add(
      MediaItem(
        id: trackTitle,
        title: trackTitle,
        artist: "News Mix", // <-- Put your actual app name here!
        // This tells Android to download the image and use it as the background!
        artUri: imageUrl != null
            ? Uri.parse(imageUrl)
            : Uri.parse(
                'https://images.unsplash.com/photo-1616401784845-180882ba9ba8?q=80&w=500',
              ), // A sleek dark fallback image
      ),
    );
  }
}
