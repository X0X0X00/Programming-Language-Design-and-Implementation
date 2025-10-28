import bisect
import sys


"""
    [3, 1, 4, 1, 5]
    dp = [3] [1] [4] [1] [5]
    
    i = 0 arr[0] = 3 -> dp[0] = [3]
    i = 1 arr[1] = 1 -> dp[1] = [1] (1 < 3)
    i = 2 arr[2] = 4 -> dp[2] = [3, 4] (4 > 3)
    i = 3 arr[3] = 1 -> dp[3] = [1] (1 < 3)
    i = 4 arr[4] = 5 -> dp[4] = [3, 4, 5] (5 > 4)

    Time complexity: O(n³) Space complexity: O(n²)
    """


def lis(sequence):
    
    n = len(sequence)
    dp = []

    for i in sequence:
        dp.append([i])

    
    for i in range(n):
        for j in range(i):
            if sequence[j] < sequence[i] and len(dp[j]) + 1 > len(dp[i]):
                dp[i] = dp[j] + [sequence[i]]
                

    return max(dp, key = len)



# Input + Output
if __name__ == "__main__":
      # Sample Inputs
      test1 = [19, 3, 11, 7, 15, 12, 4, 12, 8, 16]
      test2 = [3, 1, 4, 1, 5]
      test3 = [85, 42, 173, 91, 28, 156, 67, 234, 12, 189, 45, 278, 103, 56, 219, 134, 87, 301, 23, 167, 98, 245, 71, 312, 145, 39, 267, 112, 78, 223, 156, 89, 334, 201, 45, 289, 123, 67, 256,
  178, 94, 345, 23, 198, 112, 267, 145, 78, 312, 189, 234, 356, 67, 289, 134, 401, 223, 89, 367, 245, 178, 412, 301, 156, 423, 278, 345, 189, 434, 367, 223, 445, 389, 267, 456, 312, 401, 234,
  467, 345, 278, 478, 423, 189, 489, 401, 356, 490, 445, 367, 501, 478, 423, 512, 489, 456, 523, 501, 490, 534]

      print(f"Input: {test1}")
      print(f"LIS: {lis(test1)}")
      print()

    #   print(f"Input: {test2}")
    #   print(f"LIS: {lis(test2)}")
    #   print()

    #   print(f"Input: {test3}")
    #   print(f"LIS: {lis(test3)}")