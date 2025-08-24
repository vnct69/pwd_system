// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'services/old api_service.dart';
import 'models/registration_data.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Horizontal Stepper - Registration',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const RegistrationWizard(),
    );
  }
}

/// Input formatter to format PWD ID into groups with hyphens (2-4-3-7)
class PwdIdInputFormatter extends TextInputFormatter {
  final List<int> groups = [2, 4, 3, 7];
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final filtered = newValue.text.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    var buffer = StringBuffer();
    int start = 0;

    for (var g in groups) {
      if (start >= filtered.length) break;
      final end = (start + g) <= filtered.length ? (start + g) : filtered.length;
      if (buffer.isNotEmpty) buffer.write('-');
      buffer.write(filtered.substring(start, end).toUpperCase());
      start = end;
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Enums for clarity
enum ApplicationType { New, Renewal }
enum Sex { Male, Female }
enum CivilStatus { Single, Married, Separated, LiveIn, Widowed }

class RegistrationWizard extends StatefulWidget {
  const RegistrationWizard({super.key});
  @override
  State<RegistrationWizard> createState() => _RegistrationWizardState();
}

class _RegistrationWizardState extends State<RegistrationWizard> {
  // --- Stepper state
  int _currentStep = 0;
  final int _totalSteps = 3;

  // --- Form keys for per-step validation
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(), // step 0 - application
    GlobalKey<FormState>(), // step 1 - personal
    GlobalKey<FormState>(), // step 2 - residence/contact
  ];

  // --- Controllers & state (step 1)
  ApplicationType _applicationType = ApplicationType.New;
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _dateAppliedController = TextEditingController();

  // Personal info controllers
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _suffixController = TextEditingController();

  DateTime? _dob;
  Sex? _sex;
  CivilStatus? _civilStatus;

  // Family background
  final TextEditingController _fatherLast = TextEditingController();
  final TextEditingController _fatherFirst = TextEditingController();
  final TextEditingController _fatherMiddle = TextEditingController();

  final TextEditingController _motherLast = TextEditingController();
  final TextEditingController _motherFirst = TextEditingController();
  final TextEditingController _motherMiddle = TextEditingController();

  // Residence & contact (step 2)
  final List<String> barangayList = [
    // Replace with the full 80 barangays when ready.
    'Alaminos', 'San Jose', 'Concepcion', 'San Pedro',
  ];
  String? _selectedBarangay;
  final TextEditingController _houseStreetController = TextEditingController();

  // Auto-filled location
  final String _municipality = 'San Pablo City';
  final String _province = 'Laguna';
  final String _region = 'IV-A (CALABARZON)';

  final TextEditingController _landlineController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set Date Applied to today's date and disable editing
    _dateAppliedController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    // Dispose controllers
    _pwdController.dispose();
    _dateAppliedController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _suffixController.dispose();
    _fatherLast.dispose();
    _fatherFirst.dispose();
    _fatherMiddle.dispose();
    _motherLast.dispose();
    _motherFirst.dispose();
    _motherMiddle.dispose();
    _houseStreetController.dispose();
    _landlineController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ----------------- VALIDATORS -----------------
  String? _validatePwd(String? value) {
    if (_applicationType == ApplicationType.Renewal) {
      if (value == null || value.trim().isEmpty) return 'PWD ID is required for Renewal';
      final pattern = RegExp(r'^[A-Za-z0-9]{2}\-[A-Za-z0-9]{4}\-[A-Za-z0-9]{3}\-[A-Za-z0-9]{7}$');
      if (!pattern.hasMatch(value)) return 'Invalid format: RR-PPMM-BBB-NNNNNNN';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) return 'Mobile number required';
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 11) return 'Mobile number must be 11 digits';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email required';
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  bool _validateStepFields(int step) {
    // Additional non-Form validations (like radios / DOB) are checked here.
    final form = _formKeys[step].currentState;
    if (form == null) return false;
    final isValid = form.validate();
    if (!isValid) return false;

    // Extra checks per step:
    if (step == 1) {
      // Personal info step needs sex, civil status, and DOB
      if (_sex == null) {
        _showSnack('Please select Sex.');
        return false;
      }
      if (_civilStatus == null) {
        _showSnack('Please select Civil Status.');
        return false;
      }
      if (_dob == null) {
        _showSnack('Please select Date of Birth.');
        return false;
      }
    }
    return true;
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // ----------------- STEP NAV -----------------
  void _goToStep(int step) {
    if (step == _currentStep) return;
    // only allow jumping forward if previous steps valid
    if (step > _currentStep) {
      // Try to validate all intermediate steps
      for (int s = _currentStep; s < step; s++) {
        if (!_validateStepFields(s)) return;
      }
    }
    setState(() => _currentStep = step);
  }

  void _onNext() {
    if (!_validateStepFields(_currentStep)) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep += 1);
    } else {
      _submitForm();
    }
  }

  void _onBack() {
    if (_currentStep > 0) setState(() => _currentStep -= 1);
  }

  // void _submitForm() {
  //   // Final collection & submission (hook to API)
  //   final summary = '''
  //     Application: ${_applicationType.name}
  //     Date Applied: ${_dateAppliedController.text}
  //     Name: ${_lastNameController.text}, ${_firstNameController.text}
  //     Birthday: ${_dob != null ? DateFormat('yyyy-MM-dd').format(_dob!) : 'N/A'}
  //     Mobile: ${_mobileController.text}
  //     Barangay: ${_selectedBarangay ?? 'N/A'}
  //     ''';
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text('Submit'),
  //       content: Text(summary),
  //       actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
  //     ),
  //   );
  // }

// Submit form data to API
void _submitForm() async {
  final formData = {
    "applicationType": _applicationType.name,
    "dateApplied": _dateAppliedController.text,
    "lastName": _lastNameController.text,
    "firstName": _firstNameController.text,
    "birthday": _dob != null ? DateFormat('yyyy-MM-dd').format(_dob!) : null,
    "mobile": _mobileController.text,
    "barangay": _selectedBarangay,
  };

  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5566/api/register'), // Replace with your Go Fiber endpoint
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(formData),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: Text('Form submitted successfully: ${result['message']}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
    } else {
      throw Exception('Failed to submit form: ${response.body}');
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(e.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}

  // ----------------- UI BUILD -----------------
  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / _totalSteps;
    return Scaffold(
      appBar: AppBar(title: const Text('PWD Registration')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // --- Horizontal Stepper Header ---
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        // Step circles & labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_totalSteps, (i) {
                            final isActive = i == _currentStep;
                            final isCompleted = i < _currentStep;
                            return Expanded(
                              child: InkWell(
                                onTap: () => _goToStep(i),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isCompleted ? Colors.blue : (isActive ? Colors.blueGrey : Colors.white),
                                        border: Border.all(color: Colors.blue),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: isCompleted
                                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                                            : Text('${i + 1}',
                                                style: TextStyle(
                                                  color: isActive ? Colors.white : Colors.blue,
                                                  fontWeight: FontWeight.bold,
                                                )),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      i == 0 ? 'Application' : (i == 1 ? 'Personal' : 'Address'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isActive ? Colors.black : Colors.black54,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 8),
                        // Progress bar under the circles
                        LinearProgressIndicator(value: progress, minHeight: 6),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // --- Step Content Area (switch) ---
              Expanded(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildStepContent(_currentStep),
                  ),
                ),
              ),

              // --- Controls (Back / Next) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: _currentStep == 0 ? null : _onBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _onNext,
                    icon: Icon(_currentStep == _totalSteps - 1 ? Icons.check : Icons.arrow_forward),
                    label: Text(_currentStep == _totalSteps - 1 ? 'Submit' : 'Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build form content by step index
  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _buildApplicationStep();
      case 1:
        return _buildPersonalStep();
      case 2:
        return _buildResidenceStep();
      default:
        return const SizedBox();
    }
  }

  // ---------- STEP 0: Application ----------
  Widget _buildApplicationStep() {
    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Type of Application', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: const Text('New'),
            leading: Radio<ApplicationType>(
              value: ApplicationType.New,
              groupValue: _applicationType,
              onChanged: (v) {
                setState(() {
                  _applicationType = v!;
                  if (_applicationType == ApplicationType.New) _pwdController.clear();
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Renewal'),
            leading: Radio<ApplicationType>(
              value: ApplicationType.Renewal,
              groupValue: _applicationType,
              onChanged: (v) => setState(() => _applicationType = v!),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _pwdController,
            enabled: _applicationType == ApplicationType.Renewal,
            decoration: const InputDecoration(
              labelText: 'Persons with Disability ID',
              hintText: 'RR-PPMM-BBB-NNNNNNN',
              border: OutlineInputBorder(),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
              PwdIdInputFormatter(),
            ],
            validator: _validatePwd,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _dateAppliedController,
            enabled: false,
            decoration: const InputDecoration(labelText: 'Date Applied', border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  // ---------- STEP 1: Personal Info ----------
  Widget _buildPersonalStep() {
    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Last name required' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'First name required' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _middleNameController,
            decoration: const InputDecoration(labelText: 'Middle Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _suffixController,
            decoration: const InputDecoration(labelText: 'Suffix', border: OutlineInputBorder()),
          ),

          const SizedBox(height: 12),

          const Text('Date of Birth'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000, 1, 1),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _dob = picked);
            },
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: _dob != null ? DateFormat('yyyy-MM-dd').format(_dob!) : 'Select date of birth',
                  border: const OutlineInputBorder(),
                ),
                validator: (_) => _dob == null ? 'Date of birth required' : null,
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text('Sex', style: TextStyle(fontWeight: FontWeight.w600)),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  leading: Radio<Sex>(value: Sex.Male, groupValue: _sex, onChanged: (v) => setState(() => _sex = v)),
                  title: const Text('Male'),
                ),
              ),
              Expanded(
                child: ListTile(
                  leading: Radio<Sex>(value: Sex.Female, groupValue: _sex, onChanged: (v) => setState(() => _sex = v)),
                  title: const Text('Female'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text('Civil Status', style: TextStyle(fontWeight: FontWeight.w600)),
          Wrap(
            runSpacing: 4,
            children: [
              RadioListTile<CivilStatus>(
                value: CivilStatus.Single,
                groupValue: _civilStatus,
                title: const Text('Single'),
                onChanged: (v) => setState(() => _civilStatus = v),
              ),
              RadioListTile<CivilStatus>(
                value: CivilStatus.Married,
                groupValue: _civilStatus,
                title: const Text('Married'),
                onChanged: (v) => setState(() => _civilStatus = v),
              ),
              RadioListTile<CivilStatus>(
                value: CivilStatus.Separated,
                groupValue: _civilStatus,
                title: const Text('Separated'),
                onChanged: (v) => setState(() => _civilStatus = v),
              ),
              RadioListTile<CivilStatus>(
                value: CivilStatus.LiveIn,
                groupValue: _civilStatus,
                title: const Text('Live-in'),
                onChanged: (v) => setState(() => _civilStatus = v),
              ),
              RadioListTile<CivilStatus>(
                value: CivilStatus.Widowed,
                groupValue: _civilStatus,
                title: const Text('Widow/er'),
                onChanged: (v) => setState(() => _civilStatus = v),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text('Family Background', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Father\'s Name', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: TextFormField(controller: _fatherLast, decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()))),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: _fatherFirst, decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()))),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: _fatherMiddle, decoration: const InputDecoration(labelText: 'Middle Name', border: OutlineInputBorder()))),
            ],
          ),

          const SizedBox(height: 12),

          const Text('Mother\'s Name', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: TextFormField(controller: _motherLast, decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()))),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: _motherFirst, decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()))),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: _motherMiddle, decoration: const InputDecoration(labelText: 'Middle Name', border: OutlineInputBorder()))),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- STEP 2: Residence & Contact ----------
  Widget _buildResidenceStep() {
    return Form(
      key: _formKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Residence Address', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _houseStreetController,
            decoration: const InputDecoration(labelText: 'House No & Street', border: OutlineInputBorder()),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'House No & Street required' : null,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedBarangay,
            items: barangayList.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
            onChanged: (v) => setState(() => _selectedBarangay = v),
            decoration: const InputDecoration(labelText: 'Barangay', border: OutlineInputBorder()),
            validator: (v) => v == null ? 'Select barangay' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(initialValue: _municipality, enabled: false, decoration: const InputDecoration(labelText: 'Municipality/City', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          TextFormField(initialValue: _province, enabled: false, decoration: const InputDecoration(labelText: 'Province', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          TextFormField(initialValue: _region, enabled: false, decoration: const InputDecoration(labelText: 'Region', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          const Text('Contact Details', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _landlineController,
            decoration: const InputDecoration(labelText: 'Landline (optional)', border: OutlineInputBorder()),
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _mobileController,
            decoration: const InputDecoration(labelText: 'Mobile Number (11 digits)', border: OutlineInputBorder()),
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: _validateMobile,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
        ],
      ),
    );
  }
}
