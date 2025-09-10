
-- Import
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Fixed;


   -- Input: 3 1 4 1 5
   -- Read: 3 1 4 1 5
   -- Dynamic programming:
   -- DP[1] = 1 (list: 3)
   -- DP[2] = 1 (list: 1)
   -- DP[3] = 2 (list: 1→4 or 3→4)
   -- DP[4] = 1 (list: 1)
   -- DP[5] = 3 (list: 1→4→5)

   -- Time complexity O(n²), Space complexity O(n)
   



procedure Ada_LIS is
   Max_Size : constant := 999; 
   -- Int
   type Int_array is array (1 .. Max_Size) of Integer;
   -- Boolean
   type Bool_Array is array (1 .. Max_Size, 1 .. Max_Size) of Boolean;
   
   -- Input parameters
   arr : Int_array;
   length : Integer := 0;
   DP : Int_array;
   Parent_arr : Int_array;
   Used : Bool_Array := (others => (others => False));
   

   -- Input function
   procedure Read_Input is
      Input_Line : String(1 .. 99999); -- Assign buffer
      Last : Natural;
      Pos : Natural := 1;
      Num : Integer;
      Last_Num : Natural;
   begin
      Get_Line(Input_Line, Last);
      
      while Pos <= Last loop
         while Pos <= Last and then Input_Line(Pos) = ' ' loop
            Pos := Pos + 1;
         end loop;
         
         if Pos <= Last then
            declare
               Start_Pos : Natural := Pos;
            begin
               while Pos <= Last and then Input_Line(Pos) /= ' ' loop
                  Pos := Pos + 1;
               end loop;
               
               Num := Integer'Value(Input_Line(Start_Pos .. Pos - 1));
               length := length + 1;
               arr(length) := Num;
            end;
         end if;
      end loop;
   end Read_Input;
   


   -- Dynamic programming 
   procedure Find_LIS is
      Max_Length : Integer := 0;
      Max_End_Index : Integer := 0;
   begin
      -- Init
      for I in 1 .. length loop
         DP(I) := 1;
         Parent_arr(I) := -1;
         
         for J in 1 .. I - 1 loop
            -- if 19 3 11 7 15 12 4 12 8 16  if 3 < 11; list = [3, 11]
            if arr(J) < arr(I) and then DP(J) + 1 > DP(I) then
               DP(I) := DP(J) + 1; -- update the len
               Parent_arr(I) := J;
            end if;
         end loop;
         
         if DP(I) > Max_Length then
            Max_Length := DP(I);
            Max_End_Index := I;
         end if;
      end loop;
      
      declare
         Result : Int_array;
         Count : Integer := 0;
         Current : Integer := Max_End_Index;
      begin
      -- rebuild the Lis
         while Current /= -1 loop
            Count := Count + 1;
            Result(Count) := arr(Current);
            Current := Parent_arr(Current);
         end loop;
         
         for I in reverse 1 .. Count loop
            Put(Result(I), Width => 0);
            if I > 1 then
               Put(" ");
            end if;
         end loop;
         New_Line;
      end;
   end Find_LIS;
   
begin
   Read_Input;
   if length > 0 then
      Find_LIS;
   end if;
end Ada_LIS;