class MyTransaction{
  //транзакция

  late int id;  //планировалось для расширения, на данный момент не используется
  late double amount;
  late String description;
  late String category;
  late DateTime date;
  late int type;

  MyTransaction(this.id, this.amount, this.category, this.date, this.description, this.type);

  @override
  String toString(){
    //преобразование в строку
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

  factory MyTransaction.fromJson(dynamic json) => MyTransaction(
    //преобразование из json

    0,
    json["amount"],
    json["category"],
    json["date"].toDate(),
    json["description"],
    json["type"],

  );
}
