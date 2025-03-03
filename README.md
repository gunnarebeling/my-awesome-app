# my_awesome_app

## Setup

1. Clone this repo to a new directory with `git clone git@github.com:twinsunllc/my-awesome-app.git my-awesome-app`
2. Enter the directory `cd my-awesome-app`
3. Change the origin url to your git repository: `git remote set-url origin git@github.com:twinsunllc/my-awesome-app.git`
4. Push: `git push -u origin main`
5. Find all occurrences of `MyAwesomeApp`, `MyAwesomeApp`, `my-awesome-app`, and `my_awesome_app` and replace them with e.g. `MyAwesomeApp`, `myAwesomeApp`, `my-awesome-app` and `my_awesome_app`
6. Change the bundle identifier and relevant kotlin package path names (`dev/twinsun/my_awesome_app` to `your/package/path`).
7. Update the google-services.json and android/fastlane/Fastfile to point to the correct Firebase apps.
8. Update the Critic key in `lib/bloc/critic_bloc.dart` to your app.
9. Commit the result and push.

## Development

> Note: If using an editor besides VS Code you will need to prefix all `flutter` commands with `fvm`.
1. Install FVM if you haven't already: `dart pub global activate fvm`
2. Install the flutter version for this project: `fvm install`
4. Run the app using vscode or `flutter run`
5. Generate mocks with `flutter pub run build_runner build`
6. Run tests with `flutter test`

## Deployment

* Set up Firebase deployments (for Android)
* Set up TestFlight (for iOS)
* Set up the Play Store (for Android)
* Add or update the fastlane configurations
* Add or update the github workflows as needed

*If iOS builds are timing out, ask Jami to check that the build scripts have access to the certs*

Run deployment jobs through GitHub CI/CD.

Video walkthrough setting up deployments for iOS: https://drive.google.com/file/d/1sssT5mVUKI57BXGD-DPuTHxzhe4f69X5/view?usp=share_link

### Code Signing

#### Android

1. Add android keystore to Github Secrets and Variables. [Android Deployments](docs/android.md)

#### iOS

1. Create your app in App Store Connect.
2. Update Fastfile, Appfile, Matchfile in ios/fastlane as needed.
3. Generate signing certs and profiles as needed:

```bash
cd ios
PRIVATE_TOKEN="<your github token here>" bundle exec fastlane match development
PRIVATE_TOKEN="<your github token here>" bundle exec fastlane match appstore
```
