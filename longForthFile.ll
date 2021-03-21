

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
  %isIEqual_6 = icmp eq i64 %i_local1_3, %second_8
  br i1 %isIEqual_6, label %finish_11, label %loop_10
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

define void @Stack_Function_PRINTALL(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;DEPTH
  %Length_19 = call i64 @Stack_GetLength(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %Length_19)
  ;push 0
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  %top_25 = call i64 @Stack_Pop(%stackType* %stack)
  %second_26 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_20 = alloca i64
  store i64 %top_25, i64* %i_global_20
  br label %entry_27
entry_27:
  %i_local1_21 = load i64, i64* %i_global_20
  %isIEqual_24 = icmp eq i64 %i_local1_21, %second_26
  br i1 %isIEqual_24, label %finish_29, label %loop_28
loop_28:
  ;.
  %top_30 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_31 = call i64 @printInt(i64 %top_30)
  %i_local2_22 = load i64, i64* %i_global_20
  %i_local3_23 = add i64 1, %i_local2_22
  store i64 %i_local3_23, i64* %i_global_20
  br label %entry_27
finish_29:
  ret void
}

define void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;push 42
  call void @Stack_PushInt(%stackType* %stack, i64 42)
  ;EMIT
  %top_32 = call i64 @Stack_Pop(%stackType* %stack)
  call i64 @print_ASCII(i64 %top_32)
  ret void
}

define void @Stack_Function_STARS(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;push 0
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  %top_38 = call i64 @Stack_Pop(%stackType* %stack)
  %second_39 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_33 = alloca i64
  store i64 %top_38, i64* %i_global_33
  br label %entry_40
entry_40:
  %i_local1_34 = load i64, i64* %i_global_33
  %isIEqual_37 = icmp eq i64 %i_local1_34, %second_39
  br i1 %isIEqual_37, label %finish_42, label %loop_41
loop_41:
  ;STAR
  call void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack)
  %i_local2_35 = load i64, i64* %i_global_33
  %i_local3_36 = add i64 1, %i_local2_35
  store i64 %i_local3_36, i64* %i_global_33
  br label %entry_40
finish_42:
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
  %top_43 = call i64 @Stack_Pop(%stackType* %stack)
  %second_44 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_44)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_43)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_44)
  ;OVER
  %top_45 = call i64 @Stack_Pop(%stackType* %stack)
  %second_46 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_46)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_45)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_46)
  ;+
  %top_47 = call i64 @Stack_Pop(%stackType* %stack)
  %second_48 = call i64 @Stack_Pop(%stackType* %stack)
  %added_49 = add i64 %second_48, %top_47
  call void @Stack_PushInt(%stackType* %stack, i64 %added_49)
  ret void
}

define void @Stack_Function_FIBS(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;push 0
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  ;ROT
  %top_50 = call i64 @Stack_Pop(%stackType* %stack)
  %second_51 = call i64 @Stack_Pop(%stackType* %stack)
  %third_52 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %second_51)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_50)
  call void @Stack_PushInt(%stackType* %stack, i64 %third_52)
  ;push 0
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  %top_58 = call i64 @Stack_Pop(%stackType* %stack)
  %second_59 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_53 = alloca i64
  store i64 %top_58, i64* %i_global_53
  br label %entry_60
entry_60:
  %i_local1_54 = load i64, i64* %i_global_53
  %isIEqual_57 = icmp eq i64 %i_local1_54, %second_59
  br i1 %isIEqual_57, label %finish_62, label %loop_61
loop_61:
  ;FIB
  call void @Stack_Function_FIB(%stackType* %stack, %stackType* %return_stack)
  %i_local2_55 = load i64, i64* %i_global_53
  %i_local3_56 = add i64 1, %i_local2_55
  store i64 %i_local3_56, i64* %i_global_53
  br label %entry_60
finish_62:
  ret void
}

define void @Stack_Function_FACTORIAL(%stackType* %stack, %stackType* %return_stack) nounwind
{
  ;DUP
  %top_63 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_63)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_63)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
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
  ;DUP
  %top_74 = call i64 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_74)
  call void @Stack_PushInt(%stackType* %stack, i64 %top_74)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  ;-
  %top_75 = call i64 @Stack_Pop(%stackType* %stack)
  %second_76 = call i64 @Stack_Pop(%stackType* %stack)
  %subvalue_77 = sub i64 %second_76, %top_75
  call void @Stack_PushInt(%stackType* %stack, i64 %subvalue_77)
  %i_local2_66 = load i64, i64* %i_global_64
  %i_local3_67 = add i64 1, %i_local2_66
  store i64 %i_local3_67, i64* %i_global_64
  br label %entry_71
finish_73:
  ;DEPTH
  %Length_78 = call i64 @Stack_GetLength(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i64 %Length_78)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  %top_84 = call i64 @Stack_Pop(%stackType* %stack)
  %second_85 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_79 = alloca i64
  store i64 %top_84, i64* %i_global_79
  br label %entry_86
entry_86:
  %i_local1_80 = load i64, i64* %i_global_79
  %isIEqual_83 = icmp eq i64 %i_local1_80, %second_85
  br i1 %isIEqual_83, label %finish_88, label %loop_87
loop_87:
  ;*
  %top_89 = call i64 @Stack_Pop(%stackType* %stack)
  %second_90 = call i64 @Stack_Pop(%stackType* %stack)
  %product_91 = mul i64 %second_90, %top_89
  call void @Stack_PushInt(%stackType* %stack, i64 %product_91)
  %i_local2_81 = load i64, i64* %i_global_79
  %i_local3_82 = add i64 1, %i_local2_81
  store i64 %i_local3_82, i64* %i_global_79
  br label %entry_86
finish_88:
  ;.
  %top_92 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_93 = call i64 @printInt(i64 %top_92)
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
  %top_94 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_94, i64* @.BL
  ;push 20
  call void @Stack_PushInt(%stackType* %stack, i64 20)
  ;constant TWENTY
  %top_95 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_95, i64* @.TWENTY
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
  %top_101 = call i64 @Stack_Pop(%stackType* %stack)
  %second_102 = call i64 @Stack_Pop(%stackType* %stack)
  %i_global_96 = alloca i64
  store i64 %top_101, i64* %i_global_96
  br label %entry_103
entry_103:
  %i_local1_97 = load i64, i64* %i_global_96
  %isIEqual_100 = icmp eq i64 %i_local1_97, %second_102
  br i1 %isIEqual_100, label %finish_105, label %loop_104
loop_104:
  ;I
  %i_local_106 = load i64, i64* %i_global_96
  call void @Stack_PushInt(%stackType* %stack, i64 %i_local_106)
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
  ;J
  %j_local_119 = load i64, i64* %i_global_96
  call void @Stack_PushInt(%stackType* %stack, i64 %j_local_119)
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
  ;I
  %i_local_132 = load i64, i64* %newIndex_global_122
  call void @Stack_PushInt(%stackType* %stack, i64 %i_local_132)
  ;.
  %top_133 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_134 = call i64 @printInt(i64 %top_133)
  ;push 11
  call void @Stack_PushInt(%stackType* %stack, i64 11)
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  %top_140 = call i64 @Stack_Pop(%stackType* %stack)
  %second_141 = call i64 @Stack_Pop(%stackType* %stack)
  %newIndex_global_135 = alloca i64
  store i64 %top_140, i64* %newIndex_global_135
  br label %entry_142
entry_142:
  %newIndex_local1_136 = load i64, i64* %newIndex_global_135
  %isIGreater_139 = icmp sge i64 %newIndex_local1_136, %second_141
  br i1 %isIGreater_139, label %finish_144, label %loop_143
loop_143:
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  ;push 2
  call void @Stack_PushInt(%stackType* %stack, i64 2)
  ;push 3
  call void @Stack_PushInt(%stackType* %stack, i64 3)
  ;push 4
  call void @Stack_PushInt(%stackType* %stack, i64 4)
  ;+
  %top_145 = call i64 @Stack_Pop(%stackType* %stack)
  %second_146 = call i64 @Stack_Pop(%stackType* %stack)
  %added_147 = add i64 %second_146, %top_145
  call void @Stack_PushInt(%stackType* %stack, i64 %added_147)
  ;+
  %top_148 = call i64 @Stack_Pop(%stackType* %stack)
  %second_149 = call i64 @Stack_Pop(%stackType* %stack)
  %added_150 = add i64 %second_149, %top_148
  call void @Stack_PushInt(%stackType* %stack, i64 %added_150)
  ;+
  %top_151 = call i64 @Stack_Pop(%stackType* %stack)
  %second_152 = call i64 @Stack_Pop(%stackType* %stack)
  %added_153 = add i64 %second_152, %top_151
  call void @Stack_PushInt(%stackType* %stack, i64 %added_153)
  ;DROP
  %trashed_154 = call i64 @Stack_Pop(%stackType* %stack)
  %newIndex_local2_137 = load i64, i64* %newIndex_global_135
  %newIndex_local3_138 = add i64 1, %newIndex_local2_137
  store i64 %newIndex_local3_138, i64* %newIndex_global_135
  br label %entry_142
finish_144:
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
  %i_local2_98 = load i64, i64* %i_global_96
  %i_local3_99 = add i64 1, %i_local2_98
  store i64 %i_local3_99, i64* %i_global_96
  br label %entry_103
finish_105:
  ;push 1
  call void @Stack_PushInt(%stackType* %stack, i64 1)
  ;push 221
  call void @Stack_PushInt(%stackType* %stack, i64 221)
  ;push 220
  call void @Stack_PushInt(%stackType* %stack, i64 220)
  ;>
  %top_155 = call i64 @Stack_Pop(%stackType* %stack)
  %second_156 = call i64 @Stack_Pop(%stackType* %stack)
  %isSmaller_157 = icmp slt i64 %top_155, %second_156
  br i1 %isSmaller_157, label %topsmaller_158, label %secondsmaller_159
topsmaller_158:
  call void @Stack_PushInt(%stackType* %stack, i64 -1)
  br label %finish_160
secondsmaller_159:
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  br label %finish_160
finish_160:
  %top_164 = call i64 @Stack_Pop(%stackType* %stack)
  %isZero_163 = icmp eq i64 %top_164, 0
  br i1 %isZero_163, label %else_block_162, label %if_block_161
if_block_161:
  ;.
  %top_166 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_167 = call i64 @printInt(i64 %top_166)
  br label %if_exit_165
else_block_162:
  br label %if_exit_165
if_exit_165:
  ;push 6
  call void @Stack_PushInt(%stackType* %stack, i64 6)
  ;push 5
  call void @Stack_PushInt(%stackType* %stack, i64 5)
  ;>
  %top_168 = call i64 @Stack_Pop(%stackType* %stack)
  %second_169 = call i64 @Stack_Pop(%stackType* %stack)
  %isSmaller_170 = icmp slt i64 %top_168, %second_169
  br i1 %isSmaller_170, label %topsmaller_171, label %secondsmaller_172
topsmaller_171:
  call void @Stack_PushInt(%stackType* %stack, i64 -1)
  br label %finish_173
secondsmaller_172:
  call void @Stack_PushInt(%stackType* %stack, i64 0)
  br label %finish_173
finish_173:
  %top_177 = call i64 @Stack_Pop(%stackType* %stack)
  %isZero_176 = icmp eq i64 %top_177, 0
  br i1 %isZero_176, label %else_block_175, label %if_block_174
if_block_174:
  ;push 50
  call void @Stack_PushInt(%stackType* %stack, i64 50)
  ;.
  %top_179 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_180 = call i64 @printInt(i64 %top_179)
  br label %if_exit_178
else_block_175:
  ;push 40
  call void @Stack_PushInt(%stackType* %stack, i64 40)
  ;.
  %top_181 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_182 = call i64 @printInt(i64 %top_181)
  br label %if_exit_178
if_exit_178:
  ;push 4
  call void @Stack_PushInt(%stackType* %stack, i64 4)
  %top_183 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_183, i64* @.NB
  ;push 12
  call void @Stack_PushInt(%stackType* %stack, i64 12)
  %top_184 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_184, i64* @.DATA
  %var_local_185 = load i64, i64* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i64 %var_local_185)
  ;.
  %top_186 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_187 = call i64 @printInt(i64 %top_186)
  %var_local_188 = load i64, i64* @.NB
  call void @Stack_PushInt(%stackType* %stack, i64 %var_local_188)
  ;.
  %top_189 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_190 = call i64 @printInt(i64 %top_189)
  ;push 543
  call void @Stack_PushInt(%stackType* %stack, i64 543)
  %top_191 = call i64 @Stack_Pop(%stackType* %stack)
  store i64 %top_191, i64* @.NB
  %var_local_192 = load i64, i64* @.NB
  call void @Stack_PushInt(%stackType* %stack, i64 %var_local_192)
  ;.
  %top_193 = call i64 @Stack_Pop(%stackType* %stack)
  %printTop_194 = call i64 @printInt(i64 %top_193)
  ;TWENTY
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  ;TWENTY
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  ;PRINTALL
  call void @Stack_Function_PRINTALL(%stackType* %stack, %stackType* %return_stack)

  ret i32 0
}
