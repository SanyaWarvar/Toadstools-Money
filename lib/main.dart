import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:test/Transaction.dart";
import 'package:test/Account.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:test/goal.dart';
import 'package:test/repeat.dart';
import 'firebase_options.dart';
import 'package:device_info_plus/device_info_plus.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp(title: "Toadstools Money",));
}



class MyApp extends StatelessWidget {
  const MyApp({super.key, required title});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Toadstools Money',
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,  //const Color.fromARGB(100, 202, 218, 186),

          textTheme: const TextTheme(
              bodyMedium: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.bold
              ),
              bodySmall: TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(100, 20, 20, 20)
              ),
              bodyLarge: TextStyle(
                  fontSize: 20,
                  color: Colors.black
              )
          )

      ),
      routes: {
        "/": (context) => const MyHomePage(),
        "/NewTransaction" : (context) => const NewTransactionScreen(),
        "/Statistic" : (context) => const StatisticScreen(),
        "/Goal" : (context) => const GoalScreen(),
        "/RepeatList" : (context) => const RepeatList(),
        "/GoalList" : (context) => const GoalsList(),

      },
    );
  }

}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});



  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  Account currentAccount =  Account("debugname", 0, "₽", "", []);


  Map<String, dynamic> _deviceData = <String, dynamic>{};


  @override
  void initState() {
    super.initState();
    initPlatformState();
    WidgetsBinding.instance.addPostFrameCallback((_){
    });
  }


  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};
    deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    setState(() {
      _deviceData = deviceData;
    });

    getBalance();
    checkRepeat();
  }



  getBalance() async {
    Account entries =  Account("debugname", 0, "₽", "", []);

    await FirebaseFirestore.instance.
    collection("transactions").
    where("userId", isEqualTo: "${_deviceData["androidId"]}").
    get().then((document) {

      var data = document.docs.toList();
      for (var element in data){

        //MyTransaction t = MyTransaction(0, element["amount"], element["category"], DateTime.now(), "", element["type"]);
        MyTransaction t = MyTransaction.fromJson(element);
        entries.addMyTransaction(t);
      }
      setState(() {
        currentAccount = entries;
      });
    });
  }

  checkRepeat() async {
    await FirebaseFirestore.instance.
    collection("repeat").
    where("userId", isEqualTo: _deviceData["androidId"]).
    get().then((document) {

      var data = document.docs.toList();
      for (var element in data){
        RepeatPeriod rep = RepeatPeriod.fromJson(element);

        while(rep.checkDate())
        {
          rep.lastDate = DateTime(rep.lastDate.year, rep.lastDate.month, rep.lastDate.day + rep.period);

          FirebaseFirestore.instance
              .collection('repeat').doc(
              element.id
          )
              .set(
              {
                "userId": _deviceData["androidId"],
                "lastDate": rep.lastDate,
                "period": rep.period,
                "amount": rep.amount,
                "category": rep.category,
                "type": rep.type,
              });

          FirebaseFirestore.instance
              .collection('transactions').doc(
              "${_deviceData["androidId"]}-${currentAccount.title}-${rep.type}-${rep.category}-${rep.lastDate.year}.${rep.lastDate.month}.${rep.lastDate.day}-${currentAccount.history.length}"
          )
              .set(
              {
                "userId": _deviceData["androidId"],
                "amount": rep.amount,
                "category": rep.category,
                "description": "",
                "type": rep.type,
                "date": rep.lastDate
              });
        }
      }

    });


  }


  @override
  Widget build(BuildContext context) {
    checkRepeat();
    //var theme = Theme.of(context);

    return Scaffold(
      bottomSheet: BottomAppBar(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(onPressed: (){Navigator.pushNamed(context, '/Statistic');}, icon: const Icon(Icons.pie_chart)),
            IconButton(onPressed: (){Navigator.pushNamed(context, '/RepeatList');}, icon: const Icon(Icons.watch_later_outlined)),
            IconButton(onPressed: (){Navigator.pushNamed(context, '/NewTransaction');}, icon: const Icon(Icons.add)),
            //IconButton(onPressed: (){Navigator.pushNamed(context, '/Goal');}, icon: const Icon(Icons.rate_review)),
            IconButton(onPressed: (){Navigator.pushNamed(context, '/GoalList');}, icon: const Icon(Icons.receipt))
          ],
        ),
      ),
      appBar: AppBar(
        title: Row(
            children: [
              Text("Баланс: ${currentAccount.balance}${currentAccount.currency}"),
            ]
        ),
        backgroundColor: Colors.green,
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('transactions').where(
            "userId", isEqualTo: "${_deviceData["androidId"]}"
        ).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          getBalance();


          if (!snapshot.hasData) {
            return const Center(
              child: Text(""),
            );
          }

          return Column(
              children:[
                SizedBox(
                    width: double.maxFinite,
                    height: 600,
                    child: SingleChildScrollView(
                        child: Column(
                          children: snapshot.data!.docs.map((document) {
                            var curTransaction = MyTransaction.fromJson(document);

                            return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(width:330, child: ListTile(
                                    title: Text("${curTransaction.amount * curTransaction.type} ${curTransaction.category}"),
                                    subtitle: Text("${curTransaction.date.day}.${curTransaction.date.month}.${curTransaction.date.year}"),


                                  )),

                                  IconButton(onPressed: (){

                                    setState(() {
                                      document.reference.delete();
                                      getBalance();
                                    });

                                  }, icon: const Icon(Icons.delete, color: Colors.red,))
                                ]
                            );

                          }).toList(),))),
              ]
          );
        },
      ),
    );
  }
}


class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({super.key, account});

  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Account currentAccount =  Account("debugname", 0, "₽", "", []);

  Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    initPlatformState();

  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};
    deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    setState(() {
      _deviceData = deviceData;
    });

    getBalance();
  }

  getBalance() async {
    Account entries =  Account("debugname", 0, "₽", "", []);

    await FirebaseFirestore.instance.
    collection("transactions").
    where("userId", isEqualTo: "${_deviceData["androidId"]}").
    get().then((document) {

      var data = document.docs.toList();
      for (var element in data){

        //MyTransaction t = MyTransaction(0, element["amount"], element["category"], DateTime.now(), "", element["type"]);
        MyTransaction t = MyTransaction.fromJson(element);
        entries.addMyTransaction(t);
      }
      setState(() {
        currentAccount = entries;
      });
    });
  }





  String amount = "0";
  String category = "Продукты";
  String description = "";
  int type = -1;
  DateTime date = DateTime.now();
  bool repeat = false;
  int repeatValue = 1;



  TextStyle keyboardStyle = const TextStyle(color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*bottomSheet: BottomAppBar(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(onPressed: (){Navigator.pushNamed(context, '/Statistic');}, icon: const Icon(Icons.pie_chart)),
            IconButton(onPressed: (){
              Navigator.pushNamed(context, '/NewTransaction');
            }, icon: const Icon(Icons.add)),
            IconButton(onPressed: (){Navigator.pushNamed(context, '/Goal');}, icon: const Icon(Icons.grade))
          ],
        ),
      ),*/
      bottomSheet: BottomAppBar(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(onPressed: (){Navigator.popUntil(context, ModalRoute.withName('/'));}, icon: const Icon(Icons.close), color: Colors.red,),
                IconButton(onPressed: () async {
                  if (double.parse(amount) == 0){
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  }
                  await getBalance();

                  int l = currentAccount.history.length;

                  FirebaseFirestore.instance
                      .collection('transactions').doc(
                      "${_deviceData["androidId"]}-${currentAccount.title}-$type-$category-${date.year}.${date.month}.${date.day}-$l"
                  )
                      .set(
                      {
                        "amount": double.parse(amount),
                        "category": category,
                        "date": date,
                        "description": description,
                        "userId": _deviceData["androidId"],
                        "type": type,
                        "accountName": "${_deviceData["androidId"]}-${currentAccount.title}-${currentAccount.currency}"
                      });

                  currentAccount.addMyTransaction(
                      MyTransaction(0, double.parse(amount), category, date, description, type));

                  if (repeat){
                    FirebaseFirestore.instance
                        .collection('repeat').doc(
                        "${_deviceData["androidId"]}-${currentAccount.title}-$type-$category-${date.year}.${date.month}.${date.day}-$l"
                    )
                        .set(
                        {
                          "userId": _deviceData["androidId"],
                          "lastDate": date,
                          "period": repeatValue,

                          "amount": double.parse(amount),
                          "category": category,
                          "type": type,
                          "accountName": "${_deviceData["androidId"]}-${currentAccount.title}-${currentAccount.currency}" //todo replace normal
                        });

                  }


                  Navigator.popUntil(context, ModalRoute.withName('/'));
                }, icon: const Icon(Icons.check), color: Colors.green,),

              ]
          )
      ),
      appBar: AppBar(
        title: Row(
            children: [
              Text("Баланс: ${currentAccount.balance}${currentAccount.currency}"),
            ]
        ),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Row(children: [Expanded(child:ListTile(
              title: const Text("Расход"),
              leading: Radio<int>(value: -1, groupValue: type, onChanged: (int? value) {
                setState(() {
                  type = value!;
                  category = "Продукты";
                });
              })
          )),
            Expanded(child:ListTile(
                title: const Text("Доход"),
                leading: Radio<int>(value: 1, groupValue: type, onChanged: (int? value) {
                  setState(() {
                    type = value!;
                    category = "Зарплата";
                  });
                }
                )))
          ]),

          Row(children: [Expanded(child:ListTile(
              title: const Text("Разовый"),
              leading: Radio<bool>(value: false, groupValue: repeat, onChanged: (bool? value) {
                setState(() {
                  repeat = value!;
                });
              })
          )),
            Expanded(child:ListTile(
                title: const Text("Повторяемый"),
                leading: Radio<bool>(value: true, groupValue: repeat, onChanged: (bool? value) {
                  setState(() {
                    repeat = value!;
                  });
                }
                )))
          ]),

          if (repeat)

            DropdownButton<String>(
              hint: Text("Частота повтора: $repeatValue дня/дней"),
              items: <String>["1", "2", "3", "7", "14", "28", "30", "31"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  repeatValue = int.parse(newValue!);
                });

              },
            ),

          Padding(padding: const EdgeInsets.all(20),
            child:SizedBox(
              width: 300,
              height: 200,
              child: ListView.builder(
                  itemCount: 1,

                  /*gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 0,
                    crossAxisCount: 3,
                  ),*/

                  itemBuilder: (BuildContext context, int index) {

                    if (type == -1){
                      return Column(
                        children: [
                          ListTile(
                              title: const Text("Продукты"),
                              leading: Radio<String>(value: "Продукты", groupValue: category, onChanged: (String? value) {
                                setState(() {
                                  category = value!;
                                });
                              })
                          ),

                          ListTile(
                              title: const Text("Кафе"),
                              leading: Radio<String>(value: "Кафе", groupValue: category, onChanged: (String? value) {
                                setState(() {
                                  category = value!;
                                });
                              })
                          ),

                          ListTile(
                              title: const Text("Транспорт"),
                              leading: Radio<String>(value: "Транспорт", groupValue: category, onChanged: (String? value) {
                                setState(() {
                                  category = value!;
                                });
                              })
                          ),

                          ListTile(
                              title: const Text("Здоровье"),
                              leading: Radio<String>(value: "Здоровье", groupValue: category, onChanged: (String? value) {
                                setState(() {
                                  category = value!;
                                });
                              })
                          ),

                          ListTile(
                              title: const Text("Дом"),
                              leading: Radio<String>(value: "Дом", groupValue: category, onChanged: (String? value) {
                                setState(() {
                                  category = value!;
                                });
                              })
                          ),

                          ListTile(
                              title: const Text("Одежда"),
                              leading: Radio<String>(value: "Одежда", groupValue: category, onChanged: (String? value) {
                                setState(() {
                                  category = value!;
                                });
                              })
                          )
                        ],
                      );
                    }else{
                      return Column(
                        children: [
                          ListTile(
                              title: const Text("Зарплата"),
                              leading: Radio<String>(value: "Зарплата", groupValue: category, onChanged: (String? value) {
                                setState(() {
                                  category = value!;
                                });
                              })
                          ),

                          ListTile(
                              title: const Text("Подарки"),
                              leading: Radio<String>(value: "Подарки", groupValue: category, onChanged: (String? value) {
                                setState(() {
                                  category = value!;
                                });
                              })
                          )
                        ],
                      );
                    }






                  }
              ),

            ),
          ),

          Padding(
              padding: const EdgeInsets.only(left: 20),
              child:Align(alignment: Alignment.centerLeft,
                  child:Text("Сумма: $amount"))
          ),

          Align(
              alignment: Alignment.topLeft, child: SizedBox(
              width: 350,
              height: 250,
              child: Row(
                  children:[
                    SizedBox(
                        width:180,
                        height: 240,
                        child:GridView(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: 0,
                            crossAxisCount: 3,
                          ),
                          children: [
                            TextButton(onPressed: (){
                              amount = writeDigit(amount, "1");
                              setState(() {});
                            }, child: Text("1", style: keyboardStyle)),
                            TextButton(onPressed: (){
                              amount = writeDigit(amount, "2");
                              setState(() {});
                            }, child: Text("2", style: keyboardStyle)),
                            TextButton(onPressed: (){
                              amount = writeDigit(amount, "3");
                              setState(() {});
                            }, child: Text("3", style: keyboardStyle)),
                            TextButton(onPressed: (){
                              amount = writeDigit(amount, "4");
                              setState(() {});
                            }, child: Text("4", style: keyboardStyle)),
                            TextButton(onPressed: (){
                              amount = writeDigit(amount, "5");
                              setState(() {});
                            }, child: Text("5", style: keyboardStyle)),
                            TextButton(onPressed: (){
                              amount = writeDigit(amount, "6");
                              setState(() {});
                            }, child: Text("6", style: keyboardStyle)),
                            TextButton(onPressed: (){
                              amount = writeDigit(amount, "7");
                              setState(() {});
                            }, child: Text("7", style: keyboardStyle)),
                            TextButton(onPressed: (){
                              amount = writeDigit(amount, "8");
                              setState(() {});
                            }, child: Text("8", style: keyboardStyle)),
                            TextButton(onPressed: (){
                              amount = writeDigit(amount, "9");
                              setState(() {});
                            }, child: Text("9", style: keyboardStyle)),
                            TextButton(onPressed: (){
                              amount = writeDigit(amount, "0");
                              setState(() {});
                            }, child: Text("0", style: keyboardStyle)),
                            TextButton(onPressed: (){
                              amount = writeDigit(amount, ".");
                              setState(() {});
                            }, child: Text(".", style: keyboardStyle)),
                            TextButton(onPressed: (){
                              amount = writeDigit(amount, "00");
                              setState(() {});
                            }, child: Text("00", style: keyboardStyle)),
                          ],

                        )),
                    SizedBox(
                        width: 60,
                        height: 250,
                        child: ListView(

                            children: [
                              const SizedBox(height: 7),
                              IconButton(onPressed: (){
                                if (amount != "0"){
                                  if (amount.length == 1){
                                    amount = "0";
                                  }
                                  else{
                                    amount = amount.substring(0, amount.length - 1);
                                  }
                                  setState(() {
                                  });
                                }
                              }, icon: const Icon(Icons.arrow_back)),
                              const SizedBox(height: 13),
                              IconButton(onPressed: (){
                                amount = writeDigit(amount, "+");
                                setState(() {});
                              }, icon: const Icon(Icons.add)),
                              const SizedBox(height: 13),
                              IconButton(onPressed: (){
                                amount = writeDigit(amount, "-");
                                setState(() {});
                              }, icon: const Icon(Icons.remove)),
                              const SizedBox(height: 13),
                              TextButton(onPressed: (){
                                amount = calculateString(amount);
                                setState(() {
                                });


                              }, child: const Text("=", style: TextStyle(fontSize: 30, color: Colors.black),))
                            ]

                        )),
                    SizedBox(
                        width: 100,
                        height: 250,
                        child: ListView(
                          children: [
                            const SizedBox(height: 7),
                            TextButton(onPressed: () async {
                              date = await onTapFunction(context: context);
                              setState(()  {
                              });
                            }, child: Text("${date.day}.${date.month}.${date.year}", style: keyboardStyle)
                            ),




                          ],
                        ))

                  ])

          )),




        ],
      ),
    );
  }
}


class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreen();
}

class _StatisticScreen extends State<StatisticScreen> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Account currentAccount = Account("title", 0, "currency", "currencyIconPath", []);
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  Map<String, PieChartSectionData> pieData = {};
  late Map stat;

  @override
  void initState() {
    super.initState();
    initPlatformState();

  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};
    deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    setState(() {
      _deviceData = deviceData;

    });

    await getBalance();



  }


  DateTime firstDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime secondDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59);
  bool option = false;
  getBalance() async {
    var entries = Account("title", 0, "currency", "currencyIconPath", []);
    await FirebaseFirestore.instance.
    collection("transactions").
    where("userId", isEqualTo: _deviceData["androidId"]).
    get().then((document) {
      var data = document.docs.toList();
      for (var element in data){

        //MyTransaction t = MyTransaction(0, element["amount"], element["category"], DateTime.now(), "", element["type"]);
        MyTransaction t = MyTransaction.fromJson(element);

        entries.addMyTransaction(t);
      }

      setState(() {
        currentAccount = entries;

        stat = currentAccount.getStatistics(firstDate, secondDate, option);
        pieData = getPieCharts(stat, 5);

      });
    });
  }
  TextStyle keyboardStyle = const TextStyle(color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
              children: [
                Text(
                  "Баланс: ${currentAccount.balance}\$",

                ),
                IconButton(onPressed: () {},
                    icon: const Icon(Icons.keyboard_arrow_down)), //todo изменение счета

              ]
          ),
          backgroundColor: Colors.green,
        ),
        body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(

                    children: [
                      const Text("Дата начала"),
                      TextButton(onPressed: () async {
                        firstDate = await onTapFunction(context: context);
                        setState(()  {
                          firstDate = firstDate;
                          pieData = getPieCharts(currentAccount.getStatistics(firstDate, secondDate, option), 5);
                        });
                      }, child: Text("${firstDate.year}.${firstDate.month}.${firstDate.day}", style: keyboardStyle)
                      )
                    ],
                  ),

                  Column(
                    children: [
                      const Text("Дата окончания"),
                      TextButton(onPressed: () async {
                        secondDate = await onTapFunction(context: context);
                        setState(()  {
                          secondDate = DateTime(secondDate.year, secondDate.month, secondDate.day, 23, 59, 59);
                          pieData = getPieCharts(currentAccount.getStatistics(firstDate, secondDate, option), 5);
                        });
                      }, child: Text("${secondDate.year}.${secondDate.month}.${secondDate.day}", style: keyboardStyle)
                      )
                    ],
                  )
                ],
              ),

              Row(children: [Expanded(child:ListTile(
                  title: const Text("Расходы"),
                  leading: Radio<bool>(value: false, groupValue: option, onChanged: (bool? value) {
                    setState(() {
                      option = value!;
                      pieData = getPieCharts(currentAccount.getStatistics(firstDate, secondDate, option), 5);
                    });
                  })
              )),
                Expanded(child:ListTile(
                    title: const Text("Доходы"),
                    leading: Radio<bool>(value: true, groupValue: option, onChanged: (bool? value) {
                      setState(() {
                        option = value!;
                        pieData = getPieCharts(currentAccount.getStatistics(firstDate, secondDate, option), 5);
                      });
                    }
                    )))
              ]),
              Row(
                children: [
                  SizedBox(
                      width: 150,
                      height: 150,
                      child:PieChart(PieChartData(

                          centerSpaceRadius: 50,
                          centerSpaceColor: Colors.black54,
                          borderData: FlBorderData(show: false),
                          sections: pieData.values.toList()
                      ))
                  ),
                  SizedBox(
                      width: 220,
                      height: 420,
                      child:ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: pieData.length,
                          itemBuilder: (BuildContext context, int index) {
                            String key = pieData.keys.toList()[index];
                            double value = pieData[key]!.value;
                            Color color = pieData[key]!.color;
                            return ListTile(
                                title: Text("$key = $value"),
                                subtitle: Text("${((value / currentAccount.getStatistics(firstDate, secondDate, option).values.toList().reduce((a, b) => a + b))*100).toStringAsFixed(2)}%"),
                                textColor: color,
                                titleTextStyle: Theme.of(context).textTheme.bodyMedium);

                          }
                      ))
                ],
              )




            ]
        )


    );
  }


}


class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Account currentAccount = Account("title", 0, "currency", "currencyIconPath", []);
  Map<String, dynamic> _deviceData = <String, dynamic>{};



  @override
  void initState() {
    super.initState();
    initPlatformState();

  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};
    deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    setState(() {
      _deviceData = deviceData;

    });

    await getBalance();



  }

  bool goalType = false;
  double goalValue = 0;
  String goalCategory = "Продукты";

  DateTime firstDate = DateTime.now();
  DateTime secondDate = DateTime.now();


  getBalance() async {
    var entries = Account("title", 0, "currency", "currencyIconPath", []);
    await FirebaseFirestore.instance.
    collection("transactions").
    where("userId", isEqualTo: _deviceData["androidId"]).
    get().then((document) {
      var data = document.docs.toList();
      for (var element in data){

        //MyTransaction t = MyTransaction(0, element["amount"], element["category"], DateTime.now(), "", element["type"]);
        MyTransaction t = MyTransaction.fromJson(element);

        entries.addMyTransaction(t);
      }

      setState(() {
        currentAccount = entries;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(onPressed: (){

            }, icon: const Icon(Icons.close, color: Colors.red, size: 35)),
            IconButton(onPressed: (){
//todo индекс в название
              FirebaseFirestore.instance
                  .collection('goal').doc(
                  "${_deviceData["androidId"]}-${currentAccount.title}-$goalType-$goalCategory-${firstDate.year}.${firstDate.month}.${firstDate.day}-${secondDate.year}.${secondDate.month}.${secondDate.day}"

              )
                  .set(
                  {
                    "userId": _deviceData["androidId"],
                    "type": goalType,
                    "category": goalCategory,
                    "amount": goalValue,
                    "firstDate": firstDate,
                    "secondDate": secondDate,
                    "result": false



                  });

              Navigator.popUntil(context, ModalRoute.withName('/'));

            }, icon: const Icon(Icons.check, color:Colors.green, size: 35))
          ],
        ),
      ),
        appBar: AppBar(
          title: Row(
              children: [
                Text(
                  "Баланс: ${currentAccount.balance}\$",

                ),
                IconButton(onPressed: () {},
                    icon: const Icon(Icons.keyboard_arrow_down)), //todo изменение счета

              ]
          ),
          backgroundColor: Colors.green,
        ),
        body: Column(
            children: [


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(

                    children: [
                      const Text("Дата начала"),
                      TextButton(onPressed: () async {
                        firstDate = await onTapFunction(context: context);
                        setState(()  {
                          firstDate = firstDate;

                        });
                      }, child: Text("${firstDate.year}.${firstDate.month}.${firstDate.day}")
                      )
                    ],
                  ),

                  Column(
                    children: [
                      const Text("Дата окончания"),
                      //todo вторая дата не может быть раньше первой
                      TextButton(onPressed: () async {
                        secondDate = await onTapFunction(context: context);
                        setState(()  {
                          secondDate = secondDate;

                        });
                      }, child: Text("${secondDate.year}.${secondDate.month}.${secondDate.day}")
                      )
                    ],
                  )
                ],
              ),


              Row(children: [Expanded(child:ListTile(
                  title: const Text("Накопительная"),
                  leading: Radio<bool>(value: true, groupValue: goalType, onChanged: (bool? value) {
                    setState(() {
                      goalType = value!;
                      goalCategory = "Заработок";

                    });
                  })
              )),
                Expanded(child:ListTile(
                    title: const Text("Ограничивающая"),
                    leading: Radio<bool>(value: false, groupValue: goalType, onChanged: (bool? value) {
                      setState(() {
                        goalType = value!;
                      });
                    }
                    )))
              ]),

              TextFormField(
                decoration: const InputDecoration(labelText: "Сумма цели:"),
                keyboardType: const TextInputType.numberWithOptions(

                  decimal: true,
                  signed: true,
                ),
                onChanged: (value){
                  goalValue = double.parse(value);
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final text = newValue.text;
                    return text.isEmpty
                        ? newValue
                        : double.tryParse(text) == null
                        ? oldValue
                        : newValue;
                  }),
                ],
              ),

              if (!goalType)
                DropdownButton<String>(
                  hint: Text("Выбрана категория: $goalCategory"),
                  items: <String>[
                    "Продукты",
                    "Кафе",
                    "Транспорт",
                    "Здоровье",
                    "Дом",
                    "Одежда"
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      goalCategory = newValue!;
                    });

                  },
                ),
            ]
        ));
  }
}


class RepeatList extends StatefulWidget {
  const RepeatList({super.key});

  @override
  State<RepeatList> createState() => _RepeatListState();
}

class _RepeatListState extends State<RepeatList> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Account currentAccount = Account("title", 0, "currency", "currencyIconPath", []);
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  List repeatList = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();

  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};
    deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    setState(() {
      _deviceData = deviceData;

    });

    await getBalance();
    await getList();
  }

  getBalance() async {
    Account entries =  Account("debugname", 0, "₽", "", []);

    await FirebaseFirestore.instance.
    collection("transactions").
    where("userId", isEqualTo: "${_deviceData["androidId"]}").
    get().then((document) {

      var data = document.docs.toList();
      for (var element in data){

        //MyTransaction t = MyTransaction(0, element["amount"], element["category"], DateTime.now(), "", element["type"]);
        MyTransaction t = MyTransaction.fromJson(element);
        entries.addMyTransaction(t);
      }
      setState(() {
        currentAccount = entries;
      });
    });
  }

  getList() async {
    var entries = [];
    await FirebaseFirestore.instance.
    collection("reapeat").
    where("userId", isEqualTo: "${_deviceData["androidId"]}").
    get().then((document) {
      var data = document.docs.toList();
      for (var element in data){
        entries.add(
            RepeatPeriod.fromJson(element)
        );
      }
      return entries;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
              children: [
                Text(
                  "Баланс: ${currentAccount.balance}\$",
                ),
                IconButton(onPressed: () {},
                    icon: const Icon(Icons.keyboard_arrow_down)), //todo изменение счета

              ]
          ),
          backgroundColor: Colors.green,
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('repeat').where(
              "userId", isEqualTo: "${_deviceData["androidId"]}"
          ).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            getBalance();


            if (!snapshot.hasData) {
              return const Center(
                child: Text("Загрузка..."),
              );
            }

            return Column(
                children:[
                  SizedBox(
                      width: double.maxFinite,
                      height: 600,
                      child: SingleChildScrollView(
                          child: Column(
                            children: snapshot.data!.docs.map((document) {
                              RepeatPeriod r = RepeatPeriod.fromJson(document);
                              return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(width:330, child: ListTile(
                                      title: Text("${r.amount * r.type} ${r.category}"),
                                      subtitle: Text("Последний платеж ${r.lastDate.day}.${r.lastDate.month}.${r.lastDate.year}"),



                                    )),
                                    IconButton(onPressed: (){

                                      setState(() {
                                        document.reference.delete();

                                      });

                                    }, icon: const Icon(Icons.delete, color: Colors.red,))

                                  ]
                              );

                            }).toList(),))),
                ]
            );
          },
        )
    );
  }
}


class GoalsList extends StatefulWidget {
  const GoalsList({super.key});

  @override
  State<GoalsList> createState() => _GoalsListState();
}

class _GoalsListState extends State<GoalsList> {

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Account currentAccount = Account("title", 0, "currency", "currencyIconPath", []);
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  List repeatList = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();

  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};
    deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    setState(() {
      _deviceData = deviceData;

    });

    await getBalance();
    await getList();
  }

  getBalance() async {
    Account entries =  Account("debugname", 0, "₽", "", []);

    await FirebaseFirestore.instance.
    collection("transactions").
    where("userId", isEqualTo: "${_deviceData["androidId"]}").
    get().then((document) {

      var data = document.docs.toList();
      for (var element in data){

        //MyTransaction t = MyTransaction(0, element["amount"], element["category"], DateTime.now(), "", element["type"]);
        MyTransaction t = MyTransaction.fromJson(element);
        entries.addMyTransaction(t);
      }
      setState(() {
        currentAccount = entries;
      });
    });
  }

  getList() async {
    var entries = [];
    await FirebaseFirestore.instance.
    collection("reapeat").
    where("userId", isEqualTo: "${_deviceData["androidId"]}").
    get().then((document) {
      var data = document.docs.toList();
      for (var element in data){
        entries.add(
            RepeatPeriod.fromJson(element)
        );
      }
      return entries;
    });

  }
  String type = "";
  double stat = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: BottomAppBar(
        child: Center(
          child: IconButton(onPressed: (){Navigator.pushNamed(context, '/Goal');}, icon: const Icon(Icons.add))
        ),
      ),
        appBar: AppBar(
          title: Row(
              children: [
                Text(
                  "Баланс: ${currentAccount.balance}\$",
                )
              ]
          ),
          backgroundColor: Colors.green,
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('goal').where(
              "userId", isEqualTo: "${_deviceData["androidId"]}"
          ).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            getBalance();


            if (!snapshot.hasData) {
              return const Center(
                child: Text("Загрузка..."),
              );
            }

            return Column(
                children:[

                  SizedBox(
                      width: double.maxFinite,
                      height: 600,
                      child: SingleChildScrollView(
                          child: Column(
                            children: snapshot.data!.docs.map((document) {

                              Goal g = Goal.fromJson(document);


                              var s = currentAccount.getStatistics(
                                  document["firstDate"].toDate(), document["secondDate"].toDate(), document["type"]);

                              if (s.containsKey(document["category"])) {
                                stat = s[document["category"]];
                              }
                              if (s.isNotEmpty && document["type"]) {


                                stat = s.values.toList().reduce((a, b) => (a + b)).toDouble();

                              }
                              if (document["type"]){
                                type = "Заработать не менее";
                              } else {
                                type = "Потратить не более";
                              }

                              return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [

                                    SizedBox(
                                        width:330,
                                        child: Column(
                                          children: [


                                            ListTile(
                                              title: Text(g.category),
                                              subtitle: Text("$type ${g.amount}${currentAccount.currency}"),
                                            ),
                                            if (g.secondDate.isAfter(DateTime.now()) && !(g.checkRes(stat) && document["type"]))
                                              ListTile(
                                                title: Text("Прогресс: $stat/${g.amount}"),
                                                subtitle: Text("${g.firstDate.day}.${g.firstDate.month}.${g.firstDate.year} - ${g.secondDate.day}.${g.secondDate.month}.${g.secondDate.year}"),
                                              )
                                            else
                                              if (g.checkRes(stat))
                                                ListTile(
                                                  title: const Text("Цель достигнута"),
                                                  subtitle: Text("${g.firstDate.day}.${g.firstDate.month}.${g.firstDate.year} - ${g.secondDate.day}.${g.secondDate.month}.${g.secondDate.year}"),
                                                )
                                              else
                                                ListTile(
                                                  title: const Text("Цель провалена", style: TextStyle(color: Colors.red),),
                                                  subtitle: Text("${g.firstDate.day}.${g.firstDate.month}.${g.firstDate.year} - ${g.secondDate.day}.${g.secondDate.month}.${g.secondDate.year}"),
                                                )

                                          ],
                                        )
                                    ),
                                    IconButton(onPressed: (){

                                      setState(() {
                                        document.reference.delete();

                                      });

                                    }, icon: const Icon(Icons.delete, color: Colors.red,))

                                  ]
                              );

                            }).toList(),))),
                ]
            );
          },
        )
    );
  }
}




Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
  return <String, dynamic>{
    'version.securityPatch': build.version.securityPatch,
    'version.sdkInt': build.version.sdkInt,
    'version.release': build.version.release,
    'version.previewSdkInt': build.version.previewSdkInt,
    'version.incremental': build.version.incremental,
    'version.codename': build.version.codename,
    'version.baseOS': build.version.baseOS,
    'board': build.board,
    'bootloader': build.bootloader,
    'brand': build.brand,
    'device': build.device,
    'display': build.display,
    'fingerprint': build.fingerprint,
    'hardware': build.hardware,
    'host': build.host,
    'id': build.id,
    'manufacturer': build.manufacturer,
    'model': build.model,
    'product': build.product,
    'supported32BitAbis': build.supported32BitAbis,
    'supported64BitAbis': build.supported64BitAbis,
    'supportedAbis': build.supportedAbis,
    'tags': build.tags,
    'type': build.type,
    'isPhysicalDevice': build.isPhysicalDevice,
    'androidId': build.androidId,
    'systemFeatures': build.systemFeatures,
  };
}

String calculateString(String expression) {
  List<String> parts = expression.split(RegExp(r'(\+|-)')); // разбиваем строку на числа и знаки
  List<String> operators = expression.split(RegExp(r'(\d+(\.\d+)?)')); // получаем только знаки
  double result = double.parse(parts[0]); // первое число
  for (int i = 1; i < parts.length; i++) {
    if (operators[i].contains("+")) {
      result += double.parse(parts[i]);
    } else {
      result -= double.parse(parts[i]);
    }
  }
  return result.toStringAsFixed(2);
}


String writeDigit(String input, String digit){
  if (digit == "."){

    String curNum = input.split(RegExp(r"(\+|\-)")).last;

    if (curNum.split(".").length > 1){
      return input;
    }
  }
  if (["+", "-", "."].contains(input[input.length - 1]) && ["+", "-", "."].contains(digit)) {
  }else{
    String curNum = input.split(RegExp(r"(\+|\-)")).last;

    if(input == "0"){
      input = digit;
    }else{
      if (["+", "-", "."].contains(input[input.length - 1]) && digit == "."){
        input += "0$digit";
      }else{
        input += digit;
      }

    }

    int lastIndex = curNum.lastIndexOf(".");
    if (lastIndex != -1){
      if (curNum.substring(lastIndex).length >= 4){
        input = input.substring(0, input.length - 1);
      }
    }
  }
  return input;
}


Future<DateTime> onTapFunction({required BuildContext context}) async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    lastDate: DateTime(2077),
    firstDate: DateTime(2015),
    initialDate: DateTime.now(),
  );
  if (pickedDate == null) DateTime.now();
  return pickedDate!;
}

Map<String, PieChartSectionData> getPieCharts(Map data, int count){

  List<MaterialColor> colors = [
    Colors.red,
    Colors.amber,
    Colors.green,
    Colors.blue,
    Colors.pink,
    Colors.cyan,
  ];

  //var t = PieChartSectionData(value:100, title:"", color: Colors.amber);

  Map<String, PieChartSectionData> pieCharts = {};


  double otherValue = 0;


  data.forEach((key, value) {
    if (pieCharts.length < count) {

      pieCharts[key] = PieChartSectionData(
        value: value,
        title:"",
        color: colors[pieCharts.length], radius: 20,

      );
    }else{
      otherValue += value;
    }
  });

  if (otherValue > 0) {
    pieCharts["Прочее"] = PieChartSectionData(
        value: otherValue, color: Colors.black, title: "", radius: 20
    );
  }

  return pieCharts;
}
