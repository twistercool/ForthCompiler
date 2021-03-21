

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
  <256 x i64> ; 1: an array of the elements  
}

; constructor for %stackType
define void @Stack_Create_Empty(%stackType* %this) nounwind
{
  ; initialises the length to 0
  %1 = getelementptr %stackType, %stackType* %this, i32 0, i32 0
  store i64 0, i64* %1

  ; initialises the array to empty
  %2 = getelementptr %stackType, %stackType* %this, i32 0, i32 1
  %empty_stack = alloca <256 x i64>
  %loaded = load <256 x i64>, <256 x i64>* %empty_stack
  store <256 x i64> %loaded, <256 x i64>* %2
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
  %1 = getelementptr <256 x i64>, <256 x i64>* %stack, i32 0, i64 %length
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
  %index = sub i64 %length, 1

  ; gets the pointer element at index %index of the array
  %stack = getelementptr %stackType, %stackType* %this, i32 0, i32 1
  %indexptr = getelementptr <256 x i64>, <256 x i64>* %stack, i32 0, i64 %index
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

define void @Stack_Function_PRINTALL(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;DEPTH
  %Length_18 = call i64 @Stack_GetLength(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %Length_18)
  ;push 0
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  %top_24 = call i64 @Stack_Pop(%stackType* %stack)
  %second_25 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_19 = alloca i64
  store i64 %top_24, i64* %i_global_19
  br label %entry_26
entry_26:
  %i_local1_20 = load i64, i64* %i_global_19
  %isIEqual_23 = icmp eq i64 %i_local1_20, %second_25
  br i1 %isIEqual_23, label %finish_28, label %loop_27
loop_27:
  ;.
  %top_29 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_30 = call i64 @printInt(i64 %top_29)
  %i_local2_21 = load i64, i64* %i_global_19
  %i_local3_22 = add i64 1, %i_local2_21
  store i64 %i_local3_22, i64* %i_global_19
  br label %entry_26
finish_28:
  ret void
}

define void @Stack_Function_REVERSESTACK(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  %top_36 = call i64 @Stack_Pop(%stackType* %stack)
  %second_37 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_31 = alloca i64
  store i64 %top_36, i64* %i_global_31
  br label %entry_38
entry_38:
  %i_local1_32 = load i64, i64* %i_global_31
  %isIEqual_35 = icmp eq i64 %i_local1_32, %second_37
  br i1 %isIEqual_35, label %finish_40, label %loop_39
loop_39:
  ;I
  %i_local_41 = load i64, i64* %i_global_31
  call void @Stack_PushInt(%stackType* %stack, i64 %i_local_41)
  ;ROLL
  %i_local2_33 = load i64, i64* %i_global_31
  %i_local3_34 = add i64 1, %i_local2_33
  store i64 %i_local3_34, i64* %i_global_31
  br label %entry_38
finish_40:
  ret void
}

define void @Stack_Function_FACTORIAL(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;DUP
  %top_42 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_42)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_42)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  %top_48 = call i64 @Stack_Pop(%stackType* %stack)
  %second_49 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_43 = alloca i64
  store i64 %top_48, i64* %i_global_43
  br label %entry_50
entry_50:
  %i_local1_44 = load i64, i64* %i_global_43
  %isIEqual_47 = icmp eq i64 %i_local1_44, %second_49
  br i1 %isIEqual_47, label %finish_52, label %loop_51
loop_51:
  ;DUP
  %top_53 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_53)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_53)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  ;-
  %top_54 = call i64 @Stack_Pop(%stackType* %stack)
  %second_55 = call i64 @Stack_Pop(%stackType* %stack)
  %subvalue_56 = sub i64 %second_55, %top_54
  call void @Stack_PushInt(%stackType* %stack, i64 %subvalue_56)
  %i_local2_45 = load i64, i64* %i_global_43
  %i_local3_46 = add i64 1, %i_local2_45
  store i64 %i_local3_46, i64* %i_global_43
  br label %entry_50
finish_52:
  ;DEPTH
  %Length_57 = call i64 @Stack_GetLength(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %Length_57)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  %top_63 = call i64 @Stack_Pop(%stackType* %stack)
  %second_64 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_58 = alloca i64
  store i64 %top_63, i64* %i_global_58
  br label %entry_65
entry_65:
  %i_local1_59 = load i64, i64* %i_global_58
  %isIEqual_62 = icmp eq i64 %i_local1_59, %second_64
  br i1 %isIEqual_62, label %finish_67, label %loop_66
loop_66:
  ;*
  %top_68 = call i64 @Stack_Pop(%stackType* %stack)
  %second_69 = call i64 @Stack_Pop(%stackType* %stack)
  %product_70 = mul i64 %second_69, %top_68
  call void @Stack_PushInt(%stackType* %stack, i64 %product_70)
  %i_local2_60 = load i64, i64* %i_global_58
  %i_local3_61 = add i64 1, %i_local2_60
  store i64 %i_local3_61, i64* %i_global_58
  br label %entry_65
finish_67:
  ;.
  %top_71 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_72 = call i64 @printInt(i64 %top_71)
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
  %top_73 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_73, i64* @.BL
  ;push 13
  call void @Stack_PushInt(%stackType* %stack, i64 13)
  ;FACTORIAL
  call void @Stack_Function_FACTORIAL(%stackType* %stack, %stackType* %return_stack)

  ret i32 0
}
