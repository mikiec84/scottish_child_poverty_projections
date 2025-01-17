--
-- Created by Ada Mill (https://github.com/grahamstark/ada_mill)
-- 
with Ada.Calendar;
with Ada.Containers.Vectors;
with Ada.Exceptions;  
with Ada.Numerics.Discrete_Random;
with Ada.Strings.Unbounded; 
with Ada.Text_IO.Editing;
with Ada.Strings.Fixed;
with GNATColl.Traces;
with GNATCOLL.Templates;

with Text_IO;
with Base_Types; use Base_Types;

-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package body DB_Commons is

   use Ada.Exceptions;
   use Ada.Strings.Unbounded;
   use type Ada.Containers.Count_Type;
   
   -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===

   log_trace : GNATColl.Traces.Trace_Handle := GNATColl.Traces.Create( "DB_COMMONS" );
   
   procedure Log( s : String ) is
   begin
      GNATColl.Traces.Trace( log_trace, s );
   end Log;

   default_schema : Unbounded_String := Null_Unbounded_String;
   
   function Merge( c1 : Criteria; c2 : Criteria ) return Criteria is
      cc : Criteria := c1;
   begin
      -- cc.elements := c1.element;
      -- cc.orderings.Copy( c1.orderings );
      for e of c2.elements loop
         if not cc.elements.Contains( e ) then
            cc.elements.Append( e );
         end if;
      end loop;
      for o of c2.orderings loop
         if not cc.orderings.Contains( o ) then
            cc.orderings.Append( o );
         end if;
      end loop;   
      return cc;
   end Merge;
   
   function Add_Trailing( s : String; to_add : Character := '.' ) return String is
   begin
      if s( s'Last ) = to_add then
         return s;
      end if;
      return s & to_add;
   end Add_Trailing;

   function Get_Default_Schema return String is
      s : constant String := To_String( default_schema );
   begin
      if s'Length > 0 then
         return Add_Trailing( s ); -- ( if( s( s'Length ) = '.' )then s else s & "." );
      end if;
      return "";
   end Get_Default_Schema;

   procedure Set_Default_Schema( name : String ) is
   begin
      if( name = "" )then
         default_schema := Null_Unbounded_String;
      else
         default_schema := To_Unbounded_String( name );
      end if;
   end  Set_Default_Schema;
   
   function Add_Schema_To_Query( query : String; default : String := "" ) return String is
      val : aliased String := 
         ( if default /= "" then Add_Trailing( default ) else Get_Default_Schema );
      key : aliased String := "SCHEMA";
      subs : constant GNATColl.Templates.Substitution_Array( 1 .. 1 ) := 
         ( 1 => ( Name  => key'Unchecked_Access, 
                  Value => val'Unchecked_Access ));
      outs : constant String := GNATColl.Templates.Substitute( query, subs );
   begin
      return outs;      
   end Add_Schema_To_Query;
   
  -- return a string like '2007-09-24 16:07:47'
   function to_string( t : Date_Time_Rec ) return String is      
      
      YEAR_PICTURE : constant Ada.Text_IO.Editing.Picture :=
         Ada.Text_IO.Editing.To_Picture ("9999");
      TWO_PICTURE : constant Ada.Text_IO.Editing.Picture :=
         Ada.Text_IO.Editing.To_Picture ("99");
      
      type some_decimal is delta 1.0 digits 4;
      
      package Decimal_Format is new Ada.Text_IO.Editing.Decimal_Output (
         Num => some_decimal,
         Default_Currency => "",
         Default_Fill => '0',
         Default_Separator => ',',
         Default_Radix_Mark => '.');
      
      use Ada.Calendar;
      
      s : Bounded_String := to_bounded_string( "" );
   begin
      s := s & decimal_format.image( some_decimal(t.year) ,YEAR_PICTURE ) & "-";
      s := s & decimal_format.image( some_decimal(t.month),TWO_PICTURE ) & "-";
      s := s & decimal_format.image( some_decimal(t.day),TWO_PICTURE ) & " ";
      s := s & decimal_format.image( some_decimal(t.hour),TWO_PICTURE ) & ":";
      s := s & decimal_format.image( some_decimal(t.minute),TWO_PICTURE ) & ":";
      s := s & decimal_format.image( some_decimal(t.second),TWO_PICTURE );
      return to_string( s );
   end to_string;
   
   

   function Date_Time_To_Ada_Time( dTime : Date_Time_Rec ) return Ada.Calendar.Time is
      use Ada.Calendar;
        secs : Day_Duration;
   begin
      secs := Day_Duration( 3600*dTime.hour + 60 * dTime.minute + dTime.second ) + Day_Duration( dTime.fraction );
      return Time_Of( 
               Year_Number(dTime.year),
               Month_Number( dTime.month ),
               Day_Number( dTime.day ),
               secs );
   end Date_Time_To_Ada_Time;
   
   function round_down( d : Ada.Calendar.Day_Duration ) return Integer is
   begin
      return Integer(Long_Float'Floor(Long_Float( d )));
   end round_down;

   function Ada_Time_To_Date_Time( adaTime : Ada.Calendar.Time ) return Date_Time_Rec is
   use Ada.Calendar;
      dTime : Date_Time_Rec;
      secs : Day_Duration :=  Seconds( adaTime );
      remaining : Day_Duration := secs; 
   begin
      dTime.year := INTEGER( Year(adaTime));
      dTime.month := INTEGER( Month( adaTime ));
      dTime.day := INTEGER( Day( adaTime ));
      dTime.hour := round_down( secs / 3600.0 );
      
      remaining :=  secs - Day_Duration(dTime.hour)*3600.0;
      dTime.minute := round_down(remaining / 60.0 );
      remaining := remaining - Day_Duration( dTime.minute )*60.0;
      dTime.second := round_down(remaining);
      
      remaining := remaining - Day_Duration( dTime.second );
      dTime.fraction := Long_Float(remaining);
      return dTime;
   end Ada_Time_To_Date_Time;
   
   function to_string( t : Ada.Calendar.Time ) return String is 
   begin
      return to_string( Ada_Time_To_Date_Time( t ));
   end to_string;


   Quoting_Character : constant String := "'";
   
   function joinStr( join : join_type ) return String is
   begin
           case join is
                   when join_and => return "and";
                   when join_or => return "or";
           end case;
   end joinStr;
   
   function likeStr( op : operation_type ) return String is
   begin
           case op is
                   when like => return "like" ;
                   when gt => return  ">" ;
                   when ge => return ">=" ;
                   when lt => return "<" ;
                   when le => return "<=" ;
                   when ne => return "<>" ;
                   when eq => return "=" ;
           end case;
   end likeStr;
   
   function QuoteIdentifier ( ID : String ) return String is
   begin
           return Quoting_Character & ID & Quoting_Character;
   end QuoteIdentifier;
   
   pragma Inline( QuoteIdentifier );
   
   
   function Make_Criterion_Element( varname : String;
                                  op : operation_type;
                                  is_string : Boolean;
                                  join : join_type; 
                                  value : String  ) return Criterion is
   
   s : Unbounded_String := To_Unbounded_String( varname ) & " " & likeStr( op ) & " ";
   cr : Criterion;
   
   begin
      if( is_string ) then 
             s := s & QuoteIdentifier ( value );
             cr.value := To_Unbounded_String( QuoteIdentifier ( value ));
      else
             s := s & value;
             cr.value := To_Unbounded_String( value );
      end if;
      cr.s := s;
      cr.join := join;
       
      return cr;
   end Make_Criterion_Element;
   
   
   function Make_Criterion_Element( varname : String;
                                  op : operation_type;
                                  join : join_type; 
                                  t : Ada.Calendar.Time  ) return Criterion is
   values : String := to_string( t );
   begin
      return Make_Criterion_Element( varname, op, true, join, values );
   end Make_Criterion_Element;
                               

   
   function Make_Criterion_Element( varname : String;
                                  op : operation_type;
                                  join : join_type; 
                                  value : String;
                                  max_length : integer := -1 ) return Criterion is
   edited_string : Unbounded_String := To_Unbounded_String(value);                    
   --
   -- FIXME: got to be a better way of doing this!!!!s
   --
   begin
      if( max_length > 0 ) and ( Length(edited_string) > max_length ) then
         edited_string := 
            To_Unbounded_String( slice( edited_string, 1, max_length ));
      end if;
      return Make_Criterion_Element( varname, op, true, join, To_String(edited_string));
   end Make_Criterion_Element;
   
   function Make_Criterion_Element( varname : String;
                                  op : operation_type;
                                  join : join_type; 
                                  value : Integer
                                   ) return Criterion is
   begin
      return Make_Criterion_Element( varname, op, false, join, value'Img );
   end Make_Criterion_Element;
   
   function Make_Criterion_Element( 
      varname : String;
      op : operation_type;
      join : join_type; 
      value : Big_Int  ) return Criterion is
   begin
      return Make_Criterion_Element( varname, op, false, join, value'Img );
   end Make_Criterion_Element;

   function Make_Criterion_Element( varname : String;
                                  op : operation_type;
                                  join : join_type; 
                                  value : Boolean  ) return Criterion is
   begin
      return Make_Criterion_Element( varname, op, false, join, value'Img );
   end Make_Criterion_Element;
   
   function Make_Criterion_Element( varname : String;
                                  op : operation_type;
                                  join : join_type; 
                                  value : Long_Float  ) return Criterion is
   begin
      return Make_Criterion_Element( varname, op, false, join, value'Img );
   end Make_Criterion_Element;
   
   function Make_Order_By_Element( varname : String; direction : Asc_Or_Desc ) return Order_By_Element is
      s : Order_By_Element := To_Unbounded_String( " " ) & varname & " " & direction'Img;
   begin
      return s;      
   end Make_Order_By_Element;

   procedure Remove_From_Criteria( cr : in out Criteria; varname : String ) is
      i : Natural := 1;
   begin
      if cr.elements.Length = 0 then
         return;
      end if;
      loop
         declare
            s1 : constant String  := To_String( cr.elements.Element( i ).s );
            p  : constant Natural := Ada.Strings.Fixed.Index( s1, " " );
            s  : constant String  := s1( 1 .. p-1 );
         begin
            if s = varname then
               cr.Elements.Delete( i );
            end if;
         end;
         i := i + 1;
         exit when i > Natural( cr.elements.Length );
      end loop;
   end Remove_From_Criteria;

   procedure Add_To_Criteria( cr : in out Criteria; elem : Criterion ) is
   begin
      Criteria_P.append( cr.elements, elem );
   end Add_To_Criteria;
  
   procedure Add_To_Criteria( cr : in out Criteria; ob : Order_By_Element ) is
   begin
      Order_By_P.append( cr.orderings, ob );
   end add_to_criteria;
   
   function To_Crude_Array_Of_Values( c : Criteria ) return String is
      s : Unbounded_String := To_Unbounded_String( "" );
      last_element : Criterion;
      
      procedure Add_Element_To_String( pos : Criteria_P.Cursor ) is
      use Criteria_P;
      crit : Criterion;
      begin
         crit := element( pos );
         s := s & crit.value; 
         if( crit /= last_element ) then
               s := s & ", ";
         end if;
             
      end Add_Element_To_String;
      
   begin
      if( not Criteria_P.is_empty( c.elements )) then
         last_element := Criteria_P.Last_Element( c.elements );
         Criteria_P.iterate( c.elements, add_element_to_string'Access );
      end if;
      return To_String( s );    
   end To_Crude_Array_Of_Values;
   
   
   function To_String( c : Criteria; join_str_override : String := "" ) return String is
   
      s : Unbounded_String := To_Unbounded_String( "" );
      first_element : Criterion;
      first_order_by : Order_By_Element;
      
      procedure add_element_to_string( pos : Criteria_P.Cursor ) is
      use Criteria_P;
      crit : Criterion;
      begin
             crit := element( pos );
             if( crit /= first_element ) then
                     s := s & " ";
                     if( join_str_override = "" )then
                        s := s & joinStr( crit.join );
                     else
                        s := s & join_str_override;
                     end if;
                     s := s & " ";
             end if;
             s := s & crit.s; 
      end add_element_to_string;
      
      procedure add_ordering_to_string( pos : Order_By_P.Cursor ) is
      order : Order_By_Element;
      use Order_By_P;
      
      begin
             order := element( pos );
             if( order /= first_order_by ) then
                     s := s & ", ";
             end if;
             s := s & Unbounded_String(order); 
      end add_ordering_to_string;

   begin
      if( not Criteria_P.is_empty( c.elements )) then
         if( join_str_override = "" )then -- standard case: prefix with 'where'
            s := s & " where ";
         end if;
         first_element :=  Criteria_P.First_Element( c.elements );
         Criteria_P.iterate( c.elements, add_element_to_string'Access );
      end if;
      if( not Order_By_P.is_empty( c.orderings )) then
         s := s & " order by ";
         first_order_by :=  Order_By_P.First_Element( c.orderings );
         Order_By_P.iterate( c.orderings, add_ordering_to_string'Access );
      end if;   
      s := s & " ";
      return To_String( s );    
   end To_String;
   
   function Make_Decimal_Criterion_Element( varname : String;
                               op : operation_type;
                               join : join_type; 
                               value : Dec  ) return Criterion is
   begin
      return Make_Criterion_Element( varname, op, false, join, value'Img );         
   end Make_Decimal_Criterion_Element;
   
   function Make_Limits_Clause( 
      start : Positive := 1;
      count : Positive := Positive'Last ) return String is
      n_start : Natural := start-1;
   begin
      if start = 1 and count = Positive'Last then
         return "";
      end if;
      return " limit " & count'Img & " offset " & n_start'Img;
   end Make_Limits_Clause;
  
   package Random_Positive is new Ada.Numerics.Discrete_Random( Positive );

   Generator : Random_Positive.Generator;

   function Random_String return String is
      use Ada.Strings;
      use Ada.Strings.Fixed;
      i : Positive := Random_Positive.Random( Generator );
      iss : constant String := i'Img( 2 .. i'Img'Length );
      j : Positive := Random_Positive.Random( Generator );
      jss : constant String := j'Img( 2 .. j'Img'Length );
      k : Positive := Random_Positive.Random( Generator );
      kss : constant String := k'Img( 2 .. k'Img'Length );
   begin
      return iss & jss & kss;
   end Random_String;
   
   
   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===
   
      
end DB_Commons;
