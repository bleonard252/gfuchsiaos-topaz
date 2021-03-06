// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:concert_api/api.dart';
import 'package:concert_models/concert_models.dart';
import 'package:concert_widgets/concert_widgets.dart';
import 'package:lib.context.fidl/context_writer.fidl.dart';
import 'package:lib.module.fidl/module_context.fidl.dart';
import 'package:lib.module.fidl._module_controller/module_controller.fidl.dart';
import 'package:lib.story.fidl/link.fidl.dart';
import 'package:lib.surface.fidl/surface.fidl.dart';
import 'package:lib.user_intelligence.fidl/intelligence_services.fidl.dart';
import 'package:lib.widgets/modular.dart';
import 'package:web_view/web_view.dart' as web_view;

/// The context topic for "Music Artist"
const String _kMusicArtistTopic = 'music_artist';

/// The context topic for location
const String _kLocationTopic = 'location';

/// The Entity type for a music artist.
const String _kMusicArtistType = 'http://types.fuchsia.io/music/artist';

/// The Entity type for a location
const String _kLocationType = 'http://types.fuchsia.io/location';

const String _kContextLinkName = 'location_context';

const String _kWebViewLinkName = 'web_view';

/// [ModuleModel] that manages the state of the Event Module.
class EventPageModuleModel extends ModuleModel {
  /// Constructor
  EventPageModuleModel({this.apiKey}) : super();

  /// API key for Songkick APIs
  final String apiKey;

  /// The event for this given module
  Event _event;

  /// Get the event
  Event get event => _event;

  LoadingStatus _loadingStatus = LoadingStatus.inProgress;

  /// Get the current loading status
  LoadingStatus get loadingStatus => _loadingStatus;

  final LinkProxy _contextLink = new LinkProxy();

  LinkProxy _webViewLink;

  final ModuleControllerProxy _webViewModuleController =
      new ModuleControllerProxy();

  /// Retrieves the full event based on the given ID
  Future<Null> fetchEvent(int eventId) async {
    try {
      _event = await Api.getEvent(eventId, apiKey);
      if (_event != null) {
        _loadingStatus = LoadingStatus.completed;
      } else {
        _loadingStatus = LoadingStatus.failed;
      }
    } on Exception {
      _loadingStatus = LoadingStatus.failed;
    }

    _publishLocationContext();
    _publishArtistContext();
    notifyListeners();
  }

  @override
  void onReady(
    ModuleContext moduleContext,
    Link link,
  ) {
    super.onReady(moduleContext, link);

    // Setup the Context Link
    moduleContext.getLink(_kContextLinkName, _contextLink.ctrl.request());
  }

  /// Fetch the event whenever the eventId is updated in the link
  @override
  void onNotify(String encoded) {
    final dynamic doc = json.decode(encoded);
    if (doc is Map && doc['songkick:eventId'] is int) {
      fetchEvent(doc['songkick:eventId']);
    }
  }

  void _publishArtistContext() {
    ContextWriterProxy writer = new ContextWriterProxy();
    IntelligenceServicesProxy intelligenceServices =
        new IntelligenceServicesProxy();
    moduleContext.getIntelligenceServices(intelligenceServices.ctrl.request());
    intelligenceServices.getContextWriter(writer.ctrl.request());

    if (event != null && event.performances.isNotEmpty) {
      if (event.performances.first.artist?.name != null) {
        // TODO(thatguy): It would be better to maintain a separate context
        // value without a topic at all, but this method is easy to use. The
        // consumer of this context value only looks at the Entity type.
        writer.writeEntityTopic(
          _kMusicArtistTopic,
          json.encode(
            <String, String>{
              '@type': _kMusicArtistType,
              'name': event.performances.first.artist.name,
            },
          ),
        );
      }
    }
    writer.ctrl.close();
    intelligenceServices.ctrl.close();
  }

  void _publishLocationContext() {
    if (event != null && event.venue != null) {
      Map<String, dynamic> contextLinkData = <String, dynamic>{
        '@context': <String, dynamic>{
          'topic': _kLocationTopic,
        },
        '@type': _kLocationType,
        'longitude': event.venue.longitude,
        'latitude': event.venue.latitude,
      };
      _contextLink.set(null, json.encode(contextLinkData));
    }
  }

  /// Opens web view module to purchase tickets
  void purchaseTicket() {
    if (event != null && event.url != null) {
      String linkData = json.encode(<String, Map<String, String>>{
        'view': <String, String>{'uri': event.url},
      });

      if (_webViewLink == null) {
        _webViewLink = new LinkProxy();
        moduleContext.getLink(_kWebViewLinkName, _webViewLink.ctrl.request());
        _webViewLink.set(null, linkData);
        moduleContext.startModuleInShellDeprecated(
          'Purchase Web View',
          web_view.kWebViewURL,
          _kWebViewLinkName,
          null, // incomingServices,
          _webViewModuleController.ctrl.request(),
          const SurfaceRelation(arrangement: SurfaceArrangement.sequential),
          true,
        );
      } else {
        _webViewLink.set(null, linkData);
      }
      _webViewModuleController.focus();
    }
  }
}
