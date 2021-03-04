

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
@.BL = global i32 0

define void @Stack_Function_BL(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %load_constant_0 = load i32, i32* @.BL
  call void @Stack_PushInt(%stackType* %stack, i32 %load_constant_0)
  ret void
}
@.TWENTY = global i32 0

define void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %load_constant_1 = load i32, i32* @.TWENTY
  call void @Stack_PushInt(%stackType* %stack, i32 %load_constant_1)
  ret void
}

define void @Stack_Function_SPACES(%stackType* %stack, %stackType* %return_stack) nounwind
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
  call i32 @printSpace()
  %i_local2_4 = load i32, i32* %i_global_2
  %i_local3_5 = add i32 1, %i_local2_4
  store i32 %i_local3_5, i32* %i_global_2
  br label %entry_9
finish_11:
  ret void
}

define void @Stack_Function_FALSE(%stackType* %stack, %stackType* %return_stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  ret void
}

define void @Stack_Function_TRUE(%stackType* %stack, %stackType* %return_stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  ret void
}

define void @Stack_Function_TUCK(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %top_12 = call i32 @Stack_Pop(%stackType* %stack)
  %second_13 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_12)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_13)
  %top_14 = call i32 @Stack_Pop(%stackType* %stack)
  %second_15 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_15)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_14)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_15)
  ret void
}

define void @Stack_Function_NIP(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %top_16 = call i32 @Stack_Pop(%stackType* %stack)
  %second_17 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_16)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_17)
  %trashed_18 = call i32 @Stack_Pop(%stackType* %stack)
  ret void
}

define void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 42)
  %top_19 = call i32 @Stack_Pop(%stackType* %stack)
  call i32 @print_ASCII(i32 %top_19)
  ret void
}

define void @Stack_Function_STARS(%stackType* %stack, %stackType* %return_stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  %top_25 = call i32 @Stack_Pop(%stackType* %stack)
  %second_26 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_20 = alloca i32
  store i32 %top_25, i32* %i_global_20
  br label %entry_27
entry_27:
  %i_local1_21 = load i32, i32* %i_global_20
  %isIGreater_24 = icmp sge i32 %i_local1_21, %second_26
  br i1 %isIGreater_24, label %finish_29, label %loop_28
loop_28:
  call void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack)
  %i_local2_22 = load i32, i32* %i_global_20
  %i_local3_23 = add i32 1, %i_local2_22
  store i32 %i_local3_23, i32* %i_global_20
  br label %entry_27
finish_29:
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
  %top_30 = call i32 @Stack_Pop(%stackType* %stack)
  %second_31 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_31)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_30)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_31)
  %top_32 = call i32 @Stack_Pop(%stackType* %stack)
  %second_33 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_33)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_32)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_33)
  %top_34 = call i32 @Stack_Pop(%stackType* %stack)
  %second_35 = call i32 @Stack_Pop(%stackType* %stack)
  %added_36 = add i32 %second_35, %top_34
  call void @Stack_PushInt(%stackType* %stack, i32 %added_36)
  ret void
}

define void @Stack_Function_FIBS(%stackType* %stack, %stackType* %return_stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_37 = call i32 @Stack_Pop(%stackType* %stack)
  %second_38 = call i32 @Stack_Pop(%stackType* %stack)
  %third_39 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_38)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_37)
  call void @Stack_PushInt(%stackType* %stack, i32 %third_39)
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  %top_45 = call i32 @Stack_Pop(%stackType* %stack)
  %second_46 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_40 = alloca i32
  store i32 %top_45, i32* %i_global_40
  br label %entry_47
entry_47:
  %i_local1_41 = load i32, i32* %i_global_40
  %isIGreater_44 = icmp sge i32 %i_local1_41, %second_46
  br i1 %isIGreater_44, label %finish_49, label %loop_48
loop_48:
  call void @Stack_Function_FIB(%stackType* %stack, %stackType* %return_stack)
  %i_local2_42 = load i32, i32* %i_global_40
  %i_local3_43 = add i32 1, %i_local2_42
  store i32 %i_local3_43, i32* %i_global_40
  br label %entry_47
finish_49:
  ret void
}

define void @Stack_Function_FACTORIAL(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %top_50 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_50)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_50)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_56 = call i32 @Stack_Pop(%stackType* %stack)
  %second_57 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_51 = alloca i32
  store i32 %top_56, i32* %i_global_51
  br label %entry_58
entry_58:
  %i_local1_52 = load i32, i32* %i_global_51
  %isIGreater_55 = icmp sge i32 %i_local1_52, %second_57
  br i1 %isIGreater_55, label %finish_60, label %loop_59
loop_59:
  %top_61 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_61)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_61)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_62 = call i32 @Stack_Pop(%stackType* %stack)
  %second_63 = call i32 @Stack_Pop(%stackType* %stack)
  %subvalue_64 = sub i32 %second_63, %top_62
  call void @Stack_PushInt(%stackType* %stack, i32 %subvalue_64)
  %i_local2_53 = load i32, i32* %i_global_51
  %i_local3_54 = add i32 1, %i_local2_53
  store i32 %i_local3_54, i32* %i_global_51
  br label %entry_58
finish_60:
  %Length_65 = call i32 @Stack_GetLength(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %Length_65)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_71 = call i32 @Stack_Pop(%stackType* %stack)
  %second_72 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_66 = alloca i32
  store i32 %top_71, i32* %i_global_66
  br label %entry_73
entry_73:
  %i_local1_67 = load i32, i32* %i_global_66
  %isIGreater_70 = icmp sge i32 %i_local1_67, %second_72
  br i1 %isIGreater_70, label %finish_75, label %loop_74
loop_74:
  %top_76 = call i32 @Stack_Pop(%stackType* %stack)
  %second_77 = call i32 @Stack_Pop(%stackType* %stack)
  %product_78 = mul i32 %second_77, %top_76
  call void @Stack_PushInt(%stackType* %stack, i32 %product_78)
  %i_local2_68 = load i32, i32* %i_global_66
  %i_local3_69 = add i32 1, %i_local2_68
  store i32 %i_local3_69, i32* %i_global_66
  br label %entry_73
finish_75:
  %top_79 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_80 = call i32 @printInt(i32 %top_79)
  ret void
}


define i32 @main(i32 %argc, i8** %argv) {
  ; uses the 
  %stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %stack)
  %return_stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %return_stack)


  ; COMPILED CODE STARTS HERE


  call void @Stack_PushInt(%stackType* %stack, i32 32)
  %top_81 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_81, i32* @.BL
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
  %top_87 = call i32 @Stack_Pop(%stackType* %stack)
  %second_88 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_82 = alloca i32
  store i32 %top_87, i32* %i_global_82
  br label %entry_89
entry_89:
  %i_local1_83 = load i32, i32* %i_global_82
  %isIGreater_86 = icmp sge i32 %i_local1_83, %second_88
  br i1 %isIGreater_86, label %finish_91, label %loop_90
loop_90:
  %i_local_92 = load i32, i32* %i_global_82
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_92)
  %top_93 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_94 = call i32 @printInt(i32 %top_93)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_100 = call i32 @Stack_Pop(%stackType* %stack)
  %second_101 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_95 = alloca i32
  store i32 %top_100, i32* %newIndex_global_95
  br label %entry_102
entry_102:
  %newIndex_local1_96 = load i32, i32* %newIndex_global_95
  %isIGreater_99 = icmp sge i32 %newIndex_local1_96, %second_101
  br i1 %isIGreater_99, label %finish_104, label %loop_103
loop_103:
  %j_local_105 = load i32, i32* %i_global_82
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_105)
  %top_106 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_107 = call i32 @printInt(i32 %top_106)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_113 = call i32 @Stack_Pop(%stackType* %stack)
  %second_114 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_108 = alloca i32
  store i32 %top_113, i32* %newIndex_global_108
  br label %entry_115
entry_115:
  %newIndex_local1_109 = load i32, i32* %newIndex_global_108
  %isIGreater_112 = icmp sge i32 %newIndex_local1_109, %second_114
  br i1 %isIGreater_112, label %finish_117, label %loop_116
loop_116:
  %i_local_118 = load i32, i32* %newIndex_global_108
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_118)
  %top_119 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_120 = call i32 @printInt(i32 %top_119)
  %newIndex_local2_110 = load i32, i32* %newIndex_global_108
  %newIndex_local3_111 = add i32 1, %newIndex_local2_110
  store i32 %newIndex_local3_111, i32* %newIndex_global_108
  br label %entry_115
finish_117:
  %newIndex_local2_97 = load i32, i32* %newIndex_global_95
  %newIndex_local3_98 = add i32 1, %newIndex_local2_97
  store i32 %newIndex_local3_98, i32* %newIndex_global_95
  br label %entry_102
finish_104:
  %i_local2_84 = load i32, i32* %i_global_82
  %i_local3_85 = add i32 1, %i_local2_84
  store i32 %i_local3_85, i32* %i_global_82
  br label %entry_89
finish_91:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_124
entry_124:
  %top_121 = call i32 @Stack_Pop(%stackType* %stack)
  %second_122 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_123 = icmp slt i32 %top_121, %second_122
  br i1 %isSmaller_123, label %topsmaller_125, label %secondsmaller_126
topsmaller_125:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_127
secondsmaller_126:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_127
finish_127:
  %top_131 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_130 = icmp eq i32 %top_131, 0
  br i1 %isZero_130, label %else_block_129, label %if_block_128
if_block_128:
  %top_133 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_134 = call i32 @printInt(i32 %top_133)
  br label %if_exit_132
else_block_129:
  br label %if_exit_132
if_exit_132:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_135 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_135, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_136 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_136, i32* @.DATA
  %var_local_137 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_137)
  %top_138 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_139 = call i32 @printInt(i32 %top_138)
  %var_local_140 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_140)
  %top_141 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_142 = call i32 @printInt(i32 %top_141)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_143 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_143, i32* @.NB
  %var_local_144 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_144)
  %top_145 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_146 = call i32 @printInt(i32 %top_145)
  call void @Stack_PushInt(%stackType* %stack, i32 20)
  %top_147 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_147, i32* @.TWENTY
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  %top_148 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_149 = call i32 @printInt(i32 %top_148)
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  %top_150 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_151 = call i32 @printInt(i32 %top_150)

  ret i32 0
}
