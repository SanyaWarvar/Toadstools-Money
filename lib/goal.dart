class Goal{
  //пользовательская цель
  late double amount;
  late String category;
  late DateTime firstDate;
  late DateTime secondDate;
  late bool type;
  late String userId;
  late bool result;
  
  Goal(this.amount, this.category, this.firstDate, this.secondDate, this.type, this.userId, this.result);

  factory Goal.fromJson(dynamic json) => Goal(
    //преобразование из json

      json["amount"],
      json["category"],
      json["firstDate"].toDate(),
      json["secondDate"].toDate(),
      json["type"],
      json["userId"],
      json["result"]
  );

  bool checkRes(excepted){
    // проверяет успешна ли цель. Если цель успешна, то возвращает true
    if ((type && excepted >= amount) || (!type && excepted <= amount)){
      return true;
    }
    return false;
  }
  
}