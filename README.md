# Pulse Music — iOS 12+ Xcode starter project

A native UIKit music-player starter project targeting iOS 12. It includes on-device library browsing/playback through MediaPlayer, Apple Music catalog search through the Apple Music API, and a minimal now-playing screen with rotating artwork.

## Requirements
- A Mac with Xcode (use an Xcode version that still supports an iOS 12 deployment target).
- An Apple Developer account for device distribution/signing and Apple Music API credentials for catalog search.
- An Apple Music subscription and user authorization for subscription catalog playback.

## Open and run
1. Unzip the project on a Mac.
2. Open `PulseMusic.xcodeproj` in Xcode.
3. Select the `PulseMusic` target → Signing & Capabilities. Choose your development Team and change the bundle identifier from `com.example.PulseMusic` to one you own.
4. Connect an iPhone, select it as the run destination, and press Run.
5. On the phone, allow Media & Apple Music access when prompted.

## Enable Apple Music catalog search/streaming
1. Create a Media Services private key in the Apple Developer account and generate an Apple Music developer token (JWT) on a secure server or trusted local tool.
2. Paste the resulting developer token into `PulseMusic/PulseConfiguration.swift` as `appleMusicDeveloperToken`.
3. Do not put your `.p8` private key in the app or commit it to source control. A production app should fetch short-lived developer tokens from its own secure backend.
4. Search the catalog from the search field. The app uses the US storefront endpoint by default; adapt `/v1/catalog/us/search` to the user's storefront when building a production release.
5. Apple Music catalog playback requires authorization/subscription and is subject to Apple's API availability, storefront, content, and account rules. Test on a real device with an eligible account.

## Export an IPA
1. In Xcode, select **Any iOS Device (arm64)** as the destination.
2. Choose **Product → Archive**.
3. In Organizer, select the archive → **Distribute App**.
4. Choose **App Store Connect** for App Store/TestFlight, or **Ad Hoc / Development** for eligible registered devices.
5. Follow the signing prompts and export. Xcode creates the signed `.ipa`.

A signed IPA cannot be generated from this source bundle alone: it needs macOS/Xcode and your own Apple signing identity/provisioning profile. App Store distribution also requires Apple's review.

## Scope and limitations
- This is a functional starter, not a finished App Store release. It currently provides library listing/playback and catalog search/queueing, plus the animated now-playing screen.
- Apple Music subscription streaming is not guaranteed until developer-token setup, account authorization, subscription eligibility, and on-device testing are completed.
- The catalog search currently uses the US storefront. A production build should resolve the user's storefront and handle token refresh securely.
- Local library access is controlled by iOS privacy permission. Music DRM and subscription restrictions remain enforced by iOS/Apple Music.
- The project intentionally uses UIKit and MediaPlayer rather than modern MusicKit so the deployment target can remain iOS 12.
