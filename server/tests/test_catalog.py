import copy
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import sys
import unittest

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from chart_engine import resolve_clock,eight_at,calculate


class CatalogEvidenceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.seed=json.loads((ROOT.parent/'catalog/seed.json').read_text())

    def test_every_record_hash_and_stable_identity(self):
        self.assertEqual(len(self.seed['people']),1000)
        ids=set()
        for row in self.seed['people']:
            p=row['profile'];self.assertTrue(p['synthetic'])
            self.assertNotIn(p['id'],ids);ids.add(p['id'])
            encoded=json.dumps(p,ensure_ascii=False,sort_keys=True,separators=(',',':'))
            self.assertEqual(row['hash'],hashlib.sha256(encoded.encode()).hexdigest())

    def test_all_birth_instants_and_pillars_recalculate_independently(self):
        for row in self.seed['people']:
            p=row['profile'];clock=resolve_clock(p['birth']);snapshot=p['chart']
            self.assertEqual(snapshot['clock']['utc'],clock['utc'].isoformat(),p['id'])
            self.assertEqual(snapshot['clock']['offsetSeconds'],clock['utcOffsetSeconds'],p['id'])
            seasonal,daily=eight_at(clock['calendar'],2),eight_at(clock['meanSolar'],2)
            pillars=[seasonal.getYear(),seasonal.getMonth(),daily.getDay()]
            if p['birth']['timeKnown']:pillars.append(daily.getTime())
            self.assertEqual(snapshot['pillars'],pillars,p['id'])

    def test_analysis_never_trusts_a_client_supplied_resolved_clock(self):
        p=next(x['profile'] for x in self.seed['people'] if x['profile']['id']=='catalog-0928')
        original={'birth':p['birth'],'basis':'meanSolar','sect':2}
        changed=copy.deepcopy(original)
        changed['birth']['resolvedClock']={'utc':'2000-01-01T00:00:00Z','offsetSeconds':0,
                                         'daylightSaving':False,'repeatedTime':False}
        now=datetime(2026,11,12,tzinfo=timezone.utc)
        a=calculate(original,now);b=calculate(changed,now)
        self.assertEqual(a['pillars'],b['pillars'])
        self.assertEqual(a['clock']['utc'],b['clock']['utc'])


if __name__=='__main__':unittest.main()
