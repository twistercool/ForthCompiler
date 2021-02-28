

; string template for a number
@.str = private constant [4 x i8] c"%d \00"
; string template for an ASCII character
@.asciiStr = private constant [4 x i8] c"%c \00"

declare i32 @printf(i8*, ...)

define i32 @printInt(i32 %x) 
{
  %t0 = getelementptr [4 x i8], [4 x i8]* @.str, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* %t0, i32 %x) 
  ret i32 %x
}

define i32 @print_ASCII(i32 %x) 
{
  %t0 = getelementptr [4 x i8], [4 x i8]* @.asciiStr, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* %t0, i32 %x) 
  ret i32 %x
}

; store the newline as a string constant
; more specifically as a constant array containing i8 integers
@.nl = constant [2 x i8] c"\0A\00"

define i32 @printNL() 
{
  %castNL = getelementptr [2 x i8], [2 x i8]* @.nl, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* %castNL)
  ret i32 0
}

@.space = constant [2 x i8] c" \00"

define i32 @printSpace() 
{
  %castSpace = getelementptr [2 x i8], [2 x i8]* @.space, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* %castSpace)
  ret i32 0
}

;this is where I define the stackType, it holds the length of the stack and the stack itself (array of i32)
%stackType = type { 
  i32, ; 0: holds the current length of the stack, or the amount of elements in it 
  [100 x i32] ; 1: an array of the elements  
}

; constructor for %stackType
define void @Stack_Create_Empty(%stackType* %this) nounwind
{
  ; initialises the length to 0
  %1 = getelementptr %stackType, %stackType* %this, i32 0, i32 0
  store i32 0, i32* %1

  ; initialises the array to empty
  %2 = getelementptr %stackType, %stackType* %this, i32 0, i32 1
  %empty_stack = alloca [100 x i32]
  %loaded = load [100 x i32], [100 x i32]* %empty_stack
  store [100 x i32] %loaded, [100 x i32]* %2
  ret void
}

; returns the length of an input stack 
define i32 @Stack_GetLength(%stackType* %this) nounwind 
{
  %1 = getelementptr %stackType, %stackType* %this ,i32 0, i32 0
  %2 = load i32, i32* %1
  ret i32 %2
}

define void @Stack_IncrementLength(%stackType* %this) nounwind
{ 
  ; loads the length of the stack, adds one, stores it into the stackType
  %1 = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %2 = load i32, i32* %1
  %3 = add i32 1, %2
  store i32 %3, i32* %1 
  ret void
}

define void @Stack_DecrementLength(%stackType* %this) nounwind
{ 
  ; loads the length of the stack, adds one, stores it into the stackType
  %1 = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %2 = load i32, i32* %1
  %3 = sub i32 %2, 1
  store i32 %3, i32* %1 
  ret void
}

define void @Stack_PushInt(%stackType* %this, i32 %int) nounwind
{ 
  ; loads the length of the stack, adds one, stores it into the stackType
  %lengthptr = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %length = load i32, i32* %lengthptr

  ; gets the pointer element at index %length of the array
  %stack = getelementptr %stackType, %stackType* %this, i32 0, i32 1
  %1 = getelementptr [100 x i32], [100 x i32]* %stack, i32 0, i32 %length
  ; stores the number in the given pointer
  store i32 %int, i32* %1

  call void @Stack_IncrementLength(%stackType* %this)
  ret void
}

define i32 @Stack_Pop(%stackType* %this) nounwind
{
  ; loads the length of the stack, adds one, stores it into the stackType
  %lengthptr = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %length = load i32, i32* %lengthptr
  %negindex = sub i32 1, %length
  %index = sub i32 0, %negindex

  ; gets the pointer element at index %index of the array
  %stack = getelementptr %stackType, %stackType* %this, i32 0, i32 1
  %indexptr = getelementptr [100 x i32], [100 x i32]* %stack, i32 0, i32 %index
  ; loads the number from the given pointer
  %popped = load i32, i32* %indexptr

  call void @Stack_DecrementLength(%stackType* %this)
  ret i32 %popped
}
@.DATA = global i32 0
@.NB = global i32 0
@.TWENTY = global i32 0

define void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %load_constant_0 = load i32, i32* @.TWENTY
  call void @Stack_PushInt(%stackType* %stack, i32 %load_constant_0)
  ret void
}

define void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 42)
  %top_1 = call i32 @Stack_Pop(%stackType* %stack)
  call i32 @print_ASCII(i32 %top_1)
  ret void
}

define void @Stack_Function_STARS(%stackType* %stack, %stackType* %return_stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  %top_7 = call i32 @Stack_Pop(%stackType* %stack)
  %second_8 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_2 = alloca i32
  store i32 %top_7, i32* %i_global_2
  br label %entry_9
entry_9:
  %i_local1_3 = load i32, i32* %i_global_2
  %isIGreater_6 = icmp sge i32 %i_local1_3, %second_8
  br i1 %isIGreater_6, label %finish_11, label %loop_10
loop_10:
  call void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack)
  %i_local2_4 = load i32, i32* %i_global_2
  %i_local3_5 = add i32 1, %i_local2_4
  store i32 %i_local3_5, i32* %i_global_2
  br label %entry_9
finish_11:
  ret void
}

define void @Stack_Function_F(%stackType* %stack, %stackType* %return_stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 5)
  call void @Stack_Function_STARS(%stackType* %stack, %stackType* %return_stack)
  call i32 @printNL()
  call void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack)
  call i32 @printNL()
  call void @Stack_PushInt(%stackType* %stack, i32 5)
  call void @Stack_Function_STARS(%stackType* %stack, %stackType* %return_stack)
  call i32 @printNL()
  call void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack)
  call i32 @printNL()
  call void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack)
  call i32 @printNL()
  call void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack)
  ret void
}

define void @Stack_Function_FIB(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %top_12 = call i32 @Stack_Pop(%stackType* %stack)
  %second_13 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_13)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_12)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_13)
  %top_14 = call i32 @Stack_Pop(%stackType* %stack)
  %second_15 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_15)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_14)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_15)
  %top_16 = call i32 @Stack_Pop(%stackType* %stack)
  %second_17 = call i32 @Stack_Pop(%stackType* %stack)
  %added_18 = add i32 %second_17, %top_16
  call void @Stack_PushInt(%stackType* %stack, i32 %added_18)
  ret void
}

define void @Stack_Function_FIBS(%stackType* %stack, %stackType* %return_stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_19 = call i32 @Stack_Pop(%stackType* %stack)
  %second_20 = call i32 @Stack_Pop(%stackType* %stack)
  %third_21 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_20)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_19)
  call void @Stack_PushInt(%stackType* %stack, i32 %third_21)
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  %top_27 = call i32 @Stack_Pop(%stackType* %stack)
  %second_28 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_22 = alloca i32
  store i32 %top_27, i32* %i_global_22
  br label %entry_29
entry_29:
  %i_local1_23 = load i32, i32* %i_global_22
  %isIGreater_26 = icmp sge i32 %i_local1_23, %second_28
  br i1 %isIGreater_26, label %finish_31, label %loop_30
loop_30:
  call void @Stack_Function_FIB(%stackType* %stack, %stackType* %return_stack)
  %i_local2_24 = load i32, i32* %i_global_22
  %i_local3_25 = add i32 1, %i_local2_24
  store i32 %i_local3_25, i32* %i_global_22
  br label %entry_29
finish_31:
  ret void
}

define void @Stack_Function_FACTORIAL(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %top_32 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_32)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_32)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_38 = call i32 @Stack_Pop(%stackType* %stack)
  %second_39 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_33 = alloca i32
  store i32 %top_38, i32* %i_global_33
  br label %entry_40
entry_40:
  %i_local1_34 = load i32, i32* %i_global_33
  %isIGreater_37 = icmp sge i32 %i_local1_34, %second_39
  br i1 %isIGreater_37, label %finish_42, label %loop_41
loop_41:
  %top_43 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_43)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_43)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_44 = call i32 @Stack_Pop(%stackType* %stack)
  %second_45 = call i32 @Stack_Pop(%stackType* %stack)
  %subvalue_46 = sub i32 %second_45, %top_44
  call void @Stack_PushInt(%stackType* %stack, i32 %subvalue_46)
  %i_local2_35 = load i32, i32* %i_global_33
  %i_local3_36 = add i32 1, %i_local2_35
  store i32 %i_local3_36, i32* %i_global_33
  br label %entry_40
finish_42:
  %Length_47 = call i32 @Stack_GetLength(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %Length_47)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_53 = call i32 @Stack_Pop(%stackType* %stack)
  %second_54 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_48 = alloca i32
  store i32 %top_53, i32* %i_global_48
  br label %entry_55
entry_55:
  %i_local1_49 = load i32, i32* %i_global_48
  %isIGreater_52 = icmp sge i32 %i_local1_49, %second_54
  br i1 %isIGreater_52, label %finish_57, label %loop_56
loop_56:
  %top_58 = call i32 @Stack_Pop(%stackType* %stack)
  %second_59 = call i32 @Stack_Pop(%stackType* %stack)
  %product_60 = mul i32 %second_59, %top_58
  call void @Stack_PushInt(%stackType* %stack, i32 %product_60)
  %i_local2_50 = load i32, i32* %i_global_48
  %i_local3_51 = add i32 1, %i_local2_50
  store i32 %i_local3_51, i32* %i_global_48
  br label %entry_55
finish_57:
  %top_61 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_62 = call i32 @printInt(i32 %top_61)
  ret void
}


define i32 @main(i32 %argc, i8** %argv) {
  ; uses the 
  %stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %stack)
  %return_stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %return_stack)


  ; COMPILED CODE STARTS HERE


  call i32 @printNL()
  call i32 @printNL()
  call void @Stack_Function_F(%stackType* %stack, %stackType* %return_stack)
  call i32 @printNL()
  call void @Stack_PushInt(%stackType* %stack, i32 40)
  call void @Stack_Function_FIBS(%stackType* %stack, %stackType* %return_stack)
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  call void @Stack_Function_FACTORIAL(%stackType* %stack, %stackType* %return_stack)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_68 = call i32 @Stack_Pop(%stackType* %stack)
  %second_69 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_63 = alloca i32
  store i32 %top_68, i32* %i_global_63
  br label %entry_70
entry_70:
  %i_local1_64 = load i32, i32* %i_global_63
  %isIGreater_67 = icmp sge i32 %i_local1_64, %second_69
  br i1 %isIGreater_67, label %finish_72, label %loop_71
loop_71:
  %i_local_73 = load i32, i32* %i_global_63
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_73)
  %top_74 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_75 = call i32 @printInt(i32 %top_74)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_81 = call i32 @Stack_Pop(%stackType* %stack)
  %second_82 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_76 = alloca i32
  store i32 %top_81, i32* %newIndex_global_76
  br label %entry_83
entry_83:
  %newIndex_local1_77 = load i32, i32* %newIndex_global_76
  %isIGreater_80 = icmp sge i32 %newIndex_local1_77, %second_82
  br i1 %isIGreater_80, label %finish_85, label %loop_84
loop_84:
  %j_local_86 = load i32, i32* %i_global_63
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_86)
  %top_87 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_88 = call i32 @printInt(i32 %top_87)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_94 = call i32 @Stack_Pop(%stackType* %stack)
  %second_95 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_89 = alloca i32
  store i32 %top_94, i32* %newIndex_global_89
  br label %entry_96
entry_96:
  %newIndex_local1_90 = load i32, i32* %newIndex_global_89
  %isIGreater_93 = icmp sge i32 %newIndex_local1_90, %second_95
  br i1 %isIGreater_93, label %finish_98, label %loop_97
loop_97:
  %i_local_99 = load i32, i32* %newIndex_global_89
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_99)
  %top_100 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_101 = call i32 @printInt(i32 %top_100)
  %newIndex_local2_91 = load i32, i32* %newIndex_global_89
  %newIndex_local3_92 = add i32 1, %newIndex_local2_91
  store i32 %newIndex_local3_92, i32* %newIndex_global_89
  br label %entry_96
finish_98:
  %newIndex_local2_78 = load i32, i32* %newIndex_global_76
  %newIndex_local3_79 = add i32 1, %newIndex_local2_78
  store i32 %newIndex_local3_79, i32* %newIndex_global_76
  br label %entry_83
finish_85:
  %i_local2_65 = load i32, i32* %i_global_63
  %i_local3_66 = add i32 1, %i_local2_65
  store i32 %i_local3_66, i32* %i_global_63
  br label %entry_70
finish_72:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_105
entry_105:
  %top_102 = call i32 @Stack_Pop(%stackType* %stack)
  %second_103 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_104 = icmp slt i32 %top_102, %second_103
  br i1 %isSmaller_104, label %topsmaller_106, label %secondsmaller_107
topsmaller_106:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_108
secondsmaller_107:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_108
finish_108:
  %top_112 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_111 = icmp eq i32 %top_112, 0
  br i1 %isZero_111, label %else_block_110, label %if_block_109
if_block_109:
  %top_114 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_115 = call i32 @printInt(i32 %top_114)
  br label %if_exit_113
else_block_110:
  br label %if_exit_113
if_exit_113:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_116 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_116, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_117 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_117, i32* @.DATA
  %var_local_118 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_118)
  %top_119 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_120 = call i32 @printInt(i32 %top_119)
  %var_local_121 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_121)
  %top_122 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_123 = call i32 @printInt(i32 %top_122)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_124 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_124, i32* @.NB
  %var_local_125 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_125)
  %top_126 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_127 = call i32 @printInt(i32 %top_126)
  call void @Stack_PushInt(%stackType* %stack, i32 20)
  %top_128 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_128, i32* @.TWENTY
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  %top_129 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_130 = call i32 @printInt(i32 %top_129)
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  %top_131 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_132 = call i32 @printInt(i32 %top_131)

  ret i32 0
}
