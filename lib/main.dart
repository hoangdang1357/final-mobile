import 'package:expense_tracker/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'option_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                OptionProvider()), // Thêm Provider cho OptionProvider
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      ),
    );
  }
}
