import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:GEM/services/GlobalFilterController.dart';

import '../data/api_my_sql.dart';
import '../services/table_name_service.dart';
import '../services/utils.dart';


class EducationImpactPage extends StatefulWidget {
  const EducationImpactPage({Key? key}) : super(key: key); // Adicionado Key

  @override
  State<EducationImpactPage> createState() => _EducationImpactPage();
}

class _EducationImpactPage extends State<EducationImpactPage> {
  final GlobalFilterController filterController = Get.find<GlobalFilterController>();
  var lista;
  bool _isLoading=true;
  bool _isMaster=false;

  @override
  void initState() {
    filterController.municipio.listen((_) => _loadDataBasedOnCurrentFilters());
    filterController.ano.listen((_) => _loadDataBasedOnCurrentFilters());
    filterController.bimestre.listen((_) => _loadDataBasedOnCurrentFilters());
    _loadData();
  }

  void _loadDataBasedOnCurrentFilters() {
    _loadData();
  }

  void _loadData()async{
    lista=await ApiMySql.get(TBImpactoEducacao,null,null);
    print(lista);
    setState(() {
      _isLoading=false;
      _isMaster=Utils.getUserType()=='M';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF), // Azul bem claro
      body: _isLoading? const Center(child: CircularProgressIndicator()):
      SingleChildScrollView(
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
                         Expanded(flex: 3, child: GoalCard(
                           lista: lista,
                           isMaster:_isMaster,
                           onValueUpdated: _loadData,
                         )
                         ),
                        const SizedBox(width: 24),
                        Expanded(flex: 2, child: _buildBalanceCard(_isMaster,_loadData,'saldo',lista[0]['saldo'])),
                      ],
                    ),
                  );
                } else {
                  return Column(
                    children: [
                       GoalCard(
                         isMaster: _isMaster,
                         onValueUpdated: _loadData,
                       ),
                      const SizedBox(height: 24),
                      //bool isMaster,VoidCallback? onValueUpdated,String fieldToUpdate,
                      //       String value
                      _buildBalanceCard(
                        _isMaster,_loadData,'saldo',lista[0]['saldo']
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            // --- CARD 3: SITUAÇÃO DO MUNICÍPIO ---
             MunicipalityStatusCard(isMaster: _isMaster,onValueUpdated: _loadData,lista: lista,),
            const SizedBox(height: 24),

            // --- CARD 4: PARTICIPAÇÃO NO PROGRAMA ---
             ProgramParticipationCard(
               lista: lista,
               onValueUpdated: _loadData,
               isMaster: _isMaster,
             ),
          ],
        ),
      ),
    );
  }

  // Helper para o card de saldo, para evitar duplicação no LayoutBuilder
  Widget _buildBalanceCard(bool isMaster,VoidCallback? onValueUpdated,String fieldToUpdate,
      String value) {
    return  InfoCard(
      title: 'SALDO EM CONTA',
      headerColor: Color(0xFF007BFF), // Azul
      body: BalanceCardBody(
          isMaster: isMaster,
        onValueUpdated: onValueUpdated,
        fieldToUpdate: fieldToUpdate,
        value: value,
      ),
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
  var lista;
  final bool isMaster;
  final VoidCallback? onValueUpdated;

  GoalCard({
    super.key,
    this.lista,
    this.isMaster=false,
    this.onValueUpdated,
  });

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
              children:  [
                Expanded(
                  child: DataChip(
                    icon: Icons.track_changes,
                    iconColor: Color(0xFF007BFF),
                    label: 'Meta',
                    //value: '25%',
                    value: lista[0]['meta']??'0.00',//'25%',
                    fieldToUpdate: 'meta',
                    onValueUpdated: onValueUpdated,
                    isMaster: isMaster,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DataChip(
                    icon: Icons.trending_up,
                    iconColor: Colors.redAccent,
                    label: 'Situação',
                    //value: '20,6%',
                    value: lista[0]['sitaouac']??'0.00',//'20,6%',
                    backgroundColor: Color(0xFFFFEBEE), // Fundo rosa claro
                    fieldToUpdate: 'sitaouac',
                    onValueUpdated: onValueUpdated,
                    isMaster: isMaster,
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
  final bool isMaster;
  final String fieldToUpdate;
  final String value;
  final VoidCallback? onValueUpdated;

  BalanceCardBody(
      {
        Key? key,
        this.isMaster=false,
        required this.fieldToUpdate,
        required this.value,
        this.onValueUpdated,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:  [
          InkWell(
            // Chama a nova função estática
            onTap: () =>
            isMaster?
            Utils.showEditableValueDialog(
              tB: TBImpactoEducacao,
              context: context,
              initialValue: value,
              fieldToUpdate: fieldToUpdate!,
              valueType: 'NUM', // Supondo que seja um número simples
              onValueUpdated: onValueUpdated,
            ):null,
            //'R\$ 1.915.699,02',
            child: Text(value,
              style: TextStyle(
                color: Color(0xFF28a745),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
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
  final bool isMaster;
  final VoidCallback? onValueUpdated;
  var lista;

   MunicipalityStatusCard({
    Key? key,
    required this.isMaster,
    this.onValueUpdated,
    required this.lista,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'SITUAÇÃO DO MUNICÍPIO - TEMPO INTEGRAL',
      headerColor: const Color(0xFF343A40),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            _buildHeaderRow(), // 271
            _buildDataRow(icon: Icons.child_care_outlined, label: 'Creche', value: lista[0]['creche'],context: context,
            isMaster: isMaster,fieldToUpdate: 'creche',onValueUpdated: onValueUpdated),

            //147
            _buildDataRow(icon: Icons.sentiment_satisfied_alt_outlined, label: 'Pré-escola', value: lista[0]['pre_escola'],
            context: context,isMaster: isMaster,fieldToUpdate: 'pre_escola',onValueUpdated: onValueUpdated),

            //612
            _buildDataRow(icon: Icons.person_outline, label: 'Anos Iniciais', value: lista[0]['anos'],context: context,
                isMaster: isMaster,fieldToUpdate: 'anos',onValueUpdated: onValueUpdated),
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

  Widget _buildDataRow({
    required IconData icon, required String label, required String value,required BuildContext context,
    required bool isMaster,required String fieldToUpdate,VoidCallback? onValueUpdated,
  }) {
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
          InkWell(
            // Chama a nova função estática
            onTap: () =>
            isMaster?
            Utils.showEditableValueDialog(
              tB: TBImpactoEducacao,
              context: context,
              initialValue: value,
              fieldToUpdate: fieldToUpdate,
              valueType: 'NUM', // Supondo que seja um número simples
              onValueUpdated: onValueUpdated,
            ):null,
            child: Text(value, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// Card de Participação no Programa
class ProgramParticipationCard extends StatelessWidget {
  var lista;
  final bool isMaster;
  final VoidCallback? onValueUpdated;

  ProgramParticipationCard({
    super.key,
    required this.lista,
    this.isMaster=false,
    required this.onValueUpdated,
  });

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
              children:  [
                ParticipationChip(
                  color: Color(0xFF4FC3F7),
                  isMaster:isMaster,
                  fieldToUpdate: 'matriculas_pactuadas',
                  value: lista[0]['matriculas_pactuadas'],
                  label: 'Matrículas\nPactuadas',
                  icon: Icons.person_add_alt_1_outlined,
                  onValueUpdated:onValueUpdated ,
                ),
                ParticipationChip(
                    color: Color(0xFF4CAF50),
                    isMaster:isMaster,
                    fieldToUpdate: 'matriculas_declaradas',
                    value: lista[0]['matriculas_declaradas'],
                    label: 'Matrículas\nDeclaradas',
                    icon: Icons.check_circle_outline,
                  onValueUpdated:onValueUpdated ,
                ),

                ParticipationChip(
                    color: Color(0xFFFBC02D),
                    isMaster:isMaster,
                    fieldToUpdate: 'vr_pago',
                    value: lista[0]['vr_pago'],
                    label: 'Valor Pago',
                    isCurrency: true,
                  onValueUpdated:onValueUpdated ,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('2º Ciclo 2024/2025 (em andamento)', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children:  [
                ParticipationChip(
                    color: Color(0xFF4FC3F7),
                    isMaster: isMaster,
                    fieldToUpdate: 'matriculas_declaradas2',
                    value: lista[0]['matriculas_declaradas2'],
                    label: 'Matrículas\nPactuadas',
                    icon: Icons.person_add_alt_1_outlined,
                  onValueUpdated:onValueUpdated ,
                ),

                ParticipationChip(
                    color: Color(0xFFFFA726),
                    isMaster: isMaster,
                    fieldToUpdate: 'vr_estimado',
                    value: lista[0]['vr_estimado'],
                    label: 'Valor estimado',
                    isCurrency: true,
                  onValueUpdated:onValueUpdated ,
                ),

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
  final VoidCallback? onValueUpdated;
  final String? fieldToUpdate;
  final bool isMaster;

  const DataChip({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.onValueUpdated,
    this.backgroundColor,
    this.fieldToUpdate,
    this.isMaster=false,
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
          ///icone
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///texto
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 4),
              InkWell(
                // Chama a nova função estática
                onTap: () =>
                    isMaster?
                    Utils.showEditableValueDialog(
                  tB: TBImpactoEducacao,
                  context: context,
                  initialValue: value,
                  fieldToUpdate: fieldToUpdate!,
                  valueType: 'NUM', // Supondo que seja um número simples
                  onValueUpdated: onValueUpdated,
                ):null,
                child: Text(value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
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
  final String fieldToUpdate;
  final bool isMaster;
  final VoidCallback? onValueUpdated;

  const ParticipationChip({
    Key? key,
    required this.color,
    required this.value,
    required this.label,
    this.icon,
    this.isCurrency = false,
    required this.fieldToUpdate,
    required this.isMaster,
    this.onValueUpdated,
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
              InkWell(
                // Chama a nova função estática
                onTap: () =>
                isMaster?
                Utils.showEditableValueDialog(
                  tB: TBImpactoEducacao,
                  context: context,
                  initialValue: value,
                  fieldToUpdate: fieldToUpdate!,
                  valueType: 'NUM', // Supondo que seja um número simples
                  onValueUpdated: onValueUpdated,
                ):null,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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