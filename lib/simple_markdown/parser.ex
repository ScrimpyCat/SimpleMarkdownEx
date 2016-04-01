defmodule SimpleMarkdown.Parser do
	@spec parse(String.t) :: [Parsey.ast]
    def parse(input), do: parse input, Application.fetch_env!(:simple_markdown, :rules)

    @spec parse(String.t, [Parsey.rule]) :: [Parsey.ast]
    def parse(input, rules), do: Parsey.parse(input, rules)
end
