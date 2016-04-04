defmodule SimpleMarkdownRendererHTMLTest do
    use ExUnit.Case

    test "rendering line break" do
        assert "<br>" == [{ :line_break, [] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
    end

    test "rendering header" do
        assert "<h1>test</h1>" == [{ :header, ["test"], 1 }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
        assert "<h2>test</h2>" == [{ :header, ["test"], 2 }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
        assert "<h3>test</h3>" == [{ :header, ["test"], 3 }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
        assert "<h4>test</h4>" == [{ :header, ["test"], 4 }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
        assert "<h5>test</h5>" == [{ :header, ["test"], 5 }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
        assert "<h6>test</h6>" == [{ :header, ["test"], 6 }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
        assert "<h1>test</h1>" == [{ :header, ["test"], 1 }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
        assert "<h2>test</h2>" == [{ :header, ["test"], 2 }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
    end

    test "rendering emphasis" do
        assert "<em>test</em>" == [{ :emphasis, ["test"], :regular }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
        assert "<strong>test</strong>" == [{ :emphasis, ["test"], :strong }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
    end

    test "rendering horizontal rule" do
        assert "<hr>" == [{ :horizontal_rule, [] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
    end

    test "rendering table" do
        assert "<table><thead><tr><th>One</th><th>Two</th><th>Three</th><th>Four</th></tr></thead><tbody><tr><td>1</td><td style=\"text-align: center;\">2</td><td style=\"text-align: right;\">3</td><td style=\"text-align: left;\">4</td></tr><tr><td>11</td><td style=\"text-align: center;\">22</td><td style=\"text-align: right;\">33</td><td style=\"text-align: left;\">44</td></tr></tbody></table>" == [{ :table, [row: ["1", "2", "3", "4"], row: ["11", "22", "33", "44"]], [{ "One", :default }, { "Two", :center }, { "Three", :right }, { "Four", :left }] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
        assert "<table><tbody><tr><td>1</td><td style=\"text-align: center;\">2</td><td style=\"text-align: right;\">3</td><td style=\"text-align: left;\">4</td></tr><tr><td>11</td><td style=\"text-align: center;\">22</td><td style=\"text-align: right;\">33</td><td style=\"text-align: left;\">44</td></tr></tbody></table>" == [{ :table, [row: ["1", "2", "3", "4"], row: ["11", "22", "33", "44"]], [:default, :center, :right, :left] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
    end

    test "rendering list" do
        assert "<ul><li>a</li><li>b</li></ul>" == [{ :list, [{ :item, ["a"] }, { :item, ["b"] }], :unordered }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
        assert "<ol><li>a</li><li>b</li></ol>" == [{ :list, [{ :item, ["a"] }, { :item, ["b"] }], :ordered }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
    end

    test "rendering preformatted code" do
        assert "<pre><code>test</code></pre>" == [{ :preformatted_code, ["test"] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
        assert "<pre><code>&lt;test&gt;</code></pre>" == [{ :preformatted_code, ["<test>"] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
    end

    test "rendering paragraph" do
        assert "<p>test</p>" == [{ :paragraph, ["test"] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
    end

    test "rendering blockquote" do
        assert "<blockquote>test</blockquote>" == [{ :blockquote, ["test"] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
    end

    test "rendering link" do
        assert "<a href=\"example.com\">test</a>" == [{ :link, ["test"], "example.com" }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
    end

    test "rendering image" do
        assert "<img src=\"example.com/image.jpg\" alt=\"test\">" == [{ :image, ["test"], "example.com/image.jpg" }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
    end

    test "rendering code" do
        assert "<code>test</code>" == [{ :code, ["test"] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
        assert "<code>&lt;test&gt;</code>" == [{ :code, ["<test>"] }] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
    end

    test "rendering examples" do
        assert "<h1>Heading</h1><h2>Sub-heading</h2><h3>Another deeper heading</h3><p>Paragraphs are separatedby a blank line.</p><p>Two spaces at the end of a line leave a<br>line break.</p><p>Text attributes <em>italic</em>, <strong>bold</strong>, <code>monospace</code>.</p><p>Bullet list:</p><ul><li>apples</li><li>oranges</li><li>pears</li></ul><p>Numbered list:</p><ol><li>apples</li><li>oranges</li><li>pears</li></ol><p>A <a href=\"http://example.com\">link</a>.</p>" == [
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
        ] |> SimpleMarkdown.ast_to_structs |> SimpleMarkdown.Renderer.HTML.render
    end
end
