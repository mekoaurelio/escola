import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Google extends StatefulWidget {
  const Google({Key? key}) : super(key: key);

  @override
  State<Google> createState() => _GoogleState();
}

class _GoogleState extends State<Google> {
  // === DADOS DE ENTRADA (EDITÁVEIS) ===
  final TextEditingController _municipioController = TextEditingController(text: 'Toledo');
  final TextEditingController _previsaoRecursoController = TextEditingController(text: '1.271.621.000,00');

  final TextEditingController _ideb2021Controller = TextEditingController(text: '6,2');
  final TextEditingController _ideb2023Controller = TextEditingController(text: '6,8');
  final TextEditingController _idebMetaController = TextEditingController(text: '6,6');

  final TextEditingController _saeb2021Controller = TextEditingController(text: '6,5');
  final TextEditingController _saeb2023Controller = TextEditingController(text: '6,9');
  final TextEditingController _saebMetaController = TextEditingController(text: '6,7');

  final TextEditingController _integralCenso2022Controller = TextEditingController(text: '730');
  final TextEditingController _integralCenso2023Controller = TextEditingController(text: '1.040');
  final TextEditingController _integralMetaController = TextEditingController(text: '14,1%');

  final TextEditingController _matriculas2022Controller = TextEditingController(text: '14.444');
  final TextEditingController _matriculas2023Controller = TextEditingController(text: '14.701');

  final TextEditingController _inse2021Controller = TextEditingController(text: '5,4');
  final TextEditingController _inseMetaController = TextEditingController(text: '5,2');

  final TextEditingController _somaIndicadoresEstadoController = TextEditingController(text: '1.053.736,28');

  // Formatador de moeda
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');
  final numberFormat = NumberFormat.decimalPattern('pt_BR');

  // === CÁLCULOS DERIVADOS ===
  double get idebAtingimento {
    double ideb2023 = double.tryParse(_ideb2023Controller.text.replaceAll(',', '.')) ?? 0.0;
    double meta = double.tryParse(_idebMetaController.text.replaceAll(',', '.')) ?? 1.0;
    return meta > 0 ? ideb2023 / meta : 0;
  }

  double get saebAtingimento {
    double saeb2023 = double.tryParse(_saeb2023Controller.text.replaceAll(',', '.')) ?? 0.0;
    double meta = double.tryParse(_saebMetaController.text.replaceAll(',', '.')) ?? 1.0;
    return meta > 0 ? saeb2023 / meta : 0;
  }

  double get integralAtingimento {
    double matriculas2023 = double.tryParse(_matriculas2023Controller.text.replaceAll('.', '')) ?? 0.0;
    if (matriculas2023 == 0) return 0;

    double integral2023 = double.tryParse(_integralCenso2023Controller.text.replaceAll('.', '')) ?? 0.0;
    double percentual2023 = (integral2023 / matriculas2023) * 100;

    double meta = double.tryParse(_integralMetaController.text.replaceAll('%', '').replaceAll(',', '.')) ?? 1.0;
    return meta > 0 ? percentual2023 / meta : 0;
  }

  double get inseAtingimento {
    double inse2021 = double.tryParse(_inse2021Controller.text.replaceAll(',', '.')) ?? 0.0;
    double meta = double.tryParse(_inseMetaController.text.replaceAll(',', '.')) ?? 1.0;
    return meta > 0 ? inse2021 / meta : 0;
  }

  double get indicadoresVezesMatriculas {
    double matriculas2023 = double.tryParse(_matriculas2023Controller.text.replaceAll('.', '')) ?? 0.0;
    return (idebAtingimento * 0.5 + saebAtingimento * 0.3 + integralAtingimento * 0.1 + inseAtingimento * 0.1) * matriculas2023;
  }

  double get iqepMunicipio {
    double somaEstado = double.tryParse(_somaIndicadoresEstadoController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 1.0;
    return somaEstado > 0 ? indicadoresVezesMatriculas / somaEstado : 0;
  }

  double get previsaoValorMunicipio {
    double previsaoRecurso = double.tryParse(_previsaoRecursoController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;
    return iqepMunicipio * previsaoRecurso;
  }

  double get perCapita {
    double matriculas2023 = double.tryParse(_matriculas2023Controller.text.replaceAll('.', '')) ?? 0.0;
    return matriculas2023 > 0 ? previsaoValorMunicipio / matriculas2023 : 0;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('Calculadora IQEP - ICMS', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === COLUNA DA ESQUERDA: INDICADORES DE ENTRADA ===
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 24),
                      _buildIndicatorCard(
                        icon: Icons.school_outlined,
                        color: Colors.lightBlue,
                        title: 'Indicador de Ensino (Peso 0,5)',
                        children: [
                          _buildEditableFieldRow('IDEB 2021', _ideb2021Controller),
                          _buildEditableFieldRow('IDEB 2023', _ideb2023Controller),
                          _buildEditableFieldRow('Meta IDEB', _idebMetaController, isMeta: true),
                          _buildResultRow('Atingimento da Meta', idebAtingimento.toStringAsFixed(2)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildIndicatorCard(
                        icon: Icons.text_fields_rounded,
                        color: Colors.orange,
                        title: 'Indicador de Alfabetização (Peso 0,3)',
                        children: [
                          _buildEditableFieldRow('SAEB 2021', _saeb2021Controller),
                          _buildEditableFieldRow('SAEB 2023', _saeb2023Controller),
                          _buildEditableFieldRow('Meta SAEB', _saebMetaController, isMeta: true),
                          _buildResultRow('Atingimento da Meta', saebAtingimento.toStringAsFixed(2)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildIndicatorCard(
                        icon: Icons.hourglass_full_rounded,
                        color: Colors.purple,
                        title: 'Indicadores de Educação Integral (Peso 0,1)',
                        children: [
                          _buildEditableFieldRow('Integral Censo 2022', _integralCenso2022Controller),
                          _buildEditableFieldRow('Integral Censo 2023', _integralCenso2023Controller),
                          _buildEditableFieldRow('Meta Percentual', _integralMetaController, isMeta: true),
                          _buildResultRow('Atingimento da Meta', integralAtingimento.toStringAsFixed(2)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildIndicatorCard(
                        icon: Icons.groups_2_outlined,
                        color: Colors.teal,
                        title: 'Indicador Socioeconômico (Peso 0,1)',
                        children: [
                          _buildEditableFieldRow('INSE 2021', _inse2021Controller),
                          _buildEditableFieldRow('Meta INSE', _inseMetaController, isMeta: true),
                          _buildResultRow('Atingimento da Meta', inseAtingimento.toStringAsFixed(2)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // === COLUNA DA DIREITA: RESULTADOS E TOTAIS ===
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildResultCard(
                        title: 'Indicadores * Matrículas',
                        subtitle: '(IDEB*0,5 + ALFAB.*0,3 + ...)',
                        value: numberFormat.format(indicadoresVezesMatriculas),
                        color: Colors.green,
                      ),
                      const SizedBox(height: 24),
                      _buildResultCard(
                        title: 'Índice de Qualidade (IQEP)',
                        subtitle: 'Este Município',
                        value: iqepMunicipio.toStringAsFixed(16),
                        color: Colors.green,
                      ),
                      const SizedBox(height: 24),
                      _buildResultCard(
                        title: 'Soma (Ind*Mat) Estado',
                        subtitle: 'Todos os Municípios',
                        value: _somaIndicadoresEstadoController.text,
                        color: Colors.lightBlue,
                        isEditable: true,
                        controller: _somaIndicadoresEstadoController,
                      ),
                      const SizedBox(height: 24),
                      _buildResultCard(
                        title: 'Previsão Recurso para Distribuição',
                        subtitle: 'Total do Estado',
                        value: _previsaoRecursoController.text,
                        color: Colors.lightBlue,
                        isEditable: true,
                        controller: _previsaoRecursoController,
                      ),
                      const SizedBox(height: 24),
                      _buildFinalResultCard(
                        title: 'Previsão de Valor para este Município',
                        value: currencyFormat.format(previsaoValorMunicipio),
                      ),
                      const SizedBox(height: 24),
                      _buildFinalResultCard(
                        title: 'Per Capita',
                        value: currencyFormat.format(perCapita),
                        isSecondary: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGETS HELPER PARA CONSTRUIR A UI

  Widget _buildHeaderCard() {
    return Card(
      color: const Color(0xFF1F1F1F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Text('Município:', style: GoogleFonts.inter(fontSize: 18, color: Colors.white70)),
            const SizedBox(width: 16),
            Expanded(child: _buildEditableField(_municipioController, isHeader: true)),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorCard({
    required IconData icon,
    required Color color,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      color: const Color(0xFF1F1F1F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const Divider(color: Colors.white24, height: 32),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildEditableFieldRow(String label, TextEditingController controller, {bool isMeta = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 15, color: Colors.white70)),
          SizedBox(
            width: 120,
            child: _buildEditableField(controller, isMeta: isMeta),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(TextEditingController controller, {bool isMeta = false, bool isHeader = false}) {
    return TextFormField(
      controller: controller,
      textAlign: isHeader ? TextAlign.left : TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: isHeader ? 18 : 20,
        fontWeight: FontWeight.bold,
        color: isMeta ? Colors.cyanAccent : (isHeader ? Colors.amberAccent : Colors.white),
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.all(12),
        filled: true,
        fillColor: isMeta ? Colors.cyan.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isMeta ? Colors.cyan.withOpacity(0.3) : Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isMeta ? Colors.cyan.withOpacity(0.3) : Colors.white24),
        ),
      ),
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 15, color: Colors.white70)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String subtitle,
    required String value,
    required Color color,
    bool isEditable = false,
    TextEditingController? controller,
  }) {
    return Card(
      color: const Color(0xFF1F1F1F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 16),
            isEditable
                ? _buildEditableField(controller!)
                : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)
              ),
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalResultCard({
    required String title,
    required String value,
    bool isSecondary = false,
  }) {
    return Card(
      color: isSecondary ? const Color(0xFF1F1F1F) : Colors.green,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: isSecondary ? Colors.greenAccent : Colors.white)),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: isSecondary ? Colors.white : Colors.white),
            )
          ],
        ),
      ),
    );
  }

}