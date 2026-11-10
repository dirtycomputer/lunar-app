import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/profile.dart';
import '../services/app_state.dart';
import '../services/bazi.dart';
import '../services/social.dart';
import 'design.dart';

class ConnectionsPage extends StatefulWidget {
  final AppState state;
  final Widget saved;
  final int initialTab;
  final VoidCallback onDiscover;
  final ValueChanged<MatchResult> onProfile;
  const ConnectionsPage(
      {super.key,
      required this.state,
      required this.saved,
      required this.onDiscover,
      required this.onProfile,
      this.initialTab = 0});
  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  late int tab = widget.initialTab;
  @override
  void didUpdateWidget(ConnectionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) tab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final state = widget.state;
    final people =
        state.matches.where((m) => !state.hidden.contains(m.person.id));
    final invitations = people
        .where((m) => state.social.invitations.contains(m.person.id))
        .toList();
    final conversations = people
        .where((m) => state.social.messagesFor(m.person.id).isNotEmpty)
        .toList()
      ..sort((a, b) => state.social
          .messagesFor(b.person.id)
          .last
          .createdAt
          .compareTo(state.social.messagesFor(a.person.id).last.createdAt));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.socialTitle, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 10),
      Text(l.socialSubtitle,
          style: const TextStyle(fontSize: 12, color: muted, height: 1.7)),
      const SizedBox(height: 22),
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final (i, label)
                in [l.tabSaved, l.socialInvitations, l.socialMessages].indexed)
              Padding(
                  padding: const EdgeInsetsDirectional.only(end: 9),
                  child: ChoiceChip(
                      key: ValueKey('social-tab-$i'),
                      label: Text(label),
                      selected: tab == i,
                      onSelected: (_) => setState(() => tab = i),
                      showCheckmark: false,
                      selectedColor: blueTint,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                          fontSize: 12,
                          color: tab == i ? blue : muted,
                          fontWeight: FontWeight.w600),
                      side: BorderSide(
                          color: tab == i ? blue.withValues(alpha: .2) : line),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 11))),
          ])),
      const SizedBox(height: 18),
      Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: mintTint, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Icon(Icons.lock_outline, size: 16, color: green),
            const SizedBox(width: 10),
            Expanded(
                child: Text(l.socialLocalNotice,
                    style: const TextStyle(
                        fontSize: 11, color: green, height: 1.6)))
          ])),
      const SizedBox(height: 26),
      if (tab == 0)
        widget.saved
      else if ((tab == 1 ? invitations : conversations).isEmpty)
        _SocialEmpty(
            icon: tab == 1 ? Icons.favorite_border : Icons.forum_outlined,
            title: tab == 1
                ? l.socialEmptyInvitesTitle
                : l.socialEmptyMessagesTitle,
            body:
                tab == 1 ? l.socialEmptyInvitesBody : l.socialEmptyMessagesBody,
            onDiscover: widget.onDiscover)
      else
        for (final m in tab == 1 ? invitations : conversations)
          Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Surface(
                  padding: const EdgeInsets.all(17),
                  child: Column(children: [
                    InkWell(
                        onTap: () => tab == 1
                            ? widget.onProfile(m)
                            : showLocalConversation(context, state, m.person),
                        borderRadius: BorderRadius.circular(12),
                        child: Row(children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(17),
                              child: Image.asset(m.person.image,
                                  width: 62, height: 70, fit: BoxFit.cover)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('${m.person.name}, ${m.person.age}',
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 5),
                                Text(
                                    tab == 1
                                        ? m.person.location
                                        : state.social
                                            .messagesFor(m.person.id)
                                            .last
                                            .text,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: muted,
                                        height: 1.6)),
                                const SizedBox(height: 5),
                                Text(
                                    tab == 1
                                        ? l.socialPending
                                        : l.socialNotSent,
                                    style: const TextStyle(
                                        fontSize: 10, color: green))
                              ])),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right,
                              size: 21, color: muted)
                        ])),
                    if (tab == 1)
                      Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                              onPressed: () async {
                                final ok =
                                    await state.social.withdraw(m.person.id);
                                if (context.mounted) {
                                  showToast(
                                      context,
                                      ok
                                          ? l.socialWithdrawn
                                          : l.socialSaveFailed);
                                }
                              },
                              child: Text(l.socialWithdraw,
                                  style: const TextStyle(fontSize: 11)))),
                  ]))),
    ]);
  }
}

class _SocialEmpty extends StatelessWidget {
  final IconData icon;
  final String title, body;
  final VoidCallback onDiscover;
  const _SocialEmpty(
      {required this.icon,
      required this.title,
      required this.body,
      required this.onDiscover});
  @override
  Widget build(BuildContext context) => Surface(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 35),
          child: Column(children: [
            Icon(icon, size: 38, color: green),
            const SizedBox(height: 20),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 11),
            Text(body,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, color: muted, height: 1.8)),
            const SizedBox(height: 23),
            FilledButton(
                onPressed: onDiscover,
                child: Text(AppLocalizations.of(context)!.discoverPeople))
          ])));
}

Future<void> showLocalConversation(
        BuildContext context, AppState state, Person person) =>
    showDialog<void>(
        context: context,
        builder: (_) => _Conversation(state: state, person: person));

class _Conversation extends StatefulWidget {
  final AppState state;
  final Person person;
  const _Conversation({required this.state, required this.person});
  @override
  State<_Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<_Conversation> {
  final input = TextEditingController();
  final scroll = ScrollController();
  bool saving = false;
  String? error;
  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (saving ||
        input.text.trim().isEmpty ||
        widget.state.hidden.contains(widget.person.id)) {
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final ok =
        await widget.state.social.saveMessage(widget.person.id, input.text);
    if (!mounted) return;
    setState(() {
      saving = false;
      if (ok) {
        input.clear();
      } else {
        error = AppLocalizations.of(context)!.socialSaveFailed;
      }
    });
    if (ok) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scroll.hasClients) {
          scroll.animateTo(scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = widget.person;
    return ListenableBuilder(
        listenable: widget.state,
        builder: (context, _) {
          final hidden = widget.state.hidden.contains(p.id);
          final messages = widget.state.social.messagesFor(p.id);
          return Dialog(
              backgroundColor: canvas,
              insetPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: 510, maxHeight: 650),
                  child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(children: [
                        Row(children: [
                          ClipOval(
                              child: Image.asset(p.image,
                                  width: 43, height: 43, fit: BoxFit.cover)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(p.name,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 3),
                                Text(l.socialNotSent,
                                    style: const TextStyle(
                                        fontSize: 10, color: muted))
                              ])),
                          IconButton(
                              tooltip: l.socialCloseConversation,
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, size: 20))
                        ]),
                        const SizedBox(height: 16),
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: mintTint,
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(
                                hidden
                                    ? l.socialHiddenNotice
                                    : l.socialMessageDisclaimer,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 10, color: green, height: 1.6))),
                        const SizedBox(height: 12),
                        Expanded(
                            child: ListView(controller: scroll, children: [
                          if (messages.isEmpty)
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 40, horizontal: 12),
                                child: Column(children: [
                                  const Icon(Icons.waving_hand_outlined,
                                      size: 37, color: green),
                                  const SizedBox(height: 18),
                                  Text(l.socialEmptyMessagesTitle,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 19),
                                  ActionChip(
                                      label: Text(l.socialTryIcebreaker,
                                          style: const TextStyle(fontSize: 11)),
                                      onPressed: hidden
                                          ? null
                                          : () => setState(() => input.text =
                                              l.socialIcebreaker(
                                                  p.name,
                                                  p.interests.first
                                                      .toLowerCase())))
                                ])),
                          for (final message in messages)
                            Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 380),
                                    margin: const EdgeInsetsDirectional.only(
                                        start: 36, top: 11),
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        color: blueTint,
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          SelectableText(message.text,
                                              style: const TextStyle(
                                                  fontSize: 12, height: 1.7)),
                                          const SizedBox(height: 6),
                                          Text(
                                              '${TimeOfDay.fromDateTime(message.createdAt.toLocal()).format(context)} · ${l.socialDraftStatus}',
                                              style: const TextStyle(
                                                  fontSize: 8, color: muted))
                                        ]))),
                        ])),
                        if (error != null)
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(error!,
                                  style: const TextStyle(
                                      fontSize: 11, color: coral))),
                        const SizedBox(height: 13),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: TextField(
                                      key:
                                          const ValueKey('local-message-input'),
                                      controller: input,
                                      enabled: !saving && !hidden,
                                      minLines: 1,
                                      maxLines: 3,
                                      maxLength:
                                          LocalSocialStore.maxMessageLength,
                                      textInputAction: TextInputAction.newline,
                                      style: const TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                          hintText: l.socialMessageHint,
                                          contentPadding:
                                              const EdgeInsets.all(15)))),
                              const SizedBox(width: 10),
                              Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: IconButton.filled(
                                      tooltip: l.socialSaveMessage,
                                      onPressed: saving || hidden ? null : save,
                                      icon: saving
                                          ? const SizedBox.square(
                                              dimension: 18,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2))
                                          : const Icon(Icons.arrow_upward,
                                              size: 20)))
                            ]),
                      ]))));
        });
  }
}
