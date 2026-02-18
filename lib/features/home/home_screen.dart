import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../core/gamification/energy_provider.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildTopBar(context),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildLevelNode(
              context,
              level: 1,
              title: "Calibración Biológica",
              icon: Icons.track_changes,
              isUnlocked: true,
              isCompleted: false,
              color: AppTheme.primary,
            ),
            _buildPathLine(),
            _buildLevelNode(
              context,
              level: 2,
              title: "Anti-Supresión (Rojo)",
              icon: Icons.filter_vintage, // Icono placeholder para gafas 3D
              isUnlocked: true,
              isCompleted: false,
              color: AppTheme.redLeft,
            ),
            _buildPathLine(),
            _buildLevelNode(
              context,
              level: 3,
              title: "Fusión Neuronal",
              icon: Icons.merge_type,
              isUnlocked: false,
              isCompleted: false,
              color: Colors.grey,
            ),
             _buildPathLine(),
            _buildLevelNode(
              context,
              level: 4,
              title: "Seguimiento Infinito",
              icon: Icons.all_inclusive,
              isUnlocked: false,
              isCompleted: false,
              color: Colors.grey,
            ),
             _buildPathLine(),
            _buildLevelNode(
              context,
              level: 5,
              title: "Sácadas Rápidas",
              icon: Icons.flash_on,
              isUnlocked: false,
              isCompleted: false,
              color: Colors.grey,
            ),
            
            const SizedBox(height: 100), // Padding inferio
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final energy = context.watch<EnergyProvider>().currentEnergy;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Racha
        Row(children: [
          const Icon(Icons.local_fire_department, color: Colors.orange),
          const SizedBox(width: 4),
          const Text("5", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        ]),
        
        // Gemas
        Row(children: [
          const Icon(Icons.diamond, color: Colors.blue),
          const SizedBox(width: 4),
          const Text("450", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ]),
        
        // Energía
        Row(children: [
          const Icon(Icons.favorite, color: AppTheme.redLeft),
          const SizedBox(width: 4),
          Text("$energy/3", style: const TextStyle(color: AppTheme.redLeft, fontWeight: FontWeight.bold)),
        ]),
      ],
    );
  }

  Widget _buildLevelNode(
    BuildContext context, {
    required int level,
    required String title,
    required IconData icon,
    required bool isUnlocked,
    required bool isCompleted,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isUnlocked ? color : Colors.grey.withOpacity(0.2),
            shape: BoxShape.circle,
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ]
                : [],
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 4,
            ),
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: isUnlocked ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPathLine() {
    return Container(
      height: 40,
      width: 4,
      color: Colors.white.withOpacity(0.1),
    );
  }
  
  Widget _buildBottomNav() {
    return NavigationBar(
      backgroundColor: AppTheme.surface,
      destinations: const [
         NavigationDestination(icon: Icon(Icons.home), label: "Home"),
         NavigationDestination(icon: Icon(Icons.bar_chart), label: "Stats"),
         NavigationDestination(icon: Icon(Icons.store), label: "Shop"),
         NavigationDestination(icon: Icon(Icons.emoji_events), label: "Leagues"),
      ],
    );
  }
}
