defmodule SimpleMarkdownRendererHTMLUtilitiesTest do
    use ExUnit.Case
    doctest SimpleMarkdown.Renderer.HTML.Utilities

    test "ast_to_html" do
        assert ~S(<foo></foo>) == { :foo, [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<foo>) == { :foo, [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html(void_elements: [:foo]) |> IO.chardata_to_string
        assert ~S(<foo>) == { :foo, [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html(void_elements: ["foo"]) |> IO.chardata_to_string
        assert ~S(<foo>) == { "foo", [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html(void_elements: [:foo]) |> IO.chardata_to_string
        assert ~S(<foo />) == { :foo, [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html(void_elements: [:foo], format: { :xhtml, 1 }) |> IO.chardata_to_string
        assert ~S(<area>) == { :area, [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<base>) == { :base, [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<br>) == { :br, [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<col>) == { :col, [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<embed>) == { :embed, [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<hr>) == { :hr, [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<img>) == { :img, [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<input>) == { :input, [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<keygen>) == { :keygen, [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<link>) == { :link, [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<meta>) == { :meta, [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<param>) == { :param, [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<source>) == { :source, [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<track>) == { :track, [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<wbr>) == { :wbr, [], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string

        assert ~S(<foo id></foo>) == { :foo, [{ "id", "" }], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<foo id></foo>) == { :foo, [id: ""], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<foo id="name"></foo>) == { :foo, [id: "name"], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<foo id="name"></foo>) == { :foo, [id: ["na", "me"]], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<foo id class></foo>) == { :foo, [id: "", class: ""], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<foo id="a" class></foo>) == { :foo, [id: "a", class: ""], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<foo id class="b"></foo>) == { :foo, [id: "", class: "b"], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<foo id="a" class="b"></foo>) == { :foo, [id: "a", class: "b"], [] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string

        assert ~S(<foo>test</foo>) == { :foo, [], "test" } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<foo>test</foo>) == { :foo, [], ["test"] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<foo>test</foo>) == { :foo, [], ["te", "st"] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<foo>test</foo>) == { "foo", [], "test" } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string

        assert ~S(<foo><bar>1</bar></foo>) == { :foo, [], { :bar, [], ["1"] } } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<foo><bar>1</bar><bar>2</bar></foo>) == { :foo, [], [{ :bar, [], ["1"] }, { :bar, [], ["2"] }] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<foo>0<bar>1</bar><bar>2</bar>3</foo>) == { :foo, [], ["0", { :bar, [], ["1"] }, { :bar, [], ["2"] }, "3"] } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string

        assert ~S(<foo>1 &amp; 2</foo>) == { :foo, [], "1 & 2" } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<script>1 & 2</script>) == { :script, [], "1 & 2" } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<foo>1 & 2</foo>) == { :foo, [], "1 & 2" } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html(raw_text_elements: [:foo]) |> IO.chardata_to_string
        assert ~S(<foo>1 & 2</foo>) == { :foo, [], "1 & 2" } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html(raw_text_elements: ["foo"]) |> IO.chardata_to_string

        assert ~S(<p>test</p>) == [{ "!--", [], " <p>ignore</p> " }, { "p", [], "test" }] |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html() |> IO.chardata_to_string
        assert ~S(<!-- <p>ignore</p> --><p>test</p>) == [{ "!--", [], " <p>ignore</p> " }, { "p", [], "test" }] |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html(include_chardata: true) |> IO.chardata_to_string
        assert ~S(<!--> &lt;p&gt;ignore&lt;/p&gt; </!--><p>test</p>) == [{ "!--", [], " <p>ignore</p> " }, { "p", [], "test" }] |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html(chardata: [], include_chardata: true) |> IO.chardata_to_string
        assert ~S(<![CDATA[foo]]>) == { "![CDATA[", [], "foo" } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html(include_chardata: true) |> IO.chardata_to_string
        assert ~S(<!DOCTYPE html>) == { "!DOCTYPE", [], " html" } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html(include_chardata: true) |> IO.chardata_to_string
        assert ~S(<?xml version="1.0" encoding="UTF-8" ?>) == { "?", [], "xml version=\"1.0\" encoding=\"UTF-8\" " } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html(include_chardata: true) |> IO.chardata_to_string
        assert ~S(<foo <p>ignore</p> >) == { "foo", [], " <p>ignore</p> " } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html(chardata: [{ "foo", "" }], include_chardata: true) |> IO.chardata_to_string
        assert ~S(<foo <p>ignore</p> bar>) == { "foo", [], " <p>ignore</p> " } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html(chardata: [{ "foo", "bar" }], include_chardata: true) |> IO.chardata_to_string
    end

    test "html_to_ast" do
        assert { "hr", [], [] } == ~S(<hr>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast
        assert { "hr", [], [] } == ~S(<hr />) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast
        assert [{ "hr", [], [] }, { "p", [], "test" }] == ~S(<hr><p>test</p>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast
        assert [{ "hr", [], [] }, { "p", [], "test" }] == ~S(<hr /><p>test</p>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast
        assert { "foo", [], { "p", [], "test" } } == ~S(<foo><p>test</p>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast
        assert [{ "foo", [], [] }, { "p", [], "test" }] == ~S(<foo /><p>test</p>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast
        assert [{ "foo", [], [] }, { "p", [], "test" }] == ~S(<foo><p>test</p>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast(void_elements: [:foo])
        assert [{ "foo", [], [] }, { "p", [], "test" }] == ~S(<foo><p>test</p>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast(void_elements: ["foo"])
        assert { "foo", [], "1 & 2" } == ~S(<foo>1 &amp; 2</foo>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast
        assert { "foo", [], "1 &amp; 2" } == ~S(<foo>1 &amp; 2</foo>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast(raw_text_elements: [:foo])
        assert { "foo", [], "1 &amp; 2" } == ~S(<foo>1 &amp; 2</foo>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast(raw_text_elements: ["foo"])
        assert { "foo", [{ "a", "" }], "test" } == ~S(<foo a>test</foo>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast
        assert { "foo", [{ "a", "bar" }], "test" } == ~S(<foo a="bar">test</foo>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast
        assert { "foo", [{ "a", "bar & baz" }], "test" } == ~S(<foo a="bar &amp; baz">test</foo>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast

        assert { "p", [], "test" } == ~S(<!-- <p>ignore</p> --><p>test</p>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast
        assert [{ "!--", [], " <p>ignore</p> " }, { "p", [], "test" }] == ~S(<!-- <p>ignore</p> --><p>test</p>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast(include_chardata: true)
        assert { "!--", [], " <p>ignore</p> " } == ~S(<!-- <p>ignore</p> ) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast(include_chardata: true)
        assert { "!--", [], " <p>ignore</p> --" } == ~S(<!-- <p>ignore</p> --) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast(include_chardata: true)
        assert { "!--", [], " &lt;p&gt;ignore&lt;/p&gt; " } == ~S(<!-- &lt;p&gt;ignore&lt;/p&gt; ) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast(include_chardata: true)

        assert [{ "!--", [], " <p>ignore</p> " }, { "p", [], "test" }] == ~S(<!--> &lt;p&gt;ignore&lt;/p&gt; </!--><p>test</p>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast(chardata: [], include_chardata: true)
        assert { "![CDATA[", [], "foo" } == ~S(<![CDATA[foo]]>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast(include_chardata: true)
        assert { "!DOCTYPE", [], " html" } == ~S(<!DOCTYPE html>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast(include_chardata: true)
        assert { "?", [], "xml version=\"1.0\" encoding=\"UTF-8\" " } == ~S(<?xml version="1.0" encoding="UTF-8" ?>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast(include_chardata: true)
        assert [{ "foo", [], " <p" }, "ignore"] == ~S(<foo <p>ignore</p> >) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast(chardata: [{ "foo", "" }], include_chardata: true)
        assert { "foo", [], " <p>ignore</p> " } == ~S(<foo <p>ignore</p> bar>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast(chardata: [{ "foo", "bar" }], include_chardata: true)
    end

    test "complicated blocks" do
        s = """
        <svg class="bob" font-family="arial" font-size="14" height="208" width="232" xmlns="http://www.w3.org/2000/svg">
        <defs>
        <marker id="triangle" markerHeight="10" markerUnits="strokeWidth" markerWidth="10" orient="auto" refX="15" refY="10" viewBox="0 0 50 20">
        <path d="M 0 0 L 30 10 L 0 20 z"></path>
        </marker>
        </defs>
        <style>

            line, path {
              stroke: black;
              stroke-width: 2;
              stroke-opacity: 1;
              fill-opacity: 1;
              stroke-linecap: round;
              stroke-linejoin: miter;
            }
            circle {
              stroke: black;
              stroke-width: 2;
              stroke-opacity: 1;
              fill-opacity: 1;
              stroke-linecap: round;
              stroke-linejoin: miter;
            }
            circle.solid {
              fill:black;
            }
            circle.open {
              fill:transparent;
            }
            tspan.head{
                fill: none;
                stroke: none;
            }

        </style>
        <path d=" M 4 8 L 8 8 M 4 8 L 4 16 M 8 8 L 16 8 M 8 8 L 16 8 L 24 8 M 16 8 L 24 8 L 32 8 M 24 8 L 32 8 L 40 8 M 32 8 L 40 8 L 48 8 M 40 8 L 48 8 L 56 8 M 48 8 L 56 8 L 64 8 M 56 8 L 64 8 L 72 8 M 64 8 L 72 8 L 80 8 M 72 8 L 80 8 L 88 8 M 80 8 L 88 8 L 96 8 M 88 8 L 96 8 L 104 8 M 96 8 L 104 8 L 112 8 M 104 8 L 112 8 M 116 8 L 112 8 M 116 8 L 120 8 M 116 8 L 116 16 M 120 8 L 128 8 M 120 8 L 128 8 L 136 8 M 128 8 L 136 8 L 144 8 M 136 8 L 144 8 L 152 8 M 144 8 L 152 8 L 160 8 M 152 8 L 160 8 L 168 8 M 160 8 L 168 8 L 176 8 M 168 8 L 176 8 L 184 8 M 176 8 L 184 8 L 192 8 M 184 8 L 192 8 L 200 8 M 192 8 L 200 8 L 208 8 M 200 8 L 208 8 L 216 8 M 208 8 L 216 8 L 224 8 M 216 8 L 224 8 M 228 8 L 224 8 M 228 8 L 228 16 M 4 16 L 4 32 M 4 16 L 4 32 M 116 16 L 116 32 M 116 16 L 116 32 M 228 16 L 228 32 M 228 16 L 228 32 M 4 32 L 4 48 M 4 32 L 4 48 M 116 32 L 116 48 M 116 32 L 116 48 M 228 32 L 228 48 M 228 32 L 228 48 M 4 48 L 4 64 M 4 48 L 4 64 M 116 48 L 116 64 M 116 48 L 116 64 M 228 48 L 228 64 M 228 48 L 228 64 M 4 64 L 4 80 M 4 64 L 4 80 M 116 64 L 116 80 M 116 64 L 116 80 M 228 64 L 228 80 M 228 64 L 228 80 M 4 80 L 4 96 M 4 80 L 4 96 M 116 80 L 116 96 M 116 80 L 116 96 M 228 80 L 228 96 M 228 80 L 228 96 M 4 104 L 4 96 M 4 104 L 8 104 M 4 104 L 4 112 M 8 104 L 16 104 M 8 104 L 16 104 L 24 104 M 16 104 L 24 104 L 32 104 M 24 104 L 32 104 L 40 104 M 32 104 L 40 104 L 48 104 M 40 104 L 48 104 L 56 104 M 48 104 L 56 104 L 64 104 M 56 104 L 64 104 L 72 104 M 64 104 L 72 104 L 80 104 M 72 104 L 80 104 L 88 104 M 80 104 L 88 104 L 96 104 M 88 104 L 96 104 L 104 104 M 96 104 L 104 104 L 112 104 M 104 104 L 112 104 M 116 104 L 116 96 M 116 104 L 112 104 M 116 104 L 120 104 M 116 104 L 116 112 M 120 104 L 128 104 M 120 104 L 128 104 L 136 104 M 128 104 L 136 104 L 144 104 M 136 104 L 144 104 L 152 104 M 144 104 L 152 104 L 160 104 M 152 104 L 160 104 L 168 104 M 160 104 L 168 104 L 176 104 M 168 104 L 176 104 L 184 104 M 176 104 L 184 104 L 192 104 M 184 104 L 192 104 L 200 104 M 192 104 L 200 104 L 208 104 M 200 104 L 208 104 L 216 104 M 208 104 L 216 104 L 224 104 M 216 104 L 224 104 M 228 104 L 228 96 M 228 104 L 224 104 M 228 104 L 228 112 M 4 112 L 4 128 M 4 112 L 4 128 M 116 112 L 116 128 M 116 112 L 116 128 M 228 112 L 228 128 M 228 112 L 228 128 M 4 128 L 4 144 M 4 128 L 4 144 M 116 128 L 116 144 M 116 128 L 116 144 M 228 128 L 228 144 M 228 128 L 228 144 M 4 144 L 4 160 M 4 144 L 4 160 M 116 144 L 116 160 M 116 144 L 116 160 M 228 144 L 228 160 M 228 144 L 228 160 M 4 160 L 4 176 M 4 160 L 4 176 M 116 160 L 116 176 M 116 160 L 116 176 M 228 160 L 228 176 M 228 160 L 228 176 M 4 176 L 4 192 M 4 176 L 4 192 M 116 176 L 116 192 M 116 176 L 116 192 M 228 176 L 228 192 M 228 176 L 228 192 M 4 200 L 4 192 M 4 200 L 8 200 L 16 200 M 8 200 L 16 200 L 24 200 M 16 200 L 24 200 L 32 200 M 24 200 L 32 200 L 40 200 M 32 200 L 40 200 L 48 200 M 40 200 L 48 200 L 56 200 M 48 200 L 56 200 L 64 200 M 56 200 L 64 200 L 72 200 M 64 200 L 72 200 L 80 200 M 72 200 L 80 200 L 88 200 M 80 200 L 88 200 L 96 200 M 88 200 L 96 200 L 104 200 M 96 200 L 104 200 L 112 200 M 104 200 L 112 200 M 116 200 L 116 192 M 116 200 L 112 200 M 116 200 L 120 200 L 128 200 M 120 200 L 128 200 L 136 200 M 128 200 L 136 200 L 144 200 M 136 200 L 144 200 L 152 200 M 144 200 L 152 200 L 160 200 M 152 200 L 160 200 L 168 200 M 160 200 L 168 200 L 176 200 M 168 200 L 176 200 L 184 200 M 176 200 L 184 200 L 192 200 M 184 200 L 192 200 L 200 200 M 192 200 L 200 200 L 208 200 M 200 200 L 208 200 L 216 200 M 208 200 L 216 200 L 224 200 M 216 200 L 224 200 M 228 200 L 228 192 M 228 200 L 224 200" fill="none"></path>
        <path d fill="none" stroke-dasharray="3 3"></path>
        <text x="57" y="60">
        2
        </text>
        <text x="169" y="60">
        3
        </text>
        <text x="57" y="156">
        0
        </text>
        <text x="169" y="156">
        1
        </text>
        </svg>
        """

        ast = SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast(s)
        assert s == ast |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string

        s = """
        <div>
        <script>
        let a = "</div>";
        if (a == '&amp;</script' && a == '<script>') console.log(a);
        </script>
        </div>
        """

        ast = SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast(s)
        assert s == ast |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
    end
end
