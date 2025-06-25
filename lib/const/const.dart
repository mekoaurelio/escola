import 'package:flutter/material.dart';

const  corFundoInativo=Colors.white;
const  corLetraAtiva=Colors.black;
const  corLetraInativa=Colors.grey;
const Color primaryColor = Color(0xFF1976D2);
const Color backgroundColor = Color(0xFFFAFAFA);
const Color textColor = Color(0xFF212121);
const Color borderColor = Color(0xFFE0E0E0);

//Diretorios
const pathDados= 'https://www.xmktech.net/tattoo/dados';
const pathImage= 'https://www.xmktech.net/tattoo/imagens';

//Arquivos PHP
String arqPhpGetImage = '$pathImage/get_image.php?filename=';

//IMPACTO
const d1 =  'Soma de todos os vencimentos';
const d2 =  'Soma de todos oa vantagens';
const d3 =  'Percentual do nro 2 em relação nro 1\n (nro2/nro1)*100';
const d4 =  'Vantagens menos os vencimentos';
const d5 =  'Esse valor veio do simulado';
const d6 =  'Percentual (nro5) sobre o nro 4';
const d7 =  'Um doze ávos sobre o nro6';
const d8 =  '1/3 sobre o nro 6\n (1/3)* nro 6';
const d9 =  'Soma de nro4+nro6+nro7+nro8';
const d10 =  'Nro 9 x 12';
const d11 =  'Estimatima do FUNDEB para o ano corrente\nEsse valor vem do simulador';
const d12 =  '10% do ítem anterior';
