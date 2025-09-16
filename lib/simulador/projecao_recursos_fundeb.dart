import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:GEM/services/GlobalFilterController.dart';
import 'package:get/get.dart';

import 'package:GEM/services/table_name_service.dart';
import '../data/api_my_sql.dart';
import '../services/utils.dart';
import '../widgets/line.dart';
import '../widgets/texto.dart';

class ProjecaoRecursosFundeb extends StatefulWidget {
  const ProjecaoRecursosFundeb({super.key});

  @override
  State<ProjecaoRecursosFundeb> createState() => _FUNDEBCalculatorScreenState();

}

class _FUNDEBCalculatorScreenState extends State<ProjecaoRecursosFundeb> {
  final double ProjecaoRecursosFundebPr = 6290.1;
  final GlobalFilterController filterController = Get.find<GlobalFilterController>();
  Map<String, dynamic>? tabela;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    filterController.municipio.listen((_) => _loadDataBasedOnCurrentFilters());
    filterController.ano.listen((_) => _loadDataBasedOnCurrentFilters());
    filterController.bimestre.listen((_) => _loadDataBasedOnCurrentFilters());
    _loadDataBasedOnCurrentFilters();
  }

  void _loadDataBasedOnCurrentFilters() {
    _carregarDadosBanco();
  }

  Future<void> _carregarDadosBanco() async {
    try {
      // Supondo que a tabela só tem uma linha com id=1
      final dados = await ApiMySql.get(TBVaaf, null, null).timeout(const Duration(seconds: 30));
      if (mounted) {
        setState(() {
          tabela = dados.isNotEmpty ? dados.first : {};
          isLoading = false;
        });
      }

    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Tratar erro
      print('Erro ao carregar dados: $e');
    }
  }

  final List<Map<String, dynamic>> etapas = [
    {
      'nome': 'Creche em tempo integral - Pública',
      'fator': 1.55,
      'campo': 'vr1',
    },
    {
      'nome': 'Creche em tempo integral - Conveniada',
      'fator': 1.45,
      'campo': 'vr2',
    },
    {'nome': 'Creche em tempo parcial Pública', 'fator': 1.25, 'campo': 'vr3'},
    {
      'nome': 'Creche em tempo parcial Conveniada',
      'fator': 1.15,
      'campo': 'vr4',
    },
    {
      'nome': 'Pré-escola em tempo integral - Pública',
      'fator': 1.5,
      'campo': 'vr5',
    },
    {
      'nome': 'Pré-escola em tempo parcial - Pública',
      'fator': 1.15,
      'campo': 'vr6',
    },
    {
      'nome': 'Pré-escola em tempo integral -Conveniada',
      'fator': 1.4,
      'campo': 'vr7',
    },
    {
      'nome': 'Pré-escola em tempo parcial -Conveniada',
      'fator': 1.05,
      'campo': 'vr8',
    },
    {
      'nome': 'Anos iniciais do Ensino Fundamental urbano',
      'fator': 1.00,
      'campo': 'vr9',
    },
    {
      'nome': 'Anos iniciais do Ensino Fundamental no campo',
      'fator': 1.15,
      'campo': 'vr10',
    },
    {
      'nome': 'Anos finais do ensino fundamental urbana',
      'fator': 1.1,
      'campo': 'vr11',
    },
    {
      'nome': 'Anos finais do ensino fundamental no campo',
      'fator': 1.265,
      'campo': 'vr12',
    },
    {
      'nome': 'Ensino Fundamental em tempo integral',
      'fator': 1.5,
      'campo': 'vr13',
    },
    {'nome': 'Ensino Médio urbano', 'fator': 1.25, 'campo': 'vr14'},
    {'nome': 'Ensino Médio em tempo Integral', 'fator': 1.52, 'campo': 'vr15'},
    {
      'nome': 'Ensino Médio integrado à educação profissional',
      'fator': 1.6875,
      'campo': 'vr16',
    },
    {'nome': 'Educação especial', 'fator': 1.4, 'campo': 'vr17'},
    {
      'nome': 'Atendimento educacional especializado - AEE',
      'fator': 1.96,
      'campo': 'vr18',
    },
    {'nome': 'Educação indígena e quilombola', 'fator': 1.4, 'campo': 'vr19'},
    {
      'nome': 'Educação de jovens e adultos (EJA)',
      'fator': 1.0,
      'campo': 'vr20',
    },
    {
      'nome': 'EJA integrada à educação profissional de nível médio',
      'fator': 1.2,
      'campo': 'vr21',
    },
  ];

  void _editMatricula(int index) async { /* ... */ }

  double _obterMatricula(int index) {
    final campo = etapas[index]['campo'];
    if (tabela == null || !tabela!.containsKey(campo)) {
      return 0.0;
    }
    return double.tryParse(tabela![campo].toString()) ?? 0.0;
  }

  Future<void> _salvarMatricula(int index, double valor) async {
    final campo = etapas[index]['campo'];

    try {
      /// Atualizar no banco de dados
      await ApiMySql.executaSql('update $TBVaaf set $campo=$valor');
      /// Salva os totais
      var _result=await ApiMySql.executaSql('update $TBTotais set matricula=$totalMatriculas, receita=$totalReceitas').timeout(const Duration(seconds: 30));
     /// Salva o total_receitas_fundeb, que será usado
      await ApiMySql.executaSql('update $TBTotais set total_receitas_fundeb=$totalReceitas');
      /// Atualizar localmente
      setState(() {
        tabela?[campo] = valor;
      });
    } catch (e) {
      // Tratar erro
      print('Erro ao salvar matrícula: $e');
    }
  }

  double get totalMatriculas {
    return etapas.fold(
      0,
          (sum, item) => sum + _obterMatricula(etapas.indexOf(item)),
    );
  }

  double get totalReceitas {
    return etapas.fold(0, (sum, item) {
      final index = etapas.indexOf(item);
      final matricula = _obterMatricula(index);
      final fator = item['fator'];
      final ProjecaoRecursosFundebPonderado = matricula*fator * ProjecaoRecursosFundebPr;
      return sum + ProjecaoRecursosFundebPonderado;
    });
  }

  /// GERA UMA LINHA ESTILIZADA PARA O CABEÇALHO E RODAPÉ.
  Widget _buildStyledHeaderFooterRow() {
    // Lista de textos para as colunas.
    final List<String> columnTitles = [
      'Etapas e Modalidades',
      'Matrículas',
      'Fator',
      'VAAF Pond.',
      'Projeção Receitas',
    ];

    // Fatores de flexibilidade para alinhar com as colunas de dados.
    final List<int> flexFactors = [5, 3, 2, 2, 3];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.blue, // Cor de fundo azul claro da imagem
      ),
      child: Row(
        children: List.generate(columnTitles.length, (index) {
          return Expanded(
            flex: flexFactors[index],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: index == 0 ? 16 : 8), // Padding especial para o primeiro item
              child:
              Text(
                columnTitles[index],
                textAlign: index == 0 ? TextAlign.left : TextAlign.center, // Alinhamento
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey.shade300, // Cor do texto azul da imagem
                ),
              ),

            ),
          );
        }),
      ),
    );
  }

  /// Cria uma linha de dados da tabela (seu método existente, sem alterações).
  Widget _buildDataRow(int index) {
    final etapa = etapas[index];
    final matricula = _obterMatricula(index);
    final fator = etapa['fator'];
    final vaafPonderado = fator * ProjecaoRecursosFundebPr;
    final receita = matricula * vaafPonderado;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Coluna 1: Descrição
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(etapa['nome'], style: const TextStyle(fontSize: 13)),
            ),
          ),
          /// Coluna 2: Matrículas
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: () => _editMatricula(index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Texto(
                        tit: matricula == 0 ? '': Utils.formatVr.format(matricula),tam: 13,
                        icone: Icons.edit, // só mostra ícone se editável
                       // tooltip: widget.tooltip,
                        aoClicarIcone: () {
                          Utils.mostrarDialogoEditarValor(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'))
                            ],
                            context: context,
                            titulo: etapa['nome'],
                            labelCampo: 'Valor',
                            valorInicial: matricula.toString(),
                            aoSalvar: (novoValor) {
                             _salvarMatricula(index, double.parse(novoValor));
                            },
                          );
                          }
                      ),

                    ),
                  //  const Icon(Icons.edit, size: 16, color: Colors.black54),
                  ],
                ),
              ),
            ),
          ),
          // Demais colunas
          Expanded(flex: 2, child: Center(child: Text(fator.toString(), style: const TextStyle(fontSize: 13)))),
          Expanded(flex: 2, child: Center(child: Text(Utils.formatVr.format(vaafPonderado), style: const TextStyle(fontSize: 13)))),
          Expanded(
            flex: 3,
            child:Padding(
              padding: EdgeInsets.only(right: 30),
            child: Align(
              alignment: Alignment.center,
              child: Line(tex:Utils.formatVr.format(receita),tam: 200,alin: Alignment.centerRight,fontSize: 16,
                cor: Colors.blue,negrito: true,)
            ),
          ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    const double maxTableWidth = 1500;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxTableWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: Text('Atualiza', style: TextStyle(color: Colors.black54)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    _carregarDadosBanco();
                  },
                ),
                SizedBox(width: 25,),
                //const SizedBox(height: 16),
                Expanded( // Adicionado Expanded aqui
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // ===================================
                        // 1. CABEÇALHO (FIXO)
                        // ===================================
                        _buildStyledHeaderFooterRow(),

                        // ===================================
                        // 2. CORPO (ROLÁVEL)
                        // ===================================
                        Expanded( // Mantido o Expanded aqui
                          child: SingleChildScrollView(
                            child: Column(
                              children: List.generate(etapas.length, (index) => _buildDataRow(index)),
                            ),
                          ),
                        ),

                        // ===================================
                        // 3. RODAPÉ (FIXO)
                        // ===================================
                        Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("TOTAL FUNDEB (20%)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(totalMatriculas.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const Text("TOTAL DE RECEITAS:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                                Text(Utils.formatVr.format(totalReceitas), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue.shade800)),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}