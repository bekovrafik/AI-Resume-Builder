// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AI Resume Builder';

  @override
  String get profileTitle => 'Profile';

  @override
  String get saveProfile => 'SAVE PROFILE';

  @override
  String get deleteAccount => 'DELETE ACCOUNT';

  @override
  String get generateAiAvatar => 'GENERATE AI AVATAR';

  @override
  String get profileData => 'PROFILE DATA';

  @override
  String get fullNameLabel => 'FULL NAME';

  @override
  String get fullNameHint => 'Enter Full Name...';

  @override
  String get targetRoleLabel => 'TARGET ROLE';

  @override
  String get targetRoleHint => 'Enter Target Role...';

  @override
  String get emailLabel => 'CONTACT EMAIL';

  @override
  String get emailHint => 'Enter Contact Email...';

  @override
  String get linkedInLabel => 'LINKEDIN PROFILE LINK';

  @override
  String get linkedInHint => 'Enter LinkedIn Profile Link...';

  @override
  String get enterTargetRoleError => 'Please enter Target Role first.';

  @override
  String get generatingAvatarMessage =>
      'Generative AI Agent: Designing Avatar...';

  @override
  String get profileUpdatedSuccess => 'Profile Updated';

  @override
  String get deleteAccountTitle => 'Delete Account?';

  @override
  String get deleteAccountContent =>
      'This action is irreversible. All your resume data and profile information will be permanently removed.';

  @override
  String get cancel => 'CANCEL';

  @override
  String get delete => 'DELETE';

  @override
  String get accountDeletedSuccess => 'Account Deleted successfully.';

  @override
  String deletionFailedError(Object error) {
    return 'Deletion Failed: $error';
  }

  @override
  String get careerForge => 'Career Forge.';

  @override
  String get synced => 'SYNCED';

  @override
  String get workHistorySegment => 'WORK HISTORY';

  @override
  String get targetSpecsSegment => 'TARGET SPECS';

  @override
  String get careerLegacyData => 'CAREER LEGACY DATA';

  @override
  String get inputRawHistory => 'Input raw history or upload.';

  @override
  String get importFile => 'IMPORT FILE';

  @override
  String get historyHint =>
      'Ex: Led engineering team at Tech Corp. Launched mobile app reaching 1M users...';

  @override
  String get refineWithAi => 'REFINE WITH AI (STAR-K)';

  @override
  String get closeAuditor => 'CLOSE AUDITOR';

  @override
  String get auditImpact => 'AUDIT IMPACT (XYZ)';

  @override
  String get nextStage => 'NEXT STAGE';

  @override
  String get opportunitySpecs => 'OPPORTUNITY SPECS';

  @override
  String get keywordSynchronization => 'Keyword synchronization.';

  @override
  String get specsHint =>
      'Paste the Job Description or key requirements here to enable precise ATS alignment...';

  @override
  String get impactFirstTitle => 'IMPACT FIRST';

  @override
  String get impactFirstDesc =>
      'Quantitative data leads to 3x higher interview rates.';

  @override
  String get atsReadyTitle => 'ATS READY';

  @override
  String get atsReadyDesc =>
      'Synchronizing inputs with 500+ industry algorithms.';

  @override
  String get synthesizing => 'SYNTHESIZING...';

  @override
  String get buildResume => 'BUILD RESUME';

  @override
  String get nameRequired => 'Full name is required';

  @override
  String get roleRequired => 'Target role is required';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get invalidLinkedIn => 'Please enter a valid LinkedIn URL';

  @override
  String get careerAiDefaultName => 'Career AI';

  @override
  String get identityNotSynced => 'Identity Not Synced';

  @override
  String get personalizationSection => 'PERSONALIZATION';

  @override
  String get identityStandardTitle => 'Identity Standard';

  @override
  String get identityStandardSubtitle => 'Profile, Role, Contact';

  @override
  String get careerVaultTitle => 'Career Vault';

  @override
  String get careerVaultSubtitle => 'Narr narratives Indexed';

  @override
  String get aiControlsSection => 'AI CONTROLS';

  @override
  String get marketRadarTitle => 'Market Radar';

  @override
  String get marketRadarSubtitle => 'Initialize Job Search';

  @override
  String get interviewPrepTitle => 'Interview Prep Protocol';

  @override
  String get interviewPrepSubtitle => 'Initialize Tactical Analysis';

  @override
  String get chatAssistantTitle => 'Chat Assistant';

  @override
  String get chatAssistantSubtitle => 'Chat with AI Assistant';

  @override
  String get preferencesSection => 'PREFERENCES';

  @override
  String get conciergeTitle => 'Concierge & Support';

  @override
  String get conciergeSubtitle => 'Inquiry Dispatch';

  @override
  String get conciergeComingSoon => 'Concierge Support Coming Soon';

  @override
  String get legalTitle => 'Legal Standard';

  @override
  String get legalSubtitle => 'Institutional Privacy Policy';

  @override
  String get privacyPolicyMessage => 'Privacy Policy: Standard GDPR Compliance';

  @override
  String get terminateSessionTitle => 'Terminate Session';

  @override
  String get terminateSessionSubtitle => 'Logout securely';

  @override
  String get suiteVersion => 'AI RESUME BUILDER PROFESSIONAL SUITE V2.0';

  @override
  String get comprehensiveCareerBuilding => 'Comprehensive Career Building';

  @override
  String syncError(Object error) {
    return 'Sync Error: $error';
  }

  @override
  String get marketRadarDot => 'Market Radar.';

  @override
  String get marketRadarSettings => 'MARKET RADAR SETTINGS';

  @override
  String get applyFilters => 'APPLY FILTERS';

  @override
  String get openingJobApplication => 'Opening Job Application...';

  @override
  String get openingOffer => 'Opening Offer...';

  @override
  String get noOpportunitiesFound => 'No Opportunities Found';

  @override
  String get noOpportunitiesDesc =>
      'The API returned 0 results for this area. Try searching directly on the web.';

  @override
  String get searchOnJoobleWeb => 'SEARCH ON JOOBLE WEB';

  @override
  String get adjustFilters => 'Adjust Filters';

  @override
  String matchScore(Object score) {
    return '$score% MATCH';
  }

  @override
  String get startBuilding => 'START BUILDING';

  @override
  String get next => 'NEXT';

  @override
  String get skipOnboarding => 'SKIP ONBOARDING';

  @override
  String get step1Title => 'THE AI STANDARD';

  @override
  String get step1Desc =>
      'Welcome to AI Resume Builder. We build professional career profiles using advanced AI models.';

  @override
  String get step2Title => 'THE XYZ FORMULA';

  @override
  String get step2Desc =>
      'Google-recommended logic: \'Accomplished [X] as measured by [Y], by doing [Z]\'. Watch the transformation below.';

  @override
  String get step3Title => 'ATS OPTIMIZATION';

  @override
  String get step3Desc =>
      'Our engine automatically injects high-traffic industry keywords to ensure your narrative clears every digital gatekeeper.';

  @override
  String get step4Title => 'NARRATIVE POLISH';

  @override
  String get step4Desc =>
      'Your dashboard is interactive. Click any achievement to refine it, or chat with the AI Assistant for real-time improvements.';

  @override
  String get standardBulletLabel => 'STANDARD BULLET';

  @override
  String get standardBulletExample =>
      '\"I helped my team with sales targets.\"';

  @override
  String get aiResumeLabel => 'AI RESUME';

  @override
  String get aiResumeExample =>
      '\"Spearheaded a new sales methodology that boosted quarterly revenue by 22% (\$450k).\"';

  @override
  String get clickToApplyLogic => 'CLICK TO APPLY LOGIC';

  @override
  String get simulateAtsScan => 'SIMULATE ATS SCAN';

  @override
  String get careerVaultDot => 'Vault.';

  @override
  String get archiveEmpty => 'ARCHIVE EMPTY';

  @override
  String get createResumeButton => 'CREATE RESUME';

  @override
  String get untitledResume => 'Untitled Resume';

  @override
  String errorPrefix(Object error) {
    return 'Error: $error';
  }

  @override
  String get interviewStrategy => 'INTERVIEW STRATEGY';

  @override
  String get noResumeFoundError => 'No resume found in Vault to analyze.';

  @override
  String strategyError(Object error) {
    return 'Strategy Error: $error';
  }

  @override
  String get tacticalAnalysis => 'TACTICAL ANALYSIS';

  @override
  String get generateQuestionsDesc =>
      'Generate behavioral questions tailored to your resume\'s target role.';

  @override
  String get analyzing => 'ANALYZING...';

  @override
  String get generateStrategy => 'GENERATE STRATEGY';

  @override
  String get awaitingDeployment => 'AWAITING DEPLOYMENT';

  @override
  String get preparingScenarios => 'PREPARING SCENARIOS...';

  @override
  String questionLabel(Object number) {
    return 'QUESTION $number';
  }

  @override
  String intentLabel(Object intent) {
    return 'INTENT: $intent';
  }

  @override
  String get aiAssistant => 'AI ASSISTANT';

  @override
  String get onlineStatus => 'ONLINE';

  @override
  String get narrativeForge => 'NARRATIVE FORGE';

  @override
  String get awaitingInstructions =>
      'Awaiting instructions.\nHow shall we refine your career legacy today?';

  @override
  String get sentStatus => 'SENT';

  @override
  String get aiStatus => 'AI';

  @override
  String get applyRefinementHint => 'Apply Refinement...';

  @override
  String get actionExecutiveTone => 'Apply Executive Tone';

  @override
  String get actionHighImpactMetrics => 'Inject High-Impact Metrics';

  @override
  String get actionAtsOptimization => 'FAANG ATS Optimization';

  @override
  String get actionRefineStartups => 'Refine for Startups';

  @override
  String get actionShortenSummary => 'Shorten Summary';

  @override
  String get loginTitle => 'AI RESUME\nBUILDER';

  @override
  String get loginSubtitle => 'Create your professional resume with AI';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get termsAgreement =>
      'By continuing, you agree to our Terms of Service';

  @override
  String get splashTitle => 'ROLDANI';

  @override
  String get splashSubtitle => 'Professional Suite';

  @override
  String get navDash => 'Dash';

  @override
  String get navBuild => 'Build';

  @override
  String get navMarket => 'Market';

  @override
  String get navPreview => 'Preview';

  @override
  String get resumePreview => 'Resume Preview';

  @override
  String get exportPdf => 'EXPORT PDF';

  @override
  String get importAnalyzing => 'AI ANALYZING...';

  @override
  String get importSuccess => 'SMART ANALYSIS COMPLETE';

  @override
  String get importErrorFile => 'FILE EXTRACTION FAILED';
}
