defprotocol SimpleMarkdown.Renderer.HTML do
    @spec render([SimpleMarkdown.attribute | String.t] | SimpleMarkdown.attribute | String.t) :: String.t
    def render(ast)
end

defimpl SimpleMarkdown.Renderer.HTML, for: List do
    def render(ast) do
        Enum.reduce(ast, "", fn attribute, string ->
            string <> SimpleMarkdown.Renderer.HTML.render(attribute)
        end)
    end
end

defimpl SimpleMarkdown.Renderer.HTML, for: BitString do
    def render(string), do: string
end

defimpl SimpleMarkdown.Renderer.HTML, for: SimpleMarkdown.Attribute.Header do
    def render(%{ input: input, option: size }), do: "<h#{size}>#{SimpleMarkdown.Renderer.HTML.render(input)}</h#{size}>"
end
