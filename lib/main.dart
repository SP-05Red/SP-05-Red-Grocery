import 'package:firebase_core/firebase_core.dart';
import 'package:grocery_app/widget_tree.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

// Asynchronous function to initialize Firebase and run the application
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Run the application with MyApp as the root widget
  runApp(const MyApp());
}

// Root widget representing the entire application
class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  // This widget is the root of your application
  // Build method for MyApp to define the application's UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // The theme for the entire application
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 177, 162, 117),
        // Change the background color to RGB 146, 210, 238
        scaffoldBackgroundColor: Color.fromARGB(255, 146, 210, 238),
        // Set the app bar theme to match scaffold background color
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(255, 146, 210, 238),
        ),
      ),
      // Sets WidgetTree as the home page
      home: const WidgetTree(),
    );
  }
}
