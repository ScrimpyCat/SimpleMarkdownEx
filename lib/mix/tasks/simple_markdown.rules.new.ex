defmodule Mix.Tasks.SimpleMarkdown.Rules.New do
    @shortdoc "Generate the standard rules config"
    @moduledoc """
      Generates the standard rules config.

      The rules config should be imported into the app's config.exs
        import_config "simple_markdown_rules.exs"

      The rule config may be changed to suit your needs, if new rules are
      added or you wish the rendering behaviour of current rules to be changed
      this can be done by defining new rendering implementations for those
      rules.
    """

    use Mix.Task

    def run(env) do
        { _, { destination, formatter } } = Enum.reduce(env, { nil, { "config/simple_markdown_rules.exs", &(&1) } }, fn
            destination, { :destination, { _, formatter } } -> { nil, { destination, formatter } }
            "--destination", { _, args } -> { :destination, args }
            "--format", { _, { destination, formatter } } -> { nil, { destination, if(Version.compare(System.version, "1.6.0") != :lt, do: &Code.format_string!/1, else: formatter) } }
        end)

        write_config(destination, formatter)
    end

    defp write_config(destination, formatter) do
        with exists <- File.exists?(destination),
             true <- if(exists, do: Mix.shell.yes?("Do you want to replace the file at #{destination}"), else: true) do
                config = """
                use Mix.Config

                config :simple_markdown,
                    rules: #{File.read!(Path.join(__DIR__, "../../simple_markdown/rules.exs"))}
                """

                File.write!(destination, formatter.(config))
                Mix.shell.info "Please import the #{Path.basename(destination)} config."
        end
    end
end
