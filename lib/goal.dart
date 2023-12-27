class Goal{
  late double amount;
  late String category;
  late DateTime firstDate;
  late DateTime secondDate;
  late bool type;
  late String userId;
  late bool result;
  
  Goal(this.amount, this.category, this.firstDate, this.secondDate, this.type, this.userId, this.result);

  factory Goal.fromJson(dynamic json) => Goal(
      json["amount"],
      json["category"],
      json["firstDate"].toDate(),
      json["secondDate"].toDate(),
      json["type"],
      json["userId"],
      json["result"]
  );

  Map<String, dynamic> toJson() =>{
    "amount": amount,
    "category": category,
    "firstDate": firstDate,
    "secondDate": secondDate,
    "type": type,
    "userId": userId,
    "result": result
  };

  bool checkRes(excepted){
    if ((type && excepted >= amount) || (!type && excepted <= amount)){
      return true;
    }
    return false;
  }
  
}