require 'securerandom'

module External

  class Random

    def sample(size)
      # Eg size==6 ==> sample from [0,1,2,3,4,5]
      ::Random.rand(size) # Careful to avoid recursion
    end

    def alphanumeric(size)
      # Eg size==6 ==> 6 samples from [0-9A-Za-z]
      ::SecureRandom.alphanumeric(size)
    end

  end

end