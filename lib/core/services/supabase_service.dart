import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vision_therapy_app/core/constants/env.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  }

  // --- Métodos de Persistencia (Memory Graph) ---

  // Guardar sesión de juego
  Future<void> saveGameSession({
    required String gameId,
    required int score,
    required int durationSec,
    Map<String, dynamic>? metrics,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) return; // Si no hay usuario, guardamos local (PENDIENTE)

    await client.from('game_sessions').insert({
      'user_id': user.id,
      'game_id': gameId,
      'score': score,
      'duration_seconds': durationSec,
      'metrics': metrics, // JSONB
      'played_at': DateTime.now().toIso8601String(),
    });
  }

  // Obtener historial para gráficos
  Future<List<Map<String, dynamic>>> getHistory(String gameId) async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    final response = await client
        .from('game_sessions')
        .select()
        .eq('user_id', user.id)
        .eq('game_id', gameId)
        .order('played_at', ascending: true)
        .limit(20);
        
    return List<Map<String, dynamic>>.from(response);
  }
}
