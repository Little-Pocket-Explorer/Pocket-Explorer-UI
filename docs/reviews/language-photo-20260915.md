# Language and photo refinement review

This candidate adds ten languages while preserving existing journals and public links. It also improves photo preparation, large-text reading and share failures. This is a pre-release review. Final local verification is complete. Local TestFlight publication is pending.

## Reproduced defects and changes

- New examples could be created before language selection. They now wait for the first choice and retain consistent titles, content and dates. First-selection loading that did not resume was reproduced and fixed.
- Restoring a broken photo could duplicate the original question. Explicit photo-change state now preserves the existing request identity.
- Targeted checks cover selecting the same photo again, late results after cancellation, invalid/oversized images and download deadlines. New uploads are downsampled and stripped of EXIF/GPS. Existing request recovery retains original bytes for idempotency.
- At maximum text size, the home input was 272pt high, Play was 152.5pt high, and two-column cards were only 162pt wide. Short input labels, fixed icons, single-column cards and stacked playback controls restore usable space. Text, map entry, cards and sharing actions remain reachable.
- Network and malformed-response sharing errors used the device language. A new failing reproduction now passes after mapping failures to the selected app language, with cancellation kept distinct.

## Tests and actual review

The final candidate verifies 85 unit and 44 distinct UI tests, with two explicit skips. Its complete run had one French maximum-text failure. Failure hierarchy shows the test tapped the tab bar and returned to the map. The old helper accepted a partly obscured button whose center was inside that bar. Positioning the button fully in the usable region passed three independent French iterations and a complete 14-case language rerun. No application source changed for this test correction. Original failed evidence is retained.

Actual screenshots cover ten languages and Arabic RTL, plus maximum text in German, French, Portuguese and Arabic. Inspection found further brand-word wrapping, category truncation and a decorative chapter strip exposed as a separate accessibility target. Those issues were addressed.

Apple's contrast audit also samples scrolling labels occluded by bottom overlays. Its reports remain attached for pixel review. Ordinary test success is not described as an empty contrast report. Clipping, hit-region, element-description and reading-space checks remain strict. Control experiments isolated caption clipping reports to tracking. Kerning preserves the spaced appearance while passing the strict clipping audit, with before/after screenshot comparison. Ineffective extra-padding experiments were removed.

## Independent review

The user-authorized cl -p review reported model databricks-claude-opus-5. Reproduced photo-lifecycle findings and checked translation corrections were accepted. Claims contradicted by successful compilation, model definitions and tests were rejected. Some outputs begin mid-sentence and are not treated as complete review results.

## Release constraints and remaining checks

TestFlight remains 0.1.0 (10). New native code is unpublished. The ten-language backend viewer and compass fallback are deployed, with actual public content readback and revocation verified.

Changed Swift executable-line coverage is 401/411 (97.57%), with every changed file above 80%. Application coverage is 4989/5193 (96.07%). A fresh scan of 275 repository files found none of the three checked configured service/owner values. An earlier 145-file scan additionally checked the reasoning credential. Publication must use this Mac without a GitHub iOS workflow. Internal QoS runtime warnings remain in the original result and are not yet attributed to application code.

The paired physical iPhone could not be connected for version/crash reads. Its TestFlight app was not overwritten. Physical microphone, camera, speaker naturalness, VoiceOver and native-speaker child-facing copy review remain outstanding. The simulator recording environment's system crash was reproduced on released source and is not attributed to this candidate.

Logs, screenshots, control experiments and xcresult bundles are under ~/tmp/review/pocket-polish-20260915/.
