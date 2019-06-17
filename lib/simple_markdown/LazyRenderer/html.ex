defprotocol SimpleMarkdown.LazyRenderer.HTML do
    @moduledoc """
      A lazily evaluated renderer protocol for HTML.

      Any customisation should be done to `SimpleMarkdown.Renderer.HTML`.
    """

    @doc """
      Render the parsed markdown as HTML.
    """
    @spec render(Stream.t | [SimpleMarkdown.attribute | String.t] | SimpleMarkdown.attribute | String.t) :: Stream.t
    def render(ast)
end

defimpl SimpleMarkdown.LazyRenderer.HTML, for: [List, Stream] do
    def render(ast), do: Stream.map(ast, &SimpleMarkdown.Renderer.HTML.render/1)
end

defimpl SimpleMarkdown.LazyRenderer.HTML, for: Any do
    def render(ast), do: SimpleMarkdown.LazyRenderer.HTML.render([ast])
end
