import 'dart:convert';
import 'device_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Service contracts for the commercial launch. The Local* implementations
// below keep the prototype fully functional offline; replace them with
// backend/payment SDK implementations at launch without touching the UI.

enum Storefront { appleIap, googlePlayBilling, stripeWeb, none }

Storefront detectStorefront() {
  if (kIsWeb) return Storefront.stripeWeb;
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return Storefront.appleIap;
    case TargetPlatform.android:
      return Storefront.googlePlayBilling;
    default:
      return Storefront.none;
  }
}

String storefrontLabel(Storefront s) => switch (s) {
      Storefront.appleIap => 'Apple In-App Purchase',
      Storefront.googlePlayBilling => 'Google Play Billing',
      Storefront.stripeWeb => 'Stripe (web)',
      Storefront.none => 'None (development)',
    };

enum PlanId { free, plus, pro }

extension PlanInfo on PlanId {
  String get title => switch (this) {
        PlanId.free => 'FatePair Free',
        PlanId.plus => 'FatePair Plus',
        PlanId.pro => 'FatePair Pro',
      };
  String get subtitle => switch (this) {
        PlanId.free => 'Discovery, charts and saved connections.',
        PlanId.plus => 'More daily likes and full compatibility reports.',
        PlanId.pro => 'Everything in Plus, plus advanced cycle insights.',
      };
  String? get storeProductId => switch (this) {
        PlanId.free => null,
        PlanId.plus => 'lunar_plus_monthly',
        PlanId.pro => 'lunar_pro_monthly',
      };
}

enum SubscriptionStatus { inactive, active, inGracePeriod, expired }

class SubscriptionState {
  final PlanId plan;
  final SubscriptionStatus status;
  final DateTime? renewsAt;
  const SubscriptionState(
      {required this.plan, required this.status, this.renewsAt});
  bool get active =>
      status == SubscriptionStatus.active ||
      status == SubscriptionStatus.inGracePeriod;
}

const freeSubscription =
    SubscriptionState(plan: PlanId.free, status: SubscriptionStatus.inactive);

abstract class SubscriptionService {
  Future<SubscriptionState> status();
  Future<SubscriptionState> purchase(PlanId plan);
  Future<SubscriptionState> restore();
  Future<Uri?> manageSubscriptionUrl();
}

class LocalSubscriptionService implements SubscriptionService {
  // Launch wiring: StoreKit 2 on iOS, Play Billing on Android,
  // Stripe Checkout on web. Payments stay on the store for in-app digital
  // features (Apple guideline 3.1.1 / Google Play payments policy).
  @override
  Future<SubscriptionState> status() async => freeSubscription;
  @override
  Future<SubscriptionState> purchase(PlanId plan) async => freeSubscription;
  @override
  Future<SubscriptionState> restore() async => freeSubscription;
  @override
  Future<Uri?> manageSubscriptionUrl() async => null;
}

abstract class AccountService {
  Future<bool> deleteAccount();
  Future<String> exportDataJson();
}

class LocalAccountService implements AccountService {
  final Future<bool> Function() onLocalReset;
  final String Function() exportJson;
  LocalAccountService({required this.onLocalReset, required this.exportJson});
  // Launch wiring: DELETE /users/me on the backend, then clear local data.
  @override
  Future<bool> deleteAccount() => onLocalReset();
  @override
  Future<String> exportDataJson() async => exportJson();
}

enum ReportReason {
  harassment,
  nudityOrSexual,
  nonConsensualImagery,
  underage,
  impersonation,
  csae,
  spamOrScam,
  other,
}

extension ReportReasonInfo on ReportReason {
  String get label => switch (this) {
        ReportReason.harassment => 'Harassment or bullying',
        ReportReason.nudityOrSexual => 'Nudity or sexual content',
        ReportReason.nonConsensualImagery =>
          'Shared my private images without consent',
        ReportReason.underage => 'This person is under 18',
        ReportReason.impersonation => 'Impersonation or fake profile',
        ReportReason.csae => 'Child safety concern (CSAE)',
        ReportReason.spamOrScam => 'Spam, scam or fraud',
        ReportReason.other => 'Something else',
      };
}

class ReportRecord {
  final String id, userId, note, at;
  final int reasonIndex;
  const ReportRecord(
      {required this.id,
      required this.userId,
      required this.reasonIndex,
      required this.note,
      required this.at});
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'reasonIndex': reasonIndex,
        'note': note,
        'at': at,
      };
  factory ReportRecord.fromJson(Map<String, dynamic> json) => ReportRecord(
        id: json['id'] as String,
        userId: json['userId'] as String,
        reasonIndex: json['reasonIndex'] as int,
        note: json['note'] as String? ?? '',
        at: json['at'] as String,
      );
}

abstract class ModerationService {
  Future<bool> reportUser(ReportRecord record);
}

class LocalModerationService implements ModerationService {
  final SharedPreferences preferences;
  LocalModerationService(this.preferences);
  // Launch wiring: POST /reports into the Trust & Safety queue with a
  // 48-hour removal SLA for non-consensual imagery (TAKE IT DOWN Act).
  @override
  Future<bool> reportUser(ReportRecord record) =>
      DeviceStorage(preferences).write(() async {
        try {
          final raw =
              DeviceStorage(preferences).read<List<String>>('reports') ?? [];
          final updated = [...raw, jsonEncode(record.toJson())];
          return await preferences.setStringList('reports', updated);
        } catch (_) {
          return false;
        }
      }, failure: false);

  List<ReportRecord> loadReports() =>
      (DeviceStorage(preferences).read<List<String>>('reports') ?? [])
          .map((line) {
            try {
              return ReportRecord.fromJson(
                  jsonDecode(line) as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<ReportRecord>()
          .toList();
}

abstract class ConsentService {
  bool accepted(String id, String version);
  Future<bool> accept(String id, String version);
  List<ConsentRecord> all();
}

class ConsentRecord {
  final String id, version, at;
  const ConsentRecord(this.id, this.version, this.at);
  String get key => '$id@$version@$at';
  factory ConsentRecord.fromKey(String key) {
    final parts = key.split('@');
    return ConsentRecord(parts[0], parts[1], parts.length > 2 ? parts[2] : '');
  }
}

class LocalConsentService implements ConsentService {
  final SharedPreferences preferences;
  LocalConsentService(this.preferences);
  List<String> _keys() =>
      DeviceStorage(preferences).read<List<String>>('consents') ?? [];
  @override
  bool accepted(String id, String version) =>
      all().any((record) => record.id == id && record.version == version);
  @override
  Future<bool> accept(String id, String version) =>
      DeviceStorage(preferences).write(() async {
        final key =
            ConsentRecord(id, version, DateTime.now().toIso8601String()).key;
        final updated = [..._keys().where((k) => !k.startsWith('$id@')), key];
        try {
          return await preferences.setStringList('consents', updated);
        } catch (_) {
          return false;
        }
      }, failure: false);

  @override
  List<ConsentRecord> all() => _keys()
      .where((key) {
        final parts = key.split('@');
        return parts.length == 3 &&
            parts[0].isNotEmpty &&
            parts[1].isNotEmpty &&
            DateTime.tryParse(parts[2]) != null;
      })
      .map(ConsentRecord.fromKey)
      .toList();
}

class LegalDocument {
  final String id, title, version, effective, body;
  const LegalDocument(
      this.id, this.title, this.version, this.effective, this.body);
}

// Current, scoped preview notices. Production operator details remain a release gate.
const legalDocuments = <LegalDocument>[
  LegalDocument(
      "terms",
      "Terms of Service",
      "preview-2026-11-14",
      "14 November 2026",
      "FatePair is currently a public preview for adults aged 18 and over. You can calculate a chart, read cultural interpretations, ask the configured AI service questions, and explore 1,000 clearly labelled synthetic profiles stored in a shared database. Invitations to synthetic profiles, message drafts and reports remain on this device and are not delivered. You can separately create a real sharing link and send it yourself to a friend who chooses to join. There are no paid plans or live community accounts in this release.\n\nBaZi is a cultural tradition, not a scientifically validated prediction or a guarantee of personality, safety or relationship outcomes. AI explanations may be incorrect. Do not rely on them for medical, legal, financial or other consequential decisions. You are responsible for the information you enter. Do not submit someone else’s private birth information without permission."),
  LegalDocument(
      "privacy",
      "Privacy Notice",
      "preview-2026-11-14",
      "14 November 2026",
      "Your name and birth date, time, birthplace, time zone and longitude are used to calculate your chart on this device. Saved profiles, hidden profiles, consent records, sample invitations, message drafts, reports, chart settings and exploration progress are stored in this browser or app installation. This local storage is not an encrypted account vault. Your personal birth profile is not published to other members in this release. Friend-sharing links store only the nickname, selected reflections, day element and (for a comparison) element counts that you approve. Anyone with the invitation can see the initiating card; only the two participating device credentials can access the completed result. Either participant can withdraw it. Access expires after seven days; expired rows are purged on subsequent sharing requests. Device credentials are stored locally, server-side credentials are hashed, and full birth inputs and conversations never enter sharing records. Daily aggregate sharing events are kept for 90 days; hashed daily network counters used to limit abuse expire after two days. The public database contains synthetic catalog records, not registered members or your private device data.\n\nWhen you ask the configured interpretation service, the app sends your question, available birth inputs, calculated charts, selected conventions, the reading you are viewing, learning progress and the complete current conversation to that service. The default server recalculates the chart with lunar-python before asking DeepSeek. The service does not store request bodies; hosting providers and DeepSeek process requests under their own policies. Text you type is not automatically redacted. Custom model endpoints receive the data you submit to them.\n\nConversation history and custom model keys remain in session memory. Copy my data exports local records; Clear local data removes this app’s stored personal records and conversation state, while preserving language and unrelated preferences. Clearing this device does not erase the shared synthetic catalog, hosting records or model-provider records. Browser storage can be removed by the browser or operating system, and is not a backup. The operating entity, production support contact and live-community retention policy must be established before a commercial launch."),
  LegalDocument(
      "community",
      "Community Guidelines",
      "preview-2026-11-14",
      "14 November 2026",
      "Use the preview respectfully. Do not impersonate another person, harass or threaten others, share private information or images without permission, exploit children, solicit money, or attempt fraud. Only adults may use FatePair.\n\nThe people shown in this release are fictional samples. The local invitation and message tools do not contact them. A real community requires authenticated accounts, mutual consent and operational moderation before it can open."),
  LegalDocument(
      "safety",
      "Dating Safety",
      "preview-2026-11-14",
      "14 November 2026",
      "A compatibility score is a cultural conversation starter, never a safety assessment. If you meet someone through an online service, take your time, protect your address and financial information, never send money, and meet in a public place. Tell a trusted person where you will be. Consent can be withdrawn at any time.\n\nIf there is an immediate threat or a child is in danger, contact appropriate local emergency or child-protection services. The preview’s local report record is not an emergency or monitored support channel."),
  LegalDocument(
      "csae",
      "Child Safety",
      "preview-2026-11-14",
      "14 November 2026",
      "FatePair is for adults aged 18 and over. Child sexual abuse, exploitation and related material are prohibited. Do not upload or share such material. If a child is in immediate danger, contact the appropriate local authority.\n\nThis preview has no public uploads or delivered messages. Its report tool stores a record locally and does not notify a safety team. A dedicated child-safety contact, an operational escalation process and the applicable reporting arrangements are required before a live community launches."),
  LegalDocument(
      "deletion",
      "Local Data Deletion",
      "preview-2026-11-14",
      "14 November 2026",
      "Open Settings → Privacy & your data to copy or clear your local records. Clearing removes the birth profile, saved and hidden profiles, consent and report records, comparison charts, model settings, sample invitations, drafts and exploration progress from this installation. In-memory conversations and model keys are cleared. The chosen language and unrelated preferences are preserved.\n\nActive sharing links saved on this device are withdrawn before local deletion begins. If the network is unavailable, data and access remain for retry. Use this in-app control before clearing browser data or uninstalling; external removal loses withdrawal access until expiry. Copies or images already shared cannot be recalled.\n\nIf local deletion is interrupted, old personal records remain hidden and the app offers a retry. Startup also attempts to finish pending deletion. A failed deletion is not reported as successful. Copy data you want to keep before clearing. There is no cloud account to delete in this release, and local deletion cannot erase records held by an AI provider."),
  LegalDocument(
      "subscription",
      "Payments",
      "preview-2026-11-14",
      "14 November 2026",
      "This release does not sell subscriptions, process payments, offer paid trials or activate paid entitlements. All exploration tasks are optional and accessible without payment. Prices, billing policies and store purchase flows will be presented only if paid services are implemented."),
  LegalDocument(
      "moderation",
      "Reporting in this Preview",
      "preview-2026-11-14",
      "14 November 2026",
      "You can hide a fictional sample profile and save a local report with a reason and optional note. Hidden profiles are removed from your visible recommendations and local conversation list. Reports are included in your device data export and cleared with local data.\n\nReports are not delivered to moderators, and no response time or enforcement action is promised by this preview. Do not use this feature for urgent safety requests. A staffed review queue, contact and appeals process are required before real members can publish content or exchange messages."),
];

LegalDocument? legalDocById(String id) {
  for (final d in legalDocuments) {
    if (d.id == id) return d;
  }
  return null;
}
