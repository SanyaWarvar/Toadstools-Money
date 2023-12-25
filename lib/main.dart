




import 'dart:io';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';

import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:test/Transaction.dart";
import 'package:test/Account.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


import 'package:device_info_plus/device_info_plus.dart';






Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp(title: "",));



}



class MyApp extends StatelessWidget {
  const MyApp({super.key, required title});





  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
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

  Account currentAccount = Account("title", 0, "currency", "currencyIconPath", []);



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
  }



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
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
            children: [
              Text("Баланс: ${currentAccount.balance}\$ "),
              IconButton(onPressed: () {},
                  icon: const Icon(Icons.keyboard_arrow_down)), //todo изменение счета
              IconButton(onPressed: (){Navigator.pushNamed(context, '/Statistic');}, icon: const Icon(Icons.pie_chart))
            ]
        ),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('transactions').where("userId", isEqualTo: _deviceData["androidId"]).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

          if (!snapshot.hasData) {
            return Center(
                child: IconButton(onPressed: (){
                  Navigator.pushNamed(context, '/NewTransaction');
                }, icon: Icon(Icons.add)),
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
                            getBalance();
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(width:330, child: ListTile(
                                    title: Text("${curTransaction.amount * curTransaction.type} ${curTransaction.category}"),
                                    subtitle: Text("${curTransaction.date.day}.${curTransaction.date.month}.${curTransaction.date.year}"),
                                    titleTextStyle: theme.textTheme.bodyMedium,
                                    subtitleTextStyle: theme.textTheme.bodySmall,

                                  )),

                                  IconButton(onPressed: (){
                                    document.reference.delete();
                                    setState(() {

                                    });
                                  }, icon: const Icon(Icons.delete, color: Colors.red,))
                                ]
                            );

                          }).toList(),))),
                IconButton(onPressed: (){
                  Navigator.pushNamed(context, '/NewTransaction');
                }, icon: const Icon(Icons.add))
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
  Account currentAccount = Account("title", 0, "currency", "currencyIconPath", []);
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    initPlatformState();
    getBalance();
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};
    deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    setState(() {
      _deviceData = deviceData;
    });
    getBalance();
  }

  final amountController = TextEditingController();
  final categoryController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    amountController.dispose();
    categoryController.dispose();
    super.dispose();
  }





  getBalance() async {
    var entries = Account("title", 0, "currency", "currencyIconPath", []);
    await FirebaseFirestore.instance.
    collection("transactions").
    where("userId", isEqualTo: _deviceData["androidId"]).
    get().then((document) {
      var data = document.docs.toList();
      for (var element in data){
        MyTransaction t = MyTransaction(0, element["amount"], element["category"], DateTime.now(), "", element["type"]);
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
                  icon: const Icon(Icons.keyboard_arrow_down)) //todo изменение счета
            ]
        ),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Row(children: [Expanded(child:ListTile(
              title: Text("Расход"),
              leading: Radio<int>(value: -1, groupValue: type, onChanged: (int? value) {
                setState(() {
                  type = value!;
                  category = "Продукты";
                });
              })
          )),
            Expanded(child:ListTile(
                title: Text("Доход"),
                leading: Radio<int>(value: 1, groupValue: type, onChanged: (int? value) {
                  setState(() {
                    type = value!;
                    category = "Зарплата";
                  });
                }
                )))
          ]),
          Padding(padding: EdgeInsets.all(20),
            child:SizedBox(
              width: 300,
              height: 250,
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
                              title: Text("Продукты"),
                              leading: Radio<String>(value: "Продукты", groupValue: category, onChanged: (String? value) {
                                setState(() {
                                  category = value!;
                                });
                              })
                          ),

                          ListTile(
                              title: Text("Кафе"),
                              leading: Radio<String>(value: "Кафе", groupValue: category, onChanged: (String? value) {
                                setState(() {
                                  category = value!;
                                });
                              })
                          ),

                          ListTile(
                              title: Text("Транспорт"),
                              leading: Radio<String>(value: "Транспорт", groupValue: category, onChanged: (String? value) {
                                setState(() {
                                  category = value!;
                                });
                              })
                          ),

                          ListTile(
                              title: Text("Здоровье"),
                              leading: Radio<String>(value: "Здоровье", groupValue: category, onChanged: (String? value) {
                                setState(() {
                                  category = value!;
                                });
                              })
                          ),

                          ListTile(
                              title: Text("Дом"),
                              leading: Radio<String>(value: "Дом", groupValue: category, onChanged: (String? value) {
                                setState(() {
                                  category = value!;
                                });
                              })
                          ),

                          ListTile(
                              title: Text("Одежда"),
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
                              title: Text("Зарплата"),
                              leading: Radio<String>(value: "Зарплата", groupValue: category, onChanged: (String? value) {
                                setState(() {
                                  category = value!;
                                });
                              })
                          ),

                          ListTile(
                              title: Text("Подарки"),
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

                              }, child: Text("${date.year}.${date.month}.${date.day}", style: keyboardStyle)
                            ),
                            const SizedBox(height: 13),
                            TextButton(onPressed: (){}, child: Text("Наличные", style: keyboardStyle)),
                            const SizedBox(height: 13),
                            TextButton(onPressed: (){}, child: Text("Добавить примечание", style: keyboardStyle)),

                          ],
                        ))

                  ])

          )),

          Expanded(
              child: Align(alignment: Alignment.bottomCenter,
                  child:SizedBox(
                      width: 100,
                      child: Row(
                          children: [
                            IconButton(onPressed: () async {
                              await getBalance();
                              print(currentAccount.history);
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
                                "type": type
                              });


                              Navigator.popUntil(context, ModalRoute.withName('/'));
                            }, icon: const Icon(Icons.check)),
                            IconButton(onPressed: (){Navigator.popUntil(context, ModalRoute.withName('/'));}, icon: const Icon(Icons.close))
                          ]
                      )
                  ))),

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

  var pieData = Map<String, PieChartSectionData>();
  var stat;

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
        print(t);
        entries.addMyTransaction(t);
      }

      setState(() {
        currentAccount = entries;

        stat = currentAccount.getStatistics(firstDate, secondDate, option);
        print(stat);
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
              title: Text("Расходы"),
              leading: Radio<bool>(value: false, groupValue: option, onChanged: (bool? value) {
                setState(() {
                  option = value!;
                  pieData = getPieCharts(currentAccount.getStatistics(firstDate, secondDate, option), 5);
                });
              })
          )),
            Expanded(child:ListTile(
                title: Text("Доходы"),
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
    lastDate: DateTime.now(),
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
