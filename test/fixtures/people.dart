import 'package:lunar_social/models/profile.dart';

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
