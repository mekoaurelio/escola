class ProfessorUtils {

  static Map<String, int> _professoresPorNivel = {};
  static final List<String> niveis = ['BASE', 'NA', 'NB', 'NC', 'ND', 'NE'];

 static  int quantidadeDeProfessores(String nivel, int coluna) {
    // Formata o nível/classe no formato esperado (ex: "B01" para NB coluna 1)
    String nivelFormatado = nivel.substring(1); // Remove o "N" do início
    String colunaFormatada = coluna < 10 ? '0$coluna' : '$coluna';
    String chave = '$nivelFormatado$colunaFormatada';
    return _professoresPorNivel[chave] ?? 0;
  }

  static double totalDeVencimentos(String nivel, int coluna, var professores) {
    // Formata o nível/classe no formato esperado (ex: "B01" para NB coluna 1)
    String nivelFormatado = nivel.substring(1); // Remove o "N" do início
    String colunaFormatada = coluna < 10 ? '0$coluna' : '$coluna';
    String chave = '$nivelFormatado$colunaFormatada';

    double total = 0.0;

    for (var professor in professores) {
      if (professor['nivel'] == chave && professor['vencimento'] != null) {
        total += double.tryParse(professor['vencimento'].toString()) ?? 0.0;
      }
    }

    return total;
  }

  // Método auxiliar para calcular o total por nível
  static double calculateTotalForLevel(String nivel,var professores,int cargaHoraria) {
    double total = 0.0;
    for (int coluna = 0; coluna < cargaHoraria; coluna++) {
      total += ProfessorUtils.totalDeVencimentos(nivel, coluna + 1,professores);
    }
    return total;
  }
}