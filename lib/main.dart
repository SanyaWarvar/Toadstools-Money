



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
              )
          )

      ),
      routes: {
        "/": (context) => const MyHomePage(),
        "/NewTransaction" : (context) => const NewTransactionScreen(),
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
        MyTransaction t = MyTransaction(0, element["amount"], element["category"], DateTime.now(), "", element["type"]);
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
      appBar: AppBar(
        title: Row(
            children: [
              Text("Баланс: ${currentAccount.balance}\$ "),
              IconButton(onPressed: () {},
                  icon: const Icon(Icons.keyboard_arrow_down)) //todo изменение счета
            ]
        ),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('transactions').where("userId", isEqualTo: _deviceData["androidId"]).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
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
                            getBalance();


                            return ListTile(
                              title: Text("${document['amount'] * document["type"]}\$ ${document['category']}"),
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
  const NewTransactionScreen({super.key});

  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

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


  int amount = 0;
  String category = "";
  int type = -1;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
              children: [
                const Text(
                  "Баланс: \$",

                ),
                IconButton(onPressed: () {},
                    icon: const Icon(Icons.keyboard_arrow_down)) //todo изменение счета
              ]
          ),
          backgroundColor: Colors.green,
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children:[

              Column(
                children: <Widget>[
                  TextField(
                      decoration: const InputDecoration(labelText: "Сумма платежа"),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ], // Only numbers can be entered
                      onChanged: (value) {

                        amount = int.parse(value);
                      }
                  ),
                  TextField(
                      decoration: const InputDecoration(labelText: "Категория"), //todo кнопки выбора категории
                      onChanged: (value) {

                        category = value;
                      }
                  ),


                  ListTile(
                      title: const Text("Расход"),
                      leading: Radio<int>(value: -1, groupValue: type, onChanged: (int? value) {
                        setState(() {
                          type = value!;
                        });
                      })
                  ),
                  ListTile(
                      title: const Text("Доход"),
                      leading: Radio<int>(value: 1, groupValue: type, onChanged: (int? value) {
                        setState(() {
                          type = value!;
                        });
                      }
                      )),





                ],

              ),
              IconButton(
                  onPressed: () async {

                    FirebaseFirestore.instance
                        .collection('transactions')
                        .add(
                        {
                          'userId':_deviceData["androidId"],
                          'amount': amount,
                          'category': category,
                          'type': type
                        }
                    );
                    Navigator.pop(context);
                  }, icon: const Icon(Icons.check))
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


