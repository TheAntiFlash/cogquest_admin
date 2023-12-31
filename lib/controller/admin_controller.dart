import 'dart:core';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cr_file_saver/file_saver.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxInt _totalSubmissionsCount = RxInt(0);
  Rx<int> get totalSubmissionCount => _totalSubmissionsCount;
  RxBool _isTotalSubmissionLoaded = RxBool(false);
  Rx<bool> get isTotalSubmissionLoaded => _isTotalSubmissionLoaded;


  RxInt _averageScore = RxInt(0);
  Rx<int> get averageScore => _averageScore;
  RxBool _isAverageScoreLoaded = RxBool(false);
  Rx<bool> get isAverageScoreLoaded => _isAverageScoreLoaded;

  TextEditingController userSearchBar = TextEditingController();
  RxBool _isUserSearchFound = RxBool(false);

  RxBool get isUserSearchFound => _isUserSearchFound;
  RxBool _userSearchIsLoading = RxBool(false);

  RxBool get userSearchIsLoading => _userSearchIsLoading;
  RxString _searchedUserName = RxString('notFound');

  RxBool _userSearchStarted = RxBool(false);
  Rx<bool> get userSearchStarted => _userSearchStarted;

  Rx<String> get searchedUserName => _searchedUserName;
  RxInt _searchedUserTotalScore = RxInt(-1);

  Rx<int> get searchedUserTotalScore => _searchedUserTotalScore;
  RxString _searchedUserEmail = RxString('notFound');

  Rx<String> get searchedUserEmail => _searchedUserEmail;

  QuerySnapshot? _userDoc;

  final Map<String, String> headers = {
  /* User Info Headers */
    "Name" : "user_info.name" ,
    "Email" : "user_info.email",
    "Total Score" : "results.totalscore",
    "CFQ Score" : "results.cfqScore",

  /* Social Demographic Headers */
    "Age" : "socio_demographic.age",
    "Education" : "socio_demographic.education",
    "Gender" : "socio_demographic.gender",
    "Profession" : "socio_demographic.profession",
    "Residence" : "socio_demographic.residence" ,

  /* Medical History Headers */
    "Diet" : "medical_history.diet",
    "Medical Condition" : "medical_history.medicalCondition",
    "Physical Activity" : "medical_history.physicalActivity",
    "Does Smoke" : "medical_history.smoke",

  /* Covid Experience Headers */
    "Has Had Covid 19" : "covid_experience.covid",
    "Time Since Diagnosis" : "covid_experience.duration",
    //"Covid Experience in First 4 Weeks" : "covid_experience.first4weeks",
    "Took PCR Test" : "covid_experience.pcrTest",
    "PCR Test Result" : "covid_experience.results",
    "Did Not Take PCR - How Person Knew They Had Covid-19" : "covid_experience.pcrTestDetails",
    "Covid Experience" : "covid_experience.coivdExp",
    "is Vaccinated" : "covid_experience.vaccinated",
    "vaccination Period" : "covid_experience.vaccinationPeriod",
    //"Covid Experience After First 4 Weeks" : "covid_experience.week4Experience",

  /* Initial Illness Symptom */
   //"Covid-19 Symptom: Abdominal Pain" : "symptoms_initial_illness.abdominalPain",
  // "Covid-19 Symptom: Blurred Vision" : "symptoms_initial_illness.blurredVision",
   "Covid-19 Symptom: Blisters" : "symptoms_initial_illness.blisters",
   "Covid-19 Symptom: Breathing Issues" : "symptoms_initial_illness.breathingIssues",
   "Covid-19 Symptom: Chest Pain" : "symptoms_initial_illness.chestPainTightness",
   "Covid-19 Symptom: Forgetfulness" : "symptoms_initial_illness.forgetfulness",
   "Covid-19 Symptom: Confusion" : "symptoms_initial_illness.confusion",
   "Covid-19 Symptom: Cough" : "symptoms_initial_illness.cough",
   "Covid-19 Symptom: Delayed Thinking" : "symptoms_initial_illness.delayedthinking",
   "Covid-19 Symptom: Depression/Anxiety" : "symptoms_initial_illness.depressionAnxiety",
   "Covid-19 Symptom: Diarrhea" : "symptoms_initial_illness.diarrhea",
   "Covid-19 Symptom: Difficulty Sleeping" : "symptoms_initial_illness.difficultSleepy",
   "Covid-19 Symptom: Difficulty Speaking" : "symptoms_initial_illness.difficultySpeaking",
   "Covid-19 Symptom: Fatigue" : "symptoms_initial_illness.fatigue",
   "Covid-19 Symptom: Fever" : "symptoms_initial_illness.fever",
   //"Covid-19 Symptom: Hallucinations" : "symptoms_initial_illness.hallucinations",
   "Covid-19 Symptom: HeadAche" : "symptoms_initial_illness.headAches",
   //"Covid-19 Symptom: Hot Flashes" : "symptoms_initial_illness.hotFlashes",
   "Covid-19 Symptom: Itchy Swollen Skin" : "symptoms_initial_illness.itchySwollenSkin",
   "Covid-19 Symptom: Itchy/Red/Dry Eyes" : "symptoms_initial_illness.itchyRedDryEyes",
   "Covid-19 Symptom: Loss of Appetite" : "symptoms_initial_illness.lossOfAppetite",
   "Covid-19 Symptom: Loss of Smell and/or Taste" : "symptoms_initial_illness.lossOfSmelltaste",
   "Covid-19 Symptom: Muscle/Body Pain" : "symptoms_initial_illness.muscleBodyPain",
   "Covid-19 Symptom: Nausea/ Vomiting" : "symptoms_initial_illness.nauseaVomiting",
   "Covid-19 Symptom: Stomachache" : "symptoms_initial_illness.stomachAche",
   "Covid-19 Symptom: Palpitations" : "symptoms_initial_illness.palpitations",
   "Covid-19 Symptom: Poor Concentration" : "symptoms_initial_illness.poorconcentration",
   "Covid-19 Symptom: Sore Throat" : "symptoms_initial_illness.soreThroat",
   "Covid-19 Symptom: Rash" : "symptoms_initial_illness.rash",
   "Covid-19 Symptom: Runny Stuffy Nose" : "symptoms_initial_illness.runnyStuffyNose",
   "Covid-19 Symptom: Ulcers/Sores" : "symptoms_initial_illness.ucersSores",

  /* Ongoing Illness Symptom */
    /*
   "After 4 Weeks Symptom: Abdominal Pain" : "symptoms_ongoing_illness.abdominalPain",
   "After 4 Weeks Symptom: Blurred Vision" : "symptoms_ongoing_illness.blurredVision",
   "After 4 Weeks Symptom: Body Pain" : "symptoms_ongoing_illness.bodyPain",
   "After 4 Weeks Symptom: Breathing Issues" : "symptoms_ongoing_illness.breathingIssues",
   "After 4 Weeks Symptom: Chest Pain" : "symptoms_ongoing_illness.chestPain",
   "After 4 Weeks Symptom: Confusion" : "symptoms_ongoing_illness.confusion",
   "After 4 Weeks Symptom: Cough" : "symptoms_ongoing_illness.cough",
   "After 4 Weeks Symptom: Delayed Thinking" : "symptoms_ongoing_illness.delayedThinking",
   "After 4 Weeks Symptom: Depression Anxiety" : "symptoms_ongoing_illness.depressionAnxiety",
   "After 4 Weeks Symptom: Difficulty Sleeping" : "symptoms_ongoing_illness.difficultSleeping",
   "After 4 Weeks Symptom: Difficulty Speaking" : "symptoms_ongoing_illness.difficultSpeaking",
   "After 4 Weeks Symptom: Fatigue" : "symptoms_ongoing_illness.fatigue",
   "After 4 Weeks Symptom: Forgetfulness" : "symptoms_ongoing_illness.forgetfulness",
   "After 4 Weeks Symptom: Hallucinations" : "symptoms_ongoing_illness.hallucinations",
   "After 4 Weeks Symptom: Headache" : "symptoms_ongoing_illness.headAche",
   "After 4 Weeks Symptom: Irregular Pulse" : "symptoms_ongoing_illness.irregularPulse",
   "After 4 Weeks Symptom: Itch/Red/Dry Eyes" : "symptoms_ongoing_illness.itchyRedDryEyes",
   "After 4 Weeks Symptom: Loss Of Appetite" : "symptoms_ongoing_illness.lossOfAppetite",
   "After 4 Weeks Symptom: Loss Of Smell and/or Taste" : "symptoms_ongoing_illness.lossOfSmelltaste",
   "After 4 Weeks Symptom: Nausea" : "symptoms_ongoing_illness.nausea",
   "After 4 Weeks Symptom: Numbness" : "symptoms_ongoing_illness.numbness",
   "After 4 Weeks Symptom: Poor Concentration" : "symptoms_ongoing_illness.poorConcentration",
*/
  /* Survey Results */
  "CFQ - Q#1: Do you read something and find you haven't been thinking about it and must read it again?" : "survey_results.0.rating",
  "CFQ - Q#2: Do you find you forget why you went from one part of the house to the other?" : "survey_results.1.rating",
  "CFQ - Q#3: Do you find you confuse right and left when giving directions?" : "survey_results.2.rating",
  "CFQ - Q#4: Do you bump into people?" : "survey_results.3.rating",
  "CFQ - Q#5: Do you find you forget whether you've turned off a light or a fire or locked the door?" : "survey_results.4.rating",
  "CFQ - Q#6: Do you fail to listen to people's names when you are meeting them?" : "survey_results.5.rating",
  "CFQ - Q#7: Do you say something and realize afterwards that it might be taken as insulting?" : "survey_results.6.rating",
  "CFQ - Q#8: Do you fail to hear people speaking to you when you are doing something else?" : "survey_results.7.rating",
  "CFQ - Q#9: Do you lose your temper and regret it?" : "survey_results.8.rating",
  "CFQ - Q#10: Do you lose your temper and regret it?" : "survey_results.9.rating",
  "CFQ - Q#11: Do you leave important letters unanswered for days?" : "survey_results.10.rating",
  "CFQ - Q#12: Do you find you forget which way to turn on a road you know well but rarely use?" : "survey_results.11.rating",
  "CFQ - Q#13: Do you fail to see what you want in a supermarket (although it's there)?" : "survey_results.12.rating",
  "CFQ - Q#14: Do you find yourself suddenly wondering whether you've used a word correctly?" : "survey_results.13.rating",
  "CFQ - Q#15: Do you have trouble making up your mind?" : "survey_results.14.rating",
  "CFQ - Q#16: Do you find you forget appointments?" : "survey_results.15.rating",
  "CFQ - Q#17: Do you forget where you put something like a newspaper or a book?" : "survey_results.16.rating",
  "CFQ - Q#18: Do you find you accidentally throw away the thing you want and keep what you meant to throw away -- as in the example of throwing away the matchbox and putting the used match in your pocket?" : "survey_results.17.rating",
  "CFQ - Q#19: Do you daydream when you ought to be listening to something?" : "survey_results.18.rating",
  "CFQ - Q#20: Do you find you forget people's names?" : "survey_results.19.rating",
  "CFQ - Q#21: Do you start doing one thing at home and get distracted into doing something else (unintentionally)?" : "survey_results.20.rating",
  "CFQ - Q#22: Do you find you can't quite remember something although it's \"on the tip of your tongue\"?" : "survey_results.21.rating",
  "CFQ - Q#23: Do you find you forget what you came to the shops to buy?" : "survey_results.22.rating",
  "CFQ - Q#24: Do you drop things?" : "survey_results.23.rating",
  "CFQ - Q#25: Do you find you can't think of anything to say?" : "survey_results.24.rating",



  /* Tests */
  "Abstraction Score" : "results.abstractionresults",
  "Alternating Trail Score" : "results.viscospatialtest1",
  "Animal Naming Score" : "results.animalnametest",
  "Attention Digit Span Score" : "results.attentiontest1",
  "Attention Vigilance Score" : "results.attentiontest2",
  "Attention Serial7s Score" : "results.attentiontest3",
  "Orientation Score" : "results.dateverificationresults",
  "Delayed Recall Score" : "results.delayedRecalltest",
  "Language Test 1" : "results.languagetest1",
  "Language Test 2" : "results.languagetest2",
  //"Memory Test" : "results.memorytest",
  "Visuoconstructional Skill: Cube Drawing Score" : "results.viscospatialtest2",
  "Visuoconstructional Skill: Clock Drawing Score" : "results.visuospatialdrawclock",

};


  Future<void> downloadCSV() async {

    Map<Permission, PermissionStatus> status = await [
      Permission.manageExternalStorage,
    ].request();


    if (status[Permission.manageExternalStorage]!.isDenied) {
      await CRFileSaver.requestWriteExternalStoragePermission();
      debugPrint('Storage Permission denied');

    }
    if(status[Permission.manageExternalStorage]!.isPermanentlyDenied) {
      debugPrint('Storage Permission permanently denied');
      openAppSettings();
    }

    final QuerySnapshot querySnapshot =
    await _firestore.collection('users').get();

    List<List<dynamic>> rows = [];
    List<dynamic> row = [];



    headers.forEach((header, _) {
      row.add(header);
    });

    rows.add(row);

    for(QueryDocumentSnapshot userDoc in querySnapshot.docs) {
      List<dynamic> userData = [];

      for (String key in row) {
        dynamic data = "null";
        try {
          if(key != "Diet" && key != "Medical Condition")
           {
             data = userDoc[headers[key]??""];
           } else {
            debugPrint("key: $key");
            List<dynamic> dataArray = userDoc[headers[key]??""];

            for(int i = 0; i < dataArray.length; i++) {
              if ( dataArray[i] != "") {
                if (data != "null") {
                  data += "+\n " ;
                } else {
                  data = "";
                }
                debugPrint("Is it parsing? or nah?");
                data += dataArray[i].toString();
              }
            }
          }
        } catch (e) {
          debugPrint("Parsing Value error: $e");
          data = "null";
        }
        userData.add(data);
      }
      rows.add(userData);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    String? dir = "/storage/emulated/0/Download";//(await getExternalStorageDirectory())?.path;

    final filePath = '$dir/CogQuest_Users_Data.csv';

    File file = File(filePath);
    await file.writeAsString(csvData).whenComplete(() {
      debugPrint('dir $dir');
      Fluttertoast.showToast(msg: "file saved at: $filePath");
    });
  }

  Future<void> getAverageScore() async {
    final QuerySnapshot querySnapshot =
    await _firestore.collection('users').get();
    num sumOfScores = 0;
    int numOfValidUsers = 0;

    for(QueryDocumentSnapshot userDoc in querySnapshot.docs) {
      try {
        sumOfScores += userDoc["results.totalscore"];
        numOfValidUsers++;
      } catch (e) {
        debugPrint("Invalid User does not have total Score: id = ${userDoc.id}\nError: $e");
      }
    }
    _averageScore = (sumOfScores/numOfValidUsers).round().obs;
    _isAverageScoreLoaded = true.obs;

  }

  Future<void> getTotalSubmissions() async {
    final QuerySnapshot querySnapshot =
    await _firestore.collection('users').get();

    for (var doc in querySnapshot.docs) {
      debugPrint("${doc.id}");
    }
    _totalSubmissionsCount = querySnapshot.docs.length.obs;
    _isTotalSubmissionLoaded = true.obs;
    update();
    debugPrint("${querySnapshot.docs.length}");
  }

  Future<void> getUserByEmail() async {
    _userSearchIsLoading.value = true;
    _userSearchStarted.value = true;
    _isUserSearchFound.value = false;
    _userDoc = null;
    update();
    _searchedUserName.value = "";
    _searchedUserEmail.value = "";
    _searchedUserTotalScore.value = -1;


    final searchedEmail = userSearchBar.text;
    debugPrint(searchedEmail);
    try {
      final QuerySnapshot querySnapshot = await _firestore.collection('users')
          .where('user_info.email', isEqualTo: searchedEmail.trim())
          .get();


      if (querySnapshot.docs.isNotEmpty) {
        debugPrint(
            "${querySnapshot.docs.last['user_info']['name']} ${querySnapshot
                .docs.last['user_info']['email']} ${querySnapshot.docs
                .last['user_info']['totalScore']}");
        _searchedUserName.value =
        (querySnapshot.docs.last['user_info']['name'] as String);
        _searchedUserEmail.value =
        (querySnapshot.docs.last['user_info']['email'] as String);
        _searchedUserTotalScore.value =
        (querySnapshot.docs.last['results']['totalscore'] as int);
        _isUserSearchFound.value = true;
        _userDoc = querySnapshot;
      }
      else {
        _searchedUserName.value = "";
        _searchedUserEmail.value = "";
        _searchedUserTotalScore.value = -1;

        _isUserSearchFound.value = false;

      }
    } catch (e) {
      if(_searchedUserTotalScore.value == -1) {
        Fluttertoast.showToast(msg: "User May Not Have Submitted All Tests Yet");
      }
    }finally {
      _userSearchIsLoading.value = false;
    }


    update();
  }

  Future<void> downloadSearchedUserCsv() async {
    debugPrint(" this is my user doc ${_userDoc.toString()}");
    if (_userDoc == null) {
      Fluttertoast.showToast(msg: "Search a User By Email First!");
      return;
    }
    else {

      Map<Permission, PermissionStatus> status = await [
        Permission.manageExternalStorage,
        Permission.storage
      ].request();


      if (status[Permission.manageExternalStorage]!.isDenied) {
        await CRFileSaver.requestWriteExternalStoragePermission();
        debugPrint('Storage Permission denied');
      }
      if(status[Permission.manageExternalStorage]!.isPermanentlyDenied) {
        debugPrint('Storage Permission permanently denied');
        openAppSettings();
      }
      //else if(status[Permission.storage]!.isGranted){

      List<List<dynamic>> rows = [];
      List<dynamic> row = [];


      headers.forEach((header, _) {
        row.add(header);
      });
      rows.add(row);

      List<dynamic> userData = [];


      for (String key in row) {
        try {
          if(key != "Diet" && key != "Medical Condition") {
            userData.add(_userDoc?.docs.last[headers[key] ?? ""]);
          } else {
            debugPrint("Did it recognize me???? $key");
            List<dynamic> dataArray = _userDoc?.docs.last[headers[key] ?? ""];
            dynamic data = "null";
            for(int i = 0; i < dataArray.length; i++) {
              if ( dataArray[i] != "") {
                if (data != "null") {
                  data += "+\n " ;
                } else {
                  data = "";
                }

                debugPrint("Is it parsing? or nah?");
                data += dataArray[i].toString();
              }
            }
            userData.add(data);
          }
        } catch (e) {
          userData.add("null");
        }
      }

      rows.add(userData);
      String csvData = const ListToCsvConverter().convert(rows);
      String? dir = "/storage/emulated/0/Download";

      final filePath = '$dir/CogQuest_${_userDoc?.docs
          .last["user_info.email"]}.csv';

      File file = File(filePath);
      await file.writeAsString(csvData).whenComplete(() {
        debugPrint('dir $dir');
        Fluttertoast.showToast(msg: "file saved at: $filePath");
      });
  }}
}