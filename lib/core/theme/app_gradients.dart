import 'package:flutter/material.dart';

class AppGradients {
  const AppGradients._();

  static const LinearGradient vertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF578BB3), Color(0xFF194F78)],
  );

  static const LinearGradient horizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF578BB3), Color(0xFF194F78)],
  );
}
