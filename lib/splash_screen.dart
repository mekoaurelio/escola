import 'dart:async';
import 'package:flutter/material.dart';
import 'data/api_my_sql.dart';
import 'services/utils.dart';
import 'start.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Controla a opacidade para a animação de fade-in
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Inicia a animação e a navegação quando a tela é construída
    _startSplash();
  }
/*
  void _startSplash() {
    // Timer para a animação de fade-in começar um pouco depois da tela ser construída
    Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });

    // Timer principal para a duração da splash screen
    Timer(const Duration(seconds: 4), () async{
      if (mounted) {
        var idUser=Utils.getIdUser();
        var acessos=await ApiMySql.executaSql('select * from login_direitos where id_user=$idUser');
        var notifica=acessos[0]['notificacao'];
        if (notifica == '1') {
          print('TEM NOTIFICACAO');
          _mostrarNotificacoes(acessos);
        } else {
          _irParaStart(acessos);
        }
        // Navega para a tela principal substituindo a splash screen na pilha de navegação
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Start(acessos: acessos,)),
        );
      }
    });
  }

 */

  void _startSplash() {
    // Fade-in
    Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });

    // Timer principal
    Timer(const Duration(seconds: 4), () async {
      if (!mounted) return;

      var idUser = Utils.getIdUser();
      var acessos = await ApiMySql.executaSql(
          'select * from login_direitos where id_user=$idUser');

      var notifica = acessos[0]['notificacao'];

      if (notifica == '1') {
        _mostrarNotificacoes(acessos);
      } else {
        _irParaStart(acessos);
      }
    });
  }

  void _irParaStart(acessos) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => Start(acessos: acessos),
      ),
    );
  }
/*
  void _mostrarNotificacoes(acessos) {
    showDialog(
      context: context,
      barrierDismissible: false, // força clicar no botão
      builder: (context) {
        return AlertDialog(
          title: const Text('Notificações'),
          content: const Text(
            '1. Não cumprimento das metas e critérios de distribuição\n'
                '2. pendencias nos sistemas do Governo Federal do PAC.\n 4. Pendencias financeiras..\n',

          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // fecha o dialog
                _irParaStart(acessos);       // navega depois
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

 */

  void _mostrarNotificacoes(acessos) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 500,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header estilizado igual ao print
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade700, Colors.red.shade900],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'NOTIFICAÇÕES IMPORTANTES',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Conteúdo
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total de Receitas (estilo do print)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'TOTAL DE PENDÊNCIAS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '3',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Itens de pendências (estilo das fontes de financiamento)
                      _buildItemNotificacao(
                        '⚠️ INDICADOR DE ENSINO',
                        'Atingimento da Meta do IDPR',
                        Colors.green.shade700,
                      ),

                      _buildItemNotificacao(
                        '📋 INDICADOR DE ALFABETIZAÇÃO',
                        'Atingimento da Meta do SAEP',
                        Colors.green.shade700,
                      ),

                      _buildItemNotificacao(
                        '💰 INDICADORES DE EDUCAÇÃO INTEGRAL',
                        'Atingimento da Meta de Educação Integral',
                        Colors.red.shade700,
                      ),
                    ],
                  ),
                ),

                // Botão OK estilizado
                Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _irParaStart(acessos);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemNotificacao(String titulo, String subtitulo, Color cor) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.warning, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: cor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitulo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          /*
          Text(
            'teste',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: cor,
            ),
          ),

           */
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green, // Ou a cor que preferir
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 2),
          curve: Curves.easeIn,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // **** A CORREÇÃO ESTÁ AQUI ****
              // Envolvemos o Container em um Expanded
              Expanded(
                child: Container(
                  // A altura agora é controlada pelo Expanded, então podemos remover.
                   width: 500, // O width pode ser desnecessário se a imagem deve preencher
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/robo_login.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // O Indicador de progresso agora tem seu espaço garantido
              // Adicionamos um padding para não ficar colado na parte inferior
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white38),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


