import 'package:flutter/material.dart';

class PacDashboardPage extends StatelessWidget {
  const PacDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const Icon(Icons.arrow_back, color: Color(0xFF495057)),
        title: const Text(
          'Programa de aceleração do Crescimento',
          style: TextStyle(
            color: Color(0xFF212529),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- CARD 1: INTRODUÇÃO ---
            const IntroPacCard(),
            const SizedBox(height: 24),

            // --- LAYOUT RESPONSIVO: DUAS COLUNAS OU UMA ---
            LayoutBuilder(
              builder: (context, constraints) {
                // Se a tela for larga o suficiente, usa duas colunas.
                if (constraints.maxWidth > 800) {
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildLeftColumn(),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 1,
                          child: _buildRightColumn(),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Em telas estreitas, empilha tudo em uma única coluna.
                  return Column(
                    children: [
                      _buildLeftColumn(),
                      const SizedBox(height: 24),
                      _buildRightColumn(),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Coluna da esquerda com os cards de métricas
  Widget _buildLeftColumn() {
    return Column(
      children: const [
        MetricCard(
          title: 'CRECHES E PRÉ-ESCOLAS',
          icon: Icons.child_care,
          //#EDCB06
          color: Color(0xFFEDCB06), // Amarelo
          mainValue: '1.178',
          description: 'Novas unidades de ensino\npara a Educação Infantil',
          secondaryValue: 'R\$ 3.593.038,18',
        ),
        SizedBox(height: 24),
        MetricCard(
          title: 'ÔNIBUS ESCOLARES',
          icon: Icons.directions_bus, //FF7228
          color: Color(0xFFFF7228), // Azul claro
          mainValue: '1.500',
          description: 'Novos veículos para o\ntransporte escolar',
          secondaryValue: 'R\$ 3.593.038,18',
        ),
        SizedBox(height: 24),
        MetricCard(
          title: 'ESCOLAS DE TEMPO INTEGRAL',
          icon: Icons.school,
          color: Color(0xFFFFA726), // Laranja
          mainValue: '685',
          description: 'Novas unidades com\njornada ampliada',
          secondaryValue: 'R\$ 3.593.038,18',
        ),
      ],
    );
  }

  // Coluna da direita com o card do Pacto Nacional
  Widget _buildRightColumn() {
    return const PactoNacionalCard();
  }
}

/// WIDGET PARA O CARD DE INTRODUÇÃO DO NOVO PAC
class IntroPacCard extends StatelessWidget {
  const IntroPacCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NOVO PROGRAMA DE ACELERAÇÃO DO CRESCIMENTO',
                    style: TextStyle(
                      color: Color(0xFF007BFF),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Color(0xFF495057), height: 1.5, fontSize: 14),
                      children: [
                        TextSpan(text: 'O '),
                        TextSpan(text: 'Novo PAC', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: ' beneficiará os municípios com recursos para educação, com previsão total de '),
                        TextSpan(text: 'R\$ 13,3 bilhões', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: ' no 1º '),
                        TextSpan(text: 'Edital.', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Placeholder para a imagem do logo.
            // Substitua por Image.asset('assets/novo_pac_logo.png')
            Image.asset('assets/images/novo_pac.png',width: 351,  // largura em pixels
              height: 169,)
            //novo_pac.png
           // FlutterLogo(size: 100),
          ],
        ),
      ),
    );
  }
}

/// WIDGET REUTILIZÁVEL PARA OS CARDS DE MÉTRICA (CRECHES, ÔNIBUS, ETC.)
class MetricCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String mainValue;
  final String description;
  final String secondaryValue;

  const MetricCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.mainValue,
    required this.description,
    required this.secondaryValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Garante que o filho respeite as bordas arredondadas
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: color,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mainValue,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        //#333333
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,

                        color: Color(0xFF565656),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9ECEF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    secondaryValue,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF495057),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// WIDGET PARA O CARD DO PACTO NACIONAL
class PactoNacionalCard extends StatelessWidget {
  const PactoNacionalCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFF343A40), // Cinza escuro
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'PACTO NACIONAL PELA RETOMADA DE OBRAS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Esforço para concluir obras paralisadas da educação básica',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: const [
                    Expanded(
                      child: InfoBubble(
                        icon: Icons.assignment,
                        //#FF1D86
                        iconColor: Color(0xFFFF1D86), // Rosa
                        value: '3.700+',
                        label: 'Manifestações',
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: InfoBubble(
                        icon: Icons.monetization_on,
                        iconColor: Color(0xFF28A745), // Verde
                        value: 'R\$4,1 bi',
                        label: 'Investimento',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'PREVISÃO PARA O MUNICÍPIO',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9ECEF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'R\$ 1.267.584,72',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF343A40),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// SUB-WIDGET REUTILIZÁVEL PARA OS CÍRCULOS DE INFORMAÇÃO
class InfoBubble extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const InfoBubble({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  }) : super(key: key);

  /*
  Vector
   */
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF343A40),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}