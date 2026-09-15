# Daily discoveries and knowledge reuse: research and recommendations

Research date: 2026-09-15. Status: design discussion, with no implementation published.

## 1. Conclusion

The closest reference for Pocket Explorer is Duolingo's published separation of content and exercise pools from personalized selection. Daily recommendations can also borrow predictable cadence from Spotify and fetch/activation separation from Firebase.

Split this change into a prepared knowledge library, a stable daily recommendation snapshot, and reusable answers for free-form questions. The knowledge library must not depend solely on temporary caches. Store the answer, quiz and illustration together as a versioned work.

The sources do not establish that any particular app implements a local bank of 60 questions and selects three per day. This report distinguishes published facts from recommendations. Observable product behavior does not prove internal architecture.

## 2. How other products work

| Reference | Officially documented behavior | Application here | Evidence boundary |
| --- | --- | --- | --- |
| Duolingo | Its 2022 article separates curriculum design, raw content creation, exercise generation and personalized selection | Create content before selecting it for a learner | Historical published architecture, not proof that every current feature works this way |
| Spotify Discover Weekly | The playlist updates every Monday | Give recommendations a predictable identity and cadence | These sources do not disclose mobile cache capacity or selection algorithms |
| Spotify daylist | Changes with context throughout the day | Cadence is a product choice. A stable daily set fits our objective better | Do not describe daylist as fixed for the entire day |
| Wikipedia | Provides daily featured articles and other content through language/date-based feeds | A day can identify a content manifest | Wikifeeds documentation notes gradual deprecation. Borrow the pattern without adding a dependency on that API |

Duolingo's most relevant source is [How Duolingo experts work with AI](https://blog.duolingo.com/how-duolingo-experts-work-with-ai/). Spotify's [official help](https://support.spotify.com/us/article/find-playlists/) lists playlist refresh frequencies, complemented by its [Discover Weekly anniversary article](https://newsroom.spotify.com/2025-06-30/discover-weekly-turns-10-celebrating-100-billion-tracks-streamed-and-a-decade-of-personalized-discovery/). Wikipedia's source is [Wikifeeds API](https://www.mediawiki.org/wiki/Wikifeeds_API).

## 3. Common client loading patterns

[Firebase's loading strategies](https://firebase.google.com/docs/remote-config/loading) explicitly discourage changing sensitive UI while users are viewing or interacting with it. One strategy activates previously downloaded values, then fetches new values asynchronously for a later activation point.

This does not require Firebase. A Cloudflare API and local persistence can implement the same pattern.

Recommended application:

1. Cache a candidate bank, separating its size from the visible recommendation count.
2. On the first home entry of a day, select three and persist their IDs, order and content versions.
3. Relaunching, navigating, reconnecting and downloading a new bank must not replace that snapshot during the day.
4. Background downloads update the candidate bank. Activate it on the next day's home entry.
5. Do not replace content while a child reads across midnight. Ship a qualified fallback bank for cold starts.
6. Retain the existing bank offline. Show fewer items if insufficient qualified content exists rather than duplicating questions or recommending incomplete cards.

[Apple's background-task documentation](https://developer.apple.com/documentation/backgroundtasks/choosing-background-strategies-for-your-app) states that the system chooses when background refresh runs. Do not depend on an iPhone waking at midnight. A foreground date check must independently handle daily rollover.

## 4. Organizing prepared content

Duolingo demonstrates the value of preparing a selectable content pool. Each knowledge topic should have a stable ID. Each published version should contain its question, age applicability, language, answer, observation invitation, quiz, illustration, review metadata and version.

Recommended pipeline: select topics, generate text and artwork in batches, check facts/language/artwork alignment, publish a complete package, then admit it to recommendations.

Only packages with completed text and artwork qualify for the home bank. An image-generation queue is not a ready content library.

Treat the library as published content assets and retain its released versions. Corrections publish a new version without overwriting collected or shared works. Withdraw incorrect content from new recommendations and provide a correction where appropriate rather than silently changing the child's record.

Prefetch today's three complete packages, then additional resources within storage and network limits. Downloading every high-resolution image in the bank is unnecessary. Localized versions can share a topic ID while retaining separately reviewed language content.

## 5. Free-form question caching: practice and boundaries

[LangChain's BaseCache](https://reference.langchain.com/python/langchain-core/caches/BaseCache) derives cache lookups from both the prompt and model configuration. The user's sentence alone is insufficient cache identity.

[Microsoft's LLM semantic-cache documentation](https://learn.microsoft.com/en-us/azure/api-management/llm-semantic-cache-lookup-policy) supports similarity matching and cache partitioning. It explicitly warns that similar requests may surface incorrect, outdated or unsafe responses for the current request.

Subsequent discussion selected exact fast paths, semantic retrieval and reuse verification for this iteration, with Cloudflare Vectorize preferred. This supersedes the earlier exact-only first release recommendation:

- Check normalized exact questions and verified equivalent phrasings first, still requiring matching language, validated age applicability and response-policy revision.
- Retrieve candidates for new phrasings using embeddings and Vectorize, then read D1 content to verify eligibility and complete answer coverage. Reject partial coverage and uncertainty.
- Calibrate similarity thresholds against multilingual false-hit tests. Scores are not correctness probabilities. See the [Vectorize design](../../../Pocket-Explorer-Backend/docs/research/semantic-cache-vectorize.md).

“Why is the sky blue?” and “Why does the sky look blue?” can map to one reviewed topic. “Why is the sky red?” must remain separate. “What is this?” with different attached photos must also remain separate.

Cross-user reuse should admit only general knowledge independent of personal circumstances. Exclude photo identification, names, precise locations, personal experiences, current weather and health advice. Do not publish question histories or reveal the original asker. Cached free-form responses must pass a separate review before entering another child's home recommendations.

Reuse the complete answer, quiz and illustration version. Each child's collection time, place, observations and achievements remain independent.

## 6. Engineering long-lived caches

[AWS Builders' Library](https://aws.amazon.com/builders-library/caching-challenges-and-strategies/) describes two particularly relevant techniques:

- Request coalescing: allow one in-flight generation per uncached resource while other requests wait for or read its result. Otherwise simultaneous first requests still duplicate generation and cost.
- Soft and hard TTLs: attempt refresh after soft expiry, and retain permitted old content until hard expiry when refresh fails.

[Cloudflare's revalidation documentation](https://developers.cloudflare.com/cache/concepts/revalidation/) also describes revalidating stale content in the background. HTTP image caching alone does not provide question deduplication, content versioning or a stable native daily list.

Keep success, pending, failed and withdrawn states distinct. Do not cache failures as long-lived successful answers. Mismatched artwork must not qualify for recommendations. Incorrect content needs active invalidation rather than waiting 90 days for expiration.

## 7. Proposed Pocket Explorer defaults

These numbers are proposed starting points, not published settings from the referenced apps or implemented configuration.

| Item | Initial recommendation |
| --- | --- |
| Local candidate bank | 30–60 questions for the current language and age band, independent of the visible count |
| Home | Three daily questions with persisted IDs, order and content versions |
| Selection | Balance interests, topic diversity and recent-repeat avoidance without requiring a complex first-release model |
| Bank fetch | Check the version when online and approximately 24 hours after the last successful check. Back off on failure without changing today's snapshot |
| Daily activation | On the next day's first home entry, never while the current content is being read |
| Image prefetch | Prioritize today's three, then additional resources within storage/network limits |
| General-knowledge reuse | Start with 30-day soft expiry and 90-day hard expiry, then tune using hit rates and quality |
| Personal or time-sensitive questions | Exclude from long-lived cross-user reuse |
| Existing collections and links | Reference the original content version. Cache expiration does not delete collections |
| Concurrent same-question misses | Coalesce into one generation job with a deadline and explicit recovery states |

Cloudflare remains the selected platform: Vectorize for semantic candidates, D1 for authoritative manifests, content versions, exact reuse indexes and job state, R2 for larger artwork assets, and Queues for preparation and refresh. A CDN can distribute approved immutable illustrations. Private photos and private answers must not enter public CDN caches.

[Workers KV documentation](https://developers.cloudflare.com/kv/concepts/how-kv-works/) describes eventual consistency, potentially 60 seconds or longer for cross-region visibility, and limitations for atomic operations. KV can become a read optimization but should not serve as the first-release generation lock. The exact D1 or Durable Objects coordination design still needs specification and validation.

## 8. Acceptance criteria before development

- Relaunch, navigation, reconnection and a downloaded bank preserve the same three recommendations and order during the day.
- The next day advances selection, reading across midnight is uninterrupted, and timezone changes do not repeatedly reshuffle it.
- Opening a home recommendation invokes neither text nor artwork generation and reads its prepared package directly.
- Cache hits for equivalent questions in the same language and age band return identical answer, quiz and illustration versions.
- Simultaneous first questions create only one generation job for the same reusable content.
- Changes in negation, language, age band, photos or relevant context cannot produce incorrect cache hits.
- Expiration changes future reuse without breaking old cards, maps, memories or public links.
- Incorrect content can be withdrawn. Incomplete assets, obsolete versions, offline operation and corrupt local caches have defined recovery paths.

## 9. Current state and next action

Primary-source product and engineering research is complete, and the user selected Cloudflare Vectorize as the preferred approach. The design is updated. Next verify multilingual embeddings, false hits and index consistency before integrating retrieval and reuse verification. This checkpoint changes the design only, with no additional runtime implementation or publication.

Local, uncommitted early code and content drafts predate the user's research-first correction. They are not reviewed implementation: text misses are not coalesced, the seed bank has only nine topics, three illustrations are reused, and review/active-withdrawal mechanisms are incomplete. Do not use these drafts directly as a release candidate. No new commit, deployment or TestFlight release has occurred.

Some attempted old sources were unavailable or returned empty shells, including the Wordle help URLs tried in this round. They were not used as evidence, and this report does not infer their current behavior or internal implementation.
