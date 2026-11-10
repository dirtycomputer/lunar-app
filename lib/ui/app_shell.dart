import 'dart:convert';
import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/app_state.dart';
import '../services/bazi.dart' as bazi;
import '../services/chart_assistant.dart';
import '../services/intent_flow.dart';
import '../studio/chart_engine.dart';
import '../studio/chart_studio.dart';
import '../studio/reading_panel.dart';
import '../studio/studio_store.dart';
import 'agent_page.dart';
import 'design.dart';
import 'intent_pages.dart';
import 'language_picker.dart';
import 'profile_editor.dart';
import 'profile_detail.dart';
import 'secondary_pages.dart';
import 'social_pages.dart';

class AppShell extends StatefulWidget {
  final AppState state;
  const AppShell({super.key, required this.state});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppState get state => widget.state;
  AppIntent? section;
  late final StudioStore studio;
  late final ChartAgent agent;
  final scroll = ScrollController(), search = TextEditingController();
  final random = RandomMatchPicker();
  int matchTab = 0;
  bool outlook = false;
  OutlookPeriod period = OutlookPeriod.month;
  String gender = 'Everyone', region = 'Worldwide';
  RangeValues ageRange = const RangeValues(18, 60);
  double minScore = 0;
  late int generation;
  late String profileSignature;
  @override
  void initState() {
    super.initState();
    section = state.startIntent;
    studio = StudioStore(state);
    agent = ChartAgent(studio);
    generation = state.resetGeneration;
    profileSignature = _profileSignature();
    state.addListener(_changed);
  }

  String _profileSignature() =>
      jsonEncode([state.name, state.birth.toJson(), state.personalized]);
  void _changed() {
    final next = _profileSignature();
    if (next != profileSignature) {
      profileSignature = next;
      agent.clear();
    }
    if (generation != state.resetGeneration) {
      generation = state.resetGeneration;
      section = null;
      agent.clear();
      search.clear();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    state.removeListener(_changed);
    scroll.dispose();
    search.dispose();
    agent.dispose();
    studio.dispose();
    super.dispose();
  }

  ChartContext get chart => ChartContext(ChartEngine().calculate(ChartSubject(
      name: state.name,
      birth: state.birth,
      sex: studio.primary.sex,
      sect: studio.primary.sect,
      basis: studio.primary.basis)));
  Future<void> choose(AppIntent intent) async {
    if (intent == AppIntent.chart && !state.personalized) {
      await showProfileEditor(context, state);
      if (!mounted || !state.personalized) return;
    }
    final ok = await state.chooseIntent(intent);
    if (!mounted) return;
    setState(() => section = intent);
    if (!ok) showToast(context, AppLocalizations.of(context)!.couldNotSave);
  }

  void navigate(AppIntent intent) {
    setState(() => section = intent);
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  void ask(String question) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    agent.ask(question, context: state.personalized ? chart : null);
    final l = AppLocalizations.of(context)!;
    final panel = AnimatedBuilder(
        animation: state,
        builder: (context, _) => Scaffold(
            key: const ValueKey('contextual-agent'),
            backgroundColor: canvas,
            appBar: AppBar(
                title: Text(l.flowAskAgent),
                leading: IconButton(
                    tooltip: l.flowBack,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close))),
            body: AgentPage(
                agent: agent,
                personalized: state.personalized,
                name: state.name,
                chart: state.personalized ? chart : null,
                onEdit: () => showProfileEditor(context, state),
                onSettings: modelSettings)));
    if (MediaQuery.sizeOf(context).width >= 1000) {
      showDialog<void>(
          context: context,
          builder: (_) => Dialog(
              alignment: AlignmentDirectional.centerEnd,
              insetPadding: const EdgeInsets.all(12),
              clipBehavior: Clip.antiAlias,
              child:
                  SizedBox(width: 520, height: double.infinity, child: panel)));
    } else {
      showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          clipBehavior: Clip.antiAlias,
          builder: (context) => SizedBox(
              height: MediaQuery.sizeOf(context).height * .92, child: panel));
    }
  }

  Future<void> openTools([int tab = 0]) async {
    final ok =
        await studio.updateSubjects(chart.natal.subject, studio.secondary);
    if (!mounted) return;
    if (!ok) {
      showToast(context, AppLocalizations.of(context)!.couldNotSave);
      return;
    }
    await _fullScreen(AppLocalizations.of(context)!.flowTools,
        ChartStudio(store: studio, initialTab: tab, compact: true));
    if (mounted) setState(() {});
  }

  Future<void> _fullScreen(String title, Widget child) => showDialog<void>(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
          child: Scaffold(
              appBar: AppBar(
                  title: Text(title),
                  leading: IconButton(
                      tooltip: AppLocalizations.of(context)!.flowBack,
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close))),
              body: SingleChildScrollView(
                  padding: const EdgeInsets.all(22),
                  child: Center(
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1150),
                          child: child))))));
  void modelSettings() => _fullScreen(
      AppLocalizations.of(context)!.flowConnectModel,
      ModelSettingsPanel(store: studio));
  void settings() {
    final l = AppLocalizations.of(context)!;
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text(l.flowSettings),
                content: SizedBox(
                    width: 340,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(l.flowBirthDetails),
                          onTap: () {
                            Navigator.pop(ctx);
                            showProfileEditor(context, state);
                          }),
                      ListTile(
                          leading: const Icon(Icons.translate),
                          title: Text(l.languageTitle),
                          onTap: () {
                            Navigator.pop(ctx);
                            showLanguagePicker(context, state);
                          }),
                      ListTile(
                          leading: const Icon(Icons.tune),
                          title: Text(l.flowConnectModel),
                          onTap: () {
                            Navigator.pop(ctx);
                            modelSettings();
                          }),
                      ListTile(
                          leading: const Icon(Icons.lock_outline),
                          title: Text(l.privacyData),
                          onTap: () {
                            Navigator.pop(ctx);
                            showPrivacy(context, state);
                          }),
                      ListTile(
                          leading: const Icon(Icons.auto_stories_outlined),
                          title: Text(l.navGuide),
                          onTap: () {
                            Navigator.pop(ctx);
                            _fullScreen(l.navGuide, const GuidePage());
                          }),
                    ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l.actionClose))
                ]));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (section == null) {
      return IntentChooser(onChoose: choose, onSettings: settings);
    }
    final desktop = MediaQuery.sizeOf(context).width >= 1000;
    final labels = [l.flowChart, l.flowMatch, l.flowAgent];
    return Scaffold(
        bottomNavigationBar: desktop
            ? null
            : NavigationBar(
                height: 70,
                selectedIndex: section!.index,
                onDestinationSelected: (i) => navigate(AppIntent.values[i]),
                backgroundColor: Colors.white,
                indicatorColor: blueTint,
                destinations: [
                    NavigationDestination(
                        key: const ValueKey('nav-chart'),
                        icon: const Icon(Icons.grid_view_outlined),
                        selectedIcon: const Icon(Icons.grid_view_rounded),
                        label: l.flowChart),
                    NavigationDestination(
                        key: const ValueKey('nav-match'),
                        icon: const Icon(Icons.people_outline),
                        selectedIcon: const Icon(Icons.people),
                        label: l.flowMatch),
                    NavigationDestination(
                        key: const ValueKey('nav-agent'),
                        icon: const Icon(Icons.forum_outlined),
                        selectedIcon: const Icon(Icons.forum),
                        label: l.flowAgent),
                  ]),
        body: SafeArea(
            child: Row(children: [
          if (desktop) _sidebar(labels),
          Expanded(
              child: Column(children: [
            Container(
                height: 76,
                padding: EdgeInsets.symmetric(horizontal: desktop ? 34 : 18),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: line))),
                child: Row(children: [
                  if (!desktop) ...[
                    IconButton(
                        tooltip: l.flowStart,
                        onPressed: () => setState(() => section = null),
                        icon: const FlowerLogo(size: 24)),
                    const SizedBox(width: 6)
                  ],
                  Text(labels[section!.index],
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -.7)),
                  const Spacer(),
                  IconButton(
                      tooltip: l.flowSettings,
                      onPressed: settings,
                      icon: const Icon(Icons.settings_outlined, size: 21)),
                ])),
            Expanded(
                child: section == AppIntent.agent
                    ? AgentPage(
                        agent: agent,
                        personalized: state.personalized,
                        name: state.name,
                        chart: state.personalized ? chart : null,
                        onEdit: () => showProfileEditor(context, state),
                        onSettings: modelSettings)
                    : SingleChildScrollView(
                        controller: scroll,
                        padding: EdgeInsets.fromLTRB(
                            desktop ? 34 : 18, 26, desktop ? 34 : 18, 30),
                        child: Center(
                            child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 1320),
                                child: section == AppIntent.chart
                                    ? MyChartPage(
                                        state: state,
                                        contextData: chart,
                                        outlook: outlook,
                                        period: period,
                                        onMode: (v) =>
                                            setState(() => outlook = v),
                                        onPeriod: (v) =>
                                            setState(() => period = v),
                                        onAsk: ask,
                                        onEdit: () =>
                                            showProfileEditor(context, state),
                                        onTools: () => openTools())
                                    : _matches())))),
          ]))
        ])));
  }

  Widget _sidebar(List<String> labels) {
    final l = AppLocalizations.of(context)!;
    return Container(
        width: 194,
        decoration: const BoxDecoration(
            color: Colors.white,
            border: BorderDirectional(end: BorderSide(color: line))),
        padding: const EdgeInsets.fromLTRB(16, 27, 16, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          InkWell(
              onTap: () => setState(() => section = null),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  child: Row(children: [
                    FlowerLogo(size: 30),
                    SizedBox(width: 11),
                    Text('FatePair',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -1.3))
                  ]))),
          const SizedBox(height: 55),
          for (final i in AppIntent.values)
            Padding(
                padding: EdgeInsets.only(
                    bottom: 10, top: i == AppIntent.agent ? 28 : 0),
                child: Material(
                    color: section == i ? blueTint : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                        key: ValueKey('nav-${i.name}'),
                        onTap: () => navigate(i),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 16),
                            child: Row(children: [
                              Icon(
                                  [
                                    Icons.grid_view_outlined,
                                    Icons.people_outline,
                                    Icons.forum_outlined
                                  ][i.index],
                                  size: 20,
                                  color: section == i ? blue : muted),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(labels[i.index],
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: section == i
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: section == i ? blue : ink)))
                            ]))))),
          const Spacer(),
          ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 9),
              leading: CircleAvatar(
                  radius: 17,
                  backgroundColor: mintTint,
                  child: Text(
                      state.name.isEmpty ? '?' : state.name.characters.first,
                      style: const TextStyle(fontSize: 13, color: green))),
              title: Text(state.personalized ? state.name : l.flowProfile,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
              onTap: () => showProfileEditor(context, state)),
        ]));
  }

  List<bazi.MatchResult> get recommendations => state.matches.where((m) {
        final p = m.person;
        final q = search.text.trim().toLowerCase();
        return !state.hidden.contains(p.id) &&
            (matchTab != 1 || state.saved.contains(p.id)) &&
            (gender == 'Everyone' || p.gender == gender) &&
            (region == 'Worldwide' || p.location.endsWith(region)) &&
            p.age >= ageRange.start &&
            p.age <= ageRange.end &&
            m.score >= minScore &&
            (q.isEmpty ||
                '${p.name} ${p.location} ${p.occupation} ${p.interests.join(' ')}'
                    .toLowerCase()
                    .contains(q));
      }).toList();
  void _openProfile(bazi.MatchResult m) =>
      showProfileDetail(context, state, m, onCompare: () async {
        final ok = await studio.updateSubjects(chart.natal.subject,
            ChartSubject(name: m.person.name, birth: m.person.birth));
        if (!mounted) return;
        if (ok) {
          _fullScreen(AppLocalizations.of(context)!.flowTools,
              ChartStudio(store: studio, initialTab: 2, compact: true));
        } else {
          showToast(context, AppLocalizations.of(context)!.compareFailed);
        }
      });
  void _random() {
    final m = random.pick(recommendations);
    if (m != null) _openProfile(m);
  }

  void resetFilters() => setState(() {
        search.clear();
        gender = 'Everyone';
        region = 'Worldwide';
        ageRange = const RangeValues(18, 60);
        minScore = 0;
      });

  Widget _matches() {
    final l = AppLocalizations.of(context)!;
    final list = recommendations;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final (i, label) in [
              l.flowPeople,
              l.flowSaved,
              l.socialInvitations,
              l.socialMessages
            ].indexed)
              Padding(
                  padding: const EdgeInsetsDirectional.only(end: 20),
                  child: InkWell(
                      key: ValueKey('match-tab-$i'),
                      onTap: () => setState(() => matchTab = i),
                      child: Container(
                          padding: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 2,
                                      color: matchTab == i
                                          ? blue
                                          : Colors.transparent))),
                          child: Text(label,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: matchTab == i ? blue : muted,
                                  fontWeight: matchTab == i
                                      ? FontWeight.w600
                                      : FontWeight.w400)))))
          ])),
      const Divider(height: 1),
      const SizedBox(height: 22),
      if (matchTab < 2) ...[
        LayoutBuilder(builder: (context, c) {
          final searchBox = TextField(
              key: const ValueKey('discovery-search'),
              controller: search,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                  hintText: l.socialSearchHint,
                  prefixIcon: const Icon(Icons.search, size: 19),
                  suffixIcon: search.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l.socialClearSearch,
                          onPressed: () => setState(search.clear),
                          icon: const Icon(Icons.close, size: 17)),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 15)));
          final actions = Row(mainAxisSize: MainAxisSize.min, children: [
            if (matchTab == 0) ...[
              FilledButton.icon(
                  key: const ValueKey('random-match'),
                  onPressed: list.isEmpty ? null : _random,
                  icon: const Icon(Icons.shuffle_rounded, size: 17),
                  label: Text(l.flowRandom)),
              const SizedBox(width: 10)
            ],
            OutlinedButton.icon(
                onPressed: _showFilters,
                icon: const Icon(Icons.tune, size: 16),
                label: Text(l.filters))
          ]);
          return c.maxWidth > 720
              ? Row(children: [
                  Expanded(child: searchBox),
                  const SizedBox(width: 16),
                  actions
                ])
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [searchBox, const SizedBox(height: 13), actions]);
        }),
        if (!state.personalized)
          Padding(
              padding: const EdgeInsets.only(top: 9),
              child: TextButton.icon(
                  onPressed: () => showProfileEditor(context, state),
                  icon: const Icon(Icons.person_outline, size: 15),
                  label: Text(l.flowAddBirth,
                      style: const TextStyle(fontSize: 11)))),
        const SizedBox(height: 23),
        if (list.isEmpty)
          _empty(
              matchTab == 1 && state.saved.isEmpty
                  ? l.flowNoSaved
                  : l.flowNoPeople,
              onTap: resetFilters,
              action: l.flowResetFilters)
        else ...[
          Text(l.demoNotice,
              style: const TextStyle(fontSize: 11, color: muted)),
          const SizedBox(height: 12),
          for (final m in list)
            Padding(
                padding: const EdgeInsets.only(bottom: 12), child: _person(m)),
        ],
      ] else
        _socialList(),
    ]);
  }

  Widget _person(bazi.MatchResult m) {
    final l = AppLocalizations.of(context)!;
    final p = m.person;
    final reason = switch (matchReason(m)) {
      MatchReason.balance => l.flowReasonBalance,
      MatchReason.support => l.flowReasonSupport,
      MatchReason.shared => l.flowReasonShared,
      MatchReason.branches => l.flowReasonBranches,
      MatchReason.contrast => l.flowReasonContrast,
    };
    return Semantics(
        button: true,
        label: '${p.name}, ${p.age}, ${p.location}',
        child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: line)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
                onTap: () => _openProfile(m),
                child: LayoutBuilder(builder: (context, c) {
                  final compact = c.maxWidth < 600;
                  return Padding(
                      padding: EdgeInsets.all(compact ? 14 : 18),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(p.image,
                                    width: compact ? 76 : 106,
                                    height: compact ? 112 : 124,
                                    fit: BoxFit.cover,
                                    alignment: const Alignment(0, -.3))),
                            SizedBox(width: compact ? 14 : 22),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Row(children: [
                                    Expanded(
                                        child: Text('${p.name}, ${p.age}',
                                            style: TextStyle(
                                                fontSize: compact ? 18 : 21,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: -.4))),
                                    SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: IconButton(
                                            padding: EdgeInsets.zero,
                                            tooltip: state.saved.contains(p.id)
                                                ? l.unsave(p.name)
                                                : l.saveTo(p.name),
                                            onPressed: () async {
                                              final ok =
                                                  await state.toggleSaved(p.id);
                                              if (!ok && context.mounted) {
                                                showToast(
                                                    context, l.couldNotSave);
                                              }
                                            },
                                            icon: Icon(
                                                state.saved.contains(p.id)
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                size: 19,
                                                color:
                                                    state.saved.contains(p.id)
                                                        ? coral
                                                        : muted)))
                                  ]),
                                  Text(p.location,
                                      style: const TextStyle(
                                          fontSize: 11, color: muted)),
                                  const SizedBox(height: 10),
                                  Text(reason,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          height: 1.5,
                                          color: ink)),
                                  const SizedBox(height: 10),
                                  Row(children: [
                                    Text(l.harmonyPct(m.score),
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: green)),
                                    const Spacer(),
                                    const Icon(Icons.arrow_forward,
                                        size: 17, color: muted)
                                  ])
                                ]))
                          ]));
                }))));
  }

  Widget _empty(String title,
          {required VoidCallback onTap, required String action}) =>
      Surface(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 42),
              child: Center(
                  child: Column(children: [
                const Icon(Icons.people_outline, size: 35, color: muted),
                const SizedBox(height: 19),
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500)),
                const SizedBox(height: 23),
                OutlinedButton(onPressed: onTap, child: Text(action))
              ]))));
  Widget _socialList() {
    final l = AppLocalizations.of(context)!;
    final rows = state.matches
        .where((m) =>
            !state.hidden.contains(m.person.id) &&
            (matchTab == 2
                ? state.social.invitations.contains(m.person.id)
                : state.social.messagesFor(m.person.id).isNotEmpty))
        .toList();
    if (matchTab == 3) {
      rows.sort((a, b) => state.social
          .messagesFor(b.person.id)
          .last
          .createdAt
          .compareTo(state.social.messagesFor(a.person.id).last.createdAt));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.lock_outline, size: 13, color: muted),
        const SizedBox(width: 6),
        Text(l.flowLocalPreview,
            style: const TextStyle(fontSize: 10, color: muted))
      ]),
      const SizedBox(height: 17),
      if (rows.isEmpty)
        _empty(matchTab == 2 ? l.flowNoInvites : l.flowNoMessages,
            onTap: () => setState(() => matchTab = 0), action: l.flowPeople)
      else
        for (final m in rows)
          Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Surface(
                  padding: const EdgeInsets.all(17),
                  child: Column(children: [
                    InkWell(
                        onTap: () => matchTab == 2
                            ? _openProfile(m)
                            : showLocalConversation(context, state, m.person),
                        child: Row(children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.asset(m.person.image,
                                  width: 52, height: 59, fit: BoxFit.cover)),
                          const SizedBox(width: 15),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(m.person.name,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 7),
                                Text(
                                    matchTab == 2
                                        ? l.socialPending
                                        : state.social
                                            .messagesFor(m.person.id)
                                            .last
                                            .text,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 11, color: muted))
                              ])),
                          const Icon(Icons.chevron_right,
                              size: 20, color: muted)
                        ])),
                    if (matchTab == 2)
                      Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                              onPressed: () =>
                                  state.social.withdraw(m.person.id),
                              child: Text(l.socialWithdraw,
                                  style: const TextStyle(fontSize: 10))))
                  ])))
    ]);
  }

  String _genderLabel(AppLocalizations l, String g) => switch (g) {
        'Women' => l.genderWomen,
        'Men' => l.genderMen,
        _ => l.genderEveryone
      };
  String _regionLabel(AppLocalizations l, String r) => switch (r) {
        'USA' => l.regionUSA,
        'UK' => l.regionUK,
        'France' => l.regionFrance,
        'Australia' => l.regionAustralia,
        'Singapore' => l.regionSingapore,
        _ => l.regionWorldwide
      };
  Future<void> _showFilters() async {
    final l10n = AppLocalizations.of(context)!;
    var draftGender = gender;
    var draftRegion = region;
    var draftAge = ageRange;
    var draftScore = minScore;
    await showDialog<void>(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, update) => AlertDialog(
                  backgroundColor: canvas,
                  title: Text(l10n.filters),
                  content: SizedBox(
                      width: 410,
                      child: SingleChildScrollView(
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(l10n.showMe,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 10),
                            Wrap(
                                spacing: 8,
                                children: ['Everyone', 'Women', 'Men']
                                    .map((g) => ChoiceChip(
                                        label: Text(_genderLabel(l10n, g)),
                                        selected: draftGender == g,
                                        onSelected: (_) =>
                                            update(() => draftGender = g)))
                                    .toList()),
                            const SizedBox(height: 22),
                            DropdownButtonFormField<String>(
                                value: draftRegion,
                                isExpanded: true,
                                decoration:
                                    InputDecoration(labelText: l10n.location),
                                items: [
                                  'Worldwide',
                                  'USA',
                                  'UK',
                                  'France',
                                  'Australia',
                                  'Singapore'
                                ]
                                    .map((r) => DropdownMenuItem(
                                        value: r,
                                        child: Text(_regionLabel(l10n, r))))
                                    .toList(),
                                onChanged: (r) =>
                                    update(() => draftRegion = r!)),
                            const SizedBox(height: 22),
                            Text(l10n.ageRangeLabel(
                                draftAge.start.round(), draftAge.end.round())),
                            RangeSlider(
                                values: draftAge,
                                min: 18,
                                max: 80,
                                divisions: 62,
                                labels: RangeLabels('${draftAge.start.round()}',
                                    '${draftAge.end.round()}'),
                                onChanged: (v) => update(() => draftAge = v)),
                            Text(l10n.minHarmony(draftScore.round())),
                            Slider(
                                value: draftScore,
                                min: 0,
                                max: 100,
                                divisions: 20,
                                label: '${draftScore.round()}%',
                                onChanged: (v) => update(() => draftScore = v)),
                            Text(l10n.harmonyNote,
                                style: const TextStyle(
                                    fontSize: 11, color: muted)),
                          ]))),
                  actions: [
                    TextButton(
                        onPressed: () => update(() {
                              draftGender = 'Everyone';
                              draftRegion = 'Worldwide';
                              draftAge = const RangeValues(18, 60);
                              draftScore = 0;
                            }),
                        child: Text(l10n.reset)),
                    FilledButton(
                        onPressed: () {
                          setState(() {
                            gender = draftGender;
                            region = draftRegion;
                            ageRange = draftAge;
                            minScore = draftScore;
                          });
                          Navigator.pop(context);
                        },
                        child: Text(l10n.showConnections))
                  ],
                )));
  }
}
