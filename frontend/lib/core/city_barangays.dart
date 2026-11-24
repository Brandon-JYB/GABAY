class BatangasCityBarangays {
  static const String cityName = 'Batangas City';

  static const List<String> all = [
    'Alangilan',
    'Balagtas',
    'Balete',
    'Banaba Center',
    'Banaba Ibaba',
    'Banaba Kanluran',
    'Banaba Silangan',
    'Barangay 1',
    'Barangay 2',
    'Barangay 3',
    'Barangay 4',
    'Barangay 5',
    'Barangay 6',
    'Barangay 7',
    'Barangay 8',
    'Barangay 9',
    'Barangay 10',
    'Barangay 11',
    'Barangay 12',
    'Barangay 13',
    'Barangay 14',
    'Barangay 15',
    'Barangay 16',
    'Barangay 17',
    'Barangay 18',
    'Barangay 19',
    'Barangay 20',
    'Barangay 21',
    'Barangay 22',
    'Barangay 23',
    'Barangay 24',
    'Bilogo',
    'Bolbok',
    'Bukal',
    'Calicanto',
    'Catandala',
    'Concepcion',
    'Conde Itaas',
    'Conde Labak',
    'Cuta',
    'Dalig',
    'Dela Paz',
    'Dela Paz Pulot Aplaya',
    'Dela Paz Pulot Itaas',
    'Domoclay',
    'Dumantay',
    'Gulod Itaas',
    'Gulod Labak',
    'Haligue Kanluran',
    'Haligue Silangan',
    'Ilihan',
    'Kumba',
    'Kumintang Ibaba',
    'Kumintang Ilaya',
    'Libjo',
    'Liponpon',
    'Maapas',
    'Mabacong',
    'Mahabang Dahilig',
    'Mahabang Parang',
    'Mahacot Kanluran',
    'Mahacot Silangan',
    'Malalim',
    'Malibayo',
    'Malitam',
    'Maruclap',
    'Pagkilatan',
    'Paharang Kanluran',
    'Paharang Silangan',
    'Pallocan Kanluran',
    'Pallocan Silangan',
    'Pinamucan',
    'Pinamucan Ibaba',
    'Pinamucan Silangan',
    'Sampaga',
    'San Agapito',
    'San Agustin Kanluran',
    'San Agustin Silangan',
    'San Andres',
    'San Antonio',
    'San Isidro',
    'San Jose Sico',
    'San Miguel',
    'San Pedro',
    'Santa Clara',
    'Santa Rita Aplaya',
    'Santa Rita Karsada',
    'Santo Domingo',
    'Santo Niño',
    'Simlong',
    'Sirang Lupa',
    'Sorosoro Ibaba',
    'Sorosoro Ilaya',
    'Sorosoro Karsada',
    'Tabangao Ambulong',
    'Tabangao Aplaya',
    'Tabangao Dao',
    'Talahib Pandayan',
    'Talahib Payapa',
    'Talumpok Kanluran',
    'Talumpok Silangan',
    'Tinga Itaas',
    'Tinga Labak',
    'Tulo',
    'Wawa',
  ];

  static String _collapseSpaces(String? raw) {
    if (raw == null) return '';
    return raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Matches typed input case-insensitively against known Batangas City
  /// barangays when possible, or preserves normalized custom input.
  static String normalizeBarangay(String? raw) {
    final normalized = _collapseSpaces(raw);
    if (normalized.isEmpty) return '';

    final lower = normalized.toLowerCase();
    for (final item in all) {
      if (item.toLowerCase() == lower) {
        return item;
      }
    }
    return normalized;
  }

  static bool isKnownBarangay(String? raw) {
    final normalized = _collapseSpaces(raw);
    if (normalized.isEmpty) return false;
    final lower = normalized.toLowerCase();
    return all.any((item) => item.toLowerCase() == lower);
  }

  static String formatAddress({
    required String barangay,
    String? streetOrPurok,
  }) {
    final cleanBarangay = normalizeBarangay(barangay);
    final cleanDetail = _collapseSpaces(streetOrPurok)
        .replaceAll(RegExp(r'^,+|,+$'), '')
        .trim();

    final brgyPart = cleanBarangay.isEmpty ? '' : 'Brgy. $cleanBarangay';
    return [cleanDetail, brgyPart, cityName]
        .where((part) => part.isNotEmpty)
        .join(', ');
  }
}