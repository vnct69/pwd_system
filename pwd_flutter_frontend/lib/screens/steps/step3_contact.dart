import 'package:flutter/material.dart';
import '../../../models/registration_data.dart';

class Step3Contact extends StatefulWidget {
  final RegistrationData data;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final GlobalKey<FormState> formKey;

  const Step3Contact({
    super.key,
    required this.formKey,
    required this.data,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  State<Step3Contact> createState() => _Step3ContactState();
}

class _Step3ContactState extends State<Step3Contact> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Mobile'),
              initialValue: widget.data.mobileNo,
              onSaved: (val) => widget.data.mobileNo = val,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Mobile number is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email'),
              initialValue: widget.data.emailAddress,
              onSaved: (val) => widget.data.emailAddress = val,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Email is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Address'),
              initialValue: widget.data.houseNoAndStreet,
              onSaved: (val) => widget.data.houseNoAndStreet = val,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Address is required' : null,
            ),
          ],
        ),
      ),
    );
  }
}
