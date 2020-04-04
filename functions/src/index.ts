import * as functions from 'firebase-functions';
import * as request from 'request-promise';
import { OptionsWithUri } from 'request';

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

const lastFMOptions: OptionsWithUri = {
  uri: 'https://ws.audioscrobbler.com/2.0',
  qs: {
    api_key: functions.config().lastfm.api_key,
    format: 'json',
    method: null,
  },
  headers: {
    'User-Agent': 'TormentedPlayerAPI/1.0.0',
  },
  json: true,
};

const trStatusOptions: OptionsWithUri = {
  uri: 'http://stream2.mpegradio.com:8070/7.html',
  headers: {
    'User-Agent': 'TormentedPlayerAPI/1.0.0',
  },
};

// Get track info from LastFM
const getLastFMTrack = async (title: String, artist: String) => {
  const options = {...lastFMOptions};
  options.qs.method = 'track.getInfo';
  options.qs.track = title;
  options.qs.artist = artist;
  
  const lastFMInfo = await request(options);
  const imageObj = lastFMInfo.track.album?.image?.find((img: any) => img.size === 'extralarge') ?? {};
  
  return {
    title,
    artist,
    album: lastFMInfo.track.album?.title ?? null,
    image: imageObj['#text'] ?? null,
  };
};

// Get additional information (album, image) on a track
export const getTrack = functions.https.onRequest(async (req, res) => {
  const title: String = req.query.title;
  const artist: String = req.query.artist;
  
  if (!title || !artist) {
    res.status(400).send({ error: 'Bad request - Missing track title or artist.' });
  }
  
  try {
    // Get data from LastFM
    const track = await getLastFMTrack(title, artist);
    
    // Cache the response for 1 month
    res.set('Cache-Control', 'public, max-age=2592000, s-maxage=2592000');
    res.status(200).send(track);
  } catch(err) {
    // TODO handle status code of LastFM request
    res.status(500).send({ error: 'Internal server error' });
  }
});

// Get the current track from Tormented Radio and fetch additional info from LastFM
export const getCurrentTrack = functions.https.onRequest(async (req, res) => {
  try {
    const trResponse: String = await request(trStatusOptions);

    // No need to use DOMParser for this (for now)
    const matches = trResponse.match(RegExp('^<html><body>(.*)<\/body><\/html>$'));

    if (matches == null) {
      throw Error('Tormented Radio status data not found');
    }

    // Take the track's artist/title, considering that they could contain the ',' character
    const currentSong = matches[1].split(',').slice(6).join(',');
    const [artist, title] = currentSong.split(' - ');

    // Get data from LastFM
    const track = await getLastFMTrack(title, artist);

    // Cache the response for 10 seconds
    res.set('Cache-Control', 'public, max-age=10');
    res.status(200).send(track);
  } catch(err) {
    res.status(500).send({ error: 'Internal server error' });
  }
});
