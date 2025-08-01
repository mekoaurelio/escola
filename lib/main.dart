import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:GEM/services/GlobalFilterController.dart';
import 'services/table_name_service.dart';
import 'lang/translation_service.dart';
import 'login/login.dart';
import 'services/utils.dart';
import 'splash_screen.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    // Replace with actual values
    options: FirebaseOptions(
      apiKey: "AIzaSyDLe13nkbjdQkUYTqrOOo3T3WoJIWtHN6g",
      appId: "1:1077818876495:web:0092ca41a2e107fdf6c03a",
      messagingSenderId: "1077818876495",
      projectId: "bolinha-e9545",
      authDomain: "bolinha-e9545.firebaseapp.com",
      storageBucket: "bolinha-e9545.appspot.com",
    ),
  );
  Get.put(GlobalFilterController(), permanent: true);
  Get.put(TableNameService(), permanent: true);

  runApp(const TattooStudioApp());
}

class TattooStudioApp extends StatefulWidget {
  const TattooStudioApp({Key? key}) : super(key: key);

  @override
  State<TattooStudioApp> createState() => _TattooStudioAppState();
}

class _TattooStudioAppState extends State<TattooStudioApp> {
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    // A decisão é tomada AQUI, dentro do ciclo de vida do widget
    _setInitialScreen();
  }


  void _setInitialScreen() {
    // Agora é seguro chamar Utils, pois o widget está sendo inicializado.
    final userId = Utils.getIdUser();
    if (userId == null || userId.isEmpty) {
      _initialScreen = const Login();
    } else {
      _initialScreen = const SplashScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GEM',
      // locale: state.locale,
      supportedLocales: const [
        Locale('pt'), // Português
        Locale('en'), // Inglês
        Locale('es'), // Espanhol
      ],
      locale: TranslationService.locale,
      fallbackLocale: TranslationService.fallbackLocale,
      translations: TranslationService(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,  ],

      home: _initialScreen!,
    //  home: ReceitasEducacionais2025()
        //home: Utils.getIdUser()==null || Utils.getIdUser()=='' ? const Login():const SplashScreen()
      //IndicatorsDashboard()
    );
  }
}