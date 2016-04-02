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

    def run(_) do
        if File.cp_r!(to_string(__info__(:compile)[:source]) |> Path.split |> Enum.slice(0..-5) |> Path.join |> Path.join("config/simple_markdown_rules.exs"), "config/simple_markdown_rules.exs", fn _, destination ->
            Mix.shell.yes?("Do you want to replace the file at #{destination}")
        end) |> Enum.count == 1 do
            Mix.shell.info "Please import the simple_markdown_rules.exs config."
        end
    end
end
