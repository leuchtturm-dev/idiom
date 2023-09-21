You can integrate Idiom with your Phoenix project quite simply.

## Importing Idiom

Begin by importing Idiom into your `MyAppWeb` module which brings in a couple of helper functions used commonly in your views:

```elixir
defmodule MyAppWeb do
  def html_helpers do
    quote do
      import Phoenix.HTML
      import Idiom
      # ... Other imports
    end
  end
end
```

## User-preferred language

If your user schema includes a `preferred_language` field (storing a locale string), the `put_locale/1` function can be used during mount to set the active 
language per user's preferred language:

```elixir
defp mount_current_user(socket, session) do
  Phoenix.Component.assign_new(socket, :current_user, fn ->
    with user_token when not is_nil(user_token) <- session["user_token"],
         %Accounts.User{} = user <- Accounts.get_user_by_session_token(user_token) do
      Idiom.put_locale(user.preferred_language)
      user
    end
  end)
end
```

## Translations in templates

You can use `t/2` and `t/3` functions directly in your Phoenix templates:

```elixir
~H"""
<%= t("Welcome!") %>

<!-- With bindings -->
<%= t("Welcome, {{name}}!", %{name: @current_user.name}) %>
"""
```

## Using namespaces for pages

You can organise your translations using namespaces and set a namespace per page:

```elixir
def mount(_params, _session, socket) do
    Idiom.put_namespace("signup")

    {:ok, reply}
end

def render(assigns) do
    ~H"""
    <%= t("Create your account") %>
    """
end
```

Here, the actual translation key becomes `"signup.Create your account"`.
