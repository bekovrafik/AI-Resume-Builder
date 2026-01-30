import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Resume Builder'**
  String get appTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'SAVE PROFILE'**
  String get saveProfile;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'DELETE ACCOUNT'**
  String get deleteAccount;

  /// No description provided for @generateAiAvatar.
  ///
  /// In en, this message translates to:
  /// **'GENERATE AI AVATAR'**
  String get generateAiAvatar;

  /// No description provided for @profileData.
  ///
  /// In en, this message translates to:
  /// **'PROFILE DATA'**
  String get profileData;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Full Name...'**
  String get fullNameHint;

  /// No description provided for @targetRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'TARGET ROLE'**
  String get targetRoleLabel;

  /// No description provided for @targetRoleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Target Role...'**
  String get targetRoleHint;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'CONTACT EMAIL'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Contact Email...'**
  String get emailHint;

  /// No description provided for @linkedInLabel.
  ///
  /// In en, this message translates to:
  /// **'LINKEDIN PROFILE LINK'**
  String get linkedInLabel;

  /// No description provided for @linkedInHint.
  ///
  /// In en, this message translates to:
  /// **'Enter LinkedIn Profile Link...'**
  String get linkedInHint;

  /// No description provided for @enterTargetRoleError.
  ///
  /// In en, this message translates to:
  /// **'Please enter Target Role first.'**
  String get enterTargetRoleError;

  /// No description provided for @generatingAvatarMessage.
  ///
  /// In en, this message translates to:
  /// **'Generative AI Agent: Designing Avatar...'**
  String get generatingAvatarMessage;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile Updated'**
  String get profileUpdatedSuccess;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountContent.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. All your resume data and profile information will be permanently removed.'**
  String get deleteAccountContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get delete;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account Deleted successfully.'**
  String get accountDeletedSuccess;

  /// No description provided for @deletionFailedError.
  ///
  /// In en, this message translates to:
  /// **'Deletion Failed: {error}'**
  String deletionFailedError(Object error);

  /// No description provided for @careerForge.
  ///
  /// In en, this message translates to:
  /// **'Career Forge.'**
  String get careerForge;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'SYNCED'**
  String get synced;

  /// No description provided for @workHistorySegment.
  ///
  /// In en, this message translates to:
  /// **'WORK HISTORY'**
  String get workHistorySegment;

  /// No description provided for @targetSpecsSegment.
  ///
  /// In en, this message translates to:
  /// **'TARGET SPECS'**
  String get targetSpecsSegment;

  /// No description provided for @careerLegacyData.
  ///
  /// In en, this message translates to:
  /// **'CAREER LEGACY DATA'**
  String get careerLegacyData;

  /// No description provided for @inputRawHistory.
  ///
  /// In en, this message translates to:
  /// **'Input raw history or upload.'**
  String get inputRawHistory;

  /// No description provided for @importFile.
  ///
  /// In en, this message translates to:
  /// **'IMPORT FILE'**
  String get importFile;

  /// No description provided for @historyHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Led engineering team at Tech Corp. Launched mobile app reaching 1M users...'**
  String get historyHint;

  /// No description provided for @refineWithAi.
  ///
  /// In en, this message translates to:
  /// **'REFINE WITH AI (STAR-K)'**
  String get refineWithAi;

  /// No description provided for @closeAuditor.
  ///
  /// In en, this message translates to:
  /// **'CLOSE AUDITOR'**
  String get closeAuditor;

  /// No description provided for @auditImpact.
  ///
  /// In en, this message translates to:
  /// **'AUDIT IMPACT (XYZ)'**
  String get auditImpact;

  /// No description provided for @nextStage.
  ///
  /// In en, this message translates to:
  /// **'NEXT STAGE'**
  String get nextStage;

  /// No description provided for @opportunitySpecs.
  ///
  /// In en, this message translates to:
  /// **'OPPORTUNITY SPECS'**
  String get opportunitySpecs;

  /// No description provided for @keywordSynchronization.
  ///
  /// In en, this message translates to:
  /// **'Keyword synchronization.'**
  String get keywordSynchronization;

  /// No description provided for @specsHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the Job Description or key requirements here to enable precise ATS alignment...'**
  String get specsHint;

  /// No description provided for @impactFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'IMPACT FIRST'**
  String get impactFirstTitle;

  /// No description provided for @impactFirstDesc.
  ///
  /// In en, this message translates to:
  /// **'Quantitative data leads to 3x higher interview rates.'**
  String get impactFirstDesc;

  /// No description provided for @atsReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'ATS READY'**
  String get atsReadyTitle;

  /// No description provided for @atsReadyDesc.
  ///
  /// In en, this message translates to:
  /// **'Synchronizing inputs with 500+ industry algorithms.'**
  String get atsReadyDesc;

  /// No description provided for @synthesizing.
  ///
  /// In en, this message translates to:
  /// **'SYNTHESIZING...'**
  String get synthesizing;

  /// No description provided for @buildResume.
  ///
  /// In en, this message translates to:
  /// **'BUILD RESUME'**
  String get buildResume;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get nameRequired;

  /// No description provided for @roleRequired.
  ///
  /// In en, this message translates to:
  /// **'Target role is required'**
  String get roleRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @invalidLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid LinkedIn URL'**
  String get invalidLinkedIn;

  /// No description provided for @careerAiDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Career AI'**
  String get careerAiDefaultName;

  /// No description provided for @identityNotSynced.
  ///
  /// In en, this message translates to:
  /// **'Identity Not Synced'**
  String get identityNotSynced;

  /// No description provided for @personalizationSection.
  ///
  /// In en, this message translates to:
  /// **'PERSONALIZATION'**
  String get personalizationSection;

  /// No description provided for @identityStandardTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity Standard'**
  String get identityStandardTitle;

  /// No description provided for @identityStandardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Profile, Role, Contact'**
  String get identityStandardSubtitle;

  /// No description provided for @careerVaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Career Vault'**
  String get careerVaultTitle;

  /// No description provided for @careerVaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Narr narratives Indexed'**
  String get careerVaultSubtitle;

  /// No description provided for @aiControlsSection.
  ///
  /// In en, this message translates to:
  /// **'AI CONTROLS'**
  String get aiControlsSection;

  /// No description provided for @marketRadarTitle.
  ///
  /// In en, this message translates to:
  /// **'Market Radar'**
  String get marketRadarTitle;

  /// No description provided for @marketRadarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Initialize Job Search'**
  String get marketRadarSubtitle;

  /// No description provided for @interviewPrepTitle.
  ///
  /// In en, this message translates to:
  /// **'Interview Prep Protocol'**
  String get interviewPrepTitle;

  /// No description provided for @interviewPrepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Initialize Tactical Analysis'**
  String get interviewPrepSubtitle;

  /// No description provided for @chatAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat Assistant'**
  String get chatAssistantTitle;

  /// No description provided for @chatAssistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Chat with AI Assistant'**
  String get chatAssistantSubtitle;

  /// No description provided for @preferencesSection.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferencesSection;

  /// No description provided for @conciergeTitle.
  ///
  /// In en, this message translates to:
  /// **'Concierge & Support'**
  String get conciergeTitle;

  /// No description provided for @conciergeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Inquiry Dispatch'**
  String get conciergeSubtitle;

  /// No description provided for @conciergeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Concierge Support Coming Soon'**
  String get conciergeComingSoon;

  /// No description provided for @legalTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal Standard'**
  String get legalTitle;

  /// No description provided for @legalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Institutional Privacy Policy'**
  String get legalSubtitle;

  /// No description provided for @privacyPolicyMessage.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy: Standard GDPR Compliance'**
  String get privacyPolicyMessage;

  /// No description provided for @terminateSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Terminate Session'**
  String get terminateSessionTitle;

  /// No description provided for @terminateSessionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Logout securely'**
  String get terminateSessionSubtitle;

  /// No description provided for @suiteVersion.
  ///
  /// In en, this message translates to:
  /// **'AI RESUME BUILDER PROFESSIONAL SUITE V2.0'**
  String get suiteVersion;

  /// No description provided for @comprehensiveCareerBuilding.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive Career Building'**
  String get comprehensiveCareerBuilding;

  /// No description provided for @syncError.
  ///
  /// In en, this message translates to:
  /// **'Sync Error: {error}'**
  String syncError(Object error);

  /// No description provided for @marketRadarDot.
  ///
  /// In en, this message translates to:
  /// **'Market Radar.'**
  String get marketRadarDot;

  /// No description provided for @marketRadarSettings.
  ///
  /// In en, this message translates to:
  /// **'MARKET RADAR SETTINGS'**
  String get marketRadarSettings;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'APPLY FILTERS'**
  String get applyFilters;

  /// No description provided for @openingJobApplication.
  ///
  /// In en, this message translates to:
  /// **'Opening Job Application...'**
  String get openingJobApplication;

  /// No description provided for @openingOffer.
  ///
  /// In en, this message translates to:
  /// **'Opening Offer...'**
  String get openingOffer;

  /// No description provided for @noOpportunitiesFound.
  ///
  /// In en, this message translates to:
  /// **'No Opportunities Found'**
  String get noOpportunitiesFound;

  /// No description provided for @noOpportunitiesDesc.
  ///
  /// In en, this message translates to:
  /// **'The API returned 0 results for this area. Try searching directly on the web.'**
  String get noOpportunitiesDesc;

  /// No description provided for @searchOnJoobleWeb.
  ///
  /// In en, this message translates to:
  /// **'SEARCH ON JOOBLE WEB'**
  String get searchOnJoobleWeb;

  /// No description provided for @adjustFilters.
  ///
  /// In en, this message translates to:
  /// **'Adjust Filters'**
  String get adjustFilters;

  /// No description provided for @matchScore.
  ///
  /// In en, this message translates to:
  /// **'{score}% MATCH'**
  String matchScore(Object score);

  /// No description provided for @startBuilding.
  ///
  /// In en, this message translates to:
  /// **'START BUILDING'**
  String get startBuilding;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get next;

  /// No description provided for @skipOnboarding.
  ///
  /// In en, this message translates to:
  /// **'SKIP ONBOARDING'**
  String get skipOnboarding;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'THE AI STANDARD'**
  String get step1Title;

  /// No description provided for @step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Welcome to AI Resume Builder. We build professional career profiles using advanced AI models.'**
  String get step1Desc;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'THE XYZ FORMULA'**
  String get step2Title;

  /// No description provided for @step2Desc.
  ///
  /// In en, this message translates to:
  /// **'Google-recommended logic: \'Accomplished [X] as measured by [Y], by doing [Z]\'. Watch the transformation below.'**
  String get step2Desc;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'ATS OPTIMIZATION'**
  String get step3Title;

  /// No description provided for @step3Desc.
  ///
  /// In en, this message translates to:
  /// **'Our engine automatically injects high-traffic industry keywords to ensure your narrative clears every digital gatekeeper.'**
  String get step3Desc;

  /// No description provided for @step4Title.
  ///
  /// In en, this message translates to:
  /// **'NARRATIVE POLISH'**
  String get step4Title;

  /// No description provided for @step4Desc.
  ///
  /// In en, this message translates to:
  /// **'Your dashboard is interactive. Click any achievement to refine it, or chat with the AI Assistant for real-time improvements.'**
  String get step4Desc;

  /// No description provided for @standardBulletLabel.
  ///
  /// In en, this message translates to:
  /// **'STANDARD BULLET'**
  String get standardBulletLabel;

  /// No description provided for @standardBulletExample.
  ///
  /// In en, this message translates to:
  /// **'\"I helped my team with sales targets.\"'**
  String get standardBulletExample;

  /// No description provided for @aiResumeLabel.
  ///
  /// In en, this message translates to:
  /// **'AI RESUME'**
  String get aiResumeLabel;

  /// No description provided for @aiResumeExample.
  ///
  /// In en, this message translates to:
  /// **'\"Spearheaded a new sales methodology that boosted quarterly revenue by 22% (\$450k).\"'**
  String get aiResumeExample;

  /// No description provided for @clickToApplyLogic.
  ///
  /// In en, this message translates to:
  /// **'CLICK TO APPLY LOGIC'**
  String get clickToApplyLogic;

  /// No description provided for @simulateAtsScan.
  ///
  /// In en, this message translates to:
  /// **'SIMULATE ATS SCAN'**
  String get simulateAtsScan;

  /// No description provided for @careerVaultDot.
  ///
  /// In en, this message translates to:
  /// **'Vault.'**
  String get careerVaultDot;

  /// No description provided for @archiveEmpty.
  ///
  /// In en, this message translates to:
  /// **'ARCHIVE EMPTY'**
  String get archiveEmpty;

  /// No description provided for @createResumeButton.
  ///
  /// In en, this message translates to:
  /// **'CREATE RESUME'**
  String get createResumeButton;

  /// No description provided for @untitledResume.
  ///
  /// In en, this message translates to:
  /// **'Untitled Resume'**
  String get untitledResume;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorPrefix(Object error);

  /// No description provided for @interviewStrategy.
  ///
  /// In en, this message translates to:
  /// **'INTERVIEW STRATEGY'**
  String get interviewStrategy;

  /// No description provided for @noResumeFoundError.
  ///
  /// In en, this message translates to:
  /// **'No resume found in Vault to analyze.'**
  String get noResumeFoundError;

  /// No description provided for @strategyError.
  ///
  /// In en, this message translates to:
  /// **'Strategy Error: {error}'**
  String strategyError(Object error);

  /// No description provided for @tacticalAnalysis.
  ///
  /// In en, this message translates to:
  /// **'TACTICAL ANALYSIS'**
  String get tacticalAnalysis;

  /// No description provided for @generateQuestionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate behavioral questions tailored to your resume\'s target role.'**
  String get generateQuestionsDesc;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'ANALYZING...'**
  String get analyzing;

  /// No description provided for @generateStrategy.
  ///
  /// In en, this message translates to:
  /// **'GENERATE STRATEGY'**
  String get generateStrategy;

  /// No description provided for @awaitingDeployment.
  ///
  /// In en, this message translates to:
  /// **'AWAITING DEPLOYMENT'**
  String get awaitingDeployment;

  /// No description provided for @preparingScenarios.
  ///
  /// In en, this message translates to:
  /// **'PREPARING SCENARIOS...'**
  String get preparingScenarios;

  /// No description provided for @questionLabel.
  ///
  /// In en, this message translates to:
  /// **'QUESTION {number}'**
  String questionLabel(Object number);

  /// No description provided for @intentLabel.
  ///
  /// In en, this message translates to:
  /// **'INTENT: {intent}'**
  String intentLabel(Object intent);

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI ASSISTANT'**
  String get aiAssistant;

  /// No description provided for @onlineStatus.
  ///
  /// In en, this message translates to:
  /// **'ONLINE'**
  String get onlineStatus;

  /// No description provided for @narrativeForge.
  ///
  /// In en, this message translates to:
  /// **'NARRATIVE FORGE'**
  String get narrativeForge;

  /// No description provided for @awaitingInstructions.
  ///
  /// In en, this message translates to:
  /// **'Awaiting instructions.\nHow shall we refine your career legacy today?'**
  String get awaitingInstructions;

  /// No description provided for @sentStatus.
  ///
  /// In en, this message translates to:
  /// **'SENT'**
  String get sentStatus;

  /// No description provided for @aiStatus.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get aiStatus;

  /// No description provided for @applyRefinementHint.
  ///
  /// In en, this message translates to:
  /// **'Apply Refinement...'**
  String get applyRefinementHint;

  /// No description provided for @actionExecutiveTone.
  ///
  /// In en, this message translates to:
  /// **'Apply Executive Tone'**
  String get actionExecutiveTone;

  /// No description provided for @actionHighImpactMetrics.
  ///
  /// In en, this message translates to:
  /// **'Inject High-Impact Metrics'**
  String get actionHighImpactMetrics;

  /// No description provided for @actionAtsOptimization.
  ///
  /// In en, this message translates to:
  /// **'FAANG ATS Optimization'**
  String get actionAtsOptimization;

  /// No description provided for @actionRefineStartups.
  ///
  /// In en, this message translates to:
  /// **'Refine for Startups'**
  String get actionRefineStartups;

  /// No description provided for @actionShortenSummary.
  ///
  /// In en, this message translates to:
  /// **'Shorten Summary'**
  String get actionShortenSummary;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'AI RESUME\nBUILDER'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your professional resume with AI'**
  String get loginSubtitle;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @termsAgreement.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms of Service'**
  String get termsAgreement;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'ROLDANI'**
  String get splashTitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Professional Suite'**
  String get splashSubtitle;

  /// No description provided for @navDash.
  ///
  /// In en, this message translates to:
  /// **'Dash'**
  String get navDash;

  /// No description provided for @navBuild.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get navBuild;

  /// No description provided for @navMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get navMarket;

  /// No description provided for @navPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get navPreview;

  /// No description provided for @resumePreview.
  ///
  /// In en, this message translates to:
  /// **'Resume Preview'**
  String get resumePreview;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'EXPORT PDF'**
  String get exportPdf;

  /// No description provided for @importAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'AI ANALYZING...'**
  String get importAnalyzing;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'SMART ANALYSIS COMPLETE'**
  String get importSuccess;

  /// No description provided for @importErrorFile.
  ///
  /// In en, this message translates to:
  /// **'FILE EXTRACTION FAILED'**
  String get importErrorFile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
