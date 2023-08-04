defmodule Idiom.Source do
  @moduledoc """
  Idiom is extensible with different sources, which are grouped under `Idiom.Source`.

  ## Building a source
 
  Building an over-the-air source is easy!  

  It only has two requirements:
  1. Be a `GenServer` that can be started as a child to Idiom's supervisor.
  The OTA source is configured by setting Idiom's `ota_source` configuration to a module, which will then be passed to the supervisor. As such, it needs a
  `start_link/1` method.

  2. Write data to `Idiom.Cache`.
  Idiom's translations are stored inside an ETS table that is wrapped by `Idiom.Cache`. Your source should update the cache by calling 
  `Idiom.Cache.insert_keys/1`.
  That function takes a single argument, which is expected to be a map of the following structure:

  ```elixir
  %{
    "en" => %{"signup" => %{"Create your account" => "Create your account"}}, 
    "de" => %{"signup" => %{"Create your account" => "Erstelle deinen Account"}}}
  }
  ```

  where the first level is the locale, the second the namespace, and the third a map of the keys contained in the previous two. The keys can be nested further,
  the cache will automatically flatten them as such:

  ```elixir
  %{
    "en" => %{
      "signup" => %{
        "multiple" => %{
          "levels" => %{
            "nesting" => "Hello!"
          }
        }
      }
    }
  }
  ```

  will result in a key of `multiple.levels.nesting` inside the `signup` namespace with a message value of `Hello!`.
  """
end
