import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroro/modules/textfield.dart';

class BookingForm extends StatefulWidget {
  const BookingForm({super.key});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

final TextEditingController controller = TextEditingController();

class _BookingFormState extends State<BookingForm> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Form(
        canPop: true,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            SizedBox(height: 50,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text('Booking Form',textAlign: TextAlign.center,style: GoogleFonts.lateef(fontSize: 35),),
            ),
            TextField(
              controller: controller,
              obscureText: false,
              decoration: InputDecoration(
                hintText: 'Sample text',hintStyle: GoogleFonts.lateef(fontWeight: FontWeight.w100,fontSize: 20)
              ),
            )
          ],
        ),
      ),
    );
  }
}
