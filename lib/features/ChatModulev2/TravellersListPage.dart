// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:zenify_app/ChatModulev2/Message.dart';
// import 'package:zenify_app/ChatModulev2/chatSecreen.dart';
// import 'package:zenify_app/login/Login.dart';
// import 'package:zenify_app/modele/traveller/TravellerModel.dart';
// import 'package:zenify_app/services/constent.dart';

// class TravellersListPage extends StatefulWidget {
//   final List<Traveller> travellers;

//   const TravellersListPage({Key? key, required this.travellers})
//       : super(key: key);

//   @override
//   State<TravellersListPage> createState() => _TravellersListPageState();
// }

// class _TravellersListPageState extends State<TravellersListPage> {
//   bool isLoading = false;

//   Future<void> createConversation(String clientUserId) async {
//     final url = Uri.parse('${baseUrls}/api/conversation');
//     final token = await storage.read(key: "access_token");
//     final guideUserId = await storage.read(key: 'id') ?? "";

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token'
//         },
//         body: jsonEncode({
//           "guideUserId": guideUserId,
//           "clientUserId": clientUserId,
//         }),
//       );
//   print(response.body);
//   print(response.statusCode);
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         // final data = json.decode(response.body);
//         print(response.body);
//      final data = json.decode(response.body);
// final conversationJson = data['conversation'];
// final existing = data['existingConversation'] ?? false;

// // Convert to Conversation model
// final conversation = Conversation.fromJson(conversationJson);

//         Get.to(ChatScreenOnetoOne(conversation: conversation));
//       } else {
//         Get.snackbar(
//           'Erreur',
//           'Impossible de créer la conversation. Code: ${response.statusCode}',
//           backgroundColor: Colors.redAccent,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.BOTTOM,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         e.toString(),
//         "Vérifiez votre connexion Internet et réessayez.",
//         backgroundColor: Colors.redAccent,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Scaffold(
//           appBar: AppBar(title: const Text('Choisir un voyageur')),
//           body: ListView.builder(
//             itemCount: widget.travellers.length,
//             itemBuilder: (context, index) {
//               final traveller = widget.travellers[index];
//               return ListTile(
//                 title: Text(
//                     '${traveller.user?.firstName ?? ''} ${traveller.user?.lastName ?? ''}'),
//                 subtitle: Text('Code: ${traveller.code}'),
//                 onTap: () {
//                   createConversation(traveller.user?.id ?? '');
//                 },
//               );
//             },
//           ),
//         ),
//         if (isLoading)
//           Container(
//             color: Colors.black.withOpacity(0.5),
//             child: const Center(
//               child: CircularProgressIndicator(),
//             ),
//           ),
//       ],
//     );
//   }
// }
