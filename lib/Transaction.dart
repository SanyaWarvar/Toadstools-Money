
import 'Account.dart';

class MyTransaction{

  late int id;
  late double amount;
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

    return ("$_type $amount\$ - $category "
        "${date.day}.${date.month}.${date.year}-${date.hour}:${date.minute} "
        "$description");
  }

  Map<String, dynamic> toJson() =>{
    "id": id,
    "amount": amount,
    "description": description,
    "category": category,
    "date": date,
    "type": type,

  };

  factory MyTransaction.fromJson(dynamic json) => MyTransaction(
    0,
    json["amount"],
    json["category"],
    json["date"].toDate(),
    json["description"],
    json["type"],

  );
}




