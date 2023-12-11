import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:sportistan_admin/home/home.dart';
import 'package:sportistan_admin/widgets/errors.dart';
import 'package:sportistan_admin/widgets/page_router.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  ValueNotifier<bool> serverConnect = ValueNotifier<bool>(false);
  ValueNotifier<bool> passwordView = ValueNotifier<bool>(true);

  @override
  void dispose() {
    emailController.dispose();
    _controller.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  final db = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final emailController2 = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> _emailKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _emailKey2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xfffff5e8),
        resizeToAvoidBottomInset: false,
        body: SlidingUpPanel(
          minHeight: MediaQuery.of(context).size.height / 1.3,
          maxHeight: MediaQuery.of(context).size.height / 1.3,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          panelBuilder: (sc) => panel(sc),
          body: SafeArea(
              child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Admin Console,',
                  style: TextStyle(
                      color: Colors.black87,
                      fontFamily: "DMSans",
                      fontSize: MediaQuery.of(context).size.height / 25),
                ),
              ),
              Text(
                'Your Management Tools',
                style: TextStyle(
                    color: Colors.black87,
                    fontFamily: "DMSans",
                    fontSize: MediaQuery.of(context).size.height / 40),
              ),
            ],
          )),
        ));
  }

  Future<void> login(String email, String password) async {
    serverConnect.value = true;
    try {
      await db
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) => {
                TextInput.finishAutofillContext(),
                PageRouter.pushRemoveUntil(context, const Home())
              });
    } on FirebaseAuthException catch (e) {
      passwordController.clear();
      serverConnect.value = false;
      if (mounted) {
        Errors.flushBarInform(e.code, context, "Error");
      }
    }
  }

  panel(ScrollController sc) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(30))),
          ),
          Form(
            key: _emailKey,
            child: DelayedDisplay(
              child: Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 15,
                    right: MediaQuery.of(context).size.width / 15),
                child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter your Email";
                    } else if (!EmailValidator.validate(
                        emailController.value.text)) {
                      return "Email is Invalid";
                    } else {
                      return null;
                    }
                  },
                  autofillHints: const [AutofillHints.email],
                  showCursor: true,
                  decoration: InputDecoration(
                      errorStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      hintText: "Email",
                      suffixIcon: InkWell(
                          onTap: () {
                            emailController.clear();
                          },
                          child: const Icon(Icons.close)),
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: Colors.black54, size: 20),
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      )),
                ),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: passwordView,
            builder: (context, value, child) {
              return Form(
                key: _passwordKey,
                child: DelayedDisplay(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 10,
                      right: MediaQuery.of(context).size.width / 10,
                      top: MediaQuery.of(context).size.width / 20,
                      bottom: MediaQuery.of(context).size.width / 20,
                    ),
                    child: TextFormField(
                      obscureText: value,
                      controller: passwordController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter your password";
                        } else {
                          return null;
                        }
                      },
                      autofillHints: const [AutofillHints.password],
                      showCursor: true,
                      decoration: InputDecoration(
                          suffixIcon: GestureDetector(
                              onTap: () {
                                passwordView.value = !passwordView.value;
                              },
                              child: value
                                  ? const Icon(
                                      Icons.visibility_off,
                                      color: Colors.black,
                                    )
                                  : const Icon(
                                      Icons.remove_red_eye,
                                      color: Colors.red,
                                    )),
                          errorStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          hintText: "Password",
                          prefixIcon: const Icon(Icons.lock,
                              color: Colors.black54, size: 20),
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          )),
                    ),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoButton(
                borderRadius: BorderRadius.circular(10),
                onPressed: () {
                  if (_emailKey.currentState!.validate() &
                      _passwordKey.currentState!.validate()) {
                    login(emailController.value.text.trim(),
                        passwordController.value.text.trim());
                  }
                },
                color: Colors.black,
                child: const Text(
                  'Login Securely',
                  style: TextStyle(fontFamily: "DMSans"),
                )),
          ),
          TextButton(
              onPressed: () {
                emailController2.text = 'Support@Sportistan.co.in';
                showModalBottomSheet(
                  context: context,
                  builder: (ctx) {
                    return Scaffold(
                      body: SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text("Reset Password",
                                style: TextStyle(fontSize: 22)),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width / 15,
                                  right:
                                      MediaQuery.of(context).size.width / 15),
                              child: Form(
                                key: _emailKey2,
                                child: TextFormField(
                                  enabled: false,
                                  controller: emailController2,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Enter your Email";
                                    } else if (!EmailValidator.validate(
                                        emailController2.value.text)) {
                                      return "Email is Invalid";
                                    } else {
                                      return null;
                                    }
                                  },
                                  showCursor: true,
                                  decoration: InputDecoration(
                                      errorStyle:
                                          const TextStyle(color: Colors.black),
                                      filled: true,
                                      hintText: "Email",
                                      prefixIcon: const Icon(
                                          Icons.email_outlined,
                                          color: Colors.black54,
                                          size: 20),
                                      fillColor: Colors.grey.shade100,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      )),
                                ),
                              ),
                            ),
                            CupertinoButton(
                                color: Colors.red,
                                onPressed: () {
                                  FirebaseAuth.instance
                                      .sendPasswordResetEmail(
                                          email: 'Support@Sportistan.co.in')
                                      .then((value) => {
                                            Navigator.pop(ctx),
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text("Link Sent"),
                                              backgroundColor: Colors.green,
                                            ))
                                          });
                                },
                                child: const Text("Send Link")),
                            const Icon(
                              Icons.warning,
                              color: Colors.red,
                              size: 50,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: const Text(
                "Reset Password",
                style: TextStyle(color: Colors.red),
              )),
          ValueListenableBuilder(
            valueListenable: serverConnect,
            builder: (context, value, child) {
              return value
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(),
                    );
            },
          ),
          Lottie.asset(
            'assets/loading.json',
            controller: _controller,
            onLoaded: (composition) {
              _controller
                ..duration = composition.duration
                ..repeat();
            },
          ),
        ],
      ),
    );
  }
}
