// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:get/get.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:zenify_app/ChatModulev2/chatSecreen.dart';
// import 'package:zenify_app/features/conversation/ConversationScreen.dart';
// import 'package:zenify_app/guide_Screens/travelers_list_FromSv_Code.dart';
// import 'package:zenify_app/modele/traveller/TravellerModel.dart';
// import 'package:zenify_app/services/constent.dart';
// import 'package:zenify_app/ChatModulev2/Message.dart';
// import '../features/Travellers/data/model/TravellerModel.dart';

// class UserInfoScreen extends StatefulWidget {
//   final String userId;

//   const UserInfoScreen({
//     Key? key,
//     required this.userId,
//   }) : super(key: key);

//   @override
//   _UserInfoScreenState createState() => _UserInfoScreenState();
// }

// class _UserInfoScreenState extends State<UserInfoScreen>
//     with SingleTickerProviderStateMixin {
//   final storage = FlutterSecureStorage();
//   late Future<List<Traveller>> _travellersFuture;
//   Traveller? _traveller;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _travellersFuture = fetchTravellers(widget.userId);
//     _initializeTraveller();
//     _animationController = AnimationController(
//       duration: Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));

//     _slideAnimation = Tween<Offset>(
//       begin: Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutCubic,
//     ));

//     _animationController.forward();
//   }

//   void _initializeTraveller() async {
//     try {
//       List<Traveller> travellers = await _travellersFuture;
//       if (travellers.isNotEmpty) {
//         setState(() {
//           _traveller = travellers[0]; // Gets the first traveller
//         });
//       }
//     } catch (e) {
//       print('Error initializing traveller: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<List<Traveller>> fetchTravellers(String userid) async {
//     try {
//       String? token = await storage.read(key: "access_token");
//       final response = await http.get(
//         Uri.parse("$baseUrls/api/travellers?filters[userId]=${widget.userId}"),
//         headers: {"Authorization": "Bearer $token"},
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         if (!data.containsKey('results') || data['results'] == null) {
//           return [];
//         }
//         final List<dynamic> results = data['results'];
//         print(results);
//         return results.map((item) => Traveller.fromJson(item)).toList();
//       } else {
//         return [];
//       }
//     } catch (e) {
//       return [];
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: CustomScrollView(
//         slivers: [
//           _buildAppBar(),
//           SliverToBoxAdapter(
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: SlideTransition(
//                 position: _slideAnimation,
//                 child: _buildContent(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppBar() {
//     return SliverAppBar(
//       expandedHeight: 280,
//       floating: true,
//       pinned: false,snap: true,
//       elevation: 5,
//       backgroundColor: const Color.fromARGB(234, 236, 91, 0),
//       flexibleSpace: FlexibleSpaceBar(
//         background: Stack(
//           fit: StackFit.expand,
//           children: [
//             //Background Image or Gradient
//             _traveller?.user?.picture != null
//                 ? CachedNetworkImage(
//                     imageUrl:
//                         "$baseUrls/assets/uploads/traveller/${_traveller!.user!.picture}",
//                     fit: BoxFit.cover,
//                     errorWidget: (context, url, error) =>
//                         _buildGradientBackground(),
//                   )
//                 : _traveller?.user?.picture != null
//                     ? CachedNetworkImage(
//                         imageUrl:
//                             "$baseUrls/assets/uploads/traveller/${_traveller?.user?.picture}",
//                         fit: BoxFit.cover,
//                         errorWidget: (context, url, error) =>
//                             _buildGradientBackground(),
//                       )
//                     : _buildGradientBackground(),

//             // Gradient Overlay
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.transparent,
//                     Colors.black.withOpacity(0.7),
//                   ],
//                 ),
//               ),
//             ),

//             // Content
//             Positioned(
//               bottom: 24,
//               left: 24,
//               right: 24,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//              Transform.translate(
//                offset: const Offset(0, -0),
//                child: Container(
//                  margin: const EdgeInsets.symmetric(horizontal: 20),
//                  padding: const EdgeInsets.all(20),
//                  decoration: BoxDecoration(
//                    color: const Color.fromARGB(0, 255, 255, 255),
//                    borderRadius: BorderRadius.circular(20),
//                    boxShadow: [
//                      BoxShadow(
//                        color: Colors.black.withOpacity(0.1),
//                        blurRadius: 20,
//                        offset: const Offset(0, 10),
//                      ),
//                    ],
//                  ),
//                  child: Row(
//                    children: [
//                      Expanded(
//                        child: ElevatedButton.icon(
//                          onPressed: () => createConversations(
//                              _traveller?.user?.id ?? ""),
//                          icon: const Icon(Icons.chat_bubble_outline),
//                          label: const Text('Discussion'),
//                          style: ElevatedButton.styleFrom(
//                            backgroundColor: const Color(0xFF6A5ACD),
//                            foregroundColor: Colors.white,
//                            padding:
//                                const EdgeInsets.symmetric(vertical: 16),
//                            shape: RoundedRectangleBorder(
//                              borderRadius: BorderRadius.circular(12),
//                            ),
//                            elevation: 0,
//                          ),
//                        ),
//                      ),
//                      const SizedBox(width: 12),
//                      if (_traveller?.user?.phone != null)
//                        Container(
//                          decoration: BoxDecoration(
//                            color: const Color.fromARGB(88, 137, 234, 139),
//                            borderRadius: BorderRadius.circular(12),
//                            border:
//                                Border.all(color: Colors.grey.shade200),
//                          ),
//                          child: IconButton(
//                            onPressed: _makePhoneCall,
//                            icon: const Icon(Icons.phone,
//                                color: Color.fromARGB(255, 2, 235, 64)),
//                            padding: const EdgeInsets.all(16),
//                          ),
//                        ),
//                      const SizedBox(width: 12),
//                      Container(
//                        decoration: BoxDecoration(
//                          color: const Color.fromARGB(106, 231, 181, 1),
//                          borderRadius: BorderRadius.circular(12),
//                          border: Border.all(color: Colors.grey.shade200),
//                        ),
//                        child: IconButton(
//                          onPressed: _sendEmail,
//                          icon: const Icon(Icons.email_outlined,
//                              color: Color.fromARGB(255, 226, 0, 41)),
//                          padding: const EdgeInsets.all(16),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//              ),

//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       leading: Container(
//         margin: EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(12),
//           //  backdropFilter: BlurEffect(),
//         ),
//         child: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//     );
//   }

//   Widget _buildGradientBackground() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFF667eea),
//             Color(0xFF764ba2),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContent() {
//     return Padding(
//       padding: EdgeInsets.all(8),
//       child: FutureBuilder<List<Traveller>>(
//         future: _travellersFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return _buildLoadingState();
//           } else if (snapshot.hasError) {
//             return _buildErrorState();
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return _buildEmptyState();
//           } else {
//             return _buildTravellersList(snapshot.data!);
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return Container(
//       height: 200,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
//             ),
//             SizedBox(height: 16),
//             Text(
//              " Chargement des informations du voyageur...",
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// Widget _buildErrorState() {
//     return Container(
//       padding: EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.red[50],
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.red[200]!),
//       ),
//       child: Column(
//         children: [
//           Icon(Icons.error_outline, color: Colors.red[400], size: 48),
//           SizedBox(height: 16),
//           Text(
//             'Impossible de charger les informations',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.red[700],
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'Veuillez vérifier votre connexion et réessayer',
//             style: TextStyle(color: Colors.red[600]),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Container(
//       padding: EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.blue[50],
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.blue[200]!),
//       ),
//       child: Column(
//         children: [
//           Icon(Icons.person_outline, color: Colors.blue[400], size: 48),
//           SizedBox(height: 16),
//           Text(
//             'Aucune information disponible',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.blue[700],
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'Les informations du voyageur ne sont pas disponibles pour le moment',
//             style: TextStyle(color: Colors.blue[600]),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTravellersList(List<Traveller> travellers) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Text(
//         //   'Travellers (${travellers.length})',
//         //   style: TextStyle(
//         //     fontSize: 20,
//         //     fontWeight: FontWeight.bold,
//         //     color: Colors.grey[800],
//         //   ),
//         // ),
//         // SizedBox(height: 16),
//         ListView.separated(
//           shrinkWrap: true,
//           physics: NeverScrollableScrollPhysics(),
//           itemCount: travellers.length,
//           separatorBuilder: (context, index) => SizedBox(height: 16),
//           itemBuilder: (context, index) {
//             return TravellerProfileCard(
//               traveller: travellers[index],
//               index: index,
//             );
//           },
//         ),
//       ],
//     );
//   }

//   // Your existing methods remain the same...
//   Future<void> createConversations(String clientUserId) async {
//     final url = Uri.parse('${baseUrls}/api/conversation');
//     final token = await storage.read(key: "access_token");
//     final guideUserId = await storage.read(key: 'id') ?? "";

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

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = json.decode(response.body);
//         final conversationJson = data['conversation'];
//         final existing = data['existingConversation'] ?? false;
//         final conversation = Conversation.fromJson(conversationJson);
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
//     }
//   }

//   Future<void> createConversation(BuildContext context) async {
//     final url = Uri.parse('${baseUrls}/api/conversation');
//     final token = await storage.read(key: "access_token");
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token'
//         },
//         body: jsonEncode({
//           "recipientUserId": _traveller?.userId,
//         }),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = json.decode(response.body);
//         final conversation = data['conversation'];
//         final String conversationId = conversation['id'] ?? '';
//         final String recipientUserId = conversation['recipientUserId'] ?? '';

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ConversationScreen(
//               conversationId: conversationId,
//               recipientUserId: _traveller?.userId ?? "",
//             ),
//           ),
//         );
//       } else {
//         print('Failed to create conversation: ${response.statusCode}');
//         print('Error: ${response.body}');
//       }
//     } catch (e) {
//       print('Error creating conversation: $e');
//     }
//   }

//   Future<void> _makePhoneCall() async {
//     final phoneNumber = _traveller?.user?.phone;
//     if (phoneNumber == null || phoneNumber.isEmpty) {
//       _showErrorSnackbar(
//         'Phone Error',
//         'No phone number available for this traveler.',
//       );
//       return;
//     }

//     try {
//       final phoneUri = Uri.parse('tel:$phoneNumber');
//       if (await canLaunchUrl(phoneUri)) {
//         await launchUrl(phoneUri);
//       } else {
//         _showErrorSnackbar(
//           'Phone Error',
//           'Unable to make phone calls on this device.',
//         );
//       }
//     } catch (e) {
//       _showErrorSnackbar(
//         'Phone Error',
//         'Failed to initiate phone call.',
//       );
//     }
//   }

//   Future<void> _sendEmail() async {
//     final email = _traveller?.user?.email;
//     if (email == null || email.isEmpty) {
//       _showErrorSnackbar(
//         'Email Error',
//         'No email address available for this traveler.',
//       );
//       return;
//     }

//     try {
//       final emailUri = Uri.parse('mailto:$email');
//       if (await canLaunchUrl(emailUri)) {
//         await launchUrl(emailUri);
//       } else {
//         _showErrorSnackbar(
//           'Email Error',
//           'Unable to open email client on this device.',
//         );
//       }
//     } catch (e) {
//       _showErrorSnackbar(
//         'Email Error',
//         'Failed to open email client.',
//       );
//     }
//   }

//   void _showErrorSnackbar(String title, String message) {
//     Get.snackbar(
//       title,
//       message,
//       backgroundColor: Colors.red.shade400,
//       colorText: Colors.white,
//       snackPosition: SnackPosition.BOTTOM,
//       borderRadius: 10,
//       margin: const EdgeInsets.all(16),
//       duration: const Duration(seconds: 3),
//     );
//   }

//   String getFormattedTitle(String? title) {
//     if (title == null || title.isEmpty) {
//       return "";
//     }

//     switch (title.toLowerCase()) {
//       case 'mr':
//         return 'M';
//       case 'ms':
//         return 'Mme';
//       case 'child':
//         return 'Enfant';
//       default:
//         return title;
//     }
//   }

// }

// class TravellerProfileCard extends StatelessWidget {
//   final Traveller traveller;
//   final int index;

//   const TravellerProfileCard({
//     Key? key,
//     required this.traveller,
//     required this.index,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//            _buildHeader(),
//          SizedBox(height: 16),
//          //   _buildBasicInfo(),

            
//  buildTravellerInfo( context, traveller),
//             if (traveller.transfers != null &&
//                 traveller.transfers!.isNotEmpty) ...[
//               SizedBox(height: 20),
//               _buildTransferSection(),
//             ],
//             _buildUserInfo(context, traveller),
//             if (traveller.accommodation != null &&
//                 traveller.accommodation!.isNotEmpty) ...[
//               SizedBox(height: 20),
//               _buildAccommodationSection(),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       children: [
//         Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             gradient: LinearGradient(
//               colors: [Color(0xFF667eea), Color(0xFF764ba2)],
//             ),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: CachedNetworkImage(
//               imageUrl:
//                   "${baseUrls}/assets/uploads/traveller/${traveller.user?.picture}",
//               fit: BoxFit.cover,
//               errorWidget: (context, url, error) => Icon(
//                 Icons.person,
//                 color: Colors.white,
//                 size: 30,
//               ),
//             ),
//           ),
//         ),
//         SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//                    FittedBox(
//                      child: Row(
//                                      mainAxisAlignment: MainAxisAlignment.center,
//                                      children: [
//                                        Text(
//                       getFormattedTitle(traveller.title ?? ""),
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
                                       
//                       ),
//                                        ),
//                                        Text(
//                       ' ${traveller.user?.firstName} ${traveller.user?.lastName}',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
                       
//                       ),
//                                        ),
//                                      ],
//                                    ),
//                    ),
                         
//               SizedBox(height: 4),
//               if (traveller.user?.email != null)
//                 Text(
//                   traveller.user!.email!,
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 14,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: Color(0xFF667eea).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             '#${traveller.code}',
//             style: TextStyle(
//               color: Color(0xFF667eea),
//               fontWeight: FontWeight.w600,
//               fontSize: 12,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildBasicInfo() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           if (traveller.code != null)
//             _buildInfoRow(
//               icon: Icons.qr_code,
//               label: 'Code',
//               value: traveller.code!,
//             ),
//           if (traveller.user?.birthDate != null) ...[
//             if (traveller.code != null) SizedBox(height: 12),
//             _buildInfoRow(
//               icon: Icons.cake,
//               label: 'Date of Birth',
//               value: _formatDate(traveller.user!.birthDate!),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Row(
//       children: [
//         Container(
//           padding: EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Color(0xFF667eea).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             icon,
//             size: 20,
//             color: Color(0xFF667eea),
//           ),
//         ),
//         SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[800],
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

// // Updated condition check


// Widget _buildAccommodationSection() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Row(
//         children: [
//           Icon(
//             Icons.hotel,
//             color: Color(0xFF667eea),
//             size: 20,
//           ),
//           SizedBox(width: 8),
//           Text(
//             'Hébergements',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[800],
//             ),
//           ),
//           Spacer(),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: Color(0xFF667eea).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               '${traveller.accommodation!.length}',
//               style: TextStyle(
//                 color: Color(0xFF667eea),
//                 fontWeight: FontWeight.w600,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//       SizedBox(height: 12),
//       ListView.separated(
//         shrinkWrap: true,
//         physics: NeverScrollableScrollPhysics(),
//         itemCount: traveller.accommodation!.length,
//         separatorBuilder: (context, index) => SizedBox(height: 12),
//         itemBuilder: (context, index) {
//           final accommodation = traveller.accommodation![index];
//           return Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey[200]!),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.1),
//                   spreadRadius: 1,
//                   blurRadius: 3,
//                   offset: Offset(0, 1),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // En-tête de l'hôtel avec étoiles
//                 Row(
//                   children: [
//                      accommodation.hotel?.picture!=null?    Container(
//                     width: 48,
//                     height: 48,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       color: Colors.grey[100],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: CachedNetworkImage(
//                         imageUrl: "${baseUrls}${accommodation.hotel?.picture}",
//                         fit: BoxFit.cover,
//                         errorWidget: (context, url, error) => const Icon(
//                           Icons.hotel,
//                           color: Colors.grey,
//                         ),
//                         placeholder: (context, url) => const Center(
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         ),
//                       ),
//                     ),
//                   ):
//                   Container(
//                       width: 48,
//                       height: 48,
//                       decoration: BoxDecoration(
//                         color: Color(0xFF667eea).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Icon(
//                         Icons.hotel,
//                         color: Color(0xFF667eea),
//                         size: 24,
//                       ),
//                     ),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             accommodation?.hotel?.name ?? 'Nom de l’hôtel N/D',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               color: Colors.grey[800],
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           if (accommodation?.hotel?.starsCount != null)
//                             Row(
//                               children: [
//                                 ...List.generate(
//                                   accommodation!.hotel!.starsCount!,
//                                   (index) => Icon(
//                                     Icons.star,
//                                     color: Colors.amber,
//                                     size: 16,
//                                   ),
//                                 ),
//                                 SizedBox(width: 4),
//                                 Text(
//                                   '${accommodation.hotel!.starsCount} étoiles',
//                                   style: TextStyle(
//                                     color: Colors.grey[600],
//                                     fontSize: 12,
//                                   ),
//                                 ),    accommodation.hotel?.coordinates!=null?   IconButton(
//                     onPressed: () {
//                       final coordinates = accommodation.hotel?.coordinates;
//                       if (coordinates != null &&
//                           coordinates['coordinates'] != null) {
//                         final lat = coordinates['coordinates'][1];
//                         final lng = coordinates['coordinates'][0];
//                         _openMap(lat, lng);
//                       }
//                     },
//                     icon: const Icon(
//                       Icons.location_on,
//                       color: Color(0xFFFF5722),
//                       size: 20,
//                     ),
//                   ):Gap(0),
             
//                               ],
//                             ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 12),

//                 // Description de l'hôtel
//                 if (accommodation?.hotel?.shortDescription != null)
//                   Container(
//                     padding: EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       accommodation!.hotel!.shortDescription!,
//                       style: TextStyle(
//                         color: Colors.grey[700],
//                         fontSize: 13,
//                         height: 1.4,
//                       ),
//                     ),
//                   ),

//                 SizedBox(height: 12),

//                 // Détails de réservation
//                 Container(
//                   padding: EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Color(0xFF667eea).withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     children: [
//                       // Date d’arrivée
//                       if (accommodation?.date != null)
//                         Row(
//                           children: [
//                             Icon(Icons.calendar_today, 
//                                  color: Color(0xFF667eea), size: 16),
//                             SizedBox(width: 8),
//                             Text(
//                               'Arrivée : ${_formatDate(accommodation!.date!)}',
//                               style: TextStyle(
//                                 color: Colors.grey[700],
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),

//                       SizedBox(height: 8),

//                       // Durée
//                       if (accommodation?.countNights != null)
//                         Row(
//                           children: [
//                             Icon(Icons.nights_stay, 
//                                  color: Color(0xFF667eea), size: 16),
//                             SizedBox(width: 8),
//                             Text(
//                               '${accommodation!.countNights} nuit(s)',
//                               style: TextStyle(
//                                 color: Colors.grey[700],
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),

//                       SizedBox(height: 8),

//                       // Nombre de personnes
//                       Row(
//                         children: [
//                           Icon(Icons.people, 
//                                color: Color(0xFF667eea), size: 16),
//                           SizedBox(width: 8),
//                           Text(
//                             _buildGuestInfo(accommodation),
//                             style: TextStyle(
//                               color: Colors.grey[700],
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),

//                       // Régime de repas
//                       if (accommodation?.mealPlan != null)
//                         Padding(
//                           padding: EdgeInsets.only(top: 8),
//                           child: Row(
//                             children: [
//                               Icon(Icons.restaurant, 
//                                    color: Color(0xFF667eea), size: 16),
//                               SizedBox(width: 8),
//                               Text(
//                                 'Régime : ${accommodation!.mealPlan}',
//                                 style: TextStyle(
//                                   color: Colors.grey[700],
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),

//                 SizedBox(height: 12),

//                 // Adresse
//                 if (accommodation?.hotel?.address != null)
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(Icons.location_on, 
//                            color: Colors.grey[500], size: 16),
//                       SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           accommodation!.hotel!.address!,
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     ],
//   );
// }

// // Helper method to format date
// String _formatDate(DateTime date) {
//   return '${date.day}/${date.month}/${date.year}';
// }

// // Helper method to build guest information
// String _buildGuestInfo(dynamic accommodation) {
//   List<String> guests = [];
  
//   if (accommodation?.adultCount != null && accommodation.adultCount > 0) {
//     guests.add('${accommodation.adultCount} Adult${accommodation.adultCount > 1 ? 's' : ''}');
//   }
  
//   if (accommodation?.childCount != null && accommodation.childCount > 0) {
//     guests.add('${accommodation.childCount} Child${accommodation.childCount > 1 ? 'ren' : ''}');
//   }
  
//   if (accommodation?.babyCount != null && accommodation.babyCount > 0) {
//     guests.add('${accommodation.babyCount} Baby${accommodation.babyCount > 1 ? 'ies' : ''}');
//   }
  
//   return guests.isNotEmpty ? guests.join(', ') : 'Guest info N/A';
// }
//   Widget _buildTransferSection() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildTransferHeader(),
//           const SizedBox(height: 16),
//           _buildTransferList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTransferHeader() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFF667eea),
//             const Color(0xFF764ba2),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Icon(
//               Icons.transfer_within_a_station,
//               color: Colors.white,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               'Transfers',
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 1,
//               ),
//             ),
//             child: Text(
//               '${traveller.transfers?.length ?? 0}',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTransferList() {
//     if (traveller.transfers?.isEmpty ?? true) {
//       return _buildEmptyState();
//     }

//     return ListView.separated(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: traveller.transfers!.length,
//       separatorBuilder: (context, index) => const SizedBox(height: 12),
//       itemBuilder: (context, index) {
//         final transfer = traveller.transfers![index];
//         return _buildTransferItem(transfer, index);
//       },
//     );
//   }

//   Widget _buildTransferItem(dynamic transfer, int index) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: Colors.grey.shade200,
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           _buildTransferNumber(index),
//           const SizedBox(width: 16),
//           Expanded(
//             child: _buildTransferDetails(transfer),
//           ),
//           _buildTransferArrow(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTransferNumber(int index) {
//     return Container(
//       width: 44,
//       height: 44,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFF667eea).withOpacity(0.8),
//             const Color(0xFF764ba2).withOpacity(0.8),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF667eea).withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Center(
//         child: Text(
//           '${index + 1}',
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTransferDetails(dynamic transfer) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(
//               Icons.location_on,
//               size: 16,
//               color: Colors.grey.shade600,
//             ),
//             const SizedBox(width: 4),
//             Expanded(
//               child: Text(
//                 transfer?.from ?? 'Departure location',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey.shade800,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Container(
//           margin: const EdgeInsets.only(left: 10),
//           child: Row(
//             children: [
//               Container(
//                 width: 2,
//                 height: 20,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF667eea).withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(1),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Icon(
//                 Icons.arrow_downward,
//                 size: 14,
//                 color: Colors.grey.shade500,
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   transfer?.to ?? 'Destination',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade600,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTransferArrow() {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Icon(
//         Icons.chevron_right,
//         color: Colors.grey.shade500,
//         size: 20,
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         children: [
//           Icon(
//             Icons.transfer_within_a_station_outlined,
//             size: 48,
//             color: Colors.grey.shade400,
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'No transfers available',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Transfer details will appear here when available',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey.shade500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildUserInfo(BuildContext context, Traveller traveller) {
//     bool hasPhoneNumber = (traveller?.user?.phone != null &&
//         (traveller?.user?.phone?.isNotEmpty ??
//         false )&&
//         traveller.user?.phone != 'N/A');

//     return Column(
//       children: [
//         _buildInfoTile(
//           icon: Icons.email,
//           title: "E-Mail",
//           subtitle: traveller?.user!.email ?? 'Non disponible',
//           hasValue: traveller?.user!.email != null &&
//             (traveller?.user?.phone?.isNotEmpty ??
//         false ),
//         ),
//         _buildInfoTile(
//           icon: hasPhoneNumber ? Icons.phone : Icons.phone_disabled,
//           title: "Numéro de téléphone",
//           subtitle: hasPhoneNumber
//               ? traveller?.user?.phone??""
//               : 'Aucun numéro disponible',
//           hasValue: hasPhoneNumber,
//         ),
//      traveller.user!.birthDate != null?   _buildInfoTile(
//           icon: Icons.cake,
//           title: "Date de naissance",
//           subtitle: traveller.user!.birthDate != null
//               ? DateFormat('dd MMMM yyyy', 'fr')
//                   .format(traveller?.user!.birthDate??DateTime.now())
//               : 'Non spécifiée',
//           hasValue: traveller?.user!.birthDate != null,
//         ):Gap(2),
//         if (traveller?.supplements != null &&
//            ( traveller?.supplements?.isNotEmpty??false))
//           _buildInfoTile(
//             icon: Icons.add_circle_outline,
//             title: "Suppléments",
//             subtitle: traveller?.supplements??"",
//             hasValue: true,
//           ),
//       ],
//     );
//   }

//   Widget buildTravellerInfo(BuildContext context, Traveller _traveller) {
//     return SingleChildScrollView(
//      // padding: const EdgeInsets.all(12),
//       child: Column(
//         children: [
//           _buildInfoTile(
//             icon: Icons.flight_land,
//             title: "Date d'arrivée",
//             subtitle: DateFormat('EEEE d MMMM yyyy', 'fr')
//                 .format(_traveller?.arrivalDate ?? DateTime.now()),
//             hasValue: true,
//           ),
//           _buildInfoTile(
//             icon: Icons.flight_takeoff,
//             title: "Date de départ",
//             subtitle: DateFormat('EEEE d MMMM yyyy', 'fr')
//                 .format(_traveller?.departureDate ?? DateTime.now()),
//             hasValue: true,
//           ),
//           _buildInfoTile(
//             icon: Icons.flight_land,
//             title: "Numéro de vol d'arrivée",
//             subtitle: _traveller?.arrivalFlightNumber
//                     ?.replaceAll("withoutFlight", "Sans Vol") ??
//                 "Sans Vol",
//             hasValue: _traveller?.arrivalFlightNumber != null,
//           ),
//           _buildInfoTile(
//             icon: Icons.flight_takeoff,
//             title: "Numéro de vol de retour",
//             subtitle: _traveller?.departureFlightNumber
//                     ?.replaceAll("withoutFlight", "Sans Vol") ??
//                 "Sans Vol",
//             hasValue: _traveller?.departureFlightNumber != null,
//           ),
//           if (_traveller?.reservationDate != null)
//             _buildInfoTile(
//               icon: Icons.calendar_today,
//               title: "Date de réservation",
//               subtitle: DateFormat('dd MMMM yyyy à HH:mm', 'fr')
//                   .format(_traveller!.reservationDate!),
//               hasValue: true,
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoTile({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required bool hasValue,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: hasValue ? Colors.grey.shade50 : Colors.red.shade50,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: hasValue ? Colors.grey.shade200 : Colors.red.shade200,
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//          //   padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: hasValue
//                   ? const Color(0xFFEB5F52).withOpacity(0.1)
//                   : Colors.red.shade100,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               icon,
//               color: hasValue ? const Color(0xFFEB5F52) : Colors.red.shade600,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.grey.shade600,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: hasValue ? Colors.black87 : Colors.red.shade700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (!hasValue)
//             Icon(
//               Icons.warning_amber_rounded,
//               color: Colors.red.shade600,
//               size: 20,
//             ),
//         ],
//       ),
//     );
//   }

// }
// void _openMap(double latitude, double longitude) async {
//     final url =
//         'https://www.google.com/maps/search/?api=1&query=$longitude,$latitude';
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

// // Custom BlurEffect class (simplified version)
// class BlurEffect {
//   // This is a placeholder - in a real app you'd use BackdropFilter
// }
