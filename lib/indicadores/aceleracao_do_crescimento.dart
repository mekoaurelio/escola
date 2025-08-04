import 'package:flutter/material.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';


import 'package:GEM/services/GlobalFilterController.dart';
import '../data/api_my_sql.dart';
import '../services/table_name_service.dart';
import '../services/utils.dart';

class AceleracaoDoCrescimento extends StatelessWidget {
  const AceleracaoDoCrescimento({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body:Center(
        child: Container(
          width: MediaQuery.of(context).size.width *0.44,
          child:SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Cabeçalho do Novo PAC
                _buildProgramHeader(
                  icon: Icons.rocket_launch,
                  title: "NOVO PROGRAMA DE ACELERAÇÃO DO CRESCIMENTO",
                  description: "O Novo PAC beneficiará os municípios com recursos para educação, com previsão total de R\$ 13,3 bilhões no 1º Edital",
                ),
                const SizedBox(height: 16),

                // Card de Creches
                _buildBenefitCard(
                  icon: Icons.child_care,
                  title: "CRECHES E PRÉ-ESCOLAS",
                  value: "1.178",
                  amount: "R\$ 3.593.038,18",
                  description: "Novas unidades educacionais para educação infantil",
                  color: Colors.blue.shade700,
                ),
                const SizedBox(height: 16),

                // Card de Ônibus
                _buildBenefitCard(
                  icon: Icons.directions_bus,
                  title: "ÔNIBUS ESCOLARES",
                  value: "1.500",
                  description: "Novos veículos para transporte de estudantes",
                  color: Colors.green.shade700,
                ),
                const SizedBox(height: 16),

                // Card de Escolas Integrais
                _buildBenefitCard(
                  icon: Icons.school,
                  title: "ESCOLAS DE TEMPO INTEGRAL",
                  value: "685",
                  description: "Novas unidades com jornada ampliada",
                  color: Colors.orange.shade700,
                ),
                const SizedBox(height: 24),

                // Pacto Nacional
                _buildProgramHeader(
                  icon: Icons.construction,
                  title: "PACTO NACIONAL PELA RETOMADA DE OBRAS",
                  description: "Esforço para concluir obras paralisadas da educação básica",
                ),
                const SizedBox(height: 16),

                _buildPactoNacionalCard(),
              ],
            ),
          ),
        )
      )
    );
  }

  Future<void> _editarValor(BuildContext context,var vrinicial,String campo,String tipo) async {
    await Utils.mostrarDialogoEditarValor(
      inputFormatters: [
        tipo=='VR'?
        CurrencyTextInputFormatter.currency(symbol: 'R\$', locale: 'pt'):
        CurrencyTextInputFormatter.currency(symbol: '%', locale: 'pt')
      ],
      context: context,
      titulo: 'Atualizando',
      labelCampo: tipo=='VR'?'Valor':'Percentual',
      valorInicial: vrinicial,
      aoSalvar: (novoValor) async {
        var valorNumerico=novoValor;
        if(tipo=='VR') {
          valorNumerico = Utils.saldoToSave(novoValor);
          await ApiMySql.executaSql('Update $TBPac set $campo=$valorNumerico');
        }else{
          String nvr=novoValor.replaceAll('%', '').trim();
          await ApiMySql.executaSql('Update $TBPac set $campo="$nvr"');
        }
       // onValueUpdated?.call();
      },
    );
  }

  Widget _buildProgramHeader({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: const Color(0xFFE8F4FD),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF1F3C88)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F3C88),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String value,
    required String description,
    required Color color,
    String? tipo,
    String? campo,
    String? amount,
    BuildContext? context,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
        child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  ///icone
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 28, color: color),
                  ),
                  const SizedBox(width: 12),
                  ///titulo
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ///valor

              InkWell(
                onTap: () {
                  print('kkkkkkkk');
                  _editarValor(context!,value,campo!,tipo!);
                },

                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
              ),
        const SizedBox(height: 4),
        ///descricao
        Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                ),
              ),
        ///valor lateral

        if (amount != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    amount,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPactoNacionalCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Dados do Pacto
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  value: "3.700+",
                  label: "Manifestações",
                  icon: Icons.assignment_turned_in,
                  color: Colors.purple,
                ),
                _buildStatItem(
                  value: "R\$ 4,1 bi",
                  label: "Investimento",
                  icon: Icons.trending_up,
                  color: Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Previsão para o município
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    "Previsão para o município:",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1F3C88),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "R\$ 1.267.584,72",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 36, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}