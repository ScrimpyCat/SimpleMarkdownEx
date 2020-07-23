defprotocol SimpleMarkdown.Renderer.HTML.AST do
    @moduledoc """
      A renderer protocol for HTML AST.

      Individual rule renderers can be overriden or new ones may be
      added. Rule types follow the format of structs defined under
      `SimpleMarkdown.Attribute.*`. e.g. If there is a rule with the
      name `:header`, to provide a rendering implementation for that
      rule, you would specify `for: SimpleMarkdown.Attribute.Header`.

      Rules then consist of a Map with an `input` field, and an optional
      `option` field. See `t:SimpleMarkdown.attribute/0`.

      Example
      -------
        defimpl SimpleMarkdown.Renderer.HTML.AST, for: SimpleMarkdown.Attribute.Header do
            def render(%{ input: input, option: size }), do: { "h\#{size}", [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
        end
    """

    @doc """
      Render the parsed markdown as HTML.
    """
    @spec render(Stream.t | [SimpleMarkdown.attribute | String.t] | SimpleMarkdown.attribute | String.t) :: SimpleMarkdown.Renderer.HTML.Utilities.ast
    def render(ast)
end

defimpl SimpleMarkdown.Renderer.HTML.AST, for: [List, Stream] do
    def render(ast) do
        Enum.map(ast, fn attribute ->
            SimpleMarkdown.Renderer.HTML.AST.render(attribute)
        end)
    end
end

defimpl SimpleMarkdown.Renderer.HTML.AST, for: BitString do
    def render(string), do: string
end

defimpl SimpleMarkdown.Renderer.HTML.AST, for: SimpleMarkdown.Attribute.LineBreak do
    def render(_), do: { :br, [], [] }
end

defimpl SimpleMarkdown.Renderer.HTML.AST, for: SimpleMarkdown.Attribute.Header do
    def render(%{ input: input, option: 1 }), do: { :h1, [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
    def render(%{ input: input, option: 2 }), do: { :h2, [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
    def render(%{ input: input, option: 3 }), do: { :h3, [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
    def render(%{ input: input, option: 4 }), do: { :h4, [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
    def render(%{ input: input, option: 5 }), do: { :h5, [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
    def render(%{ input: input, option: 6 }), do: { :h6, [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
end

defimpl SimpleMarkdown.Renderer.HTML.AST, for: SimpleMarkdown.Attribute.Emphasis do
    def render(%{ input: input, option: :regular }), do: { :em, [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
    def render(%{ input: input, option: :strong }), do: { :strong, [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
end

defimpl SimpleMarkdown.Renderer.HTML.AST, for: SimpleMarkdown.Attribute.HorizontalRule do
    def render(_), do: { :hr, [], [] }
end

defimpl SimpleMarkdown.Renderer.HTML.AST, for: SimpleMarkdown.Attribute.Table do
    def render(%{ input: input, option: heading = [{_, _}|_] }) do
        { titles, aligns } = Enum.unzip(heading)

        input = Enum.map(input, fn
            %{ __struct__: SimpleMarkdown.Attribute.Row, input: elements } -> %{ __struct__: SimpleMarkdown.Attribute.Row, input: elements, option: aligns }
        end)

        {
            :table,
            [],
            [
                { :thead, [], { :tr, [], Enum.map(titles, &({ :th, [], SimpleMarkdown.Renderer.HTML.AST.render(&1) })) } },
                { :tbody, [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
            ]
        }
    end
    def render(%{ input: input, option: aligns }) do
        input = Enum.map(input, fn
            %{ __struct__: SimpleMarkdown.Attribute.Row, input: elements } -> %{ __struct__: SimpleMarkdown.Attribute.Row, input: elements, option: aligns }
        end)

        {
            :table,
            [],
            [
                { :tbody, [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
            ]
        }
    end
end

defimpl SimpleMarkdown.Renderer.HTML.AST, for: SimpleMarkdown.Attribute.Row do
    def render(%{ input: input, option: align }) do
        {
            :tr,
            [],
            Enum.zip(input, align)
            |> Enum.map(fn
                { input, :default } -> { :td, [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
                { input, align } -> { :td, [style: ["text-align: ", to_string(align), ";"]], SimpleMarkdown.Renderer.HTML.AST.render(input) }
            end)
        }
    end
    def render(%{ input: input }), do: { :tr, [], Enum.map(input, &({ :td, [], SimpleMarkdown.Renderer.HTML.AST.render(&1) })) }
end

defimpl SimpleMarkdown.Renderer.HTML.AST, for: SimpleMarkdown.Attribute.TaskList do
    def render(%{ input: input }), do: { :ul, [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
end

defimpl SimpleMarkdown.Renderer.HTML.AST, for: SimpleMarkdown.Attribute.Task do
    def render(%{ input: input, option: :deselected }), do: { :li, [], [{ :input, [type: :checkbox, disabled: ""], [] }, SimpleMarkdown.Renderer.HTML.AST.render(input)] }
    def render(%{ input: input, option: :selected }), do: { :li, [], [{ :input, [type: :checkbox, checked: "", disabled: ""], [] }, SimpleMarkdown.Renderer.HTML.AST.render(input)] }
end

defimpl SimpleMarkdown.Renderer.HTML.AST, for: SimpleMarkdown.Attribute.List do
    def render(%{ input: input, option: :unordered }), do: { :ul, [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
    def render(%{ input: input, option: :ordered }), do: { :ol, [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
end

defimpl SimpleMarkdown.Renderer.HTML.AST, for: SimpleMarkdown.Attribute.Item do
    def render(%{ input: input }), do: { :li, [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
end

defimpl SimpleMarkdown.Renderer.HTML.AST, for: SimpleMarkdown.Attribute.PreformattedCode do
    def render(%{ input: input, option: syntax }) do
        try do
            module = SimpleMarkdown.child_module!(SimpleMarkdown.Attribute.PreformattedCode, syntax)
            :ok = Protocol.assert_impl!(SimpleMarkdown.Renderer.HTML.AST, module)
            module
        rescue
            ArgumentError ->
                try do
                    module = SimpleMarkdown.child_module!(SimpleMarkdown.Attribute.PreformattedCode, syntax)
                    :ok = Protocol.assert_impl!(SimpleMarkdown.Renderer.HTML, module)
                    module
                rescue
                    ArgumentError -> SimpleMarkdown.Renderer.HTML.AST.render(%{ __struct__: SimpleMarkdown.Attribute.PreformattedCode, input: input })
                else
                    module -> SimpleMarkdown.Renderer.HTML.render(%{ __struct__: module, input: input }) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast
                end
        else
            module -> SimpleMarkdown.Renderer.HTML.AST.render(%{ __struct__: module, input: input })
        end
    end

    def render(%{ input: input }), do: { :pre, [], { :code, [], SimpleMarkdown.Renderer.HTML.AST.render(input) } }
end

defimpl SimpleMarkdown.Renderer.HTML.AST, for: SimpleMarkdown.Attribute.Paragraph do
    def render(%{ input: input }), do: { :p, [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
end

defimpl SimpleMarkdown.Renderer.HTML.AST, for: SimpleMarkdown.Attribute.Blockquote do
    def render(%{ input: input }), do: { :blockquote, [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
end

defimpl SimpleMarkdown.Renderer.HTML.AST, for: SimpleMarkdown.Attribute.Link do
    def render(%{ input: input, option: url }), do: { :a, [href: url], SimpleMarkdown.Renderer.HTML.AST.render(input) }
end

defimpl SimpleMarkdown.Renderer.HTML.AST, for: SimpleMarkdown.Attribute.Image do
    def render(%{ input: input, option: url }), do: { :img, [src: url, alt: SimpleMarkdown.Renderer.HTML.render(input)], [] }
end

defimpl SimpleMarkdown.Renderer.HTML.AST, for: SimpleMarkdown.Attribute.Code do
    def render(%{ input: input }), do: { :code, [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
end
