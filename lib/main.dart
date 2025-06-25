import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'lang/translation_service.dart';
import 'services/ano_bimestre_controller.dart';
import 'services/utils.dart';
import 'start.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  final ano = Utils.getAno() ?? '25';
  final bimestre = Utils.getBimestre() ?? "Primeiro Bimestre";

  Get.put(AnoBimestreController(
    anoInicial: ano,
    bimestreInicial: bimestre,
  ));


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

  runApp(TattooStudioApp());
}

class TattooStudioApp extends StatefulWidget {
  const TattooStudioApp({Key? key}) : super(key: key);

  @override
  State<TattooStudioApp> createState() => _TattooStudioAppState();
}

class _TattooStudioAppState extends State<TattooStudioApp> {

  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meu App',
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

      home: const Start(),
    );
  }
}