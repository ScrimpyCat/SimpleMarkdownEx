defmodule SimpleMarkdown.Renderer.HTML.Utilities do
    @type ast :: { tag :: String.Chars.t, attr :: [{ String.Chars.t, String.Chars.t }], ast } | list | binary

    @spec ast_to_html(ast) :: IO.chardata
    def ast_to_html({ tag, attrs, nodes }) do
        tag = to_string(tag)
        [
            "<",
            tag,
            Enum.map(attrs, fn
                { key, "" } -> [" ", to_string(key)]
                { key, value } -> [" ", to_string(key), "=\"", to_string(value) |> HtmlEntities.encode, "\""]
            end),
            ">",
            ast_to_html(nodes),
            "</",
            tag,
            ">"
        ]
    end
    def ast_to_html(list) when is_list(list), do: Enum.map(list, &ast_to_html/1)
    def ast_to_html(string), do: HtmlEntities.encode(string)

    @spec html_to_ast(IO.chardata) :: ast
    def html_to_ast(html)  do
        { nodes, _ } = to_ast_nodes(IO.chardata_to_string(html))
        nodes
    end

    @spaces [?\s, ?\t, ?\n, ?\f, ?\r]
    @quotes [?", ?']

    defp to_ast_nodes(html, nodes \\ [], body \\ "")
    defp to_ast_nodes("",  nodes, body), do: { Enum.reverse([HtmlEntities.decode(body)|nodes]), "" }
    defp to_ast_nodes("</" <> html,  nodes, body), do: { Enum.reverse([HtmlEntities.decode(body)|nodes]), till_closing_bracket(html) }
    defp to_ast_nodes("<" <> html, nodes, body) do
        { element, html } = to_ast_element(html)
        to_ast_nodes(html, [element, HtmlEntities.decode(body)|nodes])
    end
    defp to_ast_nodes(<<c :: utf8, html :: binary>>, nodes, body), do: to_ast_nodes(html, nodes, <<body :: binary, c :: utf8>>)

    defp till_closing_bracket(">" <> html), do: html
    defp till_closing_bracket(<<_ :: utf8, html :: binary>>), do: till_closing_bracket(html)

    defp to_ast_element(html, tag \\ "")
    defp to_ast_element(<<c :: utf8, html :: binary>>, "") when c in @spaces, do: to_ast_element(html, "")
    defp to_ast_element(<<c :: utf8, html :: binary>>, tag) when c in @spaces do
        { attrs, html } = to_ast_attributes(html)
        { nodes, html } = to_ast_nodes(html)
        { { tag, Enum.map(attrs, fn { k, v } -> { k, HtmlEntities.decode(v) } end), nodes }, html }
    end
    defp to_ast_element("/>" <> html, tag), do: { { tag, [], [] }, html }
    defp to_ast_element(">" <> html, tag) do
        { nodes, html } = to_ast_nodes(html)
        { { tag, [], nodes }, html }
    end
    defp to_ast_element(<<c :: utf8, html :: binary>>, tag), do: to_ast_element(html, <<tag :: binary, c :: utf8>>)
    defp to_ast_element(_, _), do: { [], "" }

    defp to_ast_attributes(html, type \\ :key, quoted \\ nil, attrs \\ [{ "", "" }])
    defp to_ast_attributes("=" <> html, :key, nil, attrs), do: to_ast_attributes(html, :value, nil, attrs)
    defp to_ast_attributes("/>" <> html, _, nil, [{ "", "" }|attrs]), do: { Enum.reverse(attrs), html }
    defp to_ast_attributes("/>" <> html, _, nil, attrs), do: { Enum.reverse(attrs), html }
    defp to_ast_attributes(">" <> html, _, nil, [{ "", "" }|attrs]), do: { Enum.reverse(attrs), html }
    defp to_ast_attributes(">" <> html, _, nil, attrs), do: { Enum.reverse(attrs), html }
    defp to_ast_attributes(<<c :: utf8, html :: binary>>, :key, nil, attrs = [{ "", "" }|_]) when c in @spaces, do: to_ast_attributes(html, :key, nil, attrs)
    defp to_ast_attributes(<<c :: utf8, html :: binary>>, :key, nil, attrs) when c in @spaces, do: to_ast_attributes(html, :key, nil, [{ "", "" }|attrs])
    defp to_ast_attributes(<<c :: utf8, html :: binary>>, :value, nil, attrs) when c in @spaces, do: to_ast_attributes(html, :key, nil, [{ "", "" }|attrs])
    defp to_ast_attributes(<<c :: utf8, html :: binary>>, type, nil, attrs) when c in @quotes, do: to_ast_attributes(html, type, c, attrs)
    defp to_ast_attributes(<<c :: utf8, html :: binary>>, type, c, attrs), do: to_ast_attributes(html, type, nil, attrs)
    defp to_ast_attributes(<<c :: utf8, html :: binary>>, :key, quoted, [{ key, value }|attrs]), do: to_ast_attributes(html, :key, quoted, [{ <<key :: binary, c :: utf8>>, value }|attrs])
    defp to_ast_attributes(<<c :: utf8, html :: binary>>, :value, quoted, [{ key, value }|attrs]), do: to_ast_attributes(html, :value, quoted, [{ key, <<value :: binary, c :: utf8>> }|attrs])
end
