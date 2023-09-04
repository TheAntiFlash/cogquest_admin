import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class LogInController extends GetxController {
  String email = '';
  String password = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxBool _isLoading = RxBool(false);
  RxBool get isLoading => _isLoading;


  //////login
  Future<UserCredential?> logInMethod({email, password}) async {
    debugPrint('authSignup() called');
    UserCredential? userCredential;
    try {

      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      ).then((value) async {
        final documentSnapshot = await _firestore.collection("admin").doc(value.user?.uid).get();

        if (!documentSnapshot.exists) {
          await FirebaseAuth.instance.signOut();
          throw Exception("User is Not Admin!");
        }
        debugPrint('auth.signInWithEmailAndPassword() called');
        //currentUser = value.user;
        debugPrint('currentUser: ${FirebaseAuth.instance.currentUser}');
        return value;
      });
    } on FirebaseAuthException catch (e) {
      debugPrint('LoginCalled() called Error "$e"');
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
        Get.snackbar(
          'Error',
          'No user found for that email.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided for that user.');
        Get.snackbar(
          'Error',
          'Wrong password provided for that user.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      else if (e.code == 'user-disabled') {
        debugPrint('User disabled.');
        Get.snackbar(
          'Error',
          'User disabled.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      else if(e.code == 'too-many-requests'){
        debugPrint('Too many requests.');
        Get.snackbar(
          'Error',
          'Too many requests.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      else {
        debugPrint('Error: $e');
        Get.snackbar(
          'Error',
          'Error: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

    } catch (e) {
      debugPrint('Error: $e');
      Get.snackbar(
        'Error',
        'Error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      userCredential = null;
    }
    return userCredential;
  }

  Future<bool> logIn({password, email}) async {
    _isLoading.value = true;
    try {
      debugPrint('LogIn() called');
      UserCredential? userCredential =
          await logInMethod(email: email, password: password);
      if (userCredential == null) {
        debugPrint('userCredential is null');
        _isLoading.value = false;
        return false;
      }
    } catch (e) {
      debugPrint('Error: $e');
      Get.snackbar(
        'Error',
        'Error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _isLoading.value = false;
      return false;
    }
    _isLoading.value = false;
    return true;
  }
}
