// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/ai_coach_screen.dart';
import 'screens/settings_screen.dart';
import 'services/ble_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // reads S0.3's local, git-ignored keys
  runApp(const ScribeSenseApp());
}

class ScribeSenseApp extends StatelessWidget {
  const ScribeSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // S1.2 — BLE client; single instance shared across all screens
        Provider<BleService>(
          create: (_) => BleService(),
          dispose: (_, svc) => svc.dispose(),
        ),
        // S1.3, S2.2 — db / session providers added here next
      ],
      child: MaterialApp(
        title: 'ScribeSense',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
        home: const RootNav(),
      ),
    );
  }
}

class RootNav extends StatefulWidget {
  const RootNav({super.key});
  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    HistoryScreen(),
    AiCoachScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.edit), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.smart_toy), label: 'AI Coach'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}