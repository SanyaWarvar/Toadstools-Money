
import 'Account.dart';





class Transaction{

  late int id;
  late int amount;
  late String description;
  late String category;
  late DateTime date;

  Transaction(this.id, this.amount, this.category, this.date, this.description);

  @override
  String toString(){
    return ("$amount $category "
        "${date.day}.${date.month}.${date.year}-${date.hour}:${date.minute} "
        "$description");
  }

  Map<String, dynamic> toJson() =>{
    "id": id,
    "amount": amount,
    "description": description,
    "category": category,
    "date": date.toString(),
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    json["id"],
    json["amount"],
    json["category"],
    DateTime.now(),//json["date"],
    json["description"],
  );




}




main(){



  var a = Account("Банковский счет", 0, "Рубль", "pass", []);
  var tr1 = Transaction(0, -44, "Gasoline", DateTime.now(), "");
  var tr2 = Transaction(1, -14, "Food", DateTime.now(), "");
  var tr3 = Transaction(2, -75, "Clothes", DateTime.now(), "");
  var tr4 = Transaction(3, 1623, "Salary from first job", DateTime.now(), "");
  var tr5 = Transaction(4, 1547, "Salary from second job", DateTime.now(), "");
  
  a.addTransaction(tr4);
  a.addTransaction(tr5);
  a.addTransaction(tr2);
  a.addTransaction(tr3);
  a.addTransaction(tr1);

  print(a.getStatistics(DateTime(2020, 1, 3), DateTime(2021, 12, 3), true));
  print(a.sumByPeriod(DateTime(2020, 1, 3), DateTime(2021, 12, 3), false));
}
