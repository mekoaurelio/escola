import 'package:flutter/material.dart';

class PainelDireito extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;

  const PainelDireito({super.key, required this.child, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fundo escuro semi-transparente
        GestureDetector(
          onTap: onClose,
          child: Container(
          //  color: Colors.transparent,
          ),
        ),

        // Painel lateral à direita
        Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 8,
            child: Container(
              width: MediaQuery.of(context).size.width *0.83,
              height: MediaQuery.of(context).size.height *0.90,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
