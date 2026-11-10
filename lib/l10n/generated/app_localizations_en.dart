import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lunar — Find your kind of energy';

  @override
  String get languageName => 'English';

  @override
  String get consentLead => 'I confirm I am 18 or older and I accept the ';

  @override
  String get linkTerms => 'Terms of Service';

  @override
  String get consentAnd => ' and ';

  @override
  String get linkPrivacy => 'Privacy Policy';

  @override
  String get consentEnd => '.';

  @override
  String get consentError => 'Please confirm you are 18+ and accept the terms.';

  @override
  String get reportProfile => 'Report this profile';

  @override
  String get reportIntro => 'Tell us what is wrong. Reports are reviewed by our moderation team, and the profile is hidden from your recommendations right away.';

  @override
  String get reasonHarassment => 'Harassment or bullying';

  @override
  String get reasonNudity => 'Nudity or sexual content';

  @override
  String get reasonNcii => 'Shared my private images without consent';

  @override
  String get reasonUnderage => 'This person is under 18';

  @override
  String get reasonImpersonation => 'Impersonation or fake profile';

  @override
  String get reasonCsae => 'Child safety concern (CSAE)';

  @override
  String get reasonSpam => 'Spam, scam or fraud';

  @override
  String get reasonOther => 'Something else';

  @override
  String get reportNoteHint => 'Anything else we should know? (optional)';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get submitReport => 'Submit report';

  @override
  String get reportReceivedToast => 'Report received. This profile is now hidden.';

  @override
  String get reportFailedToast => 'Could not submit the report. Please try again.';

  @override
  String get actionHide => 'Hide this profile';

  @override
  String get legalCenterTitle => 'Legal & your data';

  @override
  String get legalCenterIntro => 'Policies that will govern Lunar at launch. Tap to read the draft.';

  @override
  String get actionClose => 'Close';

  @override
  String get exportMyData => 'Export my data (JSON)';

  @override
  String get exportDoneToast => 'A copy of your data is on the clipboard.';

  @override
  String get deleteAccount => 'Delete account & data';

  @override
  String get deleteConfirmTitle => 'Delete your account and data?';

  @override
  String get deleteConfirmBody => 'This permanently removes your birth profile, saved connections, hidden profiles, reports and consents from this device. At launch this also deletes your account and data on Lunar servers. Safety and legal records may be retained where the law requires.';

  @override
  String get keepAccount => 'Keep account';

  @override
  String get deleteEverything => 'Delete everything';

  @override
  String get deleteDoneToast => 'Your account and data have been deleted from this device.';

  @override
  String get deleteFailedToast => 'Deletion failed. Please try again.';

  @override
  String get docTerms => 'Terms of Service';

  @override
  String get docPrivacy => 'Privacy Policy';

  @override
  String get docCommunity => 'Community Guidelines';

  @override
  String get docSafety => 'Dating Safety Guidelines';

  @override
  String get docCsae => 'Child Safety (CSAE) Policy';

  @override
  String get docDeletion => 'Account & Data Deletion Policy';

  @override
  String get docSubscription => 'Subscription Terms';

  @override
  String get docModeration => 'Content Moderation & Reporting Policy';

  @override
  String get legalPolicies => 'Legal & policies';

  @override
  String get languageSystem => 'Use system language';

  @override
  String get languageTitle => 'Language';

  @override
  String get planFree => 'Lunar Free';

  @override
  String get planPlus => 'Lunar Plus';

  @override
  String get planPro => 'Lunar Pro';

  @override
  String get planFreeSub => 'Discovery, charts and saved connections.';

  @override
  String get planPlusSub => 'More daily likes and full compatibility reports.';

  @override
  String get planProSub => 'Everything in Plus, plus advanced cycle insights.';

  @override
  String get tabDiscover => 'Discover';

  @override
  String get tabSaved => 'Saved';

  @override
  String get tabMyEnergy => 'My energy';

  @override
  String get tabGuide => 'Guide';

  @override
  String get tabStudio => 'Studio';

  @override
  String get navConnections => 'Connections';

  @override
  String get navGuide => 'The BaZi guide';

  @override
  String get navStudio => 'Chart studio';

  @override
  String get tagline => 'A little fate. A real connection.';

  @override
  String get yourSpace => 'YOUR SPACE';

  @override
  String get promoTitle => 'Good things take alignment.';

  @override
  String get promoBody => 'Discover the energy that makes you, you.';

  @override
  String get promoCta => 'Explore your chart';

  @override
  String get editProfileShort => 'Edit your profile';

  @override
  String get demoProfile => 'Your demo profile';

  @override
  String get topbarSub => 'Meaningful connections start with your energy.';

  @override
  String get howLunarWorks => 'How Lunar works';

  @override
  String get heroEyebrow => 'ANCIENT WISDOM. NEW CONNECTIONS.';

  @override
  String get heroTitle => 'Some energies\njust belong together.';

  @override
  String get heroBody => 'Meet people who bring out your best,\nwith a little guidance from BaZi.';

  @override
  String get findEnergy => 'Find my energy';

  @override
  String get exploreEnergy => 'Explore my energy';

  @override
  String get discoverTitle => 'Find your kind of energy';

  @override
  String get discoverSub => 'Thoughtfully matched. Naturally you.';

  @override
  String get savedTitle => 'A connection worth keeping';

  @override
  String get savedSub => 'Your saved people, all in one place.';

  @override
  String get filters => 'Filters';

  @override
  String get filtered => 'Filtered';

  @override
  String get catForYou => 'For you';

  @override
  String get catHighHarmony => 'High harmony';

  @override
  String get catSameCity => 'Same birth city';

  @override
  String get catCreative => 'Creative souls';

  @override
  String countDiscover(int n) {
    return '$n connections to discover';
  }

  @override
  String countSaved(int n) {
    return '$n saved connections';
  }

  @override
  String get bestHarmony => 'Best harmony first';

  @override
  String get curiosity => 'A little curiosity can be the start of something good.';

  @override
  String get demoNotice => 'Demo community · All profiles are illustrative';

  @override
  String harmonyPct(int n) {
    return '$n% harmony';
  }

  @override
  String savedToast(String name) {
    return '$name saved to your connections';
  }

  @override
  String removedToast(String name) {
    return '$name removed from connections';
  }

  @override
  String get couldNotSave => 'Could not save. Please try again.';

  @override
  String saveTo(String name) {
    return 'Save $name';
  }

  @override
  String unsave(String name) {
    return 'Unsave $name';
  }

  @override
  String get compareFailed => 'Could not open the comparison. Please try again.';

  @override
  String get glanceTitle => 'Your energy, at a glance';

  @override
  String get glancePersonal => 'A little insight into your nature.';

  @override
  String get glanceSample => 'Meet your sample birth chart.';

  @override
  String get seeChart => 'See my full chart';

  @override
  String get wisdomEyebrow => 'A MOMENT OF WISDOM';

  @override
  String get wisdomTitle => 'You don’t need to be\nthe same to be in sync.';

  @override
  String get wisdomBody => 'In BaZi, different elements can bring out the best in each other. Balance is a beautiful thing.';

  @override
  String get wisdomCta => 'Get to know the Five Elements';

  @override
  String get detailsYours => 'Your details stay yours.';

  @override
  String get detailsStored => 'Birth details are stored on this device. They’re never shown on your public profile.';

  @override
  String get privacyData => 'Privacy & your data';

  @override
  String get emptySavedTitle => 'Good connections are worth saving.';

  @override
  String get emptySavedBody => 'Tap the heart on a profile to keep it here.';

  @override
  String get emptyFilterTitle => 'A little more room to explore.';

  @override
  String get emptyFilterBody => 'Try a wider age range or explore worldwide.';

  @override
  String get discoverPeople => 'Discover people';

  @override
  String get resetFilters => 'Reset filters';

  @override
  String get filterTitle => 'Make room for your kind of people';

  @override
  String get showMe => 'Show me';

  @override
  String get genderEveryone => 'Everyone';

  @override
  String get genderWomen => 'Women';

  @override
  String get genderMen => 'Men';

  @override
  String get location => 'Location';

  @override
  String get regionWorldwide => 'Worldwide';

  @override
  String get regionUSA => 'USA';

  @override
  String get regionUK => 'UK';

  @override
  String get regionFrance => 'France';

  @override
  String get regionAustralia => 'Australia';

  @override
  String get regionSingapore => 'Singapore';

  @override
  String ageRangeLabel(int a, int b) {
    return 'Age range · $a–$b';
  }

  @override
  String minHarmony(int n) {
    return 'Minimum harmony · $n%';
  }

  @override
  String get harmonyNote => 'Harmony is a cultural exploration score, not a prediction of relationship success.';

  @override
  String get reset => 'Reset';

  @override
  String get showConnections => 'Show connections';

  @override
  String dayMasterContext(String name, String identity) {
    return '$name’s day master is $identity. The badge shows their day element and polarity.';
  }

  @override
  String get energyTitle => 'A nature all your own.';

  @override
  String get energySub => 'Get to know the elements that make you, you.';

  @override
  String get editBirth => 'Edit birth details';

  @override
  String get sampleNotice => 'You’re exploring a sample chart. Add your own birth details for a personal reading.';

  @override
  String get getStarted => 'Get started';

  @override
  String get dayMasterBody => 'Your day master is the central element of your BaZi chart. Think of it as a lens for reflection, with plenty of room to be yourself.';

  @override
  String get whatIsDayMaster => 'What is a day master?';

  @override
  String myDayMasterContext(String identity) {
    return 'Your day master is $identity — the stem at the top of your day pillar.';
  }

  @override
  String get fiveElements => 'Your Five Elements';

  @override
  String get elementsContext => 'The visible stems and branches of your chart add up to this distribution.';

  @override
  String get elementsSub => 'The visible stems and branches in your chart.';

  @override
  String get fourPillars => 'Your Four Pillars';

  @override
  String get pillarsContext => 'Each pillar below pairs a heavenly stem with an earthly branch.';

  @override
  String get pillarsSub => 'Four moments, eight characters, one unique combination.';

  @override
  String pillarContext(String pillar, String combo) {
    return 'Your $pillar pillar is $combo. The heavenly stem gives this card its element color.';
  }

  @override
  String get hourUnknown => 'Hour unknown';

  @override
  String get hourUnknownBody => 'Add a birth time for your fourth pillar.';

  @override
  String get contextTitle => 'A little context goes a long way.';

  @override
  String calcNote(String zone, String lon) {
    return 'Calculated with $zone birth time and local mean solar time at $lon° longitude. Year and month follow solar-term boundaries. Day changes at midnight.';
  }

  @override
  String get noTimeBoundaryNote => 'Without an exact birth time, the hour is omitted and boundary dates may be uncertain.';

  @override
  String get solarWhy => 'Why solar time matters';

  @override
  String solarContext(String lon) {
    return 'This chart uses local mean solar time at $lon° longitude.';
  }

  @override
  String get understandChart => 'Understand your chart';

  @override
  String get guideEyebrow => 'A LITTLE WISDOM, A LOT OF POSSIBILITY';

  @override
  String get guideTitle => 'Ancient roots.\nHuman connections.';

  @override
  String get guideIntro => 'BaZi is a traditional Chinese system for exploring the patterns of a birth moment. Lunar brings that tradition into a more curious, connected world.';

  @override
  String get meetElements => 'Meet the Five Elements';

  @override
  String get elementsTagline => 'Different by nature. Better in balance.';

  @override
  String get guidePillarsTitle => 'What are the Four Pillars?';

  @override
  String get guidePillarsBody => 'Your birth year, month, day, and hour each form a pillar. Each pillar has a heavenly stem and an earthly branch — eight characters in total. That is what BaZi means: “eight characters.” Your day stem is called your day master.';

  @override
  String get guideHarmonyTitle => 'How does Lunar calculate harmony?';

  @override
  String get guideHarmonyBody => 'Our demo score combines three transparent factors: 45% combined element balance, measured by the normalized entropy of visible elements; 35% day master connection, based on the generating cycle; and 20% day branch resonance, using traditional pairs, trines, and oppositions. Scores are computed from the charts and recommendations are sorted from highest to lowest.';

  @override
  String get guideScoreTitle => 'What does a high score mean?';

  @override
  String get guideScoreBody => 'It means two charts align under our chosen rules. These rules are an interpretive product choice, not a scientific test of personality or relationship success. A score should invite a conversation, never decide who deserves one. Shared values, kindness, consent, and real-life chemistry matter.';

  @override
  String get guideTimezoneTitle => 'How do time zones work?';

  @override
  String get guideTimezoneBody => 'Lunar resolves your birth time using the IANA time-zone database, including historical daylight saving rules. Year and month use the calendar library’s solar-term instants in UTC+8. Dating recommendations use local mean solar time based on birthplace longitude, with the day changing at midnight. Chart Studio additionally supports local clock time, true solar time with an approximate equation-of-time correction, and a 23:00 day boundary. During a repeated clock-change time, the earlier occurrence is used; nonexistent clock-change times are rejected. Other BaZi schools may produce different charts.';

  @override
  String get guideNoTimeTitle => 'What if I don’t know my birth time?';

  @override
  String get guideNoTimeBody => 'You can still explore. Lunar uses local noon for the date calculation, omits the hour pillar, and marks your results as approximate. On dates near a solar-term boundary, year or month may be uncertain too. Add your time later to refine your chart.';

  @override
  String get guideCommunityTitle => 'Is this a live dating community?';

  @override
  String get guideCommunityBody => 'This first version is an interactive, local demo. The people shown are fictional profiles paired with stock photographs. You can explore charts, filter recommendations, and save connections on this device. Accounts, messages, verification, and a real community will be part of a future backend integration.';

  @override
  String get digDeeper => 'DIG DEEPER';

  @override
  String get termFourPillars => 'Four pillars';

  @override
  String get termStemsBranches => 'Heavenly stems & earthly branches';

  @override
  String get termDayMaster => 'Day master';

  @override
  String get termTenGods => 'Ten Gods';

  @override
  String get termCombinations => 'Combinations';

  @override
  String get termSolarTime => 'True solar time';

  @override
  String get guideFooter => 'Stay curious. Be kind. Leave room for a little serendipity.';

  @override
  String get privacyTitle => 'Your details stay yours.';

  @override
  String get privacyBody1 => 'This app saves your name, birth details, studio charts, model settings, saved connections, and hidden profiles on this device. Client API keys stay in memory. When you choose to generate an interpretation, calculated chart evidence is sent to your selected model provider. Names, exact birth dates and places are omitted from that evidence. Resetting local data does not erase provider records or the local server’s API key. Invitations and local message drafts are also stored on this device and included in your data export.';

  @override
  String get privacyBody2 => 'Local storage is not encrypted. On a shared device, clear your data when you are done. Clearing browser or app data also removes your profile.';

  @override
  String get privacyBody3 => 'Resetting clears your personal details and saved preferences, then returns to the sample profile.';

  @override
  String get clearDataTitle => 'Clear your local data?';

  @override
  String get clearDataBody => 'Your birth profile, saved connections, and hidden profiles will be removed from this device.';

  @override
  String get keepMyData => 'Keep my data';

  @override
  String get clearData => 'Clear data';

  @override
  String get resetLocalData => 'Reset local data';

  @override
  String get clearOkToast => 'Your local data has been cleared.';

  @override
  String get clearFailToast => 'Some data could not be cleared. Please try again.';

  @override
  String get editorTitle => 'It starts with you.';

  @override
  String get editorSub => 'A moment in time. An energy all your own.\nAdd your birth details to discover your BaZi chart.';

  @override
  String get firstName => 'Your first name';

  @override
  String get nameHint => 'What should we call you?';

  @override
  String get nameRequired => 'Please enter your first name.';

  @override
  String get dateLabel => 'Date of birth';

  @override
  String get chooseDate => 'Choose date';

  @override
  String get dateInvalid => 'Enter a valid date in YYYY-MM-DD format.';

  @override
  String get adultsOnly => 'Lunar is for adults aged 18 and over.';

  @override
  String get yearMin => 'Please enter a year from 1900 onward.';

  @override
  String get timeLabel => 'Local birth time';

  @override
  String get timeInvalid => 'Use 24-hour time, for example 09:30.';

  @override
  String get noTimeCheckbox => 'I don’t know my birth time';

  @override
  String get noTimeNote => 'We’ll use three pillars and leave the hour out. Your chart and harmony scores will be approximate.';

  @override
  String get birthplace => 'Birthplace';

  @override
  String get otherBirthplace => 'Other birthplace';

  @override
  String get cityCountry => 'City and country';

  @override
  String get cityRequired => 'Please enter a birthplace.';

  @override
  String get tzLabel => 'Birthplace time zone';

  @override
  String get longitude => 'Longitude';

  @override
  String get lonHint => 'East is positive, west is negative. Example: -73.98';

  @override
  String get lonInvalid => 'Enter a longitude between -180 and 180.';

  @override
  String tzNote(String zone) {
    return 'Time zone: $zone\nDay and hour use local mean solar time. If a clock-change time repeats, the earlier occurrence is used.';
  }

  @override
  String get privacyNote => 'Your birth details stay on this device and are never displayed on your public profile.';

  @override
  String get findingEnergy => 'Finding your energy…';

  @override
  String get discoverEnergy => 'Discover my energy';

  @override
  String get energyReadyToast => 'Your energy is ready. Your connections have been refreshed.';

  @override
  String get saveFailed => 'Your profile could not be saved. Please try again.';

  @override
  String get calcFailed => 'We couldn’t calculate this chart. Please check your date and birthplace.';

  @override
  String get editorFooter => 'Cultural insight, with room for real-life chemistry.';

  @override
  String get closeProfile => 'Close profile';

  @override
  String get chemistryTitle => 'The chemistry behind your connection';

  @override
  String meetsText(String you, String name, String their) {
    return 'Your $you energy meets $name’s $their energy.';
  }

  @override
  String get factorBalance => 'Element balance';

  @override
  String get factorConnection => 'Day master connection';

  @override
  String get factorResonance => 'Day branch resonance';

  @override
  String get factorBalanceDesc => '45% of score · How evenly your visible elements combine.';

  @override
  String get factorConnectionDesc => '35% of score · The relationship between your day elements.';

  @override
  String get factorResonanceDesc => '20% of score · Traditional branch pairs and combinations.';

  @override
  String get starterTitle => 'A little conversation starter';

  @override
  String starterText(String topic) {
    return '“What’s something about $topic you could talk about for hours?”';
  }

  @override
  String get demoDisclaimer => 'This is an illustrative profile in the demo community. Harmony is a transparent cultural heuristic, not a scientific measure or a prediction of compatibility.';

  @override
  String get timeApprox => 'Your birth time is unknown, so this score is approximate.';

  @override
  String get saveConnection => 'Save this connection';

  @override
  String get savedConnection => 'Saved to connections';

  @override
  String get compareCharts => 'Compare our full charts';

  @override
  String hideToast(String name) {
    return '$name is hidden from your recommendations.';
  }

  @override
  String get hideFailed => 'Could not update recommendations. Please try again.';

  @override
  String factorContext(String title, int score) {
    return '$title contributed $score% to this harmony score.';
  }

  @override
  String get elementWood => 'Wood';

  @override
  String get elementFire => 'Fire';

  @override
  String get elementEarth => 'Earth';

  @override
  String get elementMetal => 'Metal';

  @override
  String get elementWater => 'Water';

  @override
  String get qualityWood => 'Growth & kindness';

  @override
  String get qualityFire => 'Passion & warmth';

  @override
  String get qualityEarth => 'Balance & trust';

  @override
  String get qualityMetal => 'Clarity & purpose';

  @override
  String get qualityWater => 'Depth & intuition';

  @override
  String get qualityWoodShort => 'Growth';

  @override
  String get qualityFireShort => 'Passion';

  @override
  String get qualityEarthShort => 'Balance';

  @override
  String get qualityMetalShort => 'Clarity';

  @override
  String get qualityWaterShort => 'Depth';

  @override
  String get polarityYin => 'Yin';

  @override
  String get polarityYang => 'Yang';

  @override
  String get pillarYear => 'Year';

  @override
  String get pillarMonth => 'Month';

  @override
  String get pillarDay => 'Day';

  @override
  String get pillarHour => 'Hour';

  @override
  String get branchRat => 'Rat';

  @override
  String get branchOx => 'Ox';

  @override
  String get branchTiger => 'Tiger';

  @override
  String get branchRabbit => 'Rabbit';

  @override
  String get branchDragon => 'Dragon';

  @override
  String get branchSnake => 'Snake';

  @override
  String get branchHorse => 'Horse';

  @override
  String get branchGoat => 'Goat';

  @override
  String get branchMonkey => 'Monkey';

  @override
  String get branchRooster => 'Rooster';

  @override
  String get branchDog => 'Dog';

  @override
  String get branchPig => 'Pig';

  @override
  String get matchNatural => 'Natural harmony';

  @override
  String get matchLovely => 'A lovely balance';

  @override
  String get matchRoom => 'Room to discover';

  @override
  String get socialTitle => 'Your next chapter starts with hello.';

  @override
  String get socialSubtitle => 'People you saved. Invitations you made. Conversations you started.';

  @override
  String get socialInvitations => 'Invitations';

  @override
  String get socialMessages => 'Messages';

  @override
  String socialInvite(String name) {
    return 'Connect with $name';
  }

  @override
  String get socialPending => 'Invitation pending';

  @override
  String get socialWithdraw => 'Withdraw invitation';

  @override
  String get socialLocalNotice => 'Demo mode · Invitations and messages stay on this device.';

  @override
  String get socialInviteSaved => 'Invitation saved locally. No real person is notified.';

  @override
  String get socialNotSent => 'Local draft · not sent';

  @override
  String get socialEmptyInvitesTitle => 'Your next hello is out there.';

  @override
  String get socialEmptyInvitesBody => 'Open a profile and invite someone you would like to know.';

  @override
  String get socialEmptyMessagesTitle => 'A thoughtful hello goes a long way.';

  @override
  String get socialEmptyMessagesBody => 'Open a profile and save an icebreaker to start a local conversation preview.';

  @override
  String get socialSayHello => 'Say hello';

  @override
  String get socialMessageHint => 'Write a thoughtful hello…';

  @override
  String get socialSaveMessage => 'Save message locally';

  @override
  String get socialDraftStatus => 'Saved on this device';

  @override
  String get socialMessageDisclaimer => 'Local conversation preview. No messages are delivered.';

  @override
  String socialIcebreaker(String name, String topic) {
    return 'Hi $name! What is something about $topic you could talk about for hours?';
  }

  @override
  String get socialTryIcebreaker => 'Try an icebreaker';

  @override
  String get socialSaveFailed => 'Could not save locally. Please try again.';

  @override
  String get socialSearchHint => 'Search people, places or interests';

  @override
  String get socialClearSearch => 'Clear search';

  @override
  String get socialWithdrawn => 'Invitation withdrawn on this device.';

  @override
  String get socialHiddenNotice => 'This profile is hidden. Conversation drafts are read-only.';

  @override
  String get socialCloseConversation => 'Close conversation';

  @override
  String get socialTabConnect => 'Connect';
}
