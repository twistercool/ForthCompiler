

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

; returns the length of the stack 
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

define void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 42)
  %top_0 = call i32 @Stack_Pop(%stackType* %stack)
  call i32 @print_ASCII(i32 %top_0)
  ret void
}

define void @Stack_Function_STARS(%stackType* %stack, %stackType* %return_stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  %top_6 = call i32 @Stack_Pop(%stackType* %stack)
  %second_7 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_1 = alloca i32
  store i32 %top_6, i32* %i_global_1
  br label %entry_8
entry_8:
  %i_local1_2 = load i32, i32* %i_global_1
  %isIGreater_5 = icmp sge i32 %i_local1_2, %second_7
  br i1 %isIGreater_5, label %finish_10, label %loop_9
loop_9:
  call void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack)
  %i_local2_3 = load i32, i32* %i_global_1
  %i_local3_4 = add i32 1, %i_local2_3
  store i32 %i_local3_4, i32* %i_global_1
  br label %entry_8
finish_10:
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
  %top_11 = call i32 @Stack_Pop(%stackType* %stack)
  %second_12 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_12)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_11)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_12)
  %top_13 = call i32 @Stack_Pop(%stackType* %stack)
  %second_14 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_14)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_13)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_14)
  %top_15 = call i32 @Stack_Pop(%stackType* %stack)
  %second_16 = call i32 @Stack_Pop(%stackType* %stack)
  %added_17 = add i32 %second_16, %top_15
  call void @Stack_PushInt(%stackType* %stack, i32 %added_17)
  ret void
}

define void @Stack_Function_FIBS(%stackType* %stack, %stackType* %return_stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_18 = call i32 @Stack_Pop(%stackType* %stack)
  %second_19 = call i32 @Stack_Pop(%stackType* %stack)
  %third_20 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_19)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_18)
  call void @Stack_PushInt(%stackType* %stack, i32 %third_20)
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  %top_26 = call i32 @Stack_Pop(%stackType* %stack)
  %second_27 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_21 = alloca i32
  store i32 %top_26, i32* %i_global_21
  br label %entry_28
entry_28:
  %i_local1_22 = load i32, i32* %i_global_21
  %isIGreater_25 = icmp sge i32 %i_local1_22, %second_27
  br i1 %isIGreater_25, label %finish_30, label %loop_29
loop_29:
  call void @Stack_Function_FIB(%stackType* %stack, %stackType* %return_stack)
  %i_local2_23 = load i32, i32* %i_global_21
  %i_local3_24 = add i32 1, %i_local2_23
  store i32 %i_local3_24, i32* %i_global_21
  br label %entry_28
finish_30:
  ret void
}

define void @Stack_Function_FACTORIAL(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %top_31 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_31)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_31)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_37 = call i32 @Stack_Pop(%stackType* %stack)
  %second_38 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_32 = alloca i32
  store i32 %top_37, i32* %i_global_32
  br label %entry_39
entry_39:
  %i_local1_33 = load i32, i32* %i_global_32
  %isIGreater_36 = icmp sge i32 %i_local1_33, %second_38
  br i1 %isIGreater_36, label %finish_41, label %loop_40
loop_40:
  %top_42 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_42)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_42)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_43 = call i32 @Stack_Pop(%stackType* %stack)
  %second_44 = call i32 @Stack_Pop(%stackType* %stack)
  %subvalue_45 = sub i32 %second_44, %top_43
  call void @Stack_PushInt(%stackType* %stack, i32 %subvalue_45)
  %i_local2_34 = load i32, i32* %i_global_32
  %i_local3_35 = add i32 1, %i_local2_34
  store i32 %i_local3_35, i32* %i_global_32
  br label %entry_39
finish_41:
  %Length_46 = call i32 @Stack_GetLength(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %Length_46)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_52 = call i32 @Stack_Pop(%stackType* %stack)
  %second_53 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_47 = alloca i32
  store i32 %top_52, i32* %i_global_47
  br label %entry_54
entry_54:
  %i_local1_48 = load i32, i32* %i_global_47
  %isIGreater_51 = icmp sge i32 %i_local1_48, %second_53
  br i1 %isIGreater_51, label %finish_56, label %loop_55
loop_55:
  %top_57 = call i32 @Stack_Pop(%stackType* %stack)
  %second_58 = call i32 @Stack_Pop(%stackType* %stack)
  %product_59 = mul i32 %second_58, %top_57
  call void @Stack_PushInt(%stackType* %stack, i32 %product_59)
  %i_local2_49 = load i32, i32* %i_global_47
  %i_local3_50 = add i32 1, %i_local2_49
  store i32 %i_local3_50, i32* %i_global_47
  br label %entry_54
finish_56:
  %top_60 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_61 = call i32 @printInt(i32 %top_60)
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
  %top_67 = call i32 @Stack_Pop(%stackType* %stack)
  %second_68 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_62 = alloca i32
  store i32 %top_67, i32* %i_global_62
  br label %entry_69
entry_69:
  %i_local1_63 = load i32, i32* %i_global_62
  %isIGreater_66 = icmp sge i32 %i_local1_63, %second_68
  br i1 %isIGreater_66, label %finish_71, label %loop_70
loop_70:
  %i_local_72 = load i32, i32* %i_global_62
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_72)
  %top_73 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_74 = call i32 @printInt(i32 %top_73)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_80 = call i32 @Stack_Pop(%stackType* %stack)
  %second_81 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_75 = alloca i32
  store i32 %top_80, i32* %newIndex_global_75
  br label %entry_82
entry_82:
  %newIndex_local1_76 = load i32, i32* %newIndex_global_75
  %isIGreater_79 = icmp sge i32 %newIndex_local1_76, %second_81
  br i1 %isIGreater_79, label %finish_84, label %loop_83
loop_83:
  %j_local_85 = load i32, i32* %i_global_62
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_85)
  %top_86 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_87 = call i32 @printInt(i32 %top_86)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_93 = call i32 @Stack_Pop(%stackType* %stack)
  %second_94 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_88 = alloca i32
  store i32 %top_93, i32* %newIndex_global_88
  br label %entry_95
entry_95:
  %newIndex_local1_89 = load i32, i32* %newIndex_global_88
  %isIGreater_92 = icmp sge i32 %newIndex_local1_89, %second_94
  br i1 %isIGreater_92, label %finish_97, label %loop_96
loop_96:
  %i_local_98 = load i32, i32* %newIndex_global_88
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_98)
  %top_99 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_100 = call i32 @printInt(i32 %top_99)
  %newIndex_local2_90 = load i32, i32* %newIndex_global_88
  %newIndex_local3_91 = add i32 1, %newIndex_local2_90
  store i32 %newIndex_local3_91, i32* %newIndex_global_88
  br label %entry_95
finish_97:
  %newIndex_local2_77 = load i32, i32* %newIndex_global_75
  %newIndex_local3_78 = add i32 1, %newIndex_local2_77
  store i32 %newIndex_local3_78, i32* %newIndex_global_75
  br label %entry_82
finish_84:
  %i_local2_64 = load i32, i32* %i_global_62
  %i_local3_65 = add i32 1, %i_local2_64
  store i32 %i_local3_65, i32* %i_global_62
  br label %entry_69
finish_71:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_104
entry_104:
  %top_101 = call i32 @Stack_Pop(%stackType* %stack)
  %second_102 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_103 = icmp slt i32 %top_101, %second_102
  br i1 %isSmaller_103, label %topsmaller_105, label %secondsmaller_106
topsmaller_105:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_107
secondsmaller_106:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_107
finish_107:
  %top_111 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_110 = icmp eq i32 %top_111, 0
  br i1 %isZero_110, label %else_block_109, label %if_block_108
if_block_108:
  %top_113 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_114 = call i32 @printInt(i32 %top_113)
  br label %if_exit_112
else_block_109:
  br label %if_exit_112
if_exit_112:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_115 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_115, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_116 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_116, i32* @.DATA
  %var_local_117 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_117)
  %top_118 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_119 = call i32 @printInt(i32 %top_118)
  %var_local_120 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_120)
  %top_121 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_122 = call i32 @printInt(i32 %top_121)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_123 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_123, i32* @.NB
  %var_local_124 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_124)
  %top_125 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_126 = call i32 @printInt(i32 %top_125)
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
  %top_132 = call i32 @Stack_Pop(%stackType* %stack)
  %second_133 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_127 = alloca i32
  store i32 %top_132, i32* %i_global_127
  br label %entry_134
entry_134:
  %i_local1_128 = load i32, i32* %i_global_127
  %isIGreater_131 = icmp sge i32 %i_local1_128, %second_133
  br i1 %isIGreater_131, label %finish_136, label %loop_135
loop_135:
  %i_local_137 = load i32, i32* %i_global_127
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_137)
  %top_138 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_139 = call i32 @printInt(i32 %top_138)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_145 = call i32 @Stack_Pop(%stackType* %stack)
  %second_146 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_140 = alloca i32
  store i32 %top_145, i32* %newIndex_global_140
  br label %entry_147
entry_147:
  %newIndex_local1_141 = load i32, i32* %newIndex_global_140
  %isIGreater_144 = icmp sge i32 %newIndex_local1_141, %second_146
  br i1 %isIGreater_144, label %finish_149, label %loop_148
loop_148:
  %j_local_150 = load i32, i32* %i_global_127
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_150)
  %top_151 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_152 = call i32 @printInt(i32 %top_151)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_158 = call i32 @Stack_Pop(%stackType* %stack)
  %second_159 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_153 = alloca i32
  store i32 %top_158, i32* %newIndex_global_153
  br label %entry_160
entry_160:
  %newIndex_local1_154 = load i32, i32* %newIndex_global_153
  %isIGreater_157 = icmp sge i32 %newIndex_local1_154, %second_159
  br i1 %isIGreater_157, label %finish_162, label %loop_161
loop_161:
  %i_local_163 = load i32, i32* %newIndex_global_153
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_163)
  %top_164 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_165 = call i32 @printInt(i32 %top_164)
  %newIndex_local2_155 = load i32, i32* %newIndex_global_153
  %newIndex_local3_156 = add i32 1, %newIndex_local2_155
  store i32 %newIndex_local3_156, i32* %newIndex_global_153
  br label %entry_160
finish_162:
  %newIndex_local2_142 = load i32, i32* %newIndex_global_140
  %newIndex_local3_143 = add i32 1, %newIndex_local2_142
  store i32 %newIndex_local3_143, i32* %newIndex_global_140
  br label %entry_147
finish_149:
  %i_local2_129 = load i32, i32* %i_global_127
  %i_local3_130 = add i32 1, %i_local2_129
  store i32 %i_local3_130, i32* %i_global_127
  br label %entry_134
finish_136:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_169
entry_169:
  %top_166 = call i32 @Stack_Pop(%stackType* %stack)
  %second_167 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_168 = icmp slt i32 %top_166, %second_167
  br i1 %isSmaller_168, label %topsmaller_170, label %secondsmaller_171
topsmaller_170:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_172
secondsmaller_171:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_172
finish_172:
  %top_176 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_175 = icmp eq i32 %top_176, 0
  br i1 %isZero_175, label %else_block_174, label %if_block_173
if_block_173:
  %top_178 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_179 = call i32 @printInt(i32 %top_178)
  br label %if_exit_177
else_block_174:
  br label %if_exit_177
if_exit_177:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_180 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_180, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_181 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_181, i32* @.DATA
  %var_local_182 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_182)
  %top_183 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_184 = call i32 @printInt(i32 %top_183)
  %var_local_185 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_185)
  %top_186 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_187 = call i32 @printInt(i32 %top_186)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_188 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_188, i32* @.NB
  %var_local_189 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_189)
  %top_190 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_191 = call i32 @printInt(i32 %top_190)
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
  %top_197 = call i32 @Stack_Pop(%stackType* %stack)
  %second_198 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_192 = alloca i32
  store i32 %top_197, i32* %i_global_192
  br label %entry_199
entry_199:
  %i_local1_193 = load i32, i32* %i_global_192
  %isIGreater_196 = icmp sge i32 %i_local1_193, %second_198
  br i1 %isIGreater_196, label %finish_201, label %loop_200
loop_200:
  %i_local_202 = load i32, i32* %i_global_192
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_202)
  %top_203 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_204 = call i32 @printInt(i32 %top_203)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_210 = call i32 @Stack_Pop(%stackType* %stack)
  %second_211 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_205 = alloca i32
  store i32 %top_210, i32* %newIndex_global_205
  br label %entry_212
entry_212:
  %newIndex_local1_206 = load i32, i32* %newIndex_global_205
  %isIGreater_209 = icmp sge i32 %newIndex_local1_206, %second_211
  br i1 %isIGreater_209, label %finish_214, label %loop_213
loop_213:
  %j_local_215 = load i32, i32* %i_global_192
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_215)
  %top_216 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_217 = call i32 @printInt(i32 %top_216)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_223 = call i32 @Stack_Pop(%stackType* %stack)
  %second_224 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_218 = alloca i32
  store i32 %top_223, i32* %newIndex_global_218
  br label %entry_225
entry_225:
  %newIndex_local1_219 = load i32, i32* %newIndex_global_218
  %isIGreater_222 = icmp sge i32 %newIndex_local1_219, %second_224
  br i1 %isIGreater_222, label %finish_227, label %loop_226
loop_226:
  %i_local_228 = load i32, i32* %newIndex_global_218
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_228)
  %top_229 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_230 = call i32 @printInt(i32 %top_229)
  %newIndex_local2_220 = load i32, i32* %newIndex_global_218
  %newIndex_local3_221 = add i32 1, %newIndex_local2_220
  store i32 %newIndex_local3_221, i32* %newIndex_global_218
  br label %entry_225
finish_227:
  %newIndex_local2_207 = load i32, i32* %newIndex_global_205
  %newIndex_local3_208 = add i32 1, %newIndex_local2_207
  store i32 %newIndex_local3_208, i32* %newIndex_global_205
  br label %entry_212
finish_214:
  %i_local2_194 = load i32, i32* %i_global_192
  %i_local3_195 = add i32 1, %i_local2_194
  store i32 %i_local3_195, i32* %i_global_192
  br label %entry_199
finish_201:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_234
entry_234:
  %top_231 = call i32 @Stack_Pop(%stackType* %stack)
  %second_232 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_233 = icmp slt i32 %top_231, %second_232
  br i1 %isSmaller_233, label %topsmaller_235, label %secondsmaller_236
topsmaller_235:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_237
secondsmaller_236:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_237
finish_237:
  %top_241 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_240 = icmp eq i32 %top_241, 0
  br i1 %isZero_240, label %else_block_239, label %if_block_238
if_block_238:
  %top_243 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_244 = call i32 @printInt(i32 %top_243)
  br label %if_exit_242
else_block_239:
  br label %if_exit_242
if_exit_242:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_245 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_245, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_246 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_246, i32* @.DATA
  %var_local_247 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_247)
  %top_248 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_249 = call i32 @printInt(i32 %top_248)
  %var_local_250 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_250)
  %top_251 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_252 = call i32 @printInt(i32 %top_251)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_253 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_253, i32* @.NB
  %var_local_254 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_254)
  %top_255 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_256 = call i32 @printInt(i32 %top_255)
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
  %top_262 = call i32 @Stack_Pop(%stackType* %stack)
  %second_263 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_257 = alloca i32
  store i32 %top_262, i32* %i_global_257
  br label %entry_264
entry_264:
  %i_local1_258 = load i32, i32* %i_global_257
  %isIGreater_261 = icmp sge i32 %i_local1_258, %second_263
  br i1 %isIGreater_261, label %finish_266, label %loop_265
loop_265:
  %i_local_267 = load i32, i32* %i_global_257
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_267)
  %top_268 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_269 = call i32 @printInt(i32 %top_268)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_275 = call i32 @Stack_Pop(%stackType* %stack)
  %second_276 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_270 = alloca i32
  store i32 %top_275, i32* %newIndex_global_270
  br label %entry_277
entry_277:
  %newIndex_local1_271 = load i32, i32* %newIndex_global_270
  %isIGreater_274 = icmp sge i32 %newIndex_local1_271, %second_276
  br i1 %isIGreater_274, label %finish_279, label %loop_278
loop_278:
  %j_local_280 = load i32, i32* %i_global_257
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_280)
  %top_281 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_282 = call i32 @printInt(i32 %top_281)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_288 = call i32 @Stack_Pop(%stackType* %stack)
  %second_289 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_283 = alloca i32
  store i32 %top_288, i32* %newIndex_global_283
  br label %entry_290
entry_290:
  %newIndex_local1_284 = load i32, i32* %newIndex_global_283
  %isIGreater_287 = icmp sge i32 %newIndex_local1_284, %second_289
  br i1 %isIGreater_287, label %finish_292, label %loop_291
loop_291:
  %i_local_293 = load i32, i32* %newIndex_global_283
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_293)
  %top_294 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_295 = call i32 @printInt(i32 %top_294)
  %newIndex_local2_285 = load i32, i32* %newIndex_global_283
  %newIndex_local3_286 = add i32 1, %newIndex_local2_285
  store i32 %newIndex_local3_286, i32* %newIndex_global_283
  br label %entry_290
finish_292:
  %newIndex_local2_272 = load i32, i32* %newIndex_global_270
  %newIndex_local3_273 = add i32 1, %newIndex_local2_272
  store i32 %newIndex_local3_273, i32* %newIndex_global_270
  br label %entry_277
finish_279:
  %i_local2_259 = load i32, i32* %i_global_257
  %i_local3_260 = add i32 1, %i_local2_259
  store i32 %i_local3_260, i32* %i_global_257
  br label %entry_264
finish_266:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_299
entry_299:
  %top_296 = call i32 @Stack_Pop(%stackType* %stack)
  %second_297 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_298 = icmp slt i32 %top_296, %second_297
  br i1 %isSmaller_298, label %topsmaller_300, label %secondsmaller_301
topsmaller_300:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_302
secondsmaller_301:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_302
finish_302:
  %top_306 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_305 = icmp eq i32 %top_306, 0
  br i1 %isZero_305, label %else_block_304, label %if_block_303
if_block_303:
  %top_308 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_309 = call i32 @printInt(i32 %top_308)
  br label %if_exit_307
else_block_304:
  br label %if_exit_307
if_exit_307:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_310 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_310, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_311 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_311, i32* @.DATA
  %var_local_312 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_312)
  %top_313 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_314 = call i32 @printInt(i32 %top_313)
  %var_local_315 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_315)
  %top_316 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_317 = call i32 @printInt(i32 %top_316)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_318 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_318, i32* @.NB
  %var_local_319 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_319)
  %top_320 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_321 = call i32 @printInt(i32 %top_320)
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
  %top_327 = call i32 @Stack_Pop(%stackType* %stack)
  %second_328 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_322 = alloca i32
  store i32 %top_327, i32* %i_global_322
  br label %entry_329
entry_329:
  %i_local1_323 = load i32, i32* %i_global_322
  %isIGreater_326 = icmp sge i32 %i_local1_323, %second_328
  br i1 %isIGreater_326, label %finish_331, label %loop_330
loop_330:
  %i_local_332 = load i32, i32* %i_global_322
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_332)
  %top_333 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_334 = call i32 @printInt(i32 %top_333)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_340 = call i32 @Stack_Pop(%stackType* %stack)
  %second_341 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_335 = alloca i32
  store i32 %top_340, i32* %newIndex_global_335
  br label %entry_342
entry_342:
  %newIndex_local1_336 = load i32, i32* %newIndex_global_335
  %isIGreater_339 = icmp sge i32 %newIndex_local1_336, %second_341
  br i1 %isIGreater_339, label %finish_344, label %loop_343
loop_343:
  %j_local_345 = load i32, i32* %i_global_322
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_345)
  %top_346 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_347 = call i32 @printInt(i32 %top_346)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_353 = call i32 @Stack_Pop(%stackType* %stack)
  %second_354 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_348 = alloca i32
  store i32 %top_353, i32* %newIndex_global_348
  br label %entry_355
entry_355:
  %newIndex_local1_349 = load i32, i32* %newIndex_global_348
  %isIGreater_352 = icmp sge i32 %newIndex_local1_349, %second_354
  br i1 %isIGreater_352, label %finish_357, label %loop_356
loop_356:
  %i_local_358 = load i32, i32* %newIndex_global_348
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_358)
  %top_359 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_360 = call i32 @printInt(i32 %top_359)
  %newIndex_local2_350 = load i32, i32* %newIndex_global_348
  %newIndex_local3_351 = add i32 1, %newIndex_local2_350
  store i32 %newIndex_local3_351, i32* %newIndex_global_348
  br label %entry_355
finish_357:
  %newIndex_local2_337 = load i32, i32* %newIndex_global_335
  %newIndex_local3_338 = add i32 1, %newIndex_local2_337
  store i32 %newIndex_local3_338, i32* %newIndex_global_335
  br label %entry_342
finish_344:
  %i_local2_324 = load i32, i32* %i_global_322
  %i_local3_325 = add i32 1, %i_local2_324
  store i32 %i_local3_325, i32* %i_global_322
  br label %entry_329
finish_331:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_364
entry_364:
  %top_361 = call i32 @Stack_Pop(%stackType* %stack)
  %second_362 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_363 = icmp slt i32 %top_361, %second_362
  br i1 %isSmaller_363, label %topsmaller_365, label %secondsmaller_366
topsmaller_365:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_367
secondsmaller_366:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_367
finish_367:
  %top_371 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_370 = icmp eq i32 %top_371, 0
  br i1 %isZero_370, label %else_block_369, label %if_block_368
if_block_368:
  %top_373 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_374 = call i32 @printInt(i32 %top_373)
  br label %if_exit_372
else_block_369:
  br label %if_exit_372
if_exit_372:
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
  %top_380 = call i32 @Stack_Pop(%stackType* %stack)
  %second_381 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_375 = alloca i32
  store i32 %top_380, i32* %i_global_375
  br label %entry_382
entry_382:
  %i_local1_376 = load i32, i32* %i_global_375
  %isIGreater_379 = icmp sge i32 %i_local1_376, %second_381
  br i1 %isIGreater_379, label %finish_384, label %loop_383
loop_383:
  %i_local_385 = load i32, i32* %i_global_375
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_385)
  %top_386 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_387 = call i32 @printInt(i32 %top_386)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_393 = call i32 @Stack_Pop(%stackType* %stack)
  %second_394 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_388 = alloca i32
  store i32 %top_393, i32* %newIndex_global_388
  br label %entry_395
entry_395:
  %newIndex_local1_389 = load i32, i32* %newIndex_global_388
  %isIGreater_392 = icmp sge i32 %newIndex_local1_389, %second_394
  br i1 %isIGreater_392, label %finish_397, label %loop_396
loop_396:
  %j_local_398 = load i32, i32* %i_global_375
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_398)
  %top_399 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_400 = call i32 @printInt(i32 %top_399)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_406 = call i32 @Stack_Pop(%stackType* %stack)
  %second_407 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_401 = alloca i32
  store i32 %top_406, i32* %newIndex_global_401
  br label %entry_408
entry_408:
  %newIndex_local1_402 = load i32, i32* %newIndex_global_401
  %isIGreater_405 = icmp sge i32 %newIndex_local1_402, %second_407
  br i1 %isIGreater_405, label %finish_410, label %loop_409
loop_409:
  %i_local_411 = load i32, i32* %newIndex_global_401
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_411)
  %top_412 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_413 = call i32 @printInt(i32 %top_412)
  %newIndex_local2_403 = load i32, i32* %newIndex_global_401
  %newIndex_local3_404 = add i32 1, %newIndex_local2_403
  store i32 %newIndex_local3_404, i32* %newIndex_global_401
  br label %entry_408
finish_410:
  %newIndex_local2_390 = load i32, i32* %newIndex_global_388
  %newIndex_local3_391 = add i32 1, %newIndex_local2_390
  store i32 %newIndex_local3_391, i32* %newIndex_global_388
  br label %entry_395
finish_397:
  %i_local2_377 = load i32, i32* %i_global_375
  %i_local3_378 = add i32 1, %i_local2_377
  store i32 %i_local3_378, i32* %i_global_375
  br label %entry_382
finish_384:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_417
entry_417:
  %top_414 = call i32 @Stack_Pop(%stackType* %stack)
  %second_415 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_416 = icmp slt i32 %top_414, %second_415
  br i1 %isSmaller_416, label %topsmaller_418, label %secondsmaller_419
topsmaller_418:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_420
secondsmaller_419:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_420
finish_420:
  %top_424 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_423 = icmp eq i32 %top_424, 0
  br i1 %isZero_423, label %else_block_422, label %if_block_421
if_block_421:
  %top_426 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_427 = call i32 @printInt(i32 %top_426)
  br label %if_exit_425
else_block_422:
  br label %if_exit_425
if_exit_425:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_428 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_428, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_429 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_429, i32* @.DATA
  %var_local_430 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_430)
  %top_431 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_432 = call i32 @printInt(i32 %top_431)
  %var_local_433 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_433)
  %top_434 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_435 = call i32 @printInt(i32 %top_434)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_436 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_436, i32* @.NB
  %var_local_437 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_437)
  %top_438 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_439 = call i32 @printInt(i32 %top_438)
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
  %top_445 = call i32 @Stack_Pop(%stackType* %stack)
  %second_446 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_440 = alloca i32
  store i32 %top_445, i32* %i_global_440
  br label %entry_447
entry_447:
  %i_local1_441 = load i32, i32* %i_global_440
  %isIGreater_444 = icmp sge i32 %i_local1_441, %second_446
  br i1 %isIGreater_444, label %finish_449, label %loop_448
loop_448:
  %i_local_450 = load i32, i32* %i_global_440
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_450)
  %top_451 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_452 = call i32 @printInt(i32 %top_451)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_458 = call i32 @Stack_Pop(%stackType* %stack)
  %second_459 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_453 = alloca i32
  store i32 %top_458, i32* %newIndex_global_453
  br label %entry_460
entry_460:
  %newIndex_local1_454 = load i32, i32* %newIndex_global_453
  %isIGreater_457 = icmp sge i32 %newIndex_local1_454, %second_459
  br i1 %isIGreater_457, label %finish_462, label %loop_461
loop_461:
  %j_local_463 = load i32, i32* %i_global_440
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_463)
  %top_464 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_465 = call i32 @printInt(i32 %top_464)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_471 = call i32 @Stack_Pop(%stackType* %stack)
  %second_472 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_466 = alloca i32
  store i32 %top_471, i32* %newIndex_global_466
  br label %entry_473
entry_473:
  %newIndex_local1_467 = load i32, i32* %newIndex_global_466
  %isIGreater_470 = icmp sge i32 %newIndex_local1_467, %second_472
  br i1 %isIGreater_470, label %finish_475, label %loop_474
loop_474:
  %i_local_476 = load i32, i32* %newIndex_global_466
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_476)
  %top_477 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_478 = call i32 @printInt(i32 %top_477)
  %newIndex_local2_468 = load i32, i32* %newIndex_global_466
  %newIndex_local3_469 = add i32 1, %newIndex_local2_468
  store i32 %newIndex_local3_469, i32* %newIndex_global_466
  br label %entry_473
finish_475:
  %newIndex_local2_455 = load i32, i32* %newIndex_global_453
  %newIndex_local3_456 = add i32 1, %newIndex_local2_455
  store i32 %newIndex_local3_456, i32* %newIndex_global_453
  br label %entry_460
finish_462:
  %i_local2_442 = load i32, i32* %i_global_440
  %i_local3_443 = add i32 1, %i_local2_442
  store i32 %i_local3_443, i32* %i_global_440
  br label %entry_447
finish_449:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_482
entry_482:
  %top_479 = call i32 @Stack_Pop(%stackType* %stack)
  %second_480 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_481 = icmp slt i32 %top_479, %second_480
  br i1 %isSmaller_481, label %topsmaller_483, label %secondsmaller_484
topsmaller_483:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_485
secondsmaller_484:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_485
finish_485:
  %top_489 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_488 = icmp eq i32 %top_489, 0
  br i1 %isZero_488, label %else_block_487, label %if_block_486
if_block_486:
  %top_491 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_492 = call i32 @printInt(i32 %top_491)
  br label %if_exit_490
else_block_487:
  br label %if_exit_490
if_exit_490:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_493 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_493, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_494 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_494, i32* @.DATA
  %var_local_495 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_495)
  %top_496 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_497 = call i32 @printInt(i32 %top_496)
  %var_local_498 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_498)
  %top_499 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_500 = call i32 @printInt(i32 %top_499)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_501 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_501, i32* @.NB
  %var_local_502 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_502)
  %top_503 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_504 = call i32 @printInt(i32 %top_503)
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
  %top_510 = call i32 @Stack_Pop(%stackType* %stack)
  %second_511 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_505 = alloca i32
  store i32 %top_510, i32* %i_global_505
  br label %entry_512
entry_512:
  %i_local1_506 = load i32, i32* %i_global_505
  %isIGreater_509 = icmp sge i32 %i_local1_506, %second_511
  br i1 %isIGreater_509, label %finish_514, label %loop_513
loop_513:
  %i_local_515 = load i32, i32* %i_global_505
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_515)
  %top_516 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_517 = call i32 @printInt(i32 %top_516)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_523 = call i32 @Stack_Pop(%stackType* %stack)
  %second_524 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_518 = alloca i32
  store i32 %top_523, i32* %newIndex_global_518
  br label %entry_525
entry_525:
  %newIndex_local1_519 = load i32, i32* %newIndex_global_518
  %isIGreater_522 = icmp sge i32 %newIndex_local1_519, %second_524
  br i1 %isIGreater_522, label %finish_527, label %loop_526
loop_526:
  %j_local_528 = load i32, i32* %i_global_505
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_528)
  %top_529 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_530 = call i32 @printInt(i32 %top_529)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_536 = call i32 @Stack_Pop(%stackType* %stack)
  %second_537 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_531 = alloca i32
  store i32 %top_536, i32* %newIndex_global_531
  br label %entry_538
entry_538:
  %newIndex_local1_532 = load i32, i32* %newIndex_global_531
  %isIGreater_535 = icmp sge i32 %newIndex_local1_532, %second_537
  br i1 %isIGreater_535, label %finish_540, label %loop_539
loop_539:
  %i_local_541 = load i32, i32* %newIndex_global_531
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_541)
  %top_542 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_543 = call i32 @printInt(i32 %top_542)
  %newIndex_local2_533 = load i32, i32* %newIndex_global_531
  %newIndex_local3_534 = add i32 1, %newIndex_local2_533
  store i32 %newIndex_local3_534, i32* %newIndex_global_531
  br label %entry_538
finish_540:
  %newIndex_local2_520 = load i32, i32* %newIndex_global_518
  %newIndex_local3_521 = add i32 1, %newIndex_local2_520
  store i32 %newIndex_local3_521, i32* %newIndex_global_518
  br label %entry_525
finish_527:
  %i_local2_507 = load i32, i32* %i_global_505
  %i_local3_508 = add i32 1, %i_local2_507
  store i32 %i_local3_508, i32* %i_global_505
  br label %entry_512
finish_514:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_547
entry_547:
  %top_544 = call i32 @Stack_Pop(%stackType* %stack)
  %second_545 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_546 = icmp slt i32 %top_544, %second_545
  br i1 %isSmaller_546, label %topsmaller_548, label %secondsmaller_549
topsmaller_548:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_550
secondsmaller_549:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_550
finish_550:
  %top_554 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_553 = icmp eq i32 %top_554, 0
  br i1 %isZero_553, label %else_block_552, label %if_block_551
if_block_551:
  %top_556 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_557 = call i32 @printInt(i32 %top_556)
  br label %if_exit_555
else_block_552:
  br label %if_exit_555
if_exit_555:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_558 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_558, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_559 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_559, i32* @.DATA
  %var_local_560 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_560)
  %top_561 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_562 = call i32 @printInt(i32 %top_561)
  %var_local_563 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_563)
  %top_564 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_565 = call i32 @printInt(i32 %top_564)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_566 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_566, i32* @.NB
  %var_local_567 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_567)
  %top_568 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_569 = call i32 @printInt(i32 %top_568)
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
  %top_575 = call i32 @Stack_Pop(%stackType* %stack)
  %second_576 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_570 = alloca i32
  store i32 %top_575, i32* %i_global_570
  br label %entry_577
entry_577:
  %i_local1_571 = load i32, i32* %i_global_570
  %isIGreater_574 = icmp sge i32 %i_local1_571, %second_576
  br i1 %isIGreater_574, label %finish_579, label %loop_578
loop_578:
  %i_local_580 = load i32, i32* %i_global_570
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_580)
  %top_581 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_582 = call i32 @printInt(i32 %top_581)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_588 = call i32 @Stack_Pop(%stackType* %stack)
  %second_589 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_583 = alloca i32
  store i32 %top_588, i32* %newIndex_global_583
  br label %entry_590
entry_590:
  %newIndex_local1_584 = load i32, i32* %newIndex_global_583
  %isIGreater_587 = icmp sge i32 %newIndex_local1_584, %second_589
  br i1 %isIGreater_587, label %finish_592, label %loop_591
loop_591:
  %j_local_593 = load i32, i32* %i_global_570
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_593)
  %top_594 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_595 = call i32 @printInt(i32 %top_594)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_601 = call i32 @Stack_Pop(%stackType* %stack)
  %second_602 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_596 = alloca i32
  store i32 %top_601, i32* %newIndex_global_596
  br label %entry_603
entry_603:
  %newIndex_local1_597 = load i32, i32* %newIndex_global_596
  %isIGreater_600 = icmp sge i32 %newIndex_local1_597, %second_602
  br i1 %isIGreater_600, label %finish_605, label %loop_604
loop_604:
  %i_local_606 = load i32, i32* %newIndex_global_596
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_606)
  %top_607 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_608 = call i32 @printInt(i32 %top_607)
  %newIndex_local2_598 = load i32, i32* %newIndex_global_596
  %newIndex_local3_599 = add i32 1, %newIndex_local2_598
  store i32 %newIndex_local3_599, i32* %newIndex_global_596
  br label %entry_603
finish_605:
  %newIndex_local2_585 = load i32, i32* %newIndex_global_583
  %newIndex_local3_586 = add i32 1, %newIndex_local2_585
  store i32 %newIndex_local3_586, i32* %newIndex_global_583
  br label %entry_590
finish_592:
  %i_local2_572 = load i32, i32* %i_global_570
  %i_local3_573 = add i32 1, %i_local2_572
  store i32 %i_local3_573, i32* %i_global_570
  br label %entry_577
finish_579:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_612
entry_612:
  %top_609 = call i32 @Stack_Pop(%stackType* %stack)
  %second_610 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_611 = icmp slt i32 %top_609, %second_610
  br i1 %isSmaller_611, label %topsmaller_613, label %secondsmaller_614
topsmaller_613:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_615
secondsmaller_614:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_615
finish_615:
  %top_619 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_618 = icmp eq i32 %top_619, 0
  br i1 %isZero_618, label %else_block_617, label %if_block_616
if_block_616:
  %top_621 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_622 = call i32 @printInt(i32 %top_621)
  br label %if_exit_620
else_block_617:
  br label %if_exit_620
if_exit_620:
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
  %top_628 = call i32 @Stack_Pop(%stackType* %stack)
  %second_629 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_623 = alloca i32
  store i32 %top_628, i32* %i_global_623
  br label %entry_630
entry_630:
  %i_local1_624 = load i32, i32* %i_global_623
  %isIGreater_627 = icmp sge i32 %i_local1_624, %second_629
  br i1 %isIGreater_627, label %finish_632, label %loop_631
loop_631:
  %i_local_633 = load i32, i32* %i_global_623
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_633)
  %top_634 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_635 = call i32 @printInt(i32 %top_634)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_641 = call i32 @Stack_Pop(%stackType* %stack)
  %second_642 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_636 = alloca i32
  store i32 %top_641, i32* %newIndex_global_636
  br label %entry_643
entry_643:
  %newIndex_local1_637 = load i32, i32* %newIndex_global_636
  %isIGreater_640 = icmp sge i32 %newIndex_local1_637, %second_642
  br i1 %isIGreater_640, label %finish_645, label %loop_644
loop_644:
  %j_local_646 = load i32, i32* %i_global_623
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_646)
  %top_647 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_648 = call i32 @printInt(i32 %top_647)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_654 = call i32 @Stack_Pop(%stackType* %stack)
  %second_655 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_649 = alloca i32
  store i32 %top_654, i32* %newIndex_global_649
  br label %entry_656
entry_656:
  %newIndex_local1_650 = load i32, i32* %newIndex_global_649
  %isIGreater_653 = icmp sge i32 %newIndex_local1_650, %second_655
  br i1 %isIGreater_653, label %finish_658, label %loop_657
loop_657:
  %i_local_659 = load i32, i32* %newIndex_global_649
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_659)
  %top_660 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_661 = call i32 @printInt(i32 %top_660)
  %newIndex_local2_651 = load i32, i32* %newIndex_global_649
  %newIndex_local3_652 = add i32 1, %newIndex_local2_651
  store i32 %newIndex_local3_652, i32* %newIndex_global_649
  br label %entry_656
finish_658:
  %newIndex_local2_638 = load i32, i32* %newIndex_global_636
  %newIndex_local3_639 = add i32 1, %newIndex_local2_638
  store i32 %newIndex_local3_639, i32* %newIndex_global_636
  br label %entry_643
finish_645:
  %i_local2_625 = load i32, i32* %i_global_623
  %i_local3_626 = add i32 1, %i_local2_625
  store i32 %i_local3_626, i32* %i_global_623
  br label %entry_630
finish_632:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_665
entry_665:
  %top_662 = call i32 @Stack_Pop(%stackType* %stack)
  %second_663 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_664 = icmp slt i32 %top_662, %second_663
  br i1 %isSmaller_664, label %topsmaller_666, label %secondsmaller_667
topsmaller_666:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_668
secondsmaller_667:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_668
finish_668:
  %top_672 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_671 = icmp eq i32 %top_672, 0
  br i1 %isZero_671, label %else_block_670, label %if_block_669
if_block_669:
  %top_674 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_675 = call i32 @printInt(i32 %top_674)
  br label %if_exit_673
else_block_670:
  br label %if_exit_673
if_exit_673:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_676 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_676, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_677 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_677, i32* @.DATA
  %var_local_678 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_678)
  %top_679 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_680 = call i32 @printInt(i32 %top_679)
  %var_local_681 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_681)
  %top_682 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_683 = call i32 @printInt(i32 %top_682)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_684 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_684, i32* @.NB
  %var_local_685 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_685)
  %top_686 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_687 = call i32 @printInt(i32 %top_686)
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
  %top_693 = call i32 @Stack_Pop(%stackType* %stack)
  %second_694 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_688 = alloca i32
  store i32 %top_693, i32* %i_global_688
  br label %entry_695
entry_695:
  %i_local1_689 = load i32, i32* %i_global_688
  %isIGreater_692 = icmp sge i32 %i_local1_689, %second_694
  br i1 %isIGreater_692, label %finish_697, label %loop_696
loop_696:
  %i_local_698 = load i32, i32* %i_global_688
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_698)
  %top_699 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_700 = call i32 @printInt(i32 %top_699)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_706 = call i32 @Stack_Pop(%stackType* %stack)
  %second_707 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_701 = alloca i32
  store i32 %top_706, i32* %newIndex_global_701
  br label %entry_708
entry_708:
  %newIndex_local1_702 = load i32, i32* %newIndex_global_701
  %isIGreater_705 = icmp sge i32 %newIndex_local1_702, %second_707
  br i1 %isIGreater_705, label %finish_710, label %loop_709
loop_709:
  %j_local_711 = load i32, i32* %i_global_688
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_711)
  %top_712 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_713 = call i32 @printInt(i32 %top_712)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_719 = call i32 @Stack_Pop(%stackType* %stack)
  %second_720 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_714 = alloca i32
  store i32 %top_719, i32* %newIndex_global_714
  br label %entry_721
entry_721:
  %newIndex_local1_715 = load i32, i32* %newIndex_global_714
  %isIGreater_718 = icmp sge i32 %newIndex_local1_715, %second_720
  br i1 %isIGreater_718, label %finish_723, label %loop_722
loop_722:
  %i_local_724 = load i32, i32* %newIndex_global_714
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_724)
  %top_725 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_726 = call i32 @printInt(i32 %top_725)
  %newIndex_local2_716 = load i32, i32* %newIndex_global_714
  %newIndex_local3_717 = add i32 1, %newIndex_local2_716
  store i32 %newIndex_local3_717, i32* %newIndex_global_714
  br label %entry_721
finish_723:
  %newIndex_local2_703 = load i32, i32* %newIndex_global_701
  %newIndex_local3_704 = add i32 1, %newIndex_local2_703
  store i32 %newIndex_local3_704, i32* %newIndex_global_701
  br label %entry_708
finish_710:
  %i_local2_690 = load i32, i32* %i_global_688
  %i_local3_691 = add i32 1, %i_local2_690
  store i32 %i_local3_691, i32* %i_global_688
  br label %entry_695
finish_697:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_730
entry_730:
  %top_727 = call i32 @Stack_Pop(%stackType* %stack)
  %second_728 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_729 = icmp slt i32 %top_727, %second_728
  br i1 %isSmaller_729, label %topsmaller_731, label %secondsmaller_732
topsmaller_731:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_733
secondsmaller_732:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_733
finish_733:
  %top_737 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_736 = icmp eq i32 %top_737, 0
  br i1 %isZero_736, label %else_block_735, label %if_block_734
if_block_734:
  %top_739 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_740 = call i32 @printInt(i32 %top_739)
  br label %if_exit_738
else_block_735:
  br label %if_exit_738
if_exit_738:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_741 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_741, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_742 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_742, i32* @.DATA
  %var_local_743 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_743)
  %top_744 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_745 = call i32 @printInt(i32 %top_744)
  %var_local_746 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_746)
  %top_747 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_748 = call i32 @printInt(i32 %top_747)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_749 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_749, i32* @.NB
  %var_local_750 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_750)
  %top_751 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_752 = call i32 @printInt(i32 %top_751)
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
  %top_758 = call i32 @Stack_Pop(%stackType* %stack)
  %second_759 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_753 = alloca i32
  store i32 %top_758, i32* %i_global_753
  br label %entry_760
entry_760:
  %i_local1_754 = load i32, i32* %i_global_753
  %isIGreater_757 = icmp sge i32 %i_local1_754, %second_759
  br i1 %isIGreater_757, label %finish_762, label %loop_761
loop_761:
  %i_local_763 = load i32, i32* %i_global_753
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_763)
  %top_764 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_765 = call i32 @printInt(i32 %top_764)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_771 = call i32 @Stack_Pop(%stackType* %stack)
  %second_772 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_766 = alloca i32
  store i32 %top_771, i32* %newIndex_global_766
  br label %entry_773
entry_773:
  %newIndex_local1_767 = load i32, i32* %newIndex_global_766
  %isIGreater_770 = icmp sge i32 %newIndex_local1_767, %second_772
  br i1 %isIGreater_770, label %finish_775, label %loop_774
loop_774:
  %j_local_776 = load i32, i32* %i_global_753
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_776)
  %top_777 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_778 = call i32 @printInt(i32 %top_777)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_784 = call i32 @Stack_Pop(%stackType* %stack)
  %second_785 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_779 = alloca i32
  store i32 %top_784, i32* %newIndex_global_779
  br label %entry_786
entry_786:
  %newIndex_local1_780 = load i32, i32* %newIndex_global_779
  %isIGreater_783 = icmp sge i32 %newIndex_local1_780, %second_785
  br i1 %isIGreater_783, label %finish_788, label %loop_787
loop_787:
  %i_local_789 = load i32, i32* %newIndex_global_779
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_789)
  %top_790 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_791 = call i32 @printInt(i32 %top_790)
  %newIndex_local2_781 = load i32, i32* %newIndex_global_779
  %newIndex_local3_782 = add i32 1, %newIndex_local2_781
  store i32 %newIndex_local3_782, i32* %newIndex_global_779
  br label %entry_786
finish_788:
  %newIndex_local2_768 = load i32, i32* %newIndex_global_766
  %newIndex_local3_769 = add i32 1, %newIndex_local2_768
  store i32 %newIndex_local3_769, i32* %newIndex_global_766
  br label %entry_773
finish_775:
  %i_local2_755 = load i32, i32* %i_global_753
  %i_local3_756 = add i32 1, %i_local2_755
  store i32 %i_local3_756, i32* %i_global_753
  br label %entry_760
finish_762:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_795
entry_795:
  %top_792 = call i32 @Stack_Pop(%stackType* %stack)
  %second_793 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_794 = icmp slt i32 %top_792, %second_793
  br i1 %isSmaller_794, label %topsmaller_796, label %secondsmaller_797
topsmaller_796:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_798
secondsmaller_797:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_798
finish_798:
  %top_802 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_801 = icmp eq i32 %top_802, 0
  br i1 %isZero_801, label %else_block_800, label %if_block_799
if_block_799:
  %top_804 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_805 = call i32 @printInt(i32 %top_804)
  br label %if_exit_803
else_block_800:
  br label %if_exit_803
if_exit_803:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_806 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_806, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_807 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_807, i32* @.DATA
  %var_local_808 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_808)
  %top_809 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_810 = call i32 @printInt(i32 %top_809)
  %var_local_811 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_811)
  %top_812 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_813 = call i32 @printInt(i32 %top_812)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_814 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_814, i32* @.NB
  %var_local_815 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_815)
  %top_816 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_817 = call i32 @printInt(i32 %top_816)
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
  %top_823 = call i32 @Stack_Pop(%stackType* %stack)
  %second_824 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_818 = alloca i32
  store i32 %top_823, i32* %i_global_818
  br label %entry_825
entry_825:
  %i_local1_819 = load i32, i32* %i_global_818
  %isIGreater_822 = icmp sge i32 %i_local1_819, %second_824
  br i1 %isIGreater_822, label %finish_827, label %loop_826
loop_826:
  %i_local_828 = load i32, i32* %i_global_818
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_828)
  %top_829 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_830 = call i32 @printInt(i32 %top_829)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_836 = call i32 @Stack_Pop(%stackType* %stack)
  %second_837 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_831 = alloca i32
  store i32 %top_836, i32* %newIndex_global_831
  br label %entry_838
entry_838:
  %newIndex_local1_832 = load i32, i32* %newIndex_global_831
  %isIGreater_835 = icmp sge i32 %newIndex_local1_832, %second_837
  br i1 %isIGreater_835, label %finish_840, label %loop_839
loop_839:
  %j_local_841 = load i32, i32* %i_global_818
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_841)
  %top_842 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_843 = call i32 @printInt(i32 %top_842)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_849 = call i32 @Stack_Pop(%stackType* %stack)
  %second_850 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_844 = alloca i32
  store i32 %top_849, i32* %newIndex_global_844
  br label %entry_851
entry_851:
  %newIndex_local1_845 = load i32, i32* %newIndex_global_844
  %isIGreater_848 = icmp sge i32 %newIndex_local1_845, %second_850
  br i1 %isIGreater_848, label %finish_853, label %loop_852
loop_852:
  %i_local_854 = load i32, i32* %newIndex_global_844
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_854)
  %top_855 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_856 = call i32 @printInt(i32 %top_855)
  %newIndex_local2_846 = load i32, i32* %newIndex_global_844
  %newIndex_local3_847 = add i32 1, %newIndex_local2_846
  store i32 %newIndex_local3_847, i32* %newIndex_global_844
  br label %entry_851
finish_853:
  %newIndex_local2_833 = load i32, i32* %newIndex_global_831
  %newIndex_local3_834 = add i32 1, %newIndex_local2_833
  store i32 %newIndex_local3_834, i32* %newIndex_global_831
  br label %entry_838
finish_840:
  %i_local2_820 = load i32, i32* %i_global_818
  %i_local3_821 = add i32 1, %i_local2_820
  store i32 %i_local3_821, i32* %i_global_818
  br label %entry_825
finish_827:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_860
entry_860:
  %top_857 = call i32 @Stack_Pop(%stackType* %stack)
  %second_858 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_859 = icmp slt i32 %top_857, %second_858
  br i1 %isSmaller_859, label %topsmaller_861, label %secondsmaller_862
topsmaller_861:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_863
secondsmaller_862:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_863
finish_863:
  %top_867 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_866 = icmp eq i32 %top_867, 0
  br i1 %isZero_866, label %else_block_865, label %if_block_864
if_block_864:
  %top_869 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_870 = call i32 @printInt(i32 %top_869)
  br label %if_exit_868
else_block_865:
  br label %if_exit_868
if_exit_868:
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
  %top_876 = call i32 @Stack_Pop(%stackType* %stack)
  %second_877 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_871 = alloca i32
  store i32 %top_876, i32* %i_global_871
  br label %entry_878
entry_878:
  %i_local1_872 = load i32, i32* %i_global_871
  %isIGreater_875 = icmp sge i32 %i_local1_872, %second_877
  br i1 %isIGreater_875, label %finish_880, label %loop_879
loop_879:
  %i_local_881 = load i32, i32* %i_global_871
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_881)
  %top_882 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_883 = call i32 @printInt(i32 %top_882)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_889 = call i32 @Stack_Pop(%stackType* %stack)
  %second_890 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_884 = alloca i32
  store i32 %top_889, i32* %newIndex_global_884
  br label %entry_891
entry_891:
  %newIndex_local1_885 = load i32, i32* %newIndex_global_884
  %isIGreater_888 = icmp sge i32 %newIndex_local1_885, %second_890
  br i1 %isIGreater_888, label %finish_893, label %loop_892
loop_892:
  %j_local_894 = load i32, i32* %i_global_871
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_894)
  %top_895 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_896 = call i32 @printInt(i32 %top_895)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_902 = call i32 @Stack_Pop(%stackType* %stack)
  %second_903 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_897 = alloca i32
  store i32 %top_902, i32* %newIndex_global_897
  br label %entry_904
entry_904:
  %newIndex_local1_898 = load i32, i32* %newIndex_global_897
  %isIGreater_901 = icmp sge i32 %newIndex_local1_898, %second_903
  br i1 %isIGreater_901, label %finish_906, label %loop_905
loop_905:
  %i_local_907 = load i32, i32* %newIndex_global_897
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_907)
  %top_908 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_909 = call i32 @printInt(i32 %top_908)
  %newIndex_local2_899 = load i32, i32* %newIndex_global_897
  %newIndex_local3_900 = add i32 1, %newIndex_local2_899
  store i32 %newIndex_local3_900, i32* %newIndex_global_897
  br label %entry_904
finish_906:
  %newIndex_local2_886 = load i32, i32* %newIndex_global_884
  %newIndex_local3_887 = add i32 1, %newIndex_local2_886
  store i32 %newIndex_local3_887, i32* %newIndex_global_884
  br label %entry_891
finish_893:
  %i_local2_873 = load i32, i32* %i_global_871
  %i_local3_874 = add i32 1, %i_local2_873
  store i32 %i_local3_874, i32* %i_global_871
  br label %entry_878
finish_880:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_913
entry_913:
  %top_910 = call i32 @Stack_Pop(%stackType* %stack)
  %second_911 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_912 = icmp slt i32 %top_910, %second_911
  br i1 %isSmaller_912, label %topsmaller_914, label %secondsmaller_915
topsmaller_914:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_916
secondsmaller_915:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_916
finish_916:
  %top_920 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_919 = icmp eq i32 %top_920, 0
  br i1 %isZero_919, label %else_block_918, label %if_block_917
if_block_917:
  %top_922 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_923 = call i32 @printInt(i32 %top_922)
  br label %if_exit_921
else_block_918:
  br label %if_exit_921
if_exit_921:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_924 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_924, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_925 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_925, i32* @.DATA
  %var_local_926 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_926)
  %top_927 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_928 = call i32 @printInt(i32 %top_927)
  %var_local_929 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_929)
  %top_930 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_931 = call i32 @printInt(i32 %top_930)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_932 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_932, i32* @.NB
  %var_local_933 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_933)
  %top_934 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_935 = call i32 @printInt(i32 %top_934)
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
  %top_941 = call i32 @Stack_Pop(%stackType* %stack)
  %second_942 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_936 = alloca i32
  store i32 %top_941, i32* %i_global_936
  br label %entry_943
entry_943:
  %i_local1_937 = load i32, i32* %i_global_936
  %isIGreater_940 = icmp sge i32 %i_local1_937, %second_942
  br i1 %isIGreater_940, label %finish_945, label %loop_944
loop_944:
  %i_local_946 = load i32, i32* %i_global_936
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_946)
  %top_947 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_948 = call i32 @printInt(i32 %top_947)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_954 = call i32 @Stack_Pop(%stackType* %stack)
  %second_955 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_949 = alloca i32
  store i32 %top_954, i32* %newIndex_global_949
  br label %entry_956
entry_956:
  %newIndex_local1_950 = load i32, i32* %newIndex_global_949
  %isIGreater_953 = icmp sge i32 %newIndex_local1_950, %second_955
  br i1 %isIGreater_953, label %finish_958, label %loop_957
loop_957:
  %j_local_959 = load i32, i32* %i_global_936
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_959)
  %top_960 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_961 = call i32 @printInt(i32 %top_960)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_967 = call i32 @Stack_Pop(%stackType* %stack)
  %second_968 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_962 = alloca i32
  store i32 %top_967, i32* %newIndex_global_962
  br label %entry_969
entry_969:
  %newIndex_local1_963 = load i32, i32* %newIndex_global_962
  %isIGreater_966 = icmp sge i32 %newIndex_local1_963, %second_968
  br i1 %isIGreater_966, label %finish_971, label %loop_970
loop_970:
  %i_local_972 = load i32, i32* %newIndex_global_962
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_972)
  %top_973 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_974 = call i32 @printInt(i32 %top_973)
  %newIndex_local2_964 = load i32, i32* %newIndex_global_962
  %newIndex_local3_965 = add i32 1, %newIndex_local2_964
  store i32 %newIndex_local3_965, i32* %newIndex_global_962
  br label %entry_969
finish_971:
  %newIndex_local2_951 = load i32, i32* %newIndex_global_949
  %newIndex_local3_952 = add i32 1, %newIndex_local2_951
  store i32 %newIndex_local3_952, i32* %newIndex_global_949
  br label %entry_956
finish_958:
  %i_local2_938 = load i32, i32* %i_global_936
  %i_local3_939 = add i32 1, %i_local2_938
  store i32 %i_local3_939, i32* %i_global_936
  br label %entry_943
finish_945:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_978
entry_978:
  %top_975 = call i32 @Stack_Pop(%stackType* %stack)
  %second_976 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_977 = icmp slt i32 %top_975, %second_976
  br i1 %isSmaller_977, label %topsmaller_979, label %secondsmaller_980
topsmaller_979:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_981
secondsmaller_980:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_981
finish_981:
  %top_985 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_984 = icmp eq i32 %top_985, 0
  br i1 %isZero_984, label %else_block_983, label %if_block_982
if_block_982:
  %top_987 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_988 = call i32 @printInt(i32 %top_987)
  br label %if_exit_986
else_block_983:
  br label %if_exit_986
if_exit_986:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_989 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_989, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_990 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_990, i32* @.DATA
  %var_local_991 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_991)
  %top_992 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_993 = call i32 @printInt(i32 %top_992)
  %var_local_994 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_994)
  %top_995 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_996 = call i32 @printInt(i32 %top_995)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_997 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_997, i32* @.NB
  %var_local_998 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_998)
  %top_999 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1000 = call i32 @printInt(i32 %top_999)
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
  %top_1006 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1007 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_1001 = alloca i32
  store i32 %top_1006, i32* %i_global_1001
  br label %entry_1008
entry_1008:
  %i_local1_1002 = load i32, i32* %i_global_1001
  %isIGreater_1005 = icmp sge i32 %i_local1_1002, %second_1007
  br i1 %isIGreater_1005, label %finish_1010, label %loop_1009
loop_1009:
  %i_local_1011 = load i32, i32* %i_global_1001
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1011)
  %top_1012 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1013 = call i32 @printInt(i32 %top_1012)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1019 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1020 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1014 = alloca i32
  store i32 %top_1019, i32* %newIndex_global_1014
  br label %entry_1021
entry_1021:
  %newIndex_local1_1015 = load i32, i32* %newIndex_global_1014
  %isIGreater_1018 = icmp sge i32 %newIndex_local1_1015, %second_1020
  br i1 %isIGreater_1018, label %finish_1023, label %loop_1022
loop_1022:
  %j_local_1024 = load i32, i32* %i_global_1001
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_1024)
  %top_1025 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1026 = call i32 @printInt(i32 %top_1025)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1032 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1033 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1027 = alloca i32
  store i32 %top_1032, i32* %newIndex_global_1027
  br label %entry_1034
entry_1034:
  %newIndex_local1_1028 = load i32, i32* %newIndex_global_1027
  %isIGreater_1031 = icmp sge i32 %newIndex_local1_1028, %second_1033
  br i1 %isIGreater_1031, label %finish_1036, label %loop_1035
loop_1035:
  %i_local_1037 = load i32, i32* %newIndex_global_1027
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1037)
  %top_1038 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1039 = call i32 @printInt(i32 %top_1038)
  %newIndex_local2_1029 = load i32, i32* %newIndex_global_1027
  %newIndex_local3_1030 = add i32 1, %newIndex_local2_1029
  store i32 %newIndex_local3_1030, i32* %newIndex_global_1027
  br label %entry_1034
finish_1036:
  %newIndex_local2_1016 = load i32, i32* %newIndex_global_1014
  %newIndex_local3_1017 = add i32 1, %newIndex_local2_1016
  store i32 %newIndex_local3_1017, i32* %newIndex_global_1014
  br label %entry_1021
finish_1023:
  %i_local2_1003 = load i32, i32* %i_global_1001
  %i_local3_1004 = add i32 1, %i_local2_1003
  store i32 %i_local3_1004, i32* %i_global_1001
  br label %entry_1008
finish_1010:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_1043
entry_1043:
  %top_1040 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1041 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_1042 = icmp slt i32 %top_1040, %second_1041
  br i1 %isSmaller_1042, label %topsmaller_1044, label %secondsmaller_1045
topsmaller_1044:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_1046
secondsmaller_1045:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_1046
finish_1046:
  %top_1050 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_1049 = icmp eq i32 %top_1050, 0
  br i1 %isZero_1049, label %else_block_1048, label %if_block_1047
if_block_1047:
  %top_1052 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1053 = call i32 @printInt(i32 %top_1052)
  br label %if_exit_1051
else_block_1048:
  br label %if_exit_1051
if_exit_1051:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_1054 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1054, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_1055 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1055, i32* @.DATA
  %var_local_1056 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1056)
  %top_1057 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1058 = call i32 @printInt(i32 %top_1057)
  %var_local_1059 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1059)
  %top_1060 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1061 = call i32 @printInt(i32 %top_1060)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_1062 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1062, i32* @.NB
  %var_local_1063 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1063)
  %top_1064 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1065 = call i32 @printInt(i32 %top_1064)
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
  %top_1071 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1072 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_1066 = alloca i32
  store i32 %top_1071, i32* %i_global_1066
  br label %entry_1073
entry_1073:
  %i_local1_1067 = load i32, i32* %i_global_1066
  %isIGreater_1070 = icmp sge i32 %i_local1_1067, %second_1072
  br i1 %isIGreater_1070, label %finish_1075, label %loop_1074
loop_1074:
  %i_local_1076 = load i32, i32* %i_global_1066
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1076)
  %top_1077 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1078 = call i32 @printInt(i32 %top_1077)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1084 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1085 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1079 = alloca i32
  store i32 %top_1084, i32* %newIndex_global_1079
  br label %entry_1086
entry_1086:
  %newIndex_local1_1080 = load i32, i32* %newIndex_global_1079
  %isIGreater_1083 = icmp sge i32 %newIndex_local1_1080, %second_1085
  br i1 %isIGreater_1083, label %finish_1088, label %loop_1087
loop_1087:
  %j_local_1089 = load i32, i32* %i_global_1066
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_1089)
  %top_1090 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1091 = call i32 @printInt(i32 %top_1090)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1097 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1098 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1092 = alloca i32
  store i32 %top_1097, i32* %newIndex_global_1092
  br label %entry_1099
entry_1099:
  %newIndex_local1_1093 = load i32, i32* %newIndex_global_1092
  %isIGreater_1096 = icmp sge i32 %newIndex_local1_1093, %second_1098
  br i1 %isIGreater_1096, label %finish_1101, label %loop_1100
loop_1100:
  %i_local_1102 = load i32, i32* %newIndex_global_1092
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1102)
  %top_1103 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1104 = call i32 @printInt(i32 %top_1103)
  %newIndex_local2_1094 = load i32, i32* %newIndex_global_1092
  %newIndex_local3_1095 = add i32 1, %newIndex_local2_1094
  store i32 %newIndex_local3_1095, i32* %newIndex_global_1092
  br label %entry_1099
finish_1101:
  %newIndex_local2_1081 = load i32, i32* %newIndex_global_1079
  %newIndex_local3_1082 = add i32 1, %newIndex_local2_1081
  store i32 %newIndex_local3_1082, i32* %newIndex_global_1079
  br label %entry_1086
finish_1088:
  %i_local2_1068 = load i32, i32* %i_global_1066
  %i_local3_1069 = add i32 1, %i_local2_1068
  store i32 %i_local3_1069, i32* %i_global_1066
  br label %entry_1073
finish_1075:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_1108
entry_1108:
  %top_1105 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1106 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_1107 = icmp slt i32 %top_1105, %second_1106
  br i1 %isSmaller_1107, label %topsmaller_1109, label %secondsmaller_1110
topsmaller_1109:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_1111
secondsmaller_1110:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_1111
finish_1111:
  %top_1115 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_1114 = icmp eq i32 %top_1115, 0
  br i1 %isZero_1114, label %else_block_1113, label %if_block_1112
if_block_1112:
  %top_1117 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1118 = call i32 @printInt(i32 %top_1117)
  br label %if_exit_1116
else_block_1113:
  br label %if_exit_1116
if_exit_1116:
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
  %top_1124 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1125 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_1119 = alloca i32
  store i32 %top_1124, i32* %i_global_1119
  br label %entry_1126
entry_1126:
  %i_local1_1120 = load i32, i32* %i_global_1119
  %isIGreater_1123 = icmp sge i32 %i_local1_1120, %second_1125
  br i1 %isIGreater_1123, label %finish_1128, label %loop_1127
loop_1127:
  %i_local_1129 = load i32, i32* %i_global_1119
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1129)
  %top_1130 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1131 = call i32 @printInt(i32 %top_1130)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1137 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1138 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1132 = alloca i32
  store i32 %top_1137, i32* %newIndex_global_1132
  br label %entry_1139
entry_1139:
  %newIndex_local1_1133 = load i32, i32* %newIndex_global_1132
  %isIGreater_1136 = icmp sge i32 %newIndex_local1_1133, %second_1138
  br i1 %isIGreater_1136, label %finish_1141, label %loop_1140
loop_1140:
  %j_local_1142 = load i32, i32* %i_global_1119
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_1142)
  %top_1143 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1144 = call i32 @printInt(i32 %top_1143)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1150 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1151 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1145 = alloca i32
  store i32 %top_1150, i32* %newIndex_global_1145
  br label %entry_1152
entry_1152:
  %newIndex_local1_1146 = load i32, i32* %newIndex_global_1145
  %isIGreater_1149 = icmp sge i32 %newIndex_local1_1146, %second_1151
  br i1 %isIGreater_1149, label %finish_1154, label %loop_1153
loop_1153:
  %i_local_1155 = load i32, i32* %newIndex_global_1145
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1155)
  %top_1156 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1157 = call i32 @printInt(i32 %top_1156)
  %newIndex_local2_1147 = load i32, i32* %newIndex_global_1145
  %newIndex_local3_1148 = add i32 1, %newIndex_local2_1147
  store i32 %newIndex_local3_1148, i32* %newIndex_global_1145
  br label %entry_1152
finish_1154:
  %newIndex_local2_1134 = load i32, i32* %newIndex_global_1132
  %newIndex_local3_1135 = add i32 1, %newIndex_local2_1134
  store i32 %newIndex_local3_1135, i32* %newIndex_global_1132
  br label %entry_1139
finish_1141:
  %i_local2_1121 = load i32, i32* %i_global_1119
  %i_local3_1122 = add i32 1, %i_local2_1121
  store i32 %i_local3_1122, i32* %i_global_1119
  br label %entry_1126
finish_1128:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_1161
entry_1161:
  %top_1158 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1159 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_1160 = icmp slt i32 %top_1158, %second_1159
  br i1 %isSmaller_1160, label %topsmaller_1162, label %secondsmaller_1163
topsmaller_1162:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_1164
secondsmaller_1163:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_1164
finish_1164:
  %top_1168 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_1167 = icmp eq i32 %top_1168, 0
  br i1 %isZero_1167, label %else_block_1166, label %if_block_1165
if_block_1165:
  %top_1170 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1171 = call i32 @printInt(i32 %top_1170)
  br label %if_exit_1169
else_block_1166:
  br label %if_exit_1169
if_exit_1169:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_1172 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1172, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_1173 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1173, i32* @.DATA
  %var_local_1174 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1174)
  %top_1175 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1176 = call i32 @printInt(i32 %top_1175)
  %var_local_1177 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1177)
  %top_1178 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1179 = call i32 @printInt(i32 %top_1178)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_1180 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1180, i32* @.NB
  %var_local_1181 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1181)
  %top_1182 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1183 = call i32 @printInt(i32 %top_1182)
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
  %top_1189 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1190 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_1184 = alloca i32
  store i32 %top_1189, i32* %i_global_1184
  br label %entry_1191
entry_1191:
  %i_local1_1185 = load i32, i32* %i_global_1184
  %isIGreater_1188 = icmp sge i32 %i_local1_1185, %second_1190
  br i1 %isIGreater_1188, label %finish_1193, label %loop_1192
loop_1192:
  %i_local_1194 = load i32, i32* %i_global_1184
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1194)
  %top_1195 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1196 = call i32 @printInt(i32 %top_1195)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1202 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1203 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1197 = alloca i32
  store i32 %top_1202, i32* %newIndex_global_1197
  br label %entry_1204
entry_1204:
  %newIndex_local1_1198 = load i32, i32* %newIndex_global_1197
  %isIGreater_1201 = icmp sge i32 %newIndex_local1_1198, %second_1203
  br i1 %isIGreater_1201, label %finish_1206, label %loop_1205
loop_1205:
  %j_local_1207 = load i32, i32* %i_global_1184
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_1207)
  %top_1208 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1209 = call i32 @printInt(i32 %top_1208)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1215 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1216 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1210 = alloca i32
  store i32 %top_1215, i32* %newIndex_global_1210
  br label %entry_1217
entry_1217:
  %newIndex_local1_1211 = load i32, i32* %newIndex_global_1210
  %isIGreater_1214 = icmp sge i32 %newIndex_local1_1211, %second_1216
  br i1 %isIGreater_1214, label %finish_1219, label %loop_1218
loop_1218:
  %i_local_1220 = load i32, i32* %newIndex_global_1210
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1220)
  %top_1221 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1222 = call i32 @printInt(i32 %top_1221)
  %newIndex_local2_1212 = load i32, i32* %newIndex_global_1210
  %newIndex_local3_1213 = add i32 1, %newIndex_local2_1212
  store i32 %newIndex_local3_1213, i32* %newIndex_global_1210
  br label %entry_1217
finish_1219:
  %newIndex_local2_1199 = load i32, i32* %newIndex_global_1197
  %newIndex_local3_1200 = add i32 1, %newIndex_local2_1199
  store i32 %newIndex_local3_1200, i32* %newIndex_global_1197
  br label %entry_1204
finish_1206:
  %i_local2_1186 = load i32, i32* %i_global_1184
  %i_local3_1187 = add i32 1, %i_local2_1186
  store i32 %i_local3_1187, i32* %i_global_1184
  br label %entry_1191
finish_1193:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_1226
entry_1226:
  %top_1223 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1224 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_1225 = icmp slt i32 %top_1223, %second_1224
  br i1 %isSmaller_1225, label %topsmaller_1227, label %secondsmaller_1228
topsmaller_1227:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_1229
secondsmaller_1228:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_1229
finish_1229:
  %top_1233 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_1232 = icmp eq i32 %top_1233, 0
  br i1 %isZero_1232, label %else_block_1231, label %if_block_1230
if_block_1230:
  %top_1235 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1236 = call i32 @printInt(i32 %top_1235)
  br label %if_exit_1234
else_block_1231:
  br label %if_exit_1234
if_exit_1234:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_1237 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1237, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_1238 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1238, i32* @.DATA
  %var_local_1239 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1239)
  %top_1240 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1241 = call i32 @printInt(i32 %top_1240)
  %var_local_1242 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1242)
  %top_1243 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1244 = call i32 @printInt(i32 %top_1243)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_1245 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1245, i32* @.NB
  %var_local_1246 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1246)
  %top_1247 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1248 = call i32 @printInt(i32 %top_1247)
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
  %top_1254 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1255 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_1249 = alloca i32
  store i32 %top_1254, i32* %i_global_1249
  br label %entry_1256
entry_1256:
  %i_local1_1250 = load i32, i32* %i_global_1249
  %isIGreater_1253 = icmp sge i32 %i_local1_1250, %second_1255
  br i1 %isIGreater_1253, label %finish_1258, label %loop_1257
loop_1257:
  %i_local_1259 = load i32, i32* %i_global_1249
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1259)
  %top_1260 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1261 = call i32 @printInt(i32 %top_1260)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1267 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1268 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1262 = alloca i32
  store i32 %top_1267, i32* %newIndex_global_1262
  br label %entry_1269
entry_1269:
  %newIndex_local1_1263 = load i32, i32* %newIndex_global_1262
  %isIGreater_1266 = icmp sge i32 %newIndex_local1_1263, %second_1268
  br i1 %isIGreater_1266, label %finish_1271, label %loop_1270
loop_1270:
  %j_local_1272 = load i32, i32* %i_global_1249
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_1272)
  %top_1273 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1274 = call i32 @printInt(i32 %top_1273)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1280 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1281 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1275 = alloca i32
  store i32 %top_1280, i32* %newIndex_global_1275
  br label %entry_1282
entry_1282:
  %newIndex_local1_1276 = load i32, i32* %newIndex_global_1275
  %isIGreater_1279 = icmp sge i32 %newIndex_local1_1276, %second_1281
  br i1 %isIGreater_1279, label %finish_1284, label %loop_1283
loop_1283:
  %i_local_1285 = load i32, i32* %newIndex_global_1275
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1285)
  %top_1286 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1287 = call i32 @printInt(i32 %top_1286)
  %newIndex_local2_1277 = load i32, i32* %newIndex_global_1275
  %newIndex_local3_1278 = add i32 1, %newIndex_local2_1277
  store i32 %newIndex_local3_1278, i32* %newIndex_global_1275
  br label %entry_1282
finish_1284:
  %newIndex_local2_1264 = load i32, i32* %newIndex_global_1262
  %newIndex_local3_1265 = add i32 1, %newIndex_local2_1264
  store i32 %newIndex_local3_1265, i32* %newIndex_global_1262
  br label %entry_1269
finish_1271:
  %i_local2_1251 = load i32, i32* %i_global_1249
  %i_local3_1252 = add i32 1, %i_local2_1251
  store i32 %i_local3_1252, i32* %i_global_1249
  br label %entry_1256
finish_1258:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_1291
entry_1291:
  %top_1288 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1289 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_1290 = icmp slt i32 %top_1288, %second_1289
  br i1 %isSmaller_1290, label %topsmaller_1292, label %secondsmaller_1293
topsmaller_1292:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_1294
secondsmaller_1293:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_1294
finish_1294:
  %top_1298 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_1297 = icmp eq i32 %top_1298, 0
  br i1 %isZero_1297, label %else_block_1296, label %if_block_1295
if_block_1295:
  %top_1300 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1301 = call i32 @printInt(i32 %top_1300)
  br label %if_exit_1299
else_block_1296:
  br label %if_exit_1299
if_exit_1299:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_1302 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1302, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_1303 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1303, i32* @.DATA
  %var_local_1304 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1304)
  %top_1305 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1306 = call i32 @printInt(i32 %top_1305)
  %var_local_1307 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1307)
  %top_1308 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1309 = call i32 @printInt(i32 %top_1308)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_1310 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1310, i32* @.NB
  %var_local_1311 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1311)
  %top_1312 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1313 = call i32 @printInt(i32 %top_1312)
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
  %top_1319 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1320 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_1314 = alloca i32
  store i32 %top_1319, i32* %i_global_1314
  br label %entry_1321
entry_1321:
  %i_local1_1315 = load i32, i32* %i_global_1314
  %isIGreater_1318 = icmp sge i32 %i_local1_1315, %second_1320
  br i1 %isIGreater_1318, label %finish_1323, label %loop_1322
loop_1322:
  %i_local_1324 = load i32, i32* %i_global_1314
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1324)
  %top_1325 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1326 = call i32 @printInt(i32 %top_1325)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1332 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1333 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1327 = alloca i32
  store i32 %top_1332, i32* %newIndex_global_1327
  br label %entry_1334
entry_1334:
  %newIndex_local1_1328 = load i32, i32* %newIndex_global_1327
  %isIGreater_1331 = icmp sge i32 %newIndex_local1_1328, %second_1333
  br i1 %isIGreater_1331, label %finish_1336, label %loop_1335
loop_1335:
  %j_local_1337 = load i32, i32* %i_global_1314
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_1337)
  %top_1338 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1339 = call i32 @printInt(i32 %top_1338)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1345 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1346 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1340 = alloca i32
  store i32 %top_1345, i32* %newIndex_global_1340
  br label %entry_1347
entry_1347:
  %newIndex_local1_1341 = load i32, i32* %newIndex_global_1340
  %isIGreater_1344 = icmp sge i32 %newIndex_local1_1341, %second_1346
  br i1 %isIGreater_1344, label %finish_1349, label %loop_1348
loop_1348:
  %i_local_1350 = load i32, i32* %newIndex_global_1340
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1350)
  %top_1351 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1352 = call i32 @printInt(i32 %top_1351)
  %newIndex_local2_1342 = load i32, i32* %newIndex_global_1340
  %newIndex_local3_1343 = add i32 1, %newIndex_local2_1342
  store i32 %newIndex_local3_1343, i32* %newIndex_global_1340
  br label %entry_1347
finish_1349:
  %newIndex_local2_1329 = load i32, i32* %newIndex_global_1327
  %newIndex_local3_1330 = add i32 1, %newIndex_local2_1329
  store i32 %newIndex_local3_1330, i32* %newIndex_global_1327
  br label %entry_1334
finish_1336:
  %i_local2_1316 = load i32, i32* %i_global_1314
  %i_local3_1317 = add i32 1, %i_local2_1316
  store i32 %i_local3_1317, i32* %i_global_1314
  br label %entry_1321
finish_1323:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_1356
entry_1356:
  %top_1353 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1354 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_1355 = icmp slt i32 %top_1353, %second_1354
  br i1 %isSmaller_1355, label %topsmaller_1357, label %secondsmaller_1358
topsmaller_1357:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_1359
secondsmaller_1358:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_1359
finish_1359:
  %top_1363 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_1362 = icmp eq i32 %top_1363, 0
  br i1 %isZero_1362, label %else_block_1361, label %if_block_1360
if_block_1360:
  %top_1365 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1366 = call i32 @printInt(i32 %top_1365)
  br label %if_exit_1364
else_block_1361:
  br label %if_exit_1364
if_exit_1364:
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
  %top_1372 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1373 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_1367 = alloca i32
  store i32 %top_1372, i32* %i_global_1367
  br label %entry_1374
entry_1374:
  %i_local1_1368 = load i32, i32* %i_global_1367
  %isIGreater_1371 = icmp sge i32 %i_local1_1368, %second_1373
  br i1 %isIGreater_1371, label %finish_1376, label %loop_1375
loop_1375:
  %i_local_1377 = load i32, i32* %i_global_1367
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1377)
  %top_1378 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1379 = call i32 @printInt(i32 %top_1378)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1385 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1386 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1380 = alloca i32
  store i32 %top_1385, i32* %newIndex_global_1380
  br label %entry_1387
entry_1387:
  %newIndex_local1_1381 = load i32, i32* %newIndex_global_1380
  %isIGreater_1384 = icmp sge i32 %newIndex_local1_1381, %second_1386
  br i1 %isIGreater_1384, label %finish_1389, label %loop_1388
loop_1388:
  %j_local_1390 = load i32, i32* %i_global_1367
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_1390)
  %top_1391 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1392 = call i32 @printInt(i32 %top_1391)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1398 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1399 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1393 = alloca i32
  store i32 %top_1398, i32* %newIndex_global_1393
  br label %entry_1400
entry_1400:
  %newIndex_local1_1394 = load i32, i32* %newIndex_global_1393
  %isIGreater_1397 = icmp sge i32 %newIndex_local1_1394, %second_1399
  br i1 %isIGreater_1397, label %finish_1402, label %loop_1401
loop_1401:
  %i_local_1403 = load i32, i32* %newIndex_global_1393
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1403)
  %top_1404 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1405 = call i32 @printInt(i32 %top_1404)
  %newIndex_local2_1395 = load i32, i32* %newIndex_global_1393
  %newIndex_local3_1396 = add i32 1, %newIndex_local2_1395
  store i32 %newIndex_local3_1396, i32* %newIndex_global_1393
  br label %entry_1400
finish_1402:
  %newIndex_local2_1382 = load i32, i32* %newIndex_global_1380
  %newIndex_local3_1383 = add i32 1, %newIndex_local2_1382
  store i32 %newIndex_local3_1383, i32* %newIndex_global_1380
  br label %entry_1387
finish_1389:
  %i_local2_1369 = load i32, i32* %i_global_1367
  %i_local3_1370 = add i32 1, %i_local2_1369
  store i32 %i_local3_1370, i32* %i_global_1367
  br label %entry_1374
finish_1376:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_1409
entry_1409:
  %top_1406 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1407 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_1408 = icmp slt i32 %top_1406, %second_1407
  br i1 %isSmaller_1408, label %topsmaller_1410, label %secondsmaller_1411
topsmaller_1410:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_1412
secondsmaller_1411:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_1412
finish_1412:
  %top_1416 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_1415 = icmp eq i32 %top_1416, 0
  br i1 %isZero_1415, label %else_block_1414, label %if_block_1413
if_block_1413:
  %top_1418 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1419 = call i32 @printInt(i32 %top_1418)
  br label %if_exit_1417
else_block_1414:
  br label %if_exit_1417
if_exit_1417:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_1420 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1420, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_1421 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1421, i32* @.DATA
  %var_local_1422 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1422)
  %top_1423 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1424 = call i32 @printInt(i32 %top_1423)
  %var_local_1425 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1425)
  %top_1426 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1427 = call i32 @printInt(i32 %top_1426)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_1428 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1428, i32* @.NB
  %var_local_1429 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1429)
  %top_1430 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1431 = call i32 @printInt(i32 %top_1430)
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
  %top_1437 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1438 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_1432 = alloca i32
  store i32 %top_1437, i32* %i_global_1432
  br label %entry_1439
entry_1439:
  %i_local1_1433 = load i32, i32* %i_global_1432
  %isIGreater_1436 = icmp sge i32 %i_local1_1433, %second_1438
  br i1 %isIGreater_1436, label %finish_1441, label %loop_1440
loop_1440:
  %i_local_1442 = load i32, i32* %i_global_1432
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1442)
  %top_1443 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1444 = call i32 @printInt(i32 %top_1443)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1450 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1451 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1445 = alloca i32
  store i32 %top_1450, i32* %newIndex_global_1445
  br label %entry_1452
entry_1452:
  %newIndex_local1_1446 = load i32, i32* %newIndex_global_1445
  %isIGreater_1449 = icmp sge i32 %newIndex_local1_1446, %second_1451
  br i1 %isIGreater_1449, label %finish_1454, label %loop_1453
loop_1453:
  %j_local_1455 = load i32, i32* %i_global_1432
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_1455)
  %top_1456 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1457 = call i32 @printInt(i32 %top_1456)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1463 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1464 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1458 = alloca i32
  store i32 %top_1463, i32* %newIndex_global_1458
  br label %entry_1465
entry_1465:
  %newIndex_local1_1459 = load i32, i32* %newIndex_global_1458
  %isIGreater_1462 = icmp sge i32 %newIndex_local1_1459, %second_1464
  br i1 %isIGreater_1462, label %finish_1467, label %loop_1466
loop_1466:
  %i_local_1468 = load i32, i32* %newIndex_global_1458
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1468)
  %top_1469 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1470 = call i32 @printInt(i32 %top_1469)
  %newIndex_local2_1460 = load i32, i32* %newIndex_global_1458
  %newIndex_local3_1461 = add i32 1, %newIndex_local2_1460
  store i32 %newIndex_local3_1461, i32* %newIndex_global_1458
  br label %entry_1465
finish_1467:
  %newIndex_local2_1447 = load i32, i32* %newIndex_global_1445
  %newIndex_local3_1448 = add i32 1, %newIndex_local2_1447
  store i32 %newIndex_local3_1448, i32* %newIndex_global_1445
  br label %entry_1452
finish_1454:
  %i_local2_1434 = load i32, i32* %i_global_1432
  %i_local3_1435 = add i32 1, %i_local2_1434
  store i32 %i_local3_1435, i32* %i_global_1432
  br label %entry_1439
finish_1441:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_1474
entry_1474:
  %top_1471 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1472 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_1473 = icmp slt i32 %top_1471, %second_1472
  br i1 %isSmaller_1473, label %topsmaller_1475, label %secondsmaller_1476
topsmaller_1475:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_1477
secondsmaller_1476:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_1477
finish_1477:
  %top_1481 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_1480 = icmp eq i32 %top_1481, 0
  br i1 %isZero_1480, label %else_block_1479, label %if_block_1478
if_block_1478:
  %top_1483 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1484 = call i32 @printInt(i32 %top_1483)
  br label %if_exit_1482
else_block_1479:
  br label %if_exit_1482
if_exit_1482:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_1485 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1485, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_1486 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1486, i32* @.DATA
  %var_local_1487 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1487)
  %top_1488 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1489 = call i32 @printInt(i32 %top_1488)
  %var_local_1490 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1490)
  %top_1491 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1492 = call i32 @printInt(i32 %top_1491)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_1493 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1493, i32* @.NB
  %var_local_1494 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1494)
  %top_1495 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1496 = call i32 @printInt(i32 %top_1495)
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
  %top_1502 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1503 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_1497 = alloca i32
  store i32 %top_1502, i32* %i_global_1497
  br label %entry_1504
entry_1504:
  %i_local1_1498 = load i32, i32* %i_global_1497
  %isIGreater_1501 = icmp sge i32 %i_local1_1498, %second_1503
  br i1 %isIGreater_1501, label %finish_1506, label %loop_1505
loop_1505:
  %i_local_1507 = load i32, i32* %i_global_1497
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1507)
  %top_1508 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1509 = call i32 @printInt(i32 %top_1508)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1515 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1516 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1510 = alloca i32
  store i32 %top_1515, i32* %newIndex_global_1510
  br label %entry_1517
entry_1517:
  %newIndex_local1_1511 = load i32, i32* %newIndex_global_1510
  %isIGreater_1514 = icmp sge i32 %newIndex_local1_1511, %second_1516
  br i1 %isIGreater_1514, label %finish_1519, label %loop_1518
loop_1518:
  %j_local_1520 = load i32, i32* %i_global_1497
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_1520)
  %top_1521 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1522 = call i32 @printInt(i32 %top_1521)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1528 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1529 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1523 = alloca i32
  store i32 %top_1528, i32* %newIndex_global_1523
  br label %entry_1530
entry_1530:
  %newIndex_local1_1524 = load i32, i32* %newIndex_global_1523
  %isIGreater_1527 = icmp sge i32 %newIndex_local1_1524, %second_1529
  br i1 %isIGreater_1527, label %finish_1532, label %loop_1531
loop_1531:
  %i_local_1533 = load i32, i32* %newIndex_global_1523
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1533)
  %top_1534 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1535 = call i32 @printInt(i32 %top_1534)
  %newIndex_local2_1525 = load i32, i32* %newIndex_global_1523
  %newIndex_local3_1526 = add i32 1, %newIndex_local2_1525
  store i32 %newIndex_local3_1526, i32* %newIndex_global_1523
  br label %entry_1530
finish_1532:
  %newIndex_local2_1512 = load i32, i32* %newIndex_global_1510
  %newIndex_local3_1513 = add i32 1, %newIndex_local2_1512
  store i32 %newIndex_local3_1513, i32* %newIndex_global_1510
  br label %entry_1517
finish_1519:
  %i_local2_1499 = load i32, i32* %i_global_1497
  %i_local3_1500 = add i32 1, %i_local2_1499
  store i32 %i_local3_1500, i32* %i_global_1497
  br label %entry_1504
finish_1506:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_1539
entry_1539:
  %top_1536 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1537 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_1538 = icmp slt i32 %top_1536, %second_1537
  br i1 %isSmaller_1538, label %topsmaller_1540, label %secondsmaller_1541
topsmaller_1540:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_1542
secondsmaller_1541:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_1542
finish_1542:
  %top_1546 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_1545 = icmp eq i32 %top_1546, 0
  br i1 %isZero_1545, label %else_block_1544, label %if_block_1543
if_block_1543:
  %top_1548 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1549 = call i32 @printInt(i32 %top_1548)
  br label %if_exit_1547
else_block_1544:
  br label %if_exit_1547
if_exit_1547:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_1550 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1550, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_1551 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1551, i32* @.DATA
  %var_local_1552 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1552)
  %top_1553 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1554 = call i32 @printInt(i32 %top_1553)
  %var_local_1555 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1555)
  %top_1556 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1557 = call i32 @printInt(i32 %top_1556)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_1558 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1558, i32* @.NB
  %var_local_1559 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1559)
  %top_1560 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1561 = call i32 @printInt(i32 %top_1560)
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
  %top_1567 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1568 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_1562 = alloca i32
  store i32 %top_1567, i32* %i_global_1562
  br label %entry_1569
entry_1569:
  %i_local1_1563 = load i32, i32* %i_global_1562
  %isIGreater_1566 = icmp sge i32 %i_local1_1563, %second_1568
  br i1 %isIGreater_1566, label %finish_1571, label %loop_1570
loop_1570:
  %i_local_1572 = load i32, i32* %i_global_1562
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1572)
  %top_1573 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1574 = call i32 @printInt(i32 %top_1573)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1580 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1581 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1575 = alloca i32
  store i32 %top_1580, i32* %newIndex_global_1575
  br label %entry_1582
entry_1582:
  %newIndex_local1_1576 = load i32, i32* %newIndex_global_1575
  %isIGreater_1579 = icmp sge i32 %newIndex_local1_1576, %second_1581
  br i1 %isIGreater_1579, label %finish_1584, label %loop_1583
loop_1583:
  %j_local_1585 = load i32, i32* %i_global_1562
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_1585)
  %top_1586 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1587 = call i32 @printInt(i32 %top_1586)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1593 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1594 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1588 = alloca i32
  store i32 %top_1593, i32* %newIndex_global_1588
  br label %entry_1595
entry_1595:
  %newIndex_local1_1589 = load i32, i32* %newIndex_global_1588
  %isIGreater_1592 = icmp sge i32 %newIndex_local1_1589, %second_1594
  br i1 %isIGreater_1592, label %finish_1597, label %loop_1596
loop_1596:
  %i_local_1598 = load i32, i32* %newIndex_global_1588
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1598)
  %top_1599 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1600 = call i32 @printInt(i32 %top_1599)
  %newIndex_local2_1590 = load i32, i32* %newIndex_global_1588
  %newIndex_local3_1591 = add i32 1, %newIndex_local2_1590
  store i32 %newIndex_local3_1591, i32* %newIndex_global_1588
  br label %entry_1595
finish_1597:
  %newIndex_local2_1577 = load i32, i32* %newIndex_global_1575
  %newIndex_local3_1578 = add i32 1, %newIndex_local2_1577
  store i32 %newIndex_local3_1578, i32* %newIndex_global_1575
  br label %entry_1582
finish_1584:
  %i_local2_1564 = load i32, i32* %i_global_1562
  %i_local3_1565 = add i32 1, %i_local2_1564
  store i32 %i_local3_1565, i32* %i_global_1562
  br label %entry_1569
finish_1571:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_1604
entry_1604:
  %top_1601 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1602 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_1603 = icmp slt i32 %top_1601, %second_1602
  br i1 %isSmaller_1603, label %topsmaller_1605, label %secondsmaller_1606
topsmaller_1605:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_1607
secondsmaller_1606:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_1607
finish_1607:
  %top_1611 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_1610 = icmp eq i32 %top_1611, 0
  br i1 %isZero_1610, label %else_block_1609, label %if_block_1608
if_block_1608:
  %top_1613 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1614 = call i32 @printInt(i32 %top_1613)
  br label %if_exit_1612
else_block_1609:
  br label %if_exit_1612
if_exit_1612:
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
  %top_1620 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1621 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_1615 = alloca i32
  store i32 %top_1620, i32* %i_global_1615
  br label %entry_1622
entry_1622:
  %i_local1_1616 = load i32, i32* %i_global_1615
  %isIGreater_1619 = icmp sge i32 %i_local1_1616, %second_1621
  br i1 %isIGreater_1619, label %finish_1624, label %loop_1623
loop_1623:
  %i_local_1625 = load i32, i32* %i_global_1615
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1625)
  %top_1626 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1627 = call i32 @printInt(i32 %top_1626)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1633 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1634 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1628 = alloca i32
  store i32 %top_1633, i32* %newIndex_global_1628
  br label %entry_1635
entry_1635:
  %newIndex_local1_1629 = load i32, i32* %newIndex_global_1628
  %isIGreater_1632 = icmp sge i32 %newIndex_local1_1629, %second_1634
  br i1 %isIGreater_1632, label %finish_1637, label %loop_1636
loop_1636:
  %j_local_1638 = load i32, i32* %i_global_1615
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_1638)
  %top_1639 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1640 = call i32 @printInt(i32 %top_1639)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1646 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1647 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1641 = alloca i32
  store i32 %top_1646, i32* %newIndex_global_1641
  br label %entry_1648
entry_1648:
  %newIndex_local1_1642 = load i32, i32* %newIndex_global_1641
  %isIGreater_1645 = icmp sge i32 %newIndex_local1_1642, %second_1647
  br i1 %isIGreater_1645, label %finish_1650, label %loop_1649
loop_1649:
  %i_local_1651 = load i32, i32* %newIndex_global_1641
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1651)
  %top_1652 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1653 = call i32 @printInt(i32 %top_1652)
  %newIndex_local2_1643 = load i32, i32* %newIndex_global_1641
  %newIndex_local3_1644 = add i32 1, %newIndex_local2_1643
  store i32 %newIndex_local3_1644, i32* %newIndex_global_1641
  br label %entry_1648
finish_1650:
  %newIndex_local2_1630 = load i32, i32* %newIndex_global_1628
  %newIndex_local3_1631 = add i32 1, %newIndex_local2_1630
  store i32 %newIndex_local3_1631, i32* %newIndex_global_1628
  br label %entry_1635
finish_1637:
  %i_local2_1617 = load i32, i32* %i_global_1615
  %i_local3_1618 = add i32 1, %i_local2_1617
  store i32 %i_local3_1618, i32* %i_global_1615
  br label %entry_1622
finish_1624:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_1657
entry_1657:
  %top_1654 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1655 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_1656 = icmp slt i32 %top_1654, %second_1655
  br i1 %isSmaller_1656, label %topsmaller_1658, label %secondsmaller_1659
topsmaller_1658:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_1660
secondsmaller_1659:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_1660
finish_1660:
  %top_1664 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_1663 = icmp eq i32 %top_1664, 0
  br i1 %isZero_1663, label %else_block_1662, label %if_block_1661
if_block_1661:
  %top_1666 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1667 = call i32 @printInt(i32 %top_1666)
  br label %if_exit_1665
else_block_1662:
  br label %if_exit_1665
if_exit_1665:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_1668 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1668, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_1669 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1669, i32* @.DATA
  %var_local_1670 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1670)
  %top_1671 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1672 = call i32 @printInt(i32 %top_1671)
  %var_local_1673 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1673)
  %top_1674 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1675 = call i32 @printInt(i32 %top_1674)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_1676 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1676, i32* @.NB
  %var_local_1677 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1677)
  %top_1678 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1679 = call i32 @printInt(i32 %top_1678)
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
  %top_1685 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1686 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_1680 = alloca i32
  store i32 %top_1685, i32* %i_global_1680
  br label %entry_1687
entry_1687:
  %i_local1_1681 = load i32, i32* %i_global_1680
  %isIGreater_1684 = icmp sge i32 %i_local1_1681, %second_1686
  br i1 %isIGreater_1684, label %finish_1689, label %loop_1688
loop_1688:
  %i_local_1690 = load i32, i32* %i_global_1680
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1690)
  %top_1691 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1692 = call i32 @printInt(i32 %top_1691)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1698 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1699 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1693 = alloca i32
  store i32 %top_1698, i32* %newIndex_global_1693
  br label %entry_1700
entry_1700:
  %newIndex_local1_1694 = load i32, i32* %newIndex_global_1693
  %isIGreater_1697 = icmp sge i32 %newIndex_local1_1694, %second_1699
  br i1 %isIGreater_1697, label %finish_1702, label %loop_1701
loop_1701:
  %j_local_1703 = load i32, i32* %i_global_1680
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_1703)
  %top_1704 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1705 = call i32 @printInt(i32 %top_1704)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1711 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1712 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1706 = alloca i32
  store i32 %top_1711, i32* %newIndex_global_1706
  br label %entry_1713
entry_1713:
  %newIndex_local1_1707 = load i32, i32* %newIndex_global_1706
  %isIGreater_1710 = icmp sge i32 %newIndex_local1_1707, %second_1712
  br i1 %isIGreater_1710, label %finish_1715, label %loop_1714
loop_1714:
  %i_local_1716 = load i32, i32* %newIndex_global_1706
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1716)
  %top_1717 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1718 = call i32 @printInt(i32 %top_1717)
  %newIndex_local2_1708 = load i32, i32* %newIndex_global_1706
  %newIndex_local3_1709 = add i32 1, %newIndex_local2_1708
  store i32 %newIndex_local3_1709, i32* %newIndex_global_1706
  br label %entry_1713
finish_1715:
  %newIndex_local2_1695 = load i32, i32* %newIndex_global_1693
  %newIndex_local3_1696 = add i32 1, %newIndex_local2_1695
  store i32 %newIndex_local3_1696, i32* %newIndex_global_1693
  br label %entry_1700
finish_1702:
  %i_local2_1682 = load i32, i32* %i_global_1680
  %i_local3_1683 = add i32 1, %i_local2_1682
  store i32 %i_local3_1683, i32* %i_global_1680
  br label %entry_1687
finish_1689:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_1722
entry_1722:
  %top_1719 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1720 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_1721 = icmp slt i32 %top_1719, %second_1720
  br i1 %isSmaller_1721, label %topsmaller_1723, label %secondsmaller_1724
topsmaller_1723:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_1725
secondsmaller_1724:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_1725
finish_1725:
  %top_1729 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_1728 = icmp eq i32 %top_1729, 0
  br i1 %isZero_1728, label %else_block_1727, label %if_block_1726
if_block_1726:
  %top_1731 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1732 = call i32 @printInt(i32 %top_1731)
  br label %if_exit_1730
else_block_1727:
  br label %if_exit_1730
if_exit_1730:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_1733 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1733, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_1734 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1734, i32* @.DATA
  %var_local_1735 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1735)
  %top_1736 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1737 = call i32 @printInt(i32 %top_1736)
  %var_local_1738 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1738)
  %top_1739 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1740 = call i32 @printInt(i32 %top_1739)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_1741 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1741, i32* @.NB
  %var_local_1742 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1742)
  %top_1743 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1744 = call i32 @printInt(i32 %top_1743)
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
  %top_1750 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1751 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_1745 = alloca i32
  store i32 %top_1750, i32* %i_global_1745
  br label %entry_1752
entry_1752:
  %i_local1_1746 = load i32, i32* %i_global_1745
  %isIGreater_1749 = icmp sge i32 %i_local1_1746, %second_1751
  br i1 %isIGreater_1749, label %finish_1754, label %loop_1753
loop_1753:
  %i_local_1755 = load i32, i32* %i_global_1745
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1755)
  %top_1756 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1757 = call i32 @printInt(i32 %top_1756)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1763 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1764 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1758 = alloca i32
  store i32 %top_1763, i32* %newIndex_global_1758
  br label %entry_1765
entry_1765:
  %newIndex_local1_1759 = load i32, i32* %newIndex_global_1758
  %isIGreater_1762 = icmp sge i32 %newIndex_local1_1759, %second_1764
  br i1 %isIGreater_1762, label %finish_1767, label %loop_1766
loop_1766:
  %j_local_1768 = load i32, i32* %i_global_1745
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_1768)
  %top_1769 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1770 = call i32 @printInt(i32 %top_1769)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1776 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1777 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1771 = alloca i32
  store i32 %top_1776, i32* %newIndex_global_1771
  br label %entry_1778
entry_1778:
  %newIndex_local1_1772 = load i32, i32* %newIndex_global_1771
  %isIGreater_1775 = icmp sge i32 %newIndex_local1_1772, %second_1777
  br i1 %isIGreater_1775, label %finish_1780, label %loop_1779
loop_1779:
  %i_local_1781 = load i32, i32* %newIndex_global_1771
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1781)
  %top_1782 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1783 = call i32 @printInt(i32 %top_1782)
  %newIndex_local2_1773 = load i32, i32* %newIndex_global_1771
  %newIndex_local3_1774 = add i32 1, %newIndex_local2_1773
  store i32 %newIndex_local3_1774, i32* %newIndex_global_1771
  br label %entry_1778
finish_1780:
  %newIndex_local2_1760 = load i32, i32* %newIndex_global_1758
  %newIndex_local3_1761 = add i32 1, %newIndex_local2_1760
  store i32 %newIndex_local3_1761, i32* %newIndex_global_1758
  br label %entry_1765
finish_1767:
  %i_local2_1747 = load i32, i32* %i_global_1745
  %i_local3_1748 = add i32 1, %i_local2_1747
  store i32 %i_local3_1748, i32* %i_global_1745
  br label %entry_1752
finish_1754:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_1787
entry_1787:
  %top_1784 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1785 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_1786 = icmp slt i32 %top_1784, %second_1785
  br i1 %isSmaller_1786, label %topsmaller_1788, label %secondsmaller_1789
topsmaller_1788:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_1790
secondsmaller_1789:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_1790
finish_1790:
  %top_1794 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_1793 = icmp eq i32 %top_1794, 0
  br i1 %isZero_1793, label %else_block_1792, label %if_block_1791
if_block_1791:
  %top_1796 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1797 = call i32 @printInt(i32 %top_1796)
  br label %if_exit_1795
else_block_1792:
  br label %if_exit_1795
if_exit_1795:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_1798 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1798, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_1799 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1799, i32* @.DATA
  %var_local_1800 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1800)
  %top_1801 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1802 = call i32 @printInt(i32 %top_1801)
  %var_local_1803 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1803)
  %top_1804 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1805 = call i32 @printInt(i32 %top_1804)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_1806 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1806, i32* @.NB
  %var_local_1807 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1807)
  %top_1808 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1809 = call i32 @printInt(i32 %top_1808)
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
  %top_1815 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1816 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_1810 = alloca i32
  store i32 %top_1815, i32* %i_global_1810
  br label %entry_1817
entry_1817:
  %i_local1_1811 = load i32, i32* %i_global_1810
  %isIGreater_1814 = icmp sge i32 %i_local1_1811, %second_1816
  br i1 %isIGreater_1814, label %finish_1819, label %loop_1818
loop_1818:
  %i_local_1820 = load i32, i32* %i_global_1810
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1820)
  %top_1821 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1822 = call i32 @printInt(i32 %top_1821)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1828 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1829 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1823 = alloca i32
  store i32 %top_1828, i32* %newIndex_global_1823
  br label %entry_1830
entry_1830:
  %newIndex_local1_1824 = load i32, i32* %newIndex_global_1823
  %isIGreater_1827 = icmp sge i32 %newIndex_local1_1824, %second_1829
  br i1 %isIGreater_1827, label %finish_1832, label %loop_1831
loop_1831:
  %j_local_1833 = load i32, i32* %i_global_1810
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_1833)
  %top_1834 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1835 = call i32 @printInt(i32 %top_1834)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1841 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1842 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1836 = alloca i32
  store i32 %top_1841, i32* %newIndex_global_1836
  br label %entry_1843
entry_1843:
  %newIndex_local1_1837 = load i32, i32* %newIndex_global_1836
  %isIGreater_1840 = icmp sge i32 %newIndex_local1_1837, %second_1842
  br i1 %isIGreater_1840, label %finish_1845, label %loop_1844
loop_1844:
  %i_local_1846 = load i32, i32* %newIndex_global_1836
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1846)
  %top_1847 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1848 = call i32 @printInt(i32 %top_1847)
  %newIndex_local2_1838 = load i32, i32* %newIndex_global_1836
  %newIndex_local3_1839 = add i32 1, %newIndex_local2_1838
  store i32 %newIndex_local3_1839, i32* %newIndex_global_1836
  br label %entry_1843
finish_1845:
  %newIndex_local2_1825 = load i32, i32* %newIndex_global_1823
  %newIndex_local3_1826 = add i32 1, %newIndex_local2_1825
  store i32 %newIndex_local3_1826, i32* %newIndex_global_1823
  br label %entry_1830
finish_1832:
  %i_local2_1812 = load i32, i32* %i_global_1810
  %i_local3_1813 = add i32 1, %i_local2_1812
  store i32 %i_local3_1813, i32* %i_global_1810
  br label %entry_1817
finish_1819:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_1852
entry_1852:
  %top_1849 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1850 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_1851 = icmp slt i32 %top_1849, %second_1850
  br i1 %isSmaller_1851, label %topsmaller_1853, label %secondsmaller_1854
topsmaller_1853:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_1855
secondsmaller_1854:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_1855
finish_1855:
  %top_1859 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_1858 = icmp eq i32 %top_1859, 0
  br i1 %isZero_1858, label %else_block_1857, label %if_block_1856
if_block_1856:
  %top_1861 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1862 = call i32 @printInt(i32 %top_1861)
  br label %if_exit_1860
else_block_1857:
  br label %if_exit_1860
if_exit_1860:
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
  %top_1868 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1869 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_1863 = alloca i32
  store i32 %top_1868, i32* %i_global_1863
  br label %entry_1870
entry_1870:
  %i_local1_1864 = load i32, i32* %i_global_1863
  %isIGreater_1867 = icmp sge i32 %i_local1_1864, %second_1869
  br i1 %isIGreater_1867, label %finish_1872, label %loop_1871
loop_1871:
  %i_local_1873 = load i32, i32* %i_global_1863
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1873)
  %top_1874 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1875 = call i32 @printInt(i32 %top_1874)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1881 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1882 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1876 = alloca i32
  store i32 %top_1881, i32* %newIndex_global_1876
  br label %entry_1883
entry_1883:
  %newIndex_local1_1877 = load i32, i32* %newIndex_global_1876
  %isIGreater_1880 = icmp sge i32 %newIndex_local1_1877, %second_1882
  br i1 %isIGreater_1880, label %finish_1885, label %loop_1884
loop_1884:
  %j_local_1886 = load i32, i32* %i_global_1863
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_1886)
  %top_1887 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1888 = call i32 @printInt(i32 %top_1887)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1894 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1895 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1889 = alloca i32
  store i32 %top_1894, i32* %newIndex_global_1889
  br label %entry_1896
entry_1896:
  %newIndex_local1_1890 = load i32, i32* %newIndex_global_1889
  %isIGreater_1893 = icmp sge i32 %newIndex_local1_1890, %second_1895
  br i1 %isIGreater_1893, label %finish_1898, label %loop_1897
loop_1897:
  %i_local_1899 = load i32, i32* %newIndex_global_1889
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1899)
  %top_1900 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1901 = call i32 @printInt(i32 %top_1900)
  %newIndex_local2_1891 = load i32, i32* %newIndex_global_1889
  %newIndex_local3_1892 = add i32 1, %newIndex_local2_1891
  store i32 %newIndex_local3_1892, i32* %newIndex_global_1889
  br label %entry_1896
finish_1898:
  %newIndex_local2_1878 = load i32, i32* %newIndex_global_1876
  %newIndex_local3_1879 = add i32 1, %newIndex_local2_1878
  store i32 %newIndex_local3_1879, i32* %newIndex_global_1876
  br label %entry_1883
finish_1885:
  %i_local2_1865 = load i32, i32* %i_global_1863
  %i_local3_1866 = add i32 1, %i_local2_1865
  store i32 %i_local3_1866, i32* %i_global_1863
  br label %entry_1870
finish_1872:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_1905
entry_1905:
  %top_1902 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1903 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_1904 = icmp slt i32 %top_1902, %second_1903
  br i1 %isSmaller_1904, label %topsmaller_1906, label %secondsmaller_1907
topsmaller_1906:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_1908
secondsmaller_1907:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_1908
finish_1908:
  %top_1912 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_1911 = icmp eq i32 %top_1912, 0
  br i1 %isZero_1911, label %else_block_1910, label %if_block_1909
if_block_1909:
  %top_1914 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1915 = call i32 @printInt(i32 %top_1914)
  br label %if_exit_1913
else_block_1910:
  br label %if_exit_1913
if_exit_1913:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_1916 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1916, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_1917 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1917, i32* @.DATA
  %var_local_1918 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1918)
  %top_1919 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1920 = call i32 @printInt(i32 %top_1919)
  %var_local_1921 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1921)
  %top_1922 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1923 = call i32 @printInt(i32 %top_1922)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_1924 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1924, i32* @.NB
  %var_local_1925 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1925)
  %top_1926 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1927 = call i32 @printInt(i32 %top_1926)
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
  %top_1933 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1934 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_1928 = alloca i32
  store i32 %top_1933, i32* %i_global_1928
  br label %entry_1935
entry_1935:
  %i_local1_1929 = load i32, i32* %i_global_1928
  %isIGreater_1932 = icmp sge i32 %i_local1_1929, %second_1934
  br i1 %isIGreater_1932, label %finish_1937, label %loop_1936
loop_1936:
  %i_local_1938 = load i32, i32* %i_global_1928
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1938)
  %top_1939 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1940 = call i32 @printInt(i32 %top_1939)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1946 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1947 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1941 = alloca i32
  store i32 %top_1946, i32* %newIndex_global_1941
  br label %entry_1948
entry_1948:
  %newIndex_local1_1942 = load i32, i32* %newIndex_global_1941
  %isIGreater_1945 = icmp sge i32 %newIndex_local1_1942, %second_1947
  br i1 %isIGreater_1945, label %finish_1950, label %loop_1949
loop_1949:
  %j_local_1951 = load i32, i32* %i_global_1928
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_1951)
  %top_1952 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1953 = call i32 @printInt(i32 %top_1952)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_1959 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1960 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_1954 = alloca i32
  store i32 %top_1959, i32* %newIndex_global_1954
  br label %entry_1961
entry_1961:
  %newIndex_local1_1955 = load i32, i32* %newIndex_global_1954
  %isIGreater_1958 = icmp sge i32 %newIndex_local1_1955, %second_1960
  br i1 %isIGreater_1958, label %finish_1963, label %loop_1962
loop_1962:
  %i_local_1964 = load i32, i32* %newIndex_global_1954
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_1964)
  %top_1965 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1966 = call i32 @printInt(i32 %top_1965)
  %newIndex_local2_1956 = load i32, i32* %newIndex_global_1954
  %newIndex_local3_1957 = add i32 1, %newIndex_local2_1956
  store i32 %newIndex_local3_1957, i32* %newIndex_global_1954
  br label %entry_1961
finish_1963:
  %newIndex_local2_1943 = load i32, i32* %newIndex_global_1941
  %newIndex_local3_1944 = add i32 1, %newIndex_local2_1943
  store i32 %newIndex_local3_1944, i32* %newIndex_global_1941
  br label %entry_1948
finish_1950:
  %i_local2_1930 = load i32, i32* %i_global_1928
  %i_local3_1931 = add i32 1, %i_local2_1930
  store i32 %i_local3_1931, i32* %i_global_1928
  br label %entry_1935
finish_1937:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_1970
entry_1970:
  %top_1967 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1968 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_1969 = icmp slt i32 %top_1967, %second_1968
  br i1 %isSmaller_1969, label %topsmaller_1971, label %secondsmaller_1972
topsmaller_1971:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_1973
secondsmaller_1972:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_1973
finish_1973:
  %top_1977 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_1976 = icmp eq i32 %top_1977, 0
  br i1 %isZero_1976, label %else_block_1975, label %if_block_1974
if_block_1974:
  %top_1979 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1980 = call i32 @printInt(i32 %top_1979)
  br label %if_exit_1978
else_block_1975:
  br label %if_exit_1978
if_exit_1978:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_1981 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1981, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_1982 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1982, i32* @.DATA
  %var_local_1983 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1983)
  %top_1984 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1985 = call i32 @printInt(i32 %top_1984)
  %var_local_1986 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1986)
  %top_1987 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1988 = call i32 @printInt(i32 %top_1987)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_1989 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1989, i32* @.NB
  %var_local_1990 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_1990)
  %top_1991 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_1992 = call i32 @printInt(i32 %top_1991)
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
  %top_1998 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1999 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_1993 = alloca i32
  store i32 %top_1998, i32* %i_global_1993
  br label %entry_2000
entry_2000:
  %i_local1_1994 = load i32, i32* %i_global_1993
  %isIGreater_1997 = icmp sge i32 %i_local1_1994, %second_1999
  br i1 %isIGreater_1997, label %finish_2002, label %loop_2001
loop_2001:
  %i_local_2003 = load i32, i32* %i_global_1993
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_2003)
  %top_2004 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_2005 = call i32 @printInt(i32 %top_2004)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_2011 = call i32 @Stack_Pop(%stackType* %stack)
  %second_2012 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_2006 = alloca i32
  store i32 %top_2011, i32* %newIndex_global_2006
  br label %entry_2013
entry_2013:
  %newIndex_local1_2007 = load i32, i32* %newIndex_global_2006
  %isIGreater_2010 = icmp sge i32 %newIndex_local1_2007, %second_2012
  br i1 %isIGreater_2010, label %finish_2015, label %loop_2014
loop_2014:
  %j_local_2016 = load i32, i32* %i_global_1993
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_2016)
  %top_2017 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_2018 = call i32 @printInt(i32 %top_2017)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_2024 = call i32 @Stack_Pop(%stackType* %stack)
  %second_2025 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_2019 = alloca i32
  store i32 %top_2024, i32* %newIndex_global_2019
  br label %entry_2026
entry_2026:
  %newIndex_local1_2020 = load i32, i32* %newIndex_global_2019
  %isIGreater_2023 = icmp sge i32 %newIndex_local1_2020, %second_2025
  br i1 %isIGreater_2023, label %finish_2028, label %loop_2027
loop_2027:
  %i_local_2029 = load i32, i32* %newIndex_global_2019
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_2029)
  %top_2030 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_2031 = call i32 @printInt(i32 %top_2030)
  %newIndex_local2_2021 = load i32, i32* %newIndex_global_2019
  %newIndex_local3_2022 = add i32 1, %newIndex_local2_2021
  store i32 %newIndex_local3_2022, i32* %newIndex_global_2019
  br label %entry_2026
finish_2028:
  %newIndex_local2_2008 = load i32, i32* %newIndex_global_2006
  %newIndex_local3_2009 = add i32 1, %newIndex_local2_2008
  store i32 %newIndex_local3_2009, i32* %newIndex_global_2006
  br label %entry_2013
finish_2015:
  %i_local2_1995 = load i32, i32* %i_global_1993
  %i_local3_1996 = add i32 1, %i_local2_1995
  store i32 %i_local3_1996, i32* %i_global_1993
  br label %entry_2000
finish_2002:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_2035
entry_2035:
  %top_2032 = call i32 @Stack_Pop(%stackType* %stack)
  %second_2033 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_2034 = icmp slt i32 %top_2032, %second_2033
  br i1 %isSmaller_2034, label %topsmaller_2036, label %secondsmaller_2037
topsmaller_2036:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_2038
secondsmaller_2037:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_2038
finish_2038:
  %top_2042 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_2041 = icmp eq i32 %top_2042, 0
  br i1 %isZero_2041, label %else_block_2040, label %if_block_2039
if_block_2039:
  %top_2044 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_2045 = call i32 @printInt(i32 %top_2044)
  br label %if_exit_2043
else_block_2040:
  br label %if_exit_2043
if_exit_2043:
  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_2046 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_2046, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_2047 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_2047, i32* @.DATA
  %var_local_2048 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_2048)
  %top_2049 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_2050 = call i32 @printInt(i32 %top_2049)
  %var_local_2051 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_2051)
  %top_2052 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_2053 = call i32 @printInt(i32 %top_2052)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_2054 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_2054, i32* @.NB
  %var_local_2055 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_2055)
  %top_2056 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_2057 = call i32 @printInt(i32 %top_2056)
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
  %top_2063 = call i32 @Stack_Pop(%stackType* %stack)
  %second_2064 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_2058 = alloca i32
  store i32 %top_2063, i32* %i_global_2058
  br label %entry_2065
entry_2065:
  %i_local1_2059 = load i32, i32* %i_global_2058
  %isIGreater_2062 = icmp sge i32 %i_local1_2059, %second_2064
  br i1 %isIGreater_2062, label %finish_2067, label %loop_2066
loop_2066:
  %i_local_2068 = load i32, i32* %i_global_2058
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_2068)
  %top_2069 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_2070 = call i32 @printInt(i32 %top_2069)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_2076 = call i32 @Stack_Pop(%stackType* %stack)
  %second_2077 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_2071 = alloca i32
  store i32 %top_2076, i32* %newIndex_global_2071
  br label %entry_2078
entry_2078:
  %newIndex_local1_2072 = load i32, i32* %newIndex_global_2071
  %isIGreater_2075 = icmp sge i32 %newIndex_local1_2072, %second_2077
  br i1 %isIGreater_2075, label %finish_2080, label %loop_2079
loop_2079:
  %j_local_2081 = load i32, i32* %i_global_2058
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_2081)
  %top_2082 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_2083 = call i32 @printInt(i32 %top_2082)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_2089 = call i32 @Stack_Pop(%stackType* %stack)
  %second_2090 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_2084 = alloca i32
  store i32 %top_2089, i32* %newIndex_global_2084
  br label %entry_2091
entry_2091:
  %newIndex_local1_2085 = load i32, i32* %newIndex_global_2084
  %isIGreater_2088 = icmp sge i32 %newIndex_local1_2085, %second_2090
  br i1 %isIGreater_2088, label %finish_2093, label %loop_2092
loop_2092:
  %i_local_2094 = load i32, i32* %newIndex_global_2084
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_2094)
  %top_2095 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_2096 = call i32 @printInt(i32 %top_2095)
  %newIndex_local2_2086 = load i32, i32* %newIndex_global_2084
  %newIndex_local3_2087 = add i32 1, %newIndex_local2_2086
  store i32 %newIndex_local3_2087, i32* %newIndex_global_2084
  br label %entry_2091
finish_2093:
  %newIndex_local2_2073 = load i32, i32* %newIndex_global_2071
  %newIndex_local3_2074 = add i32 1, %newIndex_local2_2073
  store i32 %newIndex_local3_2074, i32* %newIndex_global_2071
  br label %entry_2078
finish_2080:
  %i_local2_2060 = load i32, i32* %i_global_2058
  %i_local3_2061 = add i32 1, %i_local2_2060
  store i32 %i_local3_2061, i32* %i_global_2058
  br label %entry_2065
finish_2067:
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  call void @Stack_PushInt(%stackType* %stack, i32 221)
  call void @Stack_PushInt(%stackType* %stack, i32 220)
  br label %entry_2100
entry_2100:
  %top_2097 = call i32 @Stack_Pop(%stackType* %stack)
  %second_2098 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_2099 = icmp slt i32 %top_2097, %second_2098
  br i1 %isSmaller_2099, label %topsmaller_2101, label %secondsmaller_2102
topsmaller_2101:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_2103
secondsmaller_2102:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_2103
finish_2103:
  %top_2107 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_2106 = icmp eq i32 %top_2107, 0
  br i1 %isZero_2106, label %else_block_2105, label %if_block_2104
if_block_2104:
  %top_2109 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_2110 = call i32 @printInt(i32 %top_2109)
  br label %if_exit_2108
else_block_2105:
  br label %if_exit_2108
if_exit_2108:

  ret i32 0
}
