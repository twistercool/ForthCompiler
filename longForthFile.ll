

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
%stackType = type { i32, [100 x i32] }

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

define void @Stack_Function_STAR(%stackType* %stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 42)
  %top_0 = call i32 @Stack_Pop(%stackType* %stack)
  call i32 @print_ASCII(i32 %top_0)
  ret void
}

define void @Stack_Function_STARS(%stackType* %stack) nounwind
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
  call void @Stack_Function_STAR(%stackType* %stack)
  %i_local2_3 = load i32, i32* %i_global_1
  %i_local3_4 = add i32 1, %i_local2_3
  store i32 %i_local3_4, i32* %i_global_1
  br label %entry_8
finish_10:
  ret void
}

define void @Stack_Function_F(%stackType* %stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 5)
  call void @Stack_Function_STARS(%stackType* %stack)
  call i32 @printNL()
  call void @Stack_Function_STAR(%stackType* %stack)
  call i32 @printNL()
  call void @Stack_PushInt(%stackType* %stack, i32 5)
  call void @Stack_Function_STARS(%stackType* %stack)
  call i32 @printNL()
  call void @Stack_Function_STAR(%stackType* %stack)
  call i32 @printNL()
  call void @Stack_Function_STAR(%stackType* %stack)
  call i32 @printNL()
  call void @Stack_Function_STAR(%stackType* %stack)
  ret void
}

define void @Stack_Function_FIB(%stackType* %stack) nounwind
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

define void @Stack_Function_FIBS(%stackType* %stack) nounwind
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
  call void @Stack_Function_FIB(%stackType* %stack)
  %i_local2_23 = load i32, i32* %i_global_21
  %i_local3_24 = add i32 1, %i_local2_23
  store i32 %i_local3_24, i32* %i_global_21
  br label %entry_28
finish_30:
  ret void
}

define void @Stack_Function_FACTORIAL(%stackType* %stack) nounwind
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


  ; COMPILED CODE STARTS HERE


  call i32 @printNL()
  call i32 @printNL()
  call void @Stack_Function_F(%stackType* %stack)
  call i32 @printNL()
  call void @Stack_PushInt(%stackType* %stack, i32 40)
  call void @Stack_Function_FIBS(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  call void @Stack_Function_FACTORIAL(%stackType* %stack)
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

  ret i32 0
}
