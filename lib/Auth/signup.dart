import 'package:flutter/material.dart';
import 'package:maroro/Auth/auth_service.dart';
import 'package:maroro/modules/mybutton.dart';
import 'package:maroro/modules/textfield.dart';

class SignUp extends StatefulWidget {
  
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController emailcontroller = TextEditingController();

  final TextEditingController passwordcontroller = TextEditingController();

  final TextEditingController confirmPasswordcontroller = TextEditingController();

  final TextEditingController namecontroller = TextEditingController();

  final TextEditingController surnamecontroller = TextEditingController();

  final TextEditingController usernamecontroller = TextEditingController();

  Future<void> register(BuildContext context) async {
    final authService = AuthService();
    //confirm password
    if(passwordcontroller.text == confirmPasswordcontroller.text){
      try{
        await authService.signUpwithEmailPassword(emailcontroller.text, passwordcontroller.text);
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/first');
      }
      catch(e){
        
        // ignore: use_build_context_synchronously
        showDialog(context: context, builder: (context) => AlertDialog(title: Text(e.toString()),));

        
      }
    }else{
       showDialog(context: context, builder: (context) => const AlertDialog(title: Text('Passwords do not match!'),));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person,size: 200,),
              
              Padding(
                padding: const EdgeInsets.only(left:20 ,right:20,bottom: 10 ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: namecontroller,
                      obscureText: false,
                      decoration: const InputDecoration(
                        hintText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // Add some spacing between the fields
                  Expanded(
                    child: TextField(
                      controller: surnamecontroller,
                      obscureText: false,
                      decoration: const InputDecoration(
                        hintText: 'Surname',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                    ),
                  ),
                ],
                            ),
              ),
              
             
              MyTextField(controller: usernamecontroller, obscureText: false, hintText: 'Username'),
              MyTextField(controller: emailcontroller, obscureText: false, hintText: 'Email'),
              MyTextField(controller: passwordcontroller, obscureText: true, hintText: 'Password'),
              MyTextField(controller: confirmPasswordcontroller, obscureText: true, hintText: 'Confirm Password'),
              const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //Text('Forgot Password?',style:TextStyle(color: Colors.blueGrey))
                  ],
                ),
               
              ),
               MyButton(todo: 'Sign Up',onTap:() => register(context)),
               Row(
                mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Text('Already Have an Account?'),
                   const SizedBox(width: 10,),
                   GestureDetector(
                    onTap: (){Navigator.pop(context);Navigator.pushNamed(context, '/log_in');},
                    child: const Text('Login',style: TextStyle(color: Colors.blueGrey),)),
                 ],
               )
          
               
            ],
          ),
        ),
      )
      );
  }
}