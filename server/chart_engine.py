"""Authoritative BaZi calculation using lunar-python; no LLM calendar arithmetic."""
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError
import math
from lunar_python import Solar, EightChar
from lunar_python.util import LunarUtil

ENGINE = 'lunar-python 1.4.9 / FatePair clock conventions v1'
STEMS, BRANCHES = '甲乙丙丁戊己庚辛壬癸', '子丑寅卯辰巳午未申酉戌亥'
ELEMENTS = ('wood', 'fire', 'earth', 'metal', 'water')
OFFSETS = dict(zip(STEMS, (1, 6, 10, 9, 10, 9, 7, 0, 4, 3)))


def rounded(value):
    return math.floor(value + .5) if value >= 0 else math.ceil(value - .5)


def equation_of_time(instant):
    start = datetime(instant.year, 1, 1, tzinfo=timezone.utc)
    days = (datetime(instant.year + 1, 1, 1, tzinfo=timezone.utc) - start).days
    day = (instant - start).total_seconds() / 86400
    g = 2 * math.pi / days * (day - .5)
    return 229.18 * (.000075 + .001868 * math.cos(g) - .032077 * math.sin(g)
                    - .014615 * math.cos(2*g) - .040849 * math.sin(2*g))


def resolve_clock(birth):
    if not isinstance(birth, dict) or not isinstance(birth.get('date'), str):
        raise ValueError('A birth date is required.')
    date = datetime.fromisoformat(birth['date']).date()
    if not 1900 <= date.year <= 2100:
        raise ValueError('Birth year must be between 1900 and 2100.')
    known = birth.get('timeKnown', True)
    if not isinstance(known, bool):
        raise ValueError('timeKnown must be a boolean.')
    hour = birth.get('hour', 12) if known else 12
    minute = birth.get('minute', 0) if known else 0
    if type(hour) is not int or type(minute) is not int:
        raise ValueError('Birth time must contain whole hours and minutes.')
    if not isinstance(birth.get('zone'), str) or not birth['zone']:
        raise ValueError('An IANA birth timezone is required.')
    if type(birth.get('longitude')) not in (int, float):
        raise ValueError('Birthplace longitude must be a number.')
    wall = datetime(date.year, date.month, date.day, hour, minute)
    zone = ZoneInfo(birth['zone'])
    longitude = float(birth['longitude'])
    if not math.isfinite(longitude) or not -180 <= longitude <= 180:
        raise ValueError('Birthplace longitude must be between -180 and 180.')
    candidates = []
    for fold in (0, 1):
        utc = wall.replace(tzinfo=zone, fold=fold).astimezone(timezone.utc)
        if utc.astimezone(zone).replace(tzinfo=None) == wall and utc not in candidates:
            candidates.append(utc)
    if not candidates:
        raise ValueError('This birth time did not exist because the clocks changed.')
    utc = min(candidates)
    mean = utc.replace(tzinfo=None) + timedelta(seconds=rounded(longitude * 240))
    eot = equation_of_time(utc)
    return {
        'utc': utc, 'civil': wall, 'meanSolar': mean,
        'apparentSolar': mean + timedelta(seconds=rounded(eot * 60)),
        'calendar': utc.replace(tzinfo=None) + timedelta(hours=8),
        'repeatedTime': len(candidates) > 1, 'equationMinutes': eot,
        'utcOffsetSeconds': int(utc.astimezone(zone).utcoffset().total_seconds()),
    }


def eight_at(value, sect):
    e = Solar.fromYmdHms(value.year, value.month, value.day, value.hour,
                         value.minute, value.second).getLunar().getEightChar()
    e.setSect(sect)
    return e


class HybridEightChar(EightChar):
    def __init__(self, seasonal, daily, sect):
        super().__init__(seasonal.getLunar())
        self.daily = daily
        self.setSect(sect)


for _method in ('getDay', 'getDayGan', 'getDayZhi', 'getDayGanIndex',
                'getDayZhiIndex', 'getTime', 'getTimeGan', 'getTimeZhi',
                'getTimeDiShi', 'getTaiXi', 'getDayXun', 'getDayXunKong',
                'getTimeXun', 'getTimeXunKong'):
    setattr(HybridEightChar, _method,
            lambda self, method=_method: getattr(self.daily, method)())


def pillar_detail(label, value, master):
    hidden = LunarUtil.ZHI_HIDE_GAN[value[1]]
    stage = (OFFSETS[master] + (1 if STEMS.index(master) % 2 == 0 else -1)
             * BRANCHES.index(value[1])) % 12
    return {'pillar': label, 'ganZhi': value,
            'tenGod': '日主' if label == 'Day' else LunarUtil.SHI_SHEN[master + value[0]],
            'hiddenStems': hidden,
            'hiddenTenGods': [LunarUtil.SHI_SHEN[master + s] for s in hidden],
            'growthStage': EightChar.CHANG_SHENG[stage],
            'naYin': LunarUtil.NAYIN[value], 'voidBranches': LunarUtil.getXunKong(value)}


def calculate(subject, now=None):
    if not isinstance(subject, dict) or not isinstance(subject.get('birth'), dict):
        raise ValueError('A complete birth profile is required.')
    birth = subject['birth']
    basis, sect, sex = subject.get('basis', 'meanSolar'), subject.get('sect', 2), subject.get('sex', 1)
    if (basis not in ('civil', 'meanSolar', 'apparentSolar')
            or type(sect) is not int or sect not in (1, 2)
            or type(sex) is not int or sex not in (0, 1)):
        raise ValueError('Invalid chart convention.')
    clock = resolve_clock(birth)
    e = HybridEightChar(eight_at(clock['calendar'], sect), eight_at(clock[basis], sect), sect)
    values = [e.getYear(), e.getMonth(), e.getDay()]
    if birth.get('timeKnown', True):
        values.append(e.getTime())
    master = e.getDayGan()
    pillars = [pillar_detail(label, v, master) for label, v in zip(('Year', 'Month', 'Day', 'Hour'), values)]
    palaces = {'fetalOrigin': e.getTaiYuan(), 'fetalBreath': e.getTaiXi()}
    fortune = {'approximate': not birth.get('timeKnown', True)}
    if birth.get('timeKnown', True):
        palaces.update(life=e.getMingGong(), body=e.getShenGong())
        yun = e.getYun(sex, 2)
        start = datetime.fromisoformat(yun.getStartSolar().toYmdHms()).replace(tzinfo=timezone(timedelta(hours=8)))
        fortune.update(start=start.astimezone(ZoneInfo(birth['zone'])).isoformat(),
                       forward=yun.isForward(), cycles=[
                           {'ganZhi': d.getGanZhi(), 'startYear': d.getStartYear(),
                            'endYear': d.getEndYear(), 'startAge': d.getStartAge()}
                           for d in yun.getDaYun(11) if d.getGanZhi()])
    instant = now or datetime.now(timezone.utc)
    if instant.tzinfo is None:
        raise ValueError('Current instant must include its timezone.')
    civil_now = instant.astimezone(ZoneInfo(birth['zone']))
    transit_birth = dict(birth, date=civil_now.date().isoformat(), hour=civil_now.hour,
                         minute=civil_now.minute, timeKnown=True)
    transit_clock = resolve_clock(transit_birth)
    t = HybridEightChar(eight_at(transit_clock['calendar'], sect),
                        eight_at(transit_clock[basis], sect), sect)
    return {'engine': ENGINE, 'timeBasis': basis, 'dayBoundary': '00:00' if sect == 2 else '23:00',
            'timeKnown': birth.get('timeKnown', True), 'dayMaster': master,
            'pillars': pillars, 'palaces': palaces, 'fortune': fortune,
            'clock': {k: v.isoformat() if isinstance(v, datetime) else v for k, v in clock.items()},
            'currentDate': civil_now.date().isoformat(),
            'currentPeriods': {key: pillar_detail(key, value, master) for key, value in
                               [('year', t.getYear()), ('month', t.getMonth()), ('today', t.getDay())]}}


def calculate_context(evidence, now=None):
    """Recompute every chart in a packet and reject altered or inconsistent pillars."""
    charts, seen = [], set()
    def visit(value):
        if isinstance(value, dict):
            subject = value.get('calculationInput')
            if subject is not None:
                import json
                identity = json.dumps(subject, ensure_ascii=False, sort_keys=True)
                if identity not in seen:
                    if len(charts) >= 2:
                        raise ValueError('A reading can compare at most two birth charts.')
                    seen.add(identity)
                    computed = calculate(subject, now)
                    supplied = value.get('pillars')
                    if supplied is not None:
                        a = [p['ganZhi'] for p in supplied]
                        b = [p['ganZhi'] for p in computed['pillars']]
                        if a != b:
                            raise ValueError('The chart differs from the verified calculation. Review the birth details and chart convention.')
                    charts.append({'profile': subject, 'calculatedEvidence': computed})
            for key, child in value.items():
                if key != 'calculationInput':
                    visit(child)
        elif isinstance(value, list):
            for child in value:
                visit(child)
    visit(evidence)
    return charts
