import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/map/presentation/saga_map_screen.dart';
import 'core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Bloquear orientación vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Inicializar Backend (Supabase)
  // Nota: Esto fallará si no se configuran las KEYS en core/constants/env.dart
  try {
    await SupabaseService.initialize();
  } catch (e) {
    print("Supabase Init Error (Keys missing?): $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vision Therapy Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SagaMapScreen(),
    );
  }
}
