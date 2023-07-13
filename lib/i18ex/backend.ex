defmodule I18ex.Backend do
  @callback list_namespaces() :: list(String.t())
  @callback get_namespace(name :: String.t()) :: map()
end
