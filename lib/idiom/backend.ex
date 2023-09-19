defmodule Idiom.Backend do
  @moduledoc """
  Idiom is backend-agnostic and allows configuring different providers which are grouped under `Idiom.Backend`.

  ## Building your own

  Building an over-the-air backend is easy!  

  1. Build a module that can be started by a `Supervisor`.

  2. Write data to `Idiom.Cache`.
  Idiom's translations are stored inside an ETS table that is wrapped by `Idiom.Cache`. Your backend should update the cache by calling 
  `Idiom.Cache.insert_keys/2`. See the documentation for that function on the expected data structure.

  """
end
