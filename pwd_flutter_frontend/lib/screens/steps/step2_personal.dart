import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/registration_data.dart';
import 'package:pwd_upskill/utils/sanitizer.dart';
import 'package:pwd_upskill/utils/sanitized_text_form_field.dart';

class Step2Personal extends StatefulWidget {
  final RegistrationData data;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final GlobalKey<FormState> formKey;

  const Step2Personal({
    super.key,
    required this.formKey,
    required this.data,
    required this.onNext,
    required this.onBack,
  });

  

  @override
  State<Step2Personal> createState() => _Step2PersonalState();
}

class _Step2PersonalState extends State<Step2Personal> {
  late TextEditingController _dobController;

  @override
  void initState() {
    super.initState();
    _dobController = TextEditingController(text: widget.data.dateOfBirth);
  }

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: widget.formKey,
      child: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal Information Section
            Text(
              'Personal Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),

          // Last and First Name Section
          Row(
            children: [
              // Last Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Last Name',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 4),
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
                    SanitizedTextFormField(
                      hintText: 'Dela Cruz',
                      initialValue: widget.data.lastName,
                      onChanged: (val) => widget.data.lastName = val,
                      onSaved: (val) => widget.data.lastName = val,
                      validator: (val) =>
                        val == null || val.isEmpty ? 'Last name is required' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16), 

              // First Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'First Name',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 4),
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
                    SanitizedTextFormField(                     
                      hintText: 'Juan',
                      initialValue: widget.data.firstName,
                      onChanged: (val) => widget.data.firstName = val,
                      onSaved: (val) => widget.data.firstName = val,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'First name is required' : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Middle Name & Suffix Section
          Row(
            children: [
              // Middle Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Middle Name',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  SanitizedTextFormField(
                      hintText: 'Reyes',
                      initialValue: widget.data.middleName,
                      onChanged: (val) => widget.data.middleName = val,
                      onSaved: (val) => widget.data.middleName = val,
                      validator: (val) =>
                      val == null || val.isEmpty ? 'Middle name is required' : null,
                    ),
                  ],
                ),
              ),
              
              // space between Middle Name and Suffix
              const SizedBox(width: 16), 

              // Suffix
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suffix',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        hintText: 'Select Suffix',
                      ),
                      value: widget.data.suffix ?? 'None',
                      onChanged: (value) {
                        setState(() {
                          widget.data.suffix = value;
                        });
                      },
                      validator: null,
                      items: const [
                        DropdownMenuItem(value: 'None', child: Text('None')),
                        DropdownMenuItem(value: 'Jr.', child: Text('Jr.')),
                        DropdownMenuItem(value: 'Sr.', child: Text('Sr.')),
                        DropdownMenuItem(value: 'II', child: Text('II')),
                        DropdownMenuItem(value: 'III', child: Text('III')),
                        DropdownMenuItem(value: 'IV', child: Text('IV')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date of Birth
          Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date of Birth',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 4), 
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
          TextFormField(
            controller: _dobController,
            readOnly: true,
            decoration: const InputDecoration(
              hintText: 'YYYY-MM-DD',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  widget.data.dateOfBirth = DateFormat('yyyy-MM-dd').format(picked);
                  _dobController.text = widget.data.dateOfBirth!;
                });
              }
            },
            validator: (val) =>
                val == null || val.isEmpty ? 'Birthday is required' : null,
            onSaved: (val) => widget.data.dateOfBirth = val != null ? sanitizeInput(val) : null,
          ),
          const SizedBox(height: 16),
            
          // Gender/Sex
          Row(
            children: [
              Text(
                'Sex',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Radio buttons (Male & Female) with validation
          FormField<String>(
            validator: (value) {
              if (widget.data.gender == null || widget.data.gender!.isEmpty) {
                return 'Please select your gender';
              }
              return null;
            },
            builder: (formFieldState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Male
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: RadioListTile<String>(
                            title: const Text('Male'),
                            value: 'Male',
                            groupValue: widget.data.gender,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            onChanged: (val) {
                              setState(() {
                                widget.data.gender = val;
                              });
                              formFieldState.didChange(val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Female
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: RadioListTile<String>(
                            title: const Text('Female'),
                            value: 'Female',
                            groupValue: widget.data.gender,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            onChanged: (val) {
                              setState(() {
                                widget.data.gender = val;
                              });
                              formFieldState.didChange(val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Show error message
                  if (formFieldState.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        formFieldState.errorText ?? '',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // Civil Status
          Row(
            children: [
              Text(
                'Civil Status',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          // Radio buttons (Single, Married, Separated, Live-in, Widow/er) with validation
          FormField<String>(
            validator: (value) {
              if (widget.data.civilStatus == null || widget.data.civilStatus!.isEmpty) {
                return 'Please select your civil status';
              }
              return null;
            },
            builder: (formFieldState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Single & Separated
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: RadioListTile<String>(
                            title: const Text('Single'),
                            value: 'Single',
                            groupValue: widget.data.civilStatus,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            onChanged: (val) {
                              setState(() {
                                widget.data.civilStatus = val;
                              });
                              formFieldState.didChange(val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: RadioListTile<String>(
                            title: const Text('Separated'),
                            value: 'Separated',
                            groupValue: widget.data.civilStatus,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            onChanged: (val) {
                              setState(() {
                                widget.data.civilStatus = val;
                              });
                              formFieldState.didChange(val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Married & Live-in
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: RadioListTile<String>(
                            title: const Text('Married'),
                            value: 'Married',
                            groupValue: widget.data.civilStatus,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            onChanged: (val) {
                              setState(() {
                                widget.data.civilStatus = val;
                              });
                              formFieldState.didChange(val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: RadioListTile<String>(
                            title: const Text('Live-in'),
                            value: 'Live-in',
                            groupValue: widget.data.civilStatus,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            onChanged: (val) {
                              setState(() {
                                widget.data.civilStatus = val;
                              });
                              formFieldState.didChange(val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Widow/er
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: RadioListTile<String>(
                            title: const Text('Widow/er'),
                            value: 'Widow/er',
                            groupValue: widget.data.civilStatus,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            onChanged: (val) {
                              setState(() {
                                widget.data.civilStatus = val;
                              });
                              formFieldState.didChange(val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Show error if validation fails
                  if (formFieldState.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        formFieldState.errorText ?? '',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // Family Background Section
          Row(
            children: [
              Text(
                'Family Background',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                
              ),
              const SizedBox(width: 4),
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
          const SizedBox(height: 16),

          // Father's Name Section
          Text(
            'Father\'s Name',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          // Father's Name Row (Last, First, Middle)
          Row(
            children: [
              // Last Name
              Expanded(
                child: SanitizedTextFormField(
                  labelText: 'Last Name',
                  hintText: 'Dela Cruz',
                  initialValue: widget.data.fatherLastName,
                  onChanged: (val) => widget.data.fatherLastName = val,
                  onSaved: (val) => widget.data.fatherLastName = val,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'required' : null,
                ),
              ),
              const SizedBox(width: 12),

              // First Name
              Expanded(
                child: SanitizedTextFormField(
                  labelText: 'First Name',
                  hintText: 'Juan',
                  initialValue: widget.data.fatherFirstName,
                  onChanged: (val) => widget.data.fatherFirstName = val,
                  onSaved: (val) => widget.data.fatherFirstName = val,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'required' : null,
                ),
              ),
              const SizedBox(width: 12),

              // Middle Name
              Expanded(
                child: SanitizedTextFormField(
                  labelText: 'Middle Name',
                  hintText: 'Reyes',
                  initialValue: widget.data.fatherMiddleName,
                  onChanged: (val) => widget.data.fatherMiddleName = val,
                  onSaved: (val) => widget.data.fatherMiddleName = val,
                    validator: (val) =>
                      val == null || val.isEmpty ? 'required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mother's Name Section
          Text(
            'Mother\'s Name',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          // Mother's Name Row (Last, First, Middle)
          Row(
            children: [
              // Last Name
              Expanded(
                child: SanitizedTextFormField(
                    labelText: 'Last Name',
                    hintText: 'Dela Cruz',
                  initialValue: widget.data.motherLastName,
                  onChanged: (val) => widget.data.motherLastName = val,
                  onSaved: (val) => widget.data.motherLastName = val,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'required' : null,
                ),
              ),
              const SizedBox(width: 12),

              // First Name
              Expanded(
                child: SanitizedTextFormField(
                  labelText: 'First Name',
                  hintText: 'Juan',
                  initialValue: widget.data.motherFirstName,
                  onChanged: (val) => widget.data.motherFirstName = val,
                  onSaved: (val) => widget.data.motherFirstName = val,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'required' : null,
                ),
              ),
              const SizedBox(width: 12),

              // Middle Name
              Expanded(
                child: SanitizedTextFormField(
                  labelText: 'Middle Name',
                  hintText: 'Reyes',
                  initialValue: widget.data.motherMiddleName,
                  onChanged: (val) => widget.data.motherMiddleName = val,
                  onSaved: (val) => widget.data.motherMiddleName = val,
                    validator: (val) =>
                      val == null || val.isEmpty ? 'required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Guardian's Name Section
          Text(
            'Guardian\'s Name',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          // Guardian's Name Row (Last, First, Middle)
          Row(
            children: [
              // Last Name
              Expanded(
                child: SanitizedTextFormField(
                  labelText: 'Last Name',
                  hintText: 'Dela Cruz',
                  initialValue: widget.data.guardianLastName,
                  onChanged: (val) => widget.data.guardianLastName = val,
                  onSaved: (val) => widget.data.guardianLastName = val,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'required' : null,
                ),
              ),
              const SizedBox(width: 12),

              // First Name
              Expanded(
                child: SanitizedTextFormField(
                  labelText: 'First Name',
                  hintText: 'Juan',
                  initialValue: widget.data.guardianFirstName,
                  onChanged: (val) => widget.data.guardianFirstName = val,
                  onSaved: (val) => widget.data.guardianFirstName = val,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'required' : null,
                ),
              ),
              const SizedBox(width: 12),

              // Middle Name
              Expanded(
                child: SanitizedTextFormField(
                  labelText: 'Middle Name',
                  hintText: 'Reyes',
                  initialValue: widget.data.guardianMiddleName,
                  onChanged: (val) => widget.data.guardianMiddleName = val,
                  onSaved: (val) => widget.data.guardianMiddleName = val,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'required' : null,
                ),
              ),
            ],
          ),


          ],
        ),
      ),
      ),
    );
  }
}


