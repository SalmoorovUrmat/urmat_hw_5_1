import 'package:flutter/material.dart';
import 'package:urmat_hw_5_1/news_list_screen.dart';

void main() {
  runApp(const BookApp());
}

class BookApp extends StatelessWidget {
  const BookApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News App UI',
      theme: ThemeData(fontFamily: 'Georgia'),
      home: const NewsListScreen(),
    );
  }
}
