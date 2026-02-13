# Localization (i10n / l10n)

This project uses Flutter’s built-in localization generator (`flutter gen-l10n`).

- Source translations live in `lib/l10n/*.arb`
- The **template** file is `lib/l10n/app_en.arb` (configured in `l10n.yaml`)
- Generated Dart files are written into `lib/l10n/` (do **not** edit these by hand)

## Add a new text (new key)

1. Open `lib/l10n/app_en.arb`.
2. Add a new key + English value.
3. (Optional but recommended) Add a metadata entry with description:

Example:

```json
{
  "myNewLabel": "My new label",
  "@myNewLabel": { "description": "Label shown on the profile page" }
}
```

4. Add the **same key** to every other language file:

- `lib/l10n/app_fa.arb`
- `lib/l10n/app_ar.arb`
- `lib/l10n/app_tr.arb`

Notes:

- Keys must match exactly (case-sensitive).
- Keep ARB files valid JSON (commas, quotes, etc.).
- Only string values are used for simple getters.

## Update an existing translation

- Update the value for the same key in the relevant `app_*.arb` file.
- Keep the key unchanged.

## Generate / regenerate localization Dart files

The generator reads `l10n.yaml`, so you only need to run:

```bash
flutter gen-l10n
```

This will regenerate these files in `lib/l10n/` (examples):

- `app_localizations.dart`
- `app_localizations_en.dart`
- `app_localizations_fa.dart`
- `app_localizations_ar.dart`
- `app_localizations_tr.dart`

Important:

- Don’t manually edit `app_localizations*.dart` files; they will be overwritten.
- If you removed keys from `app_en.arb`, regenerate so the extra getters disappear.

## Add a new language (new locale)

1. Create a new ARB file in `lib/l10n/`:

Example for German:

- `lib/l10n/app_de.arb`
- Must include `"@@locale": "de"`

2. Copy all keys from `lib/l10n/app_en.arb` and translate values.
3. Run:

```bash
flutter gen-l10n
```

4. Ensure your app supports the locale (usually handled by the generated `supportedLocales` in `AppLocalizations`).

## Troubleshooting

- **Build fails / missing getter**: a key exists in `app_en.arb` but is missing in another `app_*.arb`.
- **Generator didn’t change output**: rerun `flutter gen-l10n` and make sure ARB JSON is valid.
- **Weird strings in UI**: verify the value language inside each `app_*.arb` file.
