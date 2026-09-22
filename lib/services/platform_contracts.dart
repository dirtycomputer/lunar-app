import 'dart:convert';
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
        PlanId.free => 'Lunar Free',
        PlanId.plus => 'Lunar Plus',
        PlanId.pro => 'Lunar Pro',
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
  Future<bool> reportUser(ReportRecord record) async {
    try {
      final raw = preferences.getStringList('reports') ?? [];
      final updated = [...raw, jsonEncode(record.toJson())];
      return await preferences.setStringList('reports', updated);
    } catch (_) {
      return false;
    }
  }

  List<ReportRecord> loadReports() => (preferences.getStringList('reports') ??
          [])
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
  List<String> _keys() => preferences.getStringList('consents') ?? [];
  @override
  bool accepted(String id, String version) =>
      _keys().any((k) => k.startsWith('$id@$version@'));
  @override
  Future<bool> accept(String id, String version) async {
    final key = ConsentRecord(id, version, DateTime.now().toIso8601String()).key;
    final updated = [..._keys().where((k) => !k.startsWith('$id@')), key];
    try {
      return await preferences.setStringList('consents', updated);
    } catch (_) {
      return false;
    }
  }

  @override
  List<ConsentRecord> all() => _keys().map(ConsentRecord.fromKey).toList();
}

class LegalDocument {
  final String id, title, version, effective, body;
  const LegalDocument(this.id, this.title, this.version, this.effective,
      this.body);
}

// Placeholder drafts for the eight launch documents. Have counsel review
// before shipping to production; bodies are intentionally short summaries.
const legalDocuments = <LegalDocument>[
  LegalDocument(
      'terms',
      "Terms of Service",
      '1.0.0-draft',
      'Upon launch',
      "Placeholder. Will cover: eligibility (18+), your account, acceptable use, the cultural-and-entertainment nature of BaZi insights (no guarantee of accuracy or relationship outcomes), subscriptions and renewals, termination, disclaimers, limitation of liability, governing law of the Hong Kong operating entity, and dispute resolution.\n\n[Draft for legal review before launch.]"),
  LegalDocument(
      'privacy',
      "Privacy Policy",
      '1.0.0-draft',
      'Upon launch',
      "Placeholder. Will cover: data we collect (birth date, time, place, gender, preferences, photos, messages), purposes and legal bases, sensitive-category handling (birth details, orientation) with explicit consent under GDPR, retention and deletion, processors (hosting, payments, moderation), your rights (access, rectification, erasure, portability, objection), California privacy rights, children (18+ only), international transfers, and our contact address.\n\n[Draft for legal review before launch.]"),
  LegalDocument(
      'community',
      "Community Guidelines",
      '1.0.0-draft',
      'Upon launch',
      "Placeholder. Will cover: be 18+, be real (no impersonation), be respectful (no harassment, hate, threats), no nudity or sexual content in photos or messages, no solicitation or scamming, respect consent, and consequences (warning, removal, ban) plus how to appeal a moderation decision.\n\n[Draft for legal review before launch.]"),
  LegalDocument(
      'safety',
      "Dating Safety Guidelines",
      '1.0.0-draft',
      'Upon launch',
      "Placeholder. Safety Center content: take conversations at your pace, meet in public, tell a friend, never send money or financial details, watch for scam patterns, report and block freely, and consent reminders. Lunar culture scores are a conversation starter, never a safety judgment.\n\n[Draft for legal review before launch.]"),
  LegalDocument(
      'csae',
      "Child Safety (CSAE) Policy",
      '1.0.0-draft',
      'Upon launch',
      "Placeholder. Required by Google Play Child Safety Standards even though Lunar is 18+ only. Will cover: zero tolerance for child sexual abuse and exploitation (CSAE), prohibition of child sexual abuse material (CSAM), mandatory reporting paths to law enforcement and NCMEC where applicable, in-app reporting and escalation, a dedicated child-safety contact email, and account termination for violations.\n\n[Draft for legal review before launch.]"),
  LegalDocument(
      'deletion',
      "Account & Data Deletion Policy",
      '1.0.0-draft',
      'Upon launch',
      "Placeholder. Will cover: in-app account deletion (Settings → Privacy & your data), the web deletion request URL for users who have uninstalled, what is deleted versus retained (legal-hold and safety records), retention windows, and expected completion time.\n\n[Draft for legal review before launch.]"),
  LegalDocument(
      'subscription',
      "Subscription Terms",
      '1.0.0-draft',
      'Upon launch',
      "Placeholder. Will cover: plan names and prices per storefront, billing cycle, auto-renewal terms, how to cancel (store subscription settings), refunds per Apple/Google policy, price-change notice, and free-trial conversion terms if offered.\n\n[Draft for legal review before launch.]"),
  LegalDocument(
      'moderation',
      "Content Moderation & Reporting Policy",
      '1.0.0-draft',
      'Upon launch',
      "Placeholder. Will cover: what we moderate (profiles, photos, messages), automated and human review, report categories and response targets, the 48-hour removal process for non-consensual intimate imagery under the US TAKE IT DOWN Act (effective May 19, 2026), enforcement ladder, appeals, and moderation transparency commitments.\n\n[Draft for legal review before launch.]"),
];

LegalDocument? legalDocById(String id) {
  for (final d in legalDocuments) {
    if (d.id == id) return d;
  }
  return null;
}
