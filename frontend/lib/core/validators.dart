import 'city_barangays.dart';

class Validators {
  static final RegExp _fullNameAllowed = RegExp(r"^[A-Za-z\s.'-]+$");
  static final RegExp _streetAllowed = RegExp(r'^[A-Za-z0-9\s#.,/-]+$');
  static final RegExp _barangayAllowed = RegExp(r'^[A-Za-z0-9\s.()-]+$');
  static final RegExp _emailAllowed =
  RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
  static final RegExp _passwordAllowed = RegExp(r'^[\x21-\x7E]+$');

  static String? requiredField(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? fullName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Full name is required';
    if (RegExp(r'\d').hasMatch(trimmed)) {
      return 'Full name cannot contain numbers';
    }
    if (!_fullNameAllowed.hasMatch(trimmed)) {
      return 'Full name can only contain letters, spaces, periods, hyphens, and apostrophes';
    }
    return null;
  }

  static String? birthDate(DateTime? value) {
    if (value == null) return 'Birthdate is required';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final pickedDay = DateTime(value.year, value.month, value.day);
    if (pickedDay.isAfter(today)) {
      return 'Birthdate cannot be in the future';
    }
    if (pickedDay.isBefore(DateTime(1900, 1, 1))) {
      return 'Enter a valid birthdate from 1900 onwards';
    }
    return null;
  }

  static String? genderStatus(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return 'Gender status is required';
    }
    if (v != 'Male' && v != 'Female') {
      return 'Select Male or Female';
    }
    return null;
  }

  static String? streetDetail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null; // Optional field
    if (!_streetAllowed.hasMatch(trimmed)) {
      return 'Address details contain invalid characters';
    }
    return null;
  }

  static String? barangay(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Barangay is required';
    }
    if (!_barangayAllowed.hasMatch(trimmed)) {
      return 'Barangay contains invalid characters';
    }
    final existsInBatangasCity = BatangasCityBarangays.all.any(
          (brgy) => brgy.toLowerCase() == trimmed.toLowerCase(),
    );
    if (!existsInBatangasCity) {
      return 'Select or enter a valid barangay within Batangas City';
    }
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!_emailAllowed.hasMatch(v)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// For registration: minimum length, printable non-space chars, letters & numbers.
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (!_passwordAllowed.hasMatch(value)) {
      return 'Password cannot contain spaces or unsupported characters';
    }
    if (value.length < 8) return 'Use at least 8 characters';
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
    final hasDigit = RegExp(r'\d').hasMatch(value);
    if (!hasLetter || !hasDigit) return 'Include both letters and numbers';
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) {
    return (value) {
      if (value == null || value.isEmpty) return 'Confirm your password';
      return value == original() ? null : 'Passwords do not match';
    };
  }
}