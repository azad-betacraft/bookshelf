class IsbnValidator
  def self.valid?(isbn)
    return false unless isbn.match?(/\A\d{13}\z/)

    digits = isbn.chars.map(&:to_i)
    sum = digits.each_with_index.sum do |digit, index|
      index.even? ? digit : digit * 3
    end
    (sum % 10).zero?
  end
end
