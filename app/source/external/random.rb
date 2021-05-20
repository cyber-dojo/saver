module External

  class Random

    def sample(size)
      # Eg size=6 ==> sample from [0,1,2,3,4,5]
      ::Random.rand(size) # Careful to avoid recursion
    end

  end

end