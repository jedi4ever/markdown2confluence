# -*- coding: utf-8 -*-
#
#--
# This file is part of based on kramdown.Confluence convertor
#
# kramdown is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++
#

require 'rexml/parsers/baseparser'

module Kramdown

  module Converter

    # Converts a Kramdown::Document to Confluence ML
    #
    # You can customize the Confluence converter by sub-classing it and overriding the +convert_NAME+
    # methods. Each such method takes the following parameters:
    #
    # [+el+] The element of type +NAME+ to be converted.
    #
    # [+indent+] A number representing the current amount of spaces for indent (only used for
    #            block-level elements).
    #
    # The return value of such a method has to be a string containing the element +el+ formatted as
    # Confluence element.
    class Confluence < Base

      # The amount of indentation used when nesting Confluence tags.
      attr_accessor :indent

      # Initialize the Confluence converter with the given Kramdown document +doc+.
      def initialize(root, options)
        super
        @indent = 2
        @stack = []
      end

      # The mapping of element type to conversion method.
      DISPATCHER = Hash.new {|h,k| h[k] = "convert_#{k}"}

      # Dispatch the conversion of the element +el+ to a +convert_TYPE+ method using the +type+ of
      # the element.
      def convert(el, indent = -@indent)
        send(DISPATCHER[el.type], el, indent)
      end

      # Return the converted content of the children of +el+ as a string. The parameter +indent+ has
      # to be the amount of indentation used for the element +el+.
      #
      # Pushes +el+ onto the @stack before converting the child elements and pops it from the stack
      # afterwards.
      def inner(el, indent)
        result = ''
        indent += @indent
        @stack.push(el)
        el.children.each do |inner_el|
          result << send(DISPATCHER[inner_el.type], inner_el, indent)
        end
        @stack.pop
        result
      end

      def convert_blank(el, indent)
        "\n"
      end

      def convert_text(el, indent)
        el.value
      end

      def convert_p(el, indent)
          "#{' '*indent}#{inner(el, indent)}\n\n"
      end

      def convert_codeblock(el, indent)
          "#{' '*indent}{code}#{inner(el, ident)}{code}\n"
      end

      def convert_blockquote(el, indent)
        "#{' '*indent}bq. #{inner(el, indent)}\n"
      end

      def convert_header(el, indent)
        "h#{el.options[:level]}. #{inner(el, indent)}\n"
      end

      def convert_hr(el, indent)
        "#{' '*indent}----\n"
      end

      def convert_ul(el, indent)
        ""
      end
      alias :convert_ol :convert_ul
      alias :convert_dl :convert_ul

      def convert_li(el, indent)
        "#{'-'*el.options[:level]} #{inner(el, indent)}\n"
      end
      alias :convert_dd :convert_li

      def convert_dt(el, indent)
        "#{' '*indent}<dt#{Confluence_attributes(el.attr)}>#{inner(el, indent)}</dt>\n"
      end

      def convert_html_element(el, indent)
        require 'pp'
        pp el
        inner(el, indent)
      end

      def convert_xml_comment(el, indent)
        ""
      end
      alias :convert_xml_pi :convert_xml_comment

      def convert_table(el, indent)
        "#{' '*indent}<table#{Confluence_attributes(el.attr)}>\n#{inner(el, indent)}#{' '*indent}</table>\n"
      end

      def convert_thead(el, indent)
        "#{' '*indent}<#{el.type}#{Confluence_attributes(el.attr)}>\n#{inner(el, indent)}#{' '*indent}</#{el.type}>\n"
      end
      alias :convert_tbody :convert_thead
      alias :convert_tfoot :convert_thead
      alias :convert_tr  :convert_thead

      def convert_td(el, indent)
        res = inner(el, indent)
        type = (@stack[-2].type == :thead ? :th : :td)
        attr = el.attr
        alignment = @stack[-3].options[:alignment][@stack.last.children.index(el)]
        if alignment != :default
          attr = el.attr.dup
          attr['style'] = (attr.has_key?('style') ? "#{attr['style']}; ": '') << "text-align: #{alignment}"
        end
        "#{' '*indent}<#{type}#{Confluence_attributes(attr)}>#{res.empty? ? entity_to_str(ENTITY_NBSP) : res}</#{type}>\n"
      end

      def convert_comment(el, indent)
      end

      def convert_br(el, indent)
        "\\"
      end

      def convert_a(el, indent)
        text=inner(el,indent)
        link=el.attr['href']
        text="[#{text+'|' unless text.nil?}#{link}]"
        return text
      end

      def convert_img(el, indent)
        "<img#{Html_attributes(el.attr)} />"
      end

      def convert_codespan(el, indent)
        if el.attr['lang'] && HIGHLIGHTING_AVAILABLE
          attr = el.attr.dup
          result = CodeRay.scan(el.value, attr.delete('lang').to_sym).Confluence(:wrap => :span, :css => @options[:coderay_css]).chomp
          "<code#{Confluence_attributes(attr)}>#{result}</code>"
        else
          "<code#{Confluence_attributes(el.attr)}>#{escape_Confluence(el.value)}</code>"
        end
      end

      def convert_footnote(el, indent)
      end

      def convert_raw(el, indent)
          el.value
      end

      def convert_em(el, indent)
        "_#{inner(el, indent)}_"
      end

      def convert_strong(el, indent)
        "*#{inner(el, indent)}*"
      end

      def convert_entity(el, indent)
         inner(el,indent)
      end

      def convert_typographic_sym(el, indent)
         inner(el,indent)
      end

      def convert_smart_quote(el, indent)
         inner(el,indent)
      end

      def convert_math(el, indent)
        block = (el.options[:category] == :block)
        "<script type=\"math/tex#{block ? '; mode=display' : ''}\">#{el.value}</script>#{block ? "\n" : ''}"
      end

      def convert_abbreviation(el, indent)
        title = @root.options[:abbrev_defs][el.value]
        "<abbr#{!title.empty? ? " title=\"#{title}\"" : ''}>#{el.value}</abbr>"
      end

      def convert_root(el, indent)
        result = inner(el, indent)
        result
      end

    end

  end
end
