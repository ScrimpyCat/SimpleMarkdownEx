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
        assert ~S(<foo a="bar &amp; baz">test</foo>) == { "foo", [{ "a", "bar &amp; baz" }], "test" } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<foo a="bar &amp; baz">test</foo>) == { "foo", [{ "a", "bar & baz" }], "test" } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html(encode_attributes: true) |> IO.chardata_to_string
        assert ~S(<foo a='bar "baz"'>test</foo>) == { "foo", [{ "a", "bar \"baz\"" }], "test" } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert ~S(<foo a="bar 'baz'">test</foo>) == { "foo", [{ "a", "bar 'baz'" }], "test" } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
        assert %SimpleMarkdown.Renderer.HTML.Utilities.UnencodableAttributeError{ value: "bar 'baz\"" } == catch_error ({ "foo", [{ "a", "bar 'baz\"" }], "test" } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html())
        assert ~S(<foo a="bar &apos;baz&quot;">test</foo>) == { "foo", [{ "a", "bar 'baz\"" }], "test" } |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html(encode_attributes: true) |> IO.chardata_to_string

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
        assert { "foo", [{ "a", "bar &amp; baz" }], "test" } == ~S(<foo a="bar &amp; baz">test</foo>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast
        assert { "foo", [{ "a", "bar & baz" }], "test" } == ~S(<foo a="bar &amp; baz">test</foo>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast(decode_attributes: true)
        assert { "foo", [{ "a", "bar" }], "test" } == ~S(<foo a=bar>test</foo>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast
        assert { "foo", [{ "a", "bar" }, { "baz", "" }], "test" } == ~S(<foo a=bar baz>test</foo>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast
        assert { "foo", [{ "a", "bar" }], "test" } == ~S(<foo a= bar>test</foo>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast
        assert { "foo", [{ "a", "bar" }, { "baz", "" }], "test" } == ~S(<foo a= bar baz>test</foo>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast
        assert { "foo", [{ "a", "bar" }, { "baz", "" }], "test" } == ~S(<foo a = bar baz>test</foo>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast
        assert { "foo", [{ "z", "" }, { "a", "bar" }, { "baz", "" }], "test" } == ~S(<foo z a = bar baz>test</foo>) |> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast

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

        s = """
        <iframe srcdoc='<svg width="1000%" height="1000%"
         viewBox="0.00 0.00 1046.14 260.00" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
        <g id="graph0" class="graph" transform="scale(1 1) rotate(0) translate(4 256)">
        <title>G</title>
        <polygon fill="#ffffff" stroke="transparent" points="-4,4 -4,-256 1042.1387,-256 1042.1387,4 -4,4"/>
        <!-- node_352 -->
        <g id="node1" class="node">
        <title>node_352</title>
        <ellipse fill="none" stroke="#6aff00" cx="41.5426" cy="-162" rx="41.5852" ry="18"/>
        <text text-anchor="middle" x="41.5426" y="-157.8" font-family="Times,serif" font-size="14.00" fill="#000000">graphvix</text>
        </g>
        <!-- node_352&#45;&gt;node_352 -->
        <g id="edge1" class="edge">
        <title>node_352&#45;&gt;node_352</title>
        <path fill="none" stroke="#6aff00" stroke-dasharray="5,2" d="M80.1986,-168.7397C91.9215,-168.5708 101.0852,-166.3242 101.0852,-162 101.0852,-159.0271 96.7539,-157.0362 90.2375,-156.0273"/>
        <polygon fill="#6aff00" stroke="#6aff00" points="90.4362,-152.5324 80.1986,-155.2603 89.9028,-159.5121 90.4362,-152.5324"/>
        </g>
        <!-- node_352&#45;&gt;node_352 -->
        <g id="edge13" class="edge">
        <title>node_352&#45;&gt;node_352</title>
        <path fill="none" stroke="#6aff00" d="M72.9994,-173.9765C96.0197,-178.0156 119.0852,-174.0234 119.0852,-162 119.0852,-151.7613 102.3591,-147.3465 83.178,-148.7557"/>
        <polygon fill="#6aff00" stroke="#6aff00" points="82.4901,-145.3143 72.9994,-150.0235 83.3553,-152.2606 82.4901,-145.3143"/>
        </g>
        <!-- node_354 -->
        <g id="node2" class="node">
        <title>node_354</title>
        <ellipse fill="none" stroke="#ff8000" cx="264.5426" cy="-234" rx="42.0697" ry="18"/>
        <text text-anchor="middle" x="264.5426" y="-229.8" font-family="Times,serif" font-size="14.00" fill="#000000">blueprint</text>
        </g>
        <!-- node_354&#45;&gt;node_352 -->
        <g id="edge3" class="edge">
        <title>node_354&#45;&gt;node_352</title>
        <path fill="none" stroke="#ff8000" d="M230.6737,-223.0647C191.5626,-210.437 127.1525,-189.6409 84.5387,-175.8822"/>
        <polygon fill="#ff8000" stroke="#ff8000" points="85.5912,-172.5441 74.9995,-172.8022 83.4404,-179.2055 85.5912,-172.5441"/>
        </g>
        <!-- node_354&#45;&gt;node_354 -->
        <g id="edge2" class="edge">
        <title>node_354&#45;&gt;node_354</title>
        <path fill="none" stroke="#ff8000" d="M293.8861,-246.8993C309.9052,-249.1982 324.5774,-244.8984 324.5774,-234 324.5774,-225.4856 315.6222,-220.9987 304.0658,-220.5393"/>
        <polygon fill="#ff8000" stroke="#ff8000" points="303.6782,-217.0553 293.8861,-221.1007 304.0637,-224.0446 303.6782,-217.0553"/>
        </g>
        <!-- node_357 -->
        <g id="node3" class="node">
        <title>node_357</title>
        <ellipse fill="none" stroke="#0009ff" cx="503.5426" cy="-162" rx="75.8639" ry="18"/>
        <text text-anchor="middle" x="503.5426" y="-157.8" font-family="Times,serif" font-size="14.00" fill="#000000">simple_markdown</text>
        </g>
        <!-- node_354&#45;&gt;node_357 -->
        <g id="edge4" class="edge">
        <title>node_354&#45;&gt;node_357</title>
        <path fill="none" stroke="#ff8000" d="M299.04,-223.6075C337.5787,-211.9975 400.5726,-193.0202 446.4761,-179.1916"/>
        <polygon fill="#ff8000" stroke="#ff8000" points="447.7228,-182.4714 456.2882,-176.2356 445.7036,-175.769 447.7228,-182.4714"/>
        </g>
        <!-- node_359 -->
        <g id="node4" class="node">
        <title>node_359</title>
        <ellipse fill="none" stroke="#0009ff" cx="264.5426" cy="-162" rx="127.5146" ry="18"/>
        <text text-anchor="middle" x="264.5426" y="-157.8" font-family="Times,serif" font-size="14.00" fill="#000000">simple_markdown_extension_cli</text>
        </g>
        <!-- node_354&#45;&gt;node_359 -->
        <g id="edge5" class="edge">
        <title>node_354&#45;&gt;node_359</title>
        <path fill="none" stroke="#ff8000" d="M264.5426,-215.8314C264.5426,-208.131 264.5426,-198.9743 264.5426,-190.4166"/>
        <polygon fill="#ff8000" stroke="#ff8000" points="268.0427,-190.4132 264.5426,-180.4133 261.0427,-190.4133 268.0427,-190.4132"/>
        </g>
        <!-- node_357&#45;&gt;node_357 -->
        <g id="edge24" class="edge">
        <title>node_357&#45;&gt;node_357</title>
        <path fill="none" stroke="#0009ff" d="M555.2279,-175.3146C577.935,-176.4929 597.4745,-172.0547 597.4745,-162 597.4745,-153.4771 583.4349,-148.9897 565.3273,-148.5379"/>
        <polygon fill="#0009ff" stroke="#0009ff" points="565.1757,-145.0397 555.2279,-148.6854 565.278,-152.0389 565.1757,-145.0397"/>
        </g>
        <!-- node_373 -->
        <g id="node9" class="node">
        <title>node_373</title>
        <ellipse fill="none" stroke="#33ff00" cx="381.5426" cy="-90" rx="56.07" ry="18"/>
        <text text-anchor="middle" x="381.5426" y="-85.8" font-family="Times,serif" font-size="14.00" fill="#000000">html_entities</text>
        </g>
        <!-- node_357&#45;&gt;node_373 -->
        <g id="edge22" class="edge">
        <title>node_357&#45;&gt;node_373</title>
        <path fill="none" stroke="#0009ff" d="M474.939,-145.1192C457.75,-134.9749 435.7261,-121.9772 417.3827,-111.1515"/>
        <polygon fill="#0009ff" stroke="#0009ff" points="419.1017,-108.102 408.7107,-106.0336 415.5439,-114.1304 419.1017,-108.102"/>
        </g>
        <!-- node_383 -->
        <g id="node12" class="node">
        <title>node_383</title>
        <ellipse fill="none" stroke="#00b7ff" cx="506.5426" cy="-90" rx="33.3752" ry="18"/>
        <text text-anchor="middle" x="506.5426" y="-85.8" font-family="Times,serif" font-size="14.00" fill="#000000">parsey</text>
        </g>
        <!-- node_357&#45;&gt;node_383 -->
        <g id="edge23" class="edge">
        <title>node_357&#45;&gt;node_383</title>
        <path fill="none" stroke="#0009ff" d="M504.2996,-143.8314C504.6205,-136.131 505.002,-126.9743 505.3586,-118.4166"/>
        <polygon fill="#0009ff" stroke="#0009ff" points="508.8559,-118.5503 505.7754,-108.4133 501.862,-118.2589 508.8559,-118.5503"/>
        </g>
        <!-- node_359&#45;&gt;node_359 -->
        <g id="edge26" class="edge">
        <title>node_359&#45;&gt;node_359</title>
        <path fill="none" stroke="#0009ff" d="M349.3706,-175.4405C382.4708,-176.0778 410.0499,-171.5977 410.0499,-162 410.0499,-153.4146 387.9815,-148.9241 359.6336,-148.5286"/>
        <polygon fill="#0009ff" stroke="#0009ff" points="359.36,-145.0294 349.3706,-148.5595 359.3812,-152.0293 359.36,-145.0294"/>
        </g>
        <!-- node_361 -->
        <g id="node5" class="node">
        <title>node_361</title>
        <ellipse fill="none" stroke="#f7ff00" cx="647.5426" cy="-90" rx="65.1958" ry="18"/>
        <text text-anchor="middle" x="647.5426" y="-85.8" font-family="Times,serif" font-size="14.00" fill="#000000">earmark_parser</text>
        </g>
        <!-- node_361&#45;&gt;node_361 -->
        <g id="edge6" class="edge">
        <title>node_361&#45;&gt;node_361</title>
        <path fill="none" stroke="#f7ff00" d="M691.9987,-103.233C712.6217,-104.6766 730.6404,-100.2656 730.6404,-90 730.6404,-81.4988 718.2833,-77.0126 702.3233,-76.5415"/>
        <polygon fill="#f7ff00" stroke="#f7ff00" points="701.9198,-73.0493 691.9987,-76.767 702.0727,-80.0477 701.9198,-73.0493"/>
        </g>
        <!-- node_363 -->
        <g id="node6" class="node">
        <title>node_363</title>
        <ellipse fill="none" stroke="#c8ff00" cx="651.5426" cy="-162" rx="35.7887" ry="18"/>
        <text text-anchor="middle" x="651.5426" y="-157.8" font-family="Times,serif" font-size="14.00" fill="#000000">ex_doc</text>
        </g>
        <!-- node_363&#45;&gt;node_361 -->
        <g id="edge7" class="edge">
        <title>node_363&#45;&gt;node_361</title>
        <path fill="none" stroke="#c8ff00" d="M650.5332,-143.8314C650.1054,-136.131 649.5967,-126.9743 649.1213,-118.4166"/>
        <polygon fill="#c8ff00" stroke="#c8ff00" points="652.6149,-118.2037 648.5655,-108.4133 645.6257,-118.592 652.6149,-118.2037"/>
        </g>
        <!-- node_363&#45;&gt;node_363 -->
        <g id="edge8" class="edge">
        <title>node_363&#45;&gt;node_363</title>
        <path fill="none" stroke="#c8ff00" d="M676.9301,-174.7584C691.5639,-177.3622 705.1866,-173.1094 705.1866,-162 705.1866,-153.5812 697.3634,-149.0999 687.2054,-148.5563"/>
        <polygon fill="#c8ff00" stroke="#c8ff00" points="686.675,-145.0838 676.9301,-149.2416 687.1409,-152.0683 686.675,-145.0838"/>
        </g>
        <!-- node_366 -->
        <g id="node7" class="node">
        <title>node_366</title>
        <ellipse fill="none" stroke="#00ffaa" cx="786.5426" cy="-90" rx="38.2024" ry="18"/>
        <text text-anchor="middle" x="786.5426" y="-85.8" font-family="Times,serif" font-size="14.00" fill="#000000">makeup</text>
        </g>
        <!-- node_363&#45;&gt;node_366 -->
        <g id="edge9" class="edge">
        <title>node_363&#45;&gt;node_366</title>
        <path fill="none" stroke="#c8ff00" d="M676.3037,-148.7941C697.5387,-137.4687 728.3605,-121.0305 752.018,-108.4131"/>
        <polygon fill="#c8ff00" stroke="#c8ff00" points="753.8447,-111.4056 761.0212,-103.6114 750.5506,-105.2291 753.8447,-111.4056"/>
        </g>
        <!-- node_366&#45;&gt;node_366 -->
        <g id="edge15" class="edge">
        <title>node_366&#45;&gt;node_366</title>
        <path fill="none" stroke="#00ffaa" d="M813.3833,-102.807C828.5767,-105.3081 842.6436,-101.0391 842.6436,-90 842.6436,-81.462 834.2287,-76.9738 823.3861,-76.5356"/>
        <polygon fill="#00ffaa" stroke="#00ffaa" points="823.1322,-73.0446 813.3833,-77.193 823.5914,-80.0295 823.1322,-73.0446"/>
        </g>
        <!-- node_376 -->
        <g id="node10" class="node">
        <title>node_376</title>
        <ellipse fill="none" stroke="#00fff2" cx="828.5426" cy="-18" rx="61.8476" ry="18"/>
        <text text-anchor="middle" x="828.5426" y="-13.8" font-family="Times,serif" font-size="14.00" fill="#000000">nimble_parsec</text>
        </g>
        <!-- node_366&#45;&gt;node_376 -->
        <g id="edge16" class="edge">
        <title>node_366&#45;&gt;node_376</title>
        <path fill="none" stroke="#00ffaa" d="M796.7096,-72.5708C801.5894,-64.2055 807.5438,-53.998 812.977,-44.6839"/>
        <polygon fill="#00ffaa" stroke="#00ffaa" points="816.1619,-46.1702 818.1774,-35.7689 810.1154,-42.6431 816.1619,-46.1702"/>
        </g>
        <!-- node_368 -->
        <g id="node8" class="node">
        <title>node_368</title>
        <ellipse fill="none" stroke="#c8ff00" cx="577.5426" cy="-234" rx="105.7819" ry="18"/>
        <text text-anchor="middle" x="577.5426" y="-229.8" font-family="Times,serif" font-size="14.00" fill="#000000">ex_doc_simple_markdown</text>
        </g>
        <!-- node_368&#45;&gt;node_357 -->
        <g id="edge12" class="edge">
        <title>node_368&#45;&gt;node_357</title>
        <path fill="none" stroke="#c8ff00" d="M559.2504,-216.2022C550.11,-207.3088 538.9025,-196.4042 528.9426,-186.7135"/>
        <polygon fill="#c8ff00" stroke="#c8ff00" points="531.2323,-184.0581 521.6243,-179.593 526.3508,-189.0752 531.2323,-184.0581"/>
        </g>
        <!-- node_368&#45;&gt;node_363 -->
        <g id="edge10" class="edge">
        <title>node_368&#45;&gt;node_363</title>
        <path fill="none" stroke="#c8ff00" d="M595.8347,-216.2022C605.4781,-206.8195 617.4222,-195.1982 627.7746,-185.1256"/>
        <polygon fill="#c8ff00" stroke="#c8ff00" points="630.2493,-187.6011 634.9758,-178.119 625.3678,-182.584 630.2493,-187.6011"/>
        </g>
        <!-- node_368&#45;&gt;node_368 -->
        <g id="edge11" class="edge">
        <title>node_368&#45;&gt;node_368</title>
        <path fill="none" stroke="#c8ff00" d="M648.5269,-247.4092C677.2584,-248.208 701.4335,-243.7383 701.4335,-234 701.4335,-225.441 682.7588,-220.9518 658.7292,-220.5324"/>
        <polygon fill="#c8ff00" stroke="#c8ff00" points="658.5066,-217.0335 648.5269,-220.5908 658.5468,-224.0334 658.5066,-217.0335"/>
        </g>
        <!-- node_373&#45;&gt;node_373 -->
        <g id="edge14" class="edge">
        <title>node_373&#45;&gt;node_373</title>
        <path fill="none" stroke="#33ff00" d="M420.1444,-103.1366C439.0507,-104.8554 455.8271,-100.4766 455.8271,-90 455.8271,-81.4878 444.7521,-77.001 430.458,-76.5397"/>
        <polygon fill="#33ff00" stroke="#33ff00" points="430.0297,-73.0513 420.1444,-76.8634 430.2493,-80.0478 430.0297,-73.0513"/>
        </g>
        <!-- node_376&#45;&gt;node_376 -->
        <g id="edge20" class="edge">
        <title>node_376&#45;&gt;node_376</title>
        <path fill="none" stroke="#00fff2" d="M870.7601,-31.2025C890.7024,-32.7368 908.2161,-28.3359 908.2161,-18 908.2161,-9.5213 896.4309,-5.0364 881.1875,-4.5453"/>
        <polygon fill="#00fff2" stroke="#00fff2" points="880.6725,-1.0566 870.7601,-4.7975 880.8418,-8.0546 880.6725,-1.0566"/>
        </g>
        <!-- node_378 -->
        <g id="node11" class="node">
        <title>node_378</title>
        <ellipse fill="none" stroke="#00ffaa" cx="829.5426" cy="-162" rx="61.3718" ry="18"/>
        <text text-anchor="middle" x="829.5426" y="-157.8" font-family="Times,serif" font-size="14.00" fill="#000000">makeup_elixir</text>
        </g>
        <!-- node_378&#45;&gt;node_366 -->
        <g id="edge17" class="edge">
        <title>node_378&#45;&gt;node_366</title>
        <path fill="none" stroke="#00ffaa" d="M818.9134,-144.2022C813.8247,-135.6817 807.6335,-125.315 802.0336,-115.9385"/>
        <polygon fill="#00ffaa" stroke="#00ffaa" points="805.0335,-114.1354 796.9011,-107.3446 799.0237,-117.7246 805.0335,-114.1354"/>
        </g>
        <!-- node_378&#45;&gt;node_376 -->
        <g id="edge19" class="edge">
        <title>node_378&#45;&gt;node_376</title>
        <path fill="none" stroke="#00ffaa" d="M838.9035,-144.0509C843.7228,-133.7943 849.0906,-120.5173 851.5426,-108 854.6183,-92.2984 854.7421,-87.6768 851.5426,-72 849.6972,-62.9581 846.2791,-53.5557 842.632,-45.1793"/>
        <polygon fill="#00ffaa" stroke="#00ffaa" points="845.7103,-43.498 838.3258,-35.9006 839.3608,-46.4448 845.7103,-43.498"/>
        </g>
        <!-- node_378&#45;&gt;node_378 -->
        <g id="edge18" class="edge">
        <title>node_378&#45;&gt;node_378</title>
        <path fill="none" stroke="#00ffaa" d="M871.5015,-175.2025C891.3218,-176.7368 908.7282,-172.3359 908.7282,-162 908.7282,-153.5213 897.0152,-149.0364 881.8651,-148.5453"/>
        <polygon fill="#00ffaa" stroke="#00ffaa" points="881.4134,-145.0552 871.5015,-148.7975 881.5838,-152.0531 881.4134,-145.0552"/>
        </g>
        <!-- node_383&#45;&gt;node_383 -->
        <g id="edge21" class="edge">
        <title>node_383&#45;&gt;node_383</title>
        <path fill="none" stroke="#00b7ff" d="M530.2366,-102.6563C544.3997,-105.4688 557.7296,-101.25 557.7296,-90 557.7296,-81.5625 550.2315,-77.0801 540.5074,-76.5527"/>
        <polygon fill="#00b7ff" stroke="#00b7ff" points="539.9383,-73.0861 530.2366,-77.3438 540.4759,-80.0654 539.9383,-73.0861"/>
        </g>
        <!-- node_388 -->
        <g id="node13" class="node">
        <title>node_388</title>
        <ellipse fill="none" stroke="#0009ff" cx="869.5426" cy="-234" rx="150.6924" ry="18"/>
        <text text-anchor="middle" x="869.5426" y="-229.8" font-family="Times,serif" font-size="14.00" fill="#000000">simple_markdown_extension_blueprint</text>
        </g>
        <!-- node_388&#45;&gt;node_388 -->
        <g id="edge25" class="edge">
        <title>node_388&#45;&gt;node_388</title>
        <path fill="none" stroke="#0009ff" d="M969.5126,-247.4652C1007.1131,-247.9454 1038.1387,-243.457 1038.1387,-234 1038.1387,-225.4296 1012.6577,-220.9398 979.8943,-220.5308"/>
        <polygon fill="#0009ff" stroke="#0009ff" points="979.5112,-217.0308 969.5126,-220.5348 979.514,-224.0308 979.5112,-217.0308"/>
        </g>
        </g>
        </svg>' width="300px" height="150px"></iframe>
        """

        ast = SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast(s)
        assert s == ast |> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html |> IO.chardata_to_string
    end
end
