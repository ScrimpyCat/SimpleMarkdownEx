defmodule SimpleMarkdown.Renderer.HTML.Utilities do
    @moduledoc """
      Convenient functions for working with HTML.
    """
    @type ast :: { tag :: String.Chars.t, attrs :: [{ String.Chars.t, String.Chars.t }], ast } | [ast] | String.t

    @type version :: { major :: non_neg_integer, minor :: non_neg_integer }
    @type format(type) :: { type, version }
    @type formats :: format(:html) | format(:xhtml)
    @type tag_list :: [atom | String.t]
    @type chardata_list :: [{ String.t, String.t }]

    @doc """
      Convert the HTML AST to HTML.

      The conversion behaviour can be modified by setting the `opts` parameter with
      any of the following:

      * `:format` - To control the HTML format. This takes one of the valid `t:formats/0`.
      By default this is set to generate HTML5 code (`{ :html, { 5, 0 } }`).
      * `:void_elements` - To customise which elements are void elements (do not
      contain content). This takes a `t:tag_list/0`. By default this is set to the list
      of tags returned by `void_elements/0`.
      * `:raw_text_elements` - To customise which elements are raw text elements (do not
      encode their content nor contain nested nodes). This takes a `t:tag_list/0`. By default
      this is set to the list of tags returned by `raw_text_elements/0`.
      * `:include_chardata` - To control whether nodes that match `:chardata` should be
      included in the HTML or not. By default this is set to false.
      * `:chardata` - To customise which elements are considered to be character data (special
      cases that do not encode their content nor contain nested nodes). This takes a
      `t:chardata_list/0`. By default this is set to the list of opening/closing tags returned
      by `chardata/0`.

      Example
      -------
        iex> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html({ :p, [], "hello" }) |> IO.chardata_to_string
        "<p>hello</p>"

        iex> SimpleMarkdown.Renderer.HTML.Utilities.ast_to_html({ "!--", [], "hello" }, include_chardata: true) |> IO.chardata_to_string
        "<!--hello-->"
    """
    @spec ast_to_html(ast, keyword) :: IO.chardata
    def ast_to_html(ast, opts \\ []) do
        ast_to_html(ast, opts[:format] || { :html, { 5, 0 } }, make_set(opts[:void_elements] || void_elements()), make_set(opts[:raw_text_elements] || raw_text_elements()), false, Map.new(opts[:chardata] || chardata()), opts[:include_chardata] || false)
    end

    @spec ast_to_html(ast, formats, MapSet.t, MapSet.t, boolean, %{ optional(String.t) => String.t }, boolean) :: IO.chardata
    defp ast_to_html({ tag, attrs, nodes }, format, void_elements, raw_text_elements, is_raw_text, chardata, include_chardata) do
        tag_s = to_string(tag)

        case chardata[tag_s] do
            nil ->
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

                html_element(tag, attrs, nodes, format, is_void, void_elements, raw_text_elements, is_raw_text, chardata, include_chardata)
            suffix ->
                if include_chardata do
                    ["<", tag_s, ast_to_html(nodes, format, void_elements, raw_text_elements, true, chardata, include_chardata), suffix, ">"]
                else
                    ""
                end
        end
    end
    defp ast_to_html(list, format, void_elements, raw_text_elements, is_raw_text, chardata, include_chardata) when is_list(list), do: Enum.map(list, &ast_to_html(&1, format, void_elements, raw_text_elements, is_raw_text, chardata, include_chardata))
    defp ast_to_html(string, _, _, _, false, _, _), do: HtmlEntities.encode(string)
    defp ast_to_html(string, _, _, _, true, _, _), do: string

    defp html_element(tag, attrs, [], { :html, { vsn, _ } }, true, _, _, _, _, _) when vsn >= 5 do
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
    defp html_element(tag, attrs, [], { :xhtml, _ }, true, _, _, _, _, _) do
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
    defp html_element(tag, attrs, nodes, format, _, void_elements, raw_text_elements, is_raw_text, chardata, include_chardata) do
        [
            "<",
            tag,
            Enum.map(attrs, fn
                { key, "" } -> [" ", to_string(key)]
                { key, value } -> [" ", to_string(key), "=\"", to_string(value) |> HtmlEntities.encode, "\""]
            end),
            ">",
            ast_to_html(nodes, format, void_elements, raw_text_elements, is_raw_text, chardata, include_chardata),
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

    @doc """
      A list of [void elements](https://html.spec.whatwg.org/multipage/syntax.html#void-elements).
    """
    @spec void_elements() :: tag_list
    def void_elements() do
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

    @doc """
      A list of [raw text elements](https://html.spec.whatwg.org/multipage/syntax.html#raw-text-elements).
    """
    @spec raw_text_elements() :: tag_list
    def raw_text_elements() do
        [
            :script,
            :style
        ]
    end

    @doc """
      A list of any special nodes that will be treated as raw character data.

      Currently this includes comments, character data, DTD (document type definitions),
      PI (processing instructons).

      Examples of currently supported nodes and how they're represented in
      the AST:

        { "!--", [], " comment " } \#<!-- comment -->
        { "![CDATA[", [], "foo" } \#<![CDATA[foo]]>
        { "!DOCTYPE", [], " html" } \#<!DOCTYPE html>
        { "?", [], "xml version=\"1.0\" encoding=\"UTF-8\" " } \#<?xml version="1.0" encoding="UTF-8" ?>
    """
    def chardata() do
        [
            { "!--", "--" },
            { "![CDATA[", "]]" },
            { "!DOCTYPE", "" },
            { "?", "?" }
        ]
    end

    @doc """
      Convert the HTML to HTML AST.

      The parsing behaviour can be modified by setting the `opts` parameter with
      any of the following:

      * `:void_elements` - To customise which elements are void elements (do not
      contain content). This takes a `t:tag_list/0`. By default this is set to the list
      of tags returned by `void_elements/0`.
      * `:raw_text_elements` - To customise which elements are raw text elements (do not
      encode their content nor contain nested nodes). This takes a `t:tag_list/0`. By default
      this is set to the list of tags returned by `raw_text_elements/0`.
      * `:include_chardata` - To control whether nodes that match `:chardata` should be
      included in the AST or not. By default this is set to false.
      * `:chardata` - To customise which elements are considered to be character data (special
      cases that do not encode their content nor contain nested nodes). This takes a
      `t:chardata_list/0`. By default this is set to the list of opening/closing tags returned
      by `chardata/0`.


      Example
      -------
        iex> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast("<p>hello</p>")
        { "p", [], "hello" }

        iex> SimpleMarkdown.Renderer.HTML.Utilities.html_to_ast("<!--hello-->", include_chardata: true)
        { "!--", [], "hello" }
    """
    @spec html_to_ast(IO.chardata, keyword) :: ast
    def html_to_ast(html, opts \\ [])  do
        { nodes, _ } = to_ast_nodes(IO.chardata_to_string(html), make_set(opts[:void_elements] || void_elements()), make_set(opts[:raw_text_elements] || raw_text_elements()), { opts[:chardata] || chardata(), opts[:include_chardata] || false })
        nodes
    end

    @spaces [?\s, ?\t, ?\n, ?\f, ?\r]
    @quotes [?", ?']
    @terminators [?>, ?/]

    defp to_ast_nodes(html, void_elements, raw_text_elements, chardata, raw_text_tag \\ nil, nodes \\ [], body \\ "")
    defp to_ast_nodes("",  _, _, _, nil, nodes, body), do: { merge_nodes(HtmlEntities.decode(body), nodes) |> compact_nodes, "" }
    defp to_ast_nodes("",  _, _, _, _, nodes, body), do: { merge_nodes(body, nodes) |> compact_nodes, "" }
    defp to_ast_nodes("</" <> html, _, _, _, nil, nodes, body), do: { merge_nodes(HtmlEntities.decode(body), nodes) |> compact_nodes, till_closing_bracket(html) }
    defp to_ast_nodes("</" <> html, void_elements, raw_text_elements, chardata, raw_text_tag, nodes, body) do
        if Regex.match?(~r/^#{raw_text_tag}\W*>/, html) do
            { merge_nodes(body, nodes) |> compact_nodes, till_closing_bracket(html) }
        else
            to_ast_nodes(html, void_elements, raw_text_elements, chardata, raw_text_tag, nodes, body <> "</")
        end
    end
    defp to_ast_nodes("<" <> html, void_elements, raw_text_elements, chardata, nil, nodes, body) do
        to_ast_nodes(html, void_elements, raw_text_elements, chardata, nil, nodes, body, chardata)
    end
    defp to_ast_nodes(<<c :: utf8, html :: binary>>, void_elements, raw_text_elements, chardata, raw_text_tag, nodes, body), do: to_ast_nodes(html, void_elements, raw_text_elements, chardata, raw_text_tag, nodes, <<body :: binary, c :: utf8>>)

    defp to_ast_nodes(html, void_elements, raw_text_elements, chardata, raw_text_tag, nodes, body, { [{ open, close }|matches], include }) do
        if String.starts_with?(html, open) do
            size = byte_size(open)
            <<_ :: binary-size(size), html :: binary>> = html

            { element, html } = to_ast_chardata(String.split(html, close <> ">", parts: 2), open, include)
            to_ast_nodes(html, void_elements, raw_text_elements, chardata, nil, merge_nodes(element, HtmlEntities.decode(body), nodes))
        else
            to_ast_nodes(html, void_elements, raw_text_elements, chardata, raw_text_tag, nodes, body, { matches, include })
        end
    end
    defp to_ast_nodes(html, void_elements, raw_text_elements, chardata, _, nodes, body, { [], _ }) do
        { element, html } = to_ast_element(html, void_elements, raw_text_elements, chardata)
        to_ast_nodes(html, void_elements, raw_text_elements, chardata, nil, merge_nodes(element, HtmlEntities.decode(body), nodes))
    end

    defp to_ast_chardata([content], open, true), do: { { open, [], content }, "" }
    defp to_ast_chardata([content, html], open, true), do: { { open, [], content }, html }
    defp to_ast_chardata([_], _, false), do: { "", "" }
    defp to_ast_chardata([_, html], _, false), do: { "", html }

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

    defp to_ast_element(html, void_elements, raw_text_elements, chardata, tag \\ "", attrs \\ [])
    defp to_ast_element(<<c :: utf8, html :: binary>>, void_elements, raw_text_elements, chardata, "", _) when c in @spaces, do: to_ast_element(html, void_elements, raw_text_elements, chardata, "")
    defp to_ast_element(<<c :: utf8, html :: binary>>, void_elements, raw_text_elements, chardata, tag, _) when c in @spaces do
        { attrs, html } = to_ast_attributes(html)
        to_ast_element(html, void_elements, raw_text_elements, chardata, tag, Enum.map(attrs, fn { k, v } -> { k, HtmlEntities.decode(v) } end))
    end
    defp to_ast_element("/>" <> html, _, _, _, tag, attrs), do: { { tag, attrs, [] }, html }
    defp to_ast_element(">" <> html, void_elements, raw_text_elements, chardata, tag, attrs) do
        { nodes, html } = if MapSet.member?(void_elements, tag) do
            { [], html }
        else
            to_ast_nodes(html, void_elements, raw_text_elements, chardata, if(MapSet.member?(raw_text_elements, tag), do: tag))
        end
        { { tag, attrs, nodes }, html }
    end
    defp to_ast_element(<<c :: utf8, html :: binary>>, void_elements, raw_text_elements, chardata, tag, attrs), do: to_ast_element(html, void_elements, raw_text_elements, chardata, <<tag :: binary, c :: utf8>>, attrs)
    defp to_ast_element(_, _, _, _, _, _), do: { [], "" }

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
