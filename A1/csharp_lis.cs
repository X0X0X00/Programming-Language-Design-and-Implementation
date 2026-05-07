// import
using System;
using System.Collections.Generic;
using System.Linq;


/*
Example: input = "3 1 4 1 5"

Step-by-step DP calculation:
    i=0: dp[0]=1 (list: [3])
    i=1: dp[1]=1 (list: [1])
    i=2: dp[2]=2 (list: [3→4])
    i=3: dp[3]=1 (list: [1])
    i=4: dp[4]=3 (list: [3→4→5])

Final: LIS = [3, 4, 5] with length 3

Time complexity: O(n³) Space complexity O(n²)
*/


/*
Type<Generic_Parameter> Variable_Name = Value;

List<int> Name = new List<int>();
- To declare a list of integers.

List<int> Name = value;
- To assign a list to another list.


String.IsNullOrEmpty(s);
- To check if the input string is null or empty.

Where(s => !string.IsNullOrWhiteSpace(s));
- To filter out any empty or whitespace-only strings from the input.

Select(int.Parse);
- To convert each string in the filtered collection to an integer.

a.ToArray();
- To convert the IEnumerable<int> collection to an array of integers.

a.Length;
- To get the number of elements in the array.

List<int> dp = new List<int>[n];
- To create an array of lists, where each list will store the longest increasing subsequence ending at that index.

List<int> = new List<int>();
- To initialize a new list.

List<int>.Add(value);
- To append a value to the end of a list.

*/



class LIS {
    static void Main() {
        // Input
        string input = Console.ReadLine(); // read input from terminal
        if (string.IsNullOrEmpty(input)) { // if input is empty, exit
            return; 
        }
        

        // Parse input
        string[] split_inputs = input.Split(' '); // 3 1 4 1 5 -> ["3", "1", "4", "1", "5"]
        var Content = split_inputs.Where(input_string => !string.IsNullOrWhiteSpace(input_string)); 
        var numbers = Content.Select(int.Parse); // ["3", "1", "4", "1", "5"] -> [3, 1, 4, 1, 5]
        int[] arr = numbers.ToArray(); // [3, 1, 4, 1, 5] -> array [3, 1, 4, 1, 5]
        int n = arr.Length; // n = 5
        if (n == 0) { // if array is empty, exit
            return;
        }
        

        // init DP arrays
        List<int>[] dp = new List<int>[n]; // dp[i] = length of LIS ending at index i
        for (int i = 0; i < n; i++) {
            dp[i] = new List<int>();
            dp[i].Add(arr[i]); 
        }
        
        // DP
        for (int i = 1; i < n; i++) {
            for (int j = 0; j < i; j++) {
                if (arr[i] > arr[j] && dp[j].Count + 1 > dp[i].Count) {
                    dp[i] = new List<int>(dp[j]); // copy the subsequence ending at j
                    dp[i].Add(arr[i]); // append arr[i]
                }
            }
        }

        // Find the longest subsequence
        List<int> longest = dp[0];
        for (int i = 1; i < n; i++) {
            if (dp[i].Count > longest.Count) {
                longest = dp[i];
            }
        }
        Console.WriteLine(string.Join(" ", longest));
    }
}