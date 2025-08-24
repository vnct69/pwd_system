import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pwd_upskill/utils/sanitizer.dart';
import '../../models/registration_data.dart';

class Step1Application extends StatefulWidget {
  final RegistrationData data;
  final VoidCallback onNext;
  final GlobalKey<FormState> formKey;

  const Step1Application({
    super.key,
    required this.formKey, 
    required this.data,
    required this.onNext,
  });

  @override
  State<Step1Application> createState() => _Step1ApplicationState();
}

class _Step1ApplicationState extends State<Step1Application> {
  final _pwdNumberController = TextEditingController();
  String? _applicantType;

  @override
  void initState() {
    super.initState();
    widget.data.createdAt = DateFormat('MM/dd/yyyy').format(DateTime.now());
    _applicantType = widget.data.applicantType ?? 'New';
    _pwdNumberController.text = widget.data.disabilityNumber ?? '';
  }

  @override
  void dispose() {
    _pwdNumberController.dispose();
    super.dispose();
  }

  // Auto-format PWD number as RR-PPMM-BBB-NNNNNNN
  String _formatPWDNumber(String input) {
    String digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    StringBuffer buffer = StringBuffer();
    List<int> sectionLengths = [2, 4, 3, 7];
    int start = 0;
    for (int i = 0; i < sectionLengths.length; i++) {
      int end = start + sectionLengths[i];
      if (digits.length > start) {
        buffer.write(digits.substring(start, digits.length < end ? digits.length : end));
        if (digits.length > end - 1 && i < sectionLengths.length - 1) {
          buffer.write('-');
        }
      }
      start = end;
    }
    return buffer.toString();
  }

  void _onPWDNumberChanged(String value) {
    String formatted = _formatPWDNumber(value);
    if (formatted != value) {
      _pwdNumberController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    widget.data.disabilityNumber = formatted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: widget.formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type of Applicant
            Row(
              children: [
                Text(
                  'Type of Applicant',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const Text(
                  '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('New Applicant'),
                    value: 'New',
                    groupValue: _applicantType,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    onChanged: (val) {
                      setState(() {
                        _applicantType = val;
                        widget.data.applicantType = val;
                        widget.data.disabilityNumber = '';
                        _pwdNumberController.text = '';
                        widget.data.disabilityNumber = sanitizeInput(val ?? '');
                      });
                    },
                  ),
                  const Divider(height: 0, thickness: 1),
                  RadioListTile<String>(
                    title: const Text('Renewal'),
                    value: 'Renewal',
                    groupValue: _applicantType,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    onChanged: (val) {
                      setState(() {
                        _applicantType = val;
                        widget.data.applicantType = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Persons with Disability Number
            Text(
              'Persons with Disability Number',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _pwdNumberController,
              enabled: _applicantType == 'Renewal',
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'RR-PPMM-BBB-NNNNNNN',
                labelStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.normal,
                ),
                filled: true,
                fillColor: _applicantType == 'Renewal'
                    ? Colors.white
                    : Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onChanged: _onPWDNumberChanged,
              validator: (val) {
                if (_applicantType == 'Renewal') {
                  if (val == null || val.isEmpty) {
                    return 'PWD number is required for renewal';
                  }
                  final pattern = RegExp(r'^\d{2}-\d{4}-\d{3}-\d{7}$');
                  if (!pattern.hasMatch(val)) {
                    return 'Format: RR-PPMM-BBB-NNNNNNN';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            // Date Applied
            Text(
              'Date Applied',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                // labelText: 'Date Applied',
                labelStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.normal,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              initialValue: widget.data.createdAt,
              readOnly: true,
              enabled: false,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 18),
            // Login link
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text.rich(
                  TextSpan(
                    text: 'Already have an account? ',
                    style: const TextStyle(fontSize: 14),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Implement navigation to login
                          },
                          child: Text(
                            'Login Here!',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
