import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:keninacafecust_web/Auth/login.dart';

void main() {
  runApp(const MyApp());
}

void enterFullScreen() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const RegisterPage(),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  // final String title;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final dateInput = TextEditingController();
  String? gender;

  @override
  void initState() {
    dateInput.text = ""; //set the initial value of text field
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize( //wrap with PreferredSize
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          elevation: 0,
          toolbarHeight: 100,
          title: const Text('Sign Up', style: TextStyle(
            fontWeight: FontWeight.bold,
          ),),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          centerTitle: true,
          leading:
            IconButton( onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginPage()));
            },icon: const Icon(Icons.arrow_back_ios,size: 20,color: Colors.black,)),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(height: 20,),
                        Text("Create an Account to get more benefits !",style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                        ),),
                        const SizedBox(height: 30,)
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60,
                      ),
                      // child: Expanded(
                      child: Column(
                        children: [
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                              child: Row(
                                  children: [
                                    Text('Full Name', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                    Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                  ]
                              )
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child:
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Please enter your full name',
                              ),
                            ),
                          ),

                          const SizedBox(height: 13,),

                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                              child: Row(
                                  children: [
                                    Text('Email', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                    Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                  ]
                              )
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child:
                            TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Please enter your email',
                              ),
                            ),
                          ),

                          const SizedBox(height: 13,),

                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                              child: Row(
                                  children: [
                                    Text('Password', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                    Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                  ]
                              )
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child:
                            TextField(
                              controller: passwordController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Please enter your password',
                              ),
                            ),
                          ),

                          const SizedBox(height: 13,),

                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                              child: Row(
                                  children: [
                                    Text('Confirm Password', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                    Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                  ]
                              )
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child:
                            TextField(
                              controller: confirmPasswordController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Please enter the password again',
                              ),
                            ),
                          ),

                          const SizedBox(height: 13,),

                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child: Row(
                              children: [
                               Text("What is your gender?", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                               Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                              ],
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                          child: Column(
                            children: [
                              RadioListTile(
                                title: const Text("Male"),
                                value: "male",
                                groupValue: gender,
                                onChanged: (value){
                                  setState(() {
                                    gender = value.toString();
                                  });
                                },
                              ),
                              RadioListTile(
                                title: const Text("Female"),
                                value: "female",
                                groupValue: gender,
                                onChanged: (value){
                                  setState(() {
                                    gender = value.toString();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child:TextField(
                              controller: dateInput, //editing controller of this TextField
                              decoration: const InputDecoration(
                                  icon: Icon(Icons.calendar_today), //icon of text field
                                  labelText: "Date Of Birth" //label text of field
                              ),
                              readOnly: true,  //set it true, so that user will not able to edit text
                              onTap: () async {
                                var pickedDate = await showDatePicker(
                                    context: context, initialDate: DateTime.now(),
                                    firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                                    lastDate: DateTime(2101)
                                );

                                if(pickedDate != null ){
                                  // print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
                                  String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                  // print(formattedDate); //formatted date output using intl package =>  2021-03-16
                                  //you can implement different kind of Date Format here according to your requirement

                                  setState(() {
                                    dateInput.text = formattedDate; //set output date to TextField value.
                                  });
                                }else{
                                  // print("Date is not selected");
                                }
                              },
                            )
                        ),
                        ],

                      ),
                    ),

                    // const SizedBox(height: 13,),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 300, vertical: 6),
                      child: Container(
                        padding: const EdgeInsets.only(top: 3,left: 3),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            border: const Border(
                                bottom: BorderSide(color: Colors.black),
                                top: BorderSide(color: Colors.black),
                                right: BorderSide(color: Colors.black),
                                left: BorderSide(color: Colors.black)
                            )
                        ),
                        child: MaterialButton(
                          minWidth: double.infinity,
                          height:60,
                          onPressed: (){},
                          color: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)
                          ),
                          child: const Text("Sign Up",style: TextStyle(
                            fontWeight: FontWeight.w600,fontSize: 16,

                          ),),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 300, vertical: 6),
                      child: Text.rich(
                        TextSpan(
                            children: [
                              const TextSpan(
                                  text: 'Already have an account?  ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.transparent,
                                    shadows: [Shadow(color: Colors.black, offset: Offset(0, -4))],
                                  )
                              ),

                              TextSpan(
                                text: 'Login',
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.transparent,
                                  shadows: [Shadow(color: Colors.blue, offset: Offset(0, -4))],
                                  decorationThickness: 4,
                                  decorationColor: Colors.blue,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                    );
                                  },
                              ),
                            ]
                        ),
                      ),
                    ),
                  ],
            ),
          ),
        ),
      ),
    );
  }
}

