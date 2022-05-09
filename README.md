# flutter_app_base

## Setup

1. Clone this repo to a new directory with `git clone git@gitlab.com:twinsunllc/twin-sun-technology/flutter-app-base.git my-awesome-app`
2. Enter the directory `cd my-awesome-app`
3. Change the origin url to your git repository: `git remote set-url origin git@gitlab.com:twinsunllc/my-awesome-app.git`
4. Push: `git push -u origin main`
5. Find all occurrences of `FlutterAppBase`, `flutterAppBase`, `flutter-app-base`, and `flutter_app_base` and replace them with e.g. `MyAwesomeApp`, `myAwesomeApp`, `my-awesome-app` and `my_awesome_app`
6. Change the bundle identifier and relevant kotlin package path names (`dev/twinsun/flutter_app_base` to `your/package/path`).
7. Update the google-services.json and android/fastlane/Fastfile to point to the correct Firebase apps.
8. Commit the result and push.

## Deployment

Set up Firebase deployments (for Android), TestFlight (for iOS), and the Play Store (for Android). Add or update the fastlane configurations and gitlab deployment jobs (.gitlab-ci.yml) as needed.

Make sure your keystore and signing certificates make it to the build agent (ask Jami about this).

Run deployment jobs through GitLab CI/CD.
