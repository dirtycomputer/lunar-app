import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_no.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('fi'),
    Locale('fr'),
    Locale('he'),
    Locale('hi'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('ms'),
    Locale('nl'),
    Locale('no'),
    Locale('pl'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('sv'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('vi'),
    Locale('zh'),
    Locale('zh', 'TW')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Lunar — Find your kind of energy'**
  String get appTitle;

  /// No description provided for @languageName.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageName;

  /// No description provided for @consentLead.
  ///
  /// In en, this message translates to:
  /// **'I confirm I am 18 or older and I accept the '**
  String get consentLead;

  /// No description provided for @linkTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get linkTerms;

  /// No description provided for @consentAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get consentAnd;

  /// No description provided for @linkPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get linkPrivacy;

  /// No description provided for @consentEnd.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get consentEnd;

  /// No description provided for @consentError.
  ///
  /// In en, this message translates to:
  /// **'Please confirm you are 18+ and accept the terms.'**
  String get consentError;

  /// No description provided for @reportProfile.
  ///
  /// In en, this message translates to:
  /// **'Report this profile'**
  String get reportProfile;

  /// No description provided for @reportIntro.
  ///
  /// In en, this message translates to:
  /// **'Tell us what is wrong. Reports are reviewed by our moderation team, and the profile is hidden from your recommendations right away.'**
  String get reportIntro;

  /// No description provided for @reasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment or bullying'**
  String get reasonHarassment;

  /// No description provided for @reasonNudity.
  ///
  /// In en, this message translates to:
  /// **'Nudity or sexual content'**
  String get reasonNudity;

  /// No description provided for @reasonNcii.
  ///
  /// In en, this message translates to:
  /// **'Shared my private images without consent'**
  String get reasonNcii;

  /// No description provided for @reasonUnderage.
  ///
  /// In en, this message translates to:
  /// **'This person is under 18'**
  String get reasonUnderage;

  /// No description provided for @reasonImpersonation.
  ///
  /// In en, this message translates to:
  /// **'Impersonation or fake profile'**
  String get reasonImpersonation;

  /// No description provided for @reasonCsae.
  ///
  /// In en, this message translates to:
  /// **'Child safety concern (CSAE)'**
  String get reasonCsae;

  /// No description provided for @reasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam, scam or fraud'**
  String get reasonSpam;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get reasonOther;

  /// No description provided for @reportNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Anything else we should know? (optional)'**
  String get reportNoteHint;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get submitReport;

  /// No description provided for @reportReceivedToast.
  ///
  /// In en, this message translates to:
  /// **'Report received. This profile is now hidden.'**
  String get reportReceivedToast;

  /// No description provided for @reportFailedToast.
  ///
  /// In en, this message translates to:
  /// **'Could not submit the report. Please try again.'**
  String get reportFailedToast;

  /// No description provided for @actionHide.
  ///
  /// In en, this message translates to:
  /// **'Hide this profile'**
  String get actionHide;

  /// No description provided for @legalCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal & your data'**
  String get legalCenterTitle;

  /// No description provided for @legalCenterIntro.
  ///
  /// In en, this message translates to:
  /// **'Policies that will govern Lunar at launch. Tap to read the draft.'**
  String get legalCenterIntro;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @exportMyData.
  ///
  /// In en, this message translates to:
  /// **'Export my data (JSON)'**
  String get exportMyData;

  /// No description provided for @exportDoneToast.
  ///
  /// In en, this message translates to:
  /// **'A copy of your data is on the clipboard.'**
  String get exportDoneToast;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account & data'**
  String get deleteAccount;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account and data?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes your birth profile, saved connections, hidden profiles, reports and consents from this device. At launch this also deletes your account and data on Lunar servers. Safety and legal records may be retained where the law requires.'**
  String get deleteConfirmBody;

  /// No description provided for @keepAccount.
  ///
  /// In en, this message translates to:
  /// **'Keep account'**
  String get keepAccount;

  /// No description provided for @deleteEverything.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get deleteEverything;

  /// No description provided for @deleteDoneToast.
  ///
  /// In en, this message translates to:
  /// **'Your account and data have been deleted from this device.'**
  String get deleteDoneToast;

  /// No description provided for @deleteFailedToast.
  ///
  /// In en, this message translates to:
  /// **'Deletion failed. Please try again.'**
  String get deleteFailedToast;

  /// No description provided for @docTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get docTerms;

  /// No description provided for @docPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get docPrivacy;

  /// No description provided for @docCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community Guidelines'**
  String get docCommunity;

  /// No description provided for @docSafety.
  ///
  /// In en, this message translates to:
  /// **'Dating Safety Guidelines'**
  String get docSafety;

  /// No description provided for @docCsae.
  ///
  /// In en, this message translates to:
  /// **'Child Safety (CSAE) Policy'**
  String get docCsae;

  /// No description provided for @docDeletion.
  ///
  /// In en, this message translates to:
  /// **'Account & Data Deletion Policy'**
  String get docDeletion;

  /// No description provided for @docSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription Terms'**
  String get docSubscription;

  /// No description provided for @docModeration.
  ///
  /// In en, this message translates to:
  /// **'Content Moderation & Reporting Policy'**
  String get docModeration;

  /// No description provided for @legalPolicies.
  ///
  /// In en, this message translates to:
  /// **'Legal & policies'**
  String get legalPolicies;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Use system language'**
  String get languageSystem;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @planFree.
  ///
  /// In en, this message translates to:
  /// **'Lunar Free'**
  String get planFree;

  /// No description provided for @planPlus.
  ///
  /// In en, this message translates to:
  /// **'Lunar Plus'**
  String get planPlus;

  /// No description provided for @planPro.
  ///
  /// In en, this message translates to:
  /// **'Lunar Pro'**
  String get planPro;

  /// No description provided for @planFreeSub.
  ///
  /// In en, this message translates to:
  /// **'Discovery, charts and saved connections.'**
  String get planFreeSub;

  /// No description provided for @planPlusSub.
  ///
  /// In en, this message translates to:
  /// **'More daily likes and full compatibility reports.'**
  String get planPlusSub;

  /// No description provided for @planProSub.
  ///
  /// In en, this message translates to:
  /// **'Everything in Plus, plus advanced cycle insights.'**
  String get planProSub;

  /// No description provided for @tabDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get tabDiscover;

  /// No description provided for @tabSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get tabSaved;

  /// No description provided for @tabMyEnergy.
  ///
  /// In en, this message translates to:
  /// **'My energy'**
  String get tabMyEnergy;

  /// No description provided for @tabGuide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get tabGuide;

  /// No description provided for @tabStudio.
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get tabStudio;

  /// No description provided for @navConnections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get navConnections;

  /// No description provided for @navGuide.
  ///
  /// In en, this message translates to:
  /// **'The BaZi guide'**
  String get navGuide;

  /// No description provided for @navStudio.
  ///
  /// In en, this message translates to:
  /// **'Chart studio'**
  String get navStudio;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'A little fate. A real connection.'**
  String get tagline;

  /// No description provided for @yourSpace.
  ///
  /// In en, this message translates to:
  /// **'YOUR SPACE'**
  String get yourSpace;

  /// No description provided for @promoTitle.
  ///
  /// In en, this message translates to:
  /// **'Good things take alignment.'**
  String get promoTitle;

  /// No description provided for @promoBody.
  ///
  /// In en, this message translates to:
  /// **'Discover the energy that makes you, you.'**
  String get promoBody;

  /// No description provided for @promoCta.
  ///
  /// In en, this message translates to:
  /// **'Explore your chart'**
  String get promoCta;

  /// No description provided for @editProfileShort.
  ///
  /// In en, this message translates to:
  /// **'Edit your profile'**
  String get editProfileShort;

  /// No description provided for @demoProfile.
  ///
  /// In en, this message translates to:
  /// **'Your demo profile'**
  String get demoProfile;

  /// No description provided for @topbarSub.
  ///
  /// In en, this message translates to:
  /// **'Meaningful connections start with your energy.'**
  String get topbarSub;

  /// No description provided for @howLunarWorks.
  ///
  /// In en, this message translates to:
  /// **'How Lunar works'**
  String get howLunarWorks;

  /// No description provided for @heroEyebrow.
  ///
  /// In en, this message translates to:
  /// **'ANCIENT WISDOM. NEW CONNECTIONS.'**
  String get heroEyebrow;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'Some energies\njust belong together.'**
  String get heroTitle;

  /// No description provided for @heroBody.
  ///
  /// In en, this message translates to:
  /// **'Meet people who bring out your best,\nwith a little guidance from BaZi.'**
  String get heroBody;

  /// No description provided for @findEnergy.
  ///
  /// In en, this message translates to:
  /// **'Find my energy'**
  String get findEnergy;

  /// No description provided for @exploreEnergy.
  ///
  /// In en, this message translates to:
  /// **'Explore my energy'**
  String get exploreEnergy;

  /// No description provided for @discoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Find your kind of energy'**
  String get discoverTitle;

  /// No description provided for @discoverSub.
  ///
  /// In en, this message translates to:
  /// **'Thoughtfully matched. Naturally you.'**
  String get discoverSub;

  /// No description provided for @savedTitle.
  ///
  /// In en, this message translates to:
  /// **'A connection worth keeping'**
  String get savedTitle;

  /// No description provided for @savedSub.
  ///
  /// In en, this message translates to:
  /// **'Your saved people, all in one place.'**
  String get savedSub;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @filtered.
  ///
  /// In en, this message translates to:
  /// **'Filtered'**
  String get filtered;

  /// No description provided for @catForYou.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get catForYou;

  /// No description provided for @catHighHarmony.
  ///
  /// In en, this message translates to:
  /// **'High harmony'**
  String get catHighHarmony;

  /// No description provided for @catSameCity.
  ///
  /// In en, this message translates to:
  /// **'Same birth city'**
  String get catSameCity;

  /// No description provided for @catCreative.
  ///
  /// In en, this message translates to:
  /// **'Creative souls'**
  String get catCreative;

  /// No description provided for @countDiscover.
  ///
  /// In en, this message translates to:
  /// **'{n} connections to discover'**
  String countDiscover(int n);

  /// No description provided for @countSaved.
  ///
  /// In en, this message translates to:
  /// **'{n} saved connections'**
  String countSaved(int n);

  /// No description provided for @bestHarmony.
  ///
  /// In en, this message translates to:
  /// **'Best harmony first'**
  String get bestHarmony;

  /// No description provided for @curiosity.
  ///
  /// In en, this message translates to:
  /// **'A little curiosity can be the start of something good.'**
  String get curiosity;

  /// No description provided for @demoNotice.
  ///
  /// In en, this message translates to:
  /// **'Demo community · All profiles are illustrative'**
  String get demoNotice;

  /// No description provided for @harmonyPct.
  ///
  /// In en, this message translates to:
  /// **'{n}% harmony'**
  String harmonyPct(int n);

  /// No description provided for @savedToast.
  ///
  /// In en, this message translates to:
  /// **'{name} saved to your connections'**
  String savedToast(String name);

  /// No description provided for @removedToast.
  ///
  /// In en, this message translates to:
  /// **'{name} removed from connections'**
  String removedToast(String name);

  /// No description provided for @couldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Please try again.'**
  String get couldNotSave;

  /// No description provided for @saveTo.
  ///
  /// In en, this message translates to:
  /// **'Save {name}'**
  String saveTo(String name);

  /// No description provided for @unsave.
  ///
  /// In en, this message translates to:
  /// **'Unsave {name}'**
  String unsave(String name);

  /// No description provided for @compareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the comparison. Please try again.'**
  String get compareFailed;

  /// No description provided for @glanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Your energy, at a glance'**
  String get glanceTitle;

  /// No description provided for @glancePersonal.
  ///
  /// In en, this message translates to:
  /// **'A little insight into your nature.'**
  String get glancePersonal;

  /// No description provided for @glanceSample.
  ///
  /// In en, this message translates to:
  /// **'Meet your sample birth chart.'**
  String get glanceSample;

  /// No description provided for @seeChart.
  ///
  /// In en, this message translates to:
  /// **'See my full chart'**
  String get seeChart;

  /// No description provided for @wisdomEyebrow.
  ///
  /// In en, this message translates to:
  /// **'A MOMENT OF WISDOM'**
  String get wisdomEyebrow;

  /// No description provided for @wisdomTitle.
  ///
  /// In en, this message translates to:
  /// **'You don’t need to be\nthe same to be in sync.'**
  String get wisdomTitle;

  /// No description provided for @wisdomBody.
  ///
  /// In en, this message translates to:
  /// **'In BaZi, different elements can bring out the best in each other. Balance is a beautiful thing.'**
  String get wisdomBody;

  /// No description provided for @wisdomCta.
  ///
  /// In en, this message translates to:
  /// **'Get to know the Five Elements'**
  String get wisdomCta;

  /// No description provided for @detailsYours.
  ///
  /// In en, this message translates to:
  /// **'Your details stay yours.'**
  String get detailsYours;

  /// No description provided for @detailsStored.
  ///
  /// In en, this message translates to:
  /// **'Birth details are stored on this device. They’re never shown on your public profile.'**
  String get detailsStored;

  /// No description provided for @privacyData.
  ///
  /// In en, this message translates to:
  /// **'Privacy & your data'**
  String get privacyData;

  /// No description provided for @emptySavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Good connections are worth saving.'**
  String get emptySavedTitle;

  /// No description provided for @emptySavedBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a profile to keep it here.'**
  String get emptySavedBody;

  /// No description provided for @emptyFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'A little more room to explore.'**
  String get emptyFilterTitle;

  /// No description provided for @emptyFilterBody.
  ///
  /// In en, this message translates to:
  /// **'Try a wider age range or explore worldwide.'**
  String get emptyFilterBody;

  /// No description provided for @discoverPeople.
  ///
  /// In en, this message translates to:
  /// **'Discover people'**
  String get discoverPeople;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get resetFilters;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Make room for your kind of people'**
  String get filterTitle;

  /// No description provided for @showMe.
  ///
  /// In en, this message translates to:
  /// **'Show me'**
  String get showMe;

  /// No description provided for @genderEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get genderEveryone;

  /// No description provided for @genderWomen.
  ///
  /// In en, this message translates to:
  /// **'Women'**
  String get genderWomen;

  /// No description provided for @genderMen.
  ///
  /// In en, this message translates to:
  /// **'Men'**
  String get genderMen;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @regionWorldwide.
  ///
  /// In en, this message translates to:
  /// **'Worldwide'**
  String get regionWorldwide;

  /// No description provided for @regionUSA.
  ///
  /// In en, this message translates to:
  /// **'USA'**
  String get regionUSA;

  /// No description provided for @regionUK.
  ///
  /// In en, this message translates to:
  /// **'UK'**
  String get regionUK;

  /// No description provided for @regionFrance.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get regionFrance;

  /// No description provided for @regionAustralia.
  ///
  /// In en, this message translates to:
  /// **'Australia'**
  String get regionAustralia;

  /// No description provided for @regionSingapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get regionSingapore;

  /// No description provided for @ageRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age range · {a}–{b}'**
  String ageRangeLabel(int a, int b);

  /// No description provided for @minHarmony.
  ///
  /// In en, this message translates to:
  /// **'Minimum harmony · {n}%'**
  String minHarmony(int n);

  /// No description provided for @harmonyNote.
  ///
  /// In en, this message translates to:
  /// **'Harmony is a cultural exploration score, not a prediction of relationship success.'**
  String get harmonyNote;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @showConnections.
  ///
  /// In en, this message translates to:
  /// **'Show connections'**
  String get showConnections;

  /// No description provided for @dayMasterContext.
  ///
  /// In en, this message translates to:
  /// **'{name}’s day master is {identity}. The badge shows their day element and polarity.'**
  String dayMasterContext(String name, String identity);

  /// No description provided for @energyTitle.
  ///
  /// In en, this message translates to:
  /// **'A nature all your own.'**
  String get energyTitle;

  /// No description provided for @energySub.
  ///
  /// In en, this message translates to:
  /// **'Get to know the elements that make you, you.'**
  String get energySub;

  /// No description provided for @editBirth.
  ///
  /// In en, this message translates to:
  /// **'Edit birth details'**
  String get editBirth;

  /// No description provided for @sampleNotice.
  ///
  /// In en, this message translates to:
  /// **'You’re exploring a sample chart. Add your own birth details for a personal reading.'**
  String get sampleNotice;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @dayMasterBody.
  ///
  /// In en, this message translates to:
  /// **'Your day master is the central element of your BaZi chart. Think of it as a lens for reflection, with plenty of room to be yourself.'**
  String get dayMasterBody;

  /// No description provided for @whatIsDayMaster.
  ///
  /// In en, this message translates to:
  /// **'What is a day master?'**
  String get whatIsDayMaster;

  /// No description provided for @myDayMasterContext.
  ///
  /// In en, this message translates to:
  /// **'Your day master is {identity} — the stem at the top of your day pillar.'**
  String myDayMasterContext(String identity);

  /// No description provided for @fiveElements.
  ///
  /// In en, this message translates to:
  /// **'Your Five Elements'**
  String get fiveElements;

  /// No description provided for @elementsContext.
  ///
  /// In en, this message translates to:
  /// **'The visible stems and branches of your chart add up to this distribution.'**
  String get elementsContext;

  /// No description provided for @elementsSub.
  ///
  /// In en, this message translates to:
  /// **'The visible stems and branches in your chart.'**
  String get elementsSub;

  /// No description provided for @fourPillars.
  ///
  /// In en, this message translates to:
  /// **'Your Four Pillars'**
  String get fourPillars;

  /// No description provided for @pillarsContext.
  ///
  /// In en, this message translates to:
  /// **'Each pillar below pairs a heavenly stem with an earthly branch.'**
  String get pillarsContext;

  /// No description provided for @pillarsSub.
  ///
  /// In en, this message translates to:
  /// **'Four moments, eight characters, one unique combination.'**
  String get pillarsSub;

  /// No description provided for @pillarContext.
  ///
  /// In en, this message translates to:
  /// **'Your {pillar} pillar is {combo}. The heavenly stem gives this card its element color.'**
  String pillarContext(String pillar, String combo);

  /// No description provided for @hourUnknown.
  ///
  /// In en, this message translates to:
  /// **'Hour unknown'**
  String get hourUnknown;

  /// No description provided for @hourUnknownBody.
  ///
  /// In en, this message translates to:
  /// **'Add a birth time for your fourth pillar.'**
  String get hourUnknownBody;

  /// No description provided for @contextTitle.
  ///
  /// In en, this message translates to:
  /// **'A little context goes a long way.'**
  String get contextTitle;

  /// No description provided for @calcNote.
  ///
  /// In en, this message translates to:
  /// **'Calculated with {zone} birth time and local mean solar time at {lon}° longitude. Year and month follow solar-term boundaries. Day changes at midnight.'**
  String calcNote(String zone, String lon);

  /// No description provided for @noTimeBoundaryNote.
  ///
  /// In en, this message translates to:
  /// **'Without an exact birth time, the hour is omitted and boundary dates may be uncertain.'**
  String get noTimeBoundaryNote;

  /// No description provided for @solarWhy.
  ///
  /// In en, this message translates to:
  /// **'Why solar time matters'**
  String get solarWhy;

  /// No description provided for @solarContext.
  ///
  /// In en, this message translates to:
  /// **'This chart uses local mean solar time at {lon}° longitude.'**
  String solarContext(String lon);

  /// No description provided for @understandChart.
  ///
  /// In en, this message translates to:
  /// **'Understand your chart'**
  String get understandChart;

  /// No description provided for @guideEyebrow.
  ///
  /// In en, this message translates to:
  /// **'A LITTLE WISDOM, A LOT OF POSSIBILITY'**
  String get guideEyebrow;

  /// No description provided for @guideTitle.
  ///
  /// In en, this message translates to:
  /// **'Ancient roots.\nHuman connections.'**
  String get guideTitle;

  /// No description provided for @guideIntro.
  ///
  /// In en, this message translates to:
  /// **'BaZi is a traditional Chinese system for exploring the patterns of a birth moment. Lunar brings that tradition into a more curious, connected world.'**
  String get guideIntro;

  /// No description provided for @meetElements.
  ///
  /// In en, this message translates to:
  /// **'Meet the Five Elements'**
  String get meetElements;

  /// No description provided for @elementsTagline.
  ///
  /// In en, this message translates to:
  /// **'Different by nature. Better in balance.'**
  String get elementsTagline;

  /// No description provided for @guidePillarsTitle.
  ///
  /// In en, this message translates to:
  /// **'What are the Four Pillars?'**
  String get guidePillarsTitle;

  /// No description provided for @guidePillarsBody.
  ///
  /// In en, this message translates to:
  /// **'Your birth year, month, day, and hour each form a pillar. Each pillar has a heavenly stem and an earthly branch — eight characters in total. That is what BaZi means: “eight characters.” Your day stem is called your day master.'**
  String get guidePillarsBody;

  /// No description provided for @guideHarmonyTitle.
  ///
  /// In en, this message translates to:
  /// **'How does Lunar calculate harmony?'**
  String get guideHarmonyTitle;

  /// No description provided for @guideHarmonyBody.
  ///
  /// In en, this message translates to:
  /// **'Our demo score combines three transparent factors: 45% combined element balance, measured by the normalized entropy of visible elements; 35% day master connection, based on the generating cycle; and 20% day branch resonance, using traditional pairs, trines, and oppositions. Scores are computed from the charts and recommendations are sorted from highest to lowest.'**
  String get guideHarmonyBody;

  /// No description provided for @guideScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'What does a high score mean?'**
  String get guideScoreTitle;

  /// No description provided for @guideScoreBody.
  ///
  /// In en, this message translates to:
  /// **'It means two charts align under our chosen rules. These rules are an interpretive product choice, not a scientific test of personality or relationship success. A score should invite a conversation, never decide who deserves one. Shared values, kindness, consent, and real-life chemistry matter.'**
  String get guideScoreBody;

  /// No description provided for @guideTimezoneTitle.
  ///
  /// In en, this message translates to:
  /// **'How do time zones work?'**
  String get guideTimezoneTitle;

  /// No description provided for @guideTimezoneBody.
  ///
  /// In en, this message translates to:
  /// **'Lunar resolves your birth time using the IANA time-zone database, including historical daylight saving rules. Year and month use the calendar library’s solar-term instants in UTC+8. Dating recommendations use local mean solar time based on birthplace longitude, with the day changing at midnight. Chart Studio additionally supports local clock time, true solar time with an approximate equation-of-time correction, and a 23:00 day boundary. During a repeated clock-change time, the earlier occurrence is used; nonexistent clock-change times are rejected. Other BaZi schools may produce different charts.'**
  String get guideTimezoneBody;

  /// No description provided for @guideNoTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'What if I don’t know my birth time?'**
  String get guideNoTimeTitle;

  /// No description provided for @guideNoTimeBody.
  ///
  /// In en, this message translates to:
  /// **'You can still explore. Lunar uses local noon for the date calculation, omits the hour pillar, and marks your results as approximate. On dates near a solar-term boundary, year or month may be uncertain too. Add your time later to refine your chart.'**
  String get guideNoTimeBody;

  /// No description provided for @guideCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Is this a live dating community?'**
  String get guideCommunityTitle;

  /// No description provided for @guideCommunityBody.
  ///
  /// In en, this message translates to:
  /// **'This first version is an interactive, local demo. The people shown are fictional profiles paired with stock photographs. You can explore charts, filter recommendations, and save connections on this device. Accounts, messages, verification, and a real community will be part of a future backend integration.'**
  String get guideCommunityBody;

  /// No description provided for @digDeeper.
  ///
  /// In en, this message translates to:
  /// **'DIG DEEPER'**
  String get digDeeper;

  /// No description provided for @termFourPillars.
  ///
  /// In en, this message translates to:
  /// **'Four pillars'**
  String get termFourPillars;

  /// No description provided for @termStemsBranches.
  ///
  /// In en, this message translates to:
  /// **'Heavenly stems & earthly branches'**
  String get termStemsBranches;

  /// No description provided for @termDayMaster.
  ///
  /// In en, this message translates to:
  /// **'Day master'**
  String get termDayMaster;

  /// No description provided for @termTenGods.
  ///
  /// In en, this message translates to:
  /// **'Ten Gods'**
  String get termTenGods;

  /// No description provided for @termCombinations.
  ///
  /// In en, this message translates to:
  /// **'Combinations'**
  String get termCombinations;

  /// No description provided for @termSolarTime.
  ///
  /// In en, this message translates to:
  /// **'True solar time'**
  String get termSolarTime;

  /// No description provided for @guideFooter.
  ///
  /// In en, this message translates to:
  /// **'Stay curious. Be kind. Leave room for a little serendipity.'**
  String get guideFooter;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your details stay yours.'**
  String get privacyTitle;

  /// No description provided for @privacyBody1.
  ///
  /// In en, this message translates to:
  /// **'This app saves your name, birth details, studio charts, model settings, saved connections, and hidden profiles on this device. Client API keys stay in memory. When you choose to generate an interpretation, calculated chart evidence is sent to your selected model provider. Names, exact birth dates and places are omitted from that evidence. Resetting local data does not erase provider records or the local server’s API key. Invitations and local message drafts are also stored on this device and included in your data export.'**
  String get privacyBody1;

  /// No description provided for @privacyBody2.
  ///
  /// In en, this message translates to:
  /// **'Local storage is not encrypted. On a shared device, clear your data when you are done. Clearing browser or app data also removes your profile.'**
  String get privacyBody2;

  /// No description provided for @privacyBody3.
  ///
  /// In en, this message translates to:
  /// **'Resetting clears your personal details and saved preferences, then returns to the sample profile.'**
  String get privacyBody3;

  /// No description provided for @clearDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear your local data?'**
  String get clearDataTitle;

  /// No description provided for @clearDataBody.
  ///
  /// In en, this message translates to:
  /// **'Your birth profile, saved connections, and hidden profiles will be removed from this device.'**
  String get clearDataBody;

  /// No description provided for @keepMyData.
  ///
  /// In en, this message translates to:
  /// **'Keep my data'**
  String get keepMyData;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear data'**
  String get clearData;

  /// No description provided for @resetLocalData.
  ///
  /// In en, this message translates to:
  /// **'Reset local data'**
  String get resetLocalData;

  /// No description provided for @clearOkToast.
  ///
  /// In en, this message translates to:
  /// **'Your local data has been cleared.'**
  String get clearOkToast;

  /// No description provided for @clearFailToast.
  ///
  /// In en, this message translates to:
  /// **'Some data could not be cleared. Please try again.'**
  String get clearFailToast;

  /// No description provided for @editorTitle.
  ///
  /// In en, this message translates to:
  /// **'It starts with you.'**
  String get editorTitle;

  /// No description provided for @editorSub.
  ///
  /// In en, this message translates to:
  /// **'A moment in time. An energy all your own.\nAdd your birth details to discover your BaZi chart.'**
  String get editorSub;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'Your first name'**
  String get firstName;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get nameHint;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name.'**
  String get nameRequired;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateLabel;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get chooseDate;

  /// No description provided for @dateInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid date in YYYY-MM-DD format.'**
  String get dateInvalid;

  /// No description provided for @adultsOnly.
  ///
  /// In en, this message translates to:
  /// **'Lunar is for adults aged 18 and over.'**
  String get adultsOnly;

  /// No description provided for @yearMin.
  ///
  /// In en, this message translates to:
  /// **'Please enter a year from 1900 onward.'**
  String get yearMin;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Local birth time'**
  String get timeLabel;

  /// No description provided for @timeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use 24-hour time, for example 09:30.'**
  String get timeInvalid;

  /// No description provided for @noTimeCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I don’t know my birth time'**
  String get noTimeCheckbox;

  /// No description provided for @noTimeNote.
  ///
  /// In en, this message translates to:
  /// **'We’ll use three pillars and leave the hour out. Your chart and harmony scores will be approximate.'**
  String get noTimeNote;

  /// No description provided for @birthplace.
  ///
  /// In en, this message translates to:
  /// **'Birthplace'**
  String get birthplace;

  /// No description provided for @otherBirthplace.
  ///
  /// In en, this message translates to:
  /// **'Other birthplace'**
  String get otherBirthplace;

  /// No description provided for @cityCountry.
  ///
  /// In en, this message translates to:
  /// **'City and country'**
  String get cityCountry;

  /// No description provided for @cityRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a birthplace.'**
  String get cityRequired;

  /// No description provided for @tzLabel.
  ///
  /// In en, this message translates to:
  /// **'Birthplace time zone'**
  String get tzLabel;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @lonHint.
  ///
  /// In en, this message translates to:
  /// **'East is positive, west is negative. Example: -73.98'**
  String get lonHint;

  /// No description provided for @lonInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a longitude between -180 and 180.'**
  String get lonInvalid;

  /// No description provided for @tzNote.
  ///
  /// In en, this message translates to:
  /// **'Time zone: {zone}\nDay and hour use local mean solar time. If a clock-change time repeats, the earlier occurrence is used.'**
  String tzNote(String zone);

  /// No description provided for @privacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your birth details stay on this device and are never displayed on your public profile.'**
  String get privacyNote;

  /// No description provided for @findingEnergy.
  ///
  /// In en, this message translates to:
  /// **'Finding your energy…'**
  String get findingEnergy;

  /// No description provided for @discoverEnergy.
  ///
  /// In en, this message translates to:
  /// **'Discover my energy'**
  String get discoverEnergy;

  /// No description provided for @energyReadyToast.
  ///
  /// In en, this message translates to:
  /// **'Your energy is ready. Your connections have been refreshed.'**
  String get energyReadyToast;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Your profile could not be saved. Please try again.'**
  String get saveFailed;

  /// No description provided for @calcFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t calculate this chart. Please check your date and birthplace.'**
  String get calcFailed;

  /// No description provided for @editorFooter.
  ///
  /// In en, this message translates to:
  /// **'Cultural insight, with room for real-life chemistry.'**
  String get editorFooter;

  /// No description provided for @closeProfile.
  ///
  /// In en, this message translates to:
  /// **'Close profile'**
  String get closeProfile;

  /// No description provided for @chemistryTitle.
  ///
  /// In en, this message translates to:
  /// **'The chemistry behind your connection'**
  String get chemistryTitle;

  /// No description provided for @meetsText.
  ///
  /// In en, this message translates to:
  /// **'Your {you} energy meets {name}’s {their} energy.'**
  String meetsText(String you, String name, String their);

  /// No description provided for @factorBalance.
  ///
  /// In en, this message translates to:
  /// **'Element balance'**
  String get factorBalance;

  /// No description provided for @factorConnection.
  ///
  /// In en, this message translates to:
  /// **'Day master connection'**
  String get factorConnection;

  /// No description provided for @factorResonance.
  ///
  /// In en, this message translates to:
  /// **'Day branch resonance'**
  String get factorResonance;

  /// No description provided for @factorBalanceDesc.
  ///
  /// In en, this message translates to:
  /// **'45% of score · How evenly your visible elements combine.'**
  String get factorBalanceDesc;

  /// No description provided for @factorConnectionDesc.
  ///
  /// In en, this message translates to:
  /// **'35% of score · The relationship between your day elements.'**
  String get factorConnectionDesc;

  /// No description provided for @factorResonanceDesc.
  ///
  /// In en, this message translates to:
  /// **'20% of score · Traditional branch pairs and combinations.'**
  String get factorResonanceDesc;

  /// No description provided for @starterTitle.
  ///
  /// In en, this message translates to:
  /// **'A little conversation starter'**
  String get starterTitle;

  /// No description provided for @starterText.
  ///
  /// In en, this message translates to:
  /// **'“What’s something about {topic} you could talk about for hours?”'**
  String starterText(String topic);

  /// No description provided for @demoDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This is an illustrative profile in the demo community. Harmony is a transparent cultural heuristic, not a scientific measure or a prediction of compatibility.'**
  String get demoDisclaimer;

  /// No description provided for @timeApprox.
  ///
  /// In en, this message translates to:
  /// **'Your birth time is unknown, so this score is approximate.'**
  String get timeApprox;

  /// No description provided for @saveConnection.
  ///
  /// In en, this message translates to:
  /// **'Save this connection'**
  String get saveConnection;

  /// No description provided for @savedConnection.
  ///
  /// In en, this message translates to:
  /// **'Saved to connections'**
  String get savedConnection;

  /// No description provided for @compareCharts.
  ///
  /// In en, this message translates to:
  /// **'Compare our full charts'**
  String get compareCharts;

  /// No description provided for @hideToast.
  ///
  /// In en, this message translates to:
  /// **'{name} is hidden from your recommendations.'**
  String hideToast(String name);

  /// No description provided for @hideFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update recommendations. Please try again.'**
  String get hideFailed;

  /// No description provided for @factorContext.
  ///
  /// In en, this message translates to:
  /// **'{title} contributed {score}% to this harmony score.'**
  String factorContext(String title, int score);

  /// No description provided for @elementWood.
  ///
  /// In en, this message translates to:
  /// **'Wood'**
  String get elementWood;

  /// No description provided for @elementFire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get elementFire;

  /// No description provided for @elementEarth.
  ///
  /// In en, this message translates to:
  /// **'Earth'**
  String get elementEarth;

  /// No description provided for @elementMetal.
  ///
  /// In en, this message translates to:
  /// **'Metal'**
  String get elementMetal;

  /// No description provided for @elementWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get elementWater;

  /// No description provided for @qualityWood.
  ///
  /// In en, this message translates to:
  /// **'Growth & kindness'**
  String get qualityWood;

  /// No description provided for @qualityFire.
  ///
  /// In en, this message translates to:
  /// **'Passion & warmth'**
  String get qualityFire;

  /// No description provided for @qualityEarth.
  ///
  /// In en, this message translates to:
  /// **'Balance & trust'**
  String get qualityEarth;

  /// No description provided for @qualityMetal.
  ///
  /// In en, this message translates to:
  /// **'Clarity & purpose'**
  String get qualityMetal;

  /// No description provided for @qualityWater.
  ///
  /// In en, this message translates to:
  /// **'Depth & intuition'**
  String get qualityWater;

  /// No description provided for @qualityWoodShort.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get qualityWoodShort;

  /// No description provided for @qualityFireShort.
  ///
  /// In en, this message translates to:
  /// **'Passion'**
  String get qualityFireShort;

  /// No description provided for @qualityEarthShort.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get qualityEarthShort;

  /// No description provided for @qualityMetalShort.
  ///
  /// In en, this message translates to:
  /// **'Clarity'**
  String get qualityMetalShort;

  /// No description provided for @qualityWaterShort.
  ///
  /// In en, this message translates to:
  /// **'Depth'**
  String get qualityWaterShort;

  /// No description provided for @polarityYin.
  ///
  /// In en, this message translates to:
  /// **'Yin'**
  String get polarityYin;

  /// No description provided for @polarityYang.
  ///
  /// In en, this message translates to:
  /// **'Yang'**
  String get polarityYang;

  /// No description provided for @pillarYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get pillarYear;

  /// No description provided for @pillarMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get pillarMonth;

  /// No description provided for @pillarDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get pillarDay;

  /// No description provided for @pillarHour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get pillarHour;

  /// No description provided for @branchRat.
  ///
  /// In en, this message translates to:
  /// **'Rat'**
  String get branchRat;

  /// No description provided for @branchOx.
  ///
  /// In en, this message translates to:
  /// **'Ox'**
  String get branchOx;

  /// No description provided for @branchTiger.
  ///
  /// In en, this message translates to:
  /// **'Tiger'**
  String get branchTiger;

  /// No description provided for @branchRabbit.
  ///
  /// In en, this message translates to:
  /// **'Rabbit'**
  String get branchRabbit;

  /// No description provided for @branchDragon.
  ///
  /// In en, this message translates to:
  /// **'Dragon'**
  String get branchDragon;

  /// No description provided for @branchSnake.
  ///
  /// In en, this message translates to:
  /// **'Snake'**
  String get branchSnake;

  /// No description provided for @branchHorse.
  ///
  /// In en, this message translates to:
  /// **'Horse'**
  String get branchHorse;

  /// No description provided for @branchGoat.
  ///
  /// In en, this message translates to:
  /// **'Goat'**
  String get branchGoat;

  /// No description provided for @branchMonkey.
  ///
  /// In en, this message translates to:
  /// **'Monkey'**
  String get branchMonkey;

  /// No description provided for @branchRooster.
  ///
  /// In en, this message translates to:
  /// **'Rooster'**
  String get branchRooster;

  /// No description provided for @branchDog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get branchDog;

  /// No description provided for @branchPig.
  ///
  /// In en, this message translates to:
  /// **'Pig'**
  String get branchPig;

  /// No description provided for @matchNatural.
  ///
  /// In en, this message translates to:
  /// **'Natural harmony'**
  String get matchNatural;

  /// No description provided for @matchLovely.
  ///
  /// In en, this message translates to:
  /// **'A lovely balance'**
  String get matchLovely;

  /// No description provided for @matchRoom.
  ///
  /// In en, this message translates to:
  /// **'Room to discover'**
  String get matchRoom;

  /// No description provided for @socialTitle.
  ///
  /// In en, this message translates to:
  /// **'Your next chapter starts with hello.'**
  String get socialTitle;

  /// No description provided for @socialSubtitle.
  ///
  /// In en, this message translates to:
  /// **'People you saved. Invitations you made. Conversations you started.'**
  String get socialSubtitle;

  /// No description provided for @socialInvitations.
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get socialInvitations;

  /// No description provided for @socialMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get socialMessages;

  /// No description provided for @socialInvite.
  ///
  /// In en, this message translates to:
  /// **'Connect with {name}'**
  String socialInvite(String name);

  /// No description provided for @socialPending.
  ///
  /// In en, this message translates to:
  /// **'Invitation pending'**
  String get socialPending;

  /// No description provided for @socialWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw invitation'**
  String get socialWithdraw;

  /// No description provided for @socialLocalNotice.
  ///
  /// In en, this message translates to:
  /// **'Demo mode · Invitations and messages stay on this device.'**
  String get socialLocalNotice;

  /// No description provided for @socialInviteSaved.
  ///
  /// In en, this message translates to:
  /// **'Invitation saved locally. No real person is notified.'**
  String get socialInviteSaved;

  /// No description provided for @socialNotSent.
  ///
  /// In en, this message translates to:
  /// **'Local draft · not sent'**
  String get socialNotSent;

  /// No description provided for @socialEmptyInvitesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your next hello is out there.'**
  String get socialEmptyInvitesTitle;

  /// No description provided for @socialEmptyInvitesBody.
  ///
  /// In en, this message translates to:
  /// **'Open a profile and invite someone you would like to know.'**
  String get socialEmptyInvitesBody;

  /// No description provided for @socialEmptyMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'A thoughtful hello goes a long way.'**
  String get socialEmptyMessagesTitle;

  /// No description provided for @socialEmptyMessagesBody.
  ///
  /// In en, this message translates to:
  /// **'Open a profile and save an icebreaker to start a local conversation preview.'**
  String get socialEmptyMessagesBody;

  /// No description provided for @socialSayHello.
  ///
  /// In en, this message translates to:
  /// **'Say hello'**
  String get socialSayHello;

  /// No description provided for @socialMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Write a thoughtful hello…'**
  String get socialMessageHint;

  /// No description provided for @socialSaveMessage.
  ///
  /// In en, this message translates to:
  /// **'Save message locally'**
  String get socialSaveMessage;

  /// No description provided for @socialDraftStatus.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device'**
  String get socialDraftStatus;

  /// No description provided for @socialMessageDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Local conversation preview. No messages are delivered.'**
  String get socialMessageDisclaimer;

  /// No description provided for @socialIcebreaker.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}! What is something about {topic} you could talk about for hours?'**
  String socialIcebreaker(String name, String topic);

  /// No description provided for @socialTryIcebreaker.
  ///
  /// In en, this message translates to:
  /// **'Try an icebreaker'**
  String get socialTryIcebreaker;

  /// No description provided for @socialSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save locally. Please try again.'**
  String get socialSaveFailed;

  /// No description provided for @socialSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search people, places or interests'**
  String get socialSearchHint;

  /// No description provided for @socialClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get socialClearSearch;

  /// No description provided for @socialWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Invitation withdrawn on this device.'**
  String get socialWithdrawn;

  /// No description provided for @socialHiddenNotice.
  ///
  /// In en, this message translates to:
  /// **'This profile is hidden. Conversation drafts are read-only.'**
  String get socialHiddenNotice;

  /// No description provided for @socialCloseConversation.
  ///
  /// In en, this message translates to:
  /// **'Close conversation'**
  String get socialCloseConversation;

  /// No description provided for @socialTabConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get socialTabConnect;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'cs', 'da', 'de', 'el', 'en', 'es', 'fi', 'fr', 'he', 'hi', 'hu', 'id', 'it', 'ja', 'ko', 'ms', 'nl', 'no', 'pl', 'pt', 'ro', 'ru', 'sv', 'th', 'tr', 'uk', 'vi', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh': {
  switch (locale.countryCode) {
    case 'TW': return AppLocalizationsZhTw();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'cs': return AppLocalizationsCs();
    case 'da': return AppLocalizationsDa();
    case 'de': return AppLocalizationsDe();
    case 'el': return AppLocalizationsEl();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fi': return AppLocalizationsFi();
    case 'fr': return AppLocalizationsFr();
    case 'he': return AppLocalizationsHe();
    case 'hi': return AppLocalizationsHi();
    case 'hu': return AppLocalizationsHu();
    case 'id': return AppLocalizationsId();
    case 'it': return AppLocalizationsIt();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'ms': return AppLocalizationsMs();
    case 'nl': return AppLocalizationsNl();
    case 'no': return AppLocalizationsNo();
    case 'pl': return AppLocalizationsPl();
    case 'pt': return AppLocalizationsPt();
    case 'ro': return AppLocalizationsRo();
    case 'ru': return AppLocalizationsRu();
    case 'sv': return AppLocalizationsSv();
    case 'th': return AppLocalizationsTh();
    case 'tr': return AppLocalizationsTr();
    case 'uk': return AppLocalizationsUk();
    case 'vi': return AppLocalizationsVi();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
