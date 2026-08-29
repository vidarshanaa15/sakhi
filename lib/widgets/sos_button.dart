import 'package:flutter/material.dart';
import '../core/state/sos_store.dart';
import '../services/sos_service.dart';

class SosButton extends StatefulWidget {
  const SosButton({super.key});

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> {
  final _sosService = SosService();
  double _holdProgress = 0;
  bool _holding = false;

  static const _holdDuration = Duration(milliseconds: 1200);

  void _startHold() async {
    setState(() => _holding = true);
    final steps = 30;
    for (int i = 0; i <= steps; i++) {
      if (!_holding) return;
      await Future.delayed(_holdDuration ~/ steps);
      if (!mounted || !_holding) return;
      setState(() => _holdProgress = i / steps);
    }
    if (_holding) await _fire();
  }

  void _cancelHold() {
    setState(() {
      _holding = false;
      _holdProgress = 0;
    });
  }

  Future<void> _fire() async {
    setState(() {
      _holding = false;
      _holdProgress = 0;
    });
    try {
      await _sosService.trigger();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SOS sent to your contacts')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('SOS failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SosStore.instance,
      builder: (context, _) {
        final active = SosStore.instance.sosActive;
        if (active) {
          return FloatingActionButton.extended(
            backgroundColor: Colors.red,
            onPressed: () async => await _sosService.resolve(),
            icon: const Icon(Icons.check),
            label: const Text('Resolve SOS'),
          );
        }
        return GestureDetector(
          onLongPressStart: (_) => _startHold(),
          onLongPressEnd: (_) => _cancelHold(),
          onLongPressCancel: () => _cancelHold(),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.shade600,
              boxShadow: _holding
                  ? [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 12)]
                  : [],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_holding)
                  CircularProgressIndicator(
                    value: _holdProgress,
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                const Icon(Icons.sos, color: Colors.white, size: 28),
              ],
            ),
          ),
        );
      },
    );
  }
}