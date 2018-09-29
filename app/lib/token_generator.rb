module TokenGenerator
  extend self
  
  def generate_token(n = 40)
    chars = 'qwertuiopasdfghjkxcvbnmQWERTUPASDFGHJKLXCVBNM123456789'.split('')
    n.times.map { chars.sample }.join('')
  end
end
