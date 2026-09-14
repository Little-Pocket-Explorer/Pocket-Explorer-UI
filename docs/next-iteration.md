# Pocket Explorer: Remaining Work and Global Language Plan

Date: 2026-09-15. Scope: inspect current source, assess gaps and update requirements. No runtime code, AI requests or releases were changed during this assessment.

## 1. Current conclusion

The core exploration prototype is delivered as TestFlight 0.1.0 (9), with the Cloudflare backend and story viewer deployed. It is not yet a complete product covering global languages.

The user explicitly requires a multilingual experience for children worldwide. This is an accepted product requirement. The initial language list and later feature ordering below are recommendations, not delivered capabilities or a fully selected language set.

Visual appeal remains the first priority, followed by feedback. Language expansion must preserve the Miro visual direction without sacrificing layout to longer text or different fonts. iPhone remains the primary product, with Web sharing that requires no installation.

## 2. Product gaps

| Capability | Available now | Remaining work and recommended order |
| --- | --- | --- |
| Live exploration | Text, speech and camera input, age-aware answers, generated images and persistent cards | Delivered. Physical microphone, speaker, camera, VoiceOver and usability acceptance remain pending and cannot be replaced by simulator tests |
| Global languages | 239 localization keys each in iOS English and Simplified Chinese, explicit selection and system following | Highest development priority. Extend selection, AI contracts, speech, content metadata, Web, typography and RTL, including missing error copy |
| Memories and quizzes | Card quizzes after one day and trip memories after seven days, shown when the app is opened, with cards retained after wrong answers | Next priority. Optional local notifications, gentle sharing invitations and dismissal. No notification is currently delivered while the app is closed |
| Map | Native satellite map, personal card markers and optional private locations | Later. Public exploration destinations within approximately 2 km, arrival checks, check-ins and location collections. Do not expose other children's live locations |
| Collection | Counts, search, fixed categories, sorting, reversal and observation editing | Later. Collection achievements, custom tags, knowledge deduplication and merging, and actual version history. V1 is currently a visual badge |
| Sharing and social | Revocable public card/trip links without recipient installation | Localize sharing first. Accounts, friends, gifts and text chat remain deferred by the previous decision. A share link is not a friend system |
| Record continuity | Local journal persistence, with questions, generated artwork and public snapshots on the server | Before broader ongoing use. Replacement-device recovery, backup/sync, complete export and deletion. Existing server storage is not a full journal backup |
| Web demo and public distribution | Shared Web stories display real generated artwork, the root page offers prepared duck/leaf/shell questions, and build 9 is in internal TestFlight | Web need not duplicate the app. Public distribution, broader regional device/network tests and language quality reviews are not complete |

## 3. Specific language gaps

| Layer | Current evidence | Required behavior |
| --- | --- | --- |
| iOS language resolution | AppLanguage contains only en/zh-Hans, maps every zh prefix to Simplified Chinese and otherwise selects English | Explicit language/script identifiers, the full system preference list, manual selection and predictable unsupported-language fallback |
| Interface copy | Both 239-key tables match, but JournalError, example content and some persisted default titles are direct English strings | Cover UI, permission descriptions, errors, accessibility labels, empty states, plurals and dates. Separate interface copy from the child's original content |
| AI contract | Validation accepts only en and zh-Hans and rejects every proposed additional locale | A defined client/server support list. Questions, answers, card knowledge and quizzes preserve the intended language and age-appropriate expression |
| Speech | Recognition and synthesis use the current interface language and only map to en-AU/zh-CN | Respect available regional voices. Replay old answers using their content language. Explain unavailable speech and retain text input and reading |
| Content and switching | Question records already store language, but cards and public stories lack independent content-language fields. UI switching does not translate saved AI text | Preserve original text and its language without overwriting it on a UI change. If translation is added later, label it and keep the original accessible |
| Web sharing | Controls, statuses, accessibility labels and HTML lang are fixed to English | Browser-language negotiation, a manual selector and correct lang/dir. Story content and interface controls may use different languages |
| Sharing contract | v1 chapter titles must exactly match fixed English templates. Directly submitting Chinese chapter titles fails validation | Preserve existing v1 links with compatible semantic chapter identifiers and language metadata. Align native, Zod and JSON Schema mirrors |
| Visual and cultural quality | Existing automated evidence covers English/Chinese. Generated artwork already excludes text | Verify long German strings, Arabic RTL, fonts, numbers and dates. Do not mirror map geography, photos or illustrations. Review expression, factual accuracy and child suitability per language |

## 4. Proposed first language wave

Propose English, Simplified Chinese, Traditional Chinese, Spanish, French, German, Brazilian Portuguese, Japanese, Korean and Arabic: en, zh-Hans, zh-Hant, es, fr, de, pt-BR, ja, ko and ar.

This candidate list covers varied writing systems and is not a claim of support for every language. Complete the English/Chinese journey first, then expand under the same acceptance criteria. Exercise long text and at least one RTL language early. AI translation can produce drafts, while child-facing expression and actual speech still require human review.

## 5. Executable next iteration

| ID | Outcome and principal files | Dependencies and failure behavior | Completion criteria |
| --- | --- | --- | --- |
| T20.1 | iOS Design/AppLanguage, LanguageSelectionView, Resources, Domain/Models, Data/TripStore and ios/project.yml: extensible languages, complete copy, durable preferences and original content language | Preserve en/zh-Hans and existing journals first. Explicitly fall back for unknown or unsupported locales without resetting records | Language resolution, key completeness, relaunch, default/error copy, legacy journal compatibility and language-switch tests pass |
| B08.1 | Backend web/worker/ai-contract, ai-provider, web/src/story and shared/public-story.schema.json, coordinated with iOS Sharing/PublicStory and Memories/MemoryBuilder | Support current English/Chinese first. Add fields compatibly as needed. Reject invalid locales, preserving request identity and old v1 snapshots | Locale input/fallback, original-text preservation, old/new contracts, matching shared content and revocation integration checks pass |
| T20.2 | iOS Explore/VoiceSession, AIClient and ExploreView: recognition and synthesis follow input/content language | Depends on T20.1/B08.1. Missing device speech retains typing and reading without silently using the wrong voice language | Voice-selection unit tests, historical-content replay, interruption/recovery checks and representative physical-device language acceptance |
| B08.2 | Backend web/src/App, story, styles, index.html and locale resources: localize sharing and the existing Web demo | Depends on B08.1. Preserve existing links and the teammate's demo. Browser language has a fallback, and translated text cannot replace originals | Language switching, loading/failure/revoked states, keyboard, screen reader and mobile-browser journeys pass |
| T20.3 | Native/Web long text, RTL, fonts, permissions and translation-quality checks, plus local release evidence | Depends on the four tasks above. Do not mark an unverified language supported. Handle maps, original images and directional media separately | Small-screen/large-type/RTL visual acceptance, at least 80% changed Swift line coverage, at least 80% TypeScript line and branch coverage per file, and independent local TestFlight/Cloudflare delivery readback |

T20/B08 are PLANNED, not implemented. The current request is gap assessment and planning. Other extensions in the product table are recommendations and do not automatically start every feature or public distribution.

## 6. Assessment evidence and limits

- Inspected baseline: UI 3e9d14401918ce042799cfe87fac3911dc112f80 and Backend e2e0dcf78f0a111da9c5fbaaade8c6f77e0a94a0.
- Independently parsed both Localizable.strings tables with plutil: 239 keys each and identical key sets. Matching keys do not establish complete display-path coverage or translation quality.
- Executed pure local validation with the current TypeScript module: en/zh-Hans pass, while zh-Hant, es, fr, de, pt-BR, ja, ko and ar fail.
- Local contract comparison: English template titles with Chinese story content pass, while replacing chapter titles with Chinese fails. No production endpoint was called.
- The static shared/public-story.schema.json omits the discovery subject and artworkID already supported by runtime Zod. Align it in B08.1 without misreporting this mirror drift as a production sharing failure.
- Notification, nearby discovery, account/chat and backup findings use current source and existing documentation. No new remote Miro revision or repeat device/deployment acceptance is asserted.

## 7. Continuation rules

This assessment changes documents only. Preserve build 9 and the current service while awaiting a development instruction or specific device issue. Existing 54-test native and production-delivery evidence does not need rerunning for this review.

Future TestFlight publication remains local through Xcode 27 RC (27A266a), with no GitHub iOS runner. Backend deployment retains its Cloudflare workflow. API credentials stay server-side, with no parental key or approval flow. Accounts and friend chat remain deferred.
