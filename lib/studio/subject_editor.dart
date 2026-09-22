import 'package:flutter/material.dart';
import 'package:lunar/lunar.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/profile.dart';
import '../services/birth_clock.dart';
import '../ui/design.dart';
import 'chart_engine.dart';

Future<ChartSubject?> editChartSubject(
        BuildContext context, ChartSubject subject) =>
    showDialog<ChartSubject>(
        context: context, builder: (_) => _SubjectEditor(subject: subject));

class _SubjectEditor extends StatefulWidget {
  final ChartSubject subject;
  const _SubjectEditor({required this.subject});
  @override
  State<_SubjectEditor> createState() => _SubjectEditorState();
}

class _SubjectEditorState extends State<_SubjectEditor> {
  final form = GlobalKey<FormState>();
  late TextEditingController name, date, time, city, longitude;
  late String zone, place;
  late bool known;
  bool lunar = false, leap = false;
  late int sex, sect;
  late TimeBasis basis;
  String? error;
  @override
  void initState() {
    super.initState();
    final s = widget.subject;
    name = TextEditingController(text: s.name);
    date = TextEditingController(text: dateLabel(s.birth.date));
    time = TextEditingController(
        text:
            '${s.birth.hour.toString().padLeft(2, '0')}:${s.birth.minute.toString().padLeft(2, '0')}');
    city = TextEditingController(text: s.birth.place.name);
    longitude = TextEditingController(text: s.birth.place.longitude.toString());
    zone = s.birth.place.zone;
    place = birthPlaces.any((p) => p.name == city.text)
        ? city.text
        : 'Custom birthplace';
    known = s.birth.timeKnown;
    sex = s.sex;
    sect = s.sect;
    basis = s.basis;
  }

  @override
  void dispose() {
    for (final c in [name, date, time, city, longitude]) {
      c.dispose();
    }
    super.dispose();
  }

  DateTime? parsedDate() {
    try {
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date.text)) return null;
      final n = date.text.split('-').map(int.parse).toList();
      if (n[0] < 1900 || n[0] > 2100) return null;
      if (lunar) {
        final month = LunarMonth.fromYm(n[0], leap ? -n[1] : n[1]);
        if (month == null || n[2] < 1 || n[2] > month.getDayCount()) {
          return null;
        }
        final s = Lunar.fromYmd(n[0], leap ? -n[1] : n[1], n[2]).getSolar();
        return DateTime(s.getYear(), s.getMonth(), s.getDay());
      }
      final d = DateTime(n[0], n[1], n[2]);
      return dateLabel(d) == date.text ? d : null;
    } catch (_) {
      return null;
    }
  }

  void switchCalendar(bool toLunar) {
    final current = parsedDate();
    setState(() {
      lunar = toLunar;
      leap = false;
      if (current != null) {
        if (toLunar) {
          final l = Solar.fromYmd(current.year, current.month, current.day)
              .getLunar();
          leap = l.getMonth() < 0;
          date.text =
              '${l.getYear()}-${l.getMonth().abs().toString().padLeft(2, '0')}-${l.getDay().toString().padLeft(2, '0')}';
        } else {
          date.text = dateLabel(current);
        }
      }
    });
  }

  void save() {
    if (!form.currentState!.validate()) return;
    final t = time.text.split(':');
    final subject = ChartSubject(
        name: name.text.trim(),
        sex: sex,
        sect: sect,
        basis: basis,
        birth: BirthData(
            date: parsedDate()!,
            hour: known ? int.parse(t[0]) : 12,
            minute: known ? int.parse(t[1]) : 0,
            timeKnown: known,
            place: BirthPlace(
                city.text.trim(), zone, double.parse(longitude.text))));
    try {
      ChartEngine().calculate(subject);
      Navigator.pop(context, subject);
    } catch (e) {
      setState(() => error = e is FormatException
          ? e.message
          : 'These details could not be calculated. Check your date, time and time zone.');
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
      insetPadding: const EdgeInsets.all(18),
      backgroundColor: canvas,
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 590),
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(26),
              child: Form(
                  key: form,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Expanded(
                              child: Text('Chart details',
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600))),
                          IconButton(
                              onPressed: () => Navigator.pop(context),
                              tooltip: 'Close chart editor',
                              icon: const Icon(Icons.close))
                        ]),
                        const Text(
                            'Choose the birth data and calculation convention explicitly.',
                            style: TextStyle(fontSize: 12, color: muted)),
                        const SizedBox(height: 22),
                        TextFormField(
                            controller: name,
                            decoration:
                                const InputDecoration(labelText: 'Chart name'),
                            maxLength: 40,
                            validator: (s) => s == null || s.trim().isEmpty
                                ? 'Enter a chart name.'
                                : null),
                        const SizedBox(height: 12),
                        SegmentedButton<bool>(segments: const [
                          ButtonSegment(value: false, label: Text('Gregorian')),
                          ButtonSegment(
                              value: true, label: Text('Chinese lunar'))
                        ], selected: {
                          lunar
                        }, onSelectionChanged: (s) => switchCalendar(s.first)),
                        const SizedBox(height: 16),
                        TextFormField(
                            controller: date,
                            decoration: InputDecoration(
                                labelText: lunar
                                    ? 'Lunar date · YYYY-MM-DD'
                                    : 'Birth date · YYYY-MM-DD',
                                helperText: 'Supported input years: 1900–2100'),
                            keyboardType: TextInputType.datetime,
                            validator: (_) => parsedDate() == null
                                ? 'Enter a valid date; check the lunar leap month.'
                                : null),
                        if (lunar)
                          CheckboxListTile(
                              value: leap,
                              onChanged: (v) => setState(() => leap = v!),
                              title: const Text('Leap lunar month',
                                  style: TextStyle(fontSize: 12)),
                              contentPadding: EdgeInsets.zero),
                        const SizedBox(height: 16),
                        TextFormField(
                            controller: time,
                            enabled: known,
                            keyboardType: TextInputType.datetime,
                            decoration: const InputDecoration(
                                labelText: 'Local birth time · HH:MM',
                                helperText:
                                    '24-hour time as recorded at the birthplace'),
                            validator: (v) => known &&
                                    !RegExp(r'^([01]\d|2[0-3]):[0-5]\d$')
                                        .hasMatch(v ?? '')
                                ? 'Use a valid 24-hour time.'
                                : null),
                        CheckboxListTile(
                            value: !known,
                            onChanged: (v) => setState(() => known = !v!),
                            title: const Text('Birth time unknown',
                                style: TextStyle(fontSize: 12)),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading),
                        DropdownButtonFormField<String>(
                            value: place,
                            isExpanded: true,
                            decoration:
                                const InputDecoration(labelText: 'Birthplace'),
                            items: [
                              ...birthPlaces.map((p) => p.name),
                              'Custom birthplace'
                            ]
                                .map((p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p,
                                        style: const TextStyle(fontSize: 12))))
                                .toList(),
                            onChanged: (v) => setState(() {
                                  place = v!;
                                  if (place != 'Custom birthplace') {
                                    final p = birthPlaces
                                        .firstWhere((p) => p.name == place);
                                    city.text = p.name;
                                    zone = p.zone;
                                    longitude.text = p.longitude.toString();
                                  }
                                })),
                        if (place == 'Custom birthplace') ...[
                          const SizedBox(height: 16),
                          TextFormField(
                              controller: city,
                              decoration: const InputDecoration(
                                  labelText: 'City / country'),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Enter a birthplace.'
                                  : null),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                              value: zone,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                  labelText: 'IANA time zone'),
                              items: (tz.timeZoneDatabase.locations.keys
                                      .toList()
                                    ..sort())
                                  .map((z) => DropdownMenuItem(
                                      value: z,
                                      child: Text(z,
                                          style:
                                              const TextStyle(fontSize: 11))))
                                  .toList(),
                              onChanged: (v) => setState(() => zone = v!)),
                          const SizedBox(height: 16),
                          TextFormField(
                              controller: longitude,
                              decoration: const InputDecoration(
                                  labelText: 'Longitude',
                                  helperText:
                                      'East positive; west negative. Longitude controls solar time.'),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true, signed: true),
                              validator: (s) {
                                final n = double.tryParse(s ?? '');
                                return n == null || !n.isFinite || n.abs() > 180
                                    ? 'Longitude must be between -180 and 180.'
                                    : null;
                              }),
                        ],
                        const SizedBox(height: 20),
                        DropdownButtonFormField<TimeBasis>(
                            value: basis,
                            isExpanded: true,
                            decoration: const InputDecoration(
                                labelText: 'Day / hour time basis'),
                            items: TimeBasis.values
                                .map((b) => DropdownMenuItem(
                                    value: b,
                                    child: Text(b.label,
                                        style: const TextStyle(fontSize: 12))))
                                .toList(),
                            onChanged: (v) => setState(() => basis = v!)),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                            value: sect,
                            isExpanded: true,
                            decoration: const InputDecoration(
                                labelText: 'Day boundary'),
                            items: const [
                              DropdownMenuItem(
                                  value: 2,
                                  child: Text('Midnight · 00:00',
                                      style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(
                                  value: 1,
                                  child: Text('Start of Zi hour · 23:00',
                                      style: TextStyle(fontSize: 12)))
                            ],
                            onChanged: (v) => setState(() => sect = v!)),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                            value: sex,
                            isExpanded: true,
                            decoration: const InputDecoration(
                                labelText: 'Traditional Da Yun convention'),
                            items: const [
                              DropdownMenuItem(
                                  value: 1,
                                  child: Text('Male chart convention',
                                      style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(
                                  value: 0,
                                  child: Text('Female chart convention',
                                      style: TextStyle(fontSize: 12)))
                            ],
                            onChanged: (v) => setState(() => sex = v!)),
                        const SizedBox(height: 12),
                        Text(
                            'Zone: $zone. Historical daylight saving is automatic. Repeated clock times use the earlier occurrence. True solar time adds a NOAA equation-of-time approximation. The Da Yun convention only controls traditional direction; it is separate from gender identity.',
                            style: const TextStyle(
                                fontSize: 10, color: muted, height: 1.7)),
                        if (error != null)
                          Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(error!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 12))),
                        const SizedBox(height: 22),
                        SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                                onPressed: save,
                                child: const Text('Calculate chart'))),
                      ])))));
}
