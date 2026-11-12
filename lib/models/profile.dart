import 'package:timezone/timezone.dart' as tz;

class BirthPlace {
  final String name;
  final String zone;
  final double longitude;
  const BirthPlace(this.name, this.zone, this.longitude);
}

const birthPlaces = [
  BirthPlace('San Francisco, USA', 'America/Los_Angeles', -122.4194),
  BirthPlace('New York, USA', 'America/New_York', -74.006),
  BirthPlace('London, UK', 'Europe/London', -0.1276),
  BirthPlace('Paris, France', 'Europe/Paris', 2.3522),
  BirthPlace('Berlin, Germany', 'Europe/Berlin', 13.405),
  BirthPlace('Singapore', 'Asia/Singapore', 103.8198),
  BirthPlace('Tokyo, Japan', 'Asia/Tokyo', 139.6917),
  BirthPlace('Seoul, South Korea', 'Asia/Seoul', 126.978),
  BirthPlace('Shanghai, China', 'Asia/Shanghai', 121.4737),
  BirthPlace('Hong Kong', 'Asia/Hong_Kong', 114.1694),
  BirthPlace('Mumbai, India', 'Asia/Kolkata', 72.8777),
  BirthPlace('Dubai, UAE', 'Asia/Dubai', 55.2708),
  BirthPlace('Sydney, Australia', 'Australia/Sydney', 151.2093),
  BirthPlace('São Paulo, Brazil', 'America/Sao_Paulo', -46.6333),
  BirthPlace('Cape Town, South Africa', 'Africa/Johannesburg', 18.4241),
  BirthPlace('Toronto, Canada', 'America/Toronto', -79.3832),
];

class BirthData {
  final DateTime date;
  final int hour;
  final int minute;
  final bool timeKnown;
  final BirthPlace place;
  final ResolvedBirthInstant? resolvedClock;
  const BirthData(
      {required this.date,
      this.hour = 12,
      this.minute = 0,
      this.timeKnown = true,
      required this.place,
      this.resolvedClock});
  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'hour': hour,
        'minute': minute,
        'timeKnown': timeKnown,
        'place': place.name,
        'zone': place.zone,
        'longitude': place.longitude,
        if (resolvedClock != null) 'resolvedClock': resolvedClock!.toJson(),
      };
  factory BirthData.fromJson(Map<String, dynamic> json) => BirthData(
        date: DateTime.parse(json['date'] as String),
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        timeKnown: json['timeKnown'] as bool,
        place: BirthPlace(json['place'] as String, json['zone'] as String,
            (json['longitude'] as num).toDouble()),
        resolvedClock: json['resolvedClock'] == null
            ? null
            : ResolvedBirthInstant.fromJson(
                json['resolvedClock'] as Map<String, dynamic>),
      );
}

/// An authoritative server-resolved instant for a synthetic catalog birth.
/// The chart service independently recalculates birth inputs during analysis.
class ResolvedBirthInstant {
  final DateTime utc;
  final int offsetSeconds;
  final bool daylightSaving, repeatedTime;
  const ResolvedBirthInstant(
      this.utc, this.offsetSeconds, this.daylightSaving, this.repeatedTime);
  factory ResolvedBirthInstant.fromJson(Map<String, dynamic> value) {
    final utc = DateTime.parse(value['utc'] as String);
    final offset = value['offsetSeconds'];
    if (!utc.isUtc ||
        offset is! int ||
        offset.abs() > 86400 ||
        value['daylightSaving'] is! bool ||
        value['repeatedTime'] is! bool) {
      throw const FormatException('Invalid resolved birth instant.');
    }
    return ResolvedBirthInstant(utc, offset, value['daylightSaving'] as bool,
        value['repeatedTime'] as bool);
  }
  Map<String, dynamic> toJson() => {
        'utc': utc.toIso8601String(),
        'offsetSeconds': offsetSeconds,
        'daylightSaving': daylightSaving,
        'repeatedTime': repeatedTime
      };
}

class Person {
  final String id, name, location, occupation, bio, image, gender;
  final List<String> interests;
  final String countryCode, country, continent;
  final List<String> languages;
  final bool synthetic;
  final CatalogChart? catalogChart;
  final BirthData birth;
  const Person(
      {required this.id,
      required this.name,
      required this.location,
      required this.occupation,
      required this.bio,
      required this.image,
      required this.gender,
      required this.interests,
      required this.birth,
      this.countryCode = '',
      this.country = '',
      this.continent = '',
      this.languages = const [],
      this.synthetic = true,
      this.catalogChart});

  String get countryName =>
      country.isEmpty ? location.split(', ').last : country;

  factory Person.fromCatalog(Map<String, dynamic> value) {
    String text(String key, int max) {
      final v = value[key];
      if (v is! String || v.isEmpty || v.length > max) {
        throw const FormatException('Invalid catalog profile.');
      }
      return v;
    }

    List<String> list(String key) {
      final v = value[key];
      if (v is! List ||
          v.length > 10 ||
          v.any((x) => x is! String || x.isEmpty || x.length > 60)) {
        throw const FormatException('Invalid profile list.');
      }
      return List<String>.unmodifiable(v.cast<String>());
    }

    final id = text('id', 48),
        gender = text('gender', 20),
        countryCode = text('countryCode', 2);
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(id) ||
        !RegExp(r'^[A-Z]{2}$').hasMatch(countryCode) ||
        !['Women', 'Men', 'Non-binary'].contains(gender) ||
        value['synthetic'] != true) {
      throw const FormatException('Invalid catalog identity.');
    }
    final chartJson = value['chart'] as Map<String, dynamic>;
    if (chartJson['clock'] is! Map<String, dynamic>) {
      throw const FormatException('Catalog birth instant is missing.');
    }
    final birth = BirthData.fromJson({
      ...value['birth'] as Map<String, dynamic>,
      'resolvedClock': chartJson['clock'],
    });
    final birthText = (value['birth'] as Map<String, dynamic>)['date'];
    if (birthText is! String ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(birthText) ||
        birth.date.toIso8601String().split('T').first != birthText) {
      throw const FormatException('Invalid catalog date.');
    }
    tz.getLocation(birth.place.zone);
    final resolved = birth.resolvedClock!;
    if (resolved.utc.add(Duration(seconds: resolved.offsetSeconds)) !=
        DateTime.utc(
            birth.date.year,
            birth.date.month,
            birth.date.day,
            birth.timeKnown ? birth.hour : 12,
            birth.timeKnown ? birth.minute : 0)) {
      throw const FormatException(
          'Catalog birth instant differs from its inputs.');
    }
    if (birth.date.year < 1900 ||
        birth.date.isAfter(DateTime.now()) ||
        birth.hour < 0 ||
        birth.hour > 23 ||
        birth.minute < 0 ||
        birth.minute > 59 ||
        !birth.place.longitude.isFinite ||
        birth.place.longitude.abs() > 180) {
      throw const FormatException('Invalid catalog birth data.');
    }
    final person = Person(
        id: id,
        name: text('name', 80),
        location: text('location', 120),
        occupation: text('occupation', 100),
        bio: text('bio', 1200),
        image: '',
        gender: gender,
        interests: list('interests'),
        languages: list('languages'),
        birth: birth,
        countryCode: countryCode,
        country: text('country', 80),
        continent: text('continent', 40),
        catalogChart: CatalogChart.fromJson(
            value['chart'] as Map<String, dynamic>, birth.timeKnown));
    if (person.age < 18 || person.age > 120) {
      throw const FormatException('Catalog contains a non-adult profile.');
    }
    return person;
  }
  int ageAt(DateTime now) {
    final d = birth.date;
    return now.year -
        d.year -
        ((now.month < d.month || (now.month == d.month && now.day < d.day))
            ? 1
            : 0);
  }

  int get age => ageAt(DateTime.now());
}

class CatalogChart {
  final List<String> pillars;
  final DateTime solarTime;
  const CatalogChart(this.pillars, this.solarTime);
  factory CatalogChart.fromJson(Map<String, dynamic> value, bool timeKnown) {
    final p = value['pillars'];
    if (value['engine'] !=
            'lunar-python 1.4.9 / FatePair clock conventions v1' ||
        value['basis'] != 'meanSolar' ||
        value['sect'] != 2 ||
        p is! List ||
        p.length != (timeKnown ? 4 : 3) ||
        p.any((x) =>
            x is! String ||
            !RegExp(r'^[甲乙丙丁戊己庚辛壬癸][子丑寅卯辰巳午未申酉戌亥]$').hasMatch(x))) {
      throw const FormatException('Unsupported catalog chart.');
    }
    return CatalogChart(List<String>.unmodifiable(p.cast<String>()),
        DateTime.parse('${value['solarTime']}Z'));
  }
}

final demoBirth = BirthData(
    date: DateTime(1997, 6, 18), hour: 9, minute: 30, place: birthPlaces[0]);

final sampleComparisonBirth =
    BirthData(date: DateTime(1998, 5, 12), hour: 10, place: birthPlaces[0]);
