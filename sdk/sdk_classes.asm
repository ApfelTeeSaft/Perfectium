INCLUDE include\master.inc

; CRT helpers
EXTRN   memcpy      :PROC
EXTRN   memcmp      :PROC
EXTRN   memmove     :PROC
EXTRN   strcmp      :PROC
EXTRN   strstr      :PROC
EXTRN   strcpy      :PROC
EXTRN   strcat      :PROC
EXTRN   strlen      :PROC
EXTRN   wcslen      :PROC

.data?

szNameBuf       BYTE    256 DUP (?)     ; narrow name of one object component
szFullNameBuf   BYTE    512 DUP (?)     ; assembled full name output

.code


; TArray_Num(arr:QWORD) -> EAX:DWORD
;   Returns arr->Count.
TArray_Num PROC
    mov     eax, DWORD PTR [rcx + 8]    ; return arr->Count
    ret
TArray_Num ENDP

; TArray_GetByIndex(arr:QWORD, idx:DWORD, elem_size:DWORD) -> RAX:QWORD
;   Returns ptr to element at index idx.
;   RAX = arr->Data + (idx * elem_size)
TArray_GetByIndex PROC
    ; RCX = arr, EDX = idx, R8D = elem_size
    mov     rax, QWORD PTR [rcx]    ; rax = Data
    movsx   rdx, edx                ; sign-extend idx to 64-bit
    movsx   r8,  r8d               ; sign-extend elem_size
    imul    rdx, r8                 ; rdx = idx * elem_size
    add     rax, rdx                ; rax = Data + offset
    ret
TArray_GetByIndex ENDP

; TArray_Add(arr:QWORD, elem:QWORD, elem_size:DWORD) -> EAX:DWORD
;   Appends elem (by value copy) to arr.  Grows via FMemory_Realloc if full.
;   Returns new Count.
;
;   Stack: push rbp rbx rsi rdi r12 (5 pushes) + sub 32 = 0 mod 16
TArray_Add PROC
    ; RCX = arr, RDX = elem, R8D = elem_size
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 32                 ; shadow (5 pushes -> RSP = 0 mod 16; sub 32 -> 0)

    mov     rbx, rcx                ; rbx = arr
    mov     rsi, rdx                ; rsi = elem
    movsx   r12, r8d                ; r12 = elem_size (sign-extended)

    ; Check if Count < Max (space available without realloc)
    mov     ecx, DWORD PTR [rbx + 8]    ; ecx = Count
    cmp     ecx, DWORD PTR [rbx + 12]   ; Count vs Max
    jl      @@copy_elem

    ; Grow array: FMemory_Realloc(Data, (Count+1)*elem_size, 0)
    mov     rcx, QWORD PTR [rbx]        ; rcx = Data
    lea     eax, [ecx + 1]              ; eax = Count + 1
    cdqe                                ; sign-extend to RAX
    imul    rax, r12                    ; rax = (Count+1) * elem_size
    mov     rdx, rax                    ; rdx = new byte size
    xor     r8d, r8d                    ; alignment = 0
    call    QWORD PTR [FMemory_Realloc]
    mov     QWORD PTR [rbx], rax        ; arr->Data = new ptr
    mov     ecx, DWORD PTR [rbx + 8]   ; reload Count (unchanged)
    lea     eax, [ecx + 1]
    mov     DWORD PTR [rbx + 12], eax   ; arr->Max = Count + 1

@@copy_elem:
    ; rdi = &arr->Data[Count] = Data + Count*elem_size
    mov     rdi, QWORD PTR [rbx]        ; rdi = Data
    movsx   rax, ecx                    ; rax = Count (from ecx, set above)
    imul    rax, r12                    ; rax = Count * elem_size
    add     rdi, rax                    ; rdi = destination slot

    ; memcpy(dst=rdi, src=rsi, size=r12)
    mov     rcx, rdi
    mov     rdx, rsi
    mov     r8,  r12
    call    memcpy

    ; Count++
    inc     DWORD PTR [rbx + 8]
    mov     eax, DWORD PTR [rbx + 8]    ; return new Count

    add     rsp, 32
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
TArray_Add ENDP

; TArray_RemoveAt(arr:QWORD, idx:DWORD, elem_size:DWORD)
;   Removes element at idx by swapping with the last element (unordered).
;
;   Stack: push rbp rbx rsi rdi (4 pushes) + sub 40 = 0 mod 16
TArray_RemoveAt PROC
    ; RCX = arr, EDX = idx, R8D = elem_size
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    sub     rsp, 40                 ; 4 pushes (RSP = 0 mod 16 after 4); sub 40 (40=8) -> 8 mod 16
    ; Wait: entry 8, push×4 = 8 mod 16 (even pushes restore parity). 8-mod-16 - 40(=8) = 0 

    mov     rbx, rcx                ; rbx = arr
    movsx   rsi, edx                ; rsi = idx (64-bit)
    movsx   rdi, r8d                ; rdi = elem_size

    mov     ecx, DWORD PTR [rbx + 8]    ; ecx = Count
    test    ecx, ecx
    jz      @@done
    movsx   rcx, ecx                    ; rcx = Count (64-bit)
    cmp     rsi, rcx
    jge     @@done                      ; idx >= Count: no-op

    lea     rax, [rcx - 1]              ; rax = last = Count - 1
    cmp     rsi, rax
    je      @@dec_only                  ; idx == last: just decrement

    ; Swap: Data[idx] = Data[last]
    mov     rdx, QWORD PTR [rbx]        ; rdx = Data
    imul    rsi, rdi                    ; rsi = idx * elem_size
    imul    rax, rdi                    ; rax = last * elem_size
    lea     rcx, [rdx + rsi]            ; dst = Data + idx*elem_size
    lea     rdx, [rdx + rax]            ; src = Data + last*elem_size
    mov     r8,  rdi                    ; size = elem_size
    call    memcpy

@@dec_only:
    dec     DWORD PTR [rbx + 8]         ; Count--

@@done:
    add     rsp, 40
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
TArray_RemoveAt ENDP

; TArray_RemoveSingle(arr:QWORD, idx:DWORD, elem_size:DWORD) -> AL:BYTE
; Removes the element at idx (same as RemoveAt) and returns 1 on success.
TArray_RemoveSingle PROC
    ; RCX = arr, EDX = idx, R8D = elem_size
    push    rbp
    push    rbx
    sub     rsp, 40                 ; 2 pushes (entry 8, ×2 -> 0), sub 40(=8) -> 8 mod 16... hmm
    ; Actually: entry 8, push rbp -> 0, push rbx -> 8. sub 40 (=8): 8-8=0 

    mov     rbx, rcx                ; rbx = arr
    mov     ecx, DWORD PTR [rbx + 8]    ; ecx = Count
    movsx   rax, edx                    ; rax = idx
    xor     eax, eax                    ; default return = false

    cmp     edx, DWORD PTR [rbx + 8]
    jge     @@done                      ; idx >= Count

    ; Call TArray_RemoveAt(arr=rbx, idx=edx, elem_size=r8d)
    mov     rcx, rbx
    ; edx already = idx
    ; r8d already = elem_size
    call    TArray_RemoveAt

    mov     al, 1                       ; return true

@@done:
    add     rsp, 40
    pop     rbx
    pop     rbp
    ret
TArray_RemoveSingle ENDP

; TArray_FreeArray(arr:QWORD)
; Frees arr->Data, zeros all fields.
TArray_FreeArray PROC
    ; RCX = arr
    push    rbp
    push    rbx
    sub     rsp, 40

    mov     rbx, rcx
    mov     rcx, QWORD PTR [rbx]        ; rcx = Data ptr
    test    rcx, rcx
    jz      @@zero_fields
    call    QWORD PTR [FMemory_Free]

@@zero_fields:
    xor     eax, eax
    mov     QWORD PTR [rbx],     rax    ; Data = null
    mov     DWORD PTR [rbx + 8], eax    ; Count = 0
    mov     DWORD PTR [rbx + 12], eax   ; Max = 0

    add     rsp, 40
    pop     rbx
    pop     rbp
    ret
TArray_FreeArray ENDP

; TArray_MarkArrayDirty(serializer:QWORD)
; Increments ArrayReplicationKey on FFastArraySerializer base
; ArrayReplicationKey is at offset 0x00 in the serializer (int32_t).
TArray_MarkArrayDirty PROC
    ; RCX = FFastArraySerializer* (base of the owning list)
    ; ArrayReplicationKey is the first field of FFastArraySerializer
    inc     DWORD PTR [rcx]
    ret
TArray_MarkArrayDirty ENDP

; TArray_MarkItemDirty(serializer:QWORD, item:QWORD)
; Marks a single replicated entry as dirty
; Increments the item's ReplicationID field (offset 0x00 in FFortItemEntry
; base, which is the first 12 bytes = FFastArraySerializerItem)
TArray_MarkItemDirty PROC
    ; RCX = FFastArraySerializer*, RDX = item ptr
    push    rbp
    push    rbx
    sub     rsp, 40

    mov     rbx, rdx                    ; rbx = item
    ; Increment item's MostRecentArrayReplicationKey at [item + 4] (WORD)
    inc     WORD PTR [rbx + 4]

    ; Also mark the array dirty
    ; RCX already = serializer
    call    TArray_MarkArrayDirty

    add     rsp, 40
    pop     rbx
    pop     rbp
    ret
TArray_MarkItemDirty ENDP


; FString_Init(str:QWORD)
; Zero-initialises a TArrayHeader (FString) to an empty string.
FString_Init PROC
    ; RCX = TArrayHeader* (FString*)
    xor     eax, eax
    mov     QWORD PTR [rcx],     rax    ; Data = null
    mov     DWORD PTR [rcx + 8], eax    ; Count = 0
    mov     DWORD PTR [rcx + 12], eax   ; Max = 0
    ret
FString_Init ENDP

; FString_FromWideChar(out:QWORD, wstr:QWORD)
; Constructs an FString from a null-terminated wchar_t* source.
; Allocates memory via FMemory_Malloc.
; out->Data = FMemory_Malloc((wcslen(wstr)+1) * 2)
; Copies wstr including null terminator.
;
; Stack: push rbp rbx rsi rdi (4 pushes) + sub 40 = 0 mod 16 
FString_FromWideChar PROC
    ; RCX = TArrayHeader* (out), RDX = wchar_t* (wstr)
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    sub     rsp, 40                 ; 4 pushes: entry 8->0->8->0->8; sub 40(=8) -> 0 

    mov     rdi, rcx                ; rdi = out
    mov     rsi, rdx                ; rsi = wstr

    ; wcslen(wstr) -> RAX = char count (not including null)
    mov     rcx, rsi
    call    wcslen
    mov     rbx, rax                ; rbx = len

    ; FMemory_Malloc((len+1)*2, 0)
    lea     ecx, [eax + 1]          ; ecx = len + 1
    shl     ecx, 1                  ; ecx = (len+1) * 2 bytes
    xor     edx, edx                ; alignment = 0
    call    QWORD PTR [FMemory_Malloc]

    ; Fill out TArrayHeader
    mov     QWORD PTR [rdi],     rax    ; Data = malloc result
    lea     ecx, [ebx + 1]
    mov     DWORD PTR [rdi + 8], ecx    ; Count = len+1
    mov     DWORD PTR [rdi + 12], ecx   ; Max   = len+1

    ; memcpy(Data, wstr, (len+1)*2)
    mov     rcx, rax                ; dst = Data
    mov     rdx, rsi                ; src = wstr
    lea     r8,  [rbx + 1]
    shl     r8,  1                  ; size = (len+1)*2
    call    memcpy

    add     rsp, 40
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
FString_FromWideChar ENDP

; FString_Free(str:QWORD)
; Releases an FString's Data buffer and zeros the header
; Equivalent to FreeArray on TArray<wchar_t>
FString_Free PROC
    ; RCX = TArrayHeader* (FString*)
    jmp     TArray_FreeArray        ; identical logic
FString_Free ENDP

; FName_Init_FromIndex(out:QWORD, index:DWORD)
; Constructs an FName with ComparisonIndex=index, Number=0.
FName_Init_FromIndex PROC
    ; RCX = FName* (8 bytes: ComparisonIndex DWORD + Number DWORD)
    ; EDX = ComparisonIndex
    mov     DWORD PTR [rcx],     edx    ; ComparisonIndex
    mov     DWORD PTR [rcx + 4], 0      ; Number = 0
    ret
FName_Init_FromIndex ENDP


; FGuid_Reset(guid:QWORD)
; Zeroes all four DWORD fields.
FGuid_Reset PROC
    ; RCX = FGuid* (4 × DWORD = 16 bytes)
    xor     eax, eax
    mov     DWORD PTR [rcx],      eax
    mov     DWORD PTR [rcx + 4],  eax
    mov     DWORD PTR [rcx + 8],  eax
    mov     DWORD PTR [rcx + 12], eax
    ret
FGuid_Reset ENDP

; FGuid_Equals(a:QWORD, b:QWORD) -> AL:BYTE (1=equal, 0=not)
; Compares two FGuid structs field by field.
FGuid_Equals PROC
    ; RCX = FGuid* a, RDX = FGuid* b
    mov     eax, DWORD PTR [rcx]
    cmp     eax, DWORD PTR [rdx]
    jne     @@neq
    mov     eax, DWORD PTR [rcx + 4]
    cmp     eax, DWORD PTR [rdx + 4]
    jne     @@neq
    mov     eax, DWORD PTR [rcx + 8]
    cmp     eax, DWORD PTR [rdx + 8]
    jne     @@neq
    mov     eax, DWORD PTR [rcx + 12]
    cmp     eax, DWORD PTR [rdx + 12]
    jne     @@neq
    mov     al, 1
    ret
@@neq:
    xor     al, al
    ret
FGuid_Equals ENDP

; SDK_GetObjectByIndex(index:DWORD) -> RAX:QWORD (UObject*)
; GObjects->Objects[index * 24] -> first QWORD = UObject*
SDK_GetObjectByIndex PROC
    ; ECX = index
    mov     rax, QWORD PTR [GObjects]   ; rax = TUObjectArray*
    test    rax, rax
    jz      @@null
    mov     rax, QWORD PTR [rax]        ; rax = Objects (uint8_t*)
    movsx   rcx, ecx                    ; sign-extend index
    imul    rcx, rcx, 24                ; offset = index * 24
    mov     rax, QWORD PTR [rax + rcx]  ; rax = *(UObject**)(Objects + offset)
    ret
@@null:
    xor     eax, eax
    ret
SDK_GetObjectByIndex ENDP

; Internal helper: UObject_GetNameBuf(obj:QWORD, outBuf:QWORD, maxLen:DWORD)
; Writes null-terminated narrow ASCII name of obj into outBuf (max maxLen bytes).
; Strips path prefix (everything up to and including last '/').
;
;   Stack: push rbp rbx rsi rdi r12 r13 (6 pushes) + sub 56 = 0 mod 16
;   6 pushes: entry 8 -> 0 -> 8 -> 0 -> 8 -> 0 -> 8 (mod 16 after 6 pushes = 8)
;   sub 56 (56=8): 8-8 = 0 
UObject_GetNameBuf PROC
    ; RCX = UObject*, RDX = char* outBuf, R8D = maxLen
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    push    r12
    push    r13
    sub     rsp, 56                 ; 6 pushes (8 mod 16 after all); sub 56(=8) -> 0 

    mov     rbx, rcx                ; rbx = obj
    mov     rdi, rdx                ; rdi = outBuf
    movsx   r12, r8d                ; r12 = maxLen

    ; Null guard
    test    rbx, rbx
    jz      @@empty
    test    rdi, rdi
    jz      @@done

    ; Allocate a local FString header on stack for FNameToString output
    ; [rsp+32..47] = TArrayHeader (Data:QWORD, Count:DWORD, Max:DWORD)
    xor     eax, eax
    mov     QWORD PTR [rsp + 32], rax   ; Data = null
    mov     DWORD PTR [rsp + 40], eax   ; Count = 0
    mov     DWORD PTR [rsp + 44], eax   ; Max = 0

    ; FNameToString(&obj->Name, &stack_fstr)
    ; Check FNameToString is resolved
    mov     rax, QWORD PTR [FNameToString]
    test    rax, rax
    jz      @@empty

    lea     rcx, [rbx + 18h]        ; rcx = &obj->Name (FName*)
    lea     rdx, [rsp + 32]         ; rdx = &stack_fstr (TArrayHeader*)
    call    rax                     ; FNameToString(name_ptr, fstr_ptr)

    ; rsi = wide string Data ptr
    mov     rsi, QWORD PTR [rsp + 32]   ; rsi = fstr.Data (wchar_t*)
    test    rsi, rsi
    jz      @@done

    ; Find last '/' in wide string and skip past it
    ; Scan forward to find the last L'/'.
    ; also find total char count.
    mov     r13, rsi                ; r13 = scan ptr, starts at beginning
    mov     rdx, rsi                ; rdx = current best (start of name portion)
@@scan_slash:
    movzx   eax, WORD PTR [r13]
    test    ax, ax
    jz      @@slash_done
    cmp     ax, 2Fh                 ; L'/'
    jne     @@not_slash
    lea     rdx, [r13 + 2]          ; rdx = char after last '/'
@@not_slash:
    add     r13, 2
    jmp     @@scan_slash
@@slash_done:
    ; rdx = start of name portion (past last '/')

    ; Copy wide chars to narrow into rdi, up to r12 chars
    mov     rcx, r12                ; rcx = remaining capacity
    test    rcx, rcx
    jz      @@free_fstr
    dec     rcx                     ; leave room for null

@@narrow_loop:
    movzx   eax, WORD PTR [rdx]
    test    ax, ax
    jz      @@narrow_done
    mov     BYTE PTR [rdi], al
    add     rdx, 2
    inc     rdi
    dec     rcx
    jnz     @@narrow_loop

@@narrow_done:
    mov     BYTE PTR [rdi], 0       ; null terminate

@@free_fstr:
    ; FMemory_Free(fstr.Data)
    mov     rcx, QWORD PTR [rsp + 32]
    test    rcx, rcx
    jz      @@done
    call    QWORD PTR [FMemory_Free]
    jmp     @@done

@@empty:
    ; Write empty string
    test    rdi, rdi
    jz      @@done
    mov     BYTE PTR [rdi], 0

@@done:
    add     rsp, 56
    pop     r13
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
UObject_GetNameBuf ENDP

; UObject_IsA(obj:QWORD, cmp:QWORD) -> AL:BYTE (1=yes, 0=no)
; Walks the Class->SuperField chain to check class inheritance.
; SuperField of UClass/UStruct is at offset 0x30.
UObject_IsA PROC
    ; RCX = UObject* obj, RDX = UClass* cmp
    test    rcx, rcx
    jz      @@no
    test    rdx, rdx
    jz      @@no

    mov     rax, QWORD PTR [rcx + 10h]  ; rax = obj->Class (UClass*)
@@loop:
    test    rax, rax
    jz      @@no
    cmp     rax, rdx
    je      @@yes
    mov     rax, QWORD PTR [rax + 30h]  ; rax = UStruct::SuperField
    jmp     @@loop

@@yes:
    mov     al, 1
    ret
@@no:
    xor     al, al
    ret
UObject_IsA ENDP

; ------------------------------------------------------------
; UObject_GetFullName(obj:QWORD, outBuf:QWORD, maxLen:DWORD)
;   Builds "ClassName OuterPath.ObjectName" into outBuf.
;
;   Algorithm:
;     1. Get Class->Name -> write to buf as "ClassName"
;     2. Append " "
;     3. Collect up to 8 outers into a local ptr array (outer_ptrs[])
;     4. Iterate outers outermost-first, append each name with "." separator
;     5. Append "." + own name
;
;   Stack frame:
;     outer_ptrs: 8 × QWORD = 64 bytes at [rsp+32..95]
;     6 push regs + sub 112 = 0 mod 16
;     6 pushes after entry: 8->0->8->0->8->0->8 mod 16 (= 8 after 6 pushes)
;     sub 112 (112=0): 8-0 = 8 mod 16... need to adjust.
;     Actually 6 pushes: entry 8; +6×8=48 -> RSP=entry-48. 8-48=8-0=8 mod 16.
;     sub 112 (112 mod 16 = 0): RSP = 8-0 = 8.
;     Need sub N where N = 8 mod 16: e.g. sub 120.
;     outer_ptrs at [rsp+32..95] (8 slots × 8 bytes), plus shadow [rsp+0..31].
UObject_GetFullName PROC
    ; RCX = UObject*, RDX = char* outBuf, R8D = maxLen
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    push    r12
    push    r13
    sub     rsp, 120    ; 6 pushes -> RSP = 8 mod 16; sub 120(=8) -> 0 
                        ; Layout: [rsp+32..95] = outer_ptrs[8] (64 bytes),
                        ;         [rsp+96..119] = scratch pad (24 bytes)

    mov     rbx, rcx                ; rbx = obj
    mov     rdi, rdx                ; rdi = outBuf
    movsx   r12, r8d                ; r12 = maxLen

    ; Start with empty outBuf
    test    rdi, rdi
    jz      @@done
    mov     BYTE PTR [rdi], 0

    test    rbx, rbx
    jz      @@done

    ; Get class name into szNameBuf
    mov     rax, QWORD PTR [rbx + 10h]  ; rax = Class (UClass*)
    test    rax, rax
    jz      @@skip_class_name

    mov     rcx, rax
    lea     rdx, szNameBuf
    mov     r8d, 255
    call    UObject_GetNameBuf

    ; strcat(outBuf, szNameBuf)
    mov     rcx, rdi
    lea     rdx, szNameBuf
    call    strcat

    ; strcat(outBuf, " ")
    mov     rcx, rdi
    lea     rdx, szSpace
    call    strcat

@@skip_class_name:
    ; Collect outer chain
    ; outer_ptrs stored at [rsp+32..95], R13D = depth counter
    xor     r13d, r13d
    mov     rax, QWORD PTR [rbx + 20h]  ; rax = this->Outer

@@collect_outers:
    test    rax, rax
    jz      @@outers_done
    cmp     r13d, 8
    jge     @@outers_done
    ; outer_ptrs[r13] = rax
    movsx   rcx, r13d
    mov     QWORD PTR [rsp + 32 + rcx*8], rax
    inc     r13d
    mov     rax, QWORD PTR [rax + 20h]  ; rax = outer->Outer
    jmp     @@collect_outers

@@outers_done:
    ; Append outers outermost-first (index depth-1 .. 0)
    mov     esi, r13d           ; esi = depth (loop counter, going down)
    test    esi, esi
    jz      @@own_name

@@outer_loop:
    dec     esi
    movsx   rcx, esi
    mov     rax, QWORD PTR [rsp + 32 + rcx*8]  ; outer_ptrs[i]
    mov     rcx, rax
    lea     rdx, szNameBuf
    mov     r8d, 255
    call    UObject_GetNameBuf

    ; strcat(outBuf, szNameBuf)
    mov     rcx, rdi
    lea     rdx, szNameBuf
    call    strcat

    ; Append "." between path segments (and before own name)
    mov     rcx, rdi
    lea     rdx, szDot
    call    strcat

    test    esi, esi
    jnz     @@outer_loop

@@own_name:
    ; Append own name
    mov     rcx, rbx
    lea     rdx, szNameBuf
    mov     r8d, 255
    call    UObject_GetNameBuf

    mov     rcx, rdi
    lea     rdx, szNameBuf
    call    strcat

@@done:
    add     rsp, 120
    pop     r13
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
UObject_GetFullName ENDP

; SDK_FindObject(searchKey:QWORD) -> RAX:QWORD (UObject*)
; Iterates GObjects and returns the first object whose full name
; contains searchKey as a substring (strstr match).
; Maps to: UObject::FindObject<T>(name)
; Stack: push rbp rbx rsi rdi r12 (5 pushes) + sub 40 = 0 mod 16 
SDK_FindObject PROC
    ; RCX = const char* searchKey
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 40                 ; 5 pushes (8 mod 16); sub 40(=8) -> 0 

    mov     r12, rcx                ; r12 = searchKey

    ; Null / not-ready guards
    test    r12, r12
    jz      @@not_found
    mov     rbx, QWORD PTR [GObjects]
    test    rbx, rbx
    jz      @@not_found

    ; Get NumElements from [rbx + 0Ch]
    mov     edi, DWORD PTR [rbx + 0Ch]  ; edi = NumElements
    xor     esi, esi                     ; esi = index

@@scan_loop:
    cmp     esi, edi
    jge     @@not_found

    ; obj = GObjects->Objects[esi * 24]
    mov     rax, QWORD PTR [rbx]        ; rax = Objects ptr
    movsx   rcx, esi
    imul    rcx, rcx, 24
    mov     rax, QWORD PTR [rax + rcx]  ; rax = UObject*
    inc     esi
    test    rax, rax
    jz      @@scan_loop                 ; skip null slots

    ; Get full name into szFullNameBuf
    mov     rcx, rax
    lea     rdx, szFullNameBuf
    mov     r8d, 511
    call    UObject_GetFullName

    ; strstr(szFullNameBuf, searchKey)
    lea     rcx, szFullNameBuf
    mov     rdx, r12
    call    strstr
    test    rax, rax
    jz      @@scan_loop

    ; Found: reload the object ptr (re-derive from esi-1)
    mov     rax, QWORD PTR [rbx]
    lea     rcx, [rsi - 1]
    imul    rcx, rcx, 24
    mov     rax, QWORD PTR [rax + rcx]
    jmp     @@done

@@not_found:
    xor     eax, eax

@@done:
    add     rsp, 40
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
SDK_FindObject ENDP

; SDK_FindClass(searchKey:QWORD) -> RAX:QWORD (UClass*)
; Returns the first UClass whose full name exactly equals searchKey.
; Maps to: UObject::FindClass(name)
SDK_FindClass PROC
    ; RCX = const char* searchKey (exact full name)
    push    rbp
    push    rbx
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 40

    mov     r12, rcx

    test    r12, r12
    jz      @@not_found
    mov     rbx, QWORD PTR [GObjects]
    test    rbx, rbx
    jz      @@not_found

    mov     edi, DWORD PTR [rbx + 0Ch]
    xor     esi, esi

@@scan_loop:
    cmp     esi, edi
    jge     @@not_found

    mov     rax, QWORD PTR [rbx]
    movsx   rcx, esi
    imul    rcx, rcx, 24
    mov     rax, QWORD PTR [rax + rcx]
    inc     esi
    test    rax, rax
    jz      @@scan_loop

    ; Build full name
    mov     rcx, rax
    lea     rdx, szFullNameBuf
    mov     r8d, 511
    call    UObject_GetFullName

    ; strcmp(szFullNameBuf, searchKey)
    lea     rcx, szFullNameBuf
    mov     rdx, r12
    call    strcmp
    test    eax, eax
    jnz     @@scan_loop

    ; Exact match — reload object ptr
    mov     rax, QWORD PTR [rbx]
    lea     rcx, [rsi - 1]
    imul    rcx, rcx, 24
    mov     rax, QWORD PTR [rax + rcx]
    jmp     @@done

@@not_found:
    xor     eax, eax

@@done:
    add     rsp, 40
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    pop     rbp
    ret
SDK_FindClass ENDP

; ProcessEvent_Call(obj:QWORD, fn:QWORD, params:QWORD)
; Indirect call through the ProcessEvent function pointer.
; Maps to: ProcessEvent(Object, Function, Params)
ProcessEvent_Call PROC
    ; RCX = UObject*, RDX = UFunction*, R8 = void* params
    push    rbp
    push    rbx
    sub     rsp, 40

    mov     rax, QWORD PTR [ProcessEvent]
    test    rax, rax
    jz      @@done
    call    rax                     ; ProcessEvent(obj, fn, params) — rcx/rdx/r8 already set

@@done:
    add     rsp, 40
    pop     rbx
    pop     rbp
    ret
ProcessEvent_Call ENDP

.const

szSpace         DB  " ", 0
szDot           DB  ".", 0

END