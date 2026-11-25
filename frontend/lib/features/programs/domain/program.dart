/// One government health assistance program (a row of the `programs` table).
class Program {
  const Program({
    required this.id,
    required this.level,
    required this.office,
    required this.name,
    required this.description,
    required this.whoCanAvail,
    this.requirements = const [],
  });

  final int id;

  /// Governance level, e.g. "City LGU (Batangas City)".
  final String level;

  /// Implementing office or facility.
  final String office;

  final String name;
  final String description;
  final String whoCanAvail;

  /// One entry per document or step in the checklist.
  final List<String> requirements;

  factory Program.fromRow(Map<String, dynamic> row) => Program(
    id: row['id'] as int,
    level: (row['level'] as String?) ?? '',
    office: (row['office'] as String?) ?? '',
    name: (row['name'] as String?) ?? '',
    description: (row['description'] as String?) ?? '',
    whoCanAvail: (row['who_can_avail'] as String?) ?? '',
    requirements: [
      for (final r in (row['requirements'] as List?) ?? const [])
        r.toString(),
    ],
  );
}