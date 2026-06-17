import 'package:app_workmatch/model/TabModel.dart';

const List<TabModel> tabsCliente = [
  TabModel(
    label: "Ativos",
    statuses: [
      "PUBLICADO",
      "NEGOCIANDO",
      "CONTRATADO",
      "ANDAMENTO",
    ],
  ),
  TabModel(
    label: "Finalizados",
    statuses: [
      "FINALIZADO",
    ],
  ),
  TabModel(
    label: "Arquivados",
    statuses: [
      "ARQUIVADO",
    ],
  ),
];
