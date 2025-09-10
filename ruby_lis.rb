# Time Complexity: O(nlogn)
# Space Complexity: O(n)

# Read one line from stdin
line = STDIN.gets
if line.nil? || line.strip.empty?
  puts
  exit
end

token = line.strip.split
nums  = token.map!(&:to_i)
n     = nums.length
if n == 0
  puts
  exit
end

# tails[p]  = smallest possible tail value of any increasing subsequence of length p+1
tails    = []
# tailsIdx[p] = index in nums where that tails[p] occurs (for reconstruction)
tailsIdx = []     
# no predecessor by default    
prev     = Array.new(n, -1)

length = 0
(0...n).each do |i|
  x = nums[i]
  # Binary search: first position p with tails[p] >= x (lower_bound)
  low = 0
  high = length
  while low < high
    mid = (low + high) / 2
    if tails[mid] < x
      low = mid + 1
    else
      high = mid
    end
  end
  p = low

  prev[i] = tailsIdx[p - 1] if p > 0

  # Update best tail for length p+1
  tails[p]    = x
  tailsIdx[p] = i

  length += 1 if p == length
end

# Reconstruct LIS
res = Array.new(length)
k = tailsIdx[length - 1]
(length - 1).downto(0) do |t|
  res[t] = nums[k]
  k = prev[k]
end

puts res.join(" ")
