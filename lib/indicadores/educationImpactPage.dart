import 'package:flutter/material.dart';

class EducationImpactPage extends StatelessWidget {
  const EducationImpactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF), // Azul bem claro
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- CARD 1: IMPACTO DA EDUCAÇÃO (COM IMAGEM) ---
            const ImpactCard(),
            const SizedBox(height: 24),

            // --- LAYOUT RESPONSIVO: META E SALDO ---
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Expanded(flex: 3, child: GoalCard()),
                        const SizedBox(width: 24),
                        Expanded(flex: 2, child: _buildBalanceCard()),
                      ],
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      const GoalCard(),
                      const SizedBox(height: 24),
                      _buildBalanceCard(),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // --- CARD 3: SITUAÇÃO DO MUNICÍPIO ---
            const MunicipalityStatusCard(),
            const SizedBox(height: 24),

            // --- CARD 4: PARTICIPAÇÃO NO PROGRAMA ---
            const ProgramParticipationCard(),
          ],
        ),
      ),
    );
  }

  // Helper para o card de saldo, para evitar duplicação no LayoutBuilder
  Widget _buildBalanceCard() {
    return const InfoCard(
      title: 'SALDO EM CONTA',
      headerColor: Color(0xFF007BFF), // Azul
      body: BalanceCardBody(),
    );
  }
}

/// WIDGETS DE COMPONENTES REUTILIZÁVEIS E ESPECÍFICOS

// Card de Impacto com Imagem de Fundo
class ImpactCard extends StatelessWidget {
  const ImpactCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF00695C), // Verde escuro
        borderRadius: BorderRadius.circular(16),
        /*
        image: const DecorationImage(
          // Substitua pela sua imagem
          image: NetworkImage('https://via.placeholder.com/300x100/FFFFFF/000000?text=Imagem+Alunos'),
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
          opacity: 0.3,
        ),

         */
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2, // Ocupa 2/3 do espaço
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IMPACTO DA EDUCAÇÃO',
                  style: TextStyle(
                    color: Color(0xFFFBC02D), // Amarelo
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: 600,
                  child: Text(
                    'Estudos demonstram que a escola de tempo integral tem impacto \npositivo no aprendizado e na continuidade dos estudos, além de\n contribuir para a proteção social e a prevenção de violências e \nviolações de direitos na infância e adolescência.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                )
              ],
            ),
          ),
       //   SizedBox(width: 16), // Espaço entre o texto e a imagem
          Expanded(
            flex: 1, // Ocupa 1/3 do espaço
            child: Image.asset(
              'assets/images/logo_estudos.jpg',
              fit: BoxFit.contain, // Mantém proporção sem cortar
              height: 200, // Ajuste conforme necessário
              width: 50,
              alignment: Alignment.centerRight, // Alinha à direita
            ),
          ),
        ],
      ),
    );
  }
}

// Card da Meta 6
class GoalCard extends StatelessWidget {
  const GoalCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'META 6 DO PLANO NACIONAL DE EDUCAÇÃO',
              style: TextStyle(
                color: Color(0xFF007BFF),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Percentual de alunos da educação básica pública que pertencem ao público da ETI e que estão em jornada de tempo integral.',
              style: TextStyle(color: Color(0xFF6C757D), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(
                  child: DataChip(
                    icon: Icons.track_changes,
                    iconColor: Color(0xFF007BFF),
                    label: 'Meta',
                    value: '25%',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DataChip(
                    icon: Icons.trending_up,
                    iconColor: Colors.redAccent,
                    label: 'Situação',
                    value: '20,6%',
                    backgroundColor: Color(0xFFFFEBEE), // Fundo rosa claro
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Fonte: Censo 2024',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Corpo do Card de Saldo
class BalanceCardBody extends StatelessWidget {
  const BalanceCardBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'R\$ 1.915.699,02',
            style: TextStyle(
              color: Color(0xFF28a745),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '*Consulta em Dezembro/2024*\nValores arredondados para melhor visualização',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// Card de Situação do Município
class MunicipalityStatusCard extends StatelessWidget {
  const MunicipalityStatusCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'SITUAÇÃO DO MUNICÍPIO - TEMPO INTEGRAL',
      headerColor: const Color(0xFF343A40),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            _buildHeaderRow(),
            _buildDataRow(icon: Icons.child_care_outlined, label: 'Creche', value: '271'),
            _buildDataRow(icon: Icons.sentiment_satisfied_alt_outlined, label: 'Pré-escola', value: '147'),
            _buildDataRow(icon: Icons.person_outline, label: 'Anos Iniciais', value: '612'),
            const Padding(
              padding: EdgeInsets.only(top: 16, right: 16, bottom: 8),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'Fonte: Inep/MEC - Censo Escolar 2023',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('NÍVEL EDUCACIONAL', style: TextStyle(color: Color(0xFF007BFF), fontSize: 12, fontWeight: FontWeight.bold)),
          Text('MATRÍCULAS', style: TextStyle(color: Color(0xFF007BFF), fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDataRow({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!))
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(color: Colors.grey[800])),
          const Spacer(),
          Text(value, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// Card de Participação no Programa
class ProgramParticipationCard extends StatelessWidget {
  const ProgramParticipationCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'PARTICIPAÇÃO NO PROGRAMA',
      headerColor: const Color(0xFF343A40),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1º Ciclo 2023/2024 (concluído)', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Wrap( // Para quebrar a linha em telas pequenas
              spacing: 16,
              runSpacing: 16,
              children: const [
                ParticipationChip(
                    color: Color(0xFF4FC3F7),
                    value: '376',
                    label: 'Matrículas\nPactuadas',
                    icon: Icons.person_add_alt_1_outlined),
                ParticipationChip(
                    color: Color(0xFF4CAF50),
                    value: '376',
                    label: 'Matrículas\nDeclaradas',
                    icon: Icons.check_circle_outline),
                ParticipationChip(
                    color: Color(0xFFFBC02D),
                    value: 'R\$ 1.942.370,88',
                    label: 'Valor Pago',
                    isCurrency: true),
              ],
            ),
            const SizedBox(height: 24),
            const Text('2º Ciclo 2024/2025 (em andamento)', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const [
                ParticipationChip(
                    color: Color(0xFF4FC3F7),
                    value: '376',
                    label: 'Matrículas\nPactuadas',
                    icon: Icons.person_add_alt_1_outlined),
                ParticipationChip(
                    color: Color(0xFFFFA726),
                    value: 'R\$ 1.942.370,88',
                    label: 'Valor estimado',
                    isCurrency: true),
              ],
            )
          ],
        ),
      ),
    );
  }
}


/// WIDGETS GENÉRICOS DE BAIXO NÍVEL

// Chip de dados para Meta e Situação
class DataChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? backgroundColor;

  const DataChip({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// Card genérico com cabeçalho colorido e corpo branco
class InfoCard extends StatelessWidget {
  final String title;
  final Color headerColor;
  final Widget body;

  const InfoCard({
    Key? key,
    required this.title,
    required this.headerColor,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: headerColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          body,
        ],
      ),
    );
  }
}

// Chip de participação no programa (matrículas, valor, etc.)
class ParticipationChip extends StatelessWidget {
  final Color color;
  final String value;
  final String label;
  final IconData? icon;
  final bool isCurrency;

  const ParticipationChip({
    Key? key,
    required this.color,
    required this.value,
    required this.label,
    this.icon,
    this.isCurrency = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Para que o Wrap funcione bem
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCurrency) ...[
                Text(
                  label,
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!isCurrency) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, height: 1.3),
                ),
              ],
            ],
          )
        ],
      ),
    );
  }
}