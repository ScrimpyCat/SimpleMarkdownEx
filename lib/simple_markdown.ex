defmodule SimpleMarkdown do
    @moduledoc """
      Converts markdown into the specified rendered output.

      When first using the library the first thing to do is usually to
      generate the base rule config.
        $ mix simple_markdown.rules.new

      And then importing the config in your config.exs:
        import_config "simple_markdown_rules.exs"

      This config can be customized as you see fit. With new rules added,
      and other rules removed or modified. Depending on the changes made
      this may require some additional steps for things to work the way
      you want. e.g. If you add or change the way a rule type fundamentally
      works, you'll need to add or override the required rendering step
      for that type. Details for this can be found in renderer protocols.

      Example
      -------
        #config/simple_markdown_rules.exs
        #add the following rule to our ruleset
        lol: %{ match: ~r/\\Alol/, rules: [] }

        #lib/lol_renderer.ex
        #add a renderer for the HTML renderer for our "lol" rule
        defimpl SimpleMarkdown.Renderer.HTML, for: SimpleMarkdown.Attribute.Lol do
            def render(_), do: "<img src=\\"lolcat.jpg\\">"
        end

        #usage:
        SimpleMarkdown.convert("#lol") #=> "<h1><img src=\\"lolcat.jpg\\"></h1>"

      Additionally new renderers can be created. How these new renderers should
      be implemented is left up to you depending on how you'll provide input.
      If you use the standard `convert/2` then the input will
      be parsed, then the AST will be converted to these structs, and then
      that will be passed to your renderer. Alternatively you may call
      `SimpleMarkdown.Parser.parse/1` directly and then manipulate that AST
      how you see fit, and pass that to your renderer.
    """

    @type attribute :: %{ :__struct__ => atom, :input => [attribute | String.t], :option => any }

    @doc """
      Convert the text input into the rendered output. The default parser
      used is the one provided in the rules config, and the default
      renderer is the HTML renderer.
    """
    @spec convert(String.t, [parser: [Parsey.rule], render: ([SimpleMarkdown.attribute | String.t] -> String.t)]) :: String.t
    def convert(input, options \\ []) do
        options = Keyword.merge([parser: SimpleMarkdown.Parser.rules, render: &SimpleMarkdown.Renderer.HTML.render/1], options)
        SimpleMarkdown.Parser.parse(input, options[:parser]) |> ast_to_structs |> options[:render].()
    end

    @doc false
    # deprecated 0.5.0
    @spec to_html(String.t, [parser: [Parsey.rule], render: ([SimpleMarkdown.attribute | String.t] -> String.t)]) :: String.t
    def to_html(input, options \\ [render: &SimpleMarkdown.Renderer.HTML.render/1]), do: convert(input, options)

    @doc """
      Convert the AST into structs to allow for the rendering protocols
      to be applied to individual attributes.
    """
    @spec ast_to_structs([Parsey.ast]) :: [attribute | String.t]
    def ast_to_structs(ast), do: Enum.map(ast, &node_to_struct(&1))

    @doc false
    @spec node_to_struct(Parsey.ast | String.t) :: attribute | String.t
    defp node_to_struct({ name, ast }), do: %{ __struct__: atom_to_module(name), input: ast_to_structs(ast) }
    defp node_to_struct({ name, ast, options }), do: %{ __struct__: atom_to_module(name), input: ast_to_structs(ast), option: options }
    defp node_to_struct(non_node), do: non_node

    @doc false
    @spec atom_to_module(atom) :: atom
    def atom_to_module(name) do
        String.to_atom("Elixir.SimpleMarkdown.Attribute." <> format_as_module(to_string(name)))
    end

    @doc """
      Format a string to follow the module naming convention.
    """
    @spec format_as_module(String.t) :: String.t
    def format_as_module(name) do
        name
        |> String.split(".")
        |> Enum.map(fn module ->
            String.split(module, "_") |> Enum.map(&String.capitalize(&1)) |> Enum.join
        end)
        |> Enum.join(".")
    end

    @doc """
      Create a child module relative to parent.
    """
    @spec child_module(atom, atom) :: atom
    def child_module(parent, child), do: String.to_atom(to_string(parent) <> "." <> format_as_module(to_string(child)))
end
