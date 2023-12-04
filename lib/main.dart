

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:test/Transaction.dart";
import 'package:test/Account.dart';
import 'package:test/Database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';





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
        "/": (context) => MyHomePage(),
        "/NewTransaction" : (context) => NewTransactionScreen(),
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Баланс: \$"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('transactions').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            
              children:[
                Column(
                  children: snapshot.data!.docs.map((document) {
                    return ListTile(
                      title: Text("${document['amount'] * (-1)}\$ ${document['category']}"),
                    );
                  }).toList(),),
                IconButton(onPressed: (){
                  Navigator.pushNamed(context, '/NewTransaction');
                }, icon: Icon(Icons.add))
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

  //Account data = await start();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
              children: [
                Text(
                    "Баланс: \$",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 25
                    )
                ),
                IconButton(onPressed: () {},
                    icon: const Icon(Icons.keyboard_arrow_down),
                    color: Colors.black) //todo изменение счета
              ]
          ),
          backgroundColor: Colors.green,
        ),
        body: Form(


          child: Column(
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

                  ],

                ),
                IconButton(
                    onPressed: () async {

                      FirebaseFirestore.instance
                          .collection('transactions')
                          .add({'amount': amount, "category": category});
                      Navigator.pop(context);
                    }, icon: const Icon(Icons.check))
              ]
          ),
        )

    );
  }
}