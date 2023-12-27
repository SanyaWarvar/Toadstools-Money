import 'package:test/Transaction.dart';

import 'Account.dart';

class RepeatPeriod{

  late DateTime lastDate;
  late int period; //в днях
  late double amount;
  late String category;
  late int type;


  RepeatPeriod(this.lastDate, this.period, this.amount, this.category, this.type);


  checkDate(){
    //todo добавить уведомление

    final difference = daysBetween(lastDate, DateTime.now());
    if (difference > period){
      return true;
    }
    return false;

  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  factory RepeatPeriod.fromJson(dynamic json) => RepeatPeriod(

      json["lastDate"].toDate(),
      json["period"],
      json["amount"],
      json["category"],
      json["type"],

  );
}
