# Open-source engine audit and feature scope

Updated 2026-11-11. Calculation-library audit originally checked 2026-09-17. The product is an original English Flutter implementation using Wen Zhen as a functional reference; no proprietary Wen Zhen code, data, interpretations or visual assets are copied. No claim of output parity with an unpublished proprietary ruleset is made.

## Library decision

| Project | Verified role | Decision |
|---|---|---|
| [6tail/lunar-flutter](https://github.com/6tail/lunar-flutter), [pub.dev lunar](https://pub.dev/packages/lunar), 1.7.8 | MIT; four pillars, hidden stems, Ten Gods, growth stages, Na Yin, void, palaces, fortune cycles, lunar/solar conversion, solar terms and almanac | Integrated and pinned to 1.7.8. Original adapter combines physical seasonal boundaries with birthplace day/hour conventions. MIT notice included in `third_party/lunar-LICENSE`. |
| [6tail/tyme4dart](https://github.com/6tail/tyme4dart), 1.5.0 audited archive | MIT; modular calendar APIs; Dart ^3.5.4 | Compatible alternative, not added alongside overlapping lunar engine. A future migration needs fixture parity tests. |
| [RedSC1/bazi_core](https://github.com/RedSC1/bazi_core) | Live main [pubspec](https://raw.githubusercontent.com/RedSC1/bazi_core/main/pubspec.yaml) declares 1.1.0 / Dart ^3.10.0. Live [LICENSE](https://raw.githubusercontent.com/RedSC1/bazi_core/main/LICENSE) is MPL-2.0, despite cached README metadata describing MIT. | Not integrated: installed Dart is 3.6.0 and the current license differs from cached descriptions. No code copied. Reassess exact tagged source if adopted later. |
| [timezone](https://pub.dev/packages/timezone), resolved 0.10.1 | IANA zone database, historical UTC offsets and DST | Integrated. Dataset is bundled, not a live timezone service; updates need review and regression tests. |
| [yzhi1065-bot/wuyun-liuqi](https://github.com/yzhi1065-bot/wuyun-liuqi) | Repository license restricts commercial use | Not copied or integrated. Five Movements/Six Qi here is an original, limited rule implementation. |
| [Noto Sans SC](https://github.com/google/fonts/tree/main/ofl/notosanssc) | OFL-1.1 Chinese glyphs | Bundled subset generated from app + pinned lunar source characters, with upstream license. Manrope remains the English typeface. |

The app uses the calendar library for calculations; DeepSeek explains the resulting evidence. Generated interpretations are not the calculation engine and are not certified classical quotations.

## Functional coverage

| Requested area | Working implementation | Explicit limits |
|---|---|---|
| Four pillars / professional chart | Gregorian or Chinese lunar input including leap months; year/month/day/hour; hidden stems, stem/hidden Ten Gods, twelve growth stages, Na Yin, void, fetal origin/breath, life/body palaces | Study range in input: 1900–2100; no practitioner-certified parity with every school |
| Global birth times | Preset/custom birthplace, IANA zone, longitude; civil / mean solar / apparent solar time; DST history; midnight / 23:00 day boundary | No geocoder or coordinate map. Latitude is not required by this solar-time correction. Apparent solar uses NOAA approximation, not high-precision ephemeris. DST repeated times use earlier occurrence with a visible notice |
| Fortune cycles | Forward/reverse Da Yun and minute-based start calculation; decade, year, solar-term month and day selection; transit Ten Gods, hidden stems and growth; natal + transit relations and common stars | Transit snapshots use UTC+8. Age labels follow lunar nominal-age convention. Traditional male/female input is only the fortune-direction convention, separate from dating identity. Unknown time makes start timing approximate |
| Structural relations | Five stem combinations, four stem clashes; branch six combinations/clashes/harms/breaks, punishment pairs/self-punishment, complete three-harmony/seasonal/punishment groups | No claimed transformation, seasonal strength, half-combination completion, 格局/用神, blind-school verdict or event prediction |
| Symbolic stars | Heavenly noble, Literary, Prosperity, Yang blade, Void, Red phoenix, Heavenly joy, Peach blossom, Travel horse, Canopy, General, Kui gang; natal and selected transit targets; basis shown | Twelve common conventions, not an exhaustive star database. Kui gang is restricted to the natal day pillar; Yang blade only for yang stems; day stem used for noble; year/day anchors shown separately. Different schools differ |
| Relationship comparison | Two saved, editable charts; reciprocal day-stem Ten Gods; all implemented interactions crossing both charts; local and model readings | Two charts only; no multi-chart workspace, marriage verdict or scientifically validated compatibility score |
| Classical references | Three short public-domain excerpts, original English plain/professional commentary, source links | Starter library only, no full-text retrieval/RAG and no copied modern copyrighted translations |
| Five Movements / Six Qi | Annual movement, excess/insufficiency, governing heaven/earth, five host/guest movement sequences; six host/guest Qi stages and solar-term boundaries; interactive stage cards | Five-movement diagram shows order, not exact turnover instants or detailed 太少相生 rules. Six-Qi boundary convention uses listed solar terms in UTC+8. Cultural calendar only |
| Almanac / date selection | Month calendar, lunar date, term/day details, full daily and hourly Yi/Ji; early/late Rat split; next-30-day activity filter requiring Yi and absence from Ji | Calendar lookup, not personalized marriage/burial date selection. Some rare activities retain Chinese terms with a generic English label |
| Custom interpretation | Chart-verified lunar-python service with DeepSeek maximum reasoning, full session context, compatible custom endpoints, plain/professional styles, labelled reference fallback, cancellation and retry | No streaming, durable history, account authorization or global quota; a generated explanation may be wrong and needs practitioner review |
| Auxiliary tools | Not implemented: bone weighing, natal astronomical sky chart, celebrity birth database, wealth/blind-school analyses, Bagua/He Tu/Luo Shu study modules | These need independently reviewed rules/data/ephemerides; they are not represented as functioning features |

## Calculation conventions

1. Validate local wall time against the IANA zone. Reject DST gaps; identify folds and choose the earlier occurrence.
2. Compute UTC; year/month solar terms use UTC+8 as the library expects.
3. Day/hour use the selected clock. Mean solar = UTC + longitude × 4 minutes/degree. Apparent solar adds the [NOAA equation-of-time approximation](https://gml.noaa.gov/grad/solcalc/solareqns.PDF). Longitude correction never changes the physical solar-term instant.
4. Day boundary is selectable: midnight (lunar sect 2, default) or 23:00 (sect 1). Hour-stem late-Rat behavior follows the pinned engine.
5. Fortune start uses the physical birth instant and the preceding/following Jie (not Zhong Qi), lunar Yun sect 2. The start date is converted back to the birthplace timezone for display.
6. Unknown hour uses noon provisionally and omits hour pillar and hour-dependent palaces. On boundary dates, remaining results can still be uncertain.
7. Visible-element proportions are counts, not seasonal strength or useful-god selection. The existing dating harmony score remains an explicitly labeled cultural heuristic, independent of model prose.

## Sources for editorial rules

- [Di Tian Sui](https://ctext.org/wiki.pl?chapter=126492&if=gb&remap=gb): short Ten-Stem excerpt.
- [San Ming Tong Hui](https://ctext.org/wiki.pl?chapter=117077&if=en): Heavenly Noble mnemonic; chosen day-stem convention is explicit.
- [Su Wen, Tian Yuan Ji Da Lun](https://ctext.org/wiki.pl?chapter=69728&if=en&remap=gb): paired-stem annual movement framework.
- [DeepSeek API](https://api-docs.deepseek.com/): compatible chat API. Live authenticated `/models` in this session returned `deepseek-flash` and `deepseek-v4-pro`; the app discovers rather than assumes availability.
- [Ollama compatibility documentation](https://docs.ollama.com/api/openai-compatibility): configurable local `/v1` endpoint.
