import 'package:grocery_app/auth.dart';
import 'package:grocery_app/pages/home_page.dart';
import 'package:grocery_app/pages/login_register_page.dart';
import 'package:flutter/material.dart';

// Stateful widget representing the widget tree for managing app navigation
class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  // Create the state for the WidgetTree
  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

// State class for the WidgetTree
class _WidgetTreeState extends State<WidgetTree> {
  @override
  // Build method to define the UI of the WidgetTree
  Widget build(BuildContext context) {
    // StreamBuilder to listen for changes in authentication state
    return StreamBuilder(
      // Use the authStateChanges stream from the Auth class
      stream: Auth().authStateChanges,
      // Builder function to handle snapshot data and return appropriate widget
      builder: (context, snapshot) {
        // Check if there is authenticated user data
        if (snapshot.hasData) {
          // If authenticated, show the HomePage
          return HomePage();
        } else {
          // If not authenticated, show the LoginPage
          return const LoginPage();
        }
      },
    );
  }
}
