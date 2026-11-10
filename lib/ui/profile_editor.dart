import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../l10n/generated/app_localizations.dart';
import '../models/profile.dart';
import '../services/app_state.dart';
import '../services/platform_contracts.dart';
import 'design.dart';
import 'legal_center.dart';

Future<void> showProfileEditor(BuildContext context, AppState state) =>
    showDialog<void>(
        context: context, builder: (_) => ProfileEditor(state: state));

class ProfileEditor extends StatefulWidget {
  final AppState state;
  const ProfileEditor({super.key, required this.state});
  @override
  State<ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name, date, time, customCity, longitude;
  late String placeName, zone;
  late bool timeKnown;
  bool busy = false;
  bool agreed = false;
  String? error;
  bool get custom => placeName == 'Other birthplace';
  @override
  void initState() {
    super.initState();
    final birth = widget.state.birth;
    name = TextEditingController(
        text: widget.state.personalized ? widget.state.name : '');
    date = TextEditingController(text: _format(birth.date));
    time = TextEditingController(
        text:
            '${birth.hour.toString().padLeft(2, '0')}:${birth.minute.toString().padLeft(2, '0')}');
    timeKnown = birth.timeKnown;
    placeName = birthPlaces.any((p) => p.name == birth.place.name)
        ? birth.place.name
        : 'Other birthplace';
    zone = birth.place.zone;
    customCity = TextEditingController(text: custom ? birth.place.name : '');
    longitude = TextEditingController(
        text: custom ? birth.place.longitude.toString() : '');
  }

  String _format(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  DateTime? _parseDate(String? s) {
    if (s == null || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) return null;
    final result = DateTime.tryParse(s);
    return result != null && _format(result) == s ? result : null;
  }

  @override
  void dispose() {
    for (final c in [name, date, time, customCity, longitude]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!form.currentState!.validate()) return;
    if (!agreed) {
      setState(() => error = AppLocalizations.of(context)!.consentError);
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    final parts = time.text.split(':');
    final birthplace = custom
        ? BirthPlace(customCity.text.trim(), zone, double.parse(longitude.text))
        : birthPlaces.firstWhere((p) => p.name == placeName);
    try {
      final ok = await widget.state.updateProfile(
          name.text,
          BirthData(
              date: _parseDate(date.text)!,
              hour: timeKnown ? int.parse(parts[0]) : 12,
              minute: timeKnown ? int.parse(parts[1]) : 0,
              timeKnown: timeKnown,
              place: birthplace));
      if (!mounted) return;
      if (ok) {
        await widget.state.acceptConsent(
            'age-terms', legalDocById('terms')?.version ?? 'unknown');
        if (!mounted) return;
        Navigator.pop(context);
        showToast(context, AppLocalizations.of(context)!.energyReadyToast);
      } else {
        setState(() => error = AppLocalizations.of(context)!.saveFailed);
      }
    } on FormatException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => error = AppLocalizations.of(context)!.calcFailed);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final consentLink =
        const TextStyle(color: blue, decoration: TextDecoration.underline);
    return Dialog(
        insetPadding: const EdgeInsets.all(18),
        backgroundColor: canvas,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Form(
                    key: form,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const FlowerLogo(size: 30),
                            const Spacer(),
                            IconButton(
                                onPressed:
                                    busy ? null : () => Navigator.pop(context),
                                tooltip: l10n.actionClose,
                                icon: const Icon(Icons.close, size: 20))
                          ]),
                          const SizedBox(height: 12),
                          Text(l10n.flowBirthDetails,
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 25),
                          TextFormField(
                              controller: name,
                              textCapitalization: TextCapitalization.words,
                              maxLength: 30,
                              decoration: InputDecoration(
                                  labelText: l10n.firstName,
                                  hintText: l10n.nameHint,
                                  counterText: ''),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? l10n.nameRequired
                                  : null),
                          const SizedBox(height: 17),
                          TextFormField(
                              controller: date,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(
                                  labelText: l10n.dateLabel,
                                  hintText: 'YYYY-MM-DD',
                                  suffixIcon: IconButton(
                                      tooltip: l10n.chooseDate,
                                      icon: const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 19),
                                      onPressed: () async {
                                        final now = DateTime.now();
                                        final last = DateTime(
                                            now.year - 18, now.month, now.day);
                                        final d = _parseDate(date.text);
                                        final result = await showDatePicker(
                                            context: context,
                                            initialDate: d != null &&
                                                    !d.isAfter(last) &&
                                                    d.year >= 1900
                                                ? d
                                                : DateTime(1997, 6, 18),
                                            firstDate: DateTime(1900),
                                            lastDate: last);
                                        if (result != null) {
                                          date.text = _format(result);
                                        }
                                      })),
                              validator: (s) {
                                final d = _parseDate(s);
                                if (d == null) {
                                  return l10n.dateInvalid;
                                }
                                final now = DateTime.now();
                                final cutoff =
                                    DateTime(now.year - 18, now.month, now.day);
                                if (d.isAfter(cutoff)) {
                                  return l10n.adultsOnly;
                                }
                                if (d.year < 1900) {
                                  return l10n.yearMin;
                                }
                                return null;
                              }),
                          const SizedBox(height: 17),
                          TextFormField(
                              controller: time,
                              enabled: timeKnown,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(
                                  labelText: l10n.timeLabel,
                                  hintText: 'HH:MM (24-hour)',
                                  suffixIcon:
                                      const Icon(Icons.schedule, size: 19)),
                              validator: (s) => timeKnown &&
                                      !RegExp(r'^([01]\d|2[0-3]):[0-5]\d$')
                                          .hasMatch(s ?? '')
                                  ? l10n.timeInvalid
                                  : null),
                          CheckboxListTile(
                              value: !timeKnown,
                              onChanged: (v) => setState(() => timeKnown = !v!),
                              title: Text(l10n.noTimeCheckbox,
                                  style: const TextStyle(fontSize: 11)),
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true),
                          if (!timeKnown)
                            Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Text(l10n.noTimeNote,
                                    style: const TextStyle(
                                        fontSize: 11, color: muted))),
                          DropdownButtonFormField<String>(
                              value: placeName,
                              isExpanded: true,
                              decoration:
                                  InputDecoration(labelText: l10n.birthplace),
                              items: [
                                ...birthPlaces.map((p) => p.name),
                                'Other birthplace'
                              ]
                                  .map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(
                                          p == 'Other birthplace'
                                              ? l10n.otherBirthplace
                                              : p,
                                          style:
                                              const TextStyle(fontSize: 13))))
                                  .toList(),
                              onChanged: (s) => setState(() {
                                    placeName = s!;
                                    if (!custom) {
                                      zone = birthPlaces
                                          .firstWhere((p) => p.name == s)
                                          .zone;
                                    }
                                  })),
                          if (custom) ...[
                            const SizedBox(height: 17),
                            TextFormField(
                                controller: customCity,
                                decoration: InputDecoration(
                                    labelText: l10n.cityCountry),
                                validator: (s) => s == null || s.trim().isEmpty
                                    ? l10n.cityRequired
                                    : null),
                            const SizedBox(height: 17),
                            DropdownButtonFormField<String>(
                                value: zone,
                                isExpanded: true,
                                decoration:
                                    InputDecoration(labelText: l10n.tzLabel),
                                items: (tz.timeZoneDatabase.locations.keys
                                        .toList()
                                      ..sort())
                                    .map((z) => DropdownMenuItem(
                                        value: z,
                                        child: Text(z,
                                            style:
                                                const TextStyle(fontSize: 12))))
                                    .toList(),
                                onChanged: (s) => setState(() => zone = s!)),
                            const SizedBox(height: 17),
                            TextFormField(
                                controller: longitude,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true, signed: true),
                                decoration: InputDecoration(
                                    labelText: l10n.longitude,
                                    helperText: l10n.lonHint),
                                validator: (s) {
                                  final n = double.tryParse(s ?? '');
                                  return n == null ||
                                          !n.isFinite ||
                                          n < -180 ||
                                          n > 180
                                      ? l10n.lonInvalid
                                      : null;
                                }),
                          ],
                          const SizedBox(height: 16),
                          Text(l10n.tzNote(zone),
                              style: const TextStyle(
                                  fontSize: 10, color: muted, height: 1.7)),
                          const SizedBox(height: 18),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lock_outline,
                                    color: green, size: 16),
                                const SizedBox(width: 9),
                                Expanded(
                                    child: Text(l10n.privacyNote,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: muted,
                                            height: 1.7))),
                              ]),
                          const SizedBox(height: 10),
                          CheckboxListTile(
                              value: agreed,
                              onChanged: (v) => setState(() {
                                    agreed = v ?? false;
                                    if (agreed) error = null;
                                  }),
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              title: Text.rich(TextSpan(
                                  style: const TextStyle(
                                      fontSize: 11, height: 1.6),
                                  children: [
                                    TextSpan(text: l10n.consentLead),
                                    TextSpan(
                                        text: l10n.linkTerms,
                                        style: consentLink,
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => showLegalDocument(
                                              context, legalDocById('terms')!)),
                                    TextSpan(text: l10n.consentAnd),
                                    TextSpan(
                                        text: l10n.linkPrivacy,
                                        style: consentLink,
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => showLegalDocument(
                                              context,
                                              legalDocById('privacy')!)),
                                    TextSpan(text: l10n.consentEnd),
                                  ]))),
                          if (error != null)
                            Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(error!,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 12))),
                          const SizedBox(height: 24),
                          SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                  onPressed: busy ? null : _submit,
                                  child: Text(busy
                                      ? l10n.findingEnergy
                                      : l10n.discoverEnergy))),
                        ])))));
  }
}
