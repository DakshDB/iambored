import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iambored/LifeGame/home.dart';
import 'home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'I am Bored',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Primary color black
        primaryColor: Colors.black,

      ),
      home: const Home(),
    );
  }
}

