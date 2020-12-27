

; string template for a number
@.str = private constant [4 x i8] c"%d \00"
; string template for an ASCII character
@.asciiStr = private constant [4 x i8] c"%c \00"

declare i32 @printf(i8*, ...)

define i32 @printInt(i32 %x) {
  %t0 = getelementptr [4 x i8], [4 x i8]* @.str, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* %t0, i32 %x) 
  ret i32 %x
}

define i32 @print_ASCII(i32 %x) {
  %t0 = getelementptr [4 x i8], [4 x i8]* @.asciiStr, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* %t0, i32 %x) 
  ret i32 %x
}

; store the newline as a string constant
; more specifically as a constant array containing i8 integers
@.nl = constant [2 x i8] c"\0A\00"

define i32 @printNL() {
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

  ;%printpopped = call i32 @printInt(i32 %popped)

  call void @Stack_DecrementLength(%stackType* %this)
  ret i32 %popped
}

define i32 @main(i32 %argc, i8** %argv) {
  ; uses the 
  %stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %stack)

  ; bullcode

  ;prints the initial length of the stack: 
  ;%length = call i32 @Stack_GetLength(%stackType* %stack)
  ;%call = call i32 @printInt(i32 %length)



  ;WILL PRINT OUT A RANDOM NUMBER
  ; gets the pointer element at index 0 of the array
  ;%1 = getelementptr %stackType, %stackType* %stack, i32 0, i32 1
  ;%2 = getelementptr [100 x i32], [100 x i32]* %1, i32 0, i32 0
  ; loads the number from the given pointer
  ;%3 = load i32, i32* %2
  ; calls print on the element %3
  ;%4 = call i32 @printInt(i32 %3)

  ;pushes 70 onto the stack and 75
  ;call void @Stack_PushInt(%stackType* %stack, i32 70)
  ;call void @Stack_PushInt(%stackType* %stack, i32 75)

  ; gets the pointer element at index 0 of the array
  ;%5 = getelementptr %stackType, %stackType* %stack, i32 0, i32 1
  ;%6 = getelementptr [100 x i32], [100 x i32]* %1, i32 0, i32 0
  ; loads the number from the given pointer
  ;%7 = load i32, i32* %2
  ; calls print on the element %7
  ;%8 = call i32 @printInt(i32 %7)

  
  ;%popped1 = call i32 @Stack_Pop(%stackType* %stack)
  ;%printpopped1 = call i32 @printInt(i32 %popped1)

  ;%popped2 = call i32 @Stack_Pop(%stackType* %stack)
  ;%printpopped2 = call i32 @printInt(i32 %popped2)





  ;prints the length of the stack after pushing an i32: 
  ;%newlength = call i32 @Stack_GetLength(%stackType* %stack)
  ;%newcall = call i32 @printInt(i32 %newlength)


  ; COMPILED CODE STARTS HERE


  call void @Stack_PushInt(%stackType* %stack, i32 10)
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  %top_5 = call i32 @Stack_Pop(%stackType* %stack)
  %second_6 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_0 = alloca i32
  store i32 %top_5, i32* %i_global_0
  br label %entry_7
entry_7:
  %i_local1_1 = load i32, i32* %i_global_0
  %isIGreater_4 = icmp sge i32 %i_local1_1, %second_6
  br i1 %isIGreater_4, label %finish_9, label %loop_8
loop_8:
  %i_local_10 = load i32, i32* %i_global_0
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_10)
  call void @Stack_PushInt(%stackType* %stack, i32 10)
  %top_11 = call i32 @Stack_Pop(%stackType* %stack)
  %second_12 = call i32 @Stack_Pop(%stackType* %stack)
  %subvalue_13 = sub i32 %second_12, %top_11
  call void @Stack_PushInt(%stackType* %stack, i32 %subvalue_13)
  br label %finish_9
  %top_14 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_15 = call i32 @printInt(i32 %top_14)
  %i_local2_2 = load i32, i32* %i_global_0
  %i_local3_3 = add i32 1, %i_local2_2
  store i32 %i_local3_3, i32* %i_global_0
  br label %entry_7
finish_9:


  ;%a = call i32 @Stack_Pop(%stackType* %stack)
  ;%b = call i32 @Stack_Pop(%stackType* %stack)
  ;%c = call i32 @Stack_Pop(%stackType* %stack)
  ;%d = call i32 @Stack_Pop(%stackType* %stack)
  

  ; allocates 3 to the element at index 5 of the array 
  ;%1 = getelementptr [100 x i32], [100 x i32]* %stack, i32 0, i32 5
  ;store i32 3, i32* %1
  ; gets the pointer element at index 5 of the array
  ;%2 = getelementptr [100 x i32], [100 x i32]* %stack, i32 0, i32 5
  ; loads the number from the given pointer
  ;%3 = load i32, i32* %2

  ; calls print on the element %3
  ;%4 = call i32 @printInt(i32 %3)
  ret i32 0
}
