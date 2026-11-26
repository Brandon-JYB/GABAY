import 'package:flutter_test/flutter_test.dart';

import 'package:gabay/core/city_barangays.dart';
import 'package:gabay/core/validators.dart';

void main() {
  group('Validators.fullName', () {
    test('rejects empty or whitespace-only input', () {
      expect(Validators.fullName(null), 'Full name is required');
      expect(Validators.fullName(''), 'Full name is required');
      expect(Validators.fullName('     '), 'Full name is required');
    });

    test('rejects names containing any numbers', () {
      expect(Validators.fullName('Juan123'), 'Full name cannot contain numbers');
      expect(Validators.fullName('Maria 2'), 'Full name cannot contain numbers');
      expect(Validators.fullName('007 Bond'), 'Full name cannot contain numbers');
    });

    test('rejects unrelated symbols, punctuation, or emojis', () {
      const msg =
          'Full name can only contain letters, spaces, periods, hyphens, and apostrophes';
      expect(Validators.fullName('Juan@Dela'), msg);
      expect(Validators.fullName('Maria#Clara'), msg);
      expect(Validators.fullName('Ana_Santos'), msg);
      expect(Validators.fullName('Jose!'), msg);
      expect(Validators.fullName('Juan 😊'), msg);
    });

    test('accepts valid names with letters, spaces, periods, hyphens, and apostrophes', () {
      expect(Validators.fullName('Juan Dela Cruz'), isNull);
      expect(Validators.fullName('  Ana Maria Santos  '), isNull);
      expect(Validators.fullName("Ma. Clara O'Connor-Reyes"), isNull);
    });
  });

  group('Validators.streetDetail', () {
    test('allows empty optional street detail and valid address characters', () {
      expect(Validators.streetDetail(null), isNull);
      expect(Validators.streetDetail(''), isNull);
      expect(Validators.streetDetail('   '), isNull);
      expect(Validators.streetDetail('#12-B Purok 4, Sitio Ibaba/Road 1'), isNull);
    });

    test('rejects unrelated symbols or emojis in street detail', () {
      const msg = 'Address details contain invalid characters';
      expect(Validators.streetDetail('Purok 1 @home'), msg);
      expect(Validators.streetDetail('Street \$100'), msg);
      expect(Validators.streetDetail('House 5 😊'), msg);
    });
  });

  group('Validators.birthDate', () {
    test('rejects null, pre-1900, and future dates', () {
      expect(Validators.birthDate(null), 'Birthdate is required');
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(
        Validators.birthDate(tomorrow),
        'Birthdate cannot be in the future',
      );
      expect(
        Validators.birthDate(DateTime(1899, 12, 31)),
        'Enter a valid birthdate from 1900 onwards',
      );
    });

    test('accepts today and valid past dates', () {
      final now = DateTime.now();
      expect(
        Validators.birthDate(DateTime(now.year, now.month, now.day)),
        isNull,
      );
      expect(Validators.birthDate(DateTime(2002, 5, 14)), isNull);
    });
  });

  group('Validators.genderStatus', () {
    test('accepts Male and Female and rejects empty/other values', () {
      expect(Validators.genderStatus(null), 'Gender status is required');
      expect(Validators.genderStatus(''), 'Gender status is required');
      expect(Validators.genderStatus('Other'), 'Select Male or Female');
      expect(Validators.genderStatus('Male1'), 'Select Male or Female');
      expect(Validators.genderStatus('Male'), isNull);
      expect(Validators.genderStatus('Female'), isNull);
    });
  });

  group('Validators.barangay & BatangasCityBarangays', () {
    test('rejects unrelated characters in barangay', () {
      expect(Validators.barangay(''), 'Barangay is required');
      expect(
        Validators.barangay('Alangilan@!'),
        'Barangay contains invalid characters',
      );
      expect(
        Validators.barangay('Alangilan#1'),
        'Barangay contains invalid characters',
      );
    });

    test('validates barangay case-insensitively and trims whitespace', () {
      expect(
        Validators.barangay('Unknown Brgy'),
        'Select or enter a valid barangay within Batangas City',
      );
      expect(Validators.barangay('  alangilan  '), isNull);
      expect(Validators.barangay('ALANGILAN'), isNull);
    });

    test('normalizes barangay and formats address cleanly', () {
      expect(
        BatangasCityBarangays.normalizeBarangay('  alangilan  '),
        'Alangilan',
      );
      expect(
        BatangasCityBarangays.formatAddress(
          barangay: 'alangilan',
          streetOrPurok: '   ',
        ),
        'Brgy. Alangilan, Batangas City',
      );
      expect(
        BatangasCityBarangays.formatAddress(
          barangay: 'alangilan',
          streetOrPurok: '  Purok 4, Zone 2  ',
        ),
        'Purok 4, Zone 2, Brgy. Alangilan, Batangas City',
      );
    });
  });

  group('Validators.email & passwords', () {
    test('validates strict email format', () {
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email('invalid-email'), 'Enter a valid email address');
      expect(Validators.email('user name@example.com'), 'Enter a valid email address');
      expect(Validators.email('user@@example.com'), 'Enter a valid email address');
      expect(Validators.email('  user@example.com  '), isNull);
    });

    test('validates newPassword and confirmPassword', () {
      expect(Validators.newPassword(''), 'Password is required');
      expect(
        Validators.newPassword('Pass 1234'),
        'Password cannot contain spaces or unsupported characters',
      );
      expect(
        Validators.newPassword('Pass1234😊'),
        'Password cannot contain spaces or unsupported characters',
      );
      expect(Validators.newPassword('abc12'), 'Use at least 8 characters');
      expect(
        Validators.newPassword('onlyletters'),
        'Include both letters and numbers',
      );
      expect(
        Validators.newPassword('12345678'),
        'Include both letters and numbers',
      );
      expect(Validators.newPassword('Password1'), isNull);

      final confirm = Validators.confirmPassword(() => 'Password1');
      expect(confirm(''), 'Confirm your password');
      expect(confirm('Password2'), 'Passwords do not match');
      expect(confirm('Password1'), isNull);
    });
  });
}