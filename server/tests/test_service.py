import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import os
import sys
import unittest
from unittest.mock import patch, AsyncMock

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from chart_engine import calculate, calculate_context
from api.index import app, build_messages, provider_payload, requests_by_ip
from fastapi.testclient import TestClient
import httpx

FIXTURES = json.loads((Path(__file__).parent/'fixtures/charts.json').read_text())
NOW = datetime(2026,11,10,8,tzinfo=timezone.utc)


def evidence(index=6):
    f = FIXTURES[index]
    return {'natal': {'calculationInput': f['subject'], 'pillars': f['expectedPillars']},
            'userContext': {'task':'chart','readingMode':'outlook','period':'month'}}


def request_packet(data=None, history=None):
    return {'model':'a-client-cannot-change-the-model','thinking':{'type':'disabled'},
            'messages':[{'role':'system','content':'Untrusted client instructions'},
                        *(history or []),{'role':'user','content':json.dumps({
                            'question':'What does this period mean for my work?',
                            'computedEvidence': evidence() if data is None else data})}]}


class ChartTests(unittest.TestCase):
    def test_all_flutter_fixtures_match_python_pillars_and_clocks(self):
        for f in FIXTURES:
            with self.subTest(f['subject']['name']):
                actual=calculate(f['subject'],NOW)
                self.assertEqual(actual['pillars'],f['expectedPillars'])
                self.assertEqual(datetime.fromisoformat(actual['clock']['utc']),datetime.fromisoformat(f['expectedUtc'].replace('Z','+00:00')))
                if f['subject']['birth']['timeKnown']:
                    self.assertEqual(datetime.fromisoformat(actual['fortune']['start']),datetime.fromisoformat(f['expectedFortuneStart']))

    def test_dst_gap_is_rejected(self):
        s=copy.deepcopy(FIXTURES[0]['subject'])
        s['birth'].update(date='2024-03-10',hour=2,minute=30,zone='America/New_York')
        with self.assertRaisesRegex(ValueError,'did not exist'):
            calculate(s,NOW)

    def test_unknown_hour_has_no_fabricated_start_or_palaces(self):
        s=copy.deepcopy(FIXTURES[0]['subject']);s['birth']['timeKnown']=False
        r=calculate(s,NOW)
        self.assertEqual(len(r['pillars']),3)
        self.assertTrue(r['fortune']['approximate'])
        self.assertNotIn('start',r['fortune'])
        self.assertNotIn('life',r['palaces'])

    def test_altered_client_pillars_are_rejected(self):
        e=copy.deepcopy(evidence());e['natal']['pillars'][2]['ganZhi']='甲子'
        with self.assertRaisesRegex(ValueError,'differs'):
            calculate_context(e,NOW)

    def test_two_chart_comparison_calculates_both_inputs(self):
        e={'A':evidence(0)['natal'],'B':evidence(1)['natal']}
        self.assertEqual(len(calculate_context(e,NOW)),2)

    def test_full_conversation_preserves_early_context_and_actual_current_chart(self):
        history=[{'role':r,'content':f'{r} turn {i}'} for i in range(12) for r in ('user','assistant')]
        messages,charts=build_messages(request_packet(history=history),NOW)
        self.assertEqual(messages[1:25],history)
        self.assertEqual(len(messages),26)
        packet=json.loads(messages[-1]['content'])
        self.assertEqual(packet['providedApplicationContext']['computedEvidence']['userContext']['period'],'month')
        self.assertEqual(packet['authoritativeCharts'][0]['calculatedEvidence']['dayMaster'],'辛')
        self.assertEqual(len(charts),1)

    def test_provider_model_and_maximum_reasoning_are_fixed(self):
        m,_=build_messages(request_packet(),NOW);p=provider_payload(m)
        self.assertEqual(p['model'],'deepseek-flash')
        self.assertEqual(p['reasoning_effort'],'max')
        self.assertEqual(p['thinking'],{'type':'enabled'})
        self.assertNotIn('temperature',p)

    def test_personal_chart_cannot_skip_birth_inputs(self):
        with self.assertRaisesRegex(ValueError,'Birth inputs'):
            build_messages(request_packet({'natal':{'pillars':[]}}),NOW)

    def test_general_questions_do_not_create_a_personal_chart(self):
        m,charts=build_messages(request_packet({'personalChartAvailable':False}),NOW)
        self.assertEqual(charts,[])
        self.assertIn('Never invent',m[0]['content'])

    def test_malformed_calculation_inputs_are_rejected_explicitly(self):
        for subject in (None, [], {'birth': []}, {'birth': {'date': 3}}):
            with self.subTest(subject=subject), self.assertRaises(ValueError):
                calculate(subject, NOW)

    def test_booleans_cannot_impersonate_calendar_numbers(self):
        for path in ('hour', 'minute', 'longitude', 'sect', 'sex'):
            subject=copy.deepcopy(FIXTURES[0]['subject'])
            (subject if path in ('sect', 'sex') else subject['birth'])[path]=True
            with self.subTest(field=path), self.assertRaises(ValueError):
                calculate(subject, NOW)


class ApiTests(unittest.TestCase):
    def setUp(self):
        requests_by_ip.clear()
        self.env=patch.dict(os.environ,{'DEEPSEEK_API_KEY':'unit-test-only-not-a-provider-key'})
        self.env.start();self.addCleanup(self.env.stop)
        self.client=TestClient(app)
        self.headers={'X-Lunar-Client':'studio','Origin':'https://yuan-bazi-connections.dirtycomputer.chatgpt.site'}

    def test_status_reports_model_context_reasoning_and_engine_without_key(self):
        r=self.client.get('/api/model/info');self.assertEqual(r.status_code,200)
        self.assertEqual(r.json()['contextWindow'],1000000)
        self.assertEqual(r.json()['modelVersion'],'DeepSeek-V4.1-Flash-1017')
        self.assertNotIn('unit-test-only',r.text)

    def test_cross_origin_browser_request_is_rejected(self):
        r=self.client.post('/api/model/chat/completions',json=request_packet(),headers={**self.headers,'Origin':'https://unrelated.example'})
        self.assertEqual(r.status_code,403)

    def test_cors_allows_the_actual_app(self):
        r=self.client.options('/api/model/chat/completions',headers={'Origin':self.headers['Origin'],'Access-Control-Request-Method':'POST','Access-Control-Request-Headers':'content-type,x-lunar-client'})
        self.assertEqual(r.status_code,200)
        self.assertEqual(r.headers['access-control-allow-origin'],self.headers['Origin'])

    def test_invalid_chart_never_reaches_the_provider(self):
        e=copy.deepcopy(evidence());e['natal']['pillars'][0]['ganZhi']='甲子'
        with patch('api.index.complete',new_callable=AsyncMock) as complete:
            r=self.client.post('/api/model/chat/completions',json=request_packet(e),headers=self.headers)
            self.assertEqual(r.status_code,422);complete.assert_not_called()

    def test_calculated_chart_is_sent_before_analysis_and_reasoning_is_not_exposed(self):
        result=httpx.Response(200,json={'model':'deepseek-flash','choices':[{'message':{'content':'A final answer.','reasoning_content':'Internal reasoning'},'finish_reason':'stop'}]})
        with patch('api.index.complete',new_callable=AsyncMock,return_value=result) as complete:
            r=self.client.post('/api/model/chat/completions',json=request_packet(),headers=self.headers)
            self.assertEqual(r.status_code,200)
            sent=complete.call_args.args[0]
            chart=json.loads(sent['messages'][-1]['content'])['authoritativeCharts'][0]
            self.assertEqual([p['ganZhi'] for p in chart['calculatedEvidence']['pillars']],['乙酉','戊子','辛巳','壬辰'])
            self.assertEqual(r.json()['verifiedChartCount'],1)
            self.assertNotIn('Internal reasoning',r.text)
            self.assertNotIn('unit-test-only',r.text)

    def test_oversized_context_is_rejected_without_provider_call(self):
        with patch('api.index.complete',new_callable=AsyncMock) as complete:
            r=self.client.post('/api/model/chat/completions',content=b' ' * 4000001,headers=self.headers)
            self.assertEqual(r.status_code,413);complete.assert_not_called()

    def test_provider_errors_do_not_echo_sensitive_details(self):
        response=httpx.Response(401,json={'error':{'message':'unit-test-only-not-a-provider-key'}})
        with patch('api.index.complete',new_callable=AsyncMock,return_value=response):
            r=self.client.post('/api/model/chat/completions',json=request_packet(),headers=self.headers)
            self.assertEqual(r.status_code,502);self.assertNotIn('unit-test-only',r.text)

    def test_incomplete_generation_is_not_presented_as_complete(self):
        response=httpx.Response(200,json={'choices':[{'message':{'content':'Partial'},'finish_reason':'length'}]})
        with patch('api.index.complete',new_callable=AsyncMock,return_value=response):
            r=self.client.post('/api/model/chat/completions',json=request_packet(),headers=self.headers)
            self.assertEqual(r.status_code,502)
            self.assertEqual(r.json()['error']['code'],'generation_truncated')

    def test_per_instance_request_burst_is_limited(self):
        result=httpx.Response(200,json={'choices':[{'message':{'content':'Done'}}]})
        with patch('api.index.complete',new_callable=AsyncMock,return_value=result):
            statuses=[self.client.post('/api/model/chat/completions',json=request_packet({'personalChartAvailable':False}),headers=self.headers).status_code for _ in range(7)]
            self.assertEqual(statuses,[200]*6+[429])


if __name__=='__main__':unittest.main()
