# GitHub Actions Build and Release

This repository now includes a GitHub Actions-based macOS build and release path
that is separate from the local interactive release script.

## Files

- `.github/workflows/ci.yml`
  - Runs on pushes to `main` and on pull requests.
  - Executes `swift test`.
  - Packages a macOS app bundle and DMG through `scripts/package-macos.sh`.
  - Uploads the packaged output as a workflow artifact.

- `.github/workflows/release.yml`
  - Runs on tags matching `v*`.
  - Builds release assets on:
    - `macos-14` for `arm64`
    - `macos-13` for `x86_64`
  - Publishes the generated DMGs to GitHub Releases.

- `scripts/package-macos.sh`
  - CI-safe, non-interactive packaging script.
  - Builds the Swift package in release mode.
  - Creates `SnapRun.app`.
  - Produces a `.dmg` file for the current runner architecture.

## Expected Outputs

- CI workflow artifact directory:
  - `SnapRun.app`
  - `SnapRun-0.0.0-ci-<arch>.dmg`

- Release workflow assets:
  - `SnapRun-<version>-arm64.dmg`
  - `SnapRun-<version>-x86_64.dmg`

## GitHub Validation Steps

### 1. Validate CI on a branch or pull request

1. Push the current branch to GitHub.
2. Open the repository's `Actions` tab.
3. Confirm the `CI` workflow starts automatically.
4. Wait for the `Test and package macOS` job to finish.
5. Open the workflow run and verify:
   - `swift --version` completed successfully.
   - `swift test` passed.
   - `Package macOS app` passed.
6. Download the uploaded artifact and confirm it contains:
   - `SnapRun.app`
   - a `.dmg` file for the runner architecture

### 2. Validate release packaging with a test tag

1. Create and push a lightweight test tag:
   - `git tag v0.0.0-test`
   - `git push origin v0.0.0-test`
2. Open the repository's `Actions` tab.
3. Confirm the `Release` workflow starts automatically.
4. Verify both matrix jobs complete:
   - `Build arm64 release`
   - `Build x86_64 release`
5. Verify the `Publish GitHub release` job completes.
6. Open the repository `Releases` page.
7. Confirm a release for `v0.0.0-test` exists and contains:
   - `SnapRun-0.0.0-test-arm64.dmg`
   - `SnapRun-0.0.0-test-x86_64.dmg`

### 3. Validate downloaded packages

1. Download both DMGs from the release page.
2. Mount each DMG on the matching macOS machine or runner type.
3. Confirm the DMG contains:
   - `SnapRun.app`
   - the `Applications` shortcut
4. Launch `SnapRun.app` and verify the app opens successfully.

## Notes

- The current workflow does not notarize or sign with a Developer ID certificate.
  It uses ad-hoc signing, matching the local packaging approach.
- The workflows intentionally avoid modifying the existing `scripts/release.sh`
  so local release behavior and CI release behavior remain isolated.
