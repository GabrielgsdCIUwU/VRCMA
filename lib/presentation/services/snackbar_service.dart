import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/main.dart';

class SnackbarService {
  void show(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message))
    );
  }
}

final snackbarServiceProvider = Provider((ref) => SnackbarService());