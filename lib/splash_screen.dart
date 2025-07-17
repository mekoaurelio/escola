import 'dart:async';
import 'package:flutter/material.dart';
import 'data/api_my_sql.dart';
import 'services/utils.dart';
import 'start.dart'; // IMPORTANTE: Importe sua tela principal (Start)

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
        // Navega para a tela principal substituindo a splash screen na pilha de navegação
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Start(acessos: acessos,)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo escuro que combina com o seu logo
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 2), // Duração suave para o fade-in
          curve: Curves.easeIn,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Seu logo
              Image.asset(
                'assets/images/Xmktec_logo.jpeg', // Certifique-se que o caminho e nome estão corretos
                width: 220, // Ajuste o tamanho conforme necessário
              ),
              const SizedBox(height: 50),

              // Indicador de progresso sutil
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}