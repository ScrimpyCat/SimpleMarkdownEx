defmodule SimpleMarkdownParserTest do
    use ExUnit.Case
    doctest SimpleMarkdown.Parser

    setup context do
        rules = Application.fetch_env!(:simple_markdown, :rules)

        rules = if type = context[:attribute] do
            Enum.filter(rules, fn
                { ^type, _ } -> true
                _ -> false
            end)
        else
            rules
        end

        { :ok, [rules: rules] }
    end

    @tag attribute: :line_break
    test "parsing line break", context do
        assert ["test", { :line_break, [] }] == SimpleMarkdown.Parser.parse("test  ", context.rules)
        assert ["tést", { :line_break, [] }] == SimpleMarkdown.Parser.parse("tést  ", context.rules)
    end

    @tag attribute: :header
    test "parsing header", context do
        assert [{ :header, ["tést"], 1 }] == SimpleMarkdown.Parser.parse("#tést", context.rules)
        assert [{ :header, ["test"], 1 }] == SimpleMarkdown.Parser.parse("#test", context.rules)
        assert [{ :header, ["test"], 2 }] == SimpleMarkdown.Parser.parse("##test", context.rules)
        assert [{ :header, ["test"], 3 }] == SimpleMarkdown.Parser.parse("###test", context.rules)
        assert [{ :header, ["test"], 4 }] == SimpleMarkdown.Parser.parse("####test", context.rules)
        assert [{ :header, ["test"], 5 }] == SimpleMarkdown.Parser.parse("#####test", context.rules)
        assert [{ :header, ["test"], 6 }] == SimpleMarkdown.Parser.parse("######test", context.rules)
        assert [{ :header, ["#test"], 6 }] == SimpleMarkdown.Parser.parse("#######test", context.rules)
        assert [{ :header, ["test #test"], 1 }] == SimpleMarkdown.Parser.parse("#test #test", context.rules)
        assert [{ :header, ["test"], 2 }] == SimpleMarkdown.Parser.parse("test\n-", context.rules)
        assert [{ :header, ["test"], 2 }] == SimpleMarkdown.Parser.parse("test\n----", context.rules)
        assert [{ :header, ["test"], 2 }] == SimpleMarkdown.Parser.parse("test\n---------", context.rules)
        assert [{ :header, ["test"], 1 }] == SimpleMarkdown.Parser.parse("test\n=", context.rules)
        assert [{ :header, ["test"], 1 }] == SimpleMarkdown.Parser.parse("test\n====", context.rules)
        assert [{ :header, ["test"], 1 }] == SimpleMarkdown.Parser.parse("test\n=========", context.rules)

        assert { :header, ["test"], 1 } == List.first(SimpleMarkdown.Parser.parse("#test\nother", context.rules))
        assert { :header, ["test"], 2 } == List.first(SimpleMarkdown.Parser.parse("##test\nother", context.rules))
        assert { :header, ["test"], 3 } == List.first(SimpleMarkdown.Parser.parse("###test\nother", context.rules))
        assert { :header, ["test"], 4 } == List.first(SimpleMarkdown.Parser.parse("####test\nother", context.rules))
        assert { :header, ["test"], 5 } == List.first(SimpleMarkdown.Parser.parse("#####test\nother", context.rules))
        assert { :header, ["test"], 6 } == List.first(SimpleMarkdown.Parser.parse("######test\nother", context.rules))
        assert { :header, ["#test"], 6 } == List.first(SimpleMarkdown.Parser.parse("#######test\nother", context.rules))
        assert { :header, ["test #test"], 1 } == List.first(SimpleMarkdown.Parser.parse("#test #test\nother", context.rules))
        assert { :header, ["test"], 2 } == List.first(SimpleMarkdown.Parser.parse("test\n-\nother", context.rules))
        assert { :header, ["test"], 2 } == List.first(SimpleMarkdown.Parser.parse("test\n----\nother", context.rules))
        assert { :header, ["test"], 2 } == List.first(SimpleMarkdown.Parser.parse("test\n---------\nother", context.rules))
        assert { :header, ["test"], 1 } == List.first(SimpleMarkdown.Parser.parse("test\n=\nother", context.rules))
        assert { :header, ["test"], 1 } == List.first(SimpleMarkdown.Parser.parse("test\n====\nother", context.rules))
        assert { :header, ["test"], 1 } == List.first(SimpleMarkdown.Parser.parse("test\n=========\nother", context.rules))

        assert { :header, ["test"], 2 } != List.first(SimpleMarkdown.Parser.parse("test\n-other", context.rules))
        assert { :header, ["test"], 2 } != List.first(SimpleMarkdown.Parser.parse("test\n----other", context.rules))
        assert { :header, ["test"], 2 } != List.first(SimpleMarkdown.Parser.parse("test\n---------other", context.rules))
        assert { :header, ["test"], 1 } != List.first(SimpleMarkdown.Parser.parse("test\n=other", context.rules))
        assert { :header, ["test"], 1 } != List.first(SimpleMarkdown.Parser.parse("test\n====other", context.rules))
        assert { :header, ["test"], 1 } != List.first(SimpleMarkdown.Parser.parse("test\n=========other", context.rules))

        assert [{ :header, ["test"], 1 }] == SimpleMarkdown.Parser.parse("#test")
        assert [{ :header, ["test"], 2 }] == SimpleMarkdown.Parser.parse("##test")
        assert [{ :header, ["test"], 3 }] == SimpleMarkdown.Parser.parse("###test")
        assert [{ :header, ["test"], 4 }] == SimpleMarkdown.Parser.parse("####test")
        assert [{ :header, ["test"], 5 }] == SimpleMarkdown.Parser.parse("#####test")
        assert [{ :header, ["test"], 6 }] == SimpleMarkdown.Parser.parse("######test")
        assert [{ :header, ["test"], 2 }] == SimpleMarkdown.Parser.parse("test\n----")
        assert [{ :header, ["test"], 1 }] == SimpleMarkdown.Parser.parse("test\n====")

        assert [{ :header, ["tést"], 1 }] == SimpleMarkdown.Parser.parse("#tést")
    end

    @tag attribute: :emphasis
    test "parsing emphasis", context do
        assert [{ :emphasis, ["tést"], :regular }] == SimpleMarkdown.Parser.parse("_tést_", context.rules)
        assert [{ :emphasis, ["test"], :regular }] == SimpleMarkdown.Parser.parse("_test_", context.rules)
        assert [{ :emphasis, ["test"], :regular }] == SimpleMarkdown.Parser.parse("*test*", context.rules)
        assert [{ :emphasis, ["test"], :strong }] == SimpleMarkdown.Parser.parse("__test__", context.rules)
        assert [{ :emphasis, ["test"], :strong }] == SimpleMarkdown.Parser.parse("**test**", context.rules)
        assert [{ :emphasis, ["*test*"], :regular }] == SimpleMarkdown.Parser.parse("_*test*_", context.rules)
        assert [{ :emphasis, ["_test_"], :regular }] == SimpleMarkdown.Parser.parse("*_test_*", context.rules)
        assert [{ :emphasis, [{ :emphasis, ["*test"], :regular }, "*"], :strong }] == SimpleMarkdown.Parser.parse("__**test**__", context.rules)
        assert [{ :emphasis, [{ :emphasis, ["_test"], :regular }, "_"], :strong }] == SimpleMarkdown.Parser.parse("**__test__**", context.rules)
        assert [{ :emphasis, [{ :emphasis, ["test"], :strong }], :regular }] == SimpleMarkdown.Parser.parse("_**test**_", context.rules)
        assert [{ :emphasis, [{ :emphasis, ["test"], :strong }], :regular }] == SimpleMarkdown.Parser.parse("*__test__*", context.rules)
        assert [{ :emphasis, [{ :emphasis, ["test"], :regular }], :strong }] == SimpleMarkdown.Parser.parse("__*test*__", context.rules)
        assert [{ :emphasis, [{ :emphasis, ["test"], :regular }], :strong }] == SimpleMarkdown.Parser.parse("**_test_**", context.rules)

        assert { :emphasis, ["test"], :regular } == List.first(SimpleMarkdown.Parser.parse("_test_other", context.rules))
        assert { :emphasis, ["test"], :regular } == List.first(SimpleMarkdown.Parser.parse("*test*other", context.rules))
        assert { :emphasis, ["test"], :strong } == List.first(SimpleMarkdown.Parser.parse("__test__other", context.rules))
        assert { :emphasis, ["test"], :strong } == List.first(SimpleMarkdown.Parser.parse("**test**other", context.rules))
        assert { :emphasis, ["*test*"], :regular } == List.first(SimpleMarkdown.Parser.parse("_*test*_other", context.rules))
        assert { :emphasis, ["_test_"], :regular } == List.first(SimpleMarkdown.Parser.parse("*_test_*other", context.rules))
        assert { :emphasis, [{ :emphasis, ["*test"], :regular }, "*"], :strong } == List.first(SimpleMarkdown.Parser.parse("__**test**__other", context.rules))
        assert { :emphasis, [{ :emphasis, ["_test"], :regular }, "_"], :strong } == List.first(SimpleMarkdown.Parser.parse("**__test__**other", context.rules))
        assert { :emphasis, [{ :emphasis, ["test"], :strong }], :regular } == List.first(SimpleMarkdown.Parser.parse("_**test**_other", context.rules))
        assert { :emphasis, [{ :emphasis, ["test"], :strong }], :regular } == List.first(SimpleMarkdown.Parser.parse("*__test__*other", context.rules))
        assert { :emphasis, [{ :emphasis, ["test"], :regular }], :strong } == List.first(SimpleMarkdown.Parser.parse("__*test*__other", context.rules))
        assert { :emphasis, [{ :emphasis, ["test"], :regular }], :strong } == List.first(SimpleMarkdown.Parser.parse("**_test_**other", context.rules))

        assert [{ :paragraph, [{ :emphasis, ["test"], :regular }] }] == SimpleMarkdown.Parser.parse("_test_")
        assert [{ :paragraph, [{ :emphasis, ["test"], :regular }] }] == SimpleMarkdown.Parser.parse("*test*")
        assert [{ :paragraph, [{ :emphasis, ["test"], :strong }] }] == SimpleMarkdown.Parser.parse("__test__")
        assert [{ :paragraph, [{ :emphasis, ["test"], :strong }] }] == SimpleMarkdown.Parser.parse("**test**")
        assert [{ :paragraph, [{ :emphasis, ["tést"], :strong }] }] == SimpleMarkdown.Parser.parse("**tést**")
    end

    @tag attribute: :horizontal_rule
    test "parsing horizontal rule", context do
        assert [{ :horizontal_rule, [] }] == SimpleMarkdown.Parser.parse("***", context.rules)
        assert [{ :horizontal_rule, [] }] == SimpleMarkdown.Parser.parse("* * *", context.rules)
        assert [{ :horizontal_rule, [] }] == SimpleMarkdown.Parser.parse("******", context.rules)
        assert [{ :horizontal_rule, [] }] == SimpleMarkdown.Parser.parse("---", context.rules)
        assert [{ :horizontal_rule, [] }] == SimpleMarkdown.Parser.parse("- - -", context.rules)
        assert [{ :horizontal_rule, [] }] == SimpleMarkdown.Parser.parse("------", context.rules)

        assert [{ :horizontal_rule, [] }] == SimpleMarkdown.Parser.parse("***")
        assert [{ :horizontal_rule, [] }] == SimpleMarkdown.Parser.parse("* * *")
        assert [{ :horizontal_rule, [] }] == SimpleMarkdown.Parser.parse("******")
        assert [{ :horizontal_rule, [] }] == SimpleMarkdown.Parser.parse("---")
        assert [{ :horizontal_rule, [] }] == SimpleMarkdown.Parser.parse("- - -")
        assert [{ :horizontal_rule, [] }] == SimpleMarkdown.Parser.parse("------")
    end

    @tag attribute: :table
    test "parsing table", context do
        assert [{ :table, ["\n", { :row, ["1", "2", "3", "4"] }, "\n", { :row, ["11", "22", "33", "44"] }], [{ "Oné", :default }, { "Two", :center }, { "Three", :right }, { "Four", :left }] }] == SimpleMarkdown.Parser.parse("|Oné|Two|Three|Four|\n|---|:---:|---:|:---|\n|1|2|3|4|\n|11|22|33|44|", context.rules)
        assert [{ :table, ["\n", { :row, ["1", "2", "3", "4"] }, "\n", { :row, ["11", "22", "33", "44"] }], [{ "One", :default }, { "Two", :center }, { "Three", :right }, { "Four", :left }] }] == SimpleMarkdown.Parser.parse("|One|Two|Three|Four|\n|---|:---:|---:|:---|\n|1|2|3|4|\n|11|22|33|44|", context.rules)
        assert [{ :table, ["\n", { :row, ["1", "2", "3", "4"] }, "\n", { :row, ["11", "22", "33", "44"] }], [{ "One", :default }, { "Two", :center }, { "Three", :right }, { "Four", :left }] }] == SimpleMarkdown.Parser.parse("One|Two|Three|Four\n---|:---:|---:|:---\n1|2|3|4\n11|22|33|44", context.rules)
        assert [{ :table, ["\n", { :row, ["1", "2", "3", "4"] }, "\n", { :row, ["11", "22", "33", "44"] }], [:default, :center, :right, :left] }] == SimpleMarkdown.Parser.parse("|---|:---:|---:|:---|\n|1|2|3|4|\n|11|22|33|44|", context.rules)
        assert [{ :table, ["\n", { :row, ["1", "2", "3", "4"] }, "\n", { :row, ["11", "22", "33", "44"] }], [:default, :center, :right, :left] }] == SimpleMarkdown.Parser.parse("---|:---:|---:|:---\n1|2|3|4\n11|22|33|44", context.rules)

        assert [{ :table, [row: ["1", "2", "3", "4"], row: ["11", "22", "33", "44"]], [{ "Oné", :default }, { "Two", :center }, { "Three", :right }, { "Four", :left }] }] == SimpleMarkdown.Parser.parse("|Oné|Two|Three|Four|\n|---|:---:|---:|:---|\n|1|2|3|4|\n|11|22|33|44|")
        assert [{ :table, [row: ["1", "2", "3", "4"], row: ["11", "22", "33", "44"]], [{ "One", :default }, { "Two", :center }, { "Three", :right }, { "Four", :left }] }] == SimpleMarkdown.Parser.parse("|One|Two|Three|Four|\n|---|:---:|---:|:---|\n|1|2|3|4|\n|11|22|33|44|")
        assert [{ :table, [row: ["1", "2", "3", "4"], row: ["11", "22", "33", "44"]], [{ "One", :default }, { "Two", :center }, { "Three", :right }, { "Four", :left }] }] == SimpleMarkdown.Parser.parse("One|Two|Three|Four\n---|:---:|---:|:---\n1|2|3|4\n11|22|33|44")
        assert [{ :table, [row: ["1", "2", "3", "4"], row: ["11", "22", "33", "44"]], [:default, :center, :right, :left] }] == SimpleMarkdown.Parser.parse("|---|:---:|---:|:---|\n|1|2|3|4|\n|11|22|33|44|")
        assert [{ :table, [row: ["1", "2", "3", "4"], row: ["11", "22", "33", "44"]], [:default, :center, :right, :left] }] == SimpleMarkdown.Parser.parse("---|:---:|---:|:---\n1|2|3|4\n11|22|33|44")
    end

    @tag attribute: :task_list
    test "parsing task list", context do
        assert [{ :task_list, [{ :task, ["test"], :deselected }] }] == SimpleMarkdown.Parser.parse("- [ ] test", context.rules)
        assert [{ :task_list, [{ :task, ["tést"], :deselected }] }] == SimpleMarkdown.Parser.parse("- [ ] tést", context.rules)
        assert [{ :task_list, [{ :task, ["test"], :deselected }] }, "\n"] == SimpleMarkdown.Parser.parse("- [ ] test\n", context.rules)
        assert [{ :task_list, [{ :task, ["a"], :deselected }, "\n", { :task, ["b"], :selected }] }] == SimpleMarkdown.Parser.parse("- [ ] a\n- [x] b", context.rules)
        assert [{ :task_list, [{ :task, ["test"], :selected }] }] == SimpleMarkdown.Parser.parse("- [x] test", context.rules)
        assert [{ :task_list, [{ :task, ["test"], :selected }] }, "\n"] == SimpleMarkdown.Parser.parse("- [x] test\n", context.rules)
        assert [{ :task_list, [{ :task, ["a"], :selected }, "\n", { :task, ["b"], :deselected }] }] == SimpleMarkdown.Parser.parse("- [x] a\n- [ ] b", context.rules)

        assert [{ :task_list, [{ :task, ["tést"], :deselected }] }] == SimpleMarkdown.Parser.parse("- [ ] tést")
        assert [{ :task_list, [{ :task, ["test"], :deselected }] }] == SimpleMarkdown.Parser.parse("- [ ] test")
        assert [{ :task_list, [{ :task, ["test"], :deselected }] }] == SimpleMarkdown.Parser.parse("- [ ] test\n")
        assert [{ :task_list, [{ :task, ["a"], :deselected }, { :task, ["b"], :selected }] }] == SimpleMarkdown.Parser.parse("- [ ] a\n- [x] b")
        assert [{ :task_list, [{ :task, ["test"], :selected }] }] == SimpleMarkdown.Parser.parse("- [x] test")
        assert [{ :task_list, [{ :task, ["test"], :selected }] }] == SimpleMarkdown.Parser.parse("- [x] test\n")
        assert [{ :task_list, [{ :task, ["a"], :selected }, { :task, ["b"], :deselected }] }] == SimpleMarkdown.Parser.parse("- [x] a\n- [ ] b")
    end

    @tag attribute: :list
    test "parsing list", context do
        assert [{ :list, [{ :item, ["test"] }], :unordered }] == SimpleMarkdown.Parser.parse("* test", context.rules)
        assert [{ :list, [{ :item, ["tést"] }], :unordered }] == SimpleMarkdown.Parser.parse("* tést", context.rules)
        assert [{ :list, [{ :item, ["test\n"] }], :unordered }] == SimpleMarkdown.Parser.parse("* test\n", context.rules)
        assert [{ :list, [{ :item, ["a\n"] }, { :item, ["b"] }], :unordered }] == SimpleMarkdown.Parser.parse("* a\n* b", context.rules)
        assert [{ :list, [{ :item, ["a\n"] }, { :item, ["b\n"] }], :unordered }, "\nc"] == SimpleMarkdown.Parser.parse("* a\n* b\n\nc", context.rules)
        assert [{ :list, [{ :item, ["a\n*c d\n"] }, { :item, ["b"] }], :unordered }] == SimpleMarkdown.Parser.parse("* a\n*c d\n * b", context.rules)
        assert [{ :list, [{ :item, ["a\nc * d\n"] }, { :item, ["b"] }], :unordered }] == SimpleMarkdown.Parser.parse("* a\nc * d\n * b", context.rules)
        assert [{ :list, [{ :item, ["test"] }], :ordered }] == SimpleMarkdown.Parser.parse("1. test", context.rules)
        assert [{ :list, [{ :item, ["test\n"] }], :ordered }] == SimpleMarkdown.Parser.parse("1. test\n", context.rules)
        assert [{ :list, [{ :item, ["a\n"] }, { :item, ["b"] }], :ordered }] == SimpleMarkdown.Parser.parse("1. a\n2. b", context.rules)
        assert [{ :list, [{ :item, ["a\n"] }, { :item, ["b\n"] }], :ordered }, "\nc"] == SimpleMarkdown.Parser.parse("1. a\n2. b\n\nc", context.rules)
        assert [{ :list, [{ :item, ["a\n2c d\n"] }, { :item, ["b"] }], :ordered }] == SimpleMarkdown.Parser.parse("1. a\n2c d\n 2. b", context.rules)
        assert [{ :list, [{ :item, ["a\nc 2. d\n"] }, { :item, ["b"] }], :ordered }] == SimpleMarkdown.Parser.parse("1. a\nc 2. d\n 2. b", context.rules)

        assert [{ :list, [{ :item, ["tést"] }], :unordered }] == SimpleMarkdown.Parser.parse("* tést")
        assert [{ :list, [{ :item, ["test"] }], :unordered }] == SimpleMarkdown.Parser.parse("* test")
        assert [{ :list, [{ :item, ["test"] }], :unordered }] == SimpleMarkdown.Parser.parse("* test\n")
        assert [{ :list, [{ :item, ["a"] }, { :item, ["b"] }], :unordered }] == SimpleMarkdown.Parser.parse("* a\n* b")
        assert [{ :list, [{ :item, ["test"] }], :ordered }] == SimpleMarkdown.Parser.parse("1. test")
        assert [{ :list, [{ :item, ["test"] }], :ordered }] == SimpleMarkdown.Parser.parse("1. test\n")
        assert [{ :list, [{ :item, ["a"] }, { :item, ["b"] }], :ordered }] == SimpleMarkdown.Parser.parse("1. a\n2. b")
    end

    @tag attribute: :preformatted_code
    test "parsing preformatted code", context do
        assert [{ :preformatted_code, ["test"] }] == SimpleMarkdown.Parser.parse("    test", context.rules)
        assert [{ :preformatted_code, ["tést"] }] == SimpleMarkdown.Parser.parse("    tést", context.rules)
        assert [{ :preformatted_code, ["test\n    test"] }] == SimpleMarkdown.Parser.parse("    test\n        test", context.rules)
        assert [{ :preformatted_code, ["test\n\ttest"] }] == SimpleMarkdown.Parser.parse("\ttest\n\t\ttest", context.rules)
        assert [{ :preformatted_code, ["test\n\ntest"] }] == SimpleMarkdown.Parser.parse("\ttest\n\t\n\ttest", context.rules)
        assert ["```test```"] == SimpleMarkdown.Parser.parse("```test```", context.rules)
        assert [{ :preformatted_code, ["test"] }] == SimpleMarkdown.Parser.parse("```\ntest```", context.rules)
        assert [{ :preformatted_code, ["test\n\ntest"] }] == SimpleMarkdown.Parser.parse("```\ntest\n\ntest```", context.rules)
        assert [{ :preformatted_code, ["    test"], :test }] == SimpleMarkdown.Parser.parse("```test\n    test\n```", context.rules)
        assert [{ :preformatted_code, ["\ttest"], :test }] == SimpleMarkdown.Parser.parse("```test\n\ttest```", context.rules)
        assert [{ :preformatted_code, ["    test"] }] == SimpleMarkdown.Parser.parse("```te st\n    test\n```", context.rules)

        assert [{ :preformatted_code, ["test"] }] == SimpleMarkdown.Parser.parse("    test")
        assert [{ :preformatted_code, ["test\n    test"] }] == SimpleMarkdown.Parser.parse("    test\n        test")
        assert [{ :preformatted_code, ["test\n\ttest"] }] == SimpleMarkdown.Parser.parse("\ttest\n\t\ttest")
        assert [{ :preformatted_code, ["_test_"] }] == SimpleMarkdown.Parser.parse("    _test_")
        assert [{ :preformatted_code, ["_test_\n    test"] }] == SimpleMarkdown.Parser.parse("    _test_\n        test")
        assert [{ :preformatted_code, ["_test_\n\ttest"] }] == SimpleMarkdown.Parser.parse("\t_test_\n\t\ttest")
        assert [{ :preformatted_code, ["test\n\ntest"] }] == SimpleMarkdown.Parser.parse("\ttest\n\t\n\ttest")
        assert [{:paragraph, ["``", { :code, ["test"] }, "``"] }] == SimpleMarkdown.Parser.parse("```test```")
        assert [{ :preformatted_code, ["test\n\ntest"] }] == SimpleMarkdown.Parser.parse("```\ntest\n\ntest```")
        assert [{ :preformatted_code, ["    test"], :test }] == SimpleMarkdown.Parser.parse("```test\n    test\n```")
        assert [{ :preformatted_code, ["\ttest"], :test }] == SimpleMarkdown.Parser.parse("```test\n\ttest```")
        assert [{ :preformatted_code, ["_test_"] }] == SimpleMarkdown.Parser.parse("```\n_test_```")
        assert [{ :preformatted_code, ["_test_\n    test"] }] == SimpleMarkdown.Parser.parse("```\n_test_\n    test\n```")
        assert [{ :preformatted_code, ["_test_\n\ttest"] }] == SimpleMarkdown.Parser.parse("```\n_test_\n\ttest```")
        assert [{ :preformatted_code, ["    test"], :_test_ }] == SimpleMarkdown.Parser.parse("```_test_\n    test\n```")
        assert [{ :preformatted_code, ["    tést"], :_test_ }] == SimpleMarkdown.Parser.parse("```_test_\n    tést\n```")

        code = """
            one

            two
                three
            four
        """ |> String.trim_trailing

        assert [{ :preformatted_code, ["one\n\ntwo\n    three\nfour"] }] == SimpleMarkdown.Parser.parse(code, context.rules)
        assert [{ :preformatted_code, ["one\n\ntwo\n    three\nfour"] }] == SimpleMarkdown.Parser.parse(code)

        code = """
        ```
        one

        two
            three
        four
        ```
        """ |> String.trim_trailing

        assert [{ :preformatted_code, ["one\n\ntwo\n    three\nfour"] }] == SimpleMarkdown.Parser.parse(code, context.rules)
        assert [{ :preformatted_code, ["one\n\ntwo\n    three\nfour"] }] == SimpleMarkdown.Parser.parse(code)
    end

    @tag attribute: :paragraph
    test "parsing paragraph", context do
        assert [{ :paragraph, ["test"] }] == SimpleMarkdown.Parser.parse("test", context.rules)
        assert [{ :paragraph, ["test test"] }] == SimpleMarkdown.Parser.parse("test test", context.rules)
        assert [{ :paragraph, ["test\ntest"] }] == SimpleMarkdown.Parser.parse("test\ntest", context.rules)
        assert [{ :paragraph, ["test\n\n"] }, { :paragraph, ["test"] }] == SimpleMarkdown.Parser.parse("test\n\ntest", context.rules)

        assert [{ :paragraph, ["test"] }] == SimpleMarkdown.Parser.parse("test")
        assert [{ :paragraph, ["test test"] }] == SimpleMarkdown.Parser.parse("test test")
        assert [{ :paragraph, ["test", "test"] }] == SimpleMarkdown.Parser.parse("test\ntest")
        assert [{ :paragraph, ["test"] }, { :paragraph, ["test"] }] == SimpleMarkdown.Parser.parse("test\n\ntest")
        assert [{ :paragraph, ["tést"] }, { :paragraph, ["test"] }] == SimpleMarkdown.Parser.parse("tést\n\ntest")
    end

    @tag attribute: :blockquote
    test "parsing blockquote", context do
        assert [{ :blockquote, ["test"] }] == SimpleMarkdown.Parser.parse("> test", context.rules)
        assert [{ :blockquote, ["test"] }, "\n"] == SimpleMarkdown.Parser.parse("> test\n", context.rules)
        assert [{ :blockquote, ["test\nstuff"] }] == SimpleMarkdown.Parser.parse("> test\n> stuff", context.rules)
        assert [{ :blockquote, ["test\n stuff"] }] == SimpleMarkdown.Parser.parse("> test\n stuff", context.rules)
        assert [{ :blockquote, ["test\n", { :blockquote, ["stuff"] }], }] == SimpleMarkdown.Parser.parse("> test\n> > stuff", context.rules)
        assert [{ :blockquote, ["test\n", { :blockquote, ["stuff"] }, "\nblah"], }] == SimpleMarkdown.Parser.parse("> test\n> > stuff\n> blah", context.rules)
        assert [{ :blockquote, ["test\n", { :blockquote, ["stuff\nagain"] }, "\nblah"], }] == SimpleMarkdown.Parser.parse("> test\n> > stuff\n> > again\n> blah", context.rules)

        assert [{ :paragraph, [{ :blockquote, ["test"] }] }] == SimpleMarkdown.Parser.parse("> test")
        assert [{ :paragraph, [{ :blockquote, ["test"] }] }] == SimpleMarkdown.Parser.parse("> test\n")
        assert [{ :paragraph, [{ :blockquote, ["test", "stuff"] }] }] == SimpleMarkdown.Parser.parse("> test\n> stuff")
        assert [{ :paragraph, [{ :blockquote, ["test", " stuff"] }] }] == SimpleMarkdown.Parser.parse("> test\n stuff")
        assert [{ :paragraph, [{ :blockquote, ["test", { :blockquote, ["stuff"] }], }] }] == SimpleMarkdown.Parser.parse("> test\n> > stuff")
        assert [{ :paragraph, [{ :blockquote, ["test", { :blockquote, ["stuff"] }, "blah"], }] }] == SimpleMarkdown.Parser.parse("> test\n> > stuff\n> blah")
        assert [{ :paragraph, [{ :blockquote, ["test", { :blockquote, ["stuff", "again"] }, "blah"], }] }] == SimpleMarkdown.Parser.parse("> test\n> > stuff\n> > again\n> blah")
        assert [{ :paragraph, [{ :blockquote, ["tést", { :blockquote, ["stuff", "again"] }, "blah"], }] }] == SimpleMarkdown.Parser.parse("> tést\n> > stuff\n> > again\n> blah")
    end

    @tag attribute: :link
    test "parsing link", context do
        assert [{ :link, ["test"], "example.com" }] == SimpleMarkdown.Parser.parse("[test](example.com)", context.rules)
        assert [{ :link, ["tést"], "éxample.com" }] == SimpleMarkdown.Parser.parse("[tést](éxample.com)", context.rules)

        assert [{ :paragraph, [{ :link, ["test"], "example.com" }] }] == SimpleMarkdown.Parser.parse("[test](example.com)")
        assert [{ :paragraph, [{ :link, [{ :emphasis, ["test"], :regular }], "example.com" }] }] == SimpleMarkdown.Parser.parse("[_test_](example.com)")
        assert [{ :paragraph, [{ :link, ["foo"], "example.com/foo" }, " ", { :link, ["bar"], "example.com/bar" }] }] == SimpleMarkdown.Parser.parse("[foo](example.com/foo) [bar](example.com/bar)")
        assert [{ :paragraph, [{ :link, [{ :image, ["test"], "example.com/image.jpg" }], "example.com" }] }] == SimpleMarkdown.Parser.parse("[![test](example.com/image.jpg)](example.com)")
    end

    @tag attribute: :image
    test "parsing image", context do
        assert [{ :image, ["test"], "example.com/image.jpg" }] == SimpleMarkdown.Parser.parse("![test](example.com/image.jpg)", context.rules)
        assert [{ :image, ["tést"], "éxample.com/image.jpg" }] == SimpleMarkdown.Parser.parse("![tést](éxample.com/image.jpg)", context.rules)

        assert [{ :paragraph, [{ :image, ["test"], "example.com/image.jpg" }] }] == SimpleMarkdown.Parser.parse("![test](example.com/image.jpg)")
        assert [{ :paragraph, [{ :image, [{ :emphasis, ["test"], :regular }], "example.com/image.jpg" }] }] == SimpleMarkdown.Parser.parse("![_test_](example.com/image.jpg)")
    end

    @tag attribute: :code
    test "parsing code", context do
        assert [{ :code, ["test"] }] == SimpleMarkdown.Parser.parse("`test`", context.rules)
        assert [{ :code, ["tést"] }] == SimpleMarkdown.Parser.parse("`tést`", context.rules)

        assert [{ :paragraph, [{ :code, ["test"] }] }] == SimpleMarkdown.Parser.parse("`test`")
        assert [{ :paragraph, [{ :code, ["_test_"] }] }] == SimpleMarkdown.Parser.parse("`_test_`")
    end

    test "parsing examples" do
        input = """
        Heading
        =======

        Sub-heading
        -----------

        ###Another deeper heading

        Paragraphs are separated
        by a blank line.

        Two spaces at the end of a line leave a#{"  "}
        line break.

        Text attributes _italic_,#{" "}
        **bold**, `monospace`.

        Bullet list:

        * apples
        * oranges
        * pears

        Numbered list:

        1. apples
        2. oranges
        3. pears

        A [link](http://example.com).
        """

        assert [
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
        ] == SimpleMarkdown.Parser.parse(input |> String.trim)
    end
end
