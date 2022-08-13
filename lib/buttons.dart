import 'package:flutter/material.dart';

Widget buttons(
    {required Color color, required String text, required Function func}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25.0),
    child: GestureDetector(
      onTap: () => func(),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        decoration: BoxDecoration(color: color),
      ),
    ),
  );
}