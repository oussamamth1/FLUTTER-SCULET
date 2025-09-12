// import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart' as Cached;
// // import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:zenify_app/modele/activitsmodel/usersmodel.dart';
// import 'package:zenify_app/services/constent.dart';

// extension BuildContextX on BuildContext {
//   void showErrorSnackBar(String message, {Duration? duration}) {
//     ScaffoldMessenger.of(this)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.red,
//           duration: duration ?? const Duration(seconds: 2),
//         ),
//       );
//   }

//   void showSuccessSnackBar(String message, {Duration? duration}) {
//     ScaffoldMessenger.of(this)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.green,
//           duration: duration ?? const Duration(seconds: 2),
//         ),
//       );
//   }

//   void hideCurrentSnackbar() {
//     ScaffoldMessenger.of(this).hideCurrentSnackBar();
//   }

//   // Future<CountryCode?> showCountryPicker() async {
//   //   final FlCountryCodePicker codePicker = FlCountryCodePicker(
//   //     countryTextStyle: TextStyle(
//   //       fontSize: 16.sp,
//   //     ),
//   //     dialCodeTextStyle: TextStyle(
//   //       fontSize: 16.sp,
//   //       fontWeight: FontWeight.w700,
//   //     ),
//   //   );

//   //   final code = await codePicker.showPicker(
//   //     context: this,
//   //     scrollToDeviceLocale: true,
//   //   );

//   //   return code;
//   // }

//   showConfirmDialog({
//     required String title,
//     String? description,
//     required VoidCallback? onNegativeButton,
//     required VoidCallback? onPositiveButton,
//   }) {
//     AwesomeDialog(
//       context: this,
//       title: title,
//       desc: description,
//       animType: AnimType.scale,
//       dialogType: DialogType.question,
//       btnCancelOnPress: onNegativeButton,
//       btnOkOnPress: onPositiveButton,
//     ).show();
//   }

//   void showSuccessDialog({
//     required String title,
//     String? description,
//     required void Function()? btnOkOnPress,
//   }) {
//     AwesomeDialog(
//       context: this,
//       title: title,
//       dismissOnTouchOutside: false,
//       desc: description,
//       animType: AnimType.scale,
//       dialogType: DialogType.success,
//       btnOkOnPress: btnOkOnPress,
//     ).show();
//   }

//   void showDilog({
//     required String title,
//     String? description,
//     required void Function()? btnOkOnPress,
//   }) {
//     AwesomeDialog(
//       context: this,
//       title: title,
//       dismissOnTouchOutside: false,
//       desc: description,
//       animType: AnimType.scale,
//       dialogType: DialogType.info,
//       customHeader: ClipOval(
//         child: Cached.CachedNetworkImage(
//           height: 60,
//           width: 60,
//           cacheManager: CacheManager(
//             Config(
//               "fluttercampus",
//               stalePeriod: const Duration(days: 20),
//               //one week cache period
//             ),
//           ),
//           imageUrl: '',
//           fadeInCurve: Curves.fastOutSlowIn,
//           placeholder:
//               (context, url) => SizedBox(
//                 height: 10,
//                 width: 10,
//                 child: Icon(Icons.groups, color: Colors.white30),
//               ),
//           errorWidget:
//               (context, url, error) => Container(
//                 color: Color.fromARGB(246, 246, 242, 240),
//                 width: 10,
//                 height: 10,
//                 child: Icon(
//                   Icons.group,
//                   color: Color.fromARGB(255, 200, 108, 3),
//                 ),
//               ),
//         ),
//       ),
//       btnOkOnPress: btnOkOnPress,
//       btnOkColor: Color.fromARGB(255, 237, 105, 17),
//     ).show();
//   }

//   void showInformationDialog({
//     required String title,
//     String? description,
//     // required void Function()? btnOkOnPress,
//   }) {
//     AwesomeDialog(
//       context: this,
//       title: title,
//       desc: description,
//       animType: AnimType.scale,
//       dialogType: DialogType.success,
//       dismissOnTouchOutside: false,
//       customHeader: ClipOval(
//         child: Cached.CachedNetworkImage(
//           height: 60,
//           width: 60,
//           cacheManager: CacheManager(
//             Config(
//               "fluttercampus",
//               stalePeriod: const Duration(days: 20),
//               //one week cache period
//             ),
//           ),
//           imageUrl:
//               'https://static6.depositphotos.com/1067431/551/i/600/depositphotos_5510312-stock-photo-warm-sun.jpg',
//           fadeInCurve: Curves.fastOutSlowIn,
//           placeholder:
//               (context, url) => SizedBox(
//                 height: 10,
//                 width: 10,
//                 child: Icon(Icons.face, color: Colors.white30),
//               ),
//           errorWidget:
//               (context, url, error) => Container(
//                 color: Colors.black87,
//                 width: 10,
//                 height: 10,
//                 child: Icon(Icons.face, color: Colors.white30),
//               ),
//         ),
//       ),

//       // btnOkOnPress: btnOkOnPress,
//     ).show();
//   }

//   void showInformationuserDialog({
//     required String title,
//     String? description,
//     required User user,
//     // required void Function()? btnOkOnPress,
//   }) {
//     AwesomeDialog(
//       context: this,
//       title: title,
//       desc: description,
//       dismissOnTouchOutside: false,
//       dismissOnBackKeyPress: false,
//       isDense: true,
//       transitionAnimationDuration: Durations.long2,
//       animType: AnimType.scale,
//       dialogType: DialogType.success,
//       // customHeader: ClipOval(
//       //   child: Cached.CachedNetworkImage(
//       //     height: 60,
//       //     width: 60,
//       //     cacheManager: CacheManager(Config(
//       //       "fluttercampus",
//       //       stalePeriod: const Duration(days: 20),
//       //       //one week cache period
//       //     )),
//       //     imageUrl:  '${baseUrls}/assets/uploads/traveller/${user?.picture}',
//       //     fadeInCurve: Curves.fastOutSlowIn,
//       //     placeholder: (context, url) => SizedBox(
//       //       height: 10,
//       //       width: 10,
//       //       child: Icon(
//       //         Icons.face,
//       //         color: Colors.white30,
//       //       ),
//       //     ),
//       //     errorWidget: (context, url, error) => Container(
//       //       color: Colors.black87,
//       //       width: 10,
//       //       height: 10,
//       //       child: Icon(
//       //         Icons.face,
//       //         color: Colors.white30,
//       //       ),
//       //     ),
//       //   ),
//       // )

//       // btnOkOnPress: btnOkOnPress,
//     ).show();
//   }

//   void showErrorDialog({
//     required String title,
//     String? description,
//     required void Function()? btnOkOnPress,
//   }) {
//     AwesomeDialog(
//       context: this,
//       title: title,
//       desc: description,
//       animType: AnimType.scale,
//       dialogType: DialogType.error,
//       btnOkOnPress: btnOkOnPress,
//       btnOkColor: Color.fromARGB(251, 235, 95, 82),
//     ).show();
//   }

//   void showselectedDialog({
//     required String title,
//     String? description,
//     required Color btnOkColor,
//     required void Function()? btnOkOnPress,
//   }) {
//     AwesomeDialog(
//       context: this,
//       title: title,
//       desc: description,
//       animType: AnimType.scale,
//       customHeader: ClipOval(
//         child: Cached.CachedNetworkImage(
//           height: 60,
//           width: 60,
//           cacheManager: CacheManager(
//             Config(
//               "fluttercampus",
//               stalePeriod: const Duration(days: 20),
//               //one week cache period
//             ),
//           ),
//           imageUrl:
//               'https://img.freepik.com/premium-photo/choosing-candidate-from-group-employee-selection-recruitment_220873-13673.jpg',
//           fadeInCurve: Curves.fastOutSlowIn,
//           placeholder:
//               (context, url) => SizedBox(
//                 height: 10,
//                 width: 10,
//                 child: Icon(Icons.face, color: Colors.white30),
//               ),
//           errorWidget:
//               (context, url, error) => Container(
//                 color: Colors.black87,
//                 width: 10,
//                 height: 10,
//                 child: Icon(Icons.face, color: Colors.white30),
//               ),
//         ),
//       ),

//       btnOkOnPress: btnOkOnPress,
//       btnOkColor: btnOkColor,
//     ).show();
//   }
// }

// extension DateTimeFormat on int {
//   String countDay() {
//     final remains = DateTime.now().difference(
//       DateTime.fromMillisecondsSinceEpoch(this),
//     );

//     if (remains.inDays == 0) return 'Today';
//     return '${remains.inDays.toString()} days ago';
//   }
// }

// extension DateFormatter on DateTime {
//   String format() {
//     return DateFormat('yyyy-MM-dd, hh:mm a').format(this);
//   }
// }

// extension F on String {
//   String toCapitalize() {
//     return replaceAllMapped(
//       RegExp(r'[A-Z]'),
//       (match) => ' ${match.group(0)}',
//     ).toLowerCase().replaceAllMapped(
//       RegExp(r'\b\w'),
//       (match) => match.group(0)!.toUpperCase(),
//     );
//   }

//   String removeDiacritics() {
//     return replaceAll(RegExp('[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
//         .replaceAll(RegExp('[èéẹẻẽêềếệểễ]'), 'e')
//         .replaceAll(RegExp('[ìíịỉĩ]'), 'i')
//         .replaceAll(RegExp('[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
//         .replaceAll(RegExp('[ùúụủũưừứựửữ]'), 'u')
//         .replaceAll(RegExp('[ỳýỵỷỹ]'), 'y')
//         .replaceAll(RegExp('[đ]'), 'd');
//   }
// }
