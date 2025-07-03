import 'package:flutter/material.dart' hide Icon, Icons;
import 'package:output/src/widgets/app_icon.g.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<void> init = AppIcon.precache(context);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: init,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState != ConnectionState.done) {
          return SizedBox();
        }
        return MaterialApp(title: 'Demo', home: const Home());
      },
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var width = 48.0;
  Color? color;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: color != null,
                onChanged: (v) {
                  final newColor = color == null ? Colors.red : null;
                  setState(() {
                    color = newColor;
                  });
                },
              ),
              Slider(
                value: width,
                min: 12,
                max: 128,
                onChanged: (v) {
                  setState(() {
                    width = v;
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                children: [
                  for (var icon in AppIcons.values)
                    SizedBox(
                      width: width,
                      child: AppIcon(data: icon, color: color),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
