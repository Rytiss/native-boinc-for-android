/*
 * arithmetic-arm.S
 * Mateusz Szpakowski
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
                .align  2
                .global mod64_arm_init
                .type   mod64_arm_init, %function
mod64_arm_init:
                push {r4,r5,r6,r7,r8,r9,r10,r11,r12}
                sub sp,sp,#8
                
                ldr r2,.LGOT0
.LPIC0:
                add r2,pc,r2
                ldr r3,.LGOT0+4
                ldr r4,[r2,r3]
                strd r0,[r4,#16]    // save p in mod
                lsl r6,r0,#2
                lsl r7,r1,#2
                orr r7,r7,r0,lsr #30
                strd r6,[r4,#40]    // save ptimes4
                
                strd r0,[sp]    // save p
                
                tst r1,r1 // clz(p)
                clz r2,r1
                clzeq r3,r0
                addeq r2,r2,r3
                add r2,#1
                // p << clzp
                rsbs r3,r2,#32
                submi r3,r2,#32
                lslmi r5,r0,r3
                lslpl r5,r1,r2
                orrpl r5,r5,r0,lsr r3
                lsl r4,r0,r2
                mov r1,#0x80000000 // onep
                mov r0,#0
                // newton raphson loop
                // iter=0
                umull r6,r7,r0,r4       // onep*dc
                umull r8,r9,r1,r4
                umull r10,r11,r0,r5
                umull r3,r12,r1,r5
                adds r8,r8,r7
                adcs r9,r9,#0
                adc r12,r12,#0
                adds r8,r8,r10
                adcs r9,r9,r11
                adc r12,r12,#0
                adds r3,r3,r9
                adc r12,r12,#0
                adds r3,r3,r0         // -mul-onep
                adc r12,r12,r1
                rsbs r3,r3,#0
                rsc r12,r12,#0
                umull r6,r7,r3,r0       // t*onep
                umull r8,r9,r12,r0
                umull r10,r11,r3,r1
                umull r3,r12,r12,r1
                adds r8,r8,r7
                adcs r9,r9,#0
                adc r12,r12,#0
                adds r8,r8,r10
                adcs r9,r9,r11
                adc r12,r12,#0
                adds r3,r3,r9
                adc r12,r12,#0
                adds r0,r0,r3          // tmp+onep
                adc r1,r1,r12
                // iter=1
                umull r6,r7,r0,r4       // onep*dc
                umull r8,r9,r1,r4
                umull r10,r11,r0,r5
                umull r3,r12,r1,r5
                adds r8,r8,r7
                adcs r9,r9,#0
                adc r12,r12,#0
                adds r8,r8,r10
                adcs r9,r9,r11
                adc r12,r12,#0
                adds r3,r3,r9
                adc r12,r12,#0
                adds r3,r3,r0         // -mul-onep
                adc r12,r12,r1
                rsbs r3,r3,#0
                rsc r12,r12,#0
                umull r6,r7,r3,r0       // t*onep
                umull r8,r9,r12,r0
                umull r10,r11,r3,r1
                umull r3,r12,r12,r1
                adds r8,r8,r7
                adcs r9,r9,#0
                adc r12,r12,#0
                adds r8,r8,r10
                adcs r9,r9,r11
                adc r12,r12,#0
                adds r3,r3,r9
                adc r12,r12,#0
                adds r0,r0,r3          // tmp+onep
                adc r1,r1,r12
                // iter=2
                umull r6,r7,r0,r4       // onep*dc
                umull r8,r9,r1,r4
                umull r10,r11,r0,r5
                umull r3,r12,r1,r5
                adds r8,r8,r7
                adcs r9,r9,#0
                adc r12,r12,#0
                adds r8,r8,r10
                adcs r9,r9,r11
                adc r12,r12,#0
                adds r3,r3,r9
                adc r12,r12,#0
                adds r3,r3,r0         // -mul-onep
                adc r12,r12,r1
                rsbs r3,r3,#0
                rsc r12,r12,#0
                umull r6,r7,r3,r0       // t*onep
                umull r8,r9,r12,r0
                umull r10,r11,r3,r1
                umull r3,r12,r12,r1
                adds r8,r8,r7
                adcs r9,r9,#0
                adc r12,r12,#0
                adds r8,r8,r10
                adcs r9,r9,r11
                adc r12,r12,#0
                adds r3,r3,r9
                adc r12,r12,#0
                adds r0,r0,r3          // tmp+onep
                adc r1,r1,r12
                // iter=3
                umull r6,r7,r0,r4       // onep*dc
                umull r8,r9,r1,r4
                umull r10,r11,r0,r5
                umull r3,r12,r1,r5
                adds r8,r8,r7
                adcs r9,r9,#0
                adc r12,r12,#0
                adds r8,r8,r10
                adcs r9,r9,r11
                adc r12,r12,#0
                adds r3,r3,r9
                adc r12,r12,#0
                adds r3,r3,r0         // -mul-onep
                adc r12,r12,r1
                rsbs r3,r3,#0
                rsc r12,r12,#0
                umull r6,r7,r3,r0       // t*onep
                umull r8,r9,r12,r0
                umull r10,r11,r3,r1
                umull r3,r12,r12,r1
                adds r8,r8,r7
                adcs r9,r9,#0
                adc r12,r12,#0
                adds r8,r8,r10
                adcs r9,r9,r11
                adc r12,r12,#0
                adds r3,r3,r9
                adc r12,r12,#0
                adds r0,r0,r3          // tmp+onep
                adc r1,r1,r12
                // iter=4
                umull r6,r7,r0,r4       // onep*dc
                umull r8,r9,r1,r4
                umull r10,r11,r0,r5
                umull r3,r12,r1,r5
                adds r8,r8,r7
                adcs r9,r9,#0
                adc r12,r12,#0
                adds r8,r8,r10
                adcs r9,r9,r11
                adc r12,r12,#0
                adds r3,r3,r9
                adc r12,r12,#0
                adds r3,r3,r0         // -mul-onep
                adc r12,r12,r1
                rsbs r3,r3,#0
                rsc r12,r12,#0
                umull r6,r7,r3,r0       // t*onep
                umull r8,r9,r12,r0
                umull r10,r11,r3,r1
                umull r3,r12,r12,r1
                adds r8,r8,r7
                adcs r9,r9,#0
                adc r12,r12,#0
                adds r8,r8,r10
                adcs r9,r9,r11
                adc r12,r12,#0
                adds r3,r3,r9
                adc r12,r12,#0
                adds r0,r0,r3          // tmp+onep
                adc r1,r1,r12
                // iter=5
                umull r6,r7,r0,r4       // onep*dc
                umull r8,r9,r1,r4
                umull r10,r11,r0,r5
                umull r3,r12,r1,r5
                adds r8,r8,r7
                adcs r9,r9,#0
                adc r12,r12,#0
                adds r8,r8,r10
                adcs r9,r9,r11
                adc r12,r12,#0
                adds r3,r3,r9
                adc r12,r12,#0
                adds r3,r3,r0         // -mul-onep
                adc r12,r12,r1
                rsbs r3,r3,#0
                rsc r12,r12,#0
                umull r6,r7,r3,r0       // t*onep
                umull r8,r9,r12,r0
                umull r10,r11,r3,r1
                umull r3,r12,r12,r1
                adds r8,r8,r7
                adcs r9,r9,#0
                adc r12,r12,#0
                adds r8,r8,r10
                adcs r9,r9,r11
                adc r12,r12,#0
                adds r3,r3,r9
                adc r12,r12,#0
                adds r0,r0,r3          // tmp+onep
                adc r1,r1,r12
                // iter=6
                umull r6,r7,r0,r4       // onep*dc
                umull r8,r9,r1,r4
                umull r10,r11,r0,r5
                umull r3,r12,r1,r5
                adds r8,r8,r7
                adcs r9,r9,#0
                adc r12,r12,#0
                adds r8,r8,r10
                adcs r9,r9,r11
                adc r12,r12,#0
                adds r3,r3,r9
                adc r12,r12,#0
                adds r3,r3,r0         // -mul-onep
                adc r12,r12,r1
                rsbs r3,r3,#0
                rsc r12,r12,#0
                umull r6,r7,r3,r0       // t*onep
                umull r8,r9,r12,r0
                umull r10,r11,r3,r1
                umull r3,r12,r12,r1
                adds r8,r8,r7
                adcs r9,r9,#0
                adc r12,r12,#0
                adds r8,r8,r10
                adcs r9,r9,r11
                adc r12,r12,#0
                adds r3,r3,r9
                adc r12,r12,#0
                adds r0,r0,r3          // tmp+onep
                adc r1,r1,r12
                // save to onep
                ldr r3,.LGOT1
.LPIC1:
                add r3,pc,r3
                ldr r4,.LGOT1+4
                ldr r5,[r3,r4]
                strd r0,[r5]
                str r2,[r5,#32] // clzp
                ldrd r0,[sp] // p
                // p<<(clzp-2)
                sub r2,r2,#2
                rsbs r8,r2,#32
                submi r8,r2,#32
                lslmi r7,r0,r8
                lslpl r7,r1,r2
                orrpl r7,r7,r0,lsr r8
                lsl r6,r0,r2
                strd r6,[r5,#48]
                // pmask = (1<<(clzp-4))-1
                rsb r2,r2,#33
                mov r6,#0x80000000
                asr r6,r6,r2
                str r6,[r5,#64]
                
                add sp,sp,#8
                pop {r4,r5,r6,r7,r8,r9,r10,r11,r12}
                bx lr
.Lend1:
                .align  2
.LGOT0:
                .word _GLOBAL_OFFSET_TABLE_-(.LPIC0+8)
                .word mod64_init_data(GOT)
.LGOT1:
                .word _GLOBAL_OFFSET_TABLE_-(.LPIC1+8)
                .word mod64_init_data(GOT)
                
                .align  2
                .global mulmod64_arm
                .type   mulmod64_arm, %function
mulmod64_arm:
                push {r4,r5,r6,r7,r8,r9,r10,r11}
                ldrd r4,[sp,#32]        // a+p
                adds r0,r0,r4
                adc r1,r1,r5
                adds r2,r2,r4           // b+p
                adc r3,r3,r5
                tst r1,r1               // clz(a)
                clz r4,r1
                clzeq r5,r0
                addeq r4,r4,r5
                tst r3,r3               // clz(b)
                clz r5,r3
                clzeq r6,r2
                addeq r5,r5,r6
                umull r6,r7,r0,r2        // a*b
                mla r7,r1,r2,r7
                mla r7,r0,r3,r7
                rsbs r8,r4,#32          // a<<clz(a)
                submi r8,r4,#32
                lslmi r1,r0,r8
                lslpl r1,r1,r4
                orrpl r1,r1,r0,lsr r8
                lsl r0,r0,r4
                rsbs r8,r5,#32          // b<<clz(b)
                submi r8,r5,#32
                lslmi r3,r2,r8
                lslpl r3,r3,r5
                orrpl r3,r3,r2,lsr r8
                lsl r2,r2,r5
                add r4,r4,r5            // clza+clzb
                // mulh(ac*bc)
                umull r5,r8,r0,r3
                umull r9,r10,r1,r2
                umull r0,r1,r1,r3
                adds r5,r5,r9
                adcs r8,r8,r10
                adc r1,r1,#0
                adds r0,r0,r8
                adc r1,r1,#0
                // load onep
                ldr r2,.LGOT2
.LPIC2:
                add r2,pc,r2
                ldr r3,.LGOT2+4
                ldr r5,[r2,r3]
                ldrd r8,[r5]
                ldr r5,[r5,#32] // clzp
                sub r4,r4,r5
                // mulh(tmp*onep)
                umull r2,r3,r0,r9
                umull r5,r10,r1,r8
                umull r0,r1,r1,r9
                adds r2,r2,r5
                adcs r3,r3,r10
                adc r1,r1,#0
                adds r0,r0,r3
                adc r1,r1,#0
                // tmp>>(clza+clzb-clzp)
                rsbs r5,r4,#32
                submi r5,r4,#32
                lsrmi r0,r1,r5
                lsrpl r0,r0,r4
                orrpl r0,r0,r1,lsl r5
                lsr r1,r1,r4
                // tmp*p
                ldrd r2,[sp,#32]
                umull r8,r9,r0,r2
                mla r9,r1,r2,r9
                mla r9,r3,r0,r9
                // a*b-tmp*p
                subs r0,r6,r8
                sbcs r1,r7,r9
                bpl .Lnoadd
                adds r0,r0,r2
                adc r1,r1,r3
.Lnoadd:
                subs r2,r0,r2
                sbcs r3,r1,r3
                movpl r0,r2
                movpl r1,r3
                pop {r4,r5,r6,r7,r8,r9,r10,r11}
                bx lr
.Lend2:
                .align  2
.LGOT2:
                .word _GLOBAL_OFFSET_TABLE_-(.LPIC2+8)
                .word mod64_init_data(GOT)
                
                .align  2
                .global sqrmod64_arm
                .type   sqrmod64_arm, %function
sqrmod64_arm:
                push {r4,r5,r6,r7,r8,r9,r10,r11,r12}
                adds r0,r0,r2
                adc r1,r1,r3
                tst r1,r1               // clz(a)
                clz r4,r1
                clzeq r5,r0
                addeq r4,r4,r5
                umull r6,r7,r0,r0        // a*a
                mla r7,r1,r0,r7
                mla r7,r1,r0,r7
                rsbs r5,r4,#32          // a<<clz(a)
                submi r5,r4,#32
                lslmi r1,r0,r5
                lslpl r1,r1,r4
                orrpl r1,r1,r0,lsr r5
                lsl r0,r0,r4
                lsl r4,r4,#1            // 2*clza
                // mulh(ac*bc)
                umull r5,r8,r0,r1
                umull r0,r1,r1,r1
                adds r5,r5,r5
                adcs r8,r8,r8
                adc r1,r1,#0
                adds r0,r0,r8
                adc r1,r1,#0
                // load onep
                ldr r5,.LGOT3
.LPIC3:
                add r5,pc,r5
                ldr r8,.LGOT3+4
                ldr r10,[r5,r8]
                ldrd r8,[r10]
                ldr r5,[r10,#32] // clzp
                sub r4,r4,r5
                // mulh(tmp*onep)
                umull r5,r10,r0,r9
                umull r11,r12,r1,r8
                umull r0,r1,r1,r9
                adds r5,r5,r11
                adcs r10,r10,r12
                adc r1,r1,#0
                adds r0,r0,r10
                adc r1,r1,#0
                // tmp>>(clza+clzb-clzp)
                rsbs r5,r4,#32
                submi r5,r4,#32
                lsrmi r0,r1,r5
                lsrpl r0,r0,r4
                orrpl r0,r0,r1,lsl r5
                lsr r1,r1,r4
                // tmp*p
                umull r8,r9,r0,r2
                mla r9,r1,r2,r9
                mla r9,r3,r0,r9
                // a*b-tmp*p
                subs r0,r6,r8
                sbcs r1,r7,r9
                bpl .Lnoadd3
                adds r0,r0,r2
                adc r1,r1,r3
.Lnoadd3:
                subs r2,r0,r2
                sbcs r3,r1,r3
                movpl r0,r2
                movpl r1,r3
                pop {r4,r5,r6,r7,r8,r9,r10,r11,r12}
                bx lr
.Lend3:
                .align  2
.LGOT3:
                .word _GLOBAL_OFFSET_TABLE_-(.LPIC3+8)
                .word mod64_init_data(GOT)
                
                .align  2
                .global premulmod64_arm_init
                .type   premulmod64_arm_init, %function
premulmod64_arm_init:
                push {r4,r5,r6,r7,r8,r9,r10,r11}
                ldr r4,.LGOT4
.LPIC4:
                add r4,pc,r4
                ldr r5,.LGOT4+4
                ldr r6,[r4,r5]
                ldrd r2,[r6]    // onep
                ldrd r8,[r6,#16]    // p
                strd r0,[r6,#24]    // b
                
                adds r0,r0,r8   // b+p
                adc r1,r1,r9
                
                tst r1,r1               // clz(b)
                clz r4,r1
                clzeq r5,r0
                addeq r4,r4,r5
                
                ldr r7,[r6,#32]     // clzp
                sub r5,r4,r7
                str r5,[r6,#36]     // clzp(bbyp)
                
                rsbs r8,r4,#32          // b<<clz(b)
                submi r8,r4,#32
                lslmi r1,r0,r8
                lslpl r1,r1,r4
                orrpl r1,r1,r0,lsr r8
                lsl r0,r0,r4
                // bc*onep
                mov r11,#0
                umull r9,r10,r0,r2
                umull r4,r5,r0,r3
                umull r7,r8,r1,r2
                umull r0,r1,r1,r3
                adds r4,r4,r10
                adcs r5,r5,#0
                adc r11,r11,#0
                adds r4,r4,r7
                adcs r5,r5,r8
                adc r11,r11,#0
                adds r0,r0,r5
                adc r1,r1,r11
                strd r0,[r6,#8]     // bbyp
                
                pop {r4,r5,r6,r7,r8,r9,r10,r11}
                bx lr
.Lend4:
                .align  2
.LGOT4:
                .word _GLOBAL_OFFSET_TABLE_-(.LPIC4+8)
                .word mod64_init_data(GOT)

                .align  2
                .global premulmod64_arm
                .type   premulmod64_arm, %function
premulmod64_arm:
                push {r4,r5,r6,r7,r8,r9,r10,r11,r12}
                ldrd r4,[sp,#36]        // a+p
                adds r0,r0,r4
                adc r1,r1,r5
                adds r2,r2,r4
                adc r3,r3,r5
                tst r1,r1               // clz(a)
                clz r4,r1
                clzeq r5,r0
                addeq r4,r4,r5
                
                umull r11,r12,r0,r2        // a*b
                mla r12,r1,r2,r12
                mla r12,r0,r3,r12
                
                rsbs r5,r4,#32          // a<<clz(a)
                submi r5,r4,#32
                lslmi r1,r0,r5
                lslpl r1,r1,r4
                orrpl r1,r1,r0,lsr r5
                lsl r0,r0,r4
                // load bbyp
                ldr r7,.LGOT5
.LPIC5:
                add r7,pc,r7
                ldr r5,.LGOT5+4
                ldr r6,[r7,r5]
                ldrd r8,[r6,#8]    // bbyp
                
                // ac*bbyp
                umull r2,r3,r0,r9
                umull r7,r10,r1,r8
                umull r0,r1,r1,r9
                adds r2,r2,r7
                adcs r3,r3,r10
                adc r1,r1,#0
                adds r0,r0,r3
                adc r1,r1,#0
                
                ldr r2,[r6,#36]
                add r4,r2,r4
                
                rsbs r5,r4,#32
                submi r5,r4,#32
                lsrmi r0,r1,r5
                lsrpl r0,r0,r4
                orrpl r0,r0,r1,lsl r5
                lsr r1,r1,r4
                
                // tmp*p
                ldrd r2,[sp,#36]
                umull r8,r9,r0,r2
                mla r9,r1,r2,r9
                mla r9,r3,r0,r9
                // a*b-tmp*p
                subs r0,r11,r8
                sbcs r1,r12,r9
                bpl .Lnoadd2
                adds r0,r0,r2
                adc r1,r1,r3
.Lnoadd2:
                subs r2,r0,r2
                sbcs r3,r1,r3
                movpl r0,r2
                movpl r1,r3
                
                pop {r4,r5,r6,r7,r8,r9,r10,r11,r12}
                bx lr
.Lend5:
                .align  2
.LGOT5:
                .word _GLOBAL_OFFSET_TABLE_-(.LPIC5+8)
                .word mod64_init_data(GOT)

.align  2
                .global premulmod64_arm_init_shifted
                .type   premulmod64_arm_init_shifted, %function
premulmod64_arm_init_shifted:
                push {r4,r5,r6,r7,r8,r9,r10,r11}
                ldr r4,.LGOT6
.LPIC6:
                add r4,pc,r4
                ldr r5,.LGOT6+4
                ldr r6,[r4,r5]
                ldrd r2,[r6]    // onep
                ldrd r8,[r6,#16]    // p
                
                cmp r9,#0x01000000
                movlo r4,#14            // for p<(2^56)
                movhs r5,#1             // for p>=(2^56)
                adds r2,r2,r4
                adc r3,r3,#0
                
                adds r0,r0,r8   // b+p
                adc r1,r1,r9
                
                ldr r4,[r6,#32]
                rsb r5,r4,#33
                mov r7,#1
                lsl r7,r7,r5            // mybit
                cmp r1,r7               // mybit>=newb
                bhs .Lnoadd4
                adds r0,r0,r8   // b+p
                adc r1,r1,r9
.Lnoadd4:       
                strd r0,[r6,#72]    // b
                
                sub r4,r4,#2
                rsbs r8,r4,#32          // b<<clz(b)
                submi r8,r4,#32
                lslmi r1,r0,r8
                lslpl r1,r1,r4
                orrpl r1,r1,r0,lsr r8
                lsl r0,r0,r4
                // bc*onep
                mov r11,#0
                umull r9,r10,r0,r2
                umull r4,r5,r0,r3
                umull r7,r8,r1,r2
                umull r0,r1,r1,r3
                adds r4,r4,r10
                adcs r5,r5,#0
                adc r11,r11,#0
                adds r4,r4,r7
                adcs r5,r5,r8
                adc r11,r11,#0
                adds r0,r0,r5
                adc r1,r1,r11
                
                strd r0,[r6,#56]     // bbyp2
                
                pop {r4,r5,r6,r7,r8,r9,r10,r11}
                bx lr
.Lend6:
                .align  2
.LGOT6:
                .word _GLOBAL_OFFSET_TABLE_-(.LPIC6+8)
                .word mod64_init_data(GOT)
                
                .align 2
                .comm mod64_init_data, 80
