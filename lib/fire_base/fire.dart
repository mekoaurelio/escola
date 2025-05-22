import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/utils.dart';


class Fire {

  static Future<Map<String, dynamic>> getFilmes() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('tattoo_galeria')
          .where('filme', isNotEqualTo: null)
          .orderBy('ordem') // Ordena pelo campo 'ordem' se existir
          .get();

      final filmes = querySnapshot.docs.map((doc) {
        return {
          'nome': doc['filme'],
          'id': doc.id,
          'thumbnail': doc['thumbnail'],
          'ordem': doc['ordem'] ?? 0, // Assume 0 se ordem não existir
        };
      }).toList();

      return {
        'quantidade': filmes.length,
        'filmes': filmes,
      };

    } catch (e) {
      print('Erro ao buscar filmes: $e');
      return {
        'quantidade': 0,
        'filmes': [],
      };
    }
  }

  ///método genérico que verifica se um determinado campo tem um certo valor
  static Future<DocumentSnapshot?> chechIfExisteDocumento({
    required String collectionName,
    required Map<String, dynamic> campos,
  }) async {
    try {
      CollectionReference ref = FirebaseFirestore.instance.collection(collectionName);
      Query query = ref;

      // Aplica os filtros da query
      campos.forEach((campo, valor) {
        query = query.where(campo, isEqualTo: valor);
      });

      final snapshot = await query.limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao buscar documento: $e');
      return null;
    }
  }

  /// Verifica se o email existe
  static Future<DocumentSnapshot?> checkIfEmailExists(
      {required String email}) async {
    try {
      final dados = await chechIfExisteDocumento(
        collectionName: 'empresas',
        campos: {
          'email': email,
        },
      );
      return dados;
    } catch (e) {
      print('Erro ao verificar campo no Firestore: $e');
      return null;
    }
  }

  /// Verifica se email e senha existe
  static Future<DocumentSnapshot?> checkIfEmailSenhaExiste(
      {required String email, required String senha}) async {
    try {
      final dados = await chechIfExisteDocumento(
        collectionName: 'usuario',
        campos: {'email': email, 'senha': senha},
      );
      return dados;
    } catch (e) {
      print('Erro ao verificar campo no Firestore: $e');
      return null;
    }
  }

  ///Retorna dados genéricos
  static Future<DocumentSnapshot?> getTattooData(String colecao, String id) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection(colecao)
          .doc(id)
          .get();
      return docSnapshot.exists ? docSnapshot : null;

    } on FirebaseException catch (e) {
      print('🔥 Erro no Firestore: ${e.code} - ${e.message}');
      rethrow; // Opcional: propagar o erro para quem chamou
    } catch (e) {
      print('❌ Erro desconhecido: $e');
      return null;
    }
  }

  ///Insere uma nova empresa
  static Future addEmpresa(var email) async {
    try {
      final collectionRef = FirebaseFirestore.instance.collection('empresas');
      final docRef = await collectionRef.add({
        'email': email,
        'dataCriado': FieldValue.serverTimestamp(),
        'dataAtualizado': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      return 'erro $e';
    }
  }

  ///ADD um novo filme
  static Future addFilme(var filme,String? thumbnailBase64) async {
    try {
      final ordem = await obterMaiorOrdem() + 1;
      final collectionRef = FirebaseFirestore.instance.collection('tattoo_galeria');
      final docRef = await collectionRef.add({
        'filme': filme,
        'ordem': ordem,
        'thumbnail': thumbnailBase64,
      });
      return docRef.id;
    } catch (e) {
      return 'erro $e';
    }
  }

 static Future<int> obterMaiorOrdem() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('tattoo_galeria')
        .orderBy('ordem', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final maiorOrdem = snapshot.docs.first.get('ordem');
      print('MAIOR $maiorOrdem');
      return maiorOrdem is int ? maiorOrdem : 0;
    } else {
      print('VAZIO');
      return 0; // Se não houver documentos, começa do zero
    }
  }


  /// atualiza os dados da empresa
  static Future<bool> atualizarEmpresa({
    String? foto,
  }) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('tattoo_config').doc('94ExteeqmeIFR1mBQFo5');

      final Map<String, dynamic> dadosAtualizar = {};

      if (foto != null && foto.trim().isNotEmpty) {
        dadosAtualizar['foto'] = foto;
      }

      if (dadosAtualizar.isEmpty) {
        print('Nenhum dado válido para atualizar.');
        return false;
      }

      dadosAtualizar['dataAtualizado'] = FieldValue.serverTimestamp();

      await docRef.update(dadosAtualizar);
      return true;
    } catch (e) {
      print('Erro ao atualizar empresa: $e');
      return false;
    }
  }

  ///Add um novo usu'rio
  static Future addUsuario(var idEmpresa, var email) async {
    try {
      String senha = Utils.randomNumber();
      final collectionRef = FirebaseFirestore.instance.collection('usuario');
      final docRef = await collectionRef.add({
        'idEmpresa': idEmpresa,
        'email': email,
        'nomeUsuario': 'adm',
        'senha': senha,
        'dataCriado': FieldValue.serverTimestamp(),
        'dataAtualizado': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      return 'erro $e';
    }
  }

}


