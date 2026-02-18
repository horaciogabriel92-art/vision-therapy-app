import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vision_therapy_app/core/theme/app_theme.dart';
import 'package:glassmorphism/glassmorphism.dart';

enum NodeStatus { locked, unlocked, completed, active }

class LevelNode extends StatelessWidget {
  final int level;
  final NodeStatus status;
  final VoidCallback? onTap;
  final IconData icon;

  const LevelNode({
    super.key,
    required this.level,
    required this.status,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLocked = status == NodeStatus.locked;
    final bool isActive = status == NodeStatus.active;
    
    Color nodeColor;
    switch (status) {
      case NodeStatus.locked:
        nodeColor = Colors.grey.withOpacity(0.3);
        break;
      case NodeStatus.unlocked:
        nodeColor = AppTheme.primary;
        break;
      case NodeStatus.active:
        nodeColor = AppTheme.energy;
        break;
      case NodeStatus.completed:
        nodeColor = AppTheme.accent;
        break;
    }

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Outer Glow for Active Node
          Container(
            decoration: isActive ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: nodeColor.withOpacity(0.6), blurRadius: 20, spreadRadius: 5),
              ],
            ) : null,
            child: GlassmorphicContainer(
              width: 80,
              height: 80,
              borderRadius: 40,
              blur: 10,
              alignment: Alignment.center,
              border: 2,
              linearGradient: LinearGradient(
                colors: [
                  nodeColor.withOpacity(0.2),
                  nodeColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderGradient: LinearGradient(
                colors: [
                  nodeColor.withOpacity(0.5),
                  nodeColor.withOpacity(0.1),
                ],
              ),
              child: Icon(
                isLocked ? Icons.lock : icon,
                color: isLocked ? Colors.white38 : Colors.white,
                size: 32,
              ),
            ),
          )
          .animate(target: isActive ? 1 : 0)
          .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds, curve: Curves.easeInOut)
          .then()
          .scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1), duration: 1.seconds, curve: Curves.easeInOut),
          
          const SizedBox(height: 8),
          
          // Labels
          if (!isLocked)
            GlassmorphicContainer(
              width: 60,
              height: 24,
              borderRadius: 12,
              blur: 5,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              alignment: Alignment.center,
              border: 1,
              linearGradient: LinearGradient(colors: [AppTheme.surfaceGlass, AppTheme.surfaceGlass]),
              borderGradient: LinearGradient(colors: [Colors.white24, Colors.white10]),
              child: Text(
                "LVL $level",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
