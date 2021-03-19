

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
@.DATA = global i64 0
@.NB = global i64 0
@.BL = global i64 0

define void @Stack_Function_BL(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %load_constant_0 = load i64, i64* @.BL
  call void @Stack_PushInt(%stackType* %stack, i64 %load_constant_0)
  ret void
}
@.TWENTY = global i64 0

define void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %load_constant_1 = load i64, i64* @.TWENTY
  call void @Stack_PushInt(%stackType* %stack, i64 %load_constant_1)
  ret void
}
@.REJECT = global i64 0

define void @Stack_Function_REJECT(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %load_constant_2 = load i64, i64* @.REJECT
  call void @Stack_PushInt(%stackType* %stack, i64 %load_constant_2)
  ret void
}
@.SMALL = global i64 0

define void @Stack_Function_SMALL(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %load_constant_3 = load i64, i64* @.SMALL
  call void @Stack_PushInt(%stackType* %stack, i64 %load_constant_3)
  ret void
}
@.MEDIUM = global i64 0

define void @Stack_Function_MEDIUM(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %load_constant_4 = load i64, i64* @.MEDIUM
  call void @Stack_PushInt(%stackType* %stack, i64 %load_constant_4)
  ret void
}
@.LARGE = global i64 0

define void @Stack_Function_LARGE(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %load_constant_5 = load i64, i64* @.LARGE
  call void @Stack_PushInt(%stackType* %stack, i64 %load_constant_5)
  ret void
}
@.EXTRA = global i64 0

define void @Stack_Function_EXTRA(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %load_constant_6 = load i64, i64* @.EXTRA
  call void @Stack_PushInt(%stackType* %stack, i64 %load_constant_6)
  ret void
}
@.ERROR = global i64 0

define void @Stack_Function_ERROR(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %load_constant_7 = load i64, i64* @.ERROR
  call void @Stack_PushInt(%stackType* %stack, i64 %load_constant_7)
  ret void
}

define void @Stack_Function_SPACES(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;push 0
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  %top_13 = call i64 @Stack_Pop(%stackType* %stack)
  %second_14 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_8 = alloca i64
  store i64 %top_13, i64* %i_global_8
  br label %entry_15
entry_15:
  %i_local1_9 = load i64, i64* %i_global_8
  %isIGreater_12 = icmp sge i64 %i_local1_9, %second_14
  br i1 %isIGreater_12, label %finish_17, label %loop_16
loop_16:
  ;SPACE
  call i64 @printSpace()
  %i_local2_10 = load i64, i64* %i_global_8
  %i_local3_11 = add i64 1, %i_local2_10
  store i64 %i_local3_11, i64* %i_global_8
  br label %entry_15
finish_17:
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
  %top_18 = call i64 @Stack_Pop(%stackType* %stack)
  %second_19 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_18)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_19)
  ;OVER
  %top_20 = call i64 @Stack_Pop(%stackType* %stack)
  %second_21 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_21)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_20)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_21)
  ret void
}

define void @Stack_Function_NIP(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;SWAP
  %top_22 = call i64 @Stack_Pop(%stackType* %stack)
  %second_23 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_22)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_23)
  ;DROP
  %trashed_24 = call i64 @Stack_Pop(%stackType* %stack)
  ret void
}

define void @Stack_Function_CATEGORY(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;DUP
  %top_25 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_25)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_25)
  ;push 18
  call void @Stack_PushInt(%stackType* %stack, i64 18)
  ;<
  br label %entry_29
entry_29:
  %top_26 = call i64 @Stack_Pop(%stackType* %stack)
  %second_27 = call i64 @Stack_Pop(%stackType* %stack)
  %isSmaller_28 = icmp sle i64 %top_26, %second_27
  br i1 %isSmaller_28, label %topsmaller_30, label %secondsmaller_31
topsmaller_30:
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  br label %finish_32
secondsmaller_31:
  call void @Stack_PushInt(%stackType* %stack, i64 -1)
  br label %finish_32
finish_32:
  %top_36 = call i64 @Stack_Pop(%stackType* %stack)
  %isZero_35 = icmp eq i64 %top_36, 0
  br i1 %isZero_35, label %else_block_34, label %if_block_33
if_block_33:
  ;REJECT
  call void @Stack_Function_REJECT(%stackType* %stack, %stackType* %return_stack)
  br label %if_exit_37
else_block_34:
  ;DUP
  %top_38 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_38)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_38)
  ;push 21
  call void @Stack_PushInt(%stackType* %stack, i64 21)
  ;<
  br label %entry_42
entry_42:
  %top_39 = call i64 @Stack_Pop(%stackType* %stack)
  %second_40 = call i64 @Stack_Pop(%stackType* %stack)
  %isSmaller_41 = icmp sle i64 %top_39, %second_40
  br i1 %isSmaller_41, label %topsmaller_43, label %secondsmaller_44
topsmaller_43:
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  br label %finish_45
secondsmaller_44:
  call void @Stack_PushInt(%stackType* %stack, i64 -1)
  br label %finish_45
finish_45:
  %top_49 = call i64 @Stack_Pop(%stackType* %stack)
  %isZero_48 = icmp eq i64 %top_49, 0
  br i1 %isZero_48, label %else_block_47, label %if_block_46
if_block_46:
  ;SMALL
  call void @Stack_Function_SMALL(%stackType* %stack, %stackType* %return_stack)
  br label %if_exit_50
else_block_47:
  ;DUP
  %top_51 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_51)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_51)
  ;push 24
  call void @Stack_PushInt(%stackType* %stack, i64 24)
  ;<
  br label %entry_55
entry_55:
  %top_52 = call i64 @Stack_Pop(%stackType* %stack)
  %second_53 = call i64 @Stack_Pop(%stackType* %stack)
  %isSmaller_54 = icmp sle i64 %top_52, %second_53
  br i1 %isSmaller_54, label %topsmaller_56, label %secondsmaller_57
topsmaller_56:
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  br label %finish_58
secondsmaller_57:
  call void @Stack_PushInt(%stackType* %stack, i64 -1)
  br label %finish_58
finish_58:
  %top_62 = call i64 @Stack_Pop(%stackType* %stack)
  %isZero_61 = icmp eq i64 %top_62, 0
  br i1 %isZero_61, label %else_block_60, label %if_block_59
if_block_59:
  ;MEDIUM
  call void @Stack_Function_MEDIUM(%stackType* %stack, %stackType* %return_stack)
  br label %if_exit_63
else_block_60:
  ;DUP
  %top_64 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_64)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_64)
  ;push 27
  call void @Stack_PushInt(%stackType* %stack, i64 27)
  ;<
  br label %entry_68
entry_68:
  %top_65 = call i64 @Stack_Pop(%stackType* %stack)
  %second_66 = call i64 @Stack_Pop(%stackType* %stack)
  %isSmaller_67 = icmp sle i64 %top_65, %second_66
  br i1 %isSmaller_67, label %topsmaller_69, label %secondsmaller_70
topsmaller_69:
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  br label %finish_71
secondsmaller_70:
  call void @Stack_PushInt(%stackType* %stack, i64 -1)
  br label %finish_71
finish_71:
  %top_75 = call i64 @Stack_Pop(%stackType* %stack)
  %isZero_74 = icmp eq i64 %top_75, 0
  br i1 %isZero_74, label %else_block_73, label %if_block_72
if_block_72:
  ;LARGE
  call void @Stack_Function_LARGE(%stackType* %stack, %stackType* %return_stack)
  br label %if_exit_76
else_block_73:
  ;DUP
  %top_77 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_77)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_77)
  ;push 30
  call void @Stack_PushInt(%stackType* %stack, i64 30)
  ;<
  br label %entry_81
entry_81:
  %top_78 = call i64 @Stack_Pop(%stackType* %stack)
  %second_79 = call i64 @Stack_Pop(%stackType* %stack)
  %isSmaller_80 = icmp sle i64 %top_78, %second_79
  br i1 %isSmaller_80, label %topsmaller_82, label %secondsmaller_83
topsmaller_82:
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  br label %finish_84
secondsmaller_83:
  call void @Stack_PushInt(%stackType* %stack, i64 -1)
  br label %finish_84
finish_84:
  %top_88 = call i64 @Stack_Pop(%stackType* %stack)
  %isZero_87 = icmp eq i64 %top_88, 0
  br i1 %isZero_87, label %else_block_86, label %if_block_85
if_block_85:
  ;EXTRA
  call void @Stack_Function_EXTRA(%stackType* %stack, %stackType* %return_stack)
  ;-
  %top_90 = call i64 @Stack_Pop(%stackType* %stack)
  %second_91 = call i64 @Stack_Pop(%stackType* %stack)
  %subvalue_92 = sub i64 %second_91, %top_90
  call void @Stack_PushInt(%stackType* %stack, i64 %subvalue_92)
  ;LARGE
  call void @Stack_Function_LARGE(%stackType* %stack, %stackType* %return_stack)
  br label %if_exit_89
else_block_86:
  ;ERROR
  call void @Stack_Function_ERROR(%stackType* %stack, %stackType* %return_stack)
  br label %if_exit_89
if_exit_89:
  br label %if_exit_76
if_exit_76:
  br label %if_exit_63
if_exit_63:
  br label %if_exit_50
if_exit_50:
  br label %if_exit_37
if_exit_37:
  ;NIP
  call void @Stack_Function_NIP(%stackType* %stack, %stackType* %return_stack)
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
  %top_93 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_93, i64* @.BL
  ;push 4
  call void @Stack_PushInt(%stackType* %stack, i64 4)
  %top_94 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_94, i64* @.NB
  ;push 12
  call void @Stack_PushInt(%stackType* %stack, i64 12)
  %top_95 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_95, i64* @.DATA
  %var_local_96 = load i64, i64* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i64 %var_local_96)
  ;.
  %top_97 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_98 = call i64 @printInt(i64 %top_97)
  %var_local_99 = load i64, i64* @.NB
  call void @Stack_PushInt(%stackType* %stack, i64 %var_local_99)
  ;.
  %top_100 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_101 = call i64 @printInt(i64 %top_100)
  ;push 543
  call void @Stack_PushInt(%stackType* %stack, i64 543)
  %top_102 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_102, i64* @.NB
  %var_local_103 = load i64, i64* @.NB
  call void @Stack_PushInt(%stackType* %stack, i64 %var_local_103)
  ;.
  %top_104 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_105 = call i64 @printInt(i64 %top_104)
  ;push 20
  call void @Stack_PushInt(%stackType* %stack, i64 20)
  ;constant TWENTY
  %top_106 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_106, i64* @.TWENTY
  ;push 0
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  ;constant REJECT
  %top_107 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_107, i64* @.REJECT
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  ;constant SMALL
  %top_108 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_108, i64* @.SMALL
  ;push 2
  call void @Stack_PushInt(%stackType* %stack, i64 2)
  ;constant MEDIUM
  %top_109 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_109, i64* @.MEDIUM
  ;push 3
  call void @Stack_PushInt(%stackType* %stack, i64 3)
  ;constant LARGE
  %top_110 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_110, i64* @.LARGE
  ;push 4
  call void @Stack_PushInt(%stackType* %stack, i64 4)
  ;constant EXTRA
  %top_111 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_111, i64* @.EXTRA
  ;-
  %top_112 = call i64 @Stack_Pop(%stackType* %stack)
  %second_113 = call i64 @Stack_Pop(%stackType* %stack)
  %subvalue_114 = sub i64 %second_113, %top_112
  call void @Stack_PushInt(%stackType* %stack, i64 %subvalue_114)
  ;LARGE
  call void @Stack_Function_LARGE(%stackType* %stack, %stackType* %return_stack)
  ;push 5
  call void @Stack_PushInt(%stackType* %stack, i64 5)
  ;constant ERROR
  %top_115 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_115, i64* @.ERROR
  ;TWENTY
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  ;.
  %top_116 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_117 = call i64 @printInt(i64 %top_116)
  ;TWENTY
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  ;.
  %top_118 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_119 = call i64 @printInt(i64 %top_118)
  ;TWENTY
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  ;.
  %top_120 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_121 = call i64 @printInt(i64 %top_120)
  ;TWENTY
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  ;TWENTY
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  ;.
  %top_122 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_123 = call i64 @printInt(i64 %top_122)
  ;.
  %top_124 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_125 = call i64 @printInt(i64 %top_124)
  ;push 5
  call void @Stack_PushInt(%stackType* %stack, i64 5)
  ;SPACES
  call void @Stack_Function_SPACES(%stackType* %stack, %stackType* %return_stack)
  ;push 23
  call void @Stack_PushInt(%stackType* %stack, i64 23)
  ;CATEGORY
  call void @Stack_Function_CATEGORY(%stackType* %stack, %stackType* %return_stack)
  ;.
  %top_126 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_127 = call i64 @printInt(i64 %top_126)

  ret i32 0
}
