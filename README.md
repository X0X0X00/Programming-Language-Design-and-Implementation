# CSC 254 Assignment 1 - Longest Increasing Subsequence 

Zhenhao Zhang zzh133@u.rochester.edu 
Zhijie Wang zwang179@u.rochester.edu 


## Description
We are a two-person team, each responsible for four different programming languages.   
**Zhenhao:** Ada, C#, Python, Prolog    | **Zhijie:** Ocaml, Java, Go, Ruby     
Each of us **individually completed our own code implementations**, ensuring independent contributions. However, we **jointly collaborated** to write the **README instructions** on how to run the programs.

**Beyond the Requirement**  
In addition to the required languages, we implemented solutions in **three extra languages**: Java  | Go  | Ruby  
For **extra credit**, we further implemented three **O(n log n) solutions using DP with binary search**.  


## Efficiency
- **Java, Go, Ruby** achieve an efficient **O(n log n)** time complexity. 
- **Ocaml** achieves a moderate **O(n²)** time complexity. 
- **Ada, C#, Python, Prolog** achieve an efficient **O(n³)** time complexity.


## Cmd
### Ada
**File**: `ada_lis.adb`
**Compile and Run**:
```bash
# Compile
gnatmake ada_lis.adb

# 1.Run with pipe input
echo "19 3 11 7 15 12 4 12 8 16" | ./ada_lis

# Output
3 11 15 16

<-------------------------->

# 2.Run interactively
./ada_lis

# Manual input
19 3 11 7 15 12 4 12 8 16

# Output
3 11 15 16
```

### C#
**File**: `csharp_lis.cs`
**Compile and Run**:
```bash
# Compile
mcs csharp_lis.cs

# 1.Run with pipe input
echo "19 3 11 7 15 12 4 12 8 16" | mono csharp_lis.exe

# Output
3 11 15 16

<-------------------------->

# 2. Run interactively
mono csharp_lis.exe

# Manual input
19 3 11 7 15 12 4 12 8 16

# Output
3 11 15 16
```

### Python
**File**: `python_lis.py`
**Run**:
```bash
# 1: Run with built-in test
python3 python_lis.py

# Output
3 11 15 16

<-------------------------->

# 2: Run with pipe input
echo "19 3 11 7 15 12 4 12 8 16" | python3 python_lis.py

# Output
3 11 15 16
```

### Prolog
**File**: `prolog_lis.pl`
**Run**:
```bash
# Interactive input
/usr/staff/bin/prolog -s prolog_lis.pl
# Then at the prompt:
# ?- lis([19, 3, 11, 7, 15, 12, 4, 12, 8, 16], L).
# L = [3, 11, 15, 16].
# -halt. (to exit)
```

### Java
**File:** `java_lis.java`
**Compile & Run**
```bash
# Compile
javac java_lis.java

# Run with a test line (stdin → stdout)
echo "19 3 11 7 15 12 4 12 8 16" | java java_lis
```

### Ruby
**File:** `ruby_lis.rb`
**Run**
```bash
# Run with a test line (stdin → stdout)
echo "19 3 11 7 15 12 4 12 8 16" | ruby ruby_lis.rb
```

### Go
**File:** `go_lis.go`
**Build & Run**
```bash
# Build
go build -o go_lis go_lis.go

# Run with a test line (stdin → stdout)
echo "19 3 11 7 15 12 4 12 8 16" | ./go_lis
```

### OCaml
**File:** `ocaml_lis.ml`
**Compile & Run**
```bash
# Compile (bytecode)
ocamlc -o ocaml_lis ocaml_lis.ml

# Run with a test line (stdin → stdout)
echo "19 3 11 7 15 12 4 12 8 16" | ./ocaml_lis
```



## Programming Experience

**The easiest language:**  
 I find Python the most comfortable to write. First, Python is the language I've worked with most extensively—not only is it required for machine learning and deep learning courses, but I also use it for programming during internships and research. Consequently, my understanding of Python is the strongest. For the LIS task, Python's advantages are particularly evident. First, excluding commits, Python requires the least amount of code. Moreover, Python's built-in `append`, `max`, and `key` functions significantly simplify the implementation.


**The Most Challenging Languages:**  
Ada has been the most troublesome for me. First, Ada don't has syntax highlighting, resulting in plain white text. This makes reading code extremely difficult. Regarding syntax specifically, Ada's syntax is exceptionally verbose. It requiring extensive type declarations and keywords like(I need to defined what are Int_Array, Sequence, and DP_Array). Also, becasue Ada don't have dynamic arrays, I had to define a large static array to hold the input, which is inconvenient and memory wasteful (type Int_Array is array (1 .. 999) of Integer; ). On the other hand, I frequently forget to include begin/end statements. Also, the notes like :, :=, and => are unfamiliar to me. Overall, Ada's syntax is overly complex and cumbersome. The code volume is nearly double that of other languages (Python, Prolog, and C#).


**Speed Differences:**  
With small inputs, nearly all languages complete execution instantly, showing no discernible differences. 


**Personal Preferences:**   
Python is my favorite. It's the mainstream language in AI and machine learning, with nearly all deep learning frameworks and LLM tools offering Python interfaces.


**Language Comparison**
1. Python - O(n³)
  - Language: Simple and direct, using `nums = []`, `append()`, `max(dp, key = len)`. The entire implementation is the most concise among all languages. Using a list of lists to store subsequences, making it easy to append new elements and find the longest subsequence with `max(dp, key = len)`. dp[i] directly stores the longest increasing subsequence ending with nums[i].   
  - Iteration: Very clear, using `for i in range(n):` and `for j in range(i):` to express nested loops.

2. C# - O(n³)
  - Language: Clear structure but verbose, using `List<int> nums = new List<int>();` to create dynamic arrays. Similar to Python. dp[i] directly stores the longest increasing subsequence ending with nums[i].
  - Library: Many tools, using Where() filters empty strings, Select() converts to integers.
  - Iteration: Clear, using `for (int i = 0; i < n; i++)` and `for (int j = 0; j < i; j++)` to express nested loops similar with Java.

3. Ada - O (n³)
  - Language: Extremely verbose, requiring extensive type declarations and keywords like (type Int_Array is array (1 .. 999) of Integer;). No dynamic arrays, so I had to define a large static array to hold the input, which is inconvenient and memory wasteful. Syntax is overly complex and cumbersome, nearly double the code volume of other languages. For the dp array, I need to define the Int_Array first, and then define the sequence, which hold a Elements and Length. Then I can define what is DP_Array. dp[i] stores a sequence, which contains the longest increasing subsequence ending with nums[i]. This is very time consuming and cumbersome. Also the list can not directly append new elements, I need to manually create a new array and copy the old elements to the new array, then add the new element. The rules for Ada is very strict, I often forget to add begin/end statements. Also, the notes like :, :=, and => are unfamiliar to me.
  - Library: Very limited, no built-in functions for this task. For example, no `append()` function, so I had to manually convert the array to a new array with one more element. 
  - Iteration: if defined with `for i in 1 .. n loop` and `for j in 1 .. i - 1 loop`, which is different from other languages. Also, array index starts from 1, not 0. eg: `Position : Natural := 1;`
 

4. Prolog - O(n³)
  - Language: Declarative programming, focusing on defining relationships rather than step-by-step procedures. Many notations are unfamiliar, such as `:-`, `.`, and `!`. It's very confusing when `,` means "and". Many details need to be handled manually, such as recursion and list construction. However, the logic is very clear, I just need to define the relationship between different elements. The most difficult part is i need to think the stop case first, then think about how to build the relationship. For the dp array, I define it as Index-Length-Sequence, where Sequence is a list. dp[i] stores a sequence, which contains the longest increasing subsequence ending with nums[i]. Every time I just need to using the index to find the corresponding sequence.
  - Library: Limited, no built-in functions for this task. For example, no `append()` and `max()` function, so I had to manually define it.
  - Iteration: Uses recursion instead of loops, which is quite different from imperative languages. eg `lis([H|T], L) :- lis(T, L1), ...`

5. OCaml - O(n²)
  - Language: Functional programming, the code is focusing on functions and immutability. Many notations are also unfamiliar, such as `let`, `in`, and `::`. The `let` keyword is used to define variables and functions, and `in` is used to indicate the scope of the variable. `::` is used to construct lists. It has some build in functions, such as `List.map` and `List.fold_left`,
  which can simplify the code. The structure of the dp array is clear, `candidates { length : int; last : int; rev_seq : int list }` list maintains the optimal increasing subsequence ending at each processed array element. dp[i] stores a candidates, which contains the longest increasing subsequence ending with nums[i]. Using extend_best to update the dp array. Over all, with the help of built-in functions, the code is clear and concise.
  - Library: Rich standard library with powerful list and array manipulation functions. like `List.map`, `List.fold_left`, and `Array.make`.
  - Iteration: Uses functions instead of traditional loops eg `List.fold_left (fun acc x -> ...) initial_value list`. This is quite different from other languages.

6. Ruby - O(n log n)
  - Language: The language is very concise and expressive. Very concise, using map!(&:to_i) completes array conversion in a single line. Also, (0...n).each do |i| provides clear loop syntax. Array.new(n, -1) directly creates initialized arrays. On the other hand, Ruby's syntax is quite different from other languages, such as using `do...end` for blocks and `| |` for block parameters. Maintains tails[p] as the smallest tail of length-p+1 subsequences,tailsIdx[p] as the index of that tail in nums, and prev[i] as the predecessor index of nums[i] in the LIS. The algorithm. Using greedy strategy to keep tails minimal for easier extension, and reconstructs via prev[i] backtracking where each element stores its predecessor's index.
  - Library: Rich built-in methods for arrays and enumerables. eg: `map!`, `each`, `fill`, `split`.
  - Iteration: Using (0...n).each do |i| for loops.

7. Java - O(n log n)
  - Language: Verbose but structured. It requires class definition even for simple part. Explicit and former type declarations like int[] tails = new int[nums.length]. Using ArrayList<Integer> for dynamic arrays. Similar to Ruby, Java maintaining tails[p] as smallest tail of length-p+1 subsequences and prev[i] for reconstruction via backtracking. On the other hand, Java's syntax is quite different from other languages, such as using `public static void main(String[] args)` for main function and `System.out.println()` for output. Also, Java requires semicolons at the end of each statement. But, there are many building tools like isEmpty and length(), which can simplify the code. 
  - Library: Rich standard libraries. For example: Arrays.fill() method to initialize arrays BufferedReader to read input.
  - Iteration: Uses for loops with traditional indexing, e.g., `for (int i = 0; i < n; i++)`.


8. Go - O(n log n)
  - Language: Simple and efficient systems language. No class definitions needed, it just contain func and main. The syntax is quite different from other languages, such as using `func` to define functions and `:=` for variable declaration. For dp, using make([]int, n) for dynamic array creation. Uses same binary search DP approach, maintaining tails[p] and prev[i] for reconstruction. Over all, the language is simple and efficient. I think that's why rewrite Go is so popular now.
  - Library: Sufficient libraries like: strings.Fields() means it can clear space automaticly. fmt.Print/Println() for print out.
  - Iteration: Using a traditional loop `for i := 0; i < n; i++`, similar to C/Java.




**Paradigm differences:**

von Neumann (Ada Go) & object-oriented (C# Java)
Common Features - Imperative DP Approach
- Ada: DP_Array stores complete subsequences 
- Go: tails[], tailsIdx[], prev[] collaborate in three arrays
- C#: List<List<int>> stores dynamic lists
- Java: tails[], tailsIdx[], prev[] collaborate in three arrays


  Ada:
  - Extremely verbose type declarations: type Sequence is record Elements : Int_Array; Length : Natural; end record;
  - Extremely verbose type declarations
  - Static array limitations: (1 .. 999), memory wasteful
  -  Manual array operations, no built-in append


  Go:
  -  Clean syntax: make([]int, n), := for variable declaration
  - O(nlogn) binary search optimization
  - No class definitions, direct function implementation
  - Efficient memory management

  C#:
  - Mandatory class encapsulation: public class Program
  - Rich class libraries: List<T>, Where(), Select()
  - Algorithm complexity O(n³)

  Java:
  - Mandatory class structure: public static void main
  - Verbose but safe explicit type declarations
  - O(nlogn) optimized algorithms
  - Rich standard library: Arrays.fill(), BufferedReader




Functional (Ocaml)
Functional Characteristics
  -  Immutable Data Structures: candidates { length : int; last : int; rev_seq : int list }
  -   Clear algorithm logic: find best predecessor → build new candidate → update global optimum
  -  Code concise but highly expressive

Scripting (Python Ruby)
Easy and Powerful Language

Python Features
  - Intuitive Data Structures: dp = [[] for _ in range(n)] directly stores subsequences 
  - Powerful Built-in Functions: max(dp, key=len) finds the longest in one line
  - Concise Syntax: for i in range(n), nums.append(x)

Ruby Features
  - Rich Syntax Sugar: map!(&:to_i) single-line conversion
  - Elegant Block Syntax: (0...n).each do |i|
  - O(nlogn) Optimization: Binary Search + Greedy Strategy
  - Dynamic Arrays: Array.new(n, -1) initializes arrays easily
  
Logic (Prolog)
Declarative Characteristics
- Relation Definition: lis([H|T], L) :- ...
- Constraint Expression: increasing(X,Y) :- X < Y defines increasing
- Main idea: "what is LIS"
- Focus on "problem specification" describe solution properties and let system solve

 















