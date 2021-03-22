

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

define void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;push 42
  call void @Stack_PushInt(%stackType* %stack, i64 42)
  ;EMIT
  %top_42 = call i64 @Stack_Pop(%stackType* %stack)
  call i64 @print_ASCII(i64 %top_42)
  ret void
}

define void @Stack_Function_STARS(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;push 0
  call void @Stack_PushInt(%stackType* %stack, i64 0)
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
  ;STAR
  call void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack)
  %i_local2_45 = load i64, i64* %i_global_43
  %i_local3_46 = add i64 1, %i_local2_45
  store i64 %i_local3_46, i64* %i_global_43
  br label %entry_50
finish_52:
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
  %top_53 = call i64 @Stack_Pop(%stackType* %stack)
  %second_54 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_54)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_53)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_54)
  ;OVER
  %top_55 = call i64 @Stack_Pop(%stackType* %stack)
  %second_56 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_56)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_55)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_56)
  ;+
  %top_57 = call i64 @Stack_Pop(%stackType* %stack)
  %second_58 = call i64 @Stack_Pop(%stackType* %stack)
  %added_59 = add i64 %second_58, %top_57
  call void @Stack_PushInt(%stackType* %stack, i64 %added_59)
  ret void
}

define void @Stack_Function_FIBS(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;push 0
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  ;ROT
  %top_60 = call i64 @Stack_Pop(%stackType* %stack)
  %second_61 = call i64 @Stack_Pop(%stackType* %stack)
  %third_62 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_61)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_60)
  call void @Stack_PushInt(%stackType* %stack, i64 %third_62)
  ;push 0
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  %top_68 = call i64 @Stack_Pop(%stackType* %stack)
  %second_69 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_63 = alloca i64
  store i64 %top_68, i64* %i_global_63
  br label %entry_70
entry_70:
  %i_local1_64 = load i64, i64* %i_global_63
  %isIEqual_67 = icmp eq i64 %i_local1_64, %second_69
  br i1 %isIEqual_67, label %finish_72, label %loop_71
loop_71:
  ;FIB
  call void @Stack_Function_FIB(%stackType* %stack, %stackType* %return_stack)
  %i_local2_65 = load i64, i64* %i_global_63
  %i_local3_66 = add i64 1, %i_local2_65
  store i64 %i_local3_66, i64* %i_global_63
  br label %entry_70
finish_72:
  ret void
}

define void @Stack_Function_FACTORIAL(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;DUP
  %top_73 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_73)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_73)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  %top_79 = call i64 @Stack_Pop(%stackType* %stack)
  %second_80 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_74 = alloca i64
  store i64 %top_79, i64* %i_global_74
  br label %entry_81
entry_81:
  %i_local1_75 = load i64, i64* %i_global_74
  %isIEqual_78 = icmp eq i64 %i_local1_75, %second_80
  br i1 %isIEqual_78, label %finish_83, label %loop_82
loop_82:
  ;DUP
  %top_84 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_84)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_84)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  ;-
  %top_85 = call i64 @Stack_Pop(%stackType* %stack)
  %second_86 = call i64 @Stack_Pop(%stackType* %stack)
  %subvalue_87 = sub i64 %second_86, %top_85
  call void @Stack_PushInt(%stackType* %stack, i64 %subvalue_87)
  %i_local2_76 = load i64, i64* %i_global_74
  %i_local3_77 = add i64 1, %i_local2_76
  store i64 %i_local3_77, i64* %i_global_74
  br label %entry_81
finish_83:
  ;DEPTH
  %Length_88 = call i64 @Stack_GetLength(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %Length_88)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  %top_94 = call i64 @Stack_Pop(%stackType* %stack)
  %second_95 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_89 = alloca i64
  store i64 %top_94, i64* %i_global_89
  br label %entry_96
entry_96:
  %i_local1_90 = load i64, i64* %i_global_89
  %isIEqual_93 = icmp eq i64 %i_local1_90, %second_95
  br i1 %isIEqual_93, label %finish_98, label %loop_97
loop_97:
  ;*
  %top_99 = call i64 @Stack_Pop(%stackType* %stack)
  %second_100 = call i64 @Stack_Pop(%stackType* %stack)
  %product_101 = mul i64 %second_100, %top_99
  call void @Stack_PushInt(%stackType* %stack, i64 %product_101)
  %i_local2_91 = load i64, i64* %i_global_89
  %i_local3_92 = add i64 1, %i_local2_91
  store i64 %i_local3_92, i64* %i_global_89
  br label %entry_96
finish_98:
  ;.
  %top_102 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_103 = call i64 @printInt(i64 %top_102)
  ret void
}
@.DATA = global i64 0
@.NB = global i64 0
@.TWENTY = global i64 0

define void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %load_constant_104 = load i64, i64* @.TWENTY
  call void @Stack_PushInt(%stackType* %stack, i64 %load_constant_104)
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
  %top_105 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_105, i64* @.BL
  ;push 20
  call void @Stack_PushInt(%stackType* %stack, i64 20)
  ;constant TWENTY
  %top_106 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_106, i64* @.TWENTY
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
  %top_112 = call i64 @Stack_Pop(%stackType* %stack)
  %second_113 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_107 = alloca i64
  store i64 %top_112, i64* %i_global_107
  br label %entry_114
entry_114:
  %i_local1_108 = load i64, i64* %i_global_107
  %isIEqual_111 = icmp eq i64 %i_local1_108, %second_113
  br i1 %isIEqual_111, label %finish_116, label %loop_115
loop_115:
  ;I
  %i_local_117 = load i64, i64* %i_global_107
  call void @Stack_PushInt(%stackType* %stack, i64 %i_local_117)
  ;.
  %top_118 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_119 = call i64 @printInt(i64 %top_118)
  ;push 11
  call void @Stack_PushInt(%stackType* %stack, i64 11)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  %top_125 = call i64 @Stack_Pop(%stackType* %stack)
  %second_126 = call i64 @Stack_Pop(%stackType* %stack)
  %newIndex_global_120 = alloca i64
  store i64 %top_125, i64* %newIndex_global_120
  br label %entry_127
entry_127:
  %newIndex_local1_121 = load i64, i64* %newIndex_global_120
  %isIGreater_124 = icmp sge i64 %newIndex_local1_121, %second_126
  br i1 %isIGreater_124, label %finish_129, label %loop_128
loop_128:
  ;J
  %j_local_130 = load i64, i64* %i_global_107
  call void @Stack_PushInt(%stackType* %stack, i64 %j_local_130)
  ;.
  %top_131 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_132 = call i64 @printInt(i64 %top_131)
  ;push 11
  call void @Stack_PushInt(%stackType* %stack, i64 11)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  %top_138 = call i64 @Stack_Pop(%stackType* %stack)
  %second_139 = call i64 @Stack_Pop(%stackType* %stack)
  %newIndex_global_133 = alloca i64
  store i64 %top_138, i64* %newIndex_global_133
  br label %entry_140
entry_140:
  %newIndex_local1_134 = load i64, i64* %newIndex_global_133
  %isIGreater_137 = icmp sge i64 %newIndex_local1_134, %second_139
  br i1 %isIGreater_137, label %finish_142, label %loop_141
loop_141:
  ;I
  %i_local_143 = load i64, i64* %newIndex_global_133
  call void @Stack_PushInt(%stackType* %stack, i64 %i_local_143)
  ;.
  %top_144 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_145 = call i64 @printInt(i64 %top_144)
  ;push 11
  call void @Stack_PushInt(%stackType* %stack, i64 11)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  %top_151 = call i64 @Stack_Pop(%stackType* %stack)
  %second_152 = call i64 @Stack_Pop(%stackType* %stack)
  %newIndex_global_146 = alloca i64
  store i64 %top_151, i64* %newIndex_global_146
  br label %entry_153
entry_153:
  %newIndex_local1_147 = load i64, i64* %newIndex_global_146
  %isIGreater_150 = icmp sge i64 %newIndex_local1_147, %second_152
  br i1 %isIGreater_150, label %finish_155, label %loop_154
loop_154:
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  ;push 2
  call void @Stack_PushInt(%stackType* %stack, i64 2)
  ;push 3
  call void @Stack_PushInt(%stackType* %stack, i64 3)
  ;push 4
  call void @Stack_PushInt(%stackType* %stack, i64 4)
  ;+
  %top_156 = call i64 @Stack_Pop(%stackType* %stack)
  %second_157 = call i64 @Stack_Pop(%stackType* %stack)
  %added_158 = add i64 %second_157, %top_156
  call void @Stack_PushInt(%stackType* %stack, i64 %added_158)
  ;+
  %top_159 = call i64 @Stack_Pop(%stackType* %stack)
  %second_160 = call i64 @Stack_Pop(%stackType* %stack)
  %added_161 = add i64 %second_160, %top_159
  call void @Stack_PushInt(%stackType* %stack, i64 %added_161)
  ;+
  %top_162 = call i64 @Stack_Pop(%stackType* %stack)
  %second_163 = call i64 @Stack_Pop(%stackType* %stack)
  %added_164 = add i64 %second_163, %top_162
  call void @Stack_PushInt(%stackType* %stack, i64 %added_164)
  ;DROP
  %trashed_165 = call i64 @Stack_Pop(%stackType* %stack)
  %newIndex_local2_148 = load i64, i64* %newIndex_global_146
  %newIndex_local3_149 = add i64 1, %newIndex_local2_148
  store i64 %newIndex_local3_149, i64* %newIndex_global_146
  br label %entry_153
finish_155:
  %newIndex_local2_135 = load i64, i64* %newIndex_global_133
  %newIndex_local3_136 = add i64 1, %newIndex_local2_135
  store i64 %newIndex_local3_136, i64* %newIndex_global_133
  br label %entry_140
finish_142:
  %newIndex_local2_122 = load i64, i64* %newIndex_global_120
  %newIndex_local3_123 = add i64 1, %newIndex_local2_122
  store i64 %newIndex_local3_123, i64* %newIndex_global_120
  br label %entry_127
finish_129:
  %i_local2_109 = load i64, i64* %i_global_107
  %i_local3_110 = add i64 1, %i_local2_109
  store i64 %i_local3_110, i64* %i_global_107
  br label %entry_114
finish_116:
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  ;push 221
  call void @Stack_PushInt(%stackType* %stack, i64 221)
  ;push 220
  call void @Stack_PushInt(%stackType* %stack, i64 220)
  ;>
  %top_166 = call i64 @Stack_Pop(%stackType* %stack)
  %second_167 = call i64 @Stack_Pop(%stackType* %stack)
  %isSmaller_168 = icmp slt i64 %top_166, %second_167
  br i1 %isSmaller_168, label %topsmaller_169, label %secondsmaller_170
topsmaller_169:
  call void @Stack_PushInt(%stackType* %stack, i64 -1)
  br label %finish_171
secondsmaller_170:
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  br label %finish_171
finish_171:
  %top_175 = call i64 @Stack_Pop(%stackType* %stack)
  %isZero_174 = icmp eq i64 %top_175, 0
  br i1 %isZero_174, label %else_block_173, label %if_block_172
if_block_172:
  ;.
  %top_177 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_178 = call i64 @printInt(i64 %top_177)
  br label %if_exit_176
else_block_173:
  br label %if_exit_176
if_exit_176:
  ;push 6
  call void @Stack_PushInt(%stackType* %stack, i64 6)
  ;push 5
  call void @Stack_PushInt(%stackType* %stack, i64 5)
  ;>
  %top_179 = call i64 @Stack_Pop(%stackType* %stack)
  %second_180 = call i64 @Stack_Pop(%stackType* %stack)
  %isSmaller_181 = icmp slt i64 %top_179, %second_180
  br i1 %isSmaller_181, label %topsmaller_182, label %secondsmaller_183
topsmaller_182:
  call void @Stack_PushInt(%stackType* %stack, i64 -1)
  br label %finish_184
secondsmaller_183:
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  br label %finish_184
finish_184:
  %top_188 = call i64 @Stack_Pop(%stackType* %stack)
  %isZero_187 = icmp eq i64 %top_188, 0
  br i1 %isZero_187, label %else_block_186, label %if_block_185
if_block_185:
  ;push 50
  call void @Stack_PushInt(%stackType* %stack, i64 50)
  ;.
  %top_190 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_191 = call i64 @printInt(i64 %top_190)
  br label %if_exit_189
else_block_186:
  ;push 40
  call void @Stack_PushInt(%stackType* %stack, i64 40)
  ;.
  %top_192 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_193 = call i64 @printInt(i64 %top_192)
  br label %if_exit_189
if_exit_189:
  ;push 4
  call void @Stack_PushInt(%stackType* %stack, i64 4)
  %top_194 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_194, i64* @.NB
  ;push 12
  call void @Stack_PushInt(%stackType* %stack, i64 12)
  %top_195 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_195, i64* @.DATA
  %var_local_196 = load i64, i64* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i64 %var_local_196)
  ;.
  %top_197 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_198 = call i64 @printInt(i64 %top_197)
  %var_local_199 = load i64, i64* @.NB
  call void @Stack_PushInt(%stackType* %stack, i64 %var_local_199)
  ;.
  %top_200 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_201 = call i64 @printInt(i64 %top_200)
  ;push 543
  call void @Stack_PushInt(%stackType* %stack, i64 543)
  %top_202 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_202, i64* @.NB
  %var_local_203 = load i64, i64* @.NB
  call void @Stack_PushInt(%stackType* %stack, i64 %var_local_203)
  ;.
  %top_204 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_205 = call i64 @printInt(i64 %top_204)
  ;TWENTY
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  ;.
  %top_206 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_207 = call i64 @printInt(i64 %top_206)
  ;TWENTY
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  ;.
  %top_208 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_209 = call i64 @printInt(i64 %top_208)

  ; COMPILATION FINISHED
  ret i32 0
}
