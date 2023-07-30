# Idiom

A new take on internationalisation in Elixir.

[![Hex.pm](https://img.shields.io/hexpm/v/idiom.svg)](https://hex.pm/packages/idiom) [![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/idiom/)

Please see the documentation on [HexDocs](https://hexdocs.pm/idiom/) for a full rundown on Idiom's features.

## Basic usage

Interaction with Idiom happens through `t/3`.

```elixir
# Set the locale
Idiom.put_locale("en-US")

t("landing.welcome")

# With natural language key
t("Hello Idiom!")

# With interpolation
t("Good morning, {{name}}. We hope you are having a great day.", %{name: "Tim"})

# With plural and interpolation
t("You need to buy {{count}} carrots", count: 1)

# With namespace
t("signup:Create your account")
t("Create your account", namespace: "signup")
Idiom.put_namespace("signup")
t("Create your account")

# With explicit locale
t("Create your account", to: "fr")

# With fallback locale
t("Create your account", to: "fr", fallback: "en")
```

## Sources

### Local

Idiom by default automatically loads files from the file system on startup. These are placed in your `priv/idiom/` directory, although you can change the
directory in your `config.exs`:

```elixir
config :idiom, Idiom.Source.Local,
    data_dir: "priv/idiom/"
```

#### Directory structure

The `Local` source expects its data directory to follow this directory structure:

```
priv/idiom
└── en
   ├── default.json
   └── login.json
```

where `en` is the locale and `default` and `login` are namespaces separating the keys.

#### File format

The `json` files roughly follow the [i18next format](https://www.i18next.com/misc/json-format), with not all of its features supported. The following example
shows all of its features that Idiom currently supports.

```json
{
  "key": "value",
  "keyDeep": {
    "inner": "value"
  },
  "keyInterpolate": "replace this {{value}}",
  "keyPluralSimple_one": "the singular",
  "keyPluralSimple_other": "the plural",
  "keyPluralMultipleEgArabic_zero": "the plural form 0",
  "keyPluralMultipleEgArabic_one": "the plural form 1",
  "keyPluralMultipleEgArabic_two": "the plural form 2",
  "keyPluralMultipleEgArabic_few": "the plural form 3",
  "keyPluralMultipleEgArabic_many": "the plural form 4",
  "keyPluralMultipleEgArabic_other": "the plural form 5",
  "keyWithObjectValue": {
    "valueA": "return this with valueB",
    "valueB": "more text"
  }
}
```

## Over-the-air

### [Phrase Strings](https://phrase.com)

...
