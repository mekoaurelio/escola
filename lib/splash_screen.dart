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


