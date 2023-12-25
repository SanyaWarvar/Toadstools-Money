import 'Transaction.dart';


class Account {
  late String title;
  late double balance;
  late String currency; //наверное нужен кортеж с разными падежами валюты
  late String currencyIconPath;
  late List<MyTransaction> history;

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
}


main(){
  Account ac = Account("title", 0, "currency", "currencyIconPath", []);
  ac.addMyTransaction(MyTransaction(0, 15, "s", DateTime(2023, 12, 1), "description", -1));
  print(ac.getStatistics(DateTime(2005, 1, 2), DateTime(2023, 12, 2), false));


}
