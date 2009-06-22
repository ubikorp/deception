class ShortRound
  URL_CHARS = ('0'..'9').to_a + %w(b c d f g h j k l m n p q r s t v w x y z) + %w(B C D F G H J K L M N P Q R S T V W X Y Z - _)
  URL_BASE  = URL_CHARS.size

  # Hang on lady, we going for a ride! 
  def self.generate(id)
    local_count = id
    result = ''
    while local_count != 0
      rem = local_count % URL_BASE
      local_count = (local_count - rem) / URL_BASE
      result = URL_CHARS[rem] + result
    end

    result
  end
end
