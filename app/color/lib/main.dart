// Copyright 2018 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:lib.app_driver.dart/module_driver.dart';
import 'package:lib.logging/logging.dart';
import 'package:lib.widgets/model.dart' show ScopedModel, ScopedModelDescendant;

import 'src/color_model.dart';
import 'src/parse_int.dart';

/// The amount of time between color updates.
const Duration _kUpdateDuration = const Duration(seconds: 5);

/// This codec is used by the [ModuleDriver] to automatically translate values
/// to and from an Entity's source data.
final EntityCodec<Color> codec = new EntityCodec<Color>(
  type: 'com.fuchsia.color',
  encode: (Color color) => color.value.toString(),
  decode: (String data) => new Color(parseInt(data)),
);

/// Main entry point to the color module.
void main() {
  setupLogger(
    name: 'color',
  );

  /// The [ColorModel] holds UI state and automatically triggers a re-render of
  /// Flutter's widget tree when attributes are updated.
  ColorModel model = new ColorModel();

  /// The [ModuleDriver] provides an idiomatic Dart API encapsulating
  /// boilerplate and book keeping required for FIDL service interactions.
  ModuleDriver module = new ModuleDriver();

  /// Use [ColorEntity#watch] to access a stream of change events for the
  /// 'color' Link's Entity updates. Since this module updates it's own Entity
  /// value the `all` param is set to true.
  module.watch('color', codec, all: true).listen(
        (Color color) => model.color = color,
        cancelOnError: true,
        onError: handleError,
        onDone: () => log.info('update stream closed'),
      );

  /// When the module is ready (listeners and async event listeners have been
  /// added etc.) it is connected to the Fuchsia's application framework via
  /// [module#start()]. When a module is "started" it is expressly stating it is
  /// in a state to handle incoming requests from the framework to it's
  /// underlying interfaces (Module, Lifecycle, etc.) and that it is in a
  /// position to handling UI rendering and input.
  module.start().then(handleStart, onError: handleError);

  runApp(new ScopedModel<ColorModel>(
    model: model,
    child: new ScopedModelDescendant<ColorModel>(
      builder: (BuildContext context, Widget child, ColorModel model) {
        return new Container(color: model.color);
      },
    ),
  ));
}

/// Generic error handler.
// TODO(SO-1123): hook up to a snackbar.
void handleError(Error error, StackTrace stackTrace) {
  log.severe('An error ocurred', error, stackTrace);
}

///
void handleStart(ModuleDriver module) {
  /// Once the module is ready to interact with the rest of the system,
  /// periodically update the color value stored in the Link that the module was
  /// started with.
  log.info('module ready, link values will periodically update');

  /// Change the [entity]'s value to a random color periodically.
  new Timer.periodic(_kUpdateDuration, (_) async {
    Random rand = new Random();
    Color color = new Color.fromRGBO(
      rand.nextInt(255), // red
      rand.nextInt(255), // green
      rand.nextInt(255), // red
      1.0,
    );

    return module.put('color', color, codec).then(
        (String ref) => log.fine('updated entity: $ref'),
        onError: handleError);
  });
}
