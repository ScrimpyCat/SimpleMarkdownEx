defmodule SimpleMarkdown do
    @type attribute :: %{ :__struct__ => atom, :input => [attribute | String.t], :option => any }

    @spec convert(String.t, [parser: [Parsey.ast], render: ([SimpleMarkdown.attribute | String.t] -> String.t)]) :: String.t
    def convert(input, options \\ []) do
        options = Keyword.merge([parser: Application.fetch_env!(:simple_markdown, :rules), render: &SimpleMarkdown.Renderer.HTML.render/1], options)
        SimpleMarkdown.Parser.parse(input, options[:parser]) |> ast_to_structs |> options[:render].()
    end

    @spec ast_to_structs([Parsey.ast]) :: [attribute | String.t]
    def ast_to_structs(ast), do: Enum.map(ast, &node_to_struct(&1))

    @spec node_to_struct(Parsey.ast | String.t) :: attribute | String.t
    defp node_to_struct({ name, ast }), do: %{ __struct__: atom_to_module(name), input: ast_to_structs(ast) }
    defp node_to_struct({ name, ast, options }), do: %{ __struct__: atom_to_module(name), input: ast_to_structs(ast), option: options }
    defp node_to_struct(non_node), do: non_node

    @spec atom_to_module(atom) :: atom
    defp atom_to_module(name), do: String.to_atom("Elixir.SimpleMarkdown.Attribute." <> (to_string(name) |> String.split("_") |> Enum.map(&String.capitalize(&1)) |> Enum.join))
end
