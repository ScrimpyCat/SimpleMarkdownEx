# SimpleMarkdownEx
A simple and extendable Markdown to HTML converter for Elixir.

When first using the library the first thing to do is usually to
generate the base rule config.
```bash
$ mix simple_markdown.rules.new
```

And then importing the config in your config.exs:
```elixir
import_config "simple_markdown_rules.exs"
```

This config can be customized as you see fit. With new rules added,
and other rules removed or modified. Depending on the changes made
this may require some additional steps for things to work the way
you want. e.g. If you add or change the way a rule type fundamentally
works, you'll need to add or override the required rendering step
for that type. Details for this can be found in renderer protocols.

Example
-------
```elixir
#config/simple_markdown_rules.exs
#add the following rule to our ruleset
lol: %{ match: ~r/\Alol/, rules: [] }

#lib/lol_renderer.ex
#add a renderer for the HTML renderer for our "lol" rule
defimpl SimpleMarkdown.Renderer.HTML, for: SimpleMarkdown.Attribute.Lol do
    def render(_), do: "<img src=\"lolcat.jpg\">"
end

#usage:
SimpleMarkdown.convert("#lol") #=> "<h1><img src=\"lolcat.jpg\"></h1>"
```

Additionally new renderers can be created. How these new renderers should
be implemented is left up to you depending on how you'll provide input.
If you use the standard `convert/2` then the input will
be parsed, then the AST will be converted to these structs, and then 
that will be passed to your renderer. Alternatively you may call
`SimpleMarkdown.Parser.parse/1` directly and then manipulate that AST
how you see fit, and pass that to your renderer.