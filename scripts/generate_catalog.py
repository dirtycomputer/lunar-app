"""Create reproducible, explicitly synthetic adults for the persistent catalog.

Requires server/requirements.txt. Does not scrape, register or impersonate people.
The generated seed is server-only; requests read D1, never this file as a fallback.
"""
import calendar
from collections import Counter
from datetime import date
import hashlib
import json
from pathlib import Path
from zoneinfo import ZoneInfo
import random
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'server'))
from chart_engine import ENGINE, eight_at, resolve_clock

AS_OF = date(2026, 11, 12)
REVISION = 'synthetic-adults-2026-11-v1'
# Code, country, continent, city, zone, longitude, language, given names, surnames.
PLACES = [
 ('US','United States','North America','New York','America/New_York',-74.006,'en','Maya Ava Leah|Ethan Noah Leo','Reed Brooks Parker Chen'),
 ('GB','United Kingdom','Europe','London','Europe/London',-.1276,'en','Amelia Olivia Freya|Oliver Theo Harry','Clarke Patel Wilson Evans'),
 ('FR','France','Europe','Paris','Europe/Paris',2.3522,'fr','Sofia Camille Lea|Louis Jules Hugo','Martin Bernard Dubois Laurent'),
 ('DE','Germany','Europe','Berlin','Europe/Berlin',13.405,'de','Mila Hannah Emilia|Jonas Felix Lukas','Weber Fischer Hoffmann Becker'),
 ('ES','Spain','Europe','Madrid','Europe/Madrid',-3.7038,'es','Lucia Alba Carmen|Mateo Pablo Diego','Garcia Ramos Vega Santos'),
 ('IT','Italy','Europe','Rome','Europe/Rome',12.4964,'it','Giulia Sofia Elena|Luca Marco Matteo','Rossi Romano Ricci Costa'),
 ('PT','Portugal','Europe','Lisbon','Europe/Lisbon',-9.1393,'pt','Ines Beatriz Mariana|Joao Tiago Duarte','Silva Sousa Almeida Pereira'),
 ('NL','Netherlands','Europe','Amsterdam','Europe/Amsterdam',4.9041,'nl','Emma Lotte Noor|Daan Bram Ruben','Bakker Visser Smit Meijer'),
 ('SE','Sweden','Europe','Stockholm','Europe/Stockholm',18.0686,'sv','Elsa Astrid Linnea|Elias Oscar Nils','Lind Berg Holm Dahl'),
 ('PL','Poland','Europe','Warsaw','Europe/Warsaw',21.0122,'pl','Zofia Hanna Julia|Jan Adam Piotr','Nowak Kowalski Wisniewski Wojcik'),
 ('GR','Greece','Europe','Athens','Europe/Athens',23.7275,'el','Eleni Maria Niki|Nikos Andreas Kostas','Pappas Nikolaou Georgiou Antoniou'),
 ('TR','Türkiye','Asia','Istanbul','Europe/Istanbul',28.9784,'tr','Elif Zeynep Deniz|Emir Kerem Eren','Yilmaz Kaya Demir Aydin'),
 ('CA','Canada','North America','Toronto','America/Toronto',-79.3832,'en','Chloe Amina Sophie|Liam Gabriel Nathan','Tremblay Roy Campbell Wong'),
 ('MX','Mexico','North America','Mexico City','America/Mexico_City',-99.1332,'es','Valeria Ximena Renata|Santiago Emiliano Andres','Hernandez Flores Ruiz Mendoza'),
 ('CR','Costa Rica','North America','San Jose','America/Costa_Rica',-84.0907,'es','Daniela Catalina Paula|Sebastian David Adrian','Vargas Mora Solano Castro'),
 ('BR','Brazil','South America','Sao Paulo','America/Sao_Paulo',-46.6333,'pt','Ana Luiza Helena|Miguel Pedro Rafael','Souza Oliveira Lima Ribeiro'),
 ('AR','Argentina','South America','Buenos Aires','America/Argentina/Buenos_Aires',-58.3816,'es','Martina Julieta Agustina|Tomas Nicolas Joaquin','Gomez Diaz Romero Acosta'),
 ('CL','Chile','South America','Santiago','America/Santiago',-70.6693,'es','Antonia Isidora Maite|Vicente Benjamin Alonso','Rojas Munoz Silva Fuentes'),
 ('CN','China','Asia','Shanghai','Asia/Shanghai',121.4737,'zh','Mei Lian Yuting|Wei Jun Haoran','Chen Lin Wang Zhou'),
 ('JP','Japan','Asia','Tokyo','Asia/Tokyo',139.6917,'ja','Yui Hana Aoi|Ren Haruto Sota','Sato Tanaka Suzuki Watanabe'),
 ('KR','South Korea','Asia','Seoul','Asia/Seoul',126.978,'ko','Jisoo Minseo Haeun|Minjun Jiho Hyunwoo','Kim Lee Park Choi'),
 ('IN','India','Asia','Mumbai','Asia/Kolkata',72.8777,'hi','Anaya Priya Kavya|Aarav Arjun Rohan','Shah Rao Kapoor Mehta'),
 ('ID','Indonesia','Asia','Jakarta','Asia/Jakarta',106.8456,'id','Ayu Putri Sari|Rizky Aditya Dimas','Pratama Saputra Wijaya Santoso'),
 ('PH','Philippines','Asia','Manila','Asia/Manila',120.9842,'fil','Isabel Sofia Tala|Gabriel Paolo Mateo','Reyes Cruz Santos Garcia'),
 ('VN','Vietnam','Asia','Hanoi','Asia/Ho_Chi_Minh',105.8342,'vi','Linh Mai Thao|Minh Huy Khoa','Nguyen Tran Le Pham'),
 ('TH','Thailand','Asia','Bangkok','Asia/Bangkok',100.5018,'th','Mali Nara Ploy|Arthit Niran Chai','Srisai Boonmee Saengchai Thongdee'),
 ('MY','Malaysia','Asia','Kuala Lumpur','Asia/Kuala_Lumpur',101.6869,'ms','Alya Nur Iman|Amir Hakim Farid','Rahman Lim Tan Abdullah'),
 ('SG','Singapore','Asia','Singapore','Asia/Singapore',103.8198,'en','Aisha Jia Nur|Kai Amir Jun','Tan Lim Lee Rahman'),
 ('AU','Australia','Oceania','Sydney','Australia/Sydney',151.2093,'en','Isla Mia Zoe|Noah Jack Finn','Taylor Nguyen Kelly Morgan'),
 ('NZ','New Zealand','Oceania','Auckland','Pacific/Auckland',174.7633,'en','Maia Aria Anika|Nikau Oliver Theo','Williams Rangi King Harris'),
 ('NG','Nigeria','Africa','Lagos','Africa/Lagos',3.3792,'en','Ada Zainab Ife|Chidi Tunde Emeka','Okafor Bello Adeyemi Balogun'),
 ('GH','Ghana','Africa','Accra','Africa/Accra',-.187,'en','Ama Akua Abena|Kofi Kwame Kojo','Mensah Owusu Boateng Asante'),
 ('KE','Kenya','Africa','Nairobi','Africa/Nairobi',36.8219,'sw','Amani Wanjiku Zuri|Kamau Otieno Baraka','Mwangi Odhiambo Kiptoo Njoroge'),
 ('ZA','South Africa','Africa','Cape Town','Africa/Johannesburg',18.4241,'en','Lerato Naledi Thandi|Sipho Themba Lunga','Dlamini Nkosi Jacobs Mokoena'),
 ('EG','Egypt','Africa','Cairo','Africa/Cairo',31.2357,'ar','Nour Mariam Salma|Omar Youssef Karim','Hassan Ibrahim Mansour Farouk'),
 ('MA','Morocco','Africa','Casablanca','Africa/Casablanca',-7.5898,'ar','Amina Yasmine Imane|Amine Yassine Mehdi','Alaoui Idrissi Bennani Amrani'),
 ('AE','United Arab Emirates','Asia','Dubai','Asia/Dubai',55.2708,'ar','Fatima Hessa Layla|Khalid Saif Rashid','Nasser Hamdan Salem Mansoor'),
 ('NO','Norway','Europe','Oslo','Europe/Oslo',10.7522,'no','Nora Ingrid Frida|Emil Sander Henrik','Hansen Johansen Olsen Larsen'),
 ('UA','Ukraine','Europe','Kyiv','Europe/Kyiv',30.5234,'uk','Olena Iryna Kateryna|Andriy Dmytro Maksym','Melnyk Shevchenko Bondarenko Kovalenko'),
 ('PE','Peru','South America','Lima','America/Lima',-77.0428,'es','Camila Luciana Adriana|Diego Alonso Renato','Quispe Huaman Torres Castillo'),
]
INTERESTS = ['Hiking','Cooking','Photography','Reading','Live music','Gardening',
 'Cycling','Drawing','Travel','Dancing','Volunteering','Coffee','Museums','Yoga',
 'Swimming','Board games','Languages','Cinema','Pottery','Birdwatching','Theatre',
 'Baking','Technology','History','Running','Sailing','Poetry','Chess','Climbing',
 'Jazz','Nature walks','Ceramics','Astronomy','Community projects','Food markets']
ROLES = ['Teacher','Designer','Engineer','Librarian','Nurse','Researcher','Chef',
 'Architect','Entrepreneur','Translator','Photographer','Accountant','Musician',
 'Social worker','Urban planner','Veterinarian','Journalist','Craftsperson',
 'Software developer','Environmental scientist','Small business owner','Editor']
LEGACY = {('US',0):('maya','Maya',1998,5,12,10,0),
 ('US',1):('ethan','Ethan',1994,12,21,19,0),
 ('GB',0):('leo','Leo',1995,9,23,14,0),
 ('FR',0):('sofia','Sofia',1999,3,8,7,0),
 ('SG',0):('aisha','Aisha',1997,8,4,8,0),
 ('AU',0):('noah','Noah',1996,11,17,16,0)}


def build():
    rng = random.Random(20261112)
    ages = [rng.randint(a,b) for a,b,n in
            [(18,24,150),(25,34,250),(35,44,200),(45,54,150),(55,64,150),(65,75,100)]
            for _ in range(n)]
    rng.shuffle(ages)
    eligible = [i for i in range(1000) if (PLACES[i//25][0],i%25) not in LEGACY]
    unknown = set(rng.sample(eligible,100))
    people, names = [], set()
    for pi,p in enumerate(PLACES):
        code,country,continent,city,zone,longitude,language,given,surnames = p
        fixed = {j:('Women' if LEGACY[code,j][0] in ('maya','sofia','aisha') else 'Men')
                 for j in range(25) if (code,j) in LEGACY}
        remaining = ['Women']*10+['Men']*10+['Non-binary']*5
        for g in fixed.values():remaining.remove(g)
        rng.shuffle(remaining)
        genders = [fixed[j] if j in fixed else remaining.pop() for j in range(25)]
        used = Counter()
        for j in range(25):
            i = pi*25+j
            gender = genders[j]
            choices = given.split('|')[0 if gender=='Women' else 1].split()
            if gender=='Non-binary': choices = ['Alex','Sam','Jordan','Riley','Casey']
            serial = used[gender];used[gender]+=1
            first = choices[serial%len(choices)]
            last = surnames.split()[serial//len(choices)]
            name = first+' '+last
            ident = f'catalog-{i+1:04}'
            age = ages[i]
            month = rng.randint(1,12)
            year = AS_OF.year-age
            day = rng.randint(1,calendar.monthrange(year,month)[1])
            if (month,day)>(AS_OF.month,AS_OF.day):year-=1
            if day>calendar.monthrange(year,month)[1]:day=28
            hour,minute = rng.randint(6,20),rng.randint(0,59)
            if (code,j) in LEGACY:
                ident,name,year,month,day,hour,minute = LEGACY[code,j]
                gender = 'Women' if ident in ('maya','sofia','aisha') else 'Men'
            # Full names are unique even where unrelated synthetic families share one.
            if name in names:name = first+' '+chr(65+(pi%26))+'. '+last
            assert name not in names;names.add(name)
            birth_place = p if rng.random()<.8 or (code,j) in LEGACY else rng.choice(PLACES)
            birth = {'date':date(year,month,day).isoformat(),'hour':hour,'minute':minute,
                     'timeKnown':i not in unknown,'place':birth_place[3]+', '+birth_place[1],
                     'zone':birth_place[4],'longitude':birth_place[5]}
            if not birth['timeKnown']:birth.update(hour=12,minute=0)
            clock = resolve_clock(birth)
            seasonal,daily = eight_at(clock['calendar'],2),eight_at(clock['meanSolar'],2)
            pillars = [seasonal.getYear(),seasonal.getMonth(),daily.getDay()]
            if birth['timeKnown']:pillars.append(daily.getTime())
            interests = rng.sample(INTERESTS,3)
            languages = list(dict.fromkeys([language,'en']+([rng.choice(['fr','es','de','zh','pt','ja'])] if rng.random()<.35 else [])))
            role = rng.choice(ROLES)
            actual_age = AS_OF.year-year-((AS_OF.month,AS_OF.day)<(month,day))
            if actual_age<23:role=rng.choice(['Student','Apprentice','Early-career '+role.lower(),role])
            if actual_age>=65:role=rng.choice([role,'Retired '+role.lower(),'Community mentor'])
            bio = (f'My free time usually includes {interests[0].lower()} and {interests[1].lower()}. '
                   f'I would enjoy sharing {interests[2].lower()} and finding new places around {city}.')
            row = {'id':ident,'name':name,'location':city+', '+country,'countryCode':code,
                   'country':country,'continent':continent,'occupation':role,'gender':gender,
                   'bio':bio,'image':'','avatarSeed':ident,'interests':interests,
                   'languages':languages,'birth':birth,'synthetic':True,
                   'chart':{'engine':ENGINE,'basis':'meanSolar','sect':2,
                            'pillars':pillars,'solarTime':clock['meanSolar'].isoformat(),
                            'clock':{'utc':clock['utc'].isoformat(),
                                     'offsetSeconds':clock['utcOffsetSeconds'],
                                     'daylightSaving':bool(clock['utc'].astimezone(ZoneInfo(birth['zone'])).dst()),
                                     'repeatedTime':clock['repeatedTime']}}}
            encoded = json.dumps(row,ensure_ascii=False,sort_keys=True,separators=(',',':'))
            people.append({'profile':row,'hash':hashlib.sha256(encoded.encode()).hexdigest()})
    people.sort(key=lambda r:r['profile']['id'])
    return {'revision':REVISION,'asOf':AS_OF.isoformat(),'synthetic':True,
            'expectedCount':1000,'people':people}


if __name__=='__main__':
    dataset = build()
    path = ROOT/'catalog/seed.json'
    path.write_text(json.dumps(dataset,ensure_ascii=False,separators=(',',':'))+'\n')
    print(json.dumps({'profiles':len(dataset['people']),'countries':len(PLACES),
                      'unknownBirthTime':sum(not x['profile']['birth']['timeKnown'] for x in dataset['people']),
                      'genders':dict(Counter(x['profile']['gender'] for x in dataset['people']))}))
