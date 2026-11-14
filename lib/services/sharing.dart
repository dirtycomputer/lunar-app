import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'device_storage.dart';
import 'bazi.dart';

const shareOrigin = String.fromEnvironment('FATEPAIR_CATALOG_URL',
    defaultValue: 'https://yuan-bazi-connections.dirtycomputer.chatgpt.site');
const elementTraits = [
  [
    'Make room for new ideas',
    'Grow through small steps',
    'Leave space to change direction'
  ],
  [
    'Bring warmth to a conversation',
    'Celebrate the little things',
    'Make room for a quieter pace'
  ],
  [
    'Build trust through consistency',
    'Create a place to feel at home',
    'Let others support you too'
  ],
  [
    'Find clarity in what matters',
    'Notice the thoughtful details',
    'Leave room for the unexpected'
  ],
  [
    'Stay curious about other people',
    'Take time to reflect',
    'Share what is on your mind'
  ],
];
String newShareToken() {
  final random = Random.secure();
  return base64Url.encode(List.generate(24, (_) => random.nextInt(256)));
}

String? shareIdFromUri(Uri uri) {
  // Flutter's default Web history may add #/ to a path-based invitation.
  // A generic fragment must not hide the invitation when the page reloads.
  for (final path in [uri.fragment, uri.path]) {
    final id = RegExp(r'^/s/([A-Za-z0-9_-]{32})/?$').firstMatch(path)?.group(1);
    if (id != null) return id;
  }
  return null;
}

class ElementPortrait {
  final String name;
  final Element element;
  final List<int> traits;
  final List<int>? counts;
  const ElementPortrait(
      {required this.name,
      required this.element,
      this.traits = const [0, 1],
      this.counts});
  factory ElementPortrait.fromChart(String name, EnergyChart chart,
          {required bool pair, List<int> traits = const [0, 1]}) =>
      ElementPortrait(
          name: name,
          element: chart.dayElement,
          traits: List.unmodifiable(traits),
          counts: pair
              ? [
                  for (final n in chart.distribution)
                    (n * chart.pillars.length * 2).round()
                ]
              : null);
  factory ElementPortrait.fromJson(Map<String, dynamic> j) => ElementPortrait(
      name: j['name'] as String,
      element: Element.values[j['element'] as int],
      traits: (j['traits'] as List).cast<int>(),
      counts: (j['counts'] as List?)?.cast<int>());
  Map<String, dynamic> toJson() => {
        'name': name,
        'element': element.index,
        'traits': traits,
        if (counts != null) 'counts': counts
      };
  bool get unknownTime => counts?.fold<int>(0, (a, b) => a + b) == 6;
}

class SharedLink {
  final String id, kind, status;
  final ElementPortrait portrait;
  final DateTime expiresAt;
  final Map<String, dynamic>? result;
  const SharedLink(
      {required this.id,
      required this.kind,
      required this.status,
      required this.portrait,
      required this.expiresAt,
      this.result});
  factory SharedLink.fromJson(Map<String, dynamic> j) => SharedLink(
      id: j['id'] as String,
      kind: j['kind'] as String,
      status: j['status'] as String,
      portrait: ElementPortrait.fromJson(j['portrait'] as Map<String, dynamic>),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
          (j['expiresAt'] as int) * 1000,
          isUtc: true),
      result: j['result'] as Map<String, dynamic>?);
}

class ShareFailure implements Exception {
  final String code;
  const ShareFailure(this.code);
  String get message => switch (code) {
        'expired_or_missing' =>
          'This link has expired or was withdrawn. Ask your friend for a new one.',
        'already_joined' =>
          'Someone has already joined this invitation. Ask your friend for a new one.',
        'rate_limited' =>
          'You have reached today’s sharing limit. Try again tomorrow.',
        'storage' =>
          'Could not save on this device. Please try again before sharing.',
        'unauthorized' => 'This device cannot access that shared result.',
        'invalid_input' => 'Check your nickname and selection, then try again.',
        'conflict' =>
          'This invitation cannot be used for that action. Create a new link.',
        _ => 'Could not reach sharing. Your details are kept here; try again.',
      };
}

class SharingRepository {
  final http.Client _client;
  final Uri origin;
  SharingRepository({http.Client? client, Uri? origin})
      : _client = client ?? http.Client(),
        origin = origin ?? Uri.parse(shareOrigin);
  Future<Map<String, dynamic>> _call(String method, String path,
      {String? secret, Map<String, dynamic>? body}) async {
    try {
      final r = http.Request(method, origin.resolve(path));
      r.headers['Content-Type'] = 'application/json';
      if (secret != null) r.headers['Authorization'] = 'Bearer $secret';
      if (body != null) r.body = jsonEncode(body);
      final response = await http.Response.fromStream(
              await _client.send(r).timeout(const Duration(seconds: 18)))
          .timeout(const Duration(seconds: 18));
      final value = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ShareFailure(value['code'] as String? ?? 'unavailable');
      }
      return value;
    } on ShareFailure {
      rethrow;
    } catch (_) {
      throw const ShareFailure('unavailable');
    }
  }

  Future<SharedLink> get(String id, {String? secret}) async =>
      SharedLink.fromJson(
          await _call('GET', '/api/shares/$id', secret: secret));
  Future<void> opened(String id) async {
    await _call('POST', '/api/shares/$id/open', body: {});
  }

  Future<DateTime> create(ShareEntry e) async {
    final j = await _call('POST', '/api/shares', secret: e.secret, body: {
      'id': e.id,
      'kind': e.kind,
      'portrait': e.portrait.toJson(),
      'consent': true,
      if (e.parentId != null) 'parentId': e.parentId
    });
    return DateTime.fromMillisecondsSinceEpoch((j['expiresAt'] as int) * 1000,
        isUtc: true);
  }

  Future<SharedLink> join(ShareEntry e) async =>
      SharedLink.fromJson(await _call('POST', '/api/shares/${e.id}/join',
          secret: e.secret,
          body: {'portrait': e.portrait.toJson(), 'consent': true}));
  Future<void> revoke(ShareEntry e) async {
    await _call('DELETE', '/api/shares/${e.id}', secret: e.secret);
  }

  void close() => _client.close();
}

class ShareEntry {
  final String id, secret, kind, role;
  final ElementPortrait portrait;
  final DateTime expiresAt;
  final bool pending;
  final String? parentId;
  const ShareEntry(
      {required this.id,
      required this.secret,
      required this.kind,
      required this.role,
      required this.portrait,
      required this.expiresAt,
      this.pending = false,
      this.parentId});
  String get url => Uri.parse(shareOrigin).resolve('/s/$id').toString();
  bool get expired => !expiresAt.isAfter(DateTime.now());
  ShareEntry saved(DateTime until) => ShareEntry(
      id: id,
      secret: secret,
      kind: kind,
      role: role,
      portrait: portrait,
      expiresAt: until,
      parentId: parentId);
  factory ShareEntry.fromJson(Map<String, dynamic> j) => ShareEntry(
      id: j['id'] as String,
      secret: j['secret'] as String,
      kind: j['kind'] as String,
      role: j['role'] as String,
      portrait: ElementPortrait.fromJson(j['portrait'] as Map<String, dynamic>),
      expiresAt: DateTime.parse(j['expiresAt'] as String),
      pending: j['pending'] == true,
      parentId: j['parentId'] as String?);
  Map<String, dynamic> toJson({bool credentials = true}) => {
        'id': id,
        if (credentials) 'secret': secret,
        'kind': kind,
        'role': role,
        'portrait': portrait.toJson(),
        'expiresAt': expiresAt.toIso8601String(),
        'pending': pending,
        if (parentId != null) 'parentId': parentId
      };
}

/// Persist credentials BEFORE a network write so ambiguous timeouts can be
/// retried idempotently and privacy deletion never loses a revocation handle.
class SharingStore extends ChangeNotifier {
  final DeviceStorage storage;
  final SharingRepository repository;
  List<ShareEntry> _entries = [];
  bool _disposed = false;
  String? restoreError;
  List<ShareEntry> get entries => List.unmodifiable(_entries);
  SharingStore(this.storage, {SharingRepository? repository})
      : repository = repository ?? SharingRepository() {
    try {
      final raw = storage.read<String>('sharing.v1');
      if (raw != null) {
        for (final value in jsonDecode(raw) as List) {
          try {
            final entry = ShareEntry.fromJson(value as Map<String, dynamic>);
            if (!RegExp(r'^[A-Za-z0-9_-]{32}$').hasMatch(entry.id) ||
                !RegExp(r'^[A-Za-z0-9_-]{32}$').hasMatch(entry.secret) ||
                !const ['owner', 'guest'].contains(entry.role) ||
                !const ['pair', 'portrait'].contains(entry.kind)) {
              throw const FormatException('Invalid shared access');
            }
            if (!_entries.any((x) => x.id == entry.id)) _entries.add(entry);
          } catch (_) {
            restoreError =
                'Some saved sharing access could not be read. Links expire after seven days.';
          }
        }
      }
    } catch (_) {
      restoreError =
          'Saved sharing access could not be read. Links expire after seven days.';
    }
  }
  ShareEntry? find(String id) {
    for (final e in _entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  Future<bool> _persist(List<ShareEntry> next) async {
    if (!await storage.preferences.setString(
        'sharing.v1', jsonEncode(next.map((e) => e.toJson()).toList()))) {
      return false;
    }
    _entries = next;
    if (!_disposed) notifyListeners();
    return true;
  }

  Future<ShareEntry> create(String kind, ElementPortrait portrait,
      {String? parentId}) async {
    final e = ShareEntry(
        id: newShareToken(),
        secret: newShareToken(),
        kind: kind,
        role: 'owner',
        portrait: portrait,
        expiresAt: DateTime.now().toUtc().add(const Duration(days: 7)),
        pending: true,
        parentId: parentId);
    await _remember(e);
    return send(e);
  }

  Future<ShareEntry> join(
      String id, ElementPortrait portrait, DateTime expiresAt) async {
    final existing = find(id);
    if (existing != null) {
      if (existing.role == 'owner') throw const ShareFailure('conflict');
      return send(existing);
    }
    final e = ShareEntry(
        id: id,
        secret: newShareToken(),
        kind: 'pair',
        role: 'guest',
        portrait: portrait,
        expiresAt: expiresAt,
        pending: true);
    await _remember(e);
    return send(e);
  }

  Future<void> _remember(ShareEntry e) async {
    final ok = await storage.write(
        () => _persist([..._entries.where((x) => !x.expired), e]),
        failure: false);
    if (!ok) throw const ShareFailure('storage');
  }

  Future<ShareEntry> send(ShareEntry e) async {
    ShareFailure? error;
    final saved = await storage.write<ShareEntry?>(() async {
      if (e.expired) throw const ShareFailure('expired_or_missing');
      try {
        final until = e.role == 'owner'
            ? await repository.create(e)
            : (await repository.join(e)).expiresAt;
        final done = e.saved(until);
        if (!await _persist([
          for (final x in _entries)
            if (x.id == e.id) done else x
        ])) {
          throw const ShareFailure('storage');
        }
        return done;
      } on ShareFailure catch (x) {
        error = x;
        return null;
      }
    }, failure: null);
    if (saved == null) throw error ?? const ShareFailure('storage');
    return saved;
  }

  Future<bool> revoke(ShareEntry e) => storage.write(() async {
        if (!e.expired) {
          try {
            await repository.revoke(e);
          } on ShareFailure catch (x) {
            // A pending join that lost a race owns no remote data.
            if (!(e.pending && e.role == 'guest' && x.code == 'unauthorized')) {
              rethrow;
            }
          }
        }
        return _persist(_entries.where((x) => x.id != e.id).toList());
      }, failure: false);
  // Called inside DeviceStorage's deletion barrier, after in-flight writes settle.
  Future<bool> revokeBeforeReset() async {
    for (final e in List<ShareEntry>.from(_entries)) {
      if (!e.expired) {
        try {
          await repository.revoke(e);
        } on ShareFailure catch (error) {
          if (!(e.pending &&
              e.role == 'guest' &&
              error.code == 'unauthorized')) {
            return false;
          }
        }
      }
      if (!await _persist(_entries.where((x) => x.id != e.id).toList())) {
        return false;
      }
    }
    return true;
  }

  void forget() {
    _entries = [];
    restoreError = null;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    repository.close();
    super.dispose();
  }
}
