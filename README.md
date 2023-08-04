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
