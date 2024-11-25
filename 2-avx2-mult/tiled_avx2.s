	.file	"tiled_avx2.c"
	.text
	.p2align 4
	.globl	create_matrix
	.def	create_matrix;	.scl	2;	.type	32;	.endef
	.seh_proc	create_matrix
create_matrix:
	pushq	%rdi
	.seh_pushreg	%rdi
	pushq	%rsi
	.seh_pushreg	%rsi
	pushq	%rbx
	.seh_pushreg	%rbx
	subq	$32, %rsp
	.seh_stackalloc	32
	.seh_endprologue
	movslq	%ecx, %rcx
	movl	%edx, %ebx
	movq	%rcx, %rdi
	salq	$3, %rcx
	call	malloc
	movl	%edi, %ecx
	imull	%ebx, %ecx
	movq	%rax, %rsi
	movslq	%ecx, %rcx
	salq	$3, %rcx
	call	malloc
	movq	%rax, (%rsi)
	cmpl	$1, %edi
	jle	.L1
	movslq	%ebx, %r8
	salq	$3, %r8
	leaq	(%rax,%r8), %rdx
	movq	%rdx, 8(%rsi)
	cmpl	$2, %edi
	je	.L1
	leal	-3(%rdi), %ecx
	cmpl	$6, %ecx
	jbe	.L8
	leal	-2(%rdi), %r8d
	vmovq	%rax, %xmm5
	movl	$8, %edx
	vmovdqu	.LC0(%rip), %ymm4
	movl	%r8d, %ecx
	vpbroadcastq	%xmm5, %ymm2
	vmovd	%edx, %xmm3
	movq	%rsi, %rax
	shrl	$3, %ecx
	vmovd	%ebx, %xmm5
	vpbroadcastd	%xmm3, %ymm3
	salq	$6, %rcx
	vpbroadcastd	%xmm5, %ymm5
	addq	%rsi, %rcx
	.p2align 4,,10
	.p2align 3
.L9:
	vmovdqa	%ymm4, %ymm0
	addq	$64, %rax
	vpaddd	%ymm3, %ymm4, %ymm4
	vpmulld	%ymm5, %ymm0, %ymm0
	vpermq	$216, %ymm0, %ymm0
	vpshufd	$80, %ymm0, %ymm1
	vpshufd	$250, %ymm0, %ymm0
	vpmuldq	%ymm3, %ymm1, %ymm1
	vpmuldq	%ymm3, %ymm0, %ymm0
	vpaddq	%ymm2, %ymm1, %ymm1
	vpaddq	%ymm2, %ymm0, %ymm0
	vmovdqu	%ymm1, -48(%rax)
	vmovdqu	%ymm0, -16(%rax)
	cmpq	%rax, %rcx
	jne	.L9
	movl	%r8d, %edx
	andl	$-8, %edx
	andl	$7, %r8d
	leal	2(%rdx), %ecx
	je	.L23
	movl	%ebx, %eax
	movq	(%rsi), %r9
	imull	%ecx, %eax
	movslq	%ecx, %rcx
	leaq	0(,%rcx,8), %r8
	movslq	%eax, %r10
	leaq	(%r9,%r10,8), %r9
	movq	%r9, (%rsi,%rcx,8)
	leal	3(%rdx), %ecx
	cmpl	%ecx, %edi
	jle	.L23
	movq	(%rsi), %rcx
	addl	%ebx, %eax
	movslq	%eax, %r9
	leaq	(%rcx,%r9,8), %rcx
	movq	%rcx, 8(%rsi,%r8)
	leal	4(%rdx), %ecx
	cmpl	%ecx, %edi
	jle	.L23
	movq	(%rsi), %rcx
	addl	%ebx, %eax
	movslq	%eax, %r9
	leaq	(%rcx,%r9,8), %rcx
	movq	%rcx, 16(%rsi,%r8)
	leal	5(%rdx), %ecx
	cmpl	%ecx, %edi
	jle	.L23
	movq	(%rsi), %rcx
	addl	%ebx, %eax
	movslq	%eax, %r9
	leaq	(%rcx,%r9,8), %rcx
	movq	%rcx, 24(%rsi,%r8)
	leal	6(%rdx), %ecx
	cmpl	%ecx, %edi
	jle	.L23
	movq	(%rsi), %rcx
	addl	%ebx, %eax
	movslq	%eax, %r9
	leaq	(%rcx,%r9,8), %rcx
	movq	%rcx, 32(%rsi,%r8)
	leal	7(%rdx), %ecx
	cmpl	%ecx, %edi
	jle	.L23
	movq	(%rsi), %rcx
	addl	%ebx, %eax
	addl	$8, %edx
	movslq	%eax, %r9
	leaq	(%rcx,%r9,8), %rcx
	movq	%rcx, 40(%rsi,%r8)
	cmpl	%edx, %edi
	jle	.L23
	movq	(%rsi), %rdx
	addl	%ebx, %eax
	cltq
	leaq	(%rdx,%rax,8), %rax
	movq	%rax, 48(%rsi,%r8)
	vzeroupper
.L1:
	movq	%rsi, %rax
	addq	$32, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4,,10
	.p2align 3
.L8:
	leal	(%rbx,%rbx), %edx
	leaq	16(%rsi), %rax
	movslq	%edx, %rdx
	leaq	24(%rsi,%rcx,8), %r9
	salq	$3, %rdx
	.p2align 4,,10
	.p2align 3
.L6:
	movq	(%rsi), %rcx
	addq	$8, %rax
	addq	%rdx, %rcx
	addq	%r8, %rdx
	movq	%rcx, -8(%rax)
	cmpq	%r9, %rax
	jne	.L6
	movq	%rsi, %rax
	addq	$32, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4,,10
	.p2align 3
.L23:
	movq	%rsi, %rax
	vzeroupper
	addq	$32, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.seh_endproc
	.p2align 4
	.globl	matrix_init
	.def	matrix_init;	.scl	2;	.type	32;	.endef
	.seh_proc	matrix_init
matrix_init:
	pushq	%r12
	.seh_pushreg	%r12
	pushq	%rbp
	.seh_pushreg	%rbp
	pushq	%rdi
	.seh_pushreg	%rdi
	pushq	%rsi
	.seh_pushreg	%rsi
	pushq	%rbx
	.seh_pushreg	%rbx
	subq	$80, %rsp
	.seh_stackalloc	80
	vmovups	%xmm6, 32(%rsp)
	.seh_savexmm	%xmm6, 32
	vmovups	%xmm7, 48(%rsp)
	.seh_savexmm	%xmm7, 48
	vmovups	%xmm8, 64(%rsp)
	.seh_savexmm	%xmm8, 64
	.seh_endprologue
	movq	%rcx, %rbx
	testb	%r9b, %r9b
	jne	.L26
	testl	%edx, %edx
	jle	.L47
	testl	%r8d, %r8d
	jle	.L47
	movl	%r8d, %edi
	movl	$8, %eax
	movl	%r8d, %esi
	movslq	%edx, %r11
	shrl	$3, %edi
	vmovd	%eax, %xmm3
	vxorps	%xmm4, %xmm4, %xmm4
	andl	$-8, %esi
	leal	-1(%r8), %ebp
	salq	$6, %rdi
	vpbroadcastd	%xmm3, %ymm3
	xorl	%r9d, %r9d
	vmovdqu	.LC2(%rip), %ymm6
	vmovdqu	.LC3(%rip), %xmm5
	.p2align 4,,10
	.p2align 3
.L29:
	vcvtsi2sdl	%r9d, %xmm4, %xmm2
	movq	(%rbx,%r9,8), %rcx
	cmpl	$6, %ebp
	jbe	.L48
.L34:
	vbroadcastsd	%xmm2, %ymm8
	leaq	(%rdi,%rcx), %rdx
	vmovdqa	%ymm6, %ymm7
	movq	%rcx, %rax
	.p2align 4,,10
	.p2align 3
.L32:
	vmovdqa	%ymm7, %ymm0
	addq	$64, %rax
	vpaddd	%ymm3, %ymm7, %ymm7
	vcvtdq2pd	%xmm0, %ymm1
	vextracti128	$0x1, %ymm0, %xmm0
	vaddpd	%ymm8, %ymm1, %ymm1
	vcvtdq2pd	%xmm0, %ymm0
	vaddpd	%ymm8, %ymm0, %ymm0
	vmovupd	%ymm1, -64(%rax)
	vmovupd	%ymm0, -32(%rax)
	cmpq	%rax, %rdx
	jne	.L32
	cmpl	%esi, %r8d
	je	.L49
	movl	%esi, %edx
	movl	%esi, %eax
.L33:
	movl	%r8d, %r10d
	subl	%edx, %r10d
	leal	-1(%r10), %r12d
	cmpl	$2, %r12d
	jbe	.L35
	vmovd	%eax, %xmm7
	vmovddup	%xmm2, %xmm1
	leaq	(%rcx,%rdx,8), %rdx
	vpshufd	$0, %xmm7, %xmm0
	vpaddd	%xmm5, %xmm0, %xmm0
	vcvtdq2pd	%xmm0, %xmm7
	vpshufd	$238, %xmm0, %xmm0
	vaddpd	%xmm1, %xmm7, %xmm7
	vcvtdq2pd	%xmm0, %xmm0
	vaddpd	%xmm1, %xmm0, %xmm0
	vmovupd	%xmm7, (%rdx)
	vmovupd	%xmm0, 16(%rdx)
	movl	%r10d, %edx
	andl	$-4, %edx
	addl	%edx, %eax
	andl	$3, %r10d
	je	.L36
.L35:
	vcvtsi2sdl	%eax, %xmm4, %xmm0
	movslq	%eax, %rdx
	leaq	0(,%rdx,8), %r10
	vaddsd	%xmm2, %xmm0, %xmm0
	vmovsd	%xmm0, (%rcx,%rdx,8)
	leal	1(%rax), %edx
	cmpl	%edx, %r8d
	jle	.L36
	vcvtsi2sdl	%edx, %xmm4, %xmm0
	addl	$2, %eax
	vaddsd	%xmm2, %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rcx,%r10)
	cmpl	%r8d, %eax
	jge	.L36
	vcvtsi2sdl	%eax, %xmm4, %xmm0
	vaddsd	%xmm2, %xmm0, %xmm0
	vmovsd	%xmm0, 16(%rcx,%r10)
.L36:
	addq	$1, %r9
	cmpq	%r11, %r9
	jne	.L29
.L46:
	vzeroupper
.L47:
	vmovups	32(%rsp), %xmm6
	vmovups	48(%rsp), %xmm7
	vmovups	64(%rsp), %xmm8
	addq	$80, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L26:
	testl	%edx, %edx
	jle	.L47
	testl	%r8d, %r8d
	jle	.L47
	movslq	%edx, %rdx
	movl	%r8d, %r8d
	leaq	(%rcx,%rdx,8), %rdi
	leaq	0(,%r8,8), %rsi
	.p2align 4,,10
	.p2align 3
.L31:
	movq	(%rbx), %rcx
	movq	%rsi, %r8
	xorl	%edx, %edx
	addq	$8, %rbx
	call	memset
	cmpq	%rbx, %rdi
	jne	.L31
	jmp	.L47
	.p2align 4,,10
	.p2align 3
.L49:
	addq	$1, %r9
	cmpq	%r11, %r9
	je	.L46
	vcvtsi2sdl	%r9d, %xmm4, %xmm2
	movq	(%rbx,%r9,8), %rcx
	jmp	.L34
.L48:
	xorl	%edx, %edx
	xorl	%eax, %eax
	jmp	.L33
	.seh_endproc
	.p2align 4
	.globl	block_avx2
	.def	block_avx2;	.scl	2;	.type	32;	.endef
	.seh_proc	block_avx2
block_avx2:
	pushq	%r15
	.seh_pushreg	%r15
	pushq	%r14
	.seh_pushreg	%r14
	pushq	%r13
	.seh_pushreg	%r13
	pushq	%r12
	.seh_pushreg	%r12
	pushq	%rbp
	.seh_pushreg	%rbp
	pushq	%rdi
	.seh_pushreg	%rdi
	pushq	%rsi
	.seh_pushreg	%rsi
	pushq	%rbx
	.seh_pushreg	%rbx
	subq	$104, %rsp
	.seh_stackalloc	104
	.seh_endprologue
	movl	%r9d, %eax
	movq	%r8, %rdi
	movl	%r9d, %r8d
	movq	%rdx, 184(%rsp)
	sarl	$31, %eax
	movq	%rcx, 176(%rsp)
	movl	%r9d, %r15d
	shrl	$30, %eax
	leal	(%r9,%rax), %edx
	andl	$3, %edx
	subl	%eax, %edx
	subl	%edx, %r8d
	testl	%r8d, %r8d
	jle	.L51
	testl	%r9d, %r9d
	jle	.L90
	movl	%r9d, %eax
	xorl	%r14d, %r14d
	movl	%r15d, %r10d
	sall	$5, %eax
	movl	%eax, 20(%rsp)
	movslq	%eax, %rbx
	movslq	%r9d, %rax
	leaq	0(,%rax,8), %r9
	movq	%rax, %rcx
.L53:
	leal	32(%r14), %eax
	cmpl	%r8d, %eax
	cmovg	%r8d, %eax
	cmpl	%r14d, %eax
	jle	.L59
	subl	%r14d, %eax
	movl	%edx, 44(%rsp)
	xorl	%r12d, %r12d
	movq	%rcx, %rbp
	subl	$1, %eax
	movl	%r8d, 32(%rsp)
	xorl	%r11d, %r11d
	xorl	%r13d, %r13d
	shrl	$2, %eax
	movq	%rdi, %r8
	movq	%r12, %rcx
	leal	0(,%rax,4), %eax
	leaq	4(%r14,%rax), %r15
.L62:
	leal	32(%r13), %edx
	movl	%r10d, %edi
	cmpl	%r10d, %edx
	cmovle	%edx, %edi
	cmpl	%r13d, %edi
	jle	.L57
	movslq	%r11d, %rax
	movl	$0, 40(%rsp)
	addq	%r14, %rax
	movq	%rbx, 48(%rsp)
	leaq	(%r8,%rax,8), %rax
	movl	%r11d, 88(%rsp)
	movq	%rbp, %r11
	movq	%rax, 24(%rsp)
	xorl	%eax, %eax
	movq	%r8, 56(%rsp)
	movl	%edx, %r8d
	movq	%rcx, %rdx
.L60:
	leal	32(%rax), %ecx
	cmpl	%r10d, %ecx
	cmovg	%r10d, %ecx
	cmpl	%eax, %ecx
	jle	.L56
	movslq	40(%rsp), %rbx
	movq	176(%rsp), %rsi
	movl	%r13d, 8(%rsp)
	movq	184(%rsp), %rbp
	movq	%rax, 64(%rsp)
	addq	%r14, %rbx
	movq	%r14, 80(%rsp)
	leaq	(%rsi,%rbx,8), %rbx
	movl	%ecx, %esi
	leaq	(%rax,%rdx), %rcx
	movl	%r10d, 92(%rsp)
	subl	%eax, %esi
	movq	%rdx, 72(%rsp)
	movq	%r11, %rdx
	addq	%rsi, %rcx
	negq	%rsi
	leaq	0(%rbp,%rcx,8), %r12
	movq	24(%rsp), %rbp
	salq	$3, %rsi
	movq	%r14, %rcx
	.p2align 4,,10
	.p2align 3
.L58:
	movl	8(%rsp), %r14d
	movq	%r12, %r11
	movq	%rbp, %r10
	.p2align 4,,10
	.p2align 3
.L55:
	vmovupd	(%r10), %ymm1
	leaq	(%r11,%rsi), %rax
	movq	%rbx, %r13
	.p2align 4,,10
	.p2align 3
.L54:
	vbroadcastsd	(%rax), %ymm0
	vmulpd	0(%r13), %ymm0, %ymm0
	addq	$8, %rax
	addq	%r9, %r13
	vaddpd	%ymm0, %ymm1, %ymm1
	vmovupd	%ymm1, (%r10)
	cmpq	%r11, %rax
	jne	.L54
	addl	$1, %r14d
	addq	%r9, %r10
	leaq	(%rax,%r9), %r11
	cmpl	%edi, %r14d
	jne	.L55
	addq	$4, %rcx
	addq	$32, %rbx
	addq	$32, %rbp
	cmpq	%r15, %rcx
	jne	.L58
	movq	%rdx, %r11
	movl	8(%rsp), %r13d
	movq	64(%rsp), %rax
	movq	80(%rsp), %r14
	movl	92(%rsp), %r10d
	movq	72(%rsp), %rdx
.L56:
	addq	$32, %rax
	movl	20(%rsp), %esi
	addl	%esi, 40(%rsp)
	cmpl	%eax, %r10d
	jg	.L60
	movq	%rdx, %rcx
	movq	%r11, %rbp
	movl	%r8d, %edx
	movq	48(%rsp), %rbx
	movl	88(%rsp), %r11d
	movq	56(%rsp), %r8
.L57:
	movl	20(%rsp), %eax
	movl	%edx, %r13d
	addq	%rbx, %rcx
	addl	%eax, %r11d
	cmpl	%edx, %r10d
	jg	.L62
	movq	%r8, %rdi
	movl	44(%rsp), %edx
	movl	32(%rsp), %r8d
	movq	%rbp, %rcx
.L59:
	addq	$32, %r14
	cmpl	%r14d, %r8d
	jg	.L53
	movl	%r10d, %r15d
	movq	%rcx, %rax
	testb	$3, %r10b
	je	.L89
	subl	$1, %edx
	cmpl	$2, %edx
	ja	.L64
.L63:
	movq	%rdx, %rax
	leaq	CSWTCH.18(%rip), %rdx
	salq	$5, %rax
	vmovdqu	(%rdx,%rax), %ymm2
.L65:
	testl	%r15d, %r15d
	jle	.L89
	movslq	%r15d, %rax
.L64:
	movl	%r15d, %r10d
	movslq	%r8d, %r8
	salq	$3, %rax
	xorl	%ecx, %ecx
	sall	$5, %r10d
	movslq	%r10d, %rdx
	leaq	0(,%rdx,8), %r14
	movq	176(%rsp), %rdx
	leaq	(%rdx,%r8,8), %r9
	xorl	%edx, %edx
	movq	%r9, %r11
.L66:
	movl	%edx, 40(%rsp)
	movl	%edx, %ebx
	addl	$32, %edx
	cmpl	%edx, %r15d
	movl	%edx, %esi
	cmovle	%r15d, %esi
	movl	%esi, 20(%rsp)
	cmpl	%ebx, %esi
	jle	.L69
	movslq	%ecx, %r13
	movq	%r11, 8(%rsp)
	leaq	0(%r13,%r8), %r9
	movl	%edx, 44(%rsp)
	leaq	(%rdi,%r9,8), %rsi
	xorl	%r9d, %r9d
	movq	%rsi, 24(%rsp)
.L72:
	leal	32(%r9), %ebx
	cmpl	%r15d, %ebx
	cmovg	%r15d, %ebx
	cmpl	%r9d, %ebx
	jle	.L71
	movq	184(%rsp), %rdx
	subl	%r9d, %ebx
	movq	24(%rsp), %rbp
	leaq	(%rbx,%r13), %rsi
	negq	%rbx
	leaq	(%rdx,%rsi,8), %r12
	leaq	0(,%rbx,8), %rdx
	movq	%rdx, 32(%rsp)
	movl	40(%rsp), %edx
.L68:
	movq	32(%rsp), %rsi
	vmaskmovpd	0(%rbp), %ymm2, %ymm1
	leaq	(%rsi,%r12), %rbx
	movq	8(%rsp), %rsi
.L67:
	vbroadcastsd	(%rbx), %ymm3
	vmaskmovpd	(%rsi), %ymm2, %ymm0
	addq	$8, %rbx
	addq	%rax, %rsi
	vmulpd	%ymm3, %ymm0, %ymm0
	vaddpd	%ymm0, %ymm1, %ymm1
	vmaskmovpd	%ymm1, %ymm2, 0(%rbp)
	cmpq	%rbx, %r12
	jne	.L67
	movl	20(%rsp), %esi
	addl	$1, %edx
	addq	%rax, %rbp
	addq	%rax, %r12
	cmpl	%esi, %edx
	jne	.L68
.L71:
	addq	$32, %r9
	addq	%r14, 8(%rsp)
	addq	$32, %r13
	cmpl	%r9d, %r15d
	jg	.L72
	movl	44(%rsp), %edx
.L69:
	addl	%r10d, %ecx
	cmpl	%edx, %r15d
	jg	.L66
.L89:
	vzeroupper
.L90:
	addq	$104, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L51:
	testb	$3, %r9b
	je	.L90
	subl	$1, %edx
	cmpl	$2, %edx
	ja	.L65
	jmp	.L63
	.seh_endproc
	.p2align 4
	.globl	block_avx2_unrolled
	.def	block_avx2_unrolled;	.scl	2;	.type	32;	.endef
	.seh_proc	block_avx2_unrolled
block_avx2_unrolled:
	pushq	%rbp
	.seh_pushreg	%rbp
	pushq	%r15
	.seh_pushreg	%r15
	pushq	%r14
	.seh_pushreg	%r14
	pushq	%r13
	.seh_pushreg	%r13
	pushq	%r12
	.seh_pushreg	%r12
	pushq	%rdi
	.seh_pushreg	%rdi
	pushq	%rsi
	.seh_pushreg	%rsi
	pushq	%rbx
	.seh_pushreg	%rbx
	subq	$216, %rsp
	.seh_stackalloc	216
	leaq	208(%rsp), %rbp
	.seh_setframe	%rbp, 208
	.seh_endprologue
	leaq	-1(%rbp), %rax
	movq	%rdx, 88(%rbp)
	movl	%r9d, %r15d
	andq	$-32, %rax
	movq	%rcx, 80(%rbp)
	movl	%r9d, %ecx
	movq	%rax, -128(%rbp)
	movl	%r9d, %eax
	andl	$15, %ecx
	sarl	$31, %eax
	movq	%r8, 96(%rbp)
	shrl	$28, %eax
	leal	(%r9,%rax), %edx
	andl	$15, %edx
	subl	%eax, %edx
	movl	%r9d, %eax
	movl	%edx, -48(%rbp)
	subl	%edx, %eax
	testl	%r9d, %r9d
	jle	.L92
	movl	%r9d, %edx
	movslq	%r9d, %rbx
	movq	$0, -40(%rbp)
	sall	$5, %edx
	leaq	0(,%rbx,8), %r12
	movslq	%edx, %r10
	movl	%edx, -56(%rbp)
	movq	%r12, %r14
	movl	%eax, %edx
	leaq	0(,%r10,8), %rdi
	movq	%r8, %rax
.L93:
	movq	-40(%rbp), %rsi
	leal	32(%rsi), %r8d
	cmpl	%edx, %r8d
	cmovg	%edx, %r8d
	cmpl	%esi, %r8d
	jle	.L102
	subl	%esi, %r8d
	movl	%edx, -104(%rbp)
	xorl	%r13d, %r13d
	xorl	%r12d, %r12d
	subl	$1, %r8d
	movl	%ecx, -112(%rbp)
	shrl	$4, %r8d
	movq	%rax, -96(%rbp)
	salq	$4, %r8
	movq	%rax, -120(%rbp)
	movl	%r15d, %eax
	movl	%r12d, %r15d
	leaq	16(%rsi,%r8), %rsi
	movq	%r13, %r8
	movq	%rsi, -80(%rbp)
.L105:
	leal	32(%r15), %r11d
	movl	%eax, %esi
	movl	$0, -88(%rbp)
	cmpl	%eax, %r11d
	cmovle	%r11d, %esi
	xorl	%ecx, %ecx
	cmpl	%esi, %r15d
	jge	.L100
	movl	%r15d, -100(%rbp)
	movq	%r8, %rdx
	movq	%rbx, %r9
	movq	%rdi, -144(%rbp)
	movq	%r10, -136(%rbp)
	movl	%r11d, %r10d
.L103:
	leal	32(%rcx), %edi
	movq	-40(%rbp), %r11
	movslq	-88(%rbp), %r8
	movl	%ecx, %r13d
	cmpl	%eax, %edi
	movq	80(%rbp), %rbx
	movq	88(%rbp), %r15
	movl	%eax, -164(%rbp)
	cmovg	%eax, %edi
	addq	%r11, %r8
	movq	%rcx, -152(%rbp)
	leaq	(%rbx,%r8,8), %r12
	leaq	(%rcx,%rdx), %r8
	movq	%rdx, -160(%rbp)
	movl	%r10d, %edx
	movl	%edi, %ebx
	subl	%ecx, %ebx
	addq	%rbx, %r8
	negq	%rbx
	leaq	(%r15,%r8,8), %r8
	movq	-96(%rbp), %r15
	salq	$3, %rbx
	movq	%r8, -72(%rbp)
	movq	%r11, %r8
.L101:
	movq	-72(%rbp), %rcx
	movl	-100(%rbp), %r11d
	movq	%r15, -64(%rbp)
	movq	%r15, %r10
	.p2align 4,,10
	.p2align 3
.L99:
	vmovupd	(%r10), %ymm4
	vmovupd	32(%r10), %ymm2
	leaq	(%rcx,%rbx), %r15
	movq	%r12, %rax
	vmovupd	64(%r10), %ymm1
	vmovupd	96(%r10), %ymm3
	cmpl	%r13d, %edi
	jle	.L97
	.p2align 4,,10
	.p2align 3
.L94:
	vbroadcastsd	(%r15), %ymm0
	vmulpd	(%rax), %ymm0, %ymm5
	addq	$8, %r15
	vaddpd	%ymm5, %ymm4, %ymm4
	vmulpd	32(%rax), %ymm0, %ymm5
	vaddpd	%ymm5, %ymm2, %ymm2
	vmulpd	64(%rax), %ymm0, %ymm5
	vmulpd	96(%rax), %ymm0, %ymm0
	addq	%r14, %rax
	vaddpd	%ymm5, %ymm1, %ymm1
	vaddpd	%ymm0, %ymm3, %ymm3
	cmpq	%rcx, %r15
	jne	.L94
.L97:
	addl	$1, %r11d
	vmovupd	%ymm4, (%r10)
	addq	%r14, %rcx
	vmovupd	%ymm2, 32(%r10)
	vmovupd	%ymm1, 64(%r10)
	vmovupd	%ymm3, 96(%r10)
	addq	%r14, %r10
	cmpl	%esi, %r11d
	jne	.L99
	movq	-64(%rbp), %r15
	movq	-80(%rbp), %rax
	addq	$16, %r8
	subq	$-128, %r12
	subq	$-128, %r15
	cmpq	%rax, %r8
	jne	.L101
	movq	-152(%rbp), %rcx
	movl	-164(%rbp), %eax
	movl	%edx, %r10d
	movl	-56(%rbp), %ebx
	movq	-160(%rbp), %rdx
	addq	$32, %rcx
	addl	%ebx, -88(%rbp)
	cmpl	%ecx, %eax
	jg	.L103
	movl	%r10d, %r11d
	movq	-144(%rbp), %rdi
	movq	%rdx, %r8
	movq	%r9, %rbx
	movq	-136(%rbp), %r10
.L100:
	addq	%rdi, -96(%rbp)
	movl	%r11d, %r15d
	addq	%r10, %r8
	cmpl	%r11d, %eax
	jg	.L105
	movl	%eax, %r15d
	movl	-104(%rbp), %edx
	movl	-112(%rbp), %ecx
	movq	-120(%rbp), %rax
.L102:
	addq	$32, -40(%rbp)
	movq	-40(%rbp), %rsi
	addq	$256, %rax
	cmpl	%esi, %r15d
	jg	.L93
	movslq	%edx, %rax
	testl	%ecx, %ecx
	je	.L174
	leal	-1(%r15), %esi
	movl	-48(%rbp), %r8d
	movq	%rax, -40(%rbp)
	movl	%esi, %edx
	movq	%rbx, -144(%rbp)
	andl	$-32, %edx
	sarl	$2, %r8d
	leal	32(%rdx), %r12d
	movl	%esi, %edx
	movslq	%r8d, %rcx
	shrl	$5, %edx
	salq	$5, %rcx
	movl	%r12d, %r13d
	addl	$1, %edx
	salq	$5, %rdx
	movq	%rdx, -112(%rbp)
	leal	-1(%r8), %edx
	addq	$1, %rdx
	salq	$5, %rdx
	testl	%r8d, %r8d
	movl	$32, %r8d
	cmovg	%rdx, %r8
	addq	$16, %rcx
	xorl	%edx, %edx
	xorl	%edi, %edi
	movq	%rcx, -136(%rbp)
	movl	%edx, %r12d
	movq	%r8, -96(%rbp)
.L108:
	movl	%edi, %edx
	addl	$32, %edi
	movl	%r15d, %eax
	movl	$0, -80(%rbp)
	cmpl	%r15d, %edi
	cmovle	%edi, %eax
	movl	%eax, %ebx
	movl	%eax, -64(%rbp)
	xorl	%eax, %eax
	cmpl	%edx, %ebx
	jle	.L121
	movl	%edi, -152(%rbp)
	movl	%r12d, %r10d
	movq	%rax, %rbx
	movl	%edx, %r14d
	movl	%r13d, -160(%rbp)
	movl	%esi, -164(%rbp)
.L123:
	leal	32(%rbx), %eax
	movl	%ebx, -120(%rbp)
	movl	%r14d, %r13d
	movl	%r10d, %edi
	cmpl	%r15d, %eax
	movl	%ebx, -72(%rbp)
	movq	%rbx, %rsi
	cmovg	%r15d, %eax
	movl	%r10d, -100(%rbp)
	movl	%r14d, -104(%rbp)
	movl	%r15d, %r14d
	movl	-48(%rbp), %r15d
	movl	%eax, %r12d
.L113:
	movq	-136(%rbp), %rax
	movq	%rsp, -88(%rbp)
	call	___chkstk_ms
	subq	%rax, %rsp
	leaq	63(%rsp), %rcx
	andq	$-32, %rcx
	cmpl	$3, %r15d
	jle	.L109
	movq	-40(%rbp), %rax
	movq	96(%rbp), %rdx
	movslq	%edi, %rbx
	movq	-96(%rbp), %r8
	addq	%rbx, %rax
	leaq	(%rdx,%rax,8), %rdx
	vzeroupper
	call	memcpy
	movq	%rax, %rcx
	cmpl	%r12d, -72(%rbp)
	jge	.L111
.L110:
	movq	88(%rbp), %rdx
	leaq	(%rsi,%rbx), %rax
	movl	-80(%rbp), %r10d
	movl	-120(%rbp), %r9d
	movq	80(%rbp), %r8
	leaq	(%rdx,%rax,8), %rdx
.L116:
	vbroadcastsd	(%rdx), %ymm0
	cmpl	$3, %r15d
	jle	.L119
	movq	-40(%rbp), %r11
	movslq	%r10d, %rax
	addq	%r11, %rax
	vmulpd	(%r8,%rax,8), %ymm0, %ymm1
	leaq	0(,%rax,8), %r11
	vaddpd	(%rcx), %ymm1, %ymm1
	vmovupd	%ymm1, (%rcx)
	cmpl	$7, %r15d
	jle	.L119
	vmulpd	32(%r8,%r11), %ymm0, %ymm1
	vaddpd	32(%rcx), %ymm1, %ymm1
	vmovupd	%ymm1, 32(%rcx)
	cmpl	$11, %r15d
	jle	.L119
	vmulpd	64(%r8,%r11), %ymm0, %ymm0
	vaddpd	64(%rcx), %ymm0, %ymm0
	vmovupd	%ymm0, 64(%rcx)
.L119:
	addl	$1, %r9d
	addq	$8, %rdx
	addl	%r14d, %r10d
	cmpl	%r9d, %r12d
	jg	.L116
	cmpl	$3, %r15d
	jle	.L176
	vzeroupper
.L111:
	movq	-40(%rbp), %rax
	movq	-96(%rbp), %r8
	movq	%rcx, %rdx
	addq	%rax, %rbx
	movq	96(%rbp), %rax
	leaq	(%rax,%rbx,8), %rax
	movq	%rax, %rcx
	call	memcpy
.L120:
	addl	$1, %r13d
	addl	%r14d, %edi
	movq	-88(%rbp), %rsp
	cmpl	%r13d, -64(%rbp)
	jne	.L113
.L165:
	movq	%rsi, %rbx
	movl	-56(%rbp), %edi
	movl	%r14d, %r15d
	addl	%edi, -80(%rbp)
	movl	-100(%rbp), %r10d
	movl	-104(%rbp), %r14d
	addq	$32, %rbx
	cmpq	%rbx, -112(%rbp)
	jne	.L123
	movl	-152(%rbp), %edi
	movl	-160(%rbp), %r13d
	movl	%r10d, %r12d
	movl	-164(%rbp), %esi
.L121:
	movl	-56(%rbp), %eax
	addl	%eax, %r12d
	cmpl	%r13d, %edi
	jne	.L108
	movl	-48(%rbp), %eax
	movq	-144(%rbp), %rbx
	andl	$3, %eax
	cmpl	$2, %eax
	je	.L124
	cmpl	$3, %eax
	je	.L125
	testl	%eax, %eax
	je	.L174
	movl	%esi, %eax
	jne	.L160
.L174:
	vzeroupper
.L175:
	leaq	8(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	ret
.L176:
	addl	$1, %r13d
	addl	%r14d, %edi
	movq	-88(%rbp), %rsp
	cmpl	%r13d, -64(%rbp)
	je	.L165
	movq	-128(%rbp), %rcx
.L109:
	movslq	%edi, %rbx
	cmpl	%r12d, -72(%rbp)
	jl	.L110
	jmp	.L120
.L92:
	testl	%ecx, %ecx
	je	.L175
.L126:
	testb	$3, -48(%rbp)
	je	.L175
.L160:
	testl	%r15d, %r15d
	jle	.L174
	vmovdqu	.LC4(%rip), %ymm0
	movslq	%r15d, %rbx
	jmp	.L128
.L125:
	vmovdqu	.LC5(%rip), %ymm0
	leal	-3(%r15), %eax
.L128:
	movl	%r15d, %edi
	movslq	%eax, %r10
	movq	80(%rbp), %rax
	xorl	%r8d, %r8d
	sall	$5, %edi
	leaq	0(,%rbx,8), %r14
	movslq	%edi, %rdx
	leaq	(%rax,%r10,8), %rax
	leaq	0(,%rdx,8), %rsi
	xorl	%edx, %edx
	movq	%rsi, -56(%rbp)
.L129:
	movl	%edx, %r13d
	addl	$32, %edx
	cmpl	%edx, %r15d
	movl	%edx, %esi
	cmovle	%r15d, %esi
	movl	%esi, -64(%rbp)
	cmpl	%esi, %r13d
	jge	.L132
	movq	96(%rbp), %rbx
	movslq	%r8d, %rsi
	movq	%rax, -40(%rbp)
	xorl	%r9d, %r9d
	leaq	(%rsi,%r10), %rcx
	leaq	(%rbx,%rcx,8), %rbx
	movq	%rbx, -48(%rbp)
	movq	%rax, %rbx
.L135:
	leal	32(%r9), %ecx
	cmpl	%r15d, %ecx
	cmovg	%r15d, %ecx
	cmpl	%r9d, %ecx
	jle	.L134
	movq	88(%rbp), %rax
	subl	%r9d, %ecx
	movl	%edx, -80(%rbp)
	leaq	(%rsi,%rcx), %r11
	negq	%rcx
	leaq	(%rax,%r11,8), %r11
	leaq	0(,%rcx,8), %rax
	movq	-48(%rbp), %rcx
	movq	%rax, -72(%rbp)
	movl	%r13d, %eax
.L131:
	movq	-72(%rbp), %rdx
	vmaskmovpd	(%rcx), %ymm0, %ymm1
	leaq	(%r11,%rdx), %r12
	movq	-40(%rbp), %rdx
.L130:
	vbroadcastsd	(%r12), %ymm3
	vmaskmovpd	(%rdx), %ymm0, %ymm2
	addq	$8, %r12
	addq	%r14, %rdx
	vmulpd	%ymm3, %ymm2, %ymm2
	vaddpd	%ymm2, %ymm1, %ymm1
	vmaskmovpd	%ymm1, %ymm0, (%rcx)
	cmpq	%r11, %r12
	jne	.L130
	movl	-64(%rbp), %edx
	addl	$1, %eax
	addq	%r14, %rcx
	addq	%r14, %r11
	cmpl	%edx, %eax
	jne	.L131
	movl	-80(%rbp), %edx
.L134:
	addq	$32, %r9
	movq	-56(%rbp), %rcx
	addq	$32, %rsi
	addq	%rcx, -40(%rbp)
	cmpl	%r9d, %r15d
	jg	.L135
	movq	%rbx, %rax
.L132:
	addl	%edi, %r8d
	cmpl	%edx, %r15d
	jg	.L129
	jmp	.L174
.L124:
	vmovdqu	.LC6(%rip), %ymm0
	leal	-2(%r15), %eax
	jmp	.L128
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.section .rdata,"dr"
.LC8:
	.ascii "test\0"
	.align 8
.LC9:
	.ascii "Starting matrix mult test with matrix size %d\12\0"
.LC10:
	.ascii "w+\0"
.LC11:
	.ascii "blocked_mult.csv\0"
	.align 8
.LC12:
	.ascii "matrix_size, gflops_mmult, tmmult, trace_mmult\0"
	.align 8
.LC13:
	.ascii "matrix_size, gflops_mmult, tmmult, trace_mmult\12\0"
.LC15:
	.ascii "%d, %f, %f, %12.12g\12\0"
	.section	.text.startup,"x"
	.p2align 4
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	pushq	%r15
	.seh_pushreg	%r15
	pushq	%r14
	.seh_pushreg	%r14
	pushq	%r13
	.seh_pushreg	%r13
	pushq	%r12
	.seh_pushreg	%r12
	pushq	%rbp
	.seh_pushreg	%rbp
	pushq	%rdi
	.seh_pushreg	%rdi
	pushq	%rsi
	.seh_pushreg	%rsi
	pushq	%rbx
	.seh_pushreg	%rbx
	subq	$120, %rsp
	.seh_stackalloc	120
	vmovups	%xmm6, 80(%rsp)
	.seh_savexmm	%xmm6, 80
	vmovups	%xmm7, 96(%rsp)
	.seh_savexmm	%xmm7, 96
	.seh_endprologue
	call	__main
	leaq	.LC8(%rip), %rcx
	leaq	64(%rsp), %r13
	call	printf
	movl	$40, %edx
	movl	$40, %ecx
	call	create_matrix
	movl	$40, %edx
	movl	$40, %ecx
	movq	%rax, %rdi
	call	create_matrix
	movl	$40, %edx
	movl	$40, %ecx
	movq	%rax, %rsi
	call	create_matrix
	xorl	%r9d, %r9d
	movl	$40, %edx
	movq	%rdi, %rcx
	movl	$40, %r8d
	movq	%rax, %rbx
	call	matrix_init
	xorl	%r9d, %r9d
	movl	$40, %edx
	movq	%rsi, %rcx
	movl	$40, %r8d
	call	matrix_init
	movl	$1, %r9d
	movl	$40, %edx
	movq	%rbx, %rcx
	movl	$40, %r8d
	call	matrix_init
	movq	(%rbx), %r8
	movl	$40, %edx
	movq	(%rdi), %r14
	leaq	.LC9(%rip), %rcx
	movq	(%rsi), %r15
	movq	%r8, 56(%rsp)
	call	printf
	movq	__imp__timespec64_get(%rip), %r12
	movl	$1, %edx
	movq	%r13, %rcx
	call	*%r12
	movslq	72(%rsp), %rax
	movq	56(%rsp), %r8
	movq	%r15, %rdx
	imulq	$1000000000, 64(%rsp), %rbp
	movl	$40, %r9d
	movq	%r14, %rcx
	addq	%rax, %rbp
	call	block_avx2_unrolled
	movl	$1, %edx
	movq	%r13, %rcx
	call	*%r12
	movslq	72(%rsp), %rdx
	vxorps	%xmm7, %xmm7, %xmm7
	vxorpd	%xmm6, %xmm6, %xmm6
	imulq	$1000000000, 64(%rsp), %rax
	addq	%rdx, %rax
	subq	%rbp, %rax
	vcvtsi2sdq	%rax, %xmm7, %xmm7
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L178:
	movq	(%rbx,%rax), %rdx
	vaddsd	(%rdx,%rax), %xmm6, %xmm6
	addq	$8, %rax
	cmpq	$320, %rax
	jne	.L178
	leaq	.LC10(%rip), %rdx
	leaq	.LC11(%rip), %rcx
	call	fopen
	leaq	.LC12(%rip), %rcx
	leaq	.LC15(%rip), %r12
	movq	%rax, %rbp
	call	puts
	movq	%rbp, %r9
	movl	$47, %r8d
	movl	$1, %edx
	leaq	.LC13(%rip), %rcx
	call	fwrite
	vmovsd	.LC14(%rip), %xmm2
	movq	%r12, %rcx
	movl	$40, %edx
	vmovsd	%xmm6, 32(%rsp)
	vmovsd	%xmm7, %xmm7, %xmm3
	vmovq	%xmm7, %r9
	vdivsd	%xmm7, %xmm2, %xmm2
	vmovq	%xmm2, %r8
	vmovsd	%xmm2, 56(%rsp)
	call	printf
	vmovsd	56(%rsp), %xmm2
	movq	%r12, %rdx
	movq	%rbp, %rcx
	vmovsd	%xmm6, 40(%rsp)
	movl	$40, %r8d
	vmovsd	%xmm7, 32(%rsp)
	vmovsd	%xmm2, %xmm2, %xmm3
	vmovq	%xmm2, %r9
	call	fprintf
	movq	%rbp, %rcx
	call	fclose
	movq	(%rdi), %rcx
	call	free
	movq	(%rsi), %rcx
	call	free
	movq	(%rbx), %rcx
	call	free
	movq	%rdi, %rcx
	call	free
	movq	%rsi, %rcx
	call	free
	movq	%rbx, %rcx
	call	free
	nop
	vmovups	80(%rsp), %xmm6
	vmovups	96(%rsp), %xmm7
	xorl	%eax, %eax
	addq	$120, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.seh_endproc
	.section .rdata,"dr"
	.align 32
CSWTCH.18:
	.quad	-4294967295
	.quad	4294967297
	.quad	4294967297
	.quad	4294967297
	.quad	-4294967295
	.quad	-4294967295
	.quad	4294967297
	.quad	4294967297
	.quad	-4294967295
	.quad	-4294967295
	.quad	-4294967295
	.quad	4294967297
	.align 32
.LC0:
	.long	2
	.long	3
	.long	4
	.long	5
	.long	6
	.long	7
	.long	8
	.long	9
	.align 32
.LC2:
	.long	0
	.long	1
	.long	2
	.long	3
	.long	4
	.long	5
	.long	6
	.long	7
	.set	.LC3,.LC2
	.align 32
.LC4:
	.quad	-4294967295
	.quad	4294967297
	.quad	4294967297
	.quad	4294967297
	.align 32
.LC5:
	.quad	-4294967295
	.quad	-4294967295
	.quad	-4294967295
	.quad	4294967297
	.align 32
.LC6:
	.quad	-4294967295
	.quad	-4294967295
	.quad	4294967297
	.quad	4294967297
	.align 8
.LC14:
	.long	0
	.long	1090469888
	.ident	"GCC: (Rev3, Built by MSYS2 project) 13.2.0"
	.def	malloc;	.scl	2;	.type	32;	.endef
	.def	memset;	.scl	2;	.type	32;	.endef
	.def	memcpy;	.scl	2;	.type	32;	.endef
	.def	printf;	.scl	2;	.type	32;	.endef
	.def	fopen;	.scl	2;	.type	32;	.endef
	.def	puts;	.scl	2;	.type	32;	.endef
	.def	fwrite;	.scl	2;	.type	32;	.endef
	.def	fprintf;	.scl	2;	.type	32;	.endef
	.def	fclose;	.scl	2;	.type	32;	.endef
	.def	free;	.scl	2;	.type	32;	.endef
