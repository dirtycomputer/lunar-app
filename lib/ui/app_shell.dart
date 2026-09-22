import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../studio/studio_store.dart';
import '../studio/chart_engine.dart';
import '../studio/glossary.dart';
import '../studio/chart_studio.dart';
import '../services/bazi.dart' as bazi;
import '../l10n/generated/app_localizations.dart';
import '../l10n/bazi_labels.dart';
import 'design.dart';
import 'profile_editor.dart';
import 'profile_detail.dart';
import 'secondary_pages.dart';

class AppShell extends StatefulWidget {
  final AppState state;
  const AppShell({super.key, required this.state});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int page = 0;
  int studioInitialTab = 0;
  late final StudioStore studio;
  String category = 'For you';
  String gender = 'Everyone';
  String region = 'Worldwide';
  RangeValues ageRange = const RangeValues(18, 60);
  double minScore = 0;
  final scroll = ScrollController();
  final matchesKey = GlobalKey();
  AppState get state => widget.state;
  @override
  void initState() {
    super.initState();
    studio = StudioStore(state);
    if (state.persistenceError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showToast(context, state.persistenceError!);
      });
    }
  }

  @override
  void dispose() {
    scroll.dispose();
    studio.dispose();
    super.dispose();
  }

  void navigate(int index, {int studioTab = 0}) {
    setState(() {
      page = index;
      studioInitialTab = studioTab;
    });
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  void editProfile() => showProfileEditor(context, state);
  void showGuide() => navigate(3);
  bool get hasFilters =>
      gender != 'Everyone' ||
      region != 'Worldwide' ||
      ageRange.start != 18 ||
      ageRange.end != 60 ||
      minScore != 0;
  List<bazi.MatchResult> get recommendations => state.matches.where((m) {
        final p = m.person;
        if (state.hidden.contains(p.id)) return false;
        if (page == 1 && !state.saved.contains(p.id)) return false;
        if (p.age < ageRange.start || p.age > ageRange.end) return false;
        if (gender != 'Everyone' && p.gender != gender) return false;
        if (region != 'Worldwide' && !p.location.endsWith(region)) return false;
        if (m.score < minScore) return false;
        if (category == 'High harmony' && m.score < 80) return false;
        if (category == 'Same birth city' &&
            p.location != state.birth.place.name) {
          return false;
        }
        if (category == 'Creative souls' &&
            !p.interests.any((i) => [
                  'Design',
                  'Art',
                  'Music',
                  'Photography',
                  'Architecture'
                ].contains(i))) {
          return false;
        }
        return true;
      }).toList();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final width = MediaQuery.sizeOf(context).width;
        final desktop = width >= 950;
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          body: SafeArea(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                if (desktop) _sidebar(),
                Expanded(
                    child: Column(children: [
                  _topbar(desktop),
                  Expanded(
                      child: SingleChildScrollView(
                    controller: scroll,
                    padding: EdgeInsets.fromLTRB(desktop ? 36 : 20,
                        desktop ? 30 : 22, desktop ? 36 : 20, 36),
                    child: Center(
                        child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1330),
                      child: page == 4
                          ? ChartStudio(
                              store: studio, initialTab: studioInitialTab)
                          : page == 2
                              ? EnergyPage(
                                  state: state,
                                  onEdit: editProfile,
                                  onLearn: showGuide)
                              : page == 3
                                  ? const GuidePage()
                                  : _discovery(width),
                    )),
                  )),
                ])),
              ])),
          bottomNavigationBar: desktop
              ? null
              : NavigationBar(
                  height: 72,
                  backgroundColor: Colors.white,
                  indicatorColor: const Color(0xFFDDE7FF),
                  selectedIndex: page,
                  onDestinationSelected: navigate,
                  destinations: [
                      NavigationDestination(
                          icon: const Icon(Icons.explore_outlined),
                          selectedIcon: const Icon(Icons.explore),
                          label: l10n.tabDiscover),
                      NavigationDestination(
                          icon: const Icon(Icons.favorite_border),
                          selectedIcon: const Icon(Icons.favorite),
                          label: l10n.tabSaved),
                      NavigationDestination(
                          icon: const Icon(Icons.spa_outlined),
                          selectedIcon: const Icon(Icons.spa),
                          label: l10n.tabMyEnergy),
                      NavigationDestination(
                          icon: const Icon(Icons.auto_stories_outlined),
                          selectedIcon: const Icon(Icons.auto_stories),
                          label: l10n.tabGuide),
                      NavigationDestination(
                          icon: const Icon(Icons.grid_view_outlined),
                          selectedIcon: const Icon(Icons.grid_view),
                          label: l10n.tabStudio),
                    ]),
        );
      });

  Widget _sidebar() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: 218,
      decoration: const BoxDecoration(
          color: Color(0xFFEEF1FA),
          border: Border(right: BorderSide(color: line))),
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Row(children: [
              FlowerLogo(size: 34),
              SizedBox(width: 11),
              Text('lunar',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1.8)),
            ])),
        Padding(
            padding: const EdgeInsets.fromLTRB(13, 8, 0, 48),
            child: Text(l10n.tagline,
                style:
                    const TextStyle(fontSize: 9, color: muted, letterSpacing: .05))),
        Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 14),
            child: Text(l10n.yourSpace,
                style: TextStyle(
                    fontSize: 9,
                    color: muted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4))),
        _navItem(0, l10n.tabDiscover, Icons.explore_outlined),
        _navItem(1, l10n.navConnections, Icons.favorite_border,
            count: state.saved.length),
        _navItem(2, l10n.tabMyEnergy, Icons.spa_outlined),
        _navItem(4, l10n.navStudio, Icons.grid_view_outlined),
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Divider(height: 1)),
        _navItem(3, l10n.navGuide, Icons.auto_stories_outlined),
        const Spacer(),
        Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
                color: const Color(0xFFF0E8F7),
                borderRadius: BorderRadius.circular(18)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.wb_sunny_outlined, color: green, size: 23),
              const SizedBox(height: 12),
              Text(l10n.promoTitle,
                  style: const TextStyle(
                      fontSize: 14, height: 1.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(l10n.promoBody,
                  style: const TextStyle(fontSize: 11, height: 1.7, color: muted)),
              const SizedBox(height: 8),
              InkWell(
                  onTap: () => navigate(2),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(children: [
                        Expanded(
                            child: Text(l10n.promoCta,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: green))),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward, size: 15, color: green),
                      ]))),
            ])),
        const SizedBox(height: 23),
        InkWell(
            onTap: editProfile,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                child: Row(children: [
                  CircleAvatar(
                      radius: 19,
                      backgroundColor: const Color(0xFFDDE5D3),
                      child: Text(state.name.characters.first.toUpperCase(),
                          style: const TextStyle(fontSize: 15, color: green))),
                  const SizedBox(width: 11),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(state.name,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                        Text(
                            state.personalized
                                ? l10n.editProfileShort
                                : l10n.demoProfile,
                            style: const TextStyle(fontSize: 10, color: muted)),
                      ])),
                  const Icon(Icons.more_horiz, color: muted, size: 19),
                ]))),
      ]));
  }

  Widget _navItem(int index, String label, IconData icon, {int count = 0}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Material(
              color:
                  page == index ? const Color(0xFFDBE5FC) : Colors.transparent,
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                  onTap: () => navigate(index),
                  borderRadius: BorderRadius.circular(28),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 17, vertical: 15),
                      child: Row(children: [
                        Icon(icon,
                            size: 20, color: page == index ? green : muted),
                        const SizedBox(width: 13),
                        Expanded(
                            child: Text(label,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: page == index ? ink : muted,
                                    fontWeight: page == index
                                        ? FontWeight.w700
                                        : FontWeight.w500))),
                        if (count > 0)
                          Text('$count',
                              style:
                                  const TextStyle(fontSize: 10, color: green)),
                      ])))));

  Widget _topbar(bool desktop) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: desktop ? 86 : 74,
      padding: EdgeInsets.symmetric(horizontal: desktop ? 38 : 20),
      decoration:
          const BoxDecoration(border: Border(bottom: BorderSide(color: line))),
      child: Row(children: [
        if (!desktop) ...[
          const FlowerLogo(size: 27),
          const SizedBox(width: 10)
        ],
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  [
                    l10n.tabDiscover,
                    l10n.navConnections,
                    l10n.tabMyEnergy,
                    l10n.navGuide,
                    l10n.navStudio
                  ][page],
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.5)),
              if (desktop)
                Text(l10n.topbarSub,
                    style: const TextStyle(fontSize: 11, color: muted)),
            ]),
        const Spacer(),
        if (desktop) ...[
          TextButton.icon(
              onPressed: _showFilters,
              icon: const Icon(Icons.public, size: 16),
              label: Text(_regionLabel(l10n, region),
                  style: const TextStyle(fontSize: 11)),
              style: TextButton.styleFrom(foregroundColor: muted)),
          const SizedBox(width: 16),
          Container(width: 1, height: 24, color: line),
          const SizedBox(width: 16),
        ],
        IconButton(
            onPressed: showGuide,
            tooltip: l10n.howLunarWorks,
            icon: const Icon(Icons.help_outline, size: 21, color: muted)),
        const SizedBox(width: 8),
        InkWell(
            onTap: editProfile,
            borderRadius: BorderRadius.circular(24),
            child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE4EBDA),
                child: Text(state.name.characters.first.toUpperCase(),
                    style: const TextStyle(
                        color: green,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)))),
      ]));
  }

  String _categoryLabel(AppLocalizations l, String c) => switch (c) {
        'High harmony' => l.catHighHarmony,
        'Same birth city' => l.catSameCity,
        'Creative souls' => l.catCreative,
        _ => l.catForYou,
      };

  String _genderLabel(AppLocalizations l, String g) => switch (g) {
        'Women' => l.genderWomen,
        'Men' => l.genderMen,
        _ => l.genderEveryone,
      };

  String _regionLabel(AppLocalizations l, String r) => switch (r) {
        'USA' => l.regionUSA,
        'UK' => l.regionUK,
        'France' => l.regionFrance,
        'Australia' => l.regionAustralia,
        'Singapore' => l.regionSingapore,
        _ => l.regionWorldwide,
      };

  Widget _discovery(double width) {
    final sidePanel = width >= 1250;
    final l10n = AppLocalizations.of(context)!;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (page == 0) ...[_hero(), const SizedBox(height: 32)],
        Row(
            key: matchesKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                        page == 0
                            ? l10n.discoverTitle
                            : l10n.savedTitle,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 5),
                    Text(
                        page == 0
                            ? l10n.discoverSub
                            : l10n.savedSub,
                        style: const TextStyle(fontSize: 12, color: muted)),
                  ])),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                  onPressed: _showFilters,
                  icon: Icon(Icons.tune,
                      size: 16, color: hasFilters ? green : ink),
                  label: Text(hasFilters ? l10n.filtered : l10n.filters,
                      style: const TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 17, vertical: 16),
                      backgroundColor: Colors.white)),
            ]),
        const SizedBox(height: 20),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              for (final (index, entry) in [
                ('For you', Icons.auto_awesome_outlined),
                ('High harmony', Icons.favorite_border),
                ('Same birth city', Icons.near_me_outlined),
                ('Creative souls', Icons.palette_outlined)
              ].indexed)
                Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Builder(builder: (context) {
                      final selected = category == entry.$1;
                      final color = accentColors[index];
                      return ChoiceChip(
                        label: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(entry.$2,
                              size: 14, color: selected ? color : muted),
                          const SizedBox(width: 6),
                          Text(_categoryLabel(l10n, entry.$1))
                        ]),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => category = entry.$1),
                        showCheckmark: false,
                        selectedColor: accentTints[index],
                        backgroundColor: canvas,
                        side: BorderSide(
                            color: selected
                                ? color.withValues(alpha: .35)
                                : line),
                        labelStyle: TextStyle(
                            fontSize: 10,
                            color: selected ? color : muted,
                            fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                      );
                    })),
            ])),
        const SizedBox(height: 21),
        Row(children: [
          Container(
              width: 5,
              height: 5,
              decoration:
                  const BoxDecoration(color: green, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Expanded(
              child: Text(
                  page == 0
                      ? l10n.countDiscover(recommendations.length)
                      : l10n.countSaved(recommendations.length),
                  style: const TextStyle(fontSize: 10, color: muted))),
          const Icon(Icons.sort, size: 13, color: muted),
          const SizedBox(width: 5),
          Text(l10n.bestHarmony,
              style: const TextStyle(fontSize: 10, color: muted)),
        ]),
        const SizedBox(height: 15),
        if (recommendations.isEmpty)
          _emptyState()
        else
          LayoutBuilder(builder: (context, c) {
            final columns = c.maxWidth >= 700
                ? 3
                : c.maxWidth >= 460
                    ? 2
                    : 1;
            final cardWidth = (c.maxWidth - (columns - 1) * 18) / columns;
            return Wrap(
                spacing: 18,
                runSpacing: 22,
                children: recommendations
                    .map((m) => SizedBox(
                        width: cardWidth, child: _personCard(m, cardWidth)))
                    .toList());
          }),
        const SizedBox(height: 28),
        Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.spa_outlined, size: 14, color: muted),
          const SizedBox(width: 8),
          Flexible(
              child: Text(l10n.curiosity,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10, color: muted.withValues(alpha: .8)))),
        ])),
        const SizedBox(height: 12),
        Center(
            child: Text(l10n.demoNotice,
                style: const TextStyle(fontSize: 9, color: muted))),
      ])),
      if (sidePanel) ...[
        const SizedBox(width: 27),
        SizedBox(width: 254, child: _rightPanel())
      ],
    ]);
  }

  Widget _hero() => LayoutBuilder(builder: (context, c) {
        final compact = c.maxWidth < 550;
        final l10n = AppLocalizations.of(context)!;
        return Container(
            height: compact ? 290 : 273,
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE3EEFF),
                      Color(0xFFEDE7F8),
                      Color(0xFFF8E9DF)
                    ]),
                borderRadius: BorderRadius.circular(25)),
            clipBehavior: Clip.antiAlias,
            child: Stack(children: [
              Positioned(
                  right: compact ? -72 : -5,
                  top: compact ? 47 : -15,
                  child: Opacity(
                      opacity: compact ? .55 : 1,
                      child: SizedBox(
                          width: compact ? 260 : 280,
                          height: compact ? 260 : 280,
                          child: const OrbitArt()))),
              Padding(
                  padding: EdgeInsets.all(compact ? 26 : 30),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: green)),
                          const SizedBox(width: 7),
                          Text(l10n.heroEyebrow,
                              style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: green,
                                  letterSpacing: 1.2))
                        ]),
                        const SizedBox(height: 14),
                        Text(l10n.heroTitle,
                            style: TextStyle(
                                fontSize: compact ? 29 : 33,
                                height: 1.18,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -1.4,
                                color: blue)),
                        const SizedBox(height: 10),
                        SizedBox(
                            width: compact ? 220 : 295,
                            child: Text(l10n.heroBody,
                                style: const TextStyle(
                                    fontSize: 11, height: 1.6, color: muted))),
                        const Spacer(),
                        FilledButton(
                            onPressed: state.personalized
                                ? () => navigate(2)
                                : editProfile,
                            style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 16)),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Text(
                                  state.personalized
                                      ? l10n.exploreEnergy
                                      : l10n.findEnergy,
                                  style: const TextStyle(fontSize: 11)),
                              const SizedBox(width: 13),
                              const Icon(Icons.arrow_forward, size: 15)
                            ])),
                      ])),
            ]));
      });

  Widget _personCard(bazi.MatchResult match, double width) {
    final p = match.person;
    final saved = state.saved.contains(p.id);
    final l10n = AppLocalizations.of(context)!;
    return Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(21),
            side: const BorderSide(color: line)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            onTap: () =>
                showProfileDetail(context, state, match, onCompare: () async {
                  final ok = await studio.updateSubjects(
                    ChartSubject(
                        name: state.name,
                        birth: state.birth,
                        sex: studio.primary.sex),
                    ChartSubject(
                        name: match.person.name, birth: match.person.birth),
                  );
                  if (!mounted) return;
                  if (ok) {
                    navigate(4, studioTab: 2);
                  } else {
                    showToast(context, l10n.compareFailed);
                  }
                }),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                  height: width > 330 ? 315 : 240,
                  child: Stack(fit: StackFit.expand, children: [
                    Image.asset(p.image,
                        fit: BoxFit.cover,
                        alignment: const Alignment(0, -.35),
                        errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFE4EBDA),
                            child: const Icon(Icons.person,
                                size: 70, color: green))),
                    Positioned.fill(
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                          Colors.black.withValues(alpha: .05),
                          Colors.transparent,
                          Colors.black.withValues(alpha: .52)
                        ],
                                    stops: const [
                          0,
                          .5,
                          1
                        ])))),
                    Positioned(
                        top: 13,
                        left: 12,
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF2F6E9),
                                borderRadius: BorderRadius.circular(20)),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.auto_awesome,
                                  size: 12, color: green),
                              const SizedBox(width: 5),
                              Text(l10n.harmonyPct(match.score),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: green,
                                      fontWeight: FontWeight.w700))
                            ]))),
                    Positioned(
                        right: 8,
                        top: 7,
                        child: IconButton.filledTonal(
                            onPressed: () async {
                              final ok = await state.toggleSaved(p.id);
                              if (mounted) {
                                showToast(
                                    context,
                                    ok
                                        ? (saved
                                            ? l10n.removedToast(p.name)
                                            : l10n.savedToast(p.name))
                                        : l10n.couldNotSave);
                              }
                            },
                            tooltip: saved
                                ? l10n.unsave(p.name)
                                : l10n.saveTo(p.name),
                            style: IconButton.styleFrom(
                                backgroundColor:
                                    Colors.white.withValues(alpha: .95),
                                minimumSize: const Size(34, 34)),
                            icon: Icon(
                                saved ? Icons.favorite : Icons.favorite_border,
                                color: saved ? const Color(0xFFBA776D) : ink,
                                size: 17))),
                    Positioned(
                        bottom: 16,
                        left: 17,
                        right: 14,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${p.name}, ${p.age}',
                                  style: const TextStyle(
                                      fontSize: 23,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -.5)),
                              const SizedBox(height: 3),
                              Row(children: [
                                const Icon(Icons.location_on_outlined,
                                    color: Colors.white, size: 12),
                                const SizedBox(width: 4),
                                Expanded(
                                    child: Text(p.location,
                                        style: const TextStyle(
                                            fontSize: 10, color: Colors.white)))
                              ]),
                            ])),
                  ])),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TermTap(
                            termId: 'master',
                            contextText: l10n.dayMasterContext(
                                p.name, identityLabel(l10n, match.chart)),
                            radius: BorderRadius.circular(20),
                            child: ElementPill(match.chart.dayElement,
                                label:
                                    '${identityLabel(l10n, match.chart)} · ${elementQualityShort(l10n, match.chart.dayElement)} ⓘ')),
                        const SizedBox(height: 10),
                        Text(p.occupation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, color: muted)),
                        const SizedBox(height: 12),
                        Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: p.interests
                                .map((i) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: line),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Text(i,
                                        style: const TextStyle(
                                            fontSize: 8, color: muted))))
                                .toList()),
                        const SizedBox(height: 13),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(children: [
                          const Icon(Icons.link, size: 15, color: green),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(
                                  matchLabel(l10n, match.score),
                                  style: const TextStyle(
                                      fontSize: 10, color: green))),
                          const Icon(Icons.arrow_forward,
                              size: 15, color: green)
                        ]),
                      ])),
            ])));
  }

  Widget _rightPanel() {
    final l10n = AppLocalizations.of(context)!;
    return Column(children: [
        Surface(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(l10n.glanceTitle,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700))),
                InkWell(
                    onTap: () => navigate(2),
                    child: const Icon(Icons.north_east, size: 17, color: muted))
              ]),
              const SizedBox(height: 5),
              Text(
                  state.personalized
                      ? l10n.glancePersonal
                      : l10n.glanceSample,
                  style: const TextStyle(fontSize: 10, color: muted)),
              const SizedBox(height: 24),
              Center(child: ElementRing(chart: state.chart, size: 155)),
              const SizedBox(height: 23),
              for (final element in bazi.Element.values)
                Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: Row(children: [
                      Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              color: elementColors[element.index],
                              shape: BoxShape.circle)),
                      const SizedBox(width: 9),
                      SizedBox(
                          width: 43,
                          child: Text(elementLabel(l10n, element),
                              style:
                                  const TextStyle(fontSize: 10, color: muted))),
                      Expanded(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: LinearProgressIndicator(
                                  value:
                                      state.chart.distribution[element.index],
                                  minHeight: 4,
                                  color: elementColors[element.index],
                                  backgroundColor: const Color(0xFFF1F3EE)))),
                      const SizedBox(width: 10),
                      SizedBox(
                          width: 29,
                          child: Text(
                              '${(state.chart.distribution[element.index] * 100).round()}%',
                              textAlign: TextAlign.right,
                              style:
                                  const TextStyle(fontSize: 9, color: muted))),
                    ])),
              const SizedBox(height: 11),
              SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                      onPressed: () => navigate(2),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15)),
                      child: Text(l10n.seeChart,
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w600)))),
            ])),
        const SizedBox(height: 20),
        Surface(
            color: const Color(0xFFF6F1E7),
            padding: const EdgeInsets.all(21),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.wb_sunny_outlined,
                    size: 18, color: Color(0xFFAD9055)),
                const SizedBox(width: 8),
                Text(l10n.wisdomEyebrow,
                    style: const TextStyle(
                        fontSize: 8,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF98815B)))
              ]),
              const SizedBox(height: 17),
              Text(l10n.wisdomTitle,
                  style: const TextStyle(
                      fontSize: 19,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -.5)),
              const SizedBox(height: 11),
              Text(l10n.wisdomBody,
                  style: const TextStyle(
                      fontSize: 11, height: 1.8, color: Color(0xFF8B8576))),
              const SizedBox(height: 15),
              InkWell(
                  onTap: showGuide,
                  child: Row(children: [
                    Expanded(
                        child: Text(l10n.wisdomCta,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8E794F)))),
                    const SizedBox(width: 7),
                    const Icon(Icons.arrow_forward,
                        size: 14, color: Color(0xFF8E794F)),
                  ])),
            ])),
        const SizedBox(height: 21),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.lock_outline, size: 15, color: muted),
              const SizedBox(width: 9),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(l10n.detailsYours,
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 5),
                    Text(l10n.detailsStored,
                        style:
                            const TextStyle(fontSize: 9, color: muted, height: 1.7)),
                    TextButton(
                        onPressed: () => showPrivacy(context, state),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(20, 32),
                            alignment: Alignment.centerLeft),
                        child: Text(l10n.privacyData,
                            style: const TextStyle(fontSize: 9))),
                  ])),
            ])),
      ]);
  }

  Widget _emptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Surface(
      child: Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(children: [
                Icon(page == 1 ? Icons.favorite_border : Icons.travel_explore,
                    color: green, size: 38),
                const SizedBox(height: 18),
                Text(
                    page == 1 && state.saved.isEmpty
                        ? l10n.emptySavedTitle
                        : l10n.emptyFilterTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 9),
                Text(
                    page == 1 && state.saved.isEmpty
                        ? l10n.emptySavedBody
                        : l10n.emptyFilterBody,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: muted, fontSize: 12)),
                const SizedBox(height: 20),
                FilledButton(
                    onPressed: () => setState(() {
                          category = 'For you';
                          gender = 'Everyone';
                          region = 'Worldwide';
                          ageRange = const RangeValues(18, 60);
                          minScore = 0;
                          if (page == 1 && state.saved.isEmpty) page = 0;
                        }),
                    child: Text(page == 1 && state.saved.isEmpty
                        ? l10n.discoverPeople
                        : l10n.resetFilters)),
              ]))));
  }

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
                  title: Text(l10n.filterTitle),
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
                                decoration: InputDecoration(
                                    labelText: l10n.location),
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
                            Text(l10n.ageRangeLabel(draftAge.start.round(),
                                draftAge.end.round())),
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
