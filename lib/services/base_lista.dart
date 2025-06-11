
import 'package:flutter/material.dart';

import '../const/const.dart';
import '../data/api_my_sql.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/texto.dart';
import 'screenSize.dart';
import 'utils.dart';

abstract class ListaBase extends StatefulWidget {
  const ListaBase({
    Key? key,
  }) : super(key: key);

  @override
  ListaBaseState createState() => createStateBase();

  ListaBaseState createStateBase();
}

abstract class ListaBaseState<T extends ListaBase> extends State<T> {
  TextEditingController controller = TextEditingController();
  List lista = [];
  List currentItems=[];
  List listaOriginal = [];
  bool isLoadingBase = true;
  var userId='';
  int hoverIndex = -1;
  var row;
  final int itemsPerPage = 12; // Define quantos itens por página
  int currentPage = 1;
  String? entidade;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      inicio();
    });
  }

  // void carregarDados(List<dynamic> data) async{
  void carregarDados(String table) async{
    List data=[];
    if(table=='folha'){
      data=await ApiMySql.getProfessor();
    }else {
      data = await ApiMySql.get(table, null, null);
    }
   // print(data);
    setState(() {
      lista = data;
      listaOriginal = List.from(lista);
      userId='1';
    //  userId=Utils.getUserName();
      isLoadingBase = false;
     // entidade=Utils.getEntidadeName();
    });
  }

  Widget image() {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: row['foto'] != null && row['foto'].toString().isNotEmpty
          ? NetworkImage(pathImage + row['foto']) as ImageProvider
          : null, // Remove a imagem quando não houver foto
      child: row['foto'] == null || row['foto'].toString().isEmpty
          ? Icon(Icons.person, color: Colors.white, size: 20) // Ícone padrão
          : null,
    );
  }

  Future<void> delData(int index,var table) async {
    final nome = lista[index]['nome'];
    final bool confirmar = await Utils.showDlg('Atenção', 'Confirma a exclusão de $nome?', context, 'Sim', 'Não',
    );
    if (confirmar) {
      await ApiMySql.executaSql("DELETE FROM $table WHERE id=${lista[index]['id']}");
      lista = await ApiMySql.get(table,null,null);
      setState(() {});
    }
  }

  Future<void> inicio() async {}

  @override
  Widget build(BuildContext context) {
    final screenSizeConfig = ScreenSizeConfig(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: isLoadingBase
            ? CircularProgressIndicator()
        //Utils.semDados()
            : buildContent(context, screenSizeConfig),
      ),
    );
  }

  Widget buildContent(BuildContext context, ScreenSizeConfig screenSizeConfig) {
    int totalPages = (lista.length / itemsPerPage).ceil();
    int startItemIndex = (currentPage - 1) * itemsPerPage;
    int endItemIndex = startItemIndex + itemsPerPage;
    currentItems = lista.sublist(
      startItemIndex,
      endItemIndex > lista.length ? lista.length : endItemIndex,
    );

    return Container(
      constraints: BoxConstraints(maxWidth: 600),
      width: screenSizeConfig.isMobile ? double.infinity : 600,
      child: Column(
        children: [
          SizedBox(height: 10,),
          _buildHeader(screenSizeConfig),

          Card(
              color: Colors.grey.shade300,
              elevation: 0,
              shape: Utils.borda(),
              child: cabecalho()
          ),

          Expanded(
            child: currentItems.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/indisponivel.png",
                    width: 150, // Ajuste o tamanho da imagem
                    height: 150,
                    fit: BoxFit.cover, // Cobrir o espaço circular
                  ),
                  SizedBox(height: 10),
                  Texto(tit: 'Nenhum dado disponível',cor: Colors.grey,tam: 18,),
                ],
              ),
            )
                : ListView.builder(
              itemCount: currentItems.length,
              itemBuilder: (context, index) {
                row = currentItems[index];
                return _buildListItem(index, screenSizeConfig);
              },
            ),
          ),
          _buildFooter(totalPages, screenSizeConfig),
        ],
      ),
    );
  }

  Widget _buildHeader(ScreenSizeConfig screenSizeConfig) {
    return
      Row(
        children: [
          Expanded(
            child: CustomTextFiel(
              controller: controller,
              label: '',
              hintText: getTituloPesquisa(),
              prefixIcon: Icons.search_outlined,
              //inputFormatters:field.inputFormatters,
              obrigatorio: false,
              onChanged:onChange ,
            )
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showAddIcon)
                IconButton(
                  onPressed: () => onAdd(),
                  icon: const Icon(
                    Icons.add_circle_outline,
                    size: 25,
                    color: Colors.black54,
                  ),
                  padding: EdgeInsets.zero, // Remove o padding padrão do IconButton
                ),
            ],
          )
          // Adjust style
        ],
      );
  }

  Widget _buildListItem(int index, ScreenSizeConfig screenSizeConfig) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 5, right: 5, bottom: 0),
      child: InkWell(
        onTap: () {
          selecao(lista[index]);
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => hoverIndex = index),
          onExit: (_) => setState(() => hoverIndex = -1),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.0,         // Espessura da linha
                ),
              ),
            ),
            child: buildGridChildren(index,screenSizeConfig),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(int totalPages, ScreenSizeConfig screenSizeConfig) {
    return Container(
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 1 ? () => setState(() => currentPage = 1) : null,
            icon: Icon(Icons.first_page, color: Colors.black54, size: screenSizeConfig.getFooterIconSize()),
          ),
          IconButton(
            onPressed: currentPage > 1 ? () => setState(() => currentPage--) : null,
            icon: Icon(Icons.arrow_back, color: Colors.black54, size: screenSizeConfig.getFooterIconSize()),
          ),
          Texto(tit: 'Página $currentPage de $totalPages', cor: Colors.black54, tam: screenSizeConfig.getBodyFontSize()),
          IconButton(
            onPressed: currentPage < totalPages ? () => setState(() => currentPage++) : null,
            icon: Icon(Icons.arrow_forward, color: Colors.black54, size: screenSizeConfig.getFooterIconSize()),
          ),
          IconButton(
            onPressed: currentPage < totalPages ? () => setState(() => currentPage = totalPages) : null,
            icon: Icon(Icons.last_page, color: Colors.black54, size: screenSizeConfig.getFooterIconSize()),
          ),
          Texto(tit: lista.length.toString() + ' Ítens', cor: Colors.black54, tam: screenSizeConfig.getBodyFontSize()),
        ],
      ),
    );
  }

  // Abstract methods that must be implemented in subclasses
  Column buildGridChildren(int index,ScreenSizeConfig screenSizeConfig);
  Widget cabecalho();
  void selecao(var row);
  String getTituloPesquisa();
  String getAppBarTitle();
  void onChange(String text) {}
  void onAdd() {}
  bool showAddIcon=true;
}