--
-- Created by ada_generator.py on 2017-09-06 17:20:42.611089
-- 
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with AUnit.Test_Cases; 
with AUnit;
-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package Model.SCP.Target_Creator.Tests is
    use AUnit.Test_Cases;
    use AUnit;
      -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===
    
    type Test_Case is new AUnit.Test_Cases.Test_Case with null record;
    
    procedure Register_Tests (T : in out Test_Case);
    --  Register routines to be run
    
    function Name (T : Test_Case) return Message_String;
    --  Returns name identifying the test case
    
    --  Override if needed. Default empty implementations provided:
    
    --  Preparation performed before each routine:
    procedure Set_Up (T : in out Test_Case);
    
   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===
    
end Model.SCP.Target_Creator.Tests;
