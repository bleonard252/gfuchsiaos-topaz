// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library fuchsia_builtin;

import 'dart:async';
import 'dart:_internal' show VMLibraryHooks;

// Corelib 'print' implementation.
void _print(arg) {
  _Logger._printString(arg.toString());
}

class _Logger {
  static void _printString(String s) native "Logger_PrintString";
}

String _rawScript;
Uri _scriptUri() {
  if (_rawScript.startsWith('http:') ||
      _rawScript.startsWith('https:') ||
      _rawScript.startsWith('file:')) {
    return Uri.parse(_rawScript);
  } else {
    return Uri.base.resolveUri(new Uri.file(_rawScript));
  }
}

void _scheduleMicrotask(void callback()) native "ScheduleMicrotask";
_getScheduleMicrotaskClosure() => _scheduleMicrotask;

_setupHooks() {
  VMLibraryHooks.platformScript = _scriptUri;
}

_getPrintClosure() => _print;
