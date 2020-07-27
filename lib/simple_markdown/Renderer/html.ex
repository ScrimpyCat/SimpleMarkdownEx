defprotocol SimpleMarkdown.Renderer.HTML do
    @moduledoc """
      A renderer protocol for HTML.

      Individual rule renderers can be overriden or new ones may be
      added. Rule types follow the format of structs defined under
      `SimpleMarkdown.Attribute.*`. e.g. If there is a rule with the
      name `:header`, to provide a rendering implementation for that
      rule, you would specify `for: SimpleMarkdown.Attribute.Header`.

      Rules then consist of a Map with an `input` field, and an optional
      `option` field. See `t:SimpleMarkdown.attribute/0`.

      Example
      -------
        defimpl SimpleMarkdown.Renderer.HTML, for: SimpleMarkdown.Attribute.Header do
            def render(%{ input: input, option: size }), do: "<h\#{size}>\#{SimpleMarkdown.Renderer.HTML.render(input)}</h\#{size}>"
        end
    """
    @fallback_to_any true

    @doc """
      Render the parsed markdown as HTML.
    """
    @spec render(Stream.t | [SimpleMarkdown.attribute | String.t] | SimpleMarkdown.attribute | String.t) :: String.t
    def render(ast)
end

defimpl SimpleMarkdown.Renderer.HTML, for: Any do
    def render(ast) do
        case SimpleMarkdown.Renderer.HTML.AST.impl_for(ast) do
            SimpleMarkdown.Renderer.HTML.AST.Any -> raise Protocol.UndefinedError, protocol: SimpleMarkdown.Renderer.HTML, value: ast
            _ -> SimpleMarkdown.Renderer.HTML.AST.render(ast) |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        end
    end
end
