// lib/screens/registration/registration_screen.dart
import 'package:flutter/material.dart';

import '../steps/step1_application.dart';
import '../steps/step2_personal.dart';
import '../steps/step3_contact.dart';
import '../../models/registration_data.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final PageController _pageController = PageController();
  final RegistrationData _formData = RegistrationData();

  // Add form keys for each step
  // final _step1Key = GlobalKey<FormState>();
  // final _step2Key = GlobalKey<FormState>();
  // final _step3Key = GlobalKey<FormState>();

  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  int _currentStep = 0;

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _step1FormKey.currentState?.validate() ?? false;
      case 1:
        return _step2FormKey.currentState?.validate() ?? false;
      case 2:
        return _step3FormKey.currentState?.validate() ?? false;
      default:
        return false;
    }
  }

  void _saveCurrentStep() {
    switch (_currentStep) {
      case 0:
        _step1FormKey.currentState?.save();
        break;
      case 1:
        _step2FormKey.currentState?.save();
        break;
      case 2:
        _step3FormKey.currentState?.save();
        break;
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      _saveCurrentStep();
      if (_currentStep < 2) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _submitForm();
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitForm() {
    if (_validateCurrentStep()) {
      _saveCurrentStep();
      // TODO: Integrate with Go Fiber backend API
      debugPrint('Submitting: ${_formData.toJson()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      Step1Application(
        formKey: _step1FormKey,
        data: _formData,
        // onNext: _nextStep,
        onNext: () {
          if (_step1FormKey.currentState!.validate()) {
            setState(() => _currentStep = 1);
          }
        },
      ),
      Step2Personal(
        formKey: _step2FormKey,
        data: _formData,
        // onNext: _nextStep,
        // onBack: _prevStep,
        onNext: () {
          if (_step2FormKey.currentState!.validate()) {
            setState(() => _currentStep = 2);
          }
        },
        onBack: () => setState(() => _currentStep = 0),
      ),
      Step3Contact(
        formKey: _step3FormKey,
        data: _formData,
        // onBack: _prevStep,
        // onSubmit: _submitForm,
        onBack: () => setState(() => _currentStep = 1), 
        onSubmit: () {
          if (_step3FormKey.currentState!.validate()) {
            _submitForm(); // final submission
          }
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 700;
          return Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 1100,
              ),
              margin: EdgeInsets.symmetric(
                vertical: isMobile ? 0 : 32,
                horizontal: isMobile ? 0 : 8,
              ),
              child: isMobile
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          // Top: Blue panel
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B2A66),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'lib/assets/images/doh.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Person with Disability\n(PWD)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Registration Form',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Note: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            'Please fill up completely and correctly the required information before each item below. For items that are not associated to you, please put ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'N/A.',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Bottom: White panel
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                            child: Column(
                              children: [
                                LinearProgressIndicator(
                                  value: (_currentStep + 1) / steps.length,
                                  backgroundColor: Colors.grey[300],
                                  color: const Color(0xFF0B2A66),
                                  minHeight: 6,
                                ),
                                const SizedBox(height: 16),
                                steps[_currentStep],
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
                                    children: [
                                      if (_currentStep > 0)
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF0B2A66), // Use same color as Next
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          onPressed: _prevStep,
                                          child: const Text('Back'),
                                        ),
                                      if (_currentStep > 0) const SizedBox(width: 16), // Space between buttons
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0B2A66), // Use same color as Next
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        onPressed: _nextStep,
                                        child: Text(_currentStep == steps.length - 1 ? 'Submit' : 'Next'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        // Left Panel (col-lg-4)
                        Expanded(
                          flex: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B2A66),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'lib/assets/images/doh.png',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 32),
                                const Text(
                                  'Person with Disability\n(PWD)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Registration Form',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Note: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            'Please fill up completely and correctly the required information before each item below. For items that are not associated to you, please put ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'N/A.',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                        // Right Panel (col-lg-7)
                        Expanded(
                          flex: 7,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 40),
                            child: Column(
                              children: [
                                LinearProgressIndicator(
                                  value: (_currentStep + 1) / steps.length,
                                  backgroundColor: Colors.grey[300],
                                  color: const Color(0xFF0B2A66),
                                  minHeight: 6,
                                ),
                                const SizedBox(height: 24),
                                Expanded(
                                  child: PageView(
                                    controller: _pageController,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: steps,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
                                    children: [
                                      if (_currentStep > 0)
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF0B2A66), // Use same color as Next
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          onPressed: _prevStep,
                                          child: const Text('Back'),
                                        ),
                                      if (_currentStep > 0) const SizedBox(width: 16), // Space between buttons
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0B2A66), // Use same color as Next
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        onPressed: _nextStep,
                                        child: Text(_currentStep == steps.length - 1 ? 'Submit' : 'Next'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
