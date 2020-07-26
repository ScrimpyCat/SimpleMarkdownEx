defmodule SimpleMarkdown.Renderer.HTML.Utilities do
    @type ast :: { tag :: String.Chars.t, attrs :: [{ String.Chars.t, String.Chars.t }], ast } | [ast] | String.t

    @type version :: { major :: non_neg_integer, minor :: non_neg_integer }
    @type format(type) :: { type, version }
    @type formats :: format(:html) | format(:xhtml)

    @doc """
      Convert the HTML AST to HTML.

        iex> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html({ :p, [], "hello" }) |> IO.chardata_to_string
        "<p>hello</p>"
    """
    @spec ast_to_html(ast, keyword) :: IO.chardata
    def ast_to_html(ast, opts \\ []) do
        ast_to_html(ast, opts[:format] || { :html, { 5, 0 } }, make_set(opts[:void_elements] || void_elements()), make_set(opts[:raw_text_elements] || raw_text_elements()), false)
    end

    @spec ast_to_html(ast, formats, MapSet.t, MapSet.t, boolean) :: IO.chardata
    defp ast_to_html({ tag, attrs, nodes }, format, void_elements, raw_text_elements, is_raw_text) do
        tag_s = to_string(tag)
        { { is_void, is_raw_text }, tag } = if is_raw_text do
            case MapSet.member?(void_elements, tag) do
                true -> { { true, true }, tag_s }
                result -> { if(is_binary(tag), do: { result, true }, else: { MapSet.member?(void_elements, tag_s), true }), tag_s }
            end
        else
            case { MapSet.member?(void_elements, tag), MapSet.member?(raw_text_elements, tag) } do
                { true, true } -> { { true, true }, tag_s }
                result -> { if(is_binary(tag), do: result, else: { MapSet.member?(void_elements, tag_s), MapSet.member?(raw_text_elements, tag_s) }), tag_s }
            end
        end
        html_element(tag, attrs, nodes, format, is_void, void_elements, raw_text_elements, is_raw_text)
    end
    defp ast_to_html(list, format, void_elements, raw_text_elements, is_raw_text) when is_list(list), do: Enum.map(list, &ast_to_html(&1, format, void_elements, raw_text_elements, is_raw_text))
    defp ast_to_html(string, _, _, _, false), do: HtmlEntities.encode(string)
    defp ast_to_html(string, _, _, _, true), do: string

    defp html_element(tag, attrs, [], { :html, { vsn, _ } }, true, _, _, _) when vsn >= 5 do
        [
            "<",
            tag,
            Enum.map(attrs, fn
                { key, "" } -> [" ", to_string(key)]
                { key, value } -> [" ", to_string(key), "=\"", to_string(value) |> HtmlEntities.encode, "\""]
            end),
            ">"
        ]
    end
    defp html_element(tag, attrs, [], { :xhtml, _ }, true, _, _, _) do
        [
            "<",
            tag,
            Enum.map(attrs, fn
                { key, "" } -> [" ", to_string(key)]
                { key, value } -> [" ", to_string(key), "=\"", to_string(value) |> HtmlEntities.encode, "\""]
            end),
            " />"
        ]
    end
    defp html_element(tag, attrs, nodes, format, _, void_elements, raw_text_elements, is_raw_text) do
        [
            "<",
            tag,
            Enum.map(attrs, fn
                { key, "" } -> [" ", to_string(key)]
                { key, value } -> [" ", to_string(key), "=\"", to_string(value) |> HtmlEntities.encode, "\""]
            end),
            ">",
            ast_to_html(nodes, format, void_elements, raw_text_elements, is_raw_text),
            "</",
            tag,
            ">"
        ]
    end

    defp make_set(tags) do
        Enum.reduce(tags, MapSet.new(), fn
            e, acc when is_binary(e) -> MapSet.put(acc, e)
            e, acc -> MapSet.put(acc, e) |> MapSet.put(to_string(e))
        end)
    end

    # https://html.spec.whatwg.org/multipage/syntax.html#void-elements
    defp void_elements() do
        [
            :area,
            :base,
            :br,
            :col,
            :embed,
            :hr,
            :img,
            :input,
            :keygen, # obsolete
            :link,
            :meta,
            :param,
            :source,
            :track,
            :wbr
        ]
    end

    # https://html.spec.whatwg.org/multipage/syntax.html#raw-text-elements
    defp raw_text_elements() do
        [
            :script,
            :style
        ]
    end

    @doc """
      Convert the HTML to HTML AST.

        iex> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast("<p>hello</p>")
        { "p", [], "hello" }
    """
    @spec html_to_ast(IO.chardata) :: ast
    def html_to_ast(html)  do
        { nodes, _ } = to_ast_nodes(IO.chardata_to_string(html))
        nodes
    end

    @spaces [?\s, ?\t, ?\n, ?\f, ?\r]
    @quotes [?", ?']
    @terminators [?>, ?/]

    defp to_ast_nodes(html, nodes \\ [], body \\ "")
    defp to_ast_nodes("",  nodes, body), do: { merge_nodes(HtmlEntities.decode(body), nodes) |> compact_nodes, "" }
    defp to_ast_nodes("</" <> html,  nodes, body), do: { merge_nodes(HtmlEntities.decode(body), nodes) |> compact_nodes, till_closing_bracket(html) }
    defp to_ast_nodes("<" <> html, nodes, body) do
        { element, html } = to_ast_element(html)
        to_ast_nodes(html, merge_nodes(element, HtmlEntities.decode(body), nodes))
    end
    defp to_ast_nodes(<<c :: utf8, html :: binary>>, nodes, body), do: to_ast_nodes(html, nodes, <<body :: binary, c :: utf8>>)

    defp compact_nodes([node]), do: node
    defp compact_nodes(nodes), do: nodes |> Enum.reverse

    defp merge_nodes("", list), do: list
    defp merge_nodes(a, list), do: [a|list]

    defp merge_nodes("", "", list), do: list
    defp merge_nodes(a, "", list), do: [a|list]
    defp merge_nodes("", b, list), do: [b|list]
    defp merge_nodes(a, b, list), do: [a, b|list]

    defp till_closing_bracket(">" <> html), do: html
    defp till_closing_bracket(<<_ :: utf8, html :: binary>>), do: till_closing_bracket(html)

    defp to_ast_element(html, tag \\ "", attrs \\ [])
    defp to_ast_element(<<c :: utf8, html :: binary>>, "", _) when c in @spaces, do: to_ast_element(html, "")
    defp to_ast_element(<<c :: utf8, html :: binary>>, tag, _) when c in @spaces do
        { attrs, html } = to_ast_attributes(html)
        to_ast_element(html, tag, Enum.map(attrs, fn { k, v } -> { k, HtmlEntities.decode(v) } end))
    end
    defp to_ast_element("/>" <> html, tag, attrs), do: { { tag, attrs, [] }, html }
    defp to_ast_element(">" <> html, tag, attrs) do
        { nodes, html } = to_ast_nodes(html)
        { { tag, attrs, nodes }, html }
    end
    defp to_ast_element(<<c :: utf8, html :: binary>>, tag, attrs), do: to_ast_element(html, <<tag :: binary, c :: utf8>>, attrs)
    defp to_ast_element(_, _, _), do: { [], "" }

    defp to_ast_attributes(html, type \\ :key, quoted \\ nil, attrs \\ [{ "", "" }])
    defp to_ast_attributes("=" <> html, :key, nil, attrs), do: to_ast_attributes(html, :value, nil, attrs)
    defp to_ast_attributes(html = <<c :: utf8, _ :: binary>>, _, nil, [{ "", "" }|attrs]) when c in @terminators, do: { Enum.reverse(attrs), html }
    defp to_ast_attributes(html = <<c :: utf8, _ :: binary>>, _, nil, attrs) when c in @terminators, do: { Enum.reverse(attrs), html }
    defp to_ast_attributes(<<c :: utf8, html :: binary>>, :key, nil, attrs = [{ "", "" }|_]) when c in @spaces, do: to_ast_attributes(html, :key, nil, attrs)
    defp to_ast_attributes(<<c :: utf8, html :: binary>>, :key, nil, attrs) when c in @spaces, do: to_ast_attributes(html, :key, nil, [{ "", "" }|attrs])
    defp to_ast_attributes(<<c :: utf8, html :: binary>>, :value, nil, attrs) when c in @spaces, do: to_ast_attributes(html, :key, nil, [{ "", "" }|attrs])
    defp to_ast_attributes(<<c :: utf8, html :: binary>>, type, nil, attrs) when c in @quotes, do: to_ast_attributes(html, type, c, attrs)
    defp to_ast_attributes(<<c :: utf8, html :: binary>>, type, c, attrs), do: to_ast_attributes(html, type, nil, attrs)
    defp to_ast_attributes(<<c :: utf8, html :: binary>>, :key, quoted, [{ key, value }|attrs]), do: to_ast_attributes(html, :key, quoted, [{ <<key :: binary, c :: utf8>>, value }|attrs])
    defp to_ast_attributes(<<c :: utf8, html :: binary>>, :value, quoted, [{ key, value }|attrs]), do: to_ast_attributes(html, :value, quoted, [{ key, <<value :: binary, c :: utf8>> }|attrs])
    defp to_ast_attributes(_, _, _, _), do: { [], "" }
end
