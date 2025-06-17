import 'package:flutter/material.dart';
import 'package:psycostatattoo/const/nome_tabelas.dart';

import '../data/api_my_sql.dart';
import '../services/progressaoScreen.dart';

class SimuladorExecuta extends StatefulWidget {
  const SimuladorExecuta({Key? key}) : super(key: key);

  @override
  State<SimuladorExecuta> createState() => _SimuladorExecutaState();
}

class _SimuladorExecutaState extends State<SimuladorExecuta> with TickerProviderStateMixin {
  bool isLoading = true;
  late List<Map<String, dynamic>> fundebRaw;
  late List<Map<String, dynamic>> infantilRaw;

  @override
  void initState() {
    super.initState();
    start();
  }

  Future<void> start() async {
    // recupera o JSArray dinâmico
     fundebRaw = await ApiMySql.get(TBReceitaFundebSimulador, null,null);
     infantilRaw = await ApiMySql.get(TBInfantil, null,null);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProgressaoScreen(),
    );
  }
}
