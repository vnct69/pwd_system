// lib/models/registration_data.dart
class RegistrationData {
  // Step 1: Application
  String? applicantType; // maps to applicant_type
  String? disabilityNumber;
  String? createdAt; // will be set automatically
  String? referenceNumber;

  // Step 2: Personal Info
  String? lastName;
  String? firstName;
  String? middleName;
  String? suffix;
  String? dateOfBirth; // send as "YYYY-MM-DD"
  String? gender;
  String? civilStatus;

  String? fatherLastName;
  String? fatherFirstName;
  String? fatherMiddleName;
  String? motherLastName;
  String? motherFirstName;
  String? motherMiddleName;
  String? guardianLastName;
  String? guardianFirstName;
  String? guardianMiddleName;

// Step 3 Disability Info
  String? typeOfDisability;
  String? causeOfDisability;

  // Step 4: Contact & Address
  String? houseNoAndStreet;
  String? barangay;
  String? municipality;
  String? province;
  String? region;
  String? landlineNo;
  String? mobileNo;
  String? emailAddress;

  String? educationalAttainment;
  String? statusOfEmployment;
  String? categoryOfEmployment;
  String? typeOfEmployment;
  String? occupation;
  String? otherOccupation;
  String? organizationAffiliated;
  String? contactPerson;
  String? officeAddress;
  String? officeTelNo;

  String? sssNo;
  String? gsisNo;
  String? pagibigNo;
  String? psnNo;
  String? philhealthNo;

  // Accomplished By
  String? accomplishByLastName;
  String? accomplishByFirstName;
  String? accomplishByMiddleName;

  Map<String, dynamic> toJson() {
    return {
      "applicant_type": applicantType,
      "disability_number": disabilityNumber,
      "created_at": createdAt,
      "reference_number": referenceNumber,
      "last_name": lastName,
      "first_name": firstName,
      "middle_name": middleName,
      "suffix": suffix,
      "date_of_birth": dateOfBirth,
      "gender": gender,
      "civil_status": civilStatus,
      "father_last_name": fatherLastName,
      "father_first_name": fatherFirstName,
      "father_middle_name": fatherMiddleName,
      "mother_last_name": motherLastName,
      "mother_first_name": motherFirstName,
      "mother_middle_name": motherMiddleName,
      "guardian_last_name": guardianLastName,
      "guardian_first_name": guardianFirstName,
      "guardian_middle_name": guardianMiddleName,
      "type_of_disability": typeOfDisability,
      "cause_of_disability": causeOfDisability,
      "house_no_and_street": houseNoAndStreet,
      "barangay": barangay,
      "municipality": municipality,
      "province": province,
      "region": region,
      "landline_no": landlineNo,
      "mobile_no": mobileNo,
      "email_address": emailAddress,
      "educational_attainment": educationalAttainment,
      "status_of_employment": statusOfEmployment,
      "category_of_employment": categoryOfEmployment,
      "type_of_employment": typeOfEmployment,
      "occupation": occupation,
      "other_occupation": otherOccupation,
      "organization_affiliated": organizationAffiliated,
      "contact_person": contactPerson,
      "office_address": officeAddress,
      "office_tel_no": officeTelNo,
      "sss_no": sssNo,
      "gsis_no": gsisNo,
      "pagibig_no": pagibigNo,
      "psn_no": psnNo,
      "philhealth_no": philhealthNo,
      "accomplish_by_last_name": accomplishByLastName,
      "accomplish_by_first_name": accomplishByFirstName,
      "accomplish_by_middle_name": accomplishByMiddleName,
    };
  }
}
