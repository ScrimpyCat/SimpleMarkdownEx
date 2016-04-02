defmodule SimpleMarkdownTest do
    use ExUnit.Case
    doctest SimpleMarkdown

    test "converting AST to struct" do
        assert ["hello"] == SimpleMarkdown.ast_to_structs(["hello"])
        assert [%{ __struct__: SimpleMarkdown.Attribute.Test, input: ["hello"] }] == SimpleMarkdown.ast_to_structs([{ :test, ["hello"] }])
        assert [%{ __struct__: SimpleMarkdown.Attribute.Test, input: ["hello"], option: 1 }] == SimpleMarkdown.ast_to_structs([{ :test, ["hello"], 1 }])
        assert [%{ __struct__: SimpleMarkdown.Attribute.Test, input: ["hello"] }, "bye"] == SimpleMarkdown.ast_to_structs([{ :test, ["hello"] }, "bye"])
        assert [%{ __struct__: SimpleMarkdown.Attribute.Test, input: [%{ __struct__: SimpleMarkdown.Attribute.Hello, input: [] }] }] == SimpleMarkdown.ast_to_structs([{ :test, [{ :hello, [] }] }])
    end

    test "conversion function" do
        assert "<h1>Test</h1>" == SimpleMarkdown.convert("#Test")
        assert "hello" == SimpleMarkdown.convert("#Test", render: fn [%{ __struct__: SimpleMarkdown.Attribute.Header, input: ["Test"], option: 1 }] -> "hello" end)
        assert "hello" == SimpleMarkdown.convert("hello", render: fn [%{ input: [word] }] -> word end, parser: [any: ~r/\A.*/])
    end
end
