
import 'package:flutter/material.dart';

import '../services/utils.dart';
import '../widgets/texto.dart';

class HoverableDataRow extends StatefulWidget {
  final String label;
  final String value;
  final bool isHighlighted;
  final IconData? icon; // Alterado para nullable
  final IconData? valueIcon;
  final String? tooltip;
  final String? valueTooltip;
  final bool negrito;
  final void Function(String label, String newValue)? onValueChanged;

  const HoverableDataRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
    this.negrito=false,
    this.icon, // Removido o valor padrão implícito
    this.valueIcon,
    this.tooltip,
    this.onValueChanged,
    this.valueTooltip,
    Key? key,
  }) : super(key: key);

  @override
  _HoverableDataRowState createState() => _HoverableDataRowState();
}

class _HoverableDataRowState extends State<HoverableDataRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1.0)),
          color: _isHovered ? Colors.blue.shade50 : Colors.transparent,
        ),
        child: Row(
          children: [
            /// Descrição
            Container(
              width: 600,
              child: Texto(
                tit: widget.label,
                icone: widget.icon, // Passando direto, o Texto já trata null
                tooltip: widget.tooltip,
                left: 10,
              ),
            ),

            /// Valor
            Container(
              width: 150,
              child:Align(
                alignment: Alignment.centerRight,
                child:  Texto(
                  tit: widget.value,
                  icone: widget.onValueChanged != null ? widget.valueIcon : null, // Mostra ícone apenas se editável
                  tooltip: widget.valueTooltip,
                  negrito: true,
                  right: 5,
                  aoClicarIcone: widget.onValueChanged != null
                      ? () => click(widget.label)
                      : null,
                ),
              )


            ),
          ],
        ),
      ),
    );
  }

  void click(String title) async {
    final callback = widget.onValueChanged;
    final initialValue = widget.value;

    await Utils.mostrarDialogoEditarValor(
      context: context,
      titulo: title,
      labelCampo: 'Valor',
      valorInicial: initialValue,
      aoSalvar: (novoValor) {
        if (callback != null) {
          callback(widget.label, novoValor);
        }
      },
    );
  }
}