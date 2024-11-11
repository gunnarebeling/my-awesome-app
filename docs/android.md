# Android
## Generate an upload key and keystore

1. Make a `.dev` directory if you do not already have one.
```bash
mkdir .dev
```
2. Generate your keystore with the following command:
```bash
keytool -genkey -v -keystore ./.dev/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
  - Generate and store a secure password with Bitwarden.
  - Input your first and last name.
  - Put `Twin Sun` for organizational unit and organization.
  - Put `Nashville` for City.
  - Put `TN` for State.
  - Put `US` for Country Code.


  *This will store your new keystore in the* `.dev` *directory of your project.*

2.