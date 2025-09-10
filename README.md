# CSC 254 Assignment 1 - Longest Increasing Subsequence 

Zhenhao Zhang zzh133@u.rochester.edu [Ada, C#, Python, Prolog]   
Zhijie Wang zwang179@u.rochester.edu [Ocaml, Java, Go, Ruby]

## Description
We are a two-person team, each responsible for four different programming languages. I handle Ada, C#, Python, and Prolog. We write the instructions for running our respective languages in our own README files. Among the four languages I work on, Python has a time complexity of **O(nlogn)**, while the other three are **O(n²)**. We additionally wrote **Java, Go, and Ruby**.

## Algorithm
- **Time Complexity**: **O(n²)** for Ada, C#, Prolog; **O(n log n)** for Python
- **Space Complexity**: **O(n)** - Stores the sequence and DP arrays
- **Approach**: Use the DP[I] array to store the length of the longest increasing subsequence ending at position I.
- **Python Optimization**: Uses binary search and Greedy algorithm to achieve **O(n log n)** complexity

## Language Implementations

### Ada
**File**: `ada_lis.adb`

**Compile and Run**:
```bash
# Compile
gnatmake ada_lis.adb

# Run
echo "19 3 11 7 15 12 4 12 8 16" | ./ada_lis
```

```bash
# Compile
gnatmake ada_lis.adb

# Run
./ada_lis

# Manual input
19 3 11 7 15 12 4 12 8 16
```


### C#
**File**: `csharp_lis.cs`

**Compile and Run**:
```bash
# Compile
mcs csharp_lis.cs

# Run
echo "19 3 11 7 15 12 4 12 8 16" | mono csharp_lis.exe
```

```bash
# Compile
mcs csharp_lis.cs

# Run
mono csharp_lis.exe

# Manual input
19 3 11 7 15 12 4 12 8 16
```



### Python
**File**: `python_lis.py`

**Run**:
```bash
# Method 1: Run with built-in test
python3 python_lis.py

# Method 3: In Python interpreter
 python3
  >>> from python_lis import lis
  >>> lis([19, 3, 11, 7, 15, 12, 4, 12, 8, 16])
  [3, 11, 15, 16]
  >>> exit()
```

### Prolog
**File**: `prolog_lis.pl`

**Run**:
```bash
# Method 1:  Interactive input
/usr/staff/bin/prolog -s prolog_lis.pl
# Then at the prompt:
# ?- lis([19, 3, 11, 7, 15, 12, 4, 12, 8, 16], L).
# L = [3, 11, 15, 16].
# -halt. (to exit)

# Method 2: Run test function
/usr/staff/bin/prolog -s prolog_lis.pl
# Then at the prompt:
# ?- test_lis.
# L = [3, 11, 15, 16].
# -halt. (to exit)
```



**After reading my partner's code, here are the commands for the remaining four languages.**


### Ruby
**File:** `ruby_lis.rb`

**Run**
```bash
# Method 1: Pipe input
echo "19 3 11 7 15 12 4 12 8 16" | ruby ruby_lis.rb

# Method 2: Interactive input
ruby ruby_lis.rb
19 3 11 7 15 12 4 12 8 16
```

**Description**    
Read a line of text from user input and store it in `line`. Convert the input content into an integer array using `map!(&:to_i)`. Using a greedy algorithm combined with binary search to store the array with the smallest last digit of length `p+1` into `tails`. Using `tailIdx` to record the index position. The position of the element preceding `nums[i]` is stored in `prev`. Finally, backtrack through the `prev` array to complete the result.

Time complexity: O(n log n)


### OCaml
**File:** `ocaml_lis.ml`

**Compile & Run**
```bash
# Compile
ocamlc -o ocaml_lis ocaml_lis.ml

# Run
echo "19 3 11 7 15 12 4 12 8 16" | ./ocaml_lis
```

```bash
# Compile
ocamlc -o ocaml_lis ocaml_lis.ml

# Run
./ocaml_lis

# Manual input
19 3 11 7 15 12 4 12 8 16
```
**Description**    
Define a `candidate` record type to store subsequence information (length, last element, and reversed sequence). The `extend_best` function finds the best predecessor. Then extend it with the new element. The main `lis` function uses recursive `build` to process each element and find the global best element. Stores sequences in reverse order (`rev_seq`), then reverses at the end with `List.rev`.

Time complexity: O(n²)


### Java
**File:** `java_lis.java`

**Compile & Run**
```bash
# Compile
javac java_lis.java

# Run
echo "19 3 11 7 15 12 4 12 8 16" | java java_lis
```

```bash
# Compile
javac java_lis.java

# Run
java java_lis

# Manual input
19 3 11 7 15 12 4 12 8 16
```
**Description**    
Same as before, we define three lists: tails, tailsIdx, and prev. The core algorithm remains binary search, implemented using a for loop. After finding a position, we update the array. Finally, we reconstruct the list by backtracking through prev.

Time complexity: O(n log n)


### Go
**File:** `go_lis.go`

**Compile & Run**
```bash
# Compile
go build -o go_lis go_lis.go

# Run
echo "19 3 11 7 15 12 4 12 8 16" | ./go_lis
```

```bash
# Compile
go build -o go_lis go_lis.go

# Run
./go_lis

# Manual input
19 3 11 7 15 12 4 12 8 16
```

**Description**    
The first step is to create an array using `make([]int, n)`. Three arrays tails, tailsIdx, and prev are created. The binary search and reconstruction logic remains identical to the previous implementation. Input processing utilizes `bufio.NewReader`. String-to-integer conversion is complete through `strconv.Atoi`.

Time complexity: O(n log n)





## Example Input/Output
**Input**:
```
19 3 11 7 15 12 4 12 8 16
```

**Output**:
```
3  7 15 16
3  4  8 16
3  4 12 16
3  7  8 16
3  7 12 16
3 11 12 16
3 11 15 16
```


## Programming Experience

**The easiest language:**  
 I find Python the most comfortable to write. First, Python is the language I've worked with most extensively—not only is it required for machine learning and deep learning courses, but I also use it for programming during internships and research. Consequently, my understanding of Python is the strongest. Beyond that, I practice on LeetCode to learn many Python tricks.  For the LIS task, Python's advantages are particularly evident. First, excluding commits, Python requires the least amount of code. Moreover, Python's built-in `bisect` module enables direct binary search implementation. I used `bisect.bisect_left()` to avoid writing binary search logic by hand.

Consequently, I implemented an O(n log n) optimized version in Python, while other languages used the basic O(n²) implementation.

**The Most Challenging Languages:**
Ada and OCaml have been the most troublesome for me. First, neither language has syntax highlighting support in my VSCode, resulting in plain white text. This makes reading code extremely difficult and leads to frequent line misreading. Regarding syntax specifically, Ada's syntax is exceptionally verbose, requiring extensive type declarations and keywords. I frequently forget to include begin/end statements. The code volume is nearly double that of other languages (Python, Prolog, and C#). OCaml's functional programming paradigm feels unfamiliar to me. Despite teammates' code comments, the nested let...in structures remain challenging to grasp. Moreover, the recursive mindset differs entirely from the iterative loops I'm accustomed to. Both languages consumed substantial time on syntax details rather than the algorithms themselves.


**Speed Differences:**
With small inputs, nearly all languages complete execution instantly, showing no discernible differences. However, when processing larger inputs of 100 numbers, Prolog proves the slowest.


**Personal Preferences:**
Python is my favorite. It's the mainstream language in AI and machine learning, with nearly all deep learning frameworks and LLM tools offering Python interfaces.


**Language Comparison**
 1. Python - O(n log n)
  - Language: Simple and direct, `nums = []`, `append()`, `reversed()`. The entire implementation is the most concise      
  - Libraries: Uses the `bisect`, no need to manually write the algorithm

  2. Ruby - O(n log n)
  - Language: Relatively simple language, using `map!(&:to_i)` concisely converts array. Also, very powerful, `prev = Array.new(n, -1)`, -1, can be directly called
  - Iteration: Very clear, using `(0...n).each do |i|`

  3. Java - O(n log n)
  - Language: Cumbersome, even simple algorithms require class definitions. But explicit typing can reduce errors
  - Library: Arrays.fill(), BufferedReader are very convenient
  - Iteration: Using loops and modify array elements


  4. Go - O(n log n)
  - Language: No while loops; all iterations use for loops. Directly create dynamic arrays with make([]int, n) and split strings automatically with strings.Fields().
  - Iteration: Very convinent, for i, v := range nums retrieves both index and value simultaneously.


  5. C# - O(n²)
  - Language: Very clear nested loop DP. Outer loop iterates each element, inner loop finds best predecessor
  - Library: Useful tools, using Where() filters empty strings, Select() converts to integers.


  6. Ada - O (n²)
  - Language: All variables must be declared in a `declare` block before use. Super complex and extensive `begin end` block structure—each `procedure`, `declare`, `if`, or `loop` requires a matching `end`. 
  - Iteration: verbose and complex syntax `while Pos <= Last and then Input_Line(Pos) = ‘ ’`

  7. OCaml - O(n²)
  - Recursion: Uses `let rec build` instead of loops
  - Language: Concise record types like `type candidate = { length : int; last : int; rev_seq : int list }`. Convenient syntax for list reversal with `List.rev`.

  8. Prolog - O(n²)
  - Language: Declarative—describes “what is” rather than “how to do.” Syntax is inherently concise, requiring no type declarations or variable declarations. Minor details exist, like variable capitalization (e.g., List, LIS, DP must start with uppercase). The complexity is its fundamentally different programming logic compared to mainstream languages like Python. 
  - Programming: Describes problems using rules and facts



**Paradigm differences:**

von Neumann (Ada)

object-oriented (C# Java OCaml)

scropting (Python Ruby)


Imperative Programming (Go)
  - Iterate through each element using loops
  - Array values can be modified
  - Python/Java/Go/Ruby use binary search to optimize to O(nlogn)
  - Ada/C# use traditional DP to maintain O(n²)

```bash
  # Python
  tails[position] = num
  dp[i] = position + 1
  parent_arr[i] = j

  // Java 
  tails[p] = x;
  tailsIdx[p] = i;
  prev[i] = tailsIdx[p - 1];

  // Go
  tails[p] = x
  tailsIdx[p] = i
  prev[i] = tailsIdx[p-1]

  # Ruby
  tails[p] = x
  tailsIdx[p] = i
  prev[i] = tailsIdx[p - 1] if p > 0

  -- Ada:
  DP(I) := DP(J) + 1;
  Parent_arr(I) := J;

  // C#: 
  dp[i] = dp[j] + 1;
  parent_arr[i] = j;
```


Functional Programming (OCaml)   
  - Immutable data structures
  - Create new data instead of modifying

```bash
  (* OCaml creates a new candidate record *)
  { length = best_prev.length + 1;
    last = x;
    rev_seq = x :: best_prev.rev_seq }

  (* Recursive construction, passing immutable lists *)
  build (cand :: candidates) best_cand' rest
```

Logic (Prolog)
  - Declaring relations instead of steps
  - Letting the system automatically search for all available solutions
  - Backtracking inference to find optimal solutions

```bash
  % Define “what constitutes a valid predecessor”
  findall(Len-Seq,
          (member(J-Len-Seq, DP),
           J < Pos,
           PrevVal < CurrVal),  % Constraints
          Candidates)
```
















