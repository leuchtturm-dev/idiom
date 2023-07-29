# Natural Language Keys

## Namespaces

By default, you can use colons (`:`) to namespace a key. When using natural language keys, this can cause issues, such as when the key contains a colon itself.
Consider this situation: 
```elixir
t("Get started on GitHub: create your account")
```
Using the colon as a separator, Idiom would try to resolve this as key ` create your account` in the `Get started on GitHub` namespace - this is obviously not 
what you intended.

There are multiple ways to work around this:

1. Explicitly specify the namespace - when a namespace is set this way, the key is left as-is without trying to extract the namespace.
```elixir
t("Get started on GitHub: create your account", namespace: "default")
```

2. Set a different namespace separator for the key.
```elixir
t("Get started on GitHub: create your account", namespace_separator: "|")
```
