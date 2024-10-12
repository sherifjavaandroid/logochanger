

import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    "checkLogoUpdate",
    "checkLogoUpdate",
    frequency: Duration(hours: 24),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
  runApp(const MyApp());

  // Check for logo update after the app is fully loaded
  WidgetsBinding.instance.addPostFrameCallback((_) {
    LogoService.checkAndUpdateLogo();
  });
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'checkLogoUpdate') {
      await LogoService.checkAndUpdateLogo();
    }
    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Logo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Dynamic Logo Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _checkForLogoUpdate();
  }

  Future<void> _checkForLogoUpdate() async {
    await LogoService.checkAndUpdateLogo();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

    );
  }
}

class LogoService {
  static const String API_URL = 'https://easycourse.net/easycourse/api.php';
  static const platform = MethodChannel('com.example.dynamic_logo_app/icon');

  static final List<Function> _listeners = [];

  static void addListener(Function listener) {
    _listeners.add(listener);
  }

  static void removeListener(Function listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  static Future<void> checkAndUpdateLogo() async {
    final prefs = await SharedPreferences.getInstance();
    final storedVersion = prefs.getString('logo_version') ?? '0';

    try {
      final response = await http.get(Uri.parse(API_URL));
      if (response.statusCode == 200) {
        final newVersion = response.headers['logo-version'];
        final newIconName = response.body;

        if (newVersion != storedVersion) {
          await _updateAppIcon(newIconName);
          await prefs.setString('logo_version', newVersion!);
          await prefs.setString('current_icon', newIconName);
          await prefs.setString('logo_url', newIconName);
          _notifyListeners();
        }
      }
    } catch (e) {
      print('Error checking for logo update: $e');
    }
  }

  static Future<void> _updateAppIcon(String iconName) async {
    try {
      print("Updating app icon to: $iconName");
      await platform.invokeMethod('updateAppIcon', {'iconName': iconName});
      print("App icon update completed");
    } on PlatformException catch (e) {
      print("Failed to update app icon: '${e.message}'.");
    }
  }

  static Future<String> getCurrentIcon() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_icon') ?? 'default';
  }

  static Future<String> getLogoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('logo_url') ?? 'assets/default_icon.png';
  }
}

class LogoWidget extends StatefulWidget {
  const LogoWidget({Key? key}) : super(key: key);

  @override
  _LogoWidgetState createState() => _LogoWidgetState();
}

class _LogoWidgetState extends State<LogoWidget> {
  String _logoUrl = 'assets/default_icon.png';

  @override
  void initState() {
    super.initState();
    _loadLogo();
    LogoService.addListener(_loadLogo);
  }

  @override
  void dispose() {
    LogoService.removeListener(_loadLogo);
    super.dispose();
  }

  Future<void> _loadLogo() async {
    final logoUrl = await LogoService.getLogoUrl();
    if (mounted) {
      setState(() {
        _logoUrl = logoUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _logoUrl,
      width: 100,
      height: 100,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/default_icon.png',
          width: 100,
          height: 100,
        );
      },
    );
  }
}