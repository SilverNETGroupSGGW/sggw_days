# iOS GitHub Actions Deployment

This repository ships iOS releases through fastlane:

- `.github/workflows/testflight-deploy.yml` builds a signed IPA on semver tags such as `v1.2.3` and uploads it to TestFlight with fastlane `pilot`.
- `.github/workflows/app-store-release.yml` runs when a GitHub Release is published from the same tag and submits the existing TestFlight build to App Store review with fastlane `deliver`.

App Store publication is still subject to Apple review. When `IOS_APPSTORE_AUTOMATIC_RELEASE=true`, the release workflow marks the approved build for automatic release after review completes.

## Tag and release flow

1. Push a tag like `v1.2.3` or `1.2.3`.
2. GitHub Actions builds version `1.2.3` and uploads the IPA to TestFlight.
3. Publish a GitHub Release from the same tag.
4. GitHub Actions reuses that uploaded build and submits it to App Store review without rebuilding.

The workflows expect strict semver tags and derive deterministic iOS build numbers from them. Minor and patch versions must stay below `100`.

## Signing strategy

The TestFlight workflow supports two iOS signing modes:

1. Preferred: fastlane `match` in readonly mode.
2. Fallback: the existing `.p12` and provisioning-profile secrets already configured in GitHub.

`fastlane/Matchfile` is already configured for the current private repository and defaults to a dedicated `match-signing` branch. In CI, the workflow automatically uses `match` when `MATCH_PASSWORD` is present. If `MATCH_PASSWORD` is not set, it falls back to the direct signing secrets.

This keeps the migration low-risk:

- no forced reset of your current direct-signing secrets,
- only one additional long-lived secret is needed for `match`,
- production submissions reuse the already-processed TestFlight build.

## GitHub configuration

Required repository variables:

```bash
gh variable set IOS_BUNDLE_IDENTIFIER \
  --body com.silvernet.sggwDays \
  -R SilverNETGroupSGGW/sggw_days

gh variable set IOS_BUILD_NUMBER_OFFSET \
  --body 1000 \
  -R SilverNETGroupSGGW/sggw_days

gh variable set APPLE_TEAM_ID \
  --body YOUR_TEAM_ID \
  -R SilverNETGroupSGGW/sggw_days

gh variable set APPSTORE_ISSUER_ID \
  --body YOUR_ISSUER_ID \
  -R SilverNETGroupSGGW/sggw_days

gh variable set APPSTORE_API_KEY_ID \
  --body YOUR_KEY_ID \
  -R SilverNETGroupSGGW/sggw_days

gh variable set IOS_APPSTORE_AUTOMATIC_RELEASE \
  --body true \
  -R SilverNETGroupSGGW/sggw_days
```

Optional repository variables for overriding iOS Firebase and Google Sign-In configuration without editing the repo:

```bash
gh variable set IOS_GOOGLE_CLIENT_ID --body YOUR_IOS_CLIENT_ID -R SilverNETGroupSGGW/sggw_days
gh variable set IOS_GOOGLE_SERVER_CLIENT_ID --body YOUR_SERVER_CLIENT_ID -R SilverNETGroupSGGW/sggw_days
gh variable set IOS_GOOGLE_REVERSED_CLIENT_ID --body YOUR_REVERSED_CLIENT_ID -R SilverNETGroupSGGW/sggw_days
gh variable set IOS_FIREBASE_API_KEY --body YOUR_IOS_FIREBASE_API_KEY -R SilverNETGroupSGGW/sggw_days
gh variable set IOS_FIREBASE_APP_ID --body YOUR_IOS_FIREBASE_APP_ID -R SilverNETGroupSGGW/sggw_days
gh variable set IOS_FIREBASE_MESSAGING_SENDER_ID --body 583939995714 -R SilverNETGroupSGGW/sggw_days
gh variable set IOS_FIREBASE_PROJECT_ID --body sggw-days -R SilverNETGroupSGGW/sggw_days
gh variable set IOS_FIREBASE_STORAGE_BUCKET --body sggw-days.firebasestorage.app -R SilverNETGroupSGGW/sggw_days
gh variable set IOS_FIREBASE_CLIENT_ID --body YOUR_FIREBASE_IOS_CLIENT_ID -R SilverNETGroupSGGW/sggw_days
gh variable set IOS_FIREBASE_BUNDLE_ID --body com.silvernet.sggwDays -R SilverNETGroupSGGW/sggw_days
```

Required repository secret for every iOS deployment:

```bash
gh secret set APPSTORE_API_PRIVATE_KEY \
  -R SilverNETGroupSGGW/sggw_days < AuthKey_XXXXXXX.p8
```

Choose one signing mode.

Fastlane `match` mode:

```bash
printf '%s' 'YOUR_MATCH_PASSWORD' | \
  gh secret set MATCH_PASSWORD \
    -R SilverNETGroupSGGW/sggw_days
```

Direct-signing fallback mode:

```bash
base64 -w 0 ios_distribution.p12 | \
  gh secret set APPSTORE_CERTIFICATES_FILE_BASE64 \
    -R SilverNETGroupSGGW/sggw_days

printf '%s' 'YOUR_P12_PASSWORD' | \
  gh secret set APPSTORE_CERTIFICATES_PASSWORD \
    -R SilverNETGroupSGGW/sggw_days

base64 -w 0 SGGWDays_AppStore.mobileprovision | \
  gh secret set IOS_APPSTORE_PROFILE_BASE64 \
    -R SilverNETGroupSGGW/sggw_days
```

## Apple-side prerequisites

- Create or update the App ID in Apple Developer to match `IOS_BUNDLE_IDENTIFIER`.
- Create an App Store provisioning profile for that App ID.
- Export an Apple Distribution certificate as `.p12`.
- Create an App Store Connect API key with a role that can upload builds.
- If the iOS bundle identifier changes, create a matching iOS app in Firebase and update the optional Firebase and Google Sign-In variables above.

## Bootstrapping fastlane match

`match` is configured but not self-bootstrapping. Before CI can use it, import your existing App Store certificate and provisioning profile from a macOS machine that has access to Apple signing tools.

Recommended approach:

1. Keep the current direct-signing secrets in GitHub until `match` is verified.
2. Create the `match-signing` branch in this private repository if you want to keep the default storage location.
3. Run fastlane `match import` locally to place your current certificate and profile into the encrypted match storage.
4. Add `MATCH_PASSWORD` to GitHub secrets.
5. Trigger `testflight-deploy.yml` manually and confirm that CI succeeds in `match` mode.
6. Remove the direct-signing fallback secrets only after the `match` path is proven.

## Manual runs

Start a TestFlight upload manually:

```bash
gh workflow run testflight-deploy.yml \
  -R SilverNETGroupSGGW/sggw_days
```

Start an App Store submission manually:

```bash
gh workflow run app-store-release.yml \
  -R SilverNETGroupSGGW/sggw_days \
  -f release_version=1.2.3
```

Optional build number override for TestFlight:

```bash
gh workflow run testflight-deploy.yml \
  -R SilverNETGroupSGGW/sggw_days \
  -f build_number=1201
```
