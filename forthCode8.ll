

; string template for a number
@.str = private constant [4 x i8] c"%d \00"
; string template for an ASCII character
@.asciiStr = private constant [4 x i8] c"%c \00"

declare i64 @printf(i8*, ...)

define i64 @printInt(i64 %x) 
{
  %t0 = getelementptr [4 x i8], [4 x i8]* @.str, i32 0, i32 0
  call i64 (i8*, ...) @printf(i8* %t0, i64 %x) 
  ret i64 %x
}

define i64 @print_ASCII(i64 %x) 
{
  %t0 = getelementptr [4 x i8], [4 x i8]* @.asciiStr, i32 0, i32 0
  call i64 (i8*, ...) @printf(i8* %t0, i64 %x) 
  ret i64 %x
}

; store the newline as a string constant
; more specifically as a constant array containing i8 integers
@.nl = constant [2 x i8] c"\0A\00"

define i64 @printNL() 
{
  %castNL = getelementptr [2 x i8], [2 x i8]* @.nl, i32 0, i32 0
  call i64 (i8*, ...) @printf(i8* %castNL)
  ret i64 0
}

@.space = constant [2 x i8] c" \00"

define i64 @printSpace() 
{
  %castSpace = getelementptr [2 x i8], [2 x i8]* @.space, i32 0, i32 0
  call i64 (i8*, ...) @printf(i8* %castSpace)
  ret i64 0
}

;this is where I define the stackType, it holds the length of the stack and the stack itself (array of i64)
%stackType = type { 
  i64, ; 0: holds the current length of the stack, or the amount of elements in it 
  [100 x i64] ; 1: an array of the elements  
}

; constructor for %stackType
define void @Stack_Create_Empty(%stackType* %this) nounwind
{
  ; initialises the length to 0
  %1 = getelementptr %stackType, %stackType* %this, i32 0, i32 0
  store i64 0, i64* %1

  ; initialises the array to empty
  %2 = getelementptr %stackType, %stackType* %this, i32 0, i32 1
  %empty_stack = alloca [100 x i64]
  %loaded = load [100 x i64], [100 x i64]* %empty_stack
  store [100 x i64] %loaded, [100 x i64]* %2
  ret void
}

; returns the length of an input stack 
define i64 @Stack_GetLength(%stackType* %this) nounwind 
{
  %1 = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %2 = load i64, i64* %1
  ret i64 %2
}

define void @Stack_IncrementLength(%stackType* %this) nounwind
{ 
  ; loads the length of the stack, adds one, stores it into the stackType
  %1 = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %2 = load i64, i64* %1
  %3 = add i64 1, %2
  store i64 %3, i64* %1 
  ret void
}

define void @Stack_DecrementLength(%stackType* %this) nounwind
{ 
  ; loads the length of the stack, adds one, stores it into the stackType
  %1 = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %2 = load i64, i64* %1
  %3 = sub i64 %2, 1
  store i64 %3, i64* %1 
  ret void
}

define void @Stack_PushInt(%stackType* %this, i64 %int) nounwind
{ 
  ; loads the length of the stack, adds one, stores it into the stackType
  %lengthptr = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %length = load i64, i64* %lengthptr

  ; gets the pointer element at index %length of the array
  %stack = getelementptr %stackType, %stackType* %this, i32 0, i32 1
  %1 = getelementptr [100 x i64], [100 x i64]* %stack, i32 0, i64 %length
  ; stores the number in the given pointer
  store i64 %int, i64* %1

  call void @Stack_IncrementLength(%stackType* %this)
  ret void
}

define i64 @Stack_Pop(%stackType* %this) nounwind
{
  ; loads the length of the stack, adds one, stores it into the stackType
  %lengthptr = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %length = load i64, i64* %lengthptr
  %negindex = sub i64 1, %length
  %index = sub i64 0, %negindex

  ; gets the pointer element at index %index of the array
  %stack = getelementptr %stackType, %stackType* %this, i32 0, i32 1
  %indexptr = getelementptr [100 x i64], [100 x i64]* %stack, i32 0, i64 %index
  ; loads the number from the given pointer
  %popped = load i64, i64* %indexptr

  call void @Stack_DecrementLength(%stackType* %this)
  ret i64 %popped
}
@.BL = global i64 0

define void @Stack_Function_BL(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %load_constant_0 = load i64, i64* @.BL
  call void @Stack_PushInt(%stackType* %stack, i64 %load_constant_0)
  ret void
}

define void @Stack_Function_SPACES(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;push 0
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  %top_6 = call i64 @Stack_Pop(%stackType* %stack)
  %second_7 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_1 = alloca i64
  store i64 %top_6, i64* %i_global_1
  br label %entry_8
entry_8:
  %i_local1_2 = load i64, i64* %i_global_1
  %isIEqual_5 = icmp eq i64 %i_local1_2, %second_7
  br i1 %isIEqual_5, label %finish_10, label %loop_9
loop_9:
  ;SPACE
  call i64 @printSpace()
  %i_local2_3 = load i64, i64* %i_global_1
  %i_local3_4 = add i64 1, %i_local2_3
  store i64 %i_local3_4, i64* %i_global_1
  br label %entry_8
finish_10:
  ret void
}

define void @Stack_Function_FALSE(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;push 0
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  ret void
}

define void @Stack_Function_TRUE(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;push -1
  call void @Stack_PushInt(%stackType* %stack, i64 -1)
  ret void
}

define void @Stack_Function_TUCK(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;SWAP
  %top_11 = call i64 @Stack_Pop(%stackType* %stack)
  %second_12 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_11)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_12)
  ;OVER
  %top_13 = call i64 @Stack_Pop(%stackType* %stack)
  %second_14 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_14)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_13)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_14)
  ret void
}

define void @Stack_Function_NIP(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;SWAP
  %top_15 = call i64 @Stack_Pop(%stackType* %stack)
  %second_16 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_15)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_16)
  ;DROP
  %trashed_17 = call i64 @Stack_Pop(%stackType* %stack)
  ret void
}

define void @Stack_Function_BUBBLE(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;DUP
  %top_18 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_18)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_18)
  %top_22 = call i64 @Stack_Pop(%stackType* %stack)
  %isZero_21 = icmp eq i64 %top_22, 0
  br i1 %isZero_21, label %else_block_20, label %if_block_19
if_block_19:
  ;>R
  %top_24 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %return_stack, i64 %top_24)
  ;OVER
  %top_25 = call i64 @Stack_Pop(%stackType* %stack)
  %second_26 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_26)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_25)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_26)
  ;OVER
  %top_27 = call i64 @Stack_Pop(%stackType* %stack)
  %second_28 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_28)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_27)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_28)
  ;<
  br label %entry_32
entry_32:
  %top_29 = call i64 @Stack_Pop(%stackType* %stack)
  %second_30 = call i64 @Stack_Pop(%stackType* %stack)
  %isSmaller_31 = icmp sle i64 %top_29, %second_30
  br i1 %isSmaller_31, label %topsmaller_33, label %secondsmaller_34
topsmaller_33:
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  br label %finish_35
secondsmaller_34:
  call void @Stack_PushInt(%stackType* %stack, i64 -1)
  br label %finish_35
finish_35:
  %top_39 = call i64 @Stack_Pop(%stackType* %stack)
  %isZero_38 = icmp eq i64 %top_39, 0
  br i1 %isZero_38, label %else_block_37, label %if_block_36
if_block_36:
  ;SWAP
  %top_41 = call i64 @Stack_Pop(%stackType* %stack)
  %second_42 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_41)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_42)
  br label %if_exit_40
else_block_37:
  br label %if_exit_40
if_exit_40:
  ;R>
  %top_43 = call i64 @Stack_Pop(%stackType* %return_stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_43)
  ;SWAP
  %top_44 = call i64 @Stack_Pop(%stackType* %stack)
  %second_45 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_44)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_45)
  ;>R
  %top_46 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %return_stack, i64 %top_46)
  ;1-
  %top_47 = call i64 @Stack_Pop(%stackType* %stack)
  %subValue_48 = sub i64 %top_47, 1
  call void @Stack_PushInt(%stackType* %stack, i64 %subValue_48)
  ;R>
  %top_49 = call i64 @Stack_Pop(%stackType* %return_stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_49)
  ;1-
  %top_50 = call i64 @Stack_Pop(%stackType* %stack)
  %subValue_51 = sub i64 %top_50, 1
  call void @Stack_PushInt(%stackType* %stack, i64 %subValue_51)
  ;R>
  %top_52 = call i64 @Stack_Pop(%stackType* %return_stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_52)
  ;R>
  %top_53 = call i64 @Stack_Pop(%stackType* %return_stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_53)
  ;SWAP
  %top_54 = call i64 @Stack_Pop(%stackType* %stack)
  %second_55 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_54)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_55)
  ;>R
  %top_56 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %return_stack, i64 %top_56)
  ;1-
  %top_57 = call i64 @Stack_Pop(%stackType* %stack)
  %subValue_58 = sub i64 %top_57, 1
  call void @Stack_PushInt(%stackType* %stack, i64 %subValue_58)
  ;R>
  %top_59 = call i64 @Stack_Pop(%stackType* %return_stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_59)
  br label %if_exit_23
else_block_20:
  ;DROP
  %trashed_60 = call i64 @Stack_Pop(%stackType* %stack)
  br label %if_exit_23
if_exit_23:
  ret void
}

define void @Stack_Function_SORT(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;1-
  %top_61 = call i64 @Stack_Pop(%stackType* %stack)
  %subValue_62 = sub i64 %top_61, 1
  call void @Stack_PushInt(%stackType* %stack, i64 %subValue_62)
  ;DUP
  %top_63 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_63)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_63)
  ;push 0
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  %top_69 = call i64 @Stack_Pop(%stackType* %stack)
  %second_70 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_64 = alloca i64
  store i64 %top_69, i64* %i_global_64
  br label %entry_71
entry_71:
  %i_local1_65 = load i64, i64* %i_global_64
  %isIEqual_68 = icmp eq i64 %i_local1_65, %second_70
  br i1 %isIEqual_68, label %finish_73, label %loop_72
loop_72:
  ;>R
  %top_74 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %return_stack, i64 %top_74)
  ;R@
  %top_75 = call i64 @Stack_Pop(%stackType* %return_stack)
  call void @Stack_PushInt(%stackType* %return_stack, i64 %top_75)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_75)
  ;BUBBLE
  call void @Stack_Function_BUBBLE(%stackType* %stack, %stackType* %return_stack)
  ;R>
  %top_76 = call i64 @Stack_Pop(%stackType* %return_stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_76)
  %i_local2_66 = load i64, i64* %i_global_64
  %i_local3_67 = add i64 1, %i_local2_66
  store i64 %i_local3_67, i64* %i_global_64
  br label %entry_71
finish_73:
  ;DROP
  %trashed_77 = call i64 @Stack_Pop(%stackType* %stack)
  ret void
}


define i32 @main(i32 %argc, i8** %argv) {
  ; uses the 
  %stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %stack)
  %return_stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %return_stack)


  ; COMPILED CODE STARTS HERE


  ;push 32
  call void @Stack_PushInt(%stackType* %stack, i64 32)
  ;constant BL
  %top_78 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_78, i64* @.BL
  ;push 2
  call void @Stack_PushInt(%stackType* %stack, i64 2)
  ;push 4
  call void @Stack_PushInt(%stackType* %stack, i64 4)
  ;push 2
  call void @Stack_PushInt(%stackType* %stack, i64 2)
  ;push 7
  call void @Stack_PushInt(%stackType* %stack, i64 7)
  ;push 4
  call void @Stack_PushInt(%stackType* %stack, i64 4)
  ;SORT
  call void @Stack_Function_SORT(%stackType* %stack, %stackType* %return_stack)

  ret i32 0
}
