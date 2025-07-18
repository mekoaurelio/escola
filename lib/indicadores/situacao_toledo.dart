import 'package:flutter/material.dart';

import '../widgets/texto.dart';

class SituacaoToledo extends StatelessWidget {
  const SituacaoToledo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body:Center(
        child: Container(
          width: MediaQuery.of(context).size.width *0.44,
          child:  SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildIntroductionCard(),
                const SizedBox(height: 16),
                _buildNationalGoalCard(),
                const SizedBox(height: 16),
                _buildMunicipalSituationCard(),
                const SizedBox(height: 16),
                _buildAccountBalanceCard(),
                const SizedBox(height: 16),
                _buildProgramParticipationHeader(),
                const SizedBox(height: 8),
                _buildFirstCycleCards(),
                const SizedBox(height: 16),
                _buildSecondCycleCards(),
              ],
            ),
          ),
        )
      )
    );
  }

  Widget _buildIntroductionCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "IMPACTO DA EDUCAÇÃO EM TEMPO INTEGRAL",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3C88),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Estudos demonstram que a escola de tempo integral possui impacto positivo no aprendizado e na probabilidade de continuidade dos estudos pelo estudante, bem como na proteção social, prevenção a violências e violações de direitos na infância e adolescência.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNationalGoalCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "META 6 DO PLANO NACIONAL DE EDUCAÇÃO",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3C88),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Percentual de alunos da educação básica pública que pertencem ao público da ETI e que estão em jornada de tempo integral.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGoalIndicator(
                  label: "META",
                  value: "25%",
                  color: const Color(0xFF1F3C88),
                ),
                _buildGoalIndicator(
                  label: "SITUAÇÃO",
                  value: "20,6%",
                  color: Colors.red.shade600,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Fonte: Censo 2024",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMunicipalSituationCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "SITUAÇÃO DO MUNICÍPIO - TEMPO INTEGRAL",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3C88),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns:  [
                  DataColumn(label: Texto(tit:'Nível Educacional',fontWeight: FontWeight.bold,tam: 16,)
                  ),
                  DataColumn(label: Texto(tit:'Matrículas',fontWeight: FontWeight.bold), numeric: true),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Texto(tit:'Creche',prefixIcon: Icons.face_retouching_natural,iconColor: Colors.blue.shade500,
                    tam: 18,)),
                    DataCell(Texto(tit:'271',tam: 20,)),
                  ]),
                  DataRow(cells: [
                    DataCell(Texto(tit:'Pré-escola',prefixIcon: Icons.face_rounded,iconColor: Colors.blue.shade500,
                      tam: 18,)),
                    DataCell(Texto(tit:'147',tam: 20,)),
                  ]),
                  DataRow(cells: [
                    DataCell(Texto(tit:'Anos Iniciais', prefixIcon: Icons.yard_outlined,iconColor: Colors.blue.shade500,
                      tam: 18,)),
                    DataCell(Texto(tit:'612',tam: 20,)),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Anos Finais')),
                    DataCell(Text('0')),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Fonte: Inep/MEC - Censo Escolar 2023",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountBalanceCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "SALDO EM CONTA",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3C88),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "R\$ 1.915.699,02",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF27AE60),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "*consulta em dezembro/2024*",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Valores arredondados para melhor visualização",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramParticipationCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "PARTICIPAÇÃO NO PROGRAMA",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3C88),
              ),
            ),
            const SizedBox(height: 16),
            _buildCycleCard(
              title: "1º Ciclo 2023/2024 (concluído)",
              matriculasPactuadas: "376",
              matriculasDeclaradas: "376",
              valor: "R\$ 1.942.370,88",
            ),
            const SizedBox(height: 16),
            _buildCycleCard(
              title: "2º Ciclo 2024/2025 (em andamento)",
              matriculasPactuadas: "387",
              valorEstimado: "R\$ 1.999.195,56",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalIndicator({required String label, required String value, required Color color}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCycleCard({
    required String title,
    required String matriculasPactuadas,
    String? matriculasDeclaradas,
    String? valor,
    String? valorEstimado,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3C88),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCycleStat(
                value: matriculasPactuadas,
                label: "Matrículas\nPactuadas",
              ),
              if (matriculasDeclaradas != null)
                _buildCycleStat(
                  value: matriculasDeclaradas,
                  label: "Matrículas\nDeclaradas",
                ),
              if (valor != null)
                _buildCycleStat(
                  value: valor,
                  label: "Valor Pago",
                  isAmount: true,
                ),
              if (valorEstimado != null)
                _buildCycleStat(
                  value: valorEstimado,
                  label: "Valor Estimado",
                  isAmount: true,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCycleStat({
    required String value,
    required String label,
    bool isAmount = false,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isAmount ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: isAmount ? const Color(0xFF27AE60) : const Color(0xFF1F3C88),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
  //********

  Widget _buildProgramParticipationHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "PARTICIPAÇÃO NO PROGRAMA",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F3C88),
          ),
        ),
      ),
    );
  }

  Widget _buildFirstCycleCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "1º Ciclo 2023/2024 (concluído)",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                value: "376",
                label: "Matrículas Pactuadas",
                icon: Icons.assignment_turned_in,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                value: "376",
                label: "Matrículas Declaradas",
                icon: Icons.check_circle,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                value: "R\$ 1.942.370,88",
                label: "Valor Pago",
                icon: Icons.attach_money,
                color: Colors.purple.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondCycleCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "2º Ciclo 2024/2025 (em andamento)",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildMetricCard(
                value: "387",
                label: "Matrículas Pactuadas",
                icon: Icons.assignment_turned_in,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _buildMetricCard(
                value: "R\$ 1.999.195,56",
                label: "Valor Estimado",
                icon: Icons.trending_up,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}