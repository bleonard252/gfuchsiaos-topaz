// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "topaz/app/term/term_params.h"

#include "lib/fxl/strings/string_number_conversions.h"

namespace term {

TermParams::TermParams() {}

TermParams::~TermParams() {}

bool TermParams::Parse(const fxl::CommandLine& command_line) {
  // --font-size=<size>
  std::string value;
  if (command_line.GetOptionValue("font-size", &value) &&
      !fxl::StringToNumberWithError(value, &font_size)) {
    return false;
  }

  // <command> <args...>
  if (!command_line.positional_args().empty()) {
    command = command_line.positional_args();
  }
  return true;
}

}  // namespace term
