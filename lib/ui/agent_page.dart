import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/chart_assistant.dart';
import '../services/bazi.dart' as bazi;
import 'design.dart';
import 'element_art.dart';

class AgentPage extends StatefulWidget {
  final ChartAgent agent;
  final bool personalized;
  final String name;
  final ChartContext? chart;
  final Map<String, dynamic> userContext;
  final VoidCallback onEdit, onSettings;
  const AgentPage(
      {super.key,
      required this.agent,
      required this.personalized,
      required this.name,
      required this.chart,
      required this.onEdit,
      required this.onSettings,
      this.userContext = const {}});
  @override
  State<AgentPage> createState() => _AgentPageState();
}

class _AgentPageState extends State<AgentPage> {
  final input = TextEditingController();
  final scroll = ScrollController();
  @override
  void initState() {
    super.initState();
    widget.agent.addListener(update);
  }

  void update() {
    if (mounted) setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scroll.hasClients) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        scroll.jumpTo(scroll.position.maxScrollExtent);
      } else {
        scroll.animateTo(scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 180), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    widget.agent.removeListener(update);
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  void ask([String? text]) {
    final q = (text ?? input.text).trim();
    if (q.isEmpty || widget.agent.busy || q.length > 2000) return;
    input.clear();
    widget.agent.ask(q, context: widget.chart, userContext: widget.userContext);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final a = widget.agent;
    final compact = MediaQuery.sizeOf(context).width < 700;
    return Center(
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
                padding: EdgeInsets.fromLTRB(compact ? 18 : 34, 18,
                    compact ? 18 : 34, compact ? 14 : 24),
                child: Column(children: [
                  SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          if (widget.personalized)
                            Text(widget.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600))
                          else
                            OutlinedButton.icon(
                                onPressed: widget.onEdit,
                                icon:
                                    const Icon(Icons.person_add_alt, size: 15),
                                label: Text(l.flowAddBirth)),
                          TextButton(
                              onPressed: widget.onSettings,
                              child: Text(l.flowConnectModel,
                                  style: const TextStyle(fontSize: 11))),
                          IconButton(
                              tooltip: l.flowClearChat,
                              onPressed: () {
                                input.clear();
                                a.clear();
                              },
                              icon: const Icon(Icons.add_comment_outlined,
                                  size: 19)),
                        ],
                      )),
                  const SizedBox(height: 12),
                  Expanded(
                      child: a.turns.isEmpty
                          ? Center(
                              child: SingleChildScrollView(
                                  child: Column(children: [
                              ElementSpirit(
                                  element:
                                      widget.chart?.natal.energy.dayElement ??
                                          bazi.Element.metal,
                                  size: 112),
                              const SizedBox(height: 28),
                              LayoutBuilder(
                                  builder: (context, c) => Wrap(
                                          spacing: 11,
                                          runSpacing: 11,
                                          children: [
                                            for (final q in widget.personalized
                                                ? [
                                                    l.flowQuestionOverview,
                                                    l.flowQuestionCycle,
                                                    l.flowQuestionWork,
                                                    l.flowQuestionRelations
                                                  ]
                                                : [
                                                    l.flowGeneralBazi,
                                                    l.flowGeneralGods,
                                                    l.flowGeneralMaster,
                                                    l.flowGeneralSolar
                                                  ])
                                              SizedBox(
                                                  width: c.maxWidth > 540
                                                      ? (c.maxWidth - 11) / 2
                                                      : c.maxWidth,
                                                  child: OutlinedButton(
                                                      onPressed: () => ask(q),
                                                      style: OutlinedButton.styleFrom(
                                                          alignment:
                                                              AlignmentDirectional
                                                                  .centerStart,
                                                          backgroundColor:
                                                              Colors.white,
                                                          padding:
                                                              const EdgeInsets.all(
                                                                  20),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      20))),
                                                      child: Text(q,
                                                          style: const TextStyle(
                                                              fontSize: 14,
                                                              height: 1.5))))
                                          ]))
                            ])))
                          : ListView(controller: scroll, children: [
                              for (final t in a.turns)
                                Align(
                                    alignment: t.role == 'user'
                                        ? AlignmentDirectional.centerEnd
                                        : AlignmentDirectional.centerStart,
                                    child: Container(
                                        constraints:
                                            const BoxConstraints(maxWidth: 720),
                                        margin:
                                            const EdgeInsets.only(bottom: 22),
                                        padding: EdgeInsets.all(
                                            t.role == 'user' ? 17 : 4),
                                        decoration: BoxDecoration(
                                            color: t.role == 'user'
                                                ? blueTint
                                                : null,
                                            borderRadius:
                                                BorderRadius.circular(17)),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (t.role == 'assistant')
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 10),
                                                    child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                              t.source ==
                                                                      'model'
                                                                  ? Icons
                                                                      .auto_awesome
                                                                  : Icons
                                                                      .menu_book_outlined,
                                                              size: 13,
                                                              color: green),
                                                          const SizedBox(
                                                              width: 6),
                                                          Text(
                                                              t.source ==
                                                                      'model'
                                                                  ? l.flowModel
                                                                  : l
                                                                      .flowReference,
                                                              style: const TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: green))
                                                        ])),
                                              SelectableText(t.text,
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      height: 1.9,
                                                      color: ink))
                                            ]))),
                              if (a.error != null)
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(a.error!,
                                              style: const TextStyle(
                                                  fontSize: 11, color: coral)),
                                          if (a.canRetry)
                                            TextButton.icon(
                                              key:
                                                  const ValueKey('agent-retry'),
                                              onPressed: a.retry,
                                              icon: const Icon(Icons.refresh,
                                                  size: 16),
                                              label: Text(l.releaseRetry),
                                            ),
                                        ])),
                              if (a.busy)
                                const Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox.square(
                                            dimension: 18,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2))))
                            ])),
                  const SizedBox(height: 12),
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: line)),
                      padding: const EdgeInsets.fromLTRB(16, 4, 7, 7),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                                child: TextField(
                                    key: const ValueKey('agent-question'),
                                    controller: input,
                                    minLines: 1,
                                    maxLines: compact ? 3 : 5,
                                    maxLength: 2000,
                                    enabled: !a.busy,
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (_) => ask(),
                                    style: const TextStyle(
                                        fontSize: 13, height: 1.7),
                                    decoration: InputDecoration(
                                        hintText: l.flowQuestionHint,
                                        counterText: '',
                                        filled: false,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 14)))),
                            IconButton.filled(
                                tooltip: a.busy ? l.flowStop : l.flowSend,
                                onPressed: a.busy ? a.cancel : ask,
                                icon: Icon(
                                    a.busy
                                        ? Icons.stop_rounded
                                        : Icons.arrow_upward,
                                    size: 21))
                          ])),
                ]))));
  }
}
