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

  test "unordered list" do
    list =  "* this\n"
    list << "* is\n"
    list << "* a\n"
    list << "* list\n"
    confluence_list = list.gsub("*", "-   ")
    assert_equal confluence_list, confluence(list)
  end

  # FIX - failing test
  test "ordered list" do
    assert_equal "1. this\n2. is\n3. a\n4. list\n", confluence("1. this\n2. is\n3. a\n4. list\n" )
  end

  test "strong text" do
    assert_equal "*strong*\n", confluence("**strong**")
  end

  test "italics text" do
    assert_equal "_some text here_\n", confluence("*some text here*")
  end

  test "inline code" do
    assert_equal "{{hello world}}\n", confluence("`hello world`")
  end

  test "block of code" do
    code = "    this is code\n"
    assert_equal "{code}this is code\n{code}\n", confluence(code)
  end

  # FIX - failing test
  test "strikethrough" do
    assert_equal "-strikethrough text-\n", confluence("~~strikethrough text~~")
  end

  # FIX - failing test
  test "quote" do
    assert_equal "bq. this is a quote", confluence("> this is a quote")
  end

  test "hyperlink" do
    assert_equal "[github|http://github.com]\n", confluence("[github](http://github.com)")
  end

  test "image link without alt" do
    assert_equal "!http://github.com/logo.png!\n", confluence("![](http://github.com/logo.png)")
  end

  test "image link with alt" do
    assert_equal "!http://github.com/logo.png|alt=logo!\n", confluence("![logo](http://github.com/logo.png)")
  end

  test "horizontal rule" do
    assert_equal "----\n", confluence("* * *")
    assert_equal "----\n", confluence("***")
    assert_equal "----\n", confluence("*****")
    assert_equal "----\n", confluence("---------------------------------------")
  end

private

  def confluence(text)
    Kramdown::Document.new(text).to_confluence
  end
end
