module StubChainMocha
  module Object
    def stub_chain(*methods)
      while methods.length > 1 do
        stubs(methods.shift).returns(self)
      end
      stubs(methods.shift)
    end
  end
end

Object.send(:include, StubChainMocha::Object)
