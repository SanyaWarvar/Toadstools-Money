import 'Transaction.dart';

class Account {
  late String title;
  late int balance;
  late String currency; //наверное нужен кортеж с разными падежами валюты
  late String currencyIconPath;
  late List<Transaction> history;

  Account(
      this.title, this.balance,
      this.currency, this.currencyIconPath,
      this.history
      );

  void addTransaction(Transaction transaction){
    //для пополнения счета транзакция должна быть с отрицательной суммой
    history.add(transaction);
    balance += transaction.amount;
  }

  Map getStatistics(DateTime start, DateTime end, bool option){
    //если option == true, то будут браться и расходы, и доходы
    var statistic = {};
    for(var item in history){
      if (start.isBefore(item.date) && end.isAfter(item.date)) {
        if (option == true || item.amount < 0) {
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