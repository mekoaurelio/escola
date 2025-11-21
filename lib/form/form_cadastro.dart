
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/api_my_sql.dart';
import '../login/footer.dart';
import '../login/recover.dart';
import '../services/utils.dart';
import '../splash_screen.dart';
import '../widgets/custom_butom.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/texto.dart';

class FormCadastro extends StatefulWidget {
  const FormCadastro({Key? key}) : super(key: key);

  @override
  State<FormCadastro> createState() => _FormCadastroState();
}

class _FormCadastroState extends State<FormCadastro> with TickerProviderStateMixin {
  final TextEditingController _edUser = TextEditingController();
  final TextEditingController _edPass = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void dispose() {
    _edUser.dispose();
    _edPass.dispose();
    super.dispose();
  }

  _login() async {
    if (_formKey.currentState!.validate()) {
      final user = _edUser.text;
      final password = _edPass.text;

      setState(() {
        _isLoading = true;
      });
      try {
        var userData = await ApiMySql
            .executaSql(
            'select * from login where id_user="$user" and senha="$password"')
            .timeout(const Duration(seconds: 30));
        if (userData!.isEmpty) {
          Utils.snak(
              'attention'.tr, 'emailOrPasswordNF'.tr, false, Colors.red);
        } else {
          if (userData[0]['primeira_vez'] == 'SIM') {
            ///Nesse caso o usuário precisa trocar de senha
            Get.to(() => AlterarSenha(data: userData), arguments: {});
          } else {
            Utils.setIdUser(userData[0]['id']);
            Utils.setUserName(userData[0]['id_user']);
            Utils.setUserMunicipio(userData[0]['municipio']);
            Utils.setUserType(userData[0]['tipo']);
            Get.offAll(() => SplashScreen(), arguments: {});
          }
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF699A92),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (isMobile) {
              return _buildMobileLayout();
            } else if (isTablet) {
              return _buildTabletLayout();
            } else {
              return _buildDesktopLayout();
            }
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            // Imagem no topo para mobile
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/robo_login.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Formulário de login
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: _buildLoginForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Imagem na lateral esquerda
        Expanded(
          flex: 1,
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/robo_login.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // Formulário de login
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Center(
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: _buildLoginForm(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Imagem na lateral esquerda
        Container(
          width: 600,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/robo_login.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 50),
        // Formulário de login
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 500,
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Center(
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildLoginForm(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Texto(
            tit: 'Login',
            negrito: true,
            tam: isMobile ? 24 : 28,
            cor: Colors.black,
            bottom: 10,
          ),
          Texto(
            tit: 'Bem vindo(a) ao GEM',
            bottom: isMobile ? 20 : 40,
            negrito: true,
            tam: isMobile ? 16 : 40,
          ),
          CustomTextFiel(
            controller: _edUser,
            label: 'Usuário',
            hintText: 'Usuário',
            prefixIcon: Icons.perm_contact_cal,
            obrigatorio: true,
            bottom: 10,
          ),
          CustomTextFiel(
            controller: _edPass,
            label: 'Senha',
            hintText: 'Senha',
            prefixIcon: Icons.lock_outline,
            suffixIcon: _obscureText ? Icons.visibility : Icons.visibility_off,
            obrigatorio: true,
            obscureText: _obscureText,
            onToggleVisibility: _togglePasswordVisibility,
          ),
          SizedBox(height: isMobile ? 15 : 20),
          AppButton(
            text: 'login'.tr,
            onPressed: _login,
            isLoading: _isLoading,
            backgroundColor: Color(0xFF699A92),
            textColor: Colors.white,
          ),
          SizedBox(height: isMobile ? 20 : 30),
          Footer(),
        ],
      ),
    );
  }
}