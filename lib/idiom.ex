defmodule Idiom do
  @moduledoc """
  A new take on internationalisation in Elixir.

  ## Basic usage

  Interaction with Idiom happens through `t/3`.

  ```elixir
  # Set the locale
  Idiom.put_locale("en-US")

  t("landing.welcome")

  # With natural language key
  t("Hello Idiom!")

  # With plural
  t("You need to buy carrots", count: 1)

  # With interpolation
  t("Good morning, {{name}}. We hope you are having a great day.", %{name: "Tim"})

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

  ## Motivation

  Today, internationalisation in Elixir is dominated by Gettext. While a great library that has served the community well since its inception, and the
  default in Phoenix, there are a few things that Idiom is looking to change:

  1. Translations do not need to be available at compile-time, with pluggable sources available.  
  Gettext requires all translations to be stored in `.po` files that need to be available at compile-time. Baking the translations into the compiled project
  has lots of advantages, in particular performance, but it also comes with a large downside: in order to update a single string in your application, you
  are required to rebuild and redeploy the entire project. Idiom builds on a different architecture, using an ETS cache as central store, and being flexible
  as to where its contents are coming from. Like Gettext, Idiom comes with an in-built source to source translations from the file-system, but can also be
  set up to pull translations from external services, allowing you to use a software localisation platform to manage all of your translations, and pushing new
  versions of it without having to redeploy your Elixir service.
  2. The public API for translating messages only includes one function, `t/3`.  
  This is in contrast to Gettext, which exposes different functions for  choosing a domain (Idiom calls these namespaces), plural, or interpolation. With 
  Idiom, you just need to remember the three parameters of `t/3`: `key`, `bindings` (optional) and `opts` (also optional).

  ## Installation

  To start off, add `idiom` to the list of your dependencies:
  ```elixir
  def deps do
    {:idiom, "~> 0.1"},
  end
  ```

  Additionally, in order to be able refresh translations in the background, add Idiom's `Supervisor` to your application:
  ```elixir
  def start(_type, _args) do
    children = [
      Idiom,
    ]

    # ...
  end
  ```

  ## Configuration

  There are a few things around Idiom that you can configure on an application level. The following fence shows all of Idiom's settings and their defaults.

  ```elixir
  config :idiom,
    default_locale: "en",
    default_fallback: "en",
    default_namespace: "default",
    ota_provider: nil
  ```

  In order to configure your OTA provider, please have a look at its module documentation.  

  ## Locales

  When calling `t/3`, Idiom follows these steps to determine which locale to translate the key to:

  1. The explicit `to` option. When you call `t("key", to: "fr")`, Idiom will always use `fr` as a locale.
  2. The locale set in the current process. You can call `Idiom.put_locale/1` to set it.
  Since this is just a wrapper around the process dictionary, it needs to be set for each process you are using Idiom in.
  3. The `default_locale` setting. See the [Configuration](#module-configuration) section for more details on how to set it.

  ### Resolution hierarchy

  > #### A note on examples {: .info}
  >
  > For ease of presentation, whenever an example in this module documentation includes a translation file for context, it will be merged from the multiple
  > files that `Idiom.Source.Local` actually expects. Instead of giving you the contents of all `en/default.json`, `en-US/default.json`, `en-GB/default.json`
  > and others, it will be represented here as one merged file, such as:
  > ```json
  > { 
  >   "en": {"default": { [Contents of what would usually be `en/default.json` ] }},
  >   "en-US": {"default": { [Contents of what would usually be `en-US/default.json` ] }},
  >   ...
  > }
  > ```

  Locale codes can consist of multiple parts. Taking `zh-Hant-HK` as an example, we have the language (`zh` - Chinese), the script (`Hant`, Tradtional) and the
  region (`HK` - Hong Kong). For different regions, there might only be differences for some specific keys, whereas all other keys share a translation. In
  order to prevent needless repetition in your translation workflow, Idiom will always try to resolve translations in all of language, language and script, and
  language, script and region variants, in order of specifity.

  Taking the following file as an example (see also [File format](#module-file-format)):
  ```json
  {
    "en": {
      "default": {
        "Create your account": "Create your account"
      }
    },
    "en-US": {
      "default": {
        "Take the elevator": "Take the elevator"
      }
    },
    "en-GB": {
      "default": {
        "Take the elevator": "Take the lift"
      }
    }
  }
  ```
  The `Create your account` message is the same for both American and British English, whereas the key `Take the elevator` has different wording for each.
  With Idiom's resolution hierarchy, you can use both `en-US` and `en-GB` to refer to the `Create your account` key as well.

  ```elixir
  t("Take the elevator", to: "en-US")
  # -> Take the elevator
  t("Take the elevator", to: "en-GB")
  # -> Take the lift
  # Will first try to resolve the key in the `en-US` locale, then, since it does not exist, try `en`.
  t("Create your account", to: "en-US")
  # -> Create your account
  t("Create your account", to: "en-GB")
  # -> Create your account
  ```

  ### Fallback locales

  For when a key might not be available in the set locale, you can set a fallback.  
  A fallback can be either a string or a list of strings. If you set the fallback as a list, Idiom will return the translation of the first locale for which
  the key is available.

  When you don't explicitly set a `fallback` for `t/3`, Idiom will try the `default_fallback` (see [Configuration](#module-configuration)).
  When a key is available in neither the target **or** any of the fallback language, the key will be returned as-is.


  ```elixir
  # will return the translation for `en`
  t("Key that is only available in `en` and `fr`", to: "es", fallback: "en")
  # will return the translation for `fr`
  t("Key that is only available in `en` and `fr`", to: "es", fallback: ["fr", "en"])
  # will return the translation for `en`, which is set as `default_fallback`
  t("Key that is only available in `en` and `fr`", to: "es")
  # will return "Key that is not available in any locale"
  t("Key that is not available in any locale", to: "es")
  ```

  ## Interpolation

  Idiom supports interpolation in messages.  
  Interpolation can be added by adding an interpolation key to the message, enclosing it in `{{}}`. Then, you can bind the key to any string by passing it as
  key inside the second parameter of `t/3`.

  Taking the following file as an example (see also [File format](#module-file-format)):
  ```json
  {
    "en": {
      "default": {
        "Welcome, {{name}}": "Welcome, {{name}}",
        "It is currently {{temperature}} degrees in {{city}}": "It is currently {{temperature}} degrees in {{city}}"
      }
    }
  }
  ```

  These messages can then be interpolated as such:

  ```elixir
  t("Welcome, {{name}}", %{name: "Tim"})
  # -> Welcome, Tim
  t("It is currently {{temperature}} degrees in {{city}}", %{temperature: "31", city: "Hong Kong"})
  # -> It is currently 31 degrees in Hong Kong
  ```
  """

  import Idiom.Interpolation
  alias Idiom.Cache
  alias Idiom.Locales
  alias Idiom.Plural
  require Logger

  @doc false
  defdelegate child_spec(options), to: Idiom.Supervisor

  @doc """
  Alias of `t/3` for when you don't need any bindings.
  """
  def t(key, opts) when is_list(opts), do: t(key, %{}, opts)

  @type translate_opts() :: [
          namespace: String.t(),
          to: String.t(),
          fallback: String.t() | list(String.t()),
          count: integer() | float() | Decimal.t() | String.t()
        ]
  @doc """
  Translates a key into a target language.

  The `translate/2` function takes two arguments:
  - `key`: The specific key for which the translation is required.
  - `opts`: An optional list of options.

  ## Target and fallback languages

  For both target and fallback languages, the selected options are based on the following order of priority:
  1. The `:to` and `:fallback` keys in `opts`.
  2. The `:locale` and `:fallback` keys in the current process dictionary.
  3. The application configuration's `:default_locale` and `:default_fallback` keys.

  The language needs to be a single string, whereas the fallback can both be a single string or a list of strings.

  ## Namespaces

  Keys can be namespaced. ... write stuff here

  ## Configuration

  Application-wide configuration can be set in `config.exs` like so:

  ```elixir
  config :idiom,
    default_locale: "en",
    default_fallback: "fr"
    # default_fallback: ["fr", "es"]
  ```

  ## Examples

      iex> translate("hello", to: "es")
      "hola"

      # If no `:to` option is provided, it will check the process dictionary:
      iex> Process.put(:lang, "fr")
      iex> translate("hello")
      "bonjour"

      # If neither `:to` option is provided nor `:lang` is set in the process, it will check the application configuration:
      # Given `config :idiom, default_lang: "en"` is set in the `config.exs` file:
      iex> translate("hello")
      "hello"

      # If a key does not exist in the target language, it will use the `:fallback` option:
      iex> translate("hello", to: "de", fallback: "fr")
      "bonjour"

      # If a key does not exist in the target language or the first fallback language:
      iex> translate("hello", to: "de", fallback: ["pl", "fr"])
      "bonjour"
  """

  @spec t(String.t(), map(), translate_opts()) :: String.t()
  def t(key, bindings \\ %{}, opts \\ []) do
    locale = Keyword.get(opts, :to) || get_locale()
    fallback = Keyword.get(opts, :fallback) || Application.get_env(:idiom, :default_fallback)
    count = Keyword.get(opts, :count)
    bindings = Map.put_new(bindings, :count, fn -> count end)
    {namespace, key} = extract_namespace(key, opts)

    resolve_hierarchy =
      [locale | List.wrap(fallback)]
      |> Enum.map(&Locales.get_hierarchy/1)
      |> List.flatten()

    keys =
      Enum.reduce(resolve_hierarchy, [], fn locale, acc ->
        acc ++ [{locale, namespace, key}, {locale, namespace, "#{key}_#{Plural.get_suffix(locale, count)}"}]
      end)

    cache_table_name = Keyword.get(opts, :cache_table_name, Cache.cache_table_name())

    Enum.find_value(keys, key, fn {locale, namespace, key} -> Cache.get_translation(locale, namespace, key, cache_table_name) end)
    |> interpolate(bindings)
  end

  @doc """
  Returns the locale that will be used by `t/3`.

  ## Examples

  ```elixir
  iex> Idiom.get_locale()
  "en-US"
  ```
  """
  @spec get_locale() :: String.t() | nil
  def get_locale() do
    Process.get(:idiom_locale) || Application.get_env(:idiom, :default_locale)
  end

  @doc """
  Sets the locale for the current process.

  ## Examples

  ```elixir
  iex> Idiom.put_locale("fr-FR")
  :ok
  ```
  """
  @spec put_locale(String.t()) :: String.t()
  def put_locale(locale) do
    Process.put(:idiom_locale, locale)

    locale
  end

  @doc """
  Returns the namespace that will be used by `t/3`.

  ## Examples

  ```elixir
  iex> Idiom.get_namespace()
  "signup"
  ```
  """
  @spec get_namespace() :: String.t() | nil
  def get_namespace() do
    Process.get(:idiom_namespace) || Application.get_env(:idiom, :default_namespace)
  end

  @doc """
  Sets the namespace for the current process.

  ## Examples

  ```elixir
  iex> Idiom.put_namespace("signup")
  :ok
  ```
  """
  @spec put_namespace(String.t()) :: String.t()
  def put_namespace(namespace) do
    Process.put(:idiom_namespace, namespace)

    namespace
  end

  @doc false
  defp extract_namespace(key, opts) do
    namespace_from_opts = Keyword.get(opts, :namespace) || get_namespace()
    namespace_separator = Keyword.get(opts, :namespace_separator, ":")

    if String.contains?(key, namespace_separator) do
      [namespace | key_parts] = String.split(key, namespace_separator)

      if is_binary(Keyword.get(opts, :namespace)) or is_binary(Process.get(:namespace)) do
        Logger.warning("Namespace was set explicitly, but key #{key} already includes a namespace. Using the key's namespace: #{namespace}.")
      end

      {namespace, Enum.join(key_parts, ".")}
    else
      {namespace_from_opts, key}
    end
  end
end
