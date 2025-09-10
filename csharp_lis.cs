// import
using System;
using System.Linq;


/*
Example: input = "3 1 4 1 5"

Step-by-step DP calculation:
    i=0: dp[0]=1 (list: [3])
    i=1: dp[1]=1 (list: [1])
    i=2: dp[2]=2 (list: [1→4])
    i=3: dp[3]=1 (list: [1])
    i=4: dp[4]=3 (list: [1→4→5])

Final: LIS = [1, 4, 5] with length 3

Time complexity: O(n²) Space complexity O(n)
*/



class LIS {
    static void Main() {
        // Input
        string input = Console.ReadLine();
        if (string.IsNullOrEmpty(input)) {
            return; // return empty input
        }
        
    
        // Split input string by spaces
        string[] inputs_parts = input.Split(' ');

        // Filter out empty or whitespace strings
        var nonEmptyParts = inputs_parts.Where(s => !string.IsNullOrWhiteSpace(s));
        var numbers = nonEmptyParts.Select(int.Parse);
        int[] arr = numbers.ToArray();
        int n = arr.Length;
        if (n == 0) {
            return;
        }
        
        // init DP arrays
        int[] dp = new int[n];
        int[] parent_arr = new int[n];
        
        for (int i = 0; i < n; i++) {
            dp[i] = 1;
            parent_arr[i] = -1;
        }
        
        int maxLength = 1;
        int maxEndIndex = 0;
        
        // DP
        for (int i = 1; i < n; i++) {
            for (int j = 0; j < i; j++) {
                if (arr[j] < arr[i] && dp[j] + 1 > dp[i]) {
                    dp[i] = dp[j] + 1;
                    parent_arr[i] = j;
                }
            }
            
            if (dp[i] > maxLength) {
                maxLength = dp[i];
                maxEndIndex = i;
            }
        }

        // Rebuilt the lis
        int[] result = new int[maxLength];
        int temp = maxEndIndex;
        int index = maxLength - 1;

        while (temp != -1) {
            result[index--] = arr[temp];
            temp = parent_arr[temp];
        }
        
        // Output
        Console.WriteLine(string.Join(" ", result));
    }
}