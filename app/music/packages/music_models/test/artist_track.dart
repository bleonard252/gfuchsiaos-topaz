// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert' show json;
import 'dart:io';

import 'package:music_models/music_models.dart';
import 'package:test/test.dart';

void main() {
  test('fromJSON() constructor', () async {
    String rawJson = await new File('mock_json/artist.json').readAsString();
    dynamic decoded = json.decode(rawJson);
    Artist artist = new Artist.fromJson(decoded);
    expect(artist.name, json['name']);
    expect(artist.images[0].url, json['images'][0]['url']);
    expect(artist.genres.contains(json['genres'][0]), true);
    expect(artist.id, json['id']);
    expect(artist.followersCount, json['followers']['total']);
  });
}
