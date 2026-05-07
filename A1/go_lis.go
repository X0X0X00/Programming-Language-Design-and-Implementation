package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

//Time Complexity: O(nlogn)
//Space Complexity: O(n)
func longestIncreasingSubsequence(nums []int) []int {
	n := len(nums)
	if n == 0 {
		return []int{}
	}

	// tails[p]  = smallest possible tail value of any increasing subsequence of length p+1
	tails := make([]int, n)

	// tailsIdx[p] = index in nums where that tails[p] occurs (for reconstruction)
	tailsIdx := make([]int, n)

	// prev[i] = predecessor index in nums for element i in the chosen LIS (-1 if none)
	prev := make([]int, n)
	for i := range prev {
		prev[i] = -1 // no predecessor by default
	}

	length := 0 // current LIS length
	for i := 0; i < n; i++ {
		x := nums[i]

		// Binary search: first position p with tails[p] >= x (lower_bound)
		low, high := 0, length
		for low < high {
			mid := (low + high) / 2
			if tails[mid] < x {
				low = mid + 1
			} else {
				high = mid
			}
		}
		p := low

		if p > 0 {
			prev[i] = tailsIdx[p-1]
		}

		// Update best tail for length p+1
		tails[p] = x
		tailsIdx[p] = i

		if p == length {
			length++ 
		}
	}

	// Reconstruct LIS
	res := make([]int, length)
	k := tailsIdx[length-1]
	for t := length - 1; t >= 0; t-- {
		res[t] = nums[k]
		k = prev[k]
	}
	return res
}

func main() {
	br := bufio.NewReader(os.Stdin)
	line, _ := br.ReadString('\n')
	line = strings.TrimSpace(line)
	if line == "" {
		fmt.Println()
		return
	}

	token := strings.Fields(line)
	nums := make([]int, len(token))
	for i := 0; i < len(token); i++ {
		val, _ := strconv.Atoi(token[i])
		nums[i] = val
	}

	lis := longestIncreasingSubsequence(nums)
	for i := 0; i < len(lis); i++ {
		if i > 0 {
			fmt.Print(" ")
		}
		fmt.Print(lis[i])
	}
	fmt.Println()
}
