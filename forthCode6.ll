

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

define void @Stack_Function_EGGSIZE(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;DUP
  %top_42 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_42)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_42)
  ;push 18
  call void @Stack_PushInt(%stackType* %stack, i64 18)
  ;<
  %top_43 = call i64 @Stack_Pop(%stackType* %stack)
  %second_44 = call i64 @Stack_Pop(%stackType* %stack)
  %isSmaller_45 = icmp sle i64 %top_43, %second_44
  br i1 %isSmaller_45, label %topsmaller_46, label %secondsmaller_47
topsmaller_46:
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  br label %finish_48
secondsmaller_47:
  call void @Stack_PushInt(%stackType* %stack, i64 -1)
  br label %finish_48
finish_48:
  %top_52 = call i64 @Stack_Pop(%stackType* %stack)
  %isZero_51 = icmp eq i64 %top_52, 0
  br i1 %isZero_51, label %else_block_50, label %if_block_49
if_block_49:
  ;PRINT STRING reject 
  %string_ref_54 = alloca [8 x i8]
  store [8 x i8] c"reject \00", [8 x i8]* %string_ref_54  
  %string_ptr_55 = getelementptr [8 x i8], [8 x i8]* %string_ref_54, i64 0, i64 0
  call i64 (i8*, ...) @printf(i8* %string_ptr_55)
  br label %if_exit_53
else_block_50:
  ;DUP
  %top_56 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_56)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_56)
  ;push 21
  call void @Stack_PushInt(%stackType* %stack, i64 21)
  ;<
  %top_57 = call i64 @Stack_Pop(%stackType* %stack)
  %second_58 = call i64 @Stack_Pop(%stackType* %stack)
  %isSmaller_59 = icmp sle i64 %top_57, %second_58
  br i1 %isSmaller_59, label %topsmaller_60, label %secondsmaller_61
topsmaller_60:
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  br label %finish_62
secondsmaller_61:
  call void @Stack_PushInt(%stackType* %stack, i64 -1)
  br label %finish_62
finish_62:
  %top_66 = call i64 @Stack_Pop(%stackType* %stack)
  %isZero_65 = icmp eq i64 %top_66, 0
  br i1 %isZero_65, label %else_block_64, label %if_block_63
if_block_63:
  ;PRINT STRING small 
  %string_ref_68 = alloca [7 x i8]
  store [7 x i8] c"small \00", [7 x i8]* %string_ref_68  
  %string_ptr_69 = getelementptr [7 x i8], [7 x i8]* %string_ref_68, i64 0, i64 0
  call i64 (i8*, ...) @printf(i8* %string_ptr_69)
  br label %if_exit_67
else_block_64:
  ;DUP
  %top_70 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_70)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_70)
  ;push 24
  call void @Stack_PushInt(%stackType* %stack, i64 24)
  ;<
  %top_71 = call i64 @Stack_Pop(%stackType* %stack)
  %second_72 = call i64 @Stack_Pop(%stackType* %stack)
  %isSmaller_73 = icmp sle i64 %top_71, %second_72
  br i1 %isSmaller_73, label %topsmaller_74, label %secondsmaller_75
topsmaller_74:
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  br label %finish_76
secondsmaller_75:
  call void @Stack_PushInt(%stackType* %stack, i64 -1)
  br label %finish_76
finish_76:
  %top_80 = call i64 @Stack_Pop(%stackType* %stack)
  %isZero_79 = icmp eq i64 %top_80, 0
  br i1 %isZero_79, label %else_block_78, label %if_block_77
if_block_77:
  ;PRINT STRING medium 
  %string_ref_82 = alloca [8 x i8]
  store [8 x i8] c"medium \00", [8 x i8]* %string_ref_82  
  %string_ptr_83 = getelementptr [8 x i8], [8 x i8]* %string_ref_82, i64 0, i64 0
  call i64 (i8*, ...) @printf(i8* %string_ptr_83)
  br label %if_exit_81
else_block_78:
  ;DUP
  %top_84 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_84)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_84)
  ;push 27
  call void @Stack_PushInt(%stackType* %stack, i64 27)
  ;<
  %top_85 = call i64 @Stack_Pop(%stackType* %stack)
  %second_86 = call i64 @Stack_Pop(%stackType* %stack)
  %isSmaller_87 = icmp sle i64 %top_85, %second_86
  br i1 %isSmaller_87, label %topsmaller_88, label %secondsmaller_89
topsmaller_88:
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  br label %finish_90
secondsmaller_89:
  call void @Stack_PushInt(%stackType* %stack, i64 -1)
  br label %finish_90
finish_90:
  %top_94 = call i64 @Stack_Pop(%stackType* %stack)
  %isZero_93 = icmp eq i64 %top_94, 0
  br i1 %isZero_93, label %else_block_92, label %if_block_91
if_block_91:
  ;PRINT STRING large 
  %string_ref_96 = alloca [7 x i8]
  store [7 x i8] c"large \00", [7 x i8]* %string_ref_96  
  %string_ptr_97 = getelementptr [7 x i8], [7 x i8]* %string_ref_96, i64 0, i64 0
  call i64 (i8*, ...) @printf(i8* %string_ptr_97)
  br label %if_exit_95
else_block_92:
  ;DUP
  %top_98 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_98)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_98)
  ;push 30
  call void @Stack_PushInt(%stackType* %stack, i64 30)
  ;<
  %top_99 = call i64 @Stack_Pop(%stackType* %stack)
  %second_100 = call i64 @Stack_Pop(%stackType* %stack)
  %isSmaller_101 = icmp sle i64 %top_99, %second_100
  br i1 %isSmaller_101, label %topsmaller_102, label %secondsmaller_103
topsmaller_102:
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  br label %finish_104
secondsmaller_103:
  call void @Stack_PushInt(%stackType* %stack, i64 -1)
  br label %finish_104
finish_104:
  %top_108 = call i64 @Stack_Pop(%stackType* %stack)
  %isZero_107 = icmp eq i64 %top_108, 0
  br i1 %isZero_107, label %else_block_106, label %if_block_105
if_block_105:
  ;PRINT STRING extra large 
  %string_ref_110 = alloca [13 x i8]
  store [13 x i8] c"extra large \00", [13 x i8]* %string_ref_110  
  %string_ptr_111 = getelementptr [13 x i8], [13 x i8]* %string_ref_110, i64 0, i64 0
  call i64 (i8*, ...) @printf(i8* %string_ptr_111)
  br label %if_exit_109
else_block_106:
  ;PRINT STRING error 
  %string_ref_112 = alloca [7 x i8]
  store [7 x i8] c"error \00", [7 x i8]* %string_ref_112  
  %string_ptr_113 = getelementptr [7 x i8], [7 x i8]* %string_ref_112, i64 0, i64 0
  call i64 (i8*, ...) @printf(i8* %string_ptr_113)
  br label %if_exit_109
if_exit_109:
  br label %if_exit_95
if_exit_95:
  br label %if_exit_81
if_exit_81:
  br label %if_exit_67
if_exit_67:
  br label %if_exit_53
if_exit_53:
  ;DROP
  %trashed_114 = call i64 @Stack_Pop(%stackType* %stack)
  ret void
}


define i32 @main(i32 %argc, i8** %argv) {
  ; uses the 
  %stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %stack)
  %return_stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %return_stack)


  ; COMPILED FORTH CODE STARTS HERE


  ;push 32
  call void @Stack_PushInt(%stackType* %stack, i64 32)
  ;constant BL
  %top_115 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_115, i64* @.BL
  ;push 19
  call void @Stack_PushInt(%stackType* %stack, i64 19)
  ;EGGSIZE
  call void @Stack_Function_EGGSIZE(%stackType* %stack, %stackType* %return_stack)

  ; COMPILATION FINISHED
  ret i32 0
}
