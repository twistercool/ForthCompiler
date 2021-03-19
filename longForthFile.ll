

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

define void @Stack_Function_SPACES(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;push 0
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  %top_7 = call i64 @Stack_Pop(%stackType* %stack)
  %second_8 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_2 = alloca i64
  store i64 %top_7, i64* %i_global_2
  br label %entry_9
entry_9:
  %i_local1_3 = load i64, i64* %i_global_2
  %isIGreater_6 = icmp sge i64 %i_local1_3, %second_8
  br i1 %isIGreater_6, label %finish_11, label %loop_10
loop_10:
  ;SPACE
  call i64 @printSpace()
  %i_local2_4 = load i64, i64* %i_global_2
  %i_local3_5 = add i64 1, %i_local2_4
  store i64 %i_local3_5, i64* %i_global_2
  br label %entry_9
finish_11:
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
  %top_12 = call i64 @Stack_Pop(%stackType* %stack)
  %second_13 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_12)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_13)
  ;OVER
  %top_14 = call i64 @Stack_Pop(%stackType* %stack)
  %second_15 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_15)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_14)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_15)
  ret void
}

define void @Stack_Function_NIP(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;SWAP
  %top_16 = call i64 @Stack_Pop(%stackType* %stack)
  %second_17 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_16)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_17)
  ;DROP
  %trashed_18 = call i64 @Stack_Pop(%stackType* %stack)
  ret void
}

define void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;push 42
  call void @Stack_PushInt(%stackType* %stack, i64 42)
  ;EMIT
  %top_19 = call i64 @Stack_Pop(%stackType* %stack)
  call i64 @print_ASCII(i64 %top_19)
  ret void
}

define void @Stack_Function_STARS(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;push 0
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  %top_25 = call i64 @Stack_Pop(%stackType* %stack)
  %second_26 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_20 = alloca i64
  store i64 %top_25, i64* %i_global_20
  br label %entry_27
entry_27:
  %i_local1_21 = load i64, i64* %i_global_20
  %isIGreater_24 = icmp sge i64 %i_local1_21, %second_26
  br i1 %isIGreater_24, label %finish_29, label %loop_28
loop_28:
  ;STAR
  call void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack)
  %i_local2_22 = load i64, i64* %i_global_20
  %i_local3_23 = add i64 1, %i_local2_22
  store i64 %i_local3_23, i64* %i_global_20
  br label %entry_27
finish_29:
  ret void
}

define void @Stack_Function_F(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;push 5
  call void @Stack_PushInt(%stackType* %stack, i64 5)
  ;STARS
  call void @Stack_Function_STARS(%stackType* %stack, %stackType* %return_stack)
  ;CR
  call i64 @printNL()
  ;STAR
  call void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack)
  ;CR
  call i64 @printNL()
  ;push 5
  call void @Stack_PushInt(%stackType* %stack, i64 5)
  ;STARS
  call void @Stack_Function_STARS(%stackType* %stack, %stackType* %return_stack)
  ;CR
  call i64 @printNL()
  ;STAR
  call void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack)
  ;CR
  call i64 @printNL()
  ;STAR
  call void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack)
  ;CR
  call i64 @printNL()
  ;STAR
  call void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack)
  ret void
}

define void @Stack_Function_FIB(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;OVER
  %top_30 = call i64 @Stack_Pop(%stackType* %stack)
  %second_31 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_31)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_30)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_31)
  ;OVER
  %top_32 = call i64 @Stack_Pop(%stackType* %stack)
  %second_33 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_33)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_32)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_33)
  ;+
  %top_34 = call i64 @Stack_Pop(%stackType* %stack)
  %second_35 = call i64 @Stack_Pop(%stackType* %stack)
  %added_36 = add i64 %second_35, %top_34
  call void @Stack_PushInt(%stackType* %stack, i64 %added_36)
  ret void
}

define void @Stack_Function_FIBS(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;push 0
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  ;ROT
  %top_37 = call i64 @Stack_Pop(%stackType* %stack)
  %second_38 = call i64 @Stack_Pop(%stackType* %stack)
  %third_39 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_38)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_37)
  call void @Stack_PushInt(%stackType* %stack, i64 %third_39)
  ;push 0
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  %top_45 = call i64 @Stack_Pop(%stackType* %stack)
  %second_46 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_40 = alloca i64
  store i64 %top_45, i64* %i_global_40
  br label %entry_47
entry_47:
  %i_local1_41 = load i64, i64* %i_global_40
  %isIGreater_44 = icmp sge i64 %i_local1_41, %second_46
  br i1 %isIGreater_44, label %finish_49, label %loop_48
loop_48:
  ;FIB
  call void @Stack_Function_FIB(%stackType* %stack, %stackType* %return_stack)
  %i_local2_42 = load i64, i64* %i_global_40
  %i_local3_43 = add i64 1, %i_local2_42
  store i64 %i_local3_43, i64* %i_global_40
  br label %entry_47
finish_49:
  ret void
}

define void @Stack_Function_FACTORIAL(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;DUP
  %top_50 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_50)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_50)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  %top_56 = call i64 @Stack_Pop(%stackType* %stack)
  %second_57 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_51 = alloca i64
  store i64 %top_56, i64* %i_global_51
  br label %entry_58
entry_58:
  %i_local1_52 = load i64, i64* %i_global_51
  %isIGreater_55 = icmp sge i64 %i_local1_52, %second_57
  br i1 %isIGreater_55, label %finish_60, label %loop_59
loop_59:
  ;DUP
  %top_61 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_61)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_61)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  ;-
  %top_62 = call i64 @Stack_Pop(%stackType* %stack)
  %second_63 = call i64 @Stack_Pop(%stackType* %stack)
  %subvalue_64 = sub i64 %second_63, %top_62
  call void @Stack_PushInt(%stackType* %stack, i64 %subvalue_64)
  %i_local2_53 = load i64, i64* %i_global_51
  %i_local3_54 = add i64 1, %i_local2_53
  store i64 %i_local3_54, i64* %i_global_51
  br label %entry_58
finish_60:
  ;DEPTH
  %Length_65 = call i64 @Stack_GetLength(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %Length_65)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  %top_71 = call i64 @Stack_Pop(%stackType* %stack)
  %second_72 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_66 = alloca i64
  store i64 %top_71, i64* %i_global_66
  br label %entry_73
entry_73:
  %i_local1_67 = load i64, i64* %i_global_66
  %isIGreater_70 = icmp sge i64 %i_local1_67, %second_72
  br i1 %isIGreater_70, label %finish_75, label %loop_74
loop_74:
  ;*
  %top_76 = call i64 @Stack_Pop(%stackType* %stack)
  %second_77 = call i64 @Stack_Pop(%stackType* %stack)
  %product_78 = mul i64 %second_77, %top_76
  call void @Stack_PushInt(%stackType* %stack, i64 %product_78)
  %i_local2_68 = load i64, i64* %i_global_66
  %i_local3_69 = add i64 1, %i_local2_68
  store i64 %i_local3_69, i64* %i_global_66
  br label %entry_73
finish_75:
  ;.
  %top_79 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_80 = call i64 @printInt(i64 %top_79)
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
  %top_81 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_81, i64* @.BL
  ;push 20
  call void @Stack_PushInt(%stackType* %stack, i64 20)
  ;constant TWENTY
  %top_82 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_82, i64* @.TWENTY
  ;CR
  call i64 @printNL()
  ;F
  call void @Stack_Function_F(%stackType* %stack, %stackType* %return_stack)
  ;CR
  call i64 @printNL()
  ;push 40
  call void @Stack_PushInt(%stackType* %stack, i64 40)
  ;FIBS
  call void @Stack_Function_FIBS(%stackType* %stack, %stackType* %return_stack)
  ;push 12
  call void @Stack_PushInt(%stackType* %stack, i64 12)
  ;FACTORIAL
  call void @Stack_Function_FACTORIAL(%stackType* %stack, %stackType* %return_stack)
  ;push 11
  call void @Stack_PushInt(%stackType* %stack, i64 11)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  %top_88 = call i64 @Stack_Pop(%stackType* %stack)
  %second_89 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_83 = alloca i64
  store i64 %top_88, i64* %i_global_83
  br label %entry_90
entry_90:
  %i_local1_84 = load i64, i64* %i_global_83
  %isIGreater_87 = icmp sge i64 %i_local1_84, %second_89
  br i1 %isIGreater_87, label %finish_92, label %loop_91
loop_91:
  ;I
  %i_local_93 = load i64, i64* %i_global_83
  call void @Stack_PushInt(%stackType* %stack, i64 %i_local_93)
  ;.
  %top_94 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_95 = call i64 @printInt(i64 %top_94)
  ;push 11
  call void @Stack_PushInt(%stackType* %stack, i64 11)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  %top_101 = call i64 @Stack_Pop(%stackType* %stack)
  %second_102 = call i64 @Stack_Pop(%stackType* %stack)
  %newIndex_global_96 = alloca i64
  store i64 %top_101, i64* %newIndex_global_96
  br label %entry_103
entry_103:
  %newIndex_local1_97 = load i64, i64* %newIndex_global_96
  %isIGreater_100 = icmp sge i64 %newIndex_local1_97, %second_102
  br i1 %isIGreater_100, label %finish_105, label %loop_104
loop_104:
  ;J
  %j_local_106 = load i64, i64* %i_global_83
  call void @Stack_PushInt(%stackType* %stack, i64 %j_local_106)
  ;.
  %top_107 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_108 = call i64 @printInt(i64 %top_107)
  ;push 11
  call void @Stack_PushInt(%stackType* %stack, i64 11)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  %top_114 = call i64 @Stack_Pop(%stackType* %stack)
  %second_115 = call i64 @Stack_Pop(%stackType* %stack)
  %newIndex_global_109 = alloca i64
  store i64 %top_114, i64* %newIndex_global_109
  br label %entry_116
entry_116:
  %newIndex_local1_110 = load i64, i64* %newIndex_global_109
  %isIGreater_113 = icmp sge i64 %newIndex_local1_110, %second_115
  br i1 %isIGreater_113, label %finish_118, label %loop_117
loop_117:
  ;I
  %i_local_119 = load i64, i64* %newIndex_global_109
  call void @Stack_PushInt(%stackType* %stack, i64 %i_local_119)
  ;.
  %top_120 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_121 = call i64 @printInt(i64 %top_120)
  ;push 11
  call void @Stack_PushInt(%stackType* %stack, i64 11)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  %top_127 = call i64 @Stack_Pop(%stackType* %stack)
  %second_128 = call i64 @Stack_Pop(%stackType* %stack)
  %newIndex_global_122 = alloca i64
  store i64 %top_127, i64* %newIndex_global_122
  br label %entry_129
entry_129:
  %newIndex_local1_123 = load i64, i64* %newIndex_global_122
  %isIGreater_126 = icmp sge i64 %newIndex_local1_123, %second_128
  br i1 %isIGreater_126, label %finish_131, label %loop_130
loop_130:
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  ;push 2
  call void @Stack_PushInt(%stackType* %stack, i64 2)
  ;push 3
  call void @Stack_PushInt(%stackType* %stack, i64 3)
  ;push 4
  call void @Stack_PushInt(%stackType* %stack, i64 4)
  ;+
  %top_132 = call i64 @Stack_Pop(%stackType* %stack)
  %second_133 = call i64 @Stack_Pop(%stackType* %stack)
  %added_134 = add i64 %second_133, %top_132
  call void @Stack_PushInt(%stackType* %stack, i64 %added_134)
  ;+
  %top_135 = call i64 @Stack_Pop(%stackType* %stack)
  %second_136 = call i64 @Stack_Pop(%stackType* %stack)
  %added_137 = add i64 %second_136, %top_135
  call void @Stack_PushInt(%stackType* %stack, i64 %added_137)
  ;+
  %top_138 = call i64 @Stack_Pop(%stackType* %stack)
  %second_139 = call i64 @Stack_Pop(%stackType* %stack)
  %added_140 = add i64 %second_139, %top_138
  call void @Stack_PushInt(%stackType* %stack, i64 %added_140)
  ;DROP
  %trashed_141 = call i64 @Stack_Pop(%stackType* %stack)
  %newIndex_local2_124 = load i64, i64* %newIndex_global_122
  %newIndex_local3_125 = add i64 1, %newIndex_local2_124
  store i64 %newIndex_local3_125, i64* %newIndex_global_122
  br label %entry_129
finish_131:
  %newIndex_local2_111 = load i64, i64* %newIndex_global_109
  %newIndex_local3_112 = add i64 1, %newIndex_local2_111
  store i64 %newIndex_local3_112, i64* %newIndex_global_109
  br label %entry_116
finish_118:
  %newIndex_local2_98 = load i64, i64* %newIndex_global_96
  %newIndex_local3_99 = add i64 1, %newIndex_local2_98
  store i64 %newIndex_local3_99, i64* %newIndex_global_96
  br label %entry_103
finish_105:
  %i_local2_85 = load i64, i64* %i_global_83
  %i_local3_86 = add i64 1, %i_local2_85
  store i64 %i_local3_86, i64* %i_global_83
  br label %entry_90
finish_92:
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  ;push 221
  call void @Stack_PushInt(%stackType* %stack, i64 221)
  ;push 220
  call void @Stack_PushInt(%stackType* %stack, i64 220)
  ;>
  br label %entry_145
entry_145:
  %top_142 = call i64 @Stack_Pop(%stackType* %stack)
  %second_143 = call i64 @Stack_Pop(%stackType* %stack)
  %isSmaller_144 = icmp slt i64 %top_142, %second_143
  br i1 %isSmaller_144, label %topsmaller_146, label %secondsmaller_147
topsmaller_146:
  call void @Stack_PushInt(%stackType* %stack, i64 -1)
  br label %finish_148
secondsmaller_147:
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  br label %finish_148
finish_148:
  %top_152 = call i64 @Stack_Pop(%stackType* %stack)
  %isZero_151 = icmp eq i64 %top_152, 0
  br i1 %isZero_151, label %else_block_150, label %if_block_149
if_block_149:
  ;.
  %top_154 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_155 = call i64 @printInt(i64 %top_154)
  br label %if_exit_153
else_block_150:
  br label %if_exit_153
if_exit_153:
  ;push 6
  call void @Stack_PushInt(%stackType* %stack, i64 6)
  ;push 5
  call void @Stack_PushInt(%stackType* %stack, i64 5)
  ;>
  br label %entry_159
entry_159:
  %top_156 = call i64 @Stack_Pop(%stackType* %stack)
  %second_157 = call i64 @Stack_Pop(%stackType* %stack)
  %isSmaller_158 = icmp slt i64 %top_156, %second_157
  br i1 %isSmaller_158, label %topsmaller_160, label %secondsmaller_161
topsmaller_160:
  call void @Stack_PushInt(%stackType* %stack, i64 -1)
  br label %finish_162
secondsmaller_161:
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  br label %finish_162
finish_162:
  %top_166 = call i64 @Stack_Pop(%stackType* %stack)
  %isZero_165 = icmp eq i64 %top_166, 0
  br i1 %isZero_165, label %else_block_164, label %if_block_163
if_block_163:
  ;push 50
  call void @Stack_PushInt(%stackType* %stack, i64 50)
  ;.
  %top_168 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_169 = call i64 @printInt(i64 %top_168)
  br label %if_exit_167
else_block_164:
  ;push 40
  call void @Stack_PushInt(%stackType* %stack, i64 40)
  ;.
  %top_170 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_171 = call i64 @printInt(i64 %top_170)
  br label %if_exit_167
if_exit_167:
  ;push 4
  call void @Stack_PushInt(%stackType* %stack, i64 4)
  %top_172 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_172, i64* @.NB
  ;push 12
  call void @Stack_PushInt(%stackType* %stack, i64 12)
  %top_173 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_173, i64* @.DATA
  %var_local_174 = load i64, i64* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i64 %var_local_174)
  ;.
  %top_175 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_176 = call i64 @printInt(i64 %top_175)
  %var_local_177 = load i64, i64* @.NB
  call void @Stack_PushInt(%stackType* %stack, i64 %var_local_177)
  ;.
  %top_178 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_179 = call i64 @printInt(i64 %top_178)
  ;push 543
  call void @Stack_PushInt(%stackType* %stack, i64 543)
  %top_180 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_180, i64* @.NB
  %var_local_181 = load i64, i64* @.NB
  call void @Stack_PushInt(%stackType* %stack, i64 %var_local_181)
  ;.
  %top_182 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_183 = call i64 @printInt(i64 %top_182)
  ;TWENTY
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  ;.
  %top_184 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_185 = call i64 @printInt(i64 %top_184)
  ;TWENTY
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  ;.
  %top_186 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_187 = call i64 @printInt(i64 %top_186)

  ret i32 0
}
