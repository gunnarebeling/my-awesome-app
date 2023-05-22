# flutter_app_base

## Setup

1. Clone this repo to a new directory with `git clone git@gitlab.com:twinsunllc/twin-sun-technology/flutter-app-base.git my-awesome-app`
2. Enter the directory `cd my-awesome-app`
3. Change the origin url to your git repository: `git remote set-url origin git@gitlab.com:twinsunllc/my-awesome-app.git`
4. Push: `git push -u origin main`
5. Find all occurrences of `FlutterAppBase`, `flutterAppBase`, `flutter-app-base`, and `flutter_app_base` and replace them with e.g. `MyAwesomeApp`, `myAwesomeApp`, `my-awesome-app` and `my_awesome_app`
6. Change the bundle identifier and relevant kotlin package path names (`dev/twinsun/flutter_app_base` to `your/package/path`).
7. Update the google-services.json and android/fastlane/Fastfile to point to the correct Firebase apps.
8. Update the Critic key in `lib/bloc/critic_bloc.dart` to your app.
9. Commit the result and push.

## Development

1. Install FVM if you haven't already: `dart pub global activate fvm`
2. Install the flutter version for this project: `fvm install $(cat .flutter-version)`
3. Use this flutter version: `fvm use $(cat .flutter-version)`
4. Run the app using vscode or `fvm flutter run`

## Deployment

Set up Firebase deployments (for Android), TestFlight (for iOS), and the Play Store (for Android). Add or update the fastlane configurations and gitlab deployment jobs (.gitlab-ci.yml) as needed.

Make sure your keystore and signing certificates make it to the build agent (ask Jami about this).

Run deployment jobs through GitLab CI/CD.

Video walkthrough setting up deployments for iOS: https://drive.google.com/file/d/1sssT5mVUKI57BXGD-DPuTHxzhe4f69X5/view?usp=share_link

### Code Signing

#### Android

1. Add keystore to Gitlab Secure Files for android.
2. Update .gitlab-ci.yml with appropriate values.

#### iOS

1. Create your app in App Store Connect.
2. Update Fastfile, Appfile, Matchfile in ios/fastlane as needed.
3. Generate signing certs and profiles as needed:

```
cd ios
PRIVATE_TOKEN="<your gitlab token here>" bundle exec fastlane match development
PRIVATE_TOKEN="<your gitlab token here>" bundle exec fastlane match appstore
```
