import 'Transaction.dart';


class Account {
  late String title;
  late double balance;
  late String currency; //наверное нужен кортеж с разными падежами валюты
  late String currencyIconPath;
  late List history;

  Account(
      this.title, this.balance,
      this.currency, this.currencyIconPath,
      this.history
      );

  void addMyTransaction(MyTransaction transaction){
    //для пополнения счета транзакция должна быть с отрицательной суммой
    history.add(transaction);
    balance += transaction.amount * transaction.type;
  }

  Map getStatistics(DateTime start, DateTime end, bool option){
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

  int sumByPeriod(DateTime start, DateTime end, bool option) {
    var statistic = getStatistics(start, end, option);
    int sum = 0;
    for (var element in statistic.values) {
      if (element != null) {
        sum += element as int;
      }
    }
    return sum;
  }

  /*List toJsonHistory(){
    List entries = [];
    for (var element in history){
      entries.add(element.toJson);
    }
    return entries;
  }*/

  factory Account.fromJson(dynamic json) => Account(
      json["title"],
      json["balance"],
      json["currency"],
      "",//json["currencyIconPath"],
      json["history"]
  );

  Map<String, dynamic> toJson() =>{
    "title": title,
    "balance": balance,
    "currency": currency,
    "currencyIconPath": currencyIconPath,
    "history": history/*toJsonHistory()*/,

  };

}


