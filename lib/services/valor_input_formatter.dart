import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ValorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 1. Remove todos os caracteres não numéricos
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // 2. Converte a string de dígitos para um número (considerando os centavos)
    final number = double.parse(digitsOnly) / 100;

    // 3. Formata o número para o padrão pt_BR
    final newString = NumberFormat("#,##0.00", "pt_BR").format(number);

    // 4. Retorna o novo valor formatado, ajustando a posição do cursor
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}