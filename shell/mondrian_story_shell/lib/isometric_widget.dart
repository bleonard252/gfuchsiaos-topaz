// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// 60-30 isometric projection matrix
final Matrix4 _iso = new Matrix4.identity()
  ..rotateX(60 * pi / 180.0)
  ..rotateZ(30 * pi / 180.0);

/// Widget that performs an isometric transformation on a Widget,
/// scaling it so that it fits within the bounds of its original rectangle
class IsoMetric extends StatelessWidget {
  /// The child to transform
  final Widget child;

  /// This size to draw the widget in orthographic projection
  final double scaleFactor;

  /// Constructor
  const IsoMetric({@required this.child, this.scaleFactor: 4.0});

  @override
  Widget build(BuildContext context) => new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          BoxConstraints _scaledConstraints = constraints * scaleFactor;
          return new FittedBox(
            fit: BoxFit.scaleDown,
            child: new Container(
              constraints: _scaledConstraints,
              child: new Transform(
                child: child,
                transform: _getTransformation(constraints: _scaledConstraints),
                origin: _scaledConstraints.biggest.center(Offset.zero),
              ),
            ),
          );
        },
      );

  /// Get the isometric transformation to apply to the views
  Matrix4 _getTransformation({BoxConstraints constraints}) {
    // Scale the transformation so the views fit in the original rectangles
    Rect constraintsRect = Offset.zero & constraints.biggest;
    Rect transRect = MatrixUtils.transformRect(
      _iso,
      constraintsRect,
    );
    double isoScale = min(constraintsRect.height / transRect.height,
        constraintsRect.width / transRect.width);
    return new Matrix4.copy(_iso)..scale(isoScale);
  }
}
