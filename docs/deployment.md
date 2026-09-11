# Pocket Explorer deployment

The native app and website have separate repositories and release workflows.

## Website and API

- Production: https://pocket.changhai.me.
- Example: https://pocket.changhai.me/s/DmprLZx_BvlA75rki9n7MqFdl1b4U4hn.
- Source: [Pocket-Explorer-Backend](https://github.com/Little-Pocket-Explorer/Pocket-Explorer-Backend).
- [Cloudflare operations](https://github.com/Little-Pocket-Explorer/Pocket-Explorer-Backend/blob/main/docs/deployment.md) owns migrations, secrets, deployment and recovery.
- Backend main pushes deploy the website and Worker after checks. Existing D1 data, links and the domain remain intact.

The app defaults to the production origin. It generates a random credential in Keychain for creating and revoking its own shares. There is no parental approval, parent mode or manual key configuration. Public URLs authorize reads only.

## TestFlight

- App: Pocket Explorer, ID 6810920731.
- Bundle: com.haichang.pocketexplorer. Minimum iOS 17, iPhone only.
- Internal group: Hackathon Internal. External group: Hackathon External.
- Public external invitation: https://testflight.apple.com/join/83Jzf4WB.
- [GitHub release operations](github-release.md) owns automated signing, build numbers, upload, group assignment and recovery.

UI main pushes affecting native or CI files run regression and live Cloudflare integration before uploading to TestFlight. CI reads Apple's latest build number and assigns the next one. Native and backend deployment do not require Xcode UI.

The latest independently verified release before this extraction was 0.1.0 (6), Testing internally. External build 2 has passed review and remains available through its public link. See TODO and release evidence for subsequent versions.

## Verification limits

Keep real-device speech, camera, mobile Safari, accessibility and human visual acceptance separate from simulator and browser results. Prepared guide responses remain in use. The backend currently implements sharing and the public viewer, while live AI is future work.
