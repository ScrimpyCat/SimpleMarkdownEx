defmodule SimpleMarkdown.Parser do
    @moduledoc """
      Parse the string with the given markdown ruleset.

      For understanding of how rulesets work, check the
      [Parsey docs](https://hexdocs.pm/parsey/api-reference.html).
    """

    { :ok, rules } = Code.string_to_quoted(File.read!(Path.join(__DIR__, "rules.exs")))

    @doc """
      Get the default parsing rules.
    """
    @spec default_rules() :: [Parsey.rule]
    def default_rules, do: unquote(rules)

    @doc """
      Get the current parsing rules.
    """
    @spec rules() :: [Parsey.rule]
    def rules, do: Application.get_env(:simple_markdown, :rules, default_rules())

    @doc """
      Parse the string with the rules found in the config file.
    """
    @spec parse(String.t) :: [Parsey.ast]
    def parse(input), do: parse input, rules()

    @doc """
      Parse the string with the specified ruleset.
    """
    @spec parse(String.t, [Parsey.rule]) :: [Parsey.ast]
    def parse(input, rules), do: Parsey.parse(input, rules)
end
