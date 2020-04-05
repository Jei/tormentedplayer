import * as functions from 'firebase-functions';
import * as request from 'request-promise';
import { OptionsWithUri } from 'request';
import express = require('express');
import DomParser = require('dom-parser');
import * as he from 'he';

const parser = new DomParser();

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

class HttpError extends Error {
  status: number;
  message: string;
  
  constructor(status: number, message: string) {
    super(message);
    this.status = status;
    this.message = message;
    Error.captureStackTrace(this, HttpError);
  }
}

// Get track info from LastFM
const getLastFMTrack = async (title: String, artist: String) => {
  const options = {...lastFMOptions};
  options.qs.method = 'track.getInfo';
  options.qs.track = title;
  options.qs.artist = artist;
  
  const lastFMInfo = await request(options);
  if (lastFMInfo.error || !lastFMInfo.track) {
    throw new HttpError(404, lastFMInfo.message || 'Invalid LastFM data.');
  }
  
  const imageObj = lastFMInfo.track.album?.image?.find((img: any) => img.size === 'extralarge') ?? {};
  
  return {
    title,
    artist,
    album: lastFMInfo.track.album?.title ?? null,
    image: imageObj['#text'] ?? null,
  };
};

// EXPRESS
const app = express();
const v1 = express.Router();

// Get additional information (album, image) from LastFM on a track
v1.get('/track', async (req, res, next) => {
  try {
    const title: String = req.query.title;
    const artist: String = req.query.artist;
    
    if (!title || !artist) {
      throw new HttpError(403, 'Missing track title or artist.');
    }
    // Get data from LastFM
    const track = await getLastFMTrack(title, artist);
    
    // Cache the response for 1 month
    res.set('Cache-Control', 'public, max-age=2592000');
    res.json(track);
  } catch(err) {
    next(err);
  }
});

// Get the current track from Tormented Radio and fetch additional info from LastFM
v1.get('/track/current', async (_req, res, next) => {
  try {
    const trResponse: string = await request(trStatusOptions);
    
    const tags = parser.parseFromString(trResponse).getElementsByTagName('body');
    const status = tags && tags.length ? he.decode(tags[0]?.textContent) : null;
    
    if (!status) {
      throw new HttpError(503, 'Tormented Radio status data not found.');
    }
    
    // Take the track's artist/title, considering that they could contain the ',' character
    const currentSong = status.split(',').slice(6).join(',');
    const [artist, title] = currentSong.split(' - ');
    
    // Get data from LastFM
    const track = await getLastFMTrack(title, artist)
    .catch((_) => {
      // Ignore LastFM errors
      return {
        title,
        artist,
        album: null,
        image: null,
      }
    });
    
    // Cache the response for 10 seconds
    res.set('Cache-Control', 'public, max-age=10');
    res.json(track);
  } catch(err) {
    next(err);
  }
});

// Error handler
v1.use((err: HttpError, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  const { status, message } = err;
  res.status(status).json({
    status,
    message,
  });
});

app.use('/api/v1', v1);

exports.api = functions.https.onRequest(app);
