# Idiom

A new take on internationalisation in Elixir.

[![Hex.pm](https://img.shields.io/hexpm/v/idiom.svg)](https://hex.pm/packages/idiom) [![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/idiom/)

Please see the documentation on [HexDocs](https://hexdocs.pm/idiom/) for a full rundown on Idiom's features.

## State of Idiom

Idiom is in active development and should be considered pre-production software. Its core functionality works and is relatively well-tested, but some cases 
(such as RTL languages) are not yet covered by tests. If you have knowledge about languages and scripts that might be considered edge cases, please get in 
touch or just submit a pull request with test cases - I'll be forever grateful.  
There are also no backends packaged with Idiom yet. I will soon start actively adding some, with Phrase Strings first, and then widening the library.

That said, I *think* the API should be relatively stable at this point - I will still leave it at `0.x` for now, though, and not make any promises in that 
regard. As such, I would not recommend using Idiom in any mission-critical software at this point.

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
