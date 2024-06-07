module NumberToRupees
  WORDS = { 0 => 'zero', 1 => 'One', 2 => 'Two', 3 => 'Three', 4 => 'Four', 5 => 'Five', 6 => 'six', 7 => 'seven', 8 => 'Eight', 9 => 'Nine',
            10 => 'Ten', 11 => 'Eleven', 12 => 'Twelve', 13 => 'Thirteen', 14 => 'Fourteen', 15 => 'Fifteen', 16 => 'Sixteen', 17 => 'Seventeen', 18 => 'Eighteen', 19 => 'Nineteen', 20 => 'Twenty', 30 => 'Thirty', 40 => 'Forty', 50 => 'Fifty', 60 => 'Sixty', 70 => 'Seventy', 80 => 'Eighty', 90 => 'Ninty' }
  SUFIXES = { 0 => 'hundred & ', 1 => ' Crore, ', 2 => ' Lakh, ', 3 => ' Thousand, ', 4 => ' Hundred, ' } # 5=>''
  module Integer
    def self.included(recipient)
      recipient.extend(ClassMethods)
      recipient.class_eval do
        include InstanceMethods
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def rupees
        result = self >= 0 ? '' : '(-) '
        num = abs

        # I would prefer One Rupee, insead of One Rupees
        return 'One Rupee.' if num == 1
        if num < 1000000000
          if num > 99
            num.to_s.rjust(11, '0').insert(-4, '0').scan(/../).each_with_index { |x, i| result += def_calc(x, i) }
          else
            result = spell_two_digits(num)
          end
          result.sub(/,\s$/, '')
        else
          large_digit_convertor(num)
        end
      end

      protected

      def def_calc(x, i)
        str = proc_unit(x)
        return '' if str.length == 0

        "#{str}#{SUFIXES[i]}"
      end

      def proc_unit(x)
        return '' unless x.to_i > 0

        spell_two_digits(x.to_i)
      end

      def spell_two_digits(x)
        return WORDS[x] if WORDS[x]

        r, f = x.divmod(10)
        f.zero? ? "#{WORDS[r*10]}" : "#{WORDS[r*10]} #{WORDS[f]}"
      end

      def large_digit_convertor(num)
        crores = num / 10**7
        remaining = num % 10**7
        lakhs = remaining / 10**5
        remaining = remaining % 10**5
        thousands = remaining / 10**3
        remaining = remaining % 10**3
        hundreds = remaining / 10**2
        remaining = remaining % 10**2

        crore_text = crores > 0 ? "#{convert_to_words(crores)} Crore" : ""
        lakh_text = lakhs > 0 ? "#{convert_to_words(lakhs)} Lakh" : ""
        thousand_text = thousands > 0 ? "#{convert_to_words(thousands)} Thousand" : ""
        hundred_text = hundreds > 0 ? "#{convert_to_words(hundreds)} Hundred" : ""
        remaining_text = remaining > 0 ? "#{convert_to_words(remaining)}" : ""

        words = [crore_text, lakh_text, thousand_text, hundred_text, remaining_text].reject(&:empty?).join(", ")
        return (words + " Rupees")
      end

      def convert_to_words(num)
        ones = %w[Zero One Two Three Four Five Six Seven Eight Nine]
        teens = %w[Ten Eleven Twelve Thirteen Fourteen Fifteen Sixteen Seventeen Eighteen Nineteen]
        tens = %w[Zero Ten Twenty Thirty Forty Fifty Sixty Seventy Eighty Ninety]
      
        if num < 10
          ones[num]
        elsif num < 20
          teens[num - 10]
        elsif num < 100
          tens_place = num / 10
          ones_place = num % 10
          ones_place == 0 ? tens[tens_place] : "#{tens[tens_place]} #{ones[ones_place]}"
        elsif num < 1000
          hundreds_place = num / 100
          remainder = num % 100
          remainder_text = remainder > 0 ? " #{convert_to_words(remainder)}" : ""
          "#{ones[hundreds_place]} Hundred#{remainder_text}"
        end
      end
    end
  end
end
Integer.include NumberToRupees::Integer
