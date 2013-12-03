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
        @table_header = false
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
        "#{' '*indent}#{inner(el, indent)}\n"
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
        inner(el,indent)
      end

      alias :convert_ol :convert_ul
      alias :convert_dl :convert_ul

      def convert_li(el, indent)
        "#{'*'*(indent/2)}#{inner(el, 0)}"
      end

      alias :convert_dd :convert_li

      def convert_dt(el, indent)
        inner(el, indent)
      end

      def convert_html_element(el, indent)
        markup=case el.value
               when "iframe" then "{iframe:src=#{el.attr["src"]}}"
               when "pre" then
                 if inner(el,indent).strip.match(/\n/)
                   "{code}#{inner(el,indent)}{code}"
                 else
                   "{{#{inner(el,indent).strip}}}"
                 end
               else inner(el, indent)
               end
      end

      def convert_xml_comment(el, indent)
        ""
      end
      alias :convert_xml_pi :convert_xml_comment

      def convert_table(el, indent)
        "#{inner(el, indent)}"
      end

      def convert_thead(el, indent)
        @table_header = true
        "#{inner(el, indent)}"
      end
      
      def convert_tbody(el, indent)
        @table_header = false
        "#{inner(el, indent)}"
      end
      alias :convert_tfoot :convert_tbody

      def convert_tr(el, indent)
        if @table_header
          "||#{inner(el, indent)}\n"
        else 
          "|#{inner(el, indent)}\n"
        end
      end
      
      def convert_td(el, indent)
        if @table_header
          " #{inner(el, indent)} ||"
        else 
          " #{inner(el, indent)} |"
        end
      end

      def convert_empty(el, indent)
        ""
      end

      def convert_comment(el, indent)
        inner(el, indent)
      end

      def convert_br(el, indent)
        "\\"
      end

      def convert_a(el, indent)
        text   = inner(el,indent)
        link   = el.attr['href']
        "[#{text+'|' unless text.nil?}#{link}]"
      end

      def convert_img(el, indent)
        src = el.attr['src']
        alt = el.attr['alt']
        alt.to_s.empty? ? "!#{src}!" : "!#{src}|alt=#{alt}!"
      end

      def convert_codeblock(el, indent)
        "{code}#{el.value}{code}\n"
      end

      def convert_codespan(el, indent)
        if  el.value.strip.match(/\n/)
          "{code}#{el.value}{code}\n"
        else
          "{{#{el.value.strip}}}"
        end
      end

      def convert_footnote(el, indent)
        inner(el, indent)
      end

      def convert_raw(el, indent)
        inner(el, indent)
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
        "'"
      end

      def convert_math(el, indent)
        inner(el,indent)
      end

      def convert_abbreviation(el, indent)
        inner(el,indent)
      end

      def convert_root(el, indent)
        handle_iframes(inner(el, indent))
      end

      def handle_iframes(text)
        markup=text.gsub(/<iframe.*iframe>/) { |match| 
          doc =Nokogiri::HTML::DocumentFragment.parse(match)
          element=doc.search('iframe').first
          attributes=element.attributes.map{ |at| "#{at[1].name}=#{at[1].value}"}
          "{iframe:#{attributes.join('|')}}#{element.text}{iframe}"
        }
        return markup
      end

    end

  end
end
