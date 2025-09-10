// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:zenify_app/services/constent.dart';
// import 'package:zenify_app/ChatModulev2/Message.dart';
// import '../features/Travellers/data/model/TravellerModel.dart';

// class TravellerInfoDialog extends StatefulWidget {
//   final String userId;
//   final Conversation conversation;
//   final String? userImage;

//   const TravellerInfoDialog(
//       {Key? key,
//       required this.userId,
//       required this.conversation,
//       required this.userImage})
//       : super(key: key);

//   @override
//   _TravellerInfoDialogState createState() => _TravellerInfoDialogState();
// }

// class _TravellerInfoDialogState extends State<TravellerInfoDialog> {
//   final storage = FlutterSecureStorage();
//   late Future<List<TravellerModel>> _travellersFuture;

//   @override
//   void initState() {
//     super.initState();
//     _travellersFuture = fetchTravellers(widget.userId);
//   }

//   Future<List<TravellerModel>> fetchTravellers(String userid) async {
//     try {
//       String? token = await storage.read(key: "access_token");
//       print("${widget.conversation.id}");
//       final response = await http.get(
//         Uri.parse(
//             "$baseUrls/api/travellers?filters[userId]=${widget.conversation.clientUserId}"),
//         headers: {"Authorization": "Bearer $token"},
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         // Note: This print statement has incorrect text for successful data
//         print("Traveller data loaded: ${data}");
//         if (!data.containsKey('results') || data['results'] == null) {
//           return [];
//         }

//         final List<dynamic> results = data['results'];
//         return results.map((item) => TravellerModel.fromJson(item)).toList();
//       } else {
//         print("Failed to load Traveller ${widget.conversation.id}");
//         return [];
//       }
//     } catch (e) {
//       print("Error fetching Traveller: $e");
//       return [];
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       child: Container(
//         child: contentBox(context),
//         height: Get.height * 0.5,
//       ),
//     );
//   }

//   Widget contentBox(BuildContext context) {
//     return Stack(
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             image: widget.userImage != null
//                 ? DecorationImage(
//                     image: NetworkImage(
//                         "$baseUrls/assets/uploads/traveller/${widget?.userImage}"),
//                     fit: BoxFit.cover,
//                     colorFilter: ColorFilter.mode(
//                       Colors.black.withOpacity(0.3),
//                       BlendMode.darken,
//                     ),
//                   )
//                 : null,
//             color: widget.userImage == null
//                 ? Theme.of(context).cardColor
//                 : Colors.transparent,
//           ),
//         ),
//         Container(
//           padding: EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 40),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             gradient: widget.userImage != null
//                 ? LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.black.withOpacity(0.1),
//                       Colors.black.withOpacity(0.8),
//                     ],
//                   )
//                 : null,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 10.0,
//                 offset: Offset(0.0, 10.0),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Text(
//                 'Traveller Information',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color:   widget.userImage != null? Colors.white
//                         : Colors.grey[900]!),
//               ),
//               SizedBox(height: 16),
//               FutureBuilder<List<TravellerModel>>(
//                 future: _travellersFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Text('Error: ${snapshot.error}');
//                   } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return Text('No traveller information available');
//                   } else {
//                     return Expanded(
//                       child: ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: snapshot.data!.length,
//                         itemBuilder: (context, index) {
//                           final traveller = snapshot.data![index];
//                           return TravellerCard(
//                             traveller: traveller,
//                             hasBackgroundImage: widget.userImage != null,
//                           );
//                         },
//                       ),
//                     );
//                   }
//                 },
//               ),
//               SizedBox(height: 16),
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('Close'),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class TravellerCard extends StatelessWidget {
//   final TravellerModel traveller;
//   final bool hasBackgroundImage;

//   const TravellerCard({
//     Key? key,
//     required this.traveller,
//     this.hasBackgroundImage = false,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     Color textColor = hasBackgroundImage ? Colors.white : Colors.grey[900]!;
//     Color labelColor = hasBackgroundImage ? Colors.white70 : Colors.grey[700]!;

//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 8),
//       color: hasBackgroundImage ? Colors.black.withOpacity(0.5) : null,
//       child: Padding(
//         padding: EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CachedNetworkImage(
//                   imageUrl:
//                       "${baseUrls}/assets/uploads/traveller/${traveller.user?.picture}",
//                   errorWidget: (context, url, error) => Container(
//                     width: Get.width * 0.08,
//                     height: Get.width * 0.08,
//                     child: Image.asset("assets/man-user-circle-icon.png"),
//                   ),
//                   placeholder: (context, url) => SizedBox(
//                     height: 5,
//                   ),
//                   imageBuilder: (context, imageProvider) => ClipOval(
//                     child: Container(
//                       width: Get.width * 0.08,
//                       height: Get.width * 0.08,
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                           image: imageProvider,
//                           fit: BoxFit.cover,
//                         ),
//                         borderRadius: BorderRadius.circular(8),
//                         color: const Color.fromARGB(255, 235, 235, 202),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '${traveller.user?.firstName} ${traveller.user?.lastName}',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: textColor,
//                         ),
//                       ),
//                       if (traveller.user?.email != null)
//                         Text(
//                           traveller.user?.email ?? "",
//                           style: TextStyle(
//                             color: textColor,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             if (traveller.code != null)
//               InfoRow(
//                 label: 'code:',
//                 value: traveller.code!,
//                 labelColor: labelColor,
//                 valueColor: textColor,
//               ),
//             if (traveller.user?.birthDate != null)
//               InfoRow(
//                 label: 'DOB:',
//                 value: _formatDate(traveller.user!.birthDate!),
//                 labelColor: labelColor,
//                 valueColor: textColor,
//               ),

//             // if (traveller.nationality != null)
//             //   InfoRow(
//             //     label: 'Nationality:',
//             //     value: traveller.nationality!,
//             //   ),

//             // Accommodation section
//             if (traveller.accommodation != null &&
//                 traveller.accommodation!.isNotEmpty)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 8),
//                   Text(
//                     'Accommodations:',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w500,
//                       color: labelColor,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   SizedBox(
//                     height: 60,
//                     width: Get.width,
//                     child: ListView.builder(
//                       scrollDirection: Axis.vertical,
//                       itemCount: traveller.accommodation?.length ?? 0,
//                       itemBuilder: (context, index) {
//                         return Padding(
//                           padding: const EdgeInsets.only(right: 8.0),
//                           child: Column(
//                             children: [
//                               Text(
//                                 " ${index}🏨 ${traveller.accommodation![index]?.hotel?.name ?? "N/A"}",
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style:  TextStyle(color: textColor,
//                                     fontSize: 14, fontWeight: FontWeight.w500),
//                               ),
//                               Text(
//                                 "Room N: ${traveller.accommodation![index]?.roomNumber ?? "N/A"}",
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style:  TextStyle(color: textColor,
//                                     fontSize: 14, fontWeight: FontWeight.w500),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }

// class InfoRow extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color labelColor;
//   final Color valueColor;

//   const InfoRow({
//     Key? key,
//     required this.label,
//     required this.value,
//     this.labelColor = const Color(0xFF616161), // Default to Colors.grey[700]
//     this.valueColor = const Color(0xFF212121), // Default to Colors.grey[900]
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontWeight: FontWeight.w500,
//               color: labelColor,
//             ),
//           ),
//           SizedBox(width: 4),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(color: valueColor),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// // // Assuming this is your TravellerModel class
// // class TravellerModel {
// //   final String id;
// //   final String firstName;
// //   final String lastName;
// //   final String? email;
// //   final String? passportNumber;
// //   final DateTime? dateOfBirth;
// //   final String? nationality;
// //   final String? profilePicture;

// //   TravellerModel({
// //     required this.id,
// //     required this.firstName,
// //     required this.lastName,
// //     this.email,
// //     this.passportNumber,
// //     this.dateOfBirth,
// //     this.nationality,
// //     this.profilePicture,
// //   });

// //   factory TravellerModel.fromJson(Map<String, dynamic> json) {
// //     return TravellerModel(
// //       id: json['id'],
// //       firstName: json['firstName'] ?? '',
// //       lastName: json['lastName'] ?? '',
// //       email: json['email'],
// //       passportNumber: json['passportNumber'],
// //       dateOfBirth: json['dateOfBirth'] != null
// //           ? DateTime.parse(json['dateOfBirth'])
// //           : null,
// //       nationality: json['nationality'],
// //       profilePicture: json['profilePicture'],
// //     );
// //   }
// // }
