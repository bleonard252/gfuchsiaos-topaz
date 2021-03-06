// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:chat_conversation_list/fixtures.dart';
import 'package:chat_conversation_list/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'Test to see if tapping on a ChatConversationListItem will call the '
      'appropiate callback', (WidgetTester tester) async {
    ChatConversationFixtures fixtures = new ChatConversationFixtures();

    Key chatConversationListItemKey = new UniqueKey();

    int taps = 0;

    await tester.pumpWidget(
      new MaterialApp(
        home: new Material(
          child: new Center(
            child: new ChatConversationListItem(
              key: chatConversationListItemKey,
              conversation: fixtures.conversation(),
              onSelect: () {
                taps++;
              },
            ),
          ),
        ),
      ),
    );

    expect(taps, 0);
    await tester.tap(find.byKey(chatConversationListItemKey));
    expect(taps, 1);
  });
}
