defmodule SimpleMarkdown.Parser do
    @moduledoc """
      Parse the string with the given markdown ruleset.
    """

    @doc """
      Parse the string with the rules found in the config file.
    """
    @spec parse(String.t) :: [Parsey.ast]
    def parse(input), do: parse input, Application.fetch_env!(:simple_markdown, :rules)

    @doc """
      Parse the string with the specified ruleset.
    """
    @spec parse(String.t, [Parsey.rule]) :: [Parsey.ast]
    def parse(input, rules), do: Parsey.parse(input, rules)
end
