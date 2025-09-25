// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';


// class CodeLoginScreen extends ConsumerStatefulWidget {
//   /// Title of the screen
//   final String title;

//   /// Subtitle or instruction text
//   final String subtitle;

//   /// Email or phone number where code was sent
//   final String? sentTo;

//   /// Number of code digits
//   final int codeLength;

//   /// Whether to show resend code button
//   final bool showResendCode;

//   /// Initial countdown for resend button (in seconds)
//   final int resendCountdown;

//   /// Callback when code is submitted
//   final Future<bool> Function(String code) onCodeSubmitted;

//   /// Callback when resend code is pressed
//   final VoidCallback? onResendCode;

//   /// Custom primary color
//   final Color? primaryColor;

//   /// Custom background color
//   final Color? backgroundColor;

//   /// Custom app logo/icon
//   final Widget? logo;

//   /// Whether to auto-submit when all digits are entered
//   final bool autoSubmit;

//   /// Custom code input decoration
//   final InputDecoration? codeInputDecoration;

//   /// Custom button text for submit
//   final String submitButtonText;

//   /// Custom button text for resend
//   final String resendButtonText;

//   /// Custom button style for submit button
//   final ButtonStyle? submitButtonStyle;

//   /// Custom button style for resend button
//   final ButtonStyle? resendButtonStyle;

//   /// Whether to show back button
//   final bool showBackButton;

//   /// Callback when back button is pressed
//   final VoidCallback? onBackPressed;

//   /// Custom snackbar color for errors
//   final Color snackBarErrorColor;

//   /// Custom snackbar color for success
//   final Color snackBarSuccessColor;

//   /// Keyboard type for code input
//   final TextInputType keyboardType;

//   /// Whether to obscure the code input
//   final bool obscureCode;

//   /// Custom text style for title
//   final TextStyle? titleStyle;

//   /// Custom text style for subtitle
//   final TextStyle? subtitleStyle;

//   /// Custom text style for sent to text
//   final TextStyle? sentToStyle;

//   /// Whether to show loading indicator during submission
//   final bool showLoadingIndicator;

//   /// Custom form padding
//   final EdgeInsetsGeometry? formPadding;

//   /// Background image path (optional)
//   final String? backgroundImage;

//   /// Background image fit
//   final BoxFit backgroundImageFit;

//   /// Overlay color for background image
//   final Color? overlayColor;

//   /// Auto-focus first input field
//   final bool autoFocus;

//   /// Custom validation message
//   final String? validationMessage;

//   /// Whether to enable haptic feedback
//   final bool enableHapticFeedback;

//   /// Custom spacing between input fields
//   final double inputSpacing;

//   /// Input field width
//   final double inputWidth;

//   /// Input field height
//   final double inputHeight;

//   /// Custom border radius for input fields
//   final double inputBorderRadius;

//   const CodeLoginScreen({
//     super.key,
//     this.title = 'Enter Verification Code',
//     this.subtitle = 'Please enter the verification code sent to your device',
//     this.sentTo,
//     this.codeLength = 6,
//     this.showResendCode = true,
//     this.resendCountdown = 60,
//     required this.onCodeSubmitted,
//     this.onResendCode,
//     this.primaryColor,
//     this.backgroundColor,
//     this.logo,
//     this.autoSubmit = true,
//     this.codeInputDecoration,
//     this.submitButtonText = 'Verify Code',
//     this.resendButtonText = 'Resend Code',
//     this.submitButtonStyle,
//     this.resendButtonStyle,
//     this.showBackButton = true,
//     this.onBackPressed,
//     this.snackBarErrorColor = Colors.red,
//     this.snackBarSuccessColor = Colors.green,
//     this.keyboardType = TextInputType.number,
//     this.obscureCode = false,
//     this.titleStyle,
//     this.subtitleStyle,
//     this.sentToStyle,
//     this.showLoadingIndicator = true,
//     this.formPadding,
//     this.backgroundImage,
//     this.backgroundImageFit = BoxFit.cover,
//     this.overlayColor,
//     this.autoFocus = true,
//     this.validationMessage = 'Please enter a valid code',
//     this.enableHapticFeedback = true,
//     this.inputSpacing = 12.0,
//     this.inputWidth = 50.0,
//     this.inputHeight = 60.0,
//     this.inputBorderRadius = 12.0,
//   });

//   @override
//   ConsumerState<CodeLoginScreen> createState() => _CodeLoginScreenState();
// }

// class _CodeLoginScreenState extends ConsumerState<CodeLoginScreen>
//     with TickerProviderStateMixin {
//   late List<TextEditingController> _controllers;
//   late List<FocusNode> _focusNodes;
//   bool _isLoading = false;
//   int _resendCountdown = 0;
//   late AnimationController _shakeController;
//   late Animation<double> _shakeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controllers = List.generate(
//       widget.codeLength,
//       (index) => TextEditingController(),
//     );
//     _focusNodes = List.generate(widget.codeLength, (index) => FocusNode());

//     _resendCountdown = widget.resendCountdown;
//     if (widget.showResendCode && _resendCountdown > 0) {
//       _startResendCountdown();
//     }

//     // Auto-focus first field
//     if (widget.autoFocus && _focusNodes.isNotEmpty) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _focusNodes.first.requestFocus();
//       });
//     }

//     // Initialize shake animation
//     _shakeController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
//       CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
//     );
//   }

//   @override
//   void dispose() {
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     for (var focusNode in _focusNodes) {
//       focusNode.dispose();
//     }
//     _shakeController.dispose();
//     super.dispose();
//   }

//   void _startResendCountdown() {
//     Future.delayed(const Duration(seconds: 1), () {
//       if (mounted && _resendCountdown > 0) {
//         setState(() {
//           _resendCountdown--;
//         });
//         _startResendCountdown();
//       }
//     });
//   }

//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor:
//             isError ? widget.snackBarErrorColor : widget.snackBarSuccessColor,
//       ),
//     );
//   }

//   String _getCode() {
//     return _controllers.map((controller) => controller.text).join();
//   }

//   bool _isCodeComplete() {
//     return _getCode().length == widget.codeLength;
//   }

//   void _clearCode() {
//     for (var controller in _controllers) {
//       controller.clear();
//     }
//     if (_focusNodes.isNotEmpty) {
//       _focusNodes.first.requestFocus();
//     }
//   }

//   void _shakeInputs() {
//     if (widget.enableHapticFeedback) {
//       HapticFeedback.vibrate();
//     }
//     _shakeController.forward().then((_) {
//       _shakeController.reverse();
//     });
//   }

//   Future<void> _submitCode() async {
//     if (!_isCodeComplete()) {
//       _shakeInputs();
//       _showSnackBar(widget.validationMessage!, isError: true);
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       bool success = await widget.onCodeSubmitted(_getCode());

//       if (!mounted) return;

//       if (success) {
//         _showSnackBar('Code verified successfully!');
//         // Navigate back or to next screen
//         if (widget.onBackPressed != null) {
//           widget.onBackPressed!();
//         } else {
//           Navigator.of(context).pop(true);
//         }
//       } else {
//         _shakeInputs();
//         _clearCode();
//         _showSnackBar('Invalid code. Please try again.', isError: true);
//       }
//     } catch (e) {
//       if (!mounted) return;
//       _shakeInputs();
//       _clearCode();
//       _showSnackBar('Verification failed: ${e.toString()}', isError: true);
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   void _handleResendCode() {
//     if (widget.onResendCode != null) {
//       widget.onResendCode!();
//       setState(() {
//         _resendCountdown = widget.resendCountdown;
//       });
//       _startResendCountdown();
//       _showSnackBar('Verification code sent!');
//     }
//   }

//   void _onTextChanged(String value, int index) {
//     if (value.isNotEmpty) {
//       // Move to next field
//       if (index < widget.codeLength - 1) {
//         _focusNodes[index + 1].requestFocus();
//       } else {
//         // Last field, unfocus
//         _focusNodes[index].unfocus();
//       }

//       // Auto-submit if enabled and code is complete
//       if (widget.autoSubmit && _isCodeComplete()) {
//         _submitCode();
//       }
//     }
//   }

//   void _onBackspacePressed(int index) {
//     if (index > 0 && _controllers[index].text.isEmpty) {
//       _focusNodes[index - 1].requestFocus();
//     }
//   }

//   Widget _buildLogo() {
//     if (widget.logo == null) return const SizedBox.shrink();

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 32),
//       child: Center(child: widget.logo!),
//     );
//   }

//   Widget _buildTitle() {
//     return Text(
//       widget.title,
//       style:
//           widget.titleStyle ??
//           Theme.of(context).textTheme.headlineMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: widget.backgroundImage != null ? Colors.black87 : null,
//           ),
//       textAlign: TextAlign.center,
//     );
//   }

//   Widget _buildSubtitle() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 8, bottom: 16),
//       child: Text(
//         widget.subtitle,
//         style:
//             widget.subtitleStyle ??
//             Theme.of(context).textTheme.bodyMedium?.copyWith(
//               color:
//                   widget.backgroundImage != null
//                       ? Colors.black54
//                       : Colors.grey[600],
//             ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }

//   Widget _buildSentToText() {
//     if (widget.sentTo == null) return const SizedBox.shrink();

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 32),
//       child: Text(
//         'Code sent to ${widget.sentTo}',
//         style:
//             widget.sentToStyle ??
//             Theme.of(context).textTheme.bodySmall?.copyWith(
//               color: widget.primaryColor ?? Theme.of(context).primaryColor,
//               fontWeight: FontWeight.w500,
//             ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }

//   Widget _buildCodeInputs() {
//     return AnimatedBuilder(
//       animation: _shakeAnimation,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(_shakeAnimation.value, 0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: List.generate(
//               widget.codeLength,
//               (index) => Container(
//                 width: widget.inputWidth,
//                 height: widget.inputHeight,
//                 margin: EdgeInsets.symmetric(
//                   horizontal: widget.inputSpacing / 2,
//                 ),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(widget.inputBorderRadius),
//                   border: Border.all(
//                     color:
//                         _focusNodes[index].hasFocus
//                             ? (widget.primaryColor ??
//                                 Theme.of(context).primaryColor)
//                             : Colors.grey[300]!,
//                     width: _focusNodes[index].hasFocus ? 2 : 1,
//                   ),
//                   color:
//                       _focusNodes[index].hasFocus
//                           ? (widget.primaryColor ??
//                                   Theme.of(context).primaryColor)
//                               .withOpacity(0.1)
//                           : Colors.grey[50],
//                 ),
//                 child: TextField(
//                   controller: _controllers[index],
//                   focusNode: _focusNodes[index],
//                   textAlign: TextAlign.center,
//                   keyboardType: widget.keyboardType,
//                   obscureText: widget.obscureCode,
//                   maxLength: 1,
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   decoration:
//                       widget.codeInputDecoration ??
//                       const InputDecoration(
//                         border: InputBorder.none,
//                         counterText: '',
//                       ),
//                   onChanged: (value) {
//                     if (value.length > 1) {
//                       // Handle paste
//                       _handlePaste(value, index);
//                     } else {
//                       _onTextChanged(value, index);
//                     }
//                   },
//                   onTap: () {
//                     // Select all text when tapping
//                     _controllers[index].selection = TextSelection(
//                       baseOffset: 0,
//                       extentOffset: _controllers[index].text.length,
//                     );
//                   },
//                   inputFormatters: [
//                     FilteringTextInputFormatter.allow(
//                       widget.keyboardType == TextInputType.number
//                           ? RegExp(r'[0-9]')
//                           : RegExp(r'[a-zA-Z0-9]'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _handlePaste(String value, int startIndex) {
//     // Handle pasting multiple characters
//     for (
//       int i = 0;
//       i < value.length && (startIndex + i) < widget.codeLength;
//       i++
//     ) {
//       _controllers[startIndex + i].text = value[i];
//     }

//     // Focus the last filled field or next empty field
//     int lastIndex = (startIndex + value.length - 1).clamp(
//       0,
//       widget.codeLength - 1,
//     );
//     if (lastIndex < widget.codeLength - 1) {
//       _focusNodes[lastIndex + 1].requestFocus();
//     } else {
//       _focusNodes[lastIndex].unfocus();
//     }

//     // Auto-submit if enabled and code is complete
//     if (widget.autoSubmit && _isCodeComplete()) {
//       Future.delayed(const Duration(milliseconds: 100), () {
//         _submitCode();
//       });
//     }
//   }

//   Widget _buildSubmitButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: (_isLoading || !_isCodeComplete()) ? null : _submitCode,
//         style:
//             widget.submitButtonStyle ??
//             ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               backgroundColor: widget.primaryColor,
//             ),
//         child:
//             widget.showLoadingIndicator && _isLoading
//                 ? const CircularProgressIndicator(color: Colors.white)
//                 : Text(
//                   widget.submitButtonText,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//       ),
//     );
//   }

//   Widget _buildResendButton() {
//     if (!widget.showResendCode) return const SizedBox.shrink();

//     return Center(
//       child: TextButton(
//         onPressed: _resendCountdown > 0 ? null : _handleResendCode,
//         style: widget.resendButtonStyle,
//         child: Text(
//           _resendCountdown > 0
//               ? '${widget.resendButtonText} (${_resendCountdown}s)'
//               : widget.resendButtonText,
//           style: TextStyle(
//             color:
//                 _resendCountdown > 0
//                     ? Colors.grey
//                     : (widget.primaryColor ?? Theme.of(context).primaryColor),
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildForm() {
//     return Container(
//       padding: widget.formPadding ?? const EdgeInsets.all(24),
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color:
//             widget.backgroundImage != null
//                 ? Colors.white.withOpacity(0.9)
//                 : null,
//         borderRadius:
//             widget.backgroundImage != null ? BorderRadius.circular(16) : null,
//         boxShadow:
//             widget.backgroundImage != null
//                 ? [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     offset: const Offset(0, 5),
//                   ),
//                 ]
//                 : null,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildLogo(),
//           _buildTitle(),
//           _buildSubtitle(),
//           _buildSentToText(),
//           _buildCodeInputs(),
//           const SizedBox(height: 32),
//           _buildSubmitButton(),
//           const SizedBox(height: 16),
//           _buildResendButton(),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: widget.backgroundColor,
//       appBar: AppBar(
//         title: Text(widget.title),
//         backgroundColor:
//             widget.backgroundImage != null
//                 ? Colors.transparent
//                 : widget.primaryColor,
//         elevation: widget.backgroundImage != null ? 0 : null,
//         leading:
//             widget.showBackButton
//                 ? IconButton(
//                   icon: const Icon(Icons.arrow_back),
//                   onPressed: () {
//                     if (widget.onBackPressed != null) {
//                       widget.onBackPressed!();
//                     } else {
//                       Navigator.of(context).pop();
//                     }
//                   },
//                 )
//                 : null,
//       ),
//       extendBodyBehindAppBar: widget.backgroundImage != null,
//       body: Stack(
//         children: [
//           // Background Image
//           if (widget.backgroundImage != null) ...[
//             Positioned.fill(
//               child: Image.network(
//                 widget.backgroundImage!,
//                 fit: widget.backgroundImageFit,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     color: Theme.of(context).scaffoldBackgroundColor,
//                     child: const Center(
//                       child: Icon(
//                         Icons.image_not_supported,
//                         size: 100,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             // Overlay for better text readability
//             if (widget.overlayColor != null)
//               Positioned.fill(child: Container(color: widget.overlayColor)),
//           ],

//           // Code Input Form
//           SafeArea(
//             child: Center(child: SingleChildScrollView(child: _buildForm())),
//           ),
//         ],
//       ),
//     );
//   }
// }
