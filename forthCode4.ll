

@.str = private constant [12 x i8] c"Output: %d\0A\00"

declare i32 @printf(i8*, ...)

define i32 @printInt(i32 %x) {
   %t0 = getelementptr [12 x i8], [12 x i8]* @.str, i32 0, i32 0
   call i32 (i8*, ...) @printf(i8* %t0, i32 %x) 
   ret i32 %x
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


  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  call void @Stack_PushInt(%stackType* %stack, i32 2)
  call void @Stack_PushInt(%stackType* %stack, i32 3)
  call void @Stack_PushInt(%stackType* %stack, i32 -4)
  br label %entryLabel_3
entryLabel_3:
  %top_0 = call i32 @Stack_Pop(%stackType* %stack)
  %compare_2 = icmp sge i32 %top_0, 0
  br i1 %compare_2, label %ifpositive_4, label %else_5
ifpositive_4:
  call void @Stack_PushInt(%stackType* %stack, i32 %top_0)
  br label %finish_6
else_5:
  %minustop_1 = sub i32 0, %top_0
  call void @Stack_PushInt(%stackType* %stack, i32 %minustop_1)
  br label %finish_6
finish_6:
  %top_7 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_8 = call i32 @printInt(i32 %top_7)
  br label %entryLabel_12
entryLabel_12:
  %top_9 = call i32 @Stack_Pop(%stackType* %stack)
  %compare_11 = icmp sge i32 %top_9, 0
  br i1 %compare_11, label %ifpositive_13, label %else_14
ifpositive_13:
  call void @Stack_PushInt(%stackType* %stack, i32 %top_9)
  br label %finish_15
else_14:
  %minustop_10 = sub i32 0, %top_9
  call void @Stack_PushInt(%stackType* %stack, i32 %minustop_10)
  br label %finish_15
finish_15:
  %top_16 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_17 = call i32 @printInt(i32 %top_16)
  br label %entryLabel_21
entryLabel_21:
  %top_18 = call i32 @Stack_Pop(%stackType* %stack)
  %compare_20 = icmp sge i32 %top_18, 0
  br i1 %compare_20, label %ifpositive_22, label %else_23
ifpositive_22:
  call void @Stack_PushInt(%stackType* %stack, i32 %top_18)
  br label %finish_24
else_23:
  %minustop_19 = sub i32 0, %top_18
  call void @Stack_PushInt(%stackType* %stack, i32 %minustop_19)
  br label %finish_24
finish_24:
  %top_25 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_26 = call i32 @printInt(i32 %top_25)
  br label %entryLabel_30
entryLabel_30:
  %top_27 = call i32 @Stack_Pop(%stackType* %stack)
  %compare_29 = icmp sge i32 %top_27, 0
  br i1 %compare_29, label %ifpositive_31, label %else_32
ifpositive_31:
  call void @Stack_PushInt(%stackType* %stack, i32 %top_27)
  br label %finish_33
else_32:
  %minustop_28 = sub i32 0, %top_27
  call void @Stack_PushInt(%stackType* %stack, i32 %minustop_28)
  br label %finish_33
finish_33:
  %top_34 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_35 = call i32 @printInt(i32 %top_34)


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
