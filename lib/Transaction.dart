
import 'Account.dart';

class MyTransaction{

  late int id;
  late int amount;
  late String description;
  late String category;
  late DateTime date;
  late int type;

  MyTransaction(this.id, this.amount, this.category, this.date, this.description, this.type);

  @override
  String toString(){
    String _type = "";
    if (type == 1) {
      _type = "Пополнение";
    }else{
      _type = "Расход";
    }

    return ("$_type $amount $category "
        "${date.day}.${date.month}.${date.year}-${date.hour}:${date.minute} "
        "$description");
  }

  Map<String, dynamic> toJson() =>{
    "id": id,
    "amount": amount,
    "description": description,
    "category": category,
    "date": date.toString(),
    "type": type
  };

  factory MyTransaction.fromJson(Map<String, dynamic> json) => MyTransaction(
    json["id"],
    json["amount"],
    json["category"],
    DateTime.now(),//json["date"],
    json["description"],
    json["type"]
  );




}




main(){



  var a = Account("Банковский счет", 0, "Рубль", "pass", []);
  var tr1 = MyTransaction(0, 44, "Gasoline", DateTime.now(), "", -1);
  var tr2 = MyTransaction(1, 14, "Food", DateTime.now(), "", -1);
  var tr3 = MyTransaction(2, 75, "Clothes", DateTime.now(), "", -1);
  var tr4 = MyTransaction(3, 1623, "Salary from first job", DateTime.now(), "", 1);
  var tr5 = MyTransaction(4, 1547, "Salary from second job", DateTime.now(), "", 1);
  
  a.addMyTransaction(tr4);
  a.addMyTransaction(tr5);
  a.addMyTransaction(tr2);
  a.addMyTransaction(tr3);
  a.addMyTransaction(tr1);

  print(a.getStatistics(DateTime(2020, 1, 3), DateTime(2021, 12, 3), true));
  print(a.sumByPeriod(DateTime(2020, 1, 3), DateTime(2021, 12, 3), false));
}
