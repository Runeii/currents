library thing;

import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

final Player globalPlayer = new Player._privateLazyConstructor();
final YoutubeExplode youtube = new YoutubeExplode();
final VlcPlayerController vlc = new VlcPlayerController(
  onInit: () {
    print('Playing');
  },
);

class Player {
  Player._privateLazyConstructor() {
    print('Player lazy setup now');
  }
  play(src) async {
    var manifest = await youtube.videos.streamsClient.getManifest(src);
    var streamInfo = manifest.audioOnly.withHighestBitrate();
    if (streamInfo != null) {
      var stream = streamInfo.url;
      var string = stream.toString();
      print(string);
      vlc.registerChannels(2);
      await vlc.manualInitialize(url: string);
      await vlc.setStreamUrl(string, isLocalMedia: false);
      vlc.play();
    }
  }

  playMediaRef(mediaRef) async {
    final doc = await mediaRef.get();
    if (!doc.exists) {
      print('Failed to find mediaRef');
    }
    final data = await doc.data();
    play(data['url']);
  }
}
