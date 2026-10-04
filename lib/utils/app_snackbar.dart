import 'dart:async';

import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void showAppSnackBar(
  String message, {
  IconData? icon,
  String? actionLabel,
  VoidCallback? onAction,
  double bottomMargin = 16,
}) {
  final messenger = scaffoldMessengerKey.currentState;
  if (messenger == null) {
    debugPrint('SnackBar skipped: messenger is null');
    return;
  }
  messenger.clearSnackBars();
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 3),
    dismissDirection: DismissDirection.horizontal,
    backgroundColor: const Color(0xFF16221F),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    margin: EdgeInsets.fromLTRB(16, 0, 16, bottomMargin),
    content: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: const Color(0xFF34D399), size: 20),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
    action: actionLabel == null
        ? null
        : SnackBarAction(
            label: actionLabel,
            textColor: const Color(0xFF34D399),
            onPressed: onAction ?? () {},
          ),
  );
  final controller = messenger.showSnackBar(snackBar);
  Timer(const Duration(seconds: 3), () {
    try {
      controller.close();
    } catch (_) {}
  });
  debugPrint('SnackBar shown: $message');
}
