import 'package:flutter/material.dart';

class DireitoDeAcesso extends StatefulWidget {
  final Map<String, bool> acessosIniciais;

  const DireitoDeAcesso({super.key, required this.acessosIniciais});

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
    // Aqui você salva os dados no MySQL via API
    // Exemplo:
    // await ApiMySql.salvarAcessos(usuarioId, acessos);
    print('Acessos salvos: $acessos');
  }

  Widget _buildGrupo(String titulo, List<String> itens) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ...itens.map((item) => CheckboxListTile(
            title: Text(item),
            value: acessos[item] ?? false,
            onChanged: (v) => toggle(item, v),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Direitos de Acesso")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
            ]),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: salvarAcessos,
              icon: const Icon(Icons.save),
              label: const Text("Salvar Direitos"),
            )
          ],
        ),
      ),
    );
  }
}
