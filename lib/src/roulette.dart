/// Copyright 2021 do9core
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///    http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

import 'package:flutter/material.dart';
import 'package:roulette/roulette.dart';

import 'roulette_paint.dart';

/// This is an static roulette widget.
///
/// You can write your customized logic
/// that provide the rotation value to controll its rolling behavior.
class Roulette extends StatelessWidget {
  const Roulette({
    Key? key,
    required this.group,
    this.rotation = 0,
    this.style = const RouletteStyle(),
  }) : super(key: key);

  /// The rotation of the roulette.
  final double rotation;

  /// The display group of the roulette.
  final RouletteGroup group;

  /// The display style of the roulette.
  final RouletteStyle style;

  @override
  Widget build(BuildContext context) {
    return RoulettePaint(
      rotation: rotation,
      style: style,
      group: group,
    );
  }
}
