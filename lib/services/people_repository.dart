import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profile.dart';

class PeopleCatalog {
  final List<Person> people;
  final String revision;
  const PeopleCatalog(this.people, this.revision);
}

/// The production source is a persisted D1 API; no local catalog fallback.
class PeopleRepository {
  static const defaultOrigin = String.fromEnvironment('FATEPAIR_CATALOG_URL',
      defaultValue: 'https://yuan-bazi-connections.dirtycomputer.chatgpt.site');
  final http.Client client;
  final Uri origin;
  PeopleRepository({http.Client? client, Uri? origin})
      : client = client ?? http.Client(),
        origin = origin ?? Uri.parse(defaultOrigin);

  Future<PeopleCatalog> load() async {
    final people = <Person>[], ids = <String>{};
    String? cursor, revision;
    int? total;
    for (var page = 0; page < 30; page++) {
      final uri = origin.resolve('/api/people').replace(queryParameters: {
        'limit': '200',
        if (cursor != null) 'after': cursor
      });
      final response = await client.get(uri, headers: {
        'Accept': 'application/json'
      }).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200 || response.bodyBytes.length > 2000000) {
        throw const FormatException('Catalog unavailable.');
      }
      final json =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (json['storage'] != 'cloudflare-d1' ||
          json['synthetic'] != true ||
          json['revision'] is! String ||
          (json['revision'] as String).isEmpty ||
          json['total'] is! int ||
          (json['total'] as int) > 5000 ||
          (json['total'] as int) < 0) {
        throw const FormatException('Invalid catalog response.');
      }
      revision ??= json['revision'] as String;
      total ??= json['total'] as int;
      if (revision != json['revision'] || total != json['total']) {
        throw const FormatException('Catalog changed while loading. Retry.');
      }
      final rows = json['people'];
      if (rows is! List || rows.length > 200) {
        throw const FormatException('Invalid catalog page.');
      }
      for (final row in rows) {
        final person = Person.fromCatalog(row as Map<String, dynamic>);
        if (!ids.add(person.id) ||
            (people.isNotEmpty && people.last.id.compareTo(person.id) >= 0)) {
          throw const FormatException(
              'Duplicate or unordered catalog profile.');
        }
        people.add(person);
      }
      final next = json['nextCursor'];
      if (next == null) {
        if (people.length != total) {
          throw const FormatException('Incomplete catalog.');
        }
        return PeopleCatalog(List.unmodifiable(people), revision);
      }
      if (next is! String ||
          rows.isEmpty ||
          next != people.last.id ||
          next == cursor) {
        throw const FormatException('Invalid catalog cursor.');
      }
      cursor = next;
    }
    throw const FormatException('Too many catalog pages.');
  }

  void close() => client.close();
}
