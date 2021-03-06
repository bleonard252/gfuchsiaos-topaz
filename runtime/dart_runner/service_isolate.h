// Copyright 2018 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef APPS_DART_CONTENT_HANDLER_SERVICE_ISOLATE_H_
#define APPS_DART_CONTENT_HANDLER_SERVICE_ISOLATE_H_

#include "third_party/dart/runtime/include/dart_api.h"

namespace dart_content_handler {

Dart_Isolate CreateServiceIsolate(const char* uri,
                                  Dart_IsolateFlags* flags,
                                  char** error);

Dart_Handle GetVMServiceAssetsArchiveCallback();

}  // namespace dart_content_handler

#endif  // APPS_DART_CONTENT_HANDLER_SERVICE_ISOLATE_H_
