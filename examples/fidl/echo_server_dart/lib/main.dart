// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:echo2/echo2.fidl.dart';
import 'package:fidl/fidl.dart';
import 'package:lib.app.dart/app.dart';

class _EchoImpl extends Echo {
  final EchoBinding _binding = new EchoBinding();

  void bind(InterfaceRequest<Echo> request) {
    _binding.bind(this, request);
  }

  @override
  // ignore: non_constant_identifier_names
  void EchoString(String value, void callback(String response)) {
    print('EchoString: $value');
    callback(value);
  }
}

ApplicationContext _context;
_EchoImpl _echo;

void main(List<String> args) {
  _context = new ApplicationContext.fromStartupInfo();
  _echo = new _EchoImpl();
  _context.outgoingServices.addServiceForName2<Echo>(_echo.bind, 'echo2.Echo');
}
