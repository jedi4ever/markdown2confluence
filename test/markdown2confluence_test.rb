require 'test_helper'

class Markdown2ConfluenceTest < ActiveSupport::TestCase
  test "header 1" do
    assert_equal "h1. Hello\n", confluence("# Hello")
  end

  test "heading 2" do
    assert_equal "h2. Hello\n", confluence("## Hello")
  end

  test "heading 3" do
    assert_equal "h3. Hello\n", confluence("### Hello")
  end

  test "heading 4" do
    assert_equal "h4. Hello\n", confluence("#### Hello")
  end

  # TODO - remove these extra spaces after - symbol
  test "lists" do
    list =  "* this\n"
    list << "* is\n"
    list << "* a\n"
    list << "* list\n"
    confluence_list = list.gsub("*", "-   ").gsub("\n", "\n\n")
    assert_equal confluence_list, confluence(list)
  end

  # TODO - two trailing newlines
  test "strong text" do
    assert_equal "*strong*\n\n", confluence("**strong**")
  end

  # TODO - two trailing newlines
  test "italics text" do
    assert_equal "_some text here_\n\n", confluence("*some text here*")
  end

  # TODO - two trailing newlines
  test "inline code" do
    assert_equal "{{hello world}}\n\n", confluence("`hello world`")
  end

  test "block of code" do
    code = "    this is code\n"
    assert_equal "{code}this is code\n{code}\n", confluence(code)
  end

  # TODO - two trailing newlines
  # FIX - failing test
  test "strikethrough" do
    assert_equal "-strikethrough text-\n\n", confluence("~~strikethrough text~~")
  end

  # FIX - failing test
  test "quote" do
    assert_equal "bq. this is a quote", confluence("> this is a quote")
  end

private

  def confluence(text)
    Kramdown::Document.new(text).to_confluence
  end
end
