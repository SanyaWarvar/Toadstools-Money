import 'Transaction.dart';

class Account {
  // Счет пользователя
  late String title;
  late double balance;
  late String currency; //планировалось для расширения в будущем. сейчас не нужно
  late String currencyIconPath; //планировалось для расширения в будущем. сейчас не нужно
  late List history;

  Account(
      this.title, this.balance,
      this.currency, this.currencyIconPath,
      this.history
      );

  void addMyTransaction(MyTransaction transaction){
    //добавление транзакции на счет и изменение баланса
    history.add(transaction);
    balance += transaction.amount * transaction.type;
  }

  Map getStatistics(DateTime start, DateTime end, bool option){
    // подсчет статистики по категориям за определенный период.
    //если option == true, то будут только доходы. Иначе только расходы
    var statistic = {};
    for(var item in history){

      if (start.toUtc().isBefore(item.date) && end.toUtc().isAfter(item.date)) {
        if (((option == true) && (item.type > 0)) ||
            ((option == false) && (item.type < 0))) {
          if (statistic[item.category] != null) {
            statistic[item.category] += item.amount;
          } else {
            statistic[item.category] = item.amount;
          }
        }
      }
      }

    return statistic;
  }

  factory Account.fromJson(dynamic json) => Account(
    //преобразование из json

      json["title"],
      json["balance"],
      json["currency"],
      "",//json["currencyIconPath"],
      json["history"]
  );
}
