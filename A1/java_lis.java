import java.io.*;
import java.util.*;

//Time Complexity: O(nlogn)
//Space Complexity: O(n)

public class java_lis {
    public static int[] longestIncreasingSubsequence(int[] nums) {
        int n = nums.length;
        if (nums.length == 0) return new int[0];

        // tails[p]  = smallest possible tail value of any increasing subsequence of length p+1
        int[] tails = new int[nums.length];

        // tailsIdx[p] = index in nums where that tails[p] occurs (for reconstruction)
        int[] tailsIdx = new int[nums.length];

        // prev[i] = predecessor index in nums for element i in the chosen LIS (-1 if none)
        int[] prev = new int[nums.length];
        Arrays.fill(prev, -1);  // no predecessor by default


        int len = 0;
        for (int i = 0; i < nums.length; i++) {
            int x = nums[i];

            // Binary search: first position p with tails[p] >= x (lower_bound)
            int low = 0, high = len;
            while (low < high) {
                int mid = (low + high) / 2;
                if (tails[mid] < x) low = mid + 1;
                else high = mid;
            }
            int p = low;
            if (p > 0) prev[i] = tailsIdx[p - 1];
            // Update best tail for length p+1
            tails[p] = x;
            tailsIdx[p] = i;
            if (p == len) len++;
        }

        // Reconstruct LIS
        int[] res = new int[len];
        int k = tailsIdx[len - 1];
        for (int t = len - 1; t >= 0; t--) {
            res[t] = nums[k];
            k = prev[k];
        }
        return res;
    }

    public static void main(String[] args) throws Exception {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        String line = br.readLine();                
        if (line == null || line.trim().isEmpty()) { System.out.println(); return; }
        String[] token = line.trim().split("\\s+");
        int[] nums = new int[token.length];
        for (int i = 0; i < token.length; i++) nums[i] = Integer.parseInt(token[i]);

        int[] lis = longestIncreasingSubsequence(nums);
        for (int i = 0; i < lis.length; i++) {
            if (i > 0) System.out.print(" ");
            System.out.print(lis[i]);
        }
        System.out.println();
    }

}
