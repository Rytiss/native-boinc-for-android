/*
 * ifpexp.S
 * Author: Mateusz Szpakowski
 * License: GPLv3
 */

                .arch armv6
                .fpu softvfp
                .eabi_attribute 20, 1
                .eabi_attribute 21, 1
                .eabi_attribute 23, 3
                .eabi_attribute 24, 1
                .eabi_attribute 25, 1
                .eabi_attribute 26, 2
                .eabi_attribute 30, 2
                .eabi_attribute 18, 4
                .text
                .align 3
.Linvlog10_2:
                .quad 14779559426900358911
                .int 3566893131
                .int 1
                .align 3
.Linvlog2:
                .quad 6636037265099849424
                .int 3098164009
                .int 0
                .align 3
                .global ifppow10
                .type   ifppow10, %function
ifppow10:
                adr r1,.Linvlog10_2
                b .Lifpexp_general
                
                .global ifpexp
                .type   ifpexp, %function
ifpexp:
                adr r1,.Linvlog2
                b .Lifpexp_general
                
.Lifpexp_general:
                push {r4,r5,r6,r7,r8,r9,r10,r11,r12,r14}
                sub sp,sp,#8
                
                str r1,[sp] // address of invlog
                
                ldrd r2,[r0]
                ldrd r6,[r1]
                ldr r8,[r1,#8]
                
                /* multiply invlog10_2 and xi
                   result in (r1,r2,r3) */
                mov r14,#0
                umull r4,r5,r2,r6
                umull r9,r10,r3,r6
                umull r11,r12,r2,r7
                adds r9,r9,r5
                adcs r10,r10,#0
                adc r14,r14,#0
                adds r9,r9,r11
                adcs r10,r10,r12
                adc r14,r14,#0
                mov r9,#0
                umull r4,r5,r2,r8
                adds r10,r10,r4
                adcs r14,r14,r5
                adc r9,r9,#0
                umull r4,r5,r3,r7
                adds r1,r10,r4
                adcs r14,r14,r5
                adc r9,r9,#0
                umull r4,r5,r3,r8
                adds r2,r14,r4
                adcs r3,r9,r5
                
                ldr r5,[sp]
                ldrsh r4,[r0,#8]
                ldr r6,[r5,#12]     // mantisa of invlog
                add r4,r4,r6
                addmi r4,r4,#1
                bmi .Lnooneshift
                adds r1,r1,r1    // shift 1
                adcs r2,r2,r2
                adc r3,r3,r3
.Lnooneshift:
                cmp r4,#10      // 1024
                bge .Loutofrange
                
                ldr r8,[r0,#8]  // load sign
                tst r8,r8
                bpl .Ldontneg_x
                rsbs r1,r1,#0
                rscs r2,r2,#0
                rsc r3,r3,#0
.Ldontneg_x:
                tst r4,r4
                bmi .Lifexplessthan1
                
                rsb r10,r4,#30
                adds r9,r8,#0x10000
                mov r7,r3,rrx   // get sign
                asr r7,r7,r10    // integer part
                pkhbt r7,r7,r4 // zeroing higher 16-bits
                
                rsb r5,r4,#32
                lsl r3,r3,r4
                orr r3,r3,r2,lsr r5
                lsl r2,r2,r4
                orr r2,r2,r1,lsr r5
                lsl r1,r1,r4
                
                b .Lafterextract
.Lifexplessthan1:
                lsr r7,r8,#16       // integer part (0 or -1)
                
                adds r9,r8,#0x10000
                movs r3,r3,rrx   // shift right 1 with sign
                movs r2,r2,rrx
                mov r1,r1,rrx
                
                mvn r4,r4       // negate-1
                
                rsbs r5,r4,#32
                bmi .Lshiftover32
                lsr r1,r1,r4
                orr r1,r1,r2,lsl r5
                lsr r2,r2,r4
                orr r2,r2,r3,lsl r5
                asr r3,r3,r4
                b .Lafterextract
.Lshiftover32:
                sub r4,r4,#32
                rsbs r5,r4,#32
                bmi .Lshiftover64
                lsr r1,r2,r4
                orr r1,r1,r3,lsl r5
                asr r2,r3,r4
                asr r3,r3,#32
                b .Lafterextract
.Lshiftover64:  // set as 1
                mov r1,#0
                mov r2,#0
                mov r3,#0x80000000
                mov r5,#0
                b .Ltoset
.Lafterextract:
                and r3,r3,#0x7fffffff
                
                str r7,[r0,#8]
                
                adr r12,.Lpolydata12
                tst r3,#0x40000000
                adrne r12,.Lpolydata23
                and r3,#0x3fffffff
                
                ldrd r4,[r12]
                ldr r6,[r12,#8]
                add r14,r12,#12*15
                add r12,r12,#12
                /* evaluate polynomial */
                /* r1,r2,r3 - xi, r4,r5,r6 - yi */
.Lpolyloop:
                mov r11,#0              // xi*yi
                umull r7,r8,r1,r6
                umull r9,r10,r3,r4
                adds r7,r7,r9
                adcs r8,r8,r10
                adc r11,r11,#0
                umull r9,r10,r2,r5
                adds r7,r7,r9
                adcs r8,r8,r10
                adc r11,r11,#0
                mov r7,#0
                umull r9,r10,r2,r6
                adds r8,r8,r9
                adcs r11,r11,r10
                adc r7,r7,#0
                umull r9,r10,r3,r5
                adds r8,r8,r9
                adcs r11,r11,r10
                adc r7,r7,#0
                umlal r11,r7,r3,r6
                adds r4,r8,r8   // left shift
                adcs r5,r11,r11
                adc r6,r7,r7
                ldrd r8,[r12]
                ldr r10,[r12,#8]        // polydata
                adds r4,r4,r8
                adcs r5,r5,r9
                adc r6,r6,r10
                
                add r12,r12,#12
                cmp r12,r14
                bne .Lpolyloop
                
                str r5,[r0]
                str r6,[r0,#4]
                
                add sp,sp,#8
                pop {r4,r5,r6,r7,r8,r9,r10,r11,r12,r14}
                bx lr
                
.Loutofrange:
                ldr r4,[r0,#8]
                tst r4,r8      // test sign
                bmi .Lsettoinf
                mov r2,#0
                mov r3,#0x80000000
                ldr r5,.Linfmantisa
                b .Ltoset
.Lsettoinf:
                mov r2,#0
                mov r3,#0
                mov r5,#0x8000
.Ltoset:
                strd r2,[r0]
                str r5,[r0,#8]
                
                add sp,sp,#8
                pop {r4,r5,r6,r7,r8,r9,r10,r11,r12,r14}
                bx lr
                
                .align 3
.Linfmantisa:
                .int 0x7fff
                .int 0
.Lpolydata12:
                .int 2188950868,743873,0
                .int 2038635075,12422006,0
                .int 3768725061,237051581,0
                .int 768864723,4100144935,0
                .int 3738006616,645630358,15
                .int 1657982735,2459846732,218
                .int 776425358,17950463,2838
                .int 3738544615,4279639891,32754
                .int 3710707143,1273082443,330788
                .int 1598892821,3474247257,2863359
                .int 361821972,4221888371,20654774
                .int 3372170310,3240636386,119194165
                .int 1864873366,2193985192,515882495
                .int 3841047708,3907501269,1488522235
                .int 8,0,2147483648
.Lpolydata23:
                .int 25958520,1051996,0
                .int 121744957,17567370,0
                .int 314051622,335241562,0
                .int 109599448,1503513279,1
                .int 325168959,1828760993,21
                .int 3681343829,466072135,309
                .int 2315786723,2336464804,4013
                .int 942171145,2405991896,46322
                .int 785286868,1267277333,467805
                .int 3247213279,1184192441,4049402
                .int 3578983183,3902844864,29210262
                .int 394254630,3289034975,168566005
                .int 4113719397,3188106309,729568021
                .int 997450141,3940817592,2105088333
                .int 1501399487,4192101508,3037000499
