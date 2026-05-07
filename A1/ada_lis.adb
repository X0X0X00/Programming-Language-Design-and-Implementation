with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Fixed;


-- Example: input = "3 1 4 1 5"
   --   DP[1] = [3] 
   --   DP[2] = [1] 1>3 false -> no update
   --   DP[3] = [3,4] 4>3 & 1+1>1 -> update
   --   DP[4] = [1] 1>3 false -> no update; 1>1 false -> no update; 1>4 false -> no update
   --   DP[5] = [3,4,5] 5>3 & 1+1>1 -> update; 5>1 & 1+1>2 false -> no update; 5>4 & 2+1>2 -> update
   -- Output: 3 4 5

-- Time complexity O(n³), Space complexity O(n²)
   

-- custom types
-- type type_name is record
--    field_definitions... 
-- end record;

-- array
-- type type_name is array (range) 
--    of Element_Type;

-- record is a collection of fields(int + array)

-- : means "of type"
-- := means "initialize"
-- = means "compare"
-- and then means "short-circuit AND"
-- /= means "not equal"
-- => means "named parameter"
-- Integer'Value(String) means convert String to Integer
-- Natural means non-negative integer
-- Integer means integer 
-- n.Length means "field Length of record n"
-- n.Elements(i) means "i-th element of array Elements of record n"
-- n(i) means "i-th element of array n"
-- put means print without newline
-- new_line means print newline
-- Get_Line(Item, Last) means read a line of input, store in string, and return length
-- arr(1 .. 999) means "array with indices from 1 to 999"
-- loop ... end loop is like { ... }
-- declare ... begin ... end is like { ... }
-- if ... then ... else ... end if is like if (...) { ... } else { ... ... }
-- for I in 1 .. n loop ... end loop is like for (int i = 1; i <= n; i++) { ... }
-- while ... loop ... end loop is like while (...) { ... }
-- procedure name(params) is ... begin ... end; is like void name(params) { ... }
-- function name(params) return Type is ... begin ... end; is like Type name(params) { ... } 


procedure Ada_LIS is 
   -- Ada doesn't have dynamic arrays like C# 
   type Int_Array is array (1 .. 999)    
      of Integer; 
   type Sequence is record
      Elements : Int_Array;
      Length : Integer := 0;
   end record;
   type DP_Array is array (1 .. 999) 
      of Sequence; -- Each dp[i] is a Sequence(array + length)   


   -- declare variables
   arr : Int_Array;
   n : Integer := 0;
   DP : DP_Array;
   
   -- fun to copy
   function Copy_Sequence(Seq : Sequence) return Sequence is
      Result : Sequence;
   begin
      Result.Length := Seq.Length;
      for I in 1 .. Seq.Length loop
         Result.Elements(I) := Seq.Elements(I);
      end loop;
      return Result;
   end Copy_Sequence;
   
   -- fun to append
   procedure Add_To_Sequence(Seq : in out Sequence; Value : Integer) is
   begin
      Seq.Length := Seq.Length + 1;
      Seq.Elements(Seq.Length) := Value;
   end Add_To_Sequence;
   

   -- fun to get input
   procedure Read_Input is
      Input_Line : String(1 .. 99999);
      Last : Natural;
      Position : Natural := 1; 
      Num : Integer;
   begin
      Get_Line(Input_Line, Last);
      
      while Position <= Last loop
      -- skip spaces
         while Position <= Last and then Input_Line(Position) = ' ' loop
            Position := Position + 1;
         end loop;

         if Position <= Last then
            declare
               Start_Pos : Natural := Position;
            begin
               -- Read number
               while Position <= Last and then Input_Line(Position) /= ' ' loop -- stop at space
                  Position := Position + 1;
               end loop;

               Num := Integer'Value(Input_Line(Start_Pos .. Position - 1));
               n := n + 1;
               arr(n) := Num;
            end;
         end if;
      end loop;
   end Read_Input;
   
   -- fun to find LIS
   procedure Find_LIS is
      Longest_Index : Integer := 1;
      Max_Length : Integer := 1;
   begin
      -- Init DP
      -- dp[i] = [arr[i]]
      for I in 1 .. n loop
         DP(I).Length := 1;
         DP(I).Elements(1) := arr(I);
      end loop;
      
      for I in 2 .. n loop
         for J in 1 .. I - 1 loop
            -- if arr[j] < arr[i] && dp[j].Count + 1 > dp[i].Count
            if arr(J) < arr(I) and then DP(J).Length + 1 > DP(I).Length then
               -- dp[i] = new List<int>(dp[j])
               DP(I) := Copy_Sequence(DP(J));
               -- dp[i].Add(arr[i])
               Add_To_Sequence(DP(I), arr(I));
            end if;
         end loop;
      end loop;
      
      -- fun to find Longest Sequence
      for I in 1 .. n loop
         if DP(I).Length > Max_Length then
            Max_Length := DP(I).Length;
            Longest_Index := I;
         end if;
      end loop;
      
      -- fun to print
      for I in 1 .. DP(Longest_Index).Length loop
         Put(DP(Longest_Index).Elements(I), Width => 0);
         if I < DP(Longest_Index).Length then
            Put(" ");
         end if;
      end loop;
      New_Line;
   end Find_LIS;


-- main
begin
   Read_Input;
   if n > 0 then
      Find_LIS;
   end if;
end Ada_LIS;