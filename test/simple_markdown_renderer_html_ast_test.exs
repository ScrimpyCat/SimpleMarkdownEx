defmodule SimpleMarkdownRendererHTMLASTTest do
    use ExUnit.Case

    test "rendering line break" do
        assert [{ :br, [], [] }] == [{ :line_break, [] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
    end

    test "rendering header" do
        assert [{ :h1, [], ["test"] }] == [{ :header, ["test"], 1 }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
        assert [{ :h2, [], ["test"] }] == [{ :header, ["test"], 2 }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
        assert [{ :h3, [], ["test"] }] == [{ :header, ["test"], 3 }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
        assert [{ :h4, [], ["test"] }] == [{ :header, ["test"], 4 }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
        assert [{ :h5, [], ["test"] }] == [{ :header, ["test"], 5 }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
        assert [{ :h6, [], ["test"] }] == [{ :header, ["test"], 6 }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
    end

    test "rendering emphasis" do
        assert [{ :em, [], ["test"] }] == [{ :emphasis, ["test"], :regular }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
        assert [{ :strong, [], ["test"] }] == [{ :emphasis, ["test"], :strong }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
    end

    test "rendering horizontal rule" do
        assert [{ :hr, [], [] }] == [{ :horizontal_rule, [] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
    end

    test "rendering table" do
        assert [
            {
                :table,
                [],
                [
                    {
                        :thead,
                        [],
                        {
                            :tr,
                            [],
                            [
                                { :th, [], "One" },
                                { :th, [], "Two" },
                                { :th, [], "Three" },
                                { :th, [], "Four" }
                            ]
                        }
                    },
                    {
                        :tbody,
                        [],
                        [
                            {
                                :tr,
                                [],
                                [
                                    { :td, [], "1" },
                                    { :td, [style: ["text-align: ", "center", ";"]], "2" },
                                    { :td, [style: ["text-align: ", "right", ";"]], "3" },
                                    { :td, [style: ["text-align: ", "left", ";"]], "4" }
                                ]
                            },
                            {
                                :tr,
                                [],
                                [
                                    { :td, [], "11" },
                                    { :td, [style: ["text-align: ", "center", ";"]], "22" },
                                    { :td, [style: ["text-align: ", "right", ";"]], "33" },
                                    { :td, [style: ["text-align: ", "left", ";"]], "44" }
                                ]
                            }
                        ]
                    }
                ]
            }
        ] == [{ :table, [row: ["1", "2", "3", "4"], row: ["11", "22", "33", "44"]], [{ "One", :default }, { "Two", :center }, { "Three", :right }, { "Four", :left }] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
        assert [
            {
                :table,
                [],
                [
                    {
                        :tbody,
                        [],
                        [
                            {
                                :tr,
                                [],
                                [
                                    { :td, [], "1" },
                                    { :td, [style: ["text-align: ", "center", ";"]], "2" },
                                    { :td, [style: ["text-align: ", "right", ";"]], "3" },
                                    { :td, [style: ["text-align: ", "left", ";"]], "4" }
                                ]
                            },
                            {
                                :tr,
                                [],
                                [
                                    { :td, [], "11" },
                                    { :td, [style: ["text-align: ", "center", ";"]], "22" },
                                    { :td, [style: ["text-align: ", "right", ";"]], "33" },
                                    { :td, [style: ["text-align: ", "left", ";"]], "44" }
                                ]
                            }
                        ]
                    }
                ]
            }
        ] == [{ :table, [row: ["1", "2", "3", "4"], row: ["11", "22", "33", "44"]], [:default, :center, :right, :left] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
    end

    test "rendering task list" do
        assert [
            {
                :ul,
                [],
                [
                    { :li, [], [{ :input, [type: :checkbox, disabled: ""], [] }, ["a"]] },
                    { :li, [], [{ :input, [type: :checkbox, checked: "", disabled: ""], [] }, ["b"]] },
                ]
            }
        ] == [{ :task_list, [{ :task, ["a"], :deselected }, { :task, ["b"], :selected }] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
    end

    test "rendering list" do
        assert [{ :ul, [], [{ :li, [], ["a"] }, { :li, [], ["b"] }] }] == [{ :list, [{ :item, ["a"] }, { :item, ["b"] }], :unordered }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
        assert [{ :ol, [], [{ :li, [], ["a"] }, { :li, [], ["b"] }] }] == [{ :list, [{ :item, ["a"] }, { :item, ["b"] }], :ordered }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
    end

    defimpl SimpleMarkdown.Renderer.HTML, for: SimpleMarkdown.Attribute.PreformattedCode.TestOther do
        def render(%{ option: _ }), do: ""
        def render(%{ input: input }), do: "<pre><code class=\"test_other\">#{SimpleMarkdown.Renderer.HTML.render(input) |> HtmlEntities.encode}</code></pre>"
    end

    defimpl SimpleMarkdown.Renderer.HTML.AST, for: SimpleMarkdown.Attribute.PreformattedCode.Test do
        def render(%{ option: _ }), do: { :pre, [], { :code, [], [] } }
        def render(%{ input: input }), do: { :pre, [], { :code, [class: :test], SimpleMarkdown.Renderer.HTML.AST.render(input) } }
    end

    test "rendering preformatted code" do
        assert [{ :pre, [], { :code, [], ["test"] } }] == [{ :preformatted_code, ["test"] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
        assert [{ :pre, [], { :code, [], ["<test>"] } }] == [{ :preformatted_code, ["<test>"] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
        assert [{ :pre, [], { :code, [], ["test"] } }] == [{ :preformatted_code, ["test"], :syntax }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
        assert [{ :pre, [], { :code, [class: :test], ["test"] } }] == [{ :preformatted_code, ["test"], :test }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
        assert [{ "pre", [], { "code", [{ "class", "test_other" }], "test" } }] == [{ :preformatted_code, ["test"], :test_other }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
    end

    test "rendering paragraph" do
        assert [{ :p, [], ["test"] }] == [{ :paragraph, ["test"] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
    end

    test "rendering blockquote" do
        assert [{ :blockquote, [], ["test"] }] == [{ :blockquote, ["test"] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
    end

    test "rendering link" do
        assert [{ :a, [href: "example.com"], ["test"] }] == [{ :link, ["test"], "example.com" }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
    end

    test "rendering image" do
        assert [{ :img, [src: "example.com/image.jpg", alt: "test"], [] }] == [{ :image, ["test"], "example.com/image.jpg" }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
    end

    test "rendering code" do
        assert [{ :code, [], ["test"] }] == [{ :code, ["test"] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
        assert [{ :code, [], ["<test>"] }] == [{ :code, ["<test>"] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
    end

    test "rendering examples" do
        assert [
            { :h1, [], ["Heading"] },
            { :h2, [], ["Sub-heading"] },
            { :h3, [], ["Another deeper heading"] },
            { :p, [], ["Paragraphs are separated", "by a blank line."] },
            { :p, [], ["Two spaces at the end of a line leave a", { :br, [], [] }, "line break."] },
            { :p, [], ["Text attributes ", { :em, [], ["italic"] }, ", ", { :strong, [], ["bold"] }, ", ", { :code, [], ["monospace"] }, "."] },
            { :p, [], ["Bullet list:"] },
            { :ul, [], [{ :li, [], ["apples"] }, { :li, [], ["oranges"] }, { :li, [], ["pears"] }] },
            { :p, [], ["Numbered list:"] },
            { :ol, [], [{ :li, [], ["apples"] }, { :li, [], ["oranges"] }, { :li, [], ["pears"] }] },
            { :p, [], ["A ", { :a, [href: "http://example.com"], ["link"] }, "."] }
        ] == [
            { :header, ["Heading"], 1 },
            { :header, ["Sub-heading"], 2 },
            { :header, ["Another deeper heading"], 3 },
            { :paragraph, ["Paragraphs are separated", "by a blank line."] },
            { :paragraph, ["Two spaces at the end of a line leave a", { :line_break, [] }, "line break."] },
            { :paragraph, ["Text attributes ", { :emphasis, ["italic"], :regular }, ", ", { :emphasis, ["bold"], :strong }, ", ", { :code, ["monospace"] }, "."] },
            { :paragraph, ["Bullet list:"] },
            { :list, [item: ["apples"], item: ["oranges"], item: ["pears"]], :unordered },
            { :paragraph, ["Numbered list:"] },
            { :list, [item: ["apples"], item: ["oranges"], item: ["pears"]], :ordered },
            { :paragraph, ["A ", { :link, ["link"], "http://example.com" }, "."] }
        ] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
    end

    test "rendering stream examples" do
        assert [{ :h1, [], ["foo"] }, { :h2, [], ["foo"] }, { :h3, [], ["foo"] }] == Stream.iterate(1, &(&1 + 1)) |> Stream.map(&({ :header, ["foo"], &1 })) |> Stream.take(3) |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
    end

    defimpl SimpleMarkdown.Renderer.HTML, for: SimpleMarkdown.Attribute.Foo do
        def render(%{ input: input }), do: "<foo>#{SimpleMarkdown.Renderer.HTML.AST.render(input)}</foo>"
    end

    defimpl SimpleMarkdown.Renderer.HTML.AST, for: SimpleMarkdown.Attribute.FooAst do
        def render(%{ input: input }), do: { :foo_ast, [], SimpleMarkdown.Renderer.HTML.AST.render(input) }
    end

    test "rendering custom ast attribute" do
        assert [{ :foo_ast, [], ["test"] }] == [{ :foo_ast, ["test"] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
    end

    test "rendering fallback custom html attribute" do
        assert [{ "foo", [], "test" }] == [{ :foo, ["test"] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render
        assert %Protocol.UndefinedError{ protocol: SimpleMarkdown.Renderer.HTML.AST } = catch_error([{ :foo_unimplemented, ["test"] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.AST.render)
    end
end
