import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/app_state.dart';
import '../services/sharing.dart';
import '../services/bazi.dart' show ElementInfo;
import '../services/intent_flow.dart';
import 'design.dart';
import 'element_art.dart';
import 'profile_editor.dart';

Future<void> showShareComposer(
    BuildContext context, AppState state, String kind,
    {String? parentId}) async {
  if (!state.personalized) await showProfileEditor(context, state);
  if (!context.mounted || !state.personalized) return;
  await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) =>
          ShareComposer(state: state, kind: kind, parentId: parentId)));
}

Future<void> showSharedLinks(BuildContext context, AppState state) =>
    Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => SharedLinksPage(state: state)));

class ShareFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onClose;
  const ShareFrame(
      {super.key, required this.title, required this.child, this.onClose});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: Text(title),
          leading: IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back),
              onPressed: onClose ?? () => Navigator.pop(context))),
      body: SafeArea(
          child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: Center(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: child)))));
}

class ElementPortraitCard extends StatelessWidget {
  final ElementPortrait portrait;
  final bool pair;
  const ElementPortraitCard(
      {super.key, required this.portrait, this.pair = false});
  @override
  Widget build(BuildContext context) {
    final i = portrait.element.index;
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
            color: elementTints[i], borderRadius: BorderRadius.circular(28)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const BrandMark(),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(
                child: Text(portrait.name,
                    style: Theme.of(context).textTheme.headlineMedium)),
            ExcludeSemantics(
                child: ElementSpirit(element: portrait.element, size: 88))
          ]),
          Text(portrait.element.label,
              style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1,
                  color: elementColors[i])),
          const SizedBox(height: 16),
          for (final t in portrait.traits)
            Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(elementTraits[i][t],
                    style: const TextStyle(fontSize: 16, height: 1.5))),
          if (pair && portrait.counts != null) ...[
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (var n = 0; n < 5; n++)
                Text(
                    '${[
                      'Wood',
                      'Fire',
                      'Earth',
                      'Metal',
                      'Water'
                    ][n]} ${portrait.counts![n]}',
                    style: const TextStyle(fontSize: 12))
            ]),
            if (portrait.unknownTime)
              const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Birth hour unknown · three pillars',
                      style: TextStyle(fontSize: 12))),
          ],
          const SizedBox(height: 12),
          const Text('A reflection from the Five Elements tradition',
              style: TextStyle(fontSize: 12, color: muted)),
        ]));
  }
}

class ShareComposer extends StatefulWidget {
  final AppState state;
  final String kind;
  final String? parentId;
  const ShareComposer(
      {super.key, required this.state, required this.kind, this.parentId});
  @override
  State<ShareComposer> createState() => _ShareComposerState();
}

class _ShareComposerState extends State<ShareComposer> {
  late final TextEditingController nickname;
  late final chart = widget.state.chart;
  final selected = <int>{0, 1};
  final cardKey = GlobalKey();
  bool agreed = false, busy = false;
  String? error;
  ShareEntry? entry;
  bool needsRetry = false;
  bool get pair => widget.kind == 'pair';
  ElementPortrait get portrait => ElementPortrait.fromChart(
      nickname.text.trim().isEmpty ? 'You' : nickname.text.trim(), chart,
      pair: pair, traits: selected.toList()..sort());
  @override
  void initState() {
    super.initState();
    nickname = TextEditingController(text: widget.state.name);
  }

  @override
  void dispose() {
    nickname.dispose();
    super.dispose();
  }

  Future<void> create() async {
    if (nickname.text.trim().isEmpty ||
        nickname.text.trim().runes.length > 30 ||
        RegExp(r'[<>\x00-\x1f]').hasMatch(nickname.text)) {
      setState(() => error = 'Use a nickname of 1–30 characters.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final e = await widget.state.sharing
          .create(widget.kind, portrait, parentId: widget.parentId);
      if (mounted) setState(() => entry = e);
    } on ShareFailure catch (e) {
      if (mounted) {
        setState(() {
          error = e.message;
          needsRetry = true;
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> shareImage(BuildContext buttonContext) async {
    setState(() => error = null);
    try {
      final boundary =
          cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (!buttonContext.mounted || data == null) return;
      final box = buttonContext.findRenderObject() as RenderBox;
      await Share.shareXFiles([
        XFile.fromData(data.buffer.asUint8List(),
            mimeType: 'image/png', name: 'fatepair-element.png')
      ],
          fileNameOverrides: [
            'fatepair-element.png'
          ],
          text: 'What happens when our elements meet? ${entry!.url}',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } catch (_) {
      if (mounted) {
        setState(() => error =
            'Image sharing is unavailable here. You can still copy the link.');
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !busy,
      child: ShareFrame(
          title: entry == null
              ? (pair ? 'Invite a friend' : 'Share my element')
              : 'Your link is ready',
          onClose: busy ? () {} : null,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            RepaintBoundary(
                key: cardKey,
                child: ElementPortraitCard(
                    portrait: entry?.portrait ?? portrait, pair: pair)),
            const SizedBox(height: 24),
            if (entry == null) ...[
              TextField(
                  key: const ValueKey('share-nickname'),
                  controller: nickname,
                  enabled: !busy,
                  maxLength: 30,
                  decoration:
                      const InputDecoration(labelText: 'Nickname on the card'),
                  onChanged: (_) => setState(() {})),
              const SizedBox(height: 8),
              const Text('Choose up to two reflections',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              for (var i = 0; i < 3; i++)
                CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(elementTraits[chart.dayElement.index][i]),
                    value: selected.contains(i),
                    onChanged: busy
                        ? null
                        : (v) => setState(() {
                              if (v == false) {
                                selected.remove(i);
                              } else if (selected.length < 2) {
                                selected.add(i);
                              }
                            })),
              const SizedBox(height: 16),
              Text(pair
                  ? 'Anyone with your link can see this card. One friend can join. Only the two of you can access the shared result.'
                  : 'Anyone with your link can see this card. They can start their own reading from it.'),
              const SizedBox(height: 10),
              const Text(
                  'No birth date, time, birthplace or conversations are shared. The link expires in 7 days. You can withdraw it from My shared links. Copies of shared images cannot be recalled.',
                  style: TextStyle(fontSize: 13, color: muted)),
              CheckboxListTile(
                  key: const ValueKey('share-consent'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('I want to share the card shown above'),
                  value: agreed,
                  onChanged:
                      busy ? null : (v) => setState(() => agreed = v == true)),
              const SizedBox(height: 12),
              FilledButton(
                  key: const ValueKey('share-create'),
                  onPressed: agreed && !busy && !needsRetry ? create : null,
                  child: Text(busy ? 'Creating link…' : 'Create link')),
              if (error != null)
                TextButton(
                    onPressed: () => showSharedLinks(context, widget.state),
                    child: const Text('Check saved links / retry')),
            ] else ...[
              Text(pair
                  ? 'Send this link to one friend.'
                  : 'Share your card with someone you know.'),
              const SizedBox(height: 14),
              ShareLinkActions(entry: entry!),
              const SizedBox(height: 10),
              Builder(
                  builder: (ctx) => OutlinedButton.icon(
                      onPressed: () => shareImage(ctx),
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Share card image'))),
              const SizedBox(height: 10),
              OutlinedButton(
                  onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<void>(
                          builder: (_) => SharedLinkPage(
                              state: widget.state,
                              id: entry!.id,
                              onExit: () => Navigator.pop(context)))),
                  child: const Text('Open shared link')),
              TextButton(
                  onPressed: () => showSharedLinks(context, widget.state),
                  child: const Text('My shared links')),
            ],
            if (error != null) ShareErrorText(error!),
          ])));
}

class ShareLinkActions extends StatefulWidget {
  final ShareEntry entry;
  const ShareLinkActions({super.key, required this.entry});
  @override
  State<ShareLinkActions> createState() => _ShareLinkActionsState();
}

class _ShareLinkActionsState extends State<ShareLinkActions> {
  String? status;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Builder(
            builder: (ctx) => FilledButton.icon(
                icon: const Icon(Icons.ios_share),
                label: const Text('Share link'),
                onPressed: () async {
                  try {
                    final box = ctx.findRenderObject() as RenderBox;
                    await Share.share(
                        'What happens when our elements meet? ${widget.entry.url}',
                        subject: 'FatePair',
                        sharePositionOrigin:
                            box.localToGlobal(Offset.zero) & box.size);
                  } catch (_) {
                    if (mounted) {
                      setState(() => status =
                          'Sharing is unavailable here. Use Copy link.');
                    }
                  }
                })),
        const SizedBox(height: 10),
        OutlinedButton.icon(
            icon: const Icon(Icons.link),
            label: const Text('Copy link'),
            onPressed: () async {
              try {
                await Clipboard.setData(ClipboardData(text: widget.entry.url));
                if (mounted) setState(() => status = 'Link copied');
              } catch (_) {
                if (mounted) {
                  setState(() => status = 'Select and copy the link below.');
                }
              }
            }),
        if (status != null)
          Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(status!, semanticsLabel: status)),
        const SizedBox(height: 10),
        SelectableText(widget.entry.url,
            style: const TextStyle(fontSize: 12, color: muted)),
      ]);
}

class SharedLinkPage extends StatefulWidget {
  final AppState state;
  final String id;
  final VoidCallback onExit;
  const SharedLinkPage(
      {super.key, required this.state, required this.id, required this.onExit});
  @override
  State<SharedLinkPage> createState() => _SharedLinkPageState();
}

class _SharedLinkPageState extends State<SharedLinkPage> {
  SharedLink? link;
  String? error;
  bool busy = false, loading = true, review = false, agreed = false;
  ElementPortrait? candidate;
  int requestGeneration = 0;
  Timer? expiryTimer;
  ShareEntry? get entry => widget.state.sharing.find(widget.id);
  bool get owner => entry?.role == 'owner';
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    requestGeneration++;
    expiryTimer?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    final request = ++requestGeneration;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final e = entry;
      SharedLink next;
      try {
        next = await widget.state.sharing.repository
            .get(widget.id, secret: e?.secret);
      } on ShareFailure catch (failure) {
        if (e?.pending == true &&
            e?.role == 'guest' &&
            failure.code == 'unauthorized') {
          next = await widget.state.sharing.repository.get(widget.id);
        } else {
          rethrow;
        }
      }
      if (!mounted || request != requestGeneration) return;
      expiryTimer?.cancel();
      expiryTimer = Timer(next.expiresAt.difference(DateTime.now()), () {
        if (mounted) {
          setState(() {
            link = null;
            review = false;
            candidate = null;
            error = const ShareFailure('expired_or_missing').message;
          });
        }
      });
      setState(() => link = next);
      if (e == null) {
        unawaited(widget.state.sharing.repository
            .opened(widget.id)
            .catchError((_) {}));
      }
    } on ShareFailure catch (e) {
      if (mounted && request == requestGeneration) {
        setState(() {
          error = e.message;
          link = null;
          review = false;
          candidate = null;
        });
      }
    } finally {
      if (mounted && request == requestGeneration) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> prepare() async {
    final saved = await showProfileEditor(context, widget.state);
    if (!mounted || !saved || !widget.state.personalized) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() {
      candidate = ElementPortrait.fromChart(
          widget.state.name, widget.state.chart,
          pair: true);
      review = true;
      agreed = false;
    });
  }

  Future<void> join() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.state.sharing.join(widget.id, candidate!, link!.expiresAt);
      if (mounted) {
        setState(() => review = false);
        await load();
      }
    } on ShareFailure catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> reading() async {
    if (!widget.state.personalized) {
      await showProfileEditor(context, widget.state);
    }
    if (!mounted || !widget.state.personalized) return;
    if (await widget.state.chooseIntent(AppIntent.chart)) {
      widget.onExit();
    } else if (mounted) {
      setState(() => error = 'Could not save your choice. Try again.');
    }
  }

  Future<void> withdraw() async {
    final e = entry;
    if (e == null) return;
    final yes = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('Withdraw this link?'),
                content: const Text(
                    'The card and any shared result will become unavailable to both people.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Keep link')),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Withdraw'))
                ]));
    if (yes != true || !mounted) return;
    setState(() => busy = true);
    final ok = await widget.state.sharing.revoke(e);
    if (!mounted) return;
    setState(() => busy = false);
    if (ok) {
      widget.onExit();
    } else {
      setState(() => error =
          'Could not withdraw the link. Your access is kept here; try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = link;
    return PopScope(
        canPop: !busy,
        child: ShareFrame(
            title: review
                ? 'Your shared details'
                : data?.result != null
                    ? 'Your elements together'
                    : data?.kind == 'pair'
                        ? 'Compare with ${data!.portrait.name}'
                        : 'An element to explore',
            onClose: busy ? () {} : widget.onExit,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (loading)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator()))
                  else if (data != null) ...[
                    if (review) ...[
                      ElementPortraitCard(portrait: candidate!, pair: true),
                      const SizedBox(height: 24),
                      Text(
                          '${data.portrait.name} will see this summary and your shared result. Your birth details stay on this device.'),
                      const SizedBox(height: 10),
                      const Text(
                          'Either person can withdraw. This result expires with the invitation.',
                          style: TextStyle(color: muted, fontSize: 13)),
                      CheckboxListTile(
                          key: const ValueKey('join-consent'),
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                              'I agree to share this summary with my friend'),
                          value: agreed,
                          onChanged: busy
                              ? null
                              : (v) => setState(() => agreed = v == true)),
                      FilledButton(
                          key: const ValueKey('join-confirm'),
                          onPressed: agreed && !busy ? join : null,
                          child: Text(busy
                              ? 'Bringing your elements together…'
                              : 'See our result')),
                      TextButton(
                          onPressed: busy ? null : prepare,
                          child: const Text('Edit my details')),
                      TextButton(
                          onPressed: busy
                              ? null
                              : () => setState(() => review = false),
                          child: const Text('Not now')),
                    ] else if (data.result != null) ...[
                      PairResultView(result: data.result!),
                      const SizedBox(height: 24),
                      FilledButton(
                          onPressed: reading,
                          child: const Text('My full reading')),
                      const SizedBox(height: 10),
                      OutlinedButton(
                          onPressed: () => showShareComposer(
                              context, widget.state, 'pair',
                              parentId: widget.id),
                          child: const Text('Compare with another friend')),
                    ] else ...[
                      ElementPortraitCard(
                          portrait: data.portrait, pair: data.kind == 'pair'),
                      const SizedBox(height: 24),
                      if (owner) ...[
                        if (data.kind == 'pair')
                          const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Text('Waiting for your friend',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600))),
                        ShareLinkActions(entry: entry!),
                        if (data.kind == 'pair')
                          TextButton.icon(
                              onPressed: load,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Check for reply')),
                      ] else if (data.kind == 'pair' &&
                          data.status == 'open') ...[
                        const Text('What happens when our elements meet?',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        FilledButton(
                            key: const ValueKey('join-start'),
                            onPressed: prepare,
                            child: const Text('Add my birth details')),
                        const SizedBox(height: 12),
                        const Text(
                            'You will preview your summary before sharing it. No account or download needed.',
                            style: TextStyle(fontSize: 13, color: muted)),
                      ] else if (data.kind == 'pair') ...[
                        const Text('This invitation has already been joined.'),
                        const SizedBox(height: 12),
                        const Text(
                            'Open My shared links on the device you used to join, or ask for a new invitation.'),
                        TextButton(
                            onPressed: reading,
                            child: const Text('Explore my own reading')),
                      ] else ...[
                        FilledButton(
                            onPressed: () async {
                              if (!widget.state.personalized) {
                                await showProfileEditor(context, widget.state);
                              }
                              if (!mounted || !widget.state.personalized) {
                                return;
                              }
                              setState(() => candidate =
                                  ElementPortrait.fromChart(
                                      widget.state.name, widget.state.chart,
                                      pair: false));
                            },
                            child: const Text('Discover my element')),
                        if (candidate != null) ...[
                          const SizedBox(height: 24),
                          ElementPortraitCard(portrait: candidate!),
                          const SizedBox(height: 16),
                          FilledButton(
                              onPressed: reading,
                              child: const Text('My full reading')),
                          TextButton(
                              onPressed: () => showShareComposer(
                                  context, widget.state, 'portrait',
                                  parentId: widget.id),
                              child: const Text('Share my element')),
                          TextButton(
                              onPressed: () => showShareComposer(
                                  context, widget.state, 'pair',
                                  parentId: widget.id),
                              child: const Text('Compare with a friend')),
                        ],
                      ],
                    ],
                    const SizedBox(height: 24),
                    Text(
                        'Available until ${data.expiresAt.toLocal().toString().substring(0, 16)}',
                        style: const TextStyle(fontSize: 12, color: muted)),
                    if (entry != null && !review)
                      TextButton.icon(
                          onPressed: busy ? null : withdraw,
                          icon: const Icon(Icons.link_off),
                          label: const Text('Withdraw link and result')),
                  ],
                  if (error != null) ...[
                    ShareErrorText(error!),
                    if (!busy)
                      TextButton(
                          onPressed: load, child: const Text('Try again'))
                  ],
                  if (!loading && data == null)
                    OutlinedButton(
                        onPressed: reading,
                        child: const Text('Start my own reading')),
                ])));
  }
}

class PairResultView extends StatelessWidget {
  final Map<String, dynamic> result;
  const PairResultView({super.key, required this.result});
  @override
  Widget build(BuildContext context) {
    final host =
        ElementPortrait.fromJson(result['host'] as Map<String, dynamic>);
    final guest =
        ElementPortrait.fromJson(result['guest'] as Map<String, dynamic>);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: blueTint, borderRadius: BorderRadius.circular(28)),
          child: Column(children: [
            Row(children: [
              for (final p in [host, guest])
                Expanded(
                    child: Column(children: [
                  ElementSpirit(element: p.element, size: 90),
                  const SizedBox(height: 12),
                  Text(p.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600)),
                  Text(p.element.label,
                      style: TextStyle(color: elementColors[p.element.index]))
                ]))
            ]),
            const SizedBox(height: 24),
            Text(result['prompt'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w600, height: 1.5)),
          ])),
      const SizedBox(height: 26),
      Text('Something you share',
          style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text(result['commonTitle'] as String,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text(result['commonText'] as String),
      const SizedBox(height: 24),
      Text('A difference to explore',
          style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text(result['differenceTitle'] as String,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text(result['differenceText'] as String),
      const SizedBox(height: 20),
      if (result['unknownTime'] == true)
        const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
                'A birth hour is unknown. This reflection uses the available pillars only.',
                style: TextStyle(color: muted))),
      ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text('How this reflection works'),
          children: [Text(result['method'] as String)]),
    ]);
  }
}

class SharedLinksPage extends StatefulWidget {
  final AppState state;
  const SharedLinksPage({super.key, required this.state});
  @override
  State<SharedLinksPage> createState() => _SharedLinksPageState();
}

class _SharedLinksPageState extends State<SharedLinksPage> {
  bool busy = false;
  String? error;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
      listenable: widget.state.sharing,
      builder: (context, _) => ShareFrame(
          title: 'My shared links',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (widget.state.sharing.restoreError != null)
              ShareErrorText(widget.state.sharing.restoreError!),
            if (widget.state.sharing.entries.isEmpty) ...[
              const Text(
                  'Share an element card or invite someone you know to compare.'),
              const SizedBox(height: 20),
              FilledButton(
                  onPressed: () =>
                      showShareComposer(context, widget.state, 'pair'),
                  child: const Text('Compare with a friend')),
            ],
            for (final e in widget.state.sharing.entries.reversed)
              Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Surface(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                                e.role == 'guest'
                                    ? 'A comparison you joined'
                                    : e.kind == 'pair'
                                        ? 'Your friend invitation'
                                        : 'Your element card',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 18)),
                            const SizedBox(height: 8),
                            Text(e.portrait.name),
                            Text(
                                e.expired
                                    ? 'Expired'
                                    : e.pending
                                        ? 'Needs retry'
                                        : 'Expires ${e.expiresAt.toLocal().toString().substring(0, 10)}',
                                style: const TextStyle(
                                    color: muted, fontSize: 12)),
                            const SizedBox(height: 12),
                            if (!e.expired)
                              OutlinedButton(
                                  onPressed: busy
                                      ? null
                                      : () async {
                                          if (e.pending) {
                                            setState(() => busy = true);
                                            try {
                                              await widget.state.sharing
                                                  .send(e);
                                            } on ShareFailure catch (x) {
                                              if (mounted) {
                                                setState(
                                                    () => error = x.message);
                                              }
                                              return;
                                            } finally {
                                              if (mounted) {
                                                setState(() => busy = false);
                                              }
                                            }
                                          }
                                          if (context.mounted) {
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute<void>(
                                                    builder: (_) =>
                                                        SharedLinkPage(
                                                            state: widget.state,
                                                            id: e.id,
                                                            onExit: () =>
                                                                Navigator.pop(
                                                                    context))));
                                          }
                                        },
                                  child: Text(e.pending
                                      ? 'Retry saved request'
                                      : 'View link / result')),
                            TextButton(
                                onPressed: busy
                                    ? null
                                    : () async {
                                        setState(() => busy = true);
                                        final ok = await widget.state.sharing
                                            .revoke(e);
                                        if (mounted) {
                                          setState(() {
                                            busy = false;
                                            error = ok
                                                ? null
                                                : 'Could not withdraw. Try again when you are online.';
                                          });
                                        }
                                      },
                                child: Text(e.expired
                                    ? 'Remove expired link'
                                    : 'Withdraw link and result')),
                          ]))),
            if (error != null) ShareErrorText(error!),
            const SizedBox(height: 16),
            const Text(
                'Access is saved on this device. Links and shared results expire after seven days. A copied image cannot be withdrawn.',
                style: TextStyle(color: muted, fontSize: 13)),
          ])));
}

class ShareErrorText extends StatelessWidget {
  final String text;
  const ShareErrorText(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Semantics(
      liveRegion: true,
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(text, style: const TextStyle(color: coral))));
}
