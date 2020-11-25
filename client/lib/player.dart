library thing;

import 'dart:async';

import 'package:currents/spotify.dart';
import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

Player globalPlayer;
YoutubeExplode youtube;
VlcPlayerController vlc;

//SpotifySdk spotify
class Track {
  String src;
  String artist;
  String album;
  String title;
  String image;

  Track({String artist, String src, String title, String image}) {
    this.artist = artist;
    this.src = src;
    this.title = title;
    this.image = image;
  }
}

class StreamValues {
  Track currentTrack;
  bool isBuffering;
  bool isPlaying;

  StreamValues(currentTrack, isBuffering, isPlaying) {
    this.currentTrack = currentTrack;
    this.isBuffering = isBuffering;
    this.isPlaying = isPlaying;
  }
}

class Player {
  Track currentTrack;
  bool isBuffering = false;
  bool isPlaying = false;
  StreamController streamController;

  Player._privateLazyConstructor() {
    streamController = new StreamController<StreamValues>();
    youtube = new YoutubeExplode();
    vlc = new VlcPlayerController();
    connectToSpotifyRemote();
  }

  pause() {
    vlc.pause();
    isPlaying = false;
    this.updateUI();
  }

  play([track]) async {
    this.pause();
    isBuffering = true;
    if (track != null) {
      currentTrack = track;
      this.updateUI();
      var manifest = await youtube.videos.streamsClient.getManifest(track.src);
      var streamInfo = manifest.audioOnly.withHighestBitrate();
      if (streamInfo != null) {
        var stream = streamInfo.url;
        var string = stream.toString();
        await vlc.setStreamUrl(string, isLocalMedia: false);
      }
    }
    if (track != null && currentTrack.src != track.src) {
      return;
    }
    vlc.play();
    isPlaying = true;
    isBuffering = false;
    this.updateUI();
  }

  playMediaRef(mediaRef) async {
    final doc = await mediaRef.get();
    if (!doc.exists) {
      print('Failed to find mediaRef');
    }
    final data = await doc.data();
    play(data['url']);
  }

  updateUI() {
    streamController.sink
        .add(StreamValues(currentTrack, isBuffering, isPlaying));
  }
}

class PlayerWidget extends StatefulWidget {
  @override
  _PlayerWidgetState createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  bool isBuffering = false;
  bool isPlaying = false;
  Track currentTrack;

  @override
  void initState() {
    super.initState();
    globalPlayer = new Player._privateLazyConstructor();
    globalPlayer.streamController.stream.listen((values) {
      setState(() {
        currentTrack = values.currentTrack;
        isBuffering = values.isBuffering;
        isPlaying = values.isPlaying;
      });
    });
  }

  @override
  Widget build(BuildContext buildContext) {
    return Container(
      child: Row(
        children: [
          if (currentTrack != null)
            Row(
              children: [
                Image.network(
                  currentTrack.image,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),
                Container(
                  height: 1,
                  width: 1,
                  child: VlcPlayer(
                      controller: vlc,
                      aspectRatio: 16 / 9,
                      url: currentTrack?.src),
                ),
              ],
            ),
          DetailsPane(currentTrack),
          PlayButton(isBuffering, isPlaying)
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
      height: 48.0,
      color: Colors.blueAccent,
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
    );
  }
}

class DetailsPane extends StatelessWidget {
  DetailsPane(this.currentTrack);
  final currentTrack;

  @override
  Widget build(BuildContext buildContext) {
    return Flexible(
      child: Column(
        children: [
          Text(
            currentTrack?.title ?? '',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white),
          ),
          Text(
            currentTrack?.artist ?? '',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      flex: 10,
      fit: FlexFit.tight,
    );
  }
}

class PlayButton extends StatelessWidget {
  final bool isBuffering;
  final bool isPlaying;

  PlayButton(this.isBuffering, this.isPlaying);

  @override
  Widget build(BuildContext buildContext) {
    if (isPlaying) {
      return GestureDetector(
        onTap: () => {globalPlayer.pause()},
        child: Icon(
          Icons.pause_circle_outline,
          color: Colors.white,
          size: 40,
          semanticLabel: 'Pause',
        ),
      );
    }
    if (isBuffering) {
      return Container(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          width: 40,
          height: 28,
          padding: EdgeInsets.symmetric(horizontal: 6));
    }
    return GestureDetector(
      onTap: () => {globalPlayer.play()},
      child: Icon(
        Icons.play_circle_outline,
        color: Colors.white,
        size: 40,
        semanticLabel: 'Play',
      ),
    );
  }
}
