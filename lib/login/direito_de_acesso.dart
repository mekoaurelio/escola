import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../const/const.dart';
import '../data/api_my_sql.dart';
import '../widgets/custom_butom.dart';

class DireitoDeAcesso extends StatefulWidget {
  final Map<String, bool> acessosIniciais;
  final String? idUser;
  final String? nmUser;
  final String? tipo;

  const DireitoDeAcesso({
    super.key,
    required this.acessosIniciais,
    this.idUser,
    this.nmUser,
    this.tipo,
  });

  @override
  State<DireitoDeAcesso> createState() => _DireitoDeAcessoState();
}

class _DireitoDeAcessoState extends State<DireitoDeAcesso> {
  late Map<String, bool> acessos;

  @override
  void initState() {
    super.initState();
    acessos = Map<String, bool>.from(widget.acessosIniciais);
  }

  void toggle(String key, bool? value) {
    setState(() {
      acessos[key] = value ?? false;
    });
  }

  Future<void> salvarAcessos() async {
    int idUser=int.parse(widget.idUser!);
    if(widget.tipo=='INSERT'){
      await ApiMySql.gerarInsertQuery(idUser, acessos);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Funcionou!')),
      );
      //Utils.snak('Parabéns', 'Direitos inseridos com sucesso!', false, Colors.green);
    }else{
      await ApiMySql.gerarUpdateQuery(idUser, acessos);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Direitos Atualizados com sucesso!'),backgroundColor: Colors.blue,));
     // Utils.snak('Parabéns', 'Direitos Atualizados com sucesso!', false, Colors.green);
    }
  }

  Widget _buildGrupo(String titulo, List<String> itens) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...itens.map((item) => CheckboxListTile(
              title: Text(item),
              value: acessos[item] ?? false,
              onChanged: (v) => toggle(item, v),
              contentPadding: EdgeInsets.zero,
              dense: true,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTituloVisual(String titulo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF2196F3), // azul padrão
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Center(
        child: Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundoOadrao,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.44,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTituloVisual("Direitos de Acesso de ${widget.nmUser!}"),
                  const SizedBox(height: 12),
                  _buildGrupo("Simulador", [
                    "Simulador",
                    "Projeção dos Recursos do FUNDEB",
                    "Projeção de Recursos",
                    "Simulador Magistério",
                  ]),
                  _buildGrupo("Professores", [
                    "Professores",
                    "Professor Educador",
                    "Educador Infantil",
                    "Folha de Pagamento",
                  ]),
                  _buildGrupo("Impacto", [
                    "Impacto",
                  ]),
                  _buildGrupo("Auxiliares", [
                    "Documentação",
                    "Encargos Sociais",
                    "Notificação",  // Opção adicionada
                  ]),
                  const SizedBox(height: 20),
                  Center(
                    child: Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Cancelar',
                           // onPressed: Get.back,
                            onPressed: () {
                              // Garantir que o pop seja chamado com segurança
                              if (Navigator.canPop(context)) {
                                Navigator.of(context).pop();
                              }
                              Get.back();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            text: 'Salvar',
                            backgroundColor: Colors.blue.shade300,
                            onPressed: salvarAcessos,
                          ),
                        ),
                      ],
                    ),
                  )
                ]
            ),
          ),
        ),
      ),
    );
  }
}
