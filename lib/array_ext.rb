class Array
  def modes(find_all = true)
    histogram = self.inject(Hash.new(0)) { |h, n| h[n] += 1; h }
    m = nil
    histogram.each_pair do |item, times|
      m << item if m && times == m[0] and find_all
      m = [times, item] if (!m && times>1) or (m && times > m[0])
    end

    if m.nil?
      find_all ? self : self.first
    else
      m[1...m.size]
    end
  end
end
