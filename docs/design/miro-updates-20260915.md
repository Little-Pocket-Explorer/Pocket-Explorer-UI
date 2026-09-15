# Miro suggestions and supplied artwork

Source of truth: [Pocket Explorer Miro board](https://miro.com/app/board/uXjVHn9F6EQ=/).
Reviewed frames: App Suggestion (3458764683619183873) and IOS App View (3458764683600231800).
The refreshed board has 196 items. The suggestion frame contains seven reference images and feedback notes.
Miro images were returned as small thumbnails, and direct image URLs returned HTTP 403. Text feedback is readable. Pixel-exact comparison with those screenshots remains unverified.

## Feedback and implementation mapping

| Feedback | Current response | Remaining verification or scope |
| --- | --- | --- |
| Performance | Prepared questions, illustrations and narration are released in build 16 | Shared progressive text and automatic prepared narration are under verification |
| V1 top-left border radius | Clip badge within the card outline | Native screenshots |
| Illustration does not fill the card | Legacy artwork uses fill | Compare framing and cropping |
| Unequal compact card heights | Reserve two title lines | Long titles and Dynamic Type |
| Avatar alignment | Centered avatar released in build 16 | Check profile with new backdrop |
| Fade image edges | Home hero edge fade added locally | Actual device-size screenshot |
| Padding and margins | Preserve readable content margins | Review every supplied reference before broader changes |
| Settings styling | Supplied quiet backdrop applied locally | Full reference-style redesign remains pending |
| Restore more options, mock data acceptable | Six supplied artwork samples added to private Studio | Event and social mock flows remain pending |
| Reference map styling | Recorded as follow-up | Existing functional map remains, no new matching-style claim |
| Social priority | Recorded | Real accounts and friend chat remain deferred by explicit user decision |

## Supplied Marketing assets

Repository revision: [87a1be555c79acef4aa7553eda60d724bc3375d3](https://github.com/Little-Pocket-Explorer/Pocket-Explorer-Marketing/commit/87a1be555c79acef4aa7553eda60d724bc3375d3).

| Folder | Contents | Current use |
| --- | --- | --- |
| production/app-backgrounds-v1 | 13 portrait backgrounds, 853 by 1844 | 13-clean-blue-mint-perimeter.png converted to the native explorer-background asset |
| production/event-backgrounds-v1 | Stargazing, tide pool, fossil trail | Reviewed and reserved for explicit event demonstrations |
| production/card-art-v1 | Red panda, penguin chick, Maya pyramid, torii gates, prism, geode | Six selectable Studio samples, complete images preserved in square previews |
| production/ui-mockups-v1 | 51 high-resolution references | Available for visual comparison, not application functionality |

Source artwork is preserved in Marketing. The Backend asset evidence records source/output SHA256 hashes for the six samples.
The original Figma import baseline is unchanged. No board or Figma mutation was performed during this review.
Snapshots are retained in the primary UI checkout at design/miro-sync/source/snapshots/20260915-app-suggestion.svg and 20260915-ios-app-view.svg.
Do not mark a feedback item complete from compilation alone. Local visual changes are not in TestFlight build 16.
