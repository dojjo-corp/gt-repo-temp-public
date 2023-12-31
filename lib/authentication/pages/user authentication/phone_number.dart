// ignore_for_file: use_build_context_synchronously

// import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:gt_daily/authentication/pages/user%20account/add_profile_picture.dart';

import '../../components/buttons/buttons.dart';
import '../../components/buttons/custom_back_button.dart';

class EnterPhonePage extends StatefulWidget {
  const EnterPhonePage({super.key});

  @override
  State<EnterPhonePage> createState() => _EnterPhonePageState();
}

class _EnterPhonePageState extends State<EnterPhonePage> {
  bool _isLoading = false;
  final _key = GlobalKey<FormState>();
  final contactController = TextEditingController();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    void goToProfilePicture() async {
      setState(() {
        _isLoading = true;
      });
      try {
        if (_key.currentState!.validate()) {
          _key.currentState!.save();
          // update firestore records
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({'contact': contactController.text.split(' ').join()});

          // todo: initiate phone number verification process

          // navigate to home page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProfileImagePage(
                isFromRegistration: true,
              ),
            ),
          );
        }
      } catch (e) {
        showSnackBar(context, 'Error Updating Contact Info: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 100, bottom: 10, right: 20, left: 20),
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Enter Your Phone Number',
                      style: GoogleFonts.poppins(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 60),
                    Form(
                      key: _key,
                      child: TextFormField(
                        controller: contactController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(Icons.phone_rounded,
                              color: Theme.of(context).primaryColor),
                          hintText: '0241 234 567',
                        ),
                        style: GoogleFonts.poppins(
                            color: Theme.of(context).primaryColor),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter phone number';
                          } else if (value.split(' ').join().length != 10) {
                            return 'Number must be 10 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    MyButton(
                      onPressed: goToProfilePicture,
                      btnText: 'Done',
                      isPrimary: false,
                    )
                  ],
                ),
              ),
            ),
          ),
          const MyBackButton(),
        ],
      ),
      floatingActionButton: _isLoading ? const LinearProgressIndicator() : null,
    );
  }
}
