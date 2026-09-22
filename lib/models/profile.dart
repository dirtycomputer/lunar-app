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
  const BirthData(
      {required this.date,
      this.hour = 12,
      this.minute = 0,
      this.timeKnown = true,
      required this.place});
  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'hour': hour,
        'minute': minute,
        'timeKnown': timeKnown,
        'place': place.name,
        'zone': place.zone,
        'longitude': place.longitude,
      };
  factory BirthData.fromJson(Map<String, dynamic> json) => BirthData(
        date: DateTime.parse(json['date'] as String),
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        timeKnown: json['timeKnown'] as bool,
        place: BirthPlace(json['place'] as String, json['zone'] as String,
            (json['longitude'] as num).toDouble()),
      );
}

class Person {
  final String id, name, location, occupation, bio, image, gender;
  final List<String> interests;
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
      required this.birth});
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

final demoBirth = BirthData(
    date: DateTime(1997, 6, 18), hour: 9, minute: 30, place: birthPlaces[0]);

final demoPeople = <Person>[
  Person(
      id: 'maya',
      name: 'Maya',
      location: 'San Francisco, USA',
      occupation: 'Designer & weekend wanderer',
      gender: 'Women',
      bio:
          'Collecting little moments, big books, and places with really good coffee. Looking for someone to take the scenic route with.',
      image: 'assets/portraits/maya.jpg',
      interests: ['Design', 'Hiking', 'Coffee'],
      birth: BirthData(
          date: DateTime(1998, 5, 12), hour: 10, place: birthPlaces[0])),
  Person(
      id: 'leo',
      name: 'Leo',
      location: 'London, UK',
      occupation: 'Architect with a curious mind',
      gender: 'Men',
      bio:
          'Usually sketching a building or planning my next trip. A good conversation is my favorite kind of adventure.',
      image: 'assets/portraits/leo.jpg',
      interests: ['Architecture', 'Travel', 'Music'],
      birth: BirthData(
          date: DateTime(1995, 9, 23), hour: 14, place: birthPlaces[2])),
  Person(
      id: 'sofia',
      name: 'Sofia',
      location: 'Paris, France',
      occupation: 'Creative soul, city explorer',
      gender: 'Women',
      bio:
          'A photographer who believes that the best things happen when you put your phone away. Let’s find a tiny gallery and get lost.',
      image: 'assets/portraits/sofia.jpg',
      interests: ['Photography', 'Art', 'Travel'],
      birth: BirthData(
          date: DateTime(1999, 3, 8), hour: 7, place: birthPlaces[3])),
  Person(
      id: 'noah',
      name: 'Noah',
      location: 'Sydney, Australia',
      occupation: 'Ocean lover & product builder',
      gender: 'Men',
      bio:
          'Early swims, late dinners, and ideas written on napkins. Happiest outside, especially with good company.',
      image: 'assets/portraits/noah.jpg',
      interests: ['Surfing', 'Cooking', 'Design'],
      birth: BirthData(
          date: DateTime(1996, 11, 17), hour: 16, place: birthPlaces[12])),
  Person(
      id: 'aisha',
      name: 'Aisha',
      location: 'Singapore',
      occupation: 'Storyteller, always discovering',
      gender: 'Women',
      bio:
          'Here for meaningful stories and spontaneous food adventures. Tell me about something that made you smile today.',
      image: 'assets/portraits/aisha.jpg',
      interests: ['Reading', 'Food', 'Yoga'],
      birth: BirthData(
          date: DateTime(1997, 8, 4), hour: 8, place: birthPlaces[5])),
  Person(
      id: 'ethan',
      name: 'Ethan',
      location: 'New York, USA',
      occupation: 'Music maker & everyday optimist',
      gender: 'Men',
      bio:
          'There is a playlist for every feeling. I love live jazz, slow Sundays, and people who are kind to strangers.',
      image: 'assets/portraits/ethan.jpg',
      interests: ['Music', 'Coffee', 'Art'],
      birth: BirthData(
          date: DateTime(1994, 12, 21), hour: 19, place: birthPlaces[1])),
];
