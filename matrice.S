
.data
	v: .space 1048576
	d: .space 1024
	l: .space 1024
	O: .space 4
	op: .space 4
	N: .space 4
	id: .space 4
	dim: .space 4
	di: .space 4
	li: .space 4
	auxiliar: .space 4
	auxiliar2: .space 4
	capat: .space 4
	nrlinii: .long 1024
	dim_blocuri: .space 4
	nrde0 : .space 4
	contor: .space 4
	inceput0: .space 4
	sfarsit0: .space 4
	inceputc: .space 4
	sfarsitc: .space 4
	inceputl: .space 4
	sfarsitl: .space 4
	impartitor: .long 8
	add_aux: .space 4
	auxx: .space 4
	defrag_aux: .space 4
	ind: .space 4
	zero: .long 0
	k: .space 4
	aux: .space 4
	ok: .space 4
	auxd: .space 4
	auxl: .space 4
	ok_def: .space 1
	formatscanf: .asciz "%d"
	linie: .asciz "\n"
	test: .asciz "%d "
	format_de_test: .asciz " -> %d <-\n"
	formatprintfget: .asciz "((%d, %d), (%d, %d))\n"
	formatprintf: .asciz "%d: ((%d, %d), (%d, %d))\n"

.text
.global main

main:



citire_nr_operatii:
	# citesc nr de operatii care vor fi efectuate
	push $O
	push $formatscanf
	call scanf
	add $8, %esp
	
citire_operati:
	xor %ecx, %ecx 		# ecx va fi indicele cu care voi parcurge operatiile
	xor %eax, %eax
	
citire_operatii_loop:
	
	cmp %ecx, O		# daca ecx e egal cu O, atunci ies din for
	je citire_operatii_loop_stop
	
	pushl %eax
	pushl %ecx
	push $op
	push $formatscanf
	call scanf
	add $8, %esp
	popl %ecx
	popl %eax
	
	# am citit op, acum verific daca e 1 2 3 sau 4
	# eax=1
	
	mov op, %eax		# verific daca op=1, daca nu, continui sa compar cu 
	cmpl $1, %eax		# 2 3 si 4
	jne verific_get
	
procedura_add:
	# ecx- contor pentru citire op, eax- valoarea lui op
	
	pushl %eax
	pushl %ecx
	push $N
	push $formatscanf
	call scanf
	add $8, %esp
	popl %ecx
	popl %eax
	
	# voi parcurge cu edx numerele de la 0 la N-1 si citesc pt fiecare edx
	# citesc un id pentru fisier si o dimensiune pentru nr de blocuri ocupate
	
	xor %edx, %edx		# fac contorul 0
	
citire_id_loop:
	
	cmp %edx, N
	je citire_id_loop_stop
	
	pushl %eax
	pushl %ecx
	pushl %edx
	push $id
	push $formatscanf		# am citit id-ul fisierului
	call scanf
	add $8, %esp
	popl %edx
	popl %ecx
	popl %eax
	
	pushl %eax
	pushl %ecx
	pushl %edx
	push $dim
	push $formatscanf		# am citit dim fisierului
	call scanf
	add $8, %esp
	popl %edx
	popl %ecx
	popl %eax
	
	# ecx- contor pt op, %eax, val lui op, edx- contor pentru fisiere
	mov dim, %ebx	# ebx ia valoarea lui dim
	add $7, %ebx	# ebx e dim plus 7, trebuie impartit la 8 pentru a ramane
			# cu nr de blocuri ocupate de un id
	
	pushl %eax	# am pus eax si edx in stiva pentru a le recupera valorile
	pushl %edx	# dupa impartirea la 8
	
	xor %edx, %edx 		#eax, edx =0 pt a nu avea 'resturi' de anterior
	mov %ebx, %eax		# il pun pe ebx in eax pt a se efectua impartirea
	
	divl impartitor		#impart ebx=dim+7 la 8, eax=cat, edx=rest
	
	mov %eax, %ebx	# ebx ia valoarea dim in blocuri
	popl %edx
	popl %eax
	
	# ebx reprezinta acum dim in blocuri a lui id, eax are val lui op, ecx e contor pentru operatiile citite,
	# edx contor pentru fisiere
	mov $v, %edi
	# adresa lui v e in %edi
	
	# pun ecx, edx, eax pe stiva deoarece in add le voi altera valorile 
	
	pushl %ecx
	pushl %eax
	pushl %edx
	
efectuare_add:

	movl $-1, %eax		
	movl %eax, inceput0
	movl %eax, sfarsit0		#inceput0 si sfarsit0 sunt initializate cu -1
	movl $0, nrde0 			#nrde0=0
	movl %ebx, dim_blocuri		#dim_blocuri are val in blocuri a fisierului citit
	
	# voi parcurge matricea cu 2 for-uri
	# edx va fi contor pentru for ul de linie
	# ecx va fi contor pentru for ul de coloana
	# ebx- liber /// bl- el curent din matrice
	# eax=-1 pt a compara cu inceput0
	
	
	xor %edx, %edx 		# init edx cu 0 pentru parcurgere linii
	xor %ecx, %ecx		# init ecx cu 0 pentru parcurgere coloane
	xor %ebx, %ebx
	
add_linie_loop:

	cmp $1024, %edx		# daca edx e 8, opresc for ul pentru linie
	je add_linie_loop_stop
	
	movl $-1, %eax		# eax este pe post de inceput0
	movl %eax, sfarsit0
	movl %edx, aux		# aux are acum indicele de linie al id-ului citit
	
add_coloana_loop:
	
	cmp $1024, %ecx		# daca ecx e 8, opresc for ul pt col si verif daca nrde0 este egal cu dim_blocuri
	je add_coloana_loop_stop
	
	# in eax voi calcula indicele din matrice, dar inainte ii dau push pentru a ma reintoarce la val prec
	
	pushl %eax
	pushl %edx

	movl %edx, %eax		# am pus in eax val indicelui de linie
	xor %edx, %edx		# salvez edx pt ca il voi face 0 pt inmultire	xor %edx, %edx
	mull nrlinii 		# inmultesc eax cu nr de linii/coloane ale matricei
	addl %ecx, %eax 	# adaug la eax indicele nr de coloane

	# acum in eax am indicele matricei	
	movb (%edi, %eax, 1), %bl	# pun in bl elementul curent din matrice
	
	popl %edx	# edx e iar contor pentru linii
	popl %eax	# eax e iar -1
	
add_if1:
	cmpb $0, %bl 
	jne add_if2
	
	cmpl $-1, %eax
	jne crestere_sfarsit0
	
	mov %ecx, %eax
	movl %ecx, sfarsit0
	# calc in eax val lui ecx -1, apoi restaurez in eax val -1
	jmp add_if3
	
crestere_sfarsit0:
	addl $1, sfarsit0
	jmp add_if3

add_if2:
	movl $-1, %eax
	mov %eax, sfarsit0
	
add_if3:
	block:
	# calculez nrde0 ca fiind sfarsit0-inceput0+1, ma voi folosi de eax
	# nu mai am nevoie de eax=-1, deci in eax voi calcula nr de 0 -uri
	
	movl sfarsit0, %ebx
	sub %eax, %ebx
	inc %ebx
	# in ebx am nr de 0-uri
	jmp skip	
	
	
skip:
	cmp %ebx, dim_blocuri
	jne continuare_coloana
	movl %eax, inceput0
	
	mov $1023, %ecx
	
continuare_coloana:
	inc %ecx
	jmp add_coloana_loop
	
add_coloana_loop_stop:				
	
	cmp %ebx, dim_blocuri
	jne continuare_linie
	
	mov $1023, %edx
	
continuare_linie:

	/*pushl %eax
	mov id, %eax
	mov %eax, add_aux
	popl %eax
	#am pus in add_aux id ul curent, care nu incape in matrice
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx
	push zero
	push zero
	push zero
	push zero
	push add_aux
	push $formatprintf
	call printf
	add $24, %esp
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax*/
	
	xor %ecx, %ecx
	inc %edx
	jmp add_linie_loop
	
add_linie_loop_stop:
	
	# am terminat de parcurs cele 2 for-uri pentru linie si coloana, ecx si edx sunt liberi
	# bl- elementul curent din matrice
	# inceput0,sfarsit0- unde incepe si unde se termina id ul pe coloana
	# aux- linia pe care se afla id-ul citit
	
	cmpl %ebx, dim_blocuri
	jg nu_pot_adauga
	
	xor %ecx, %ecx		# folosesc ecx ca indice pentru atribuire
	movl inceput0, %ecx
	addl $1, sfarsit0 

atribuire_loop:
	
	cmpl %ecx, sfarsit0
	je atribuire_loop_stop
	
	# pun il matrice id-ul fisierului citit
	# ecx- indice pt parcurgere, eax - nrde0 (nu mai am nevoie), bl- el din matrice, ebx- liber
	# in eax calculez indicele elementului bl din matrice
	
	movl aux, %eax
	xor %edx, %edx
	mull nrlinii
	addl %ecx, %eax
calcul_indice:
	#eax=indicele el din matrice
	# pun id-ul fisierului in matrice
	movb id, %bl
	movb %bl, (%edi, %eax, 1)
	
	inc %ecx
	jmp atribuire_loop

atribuire_loop_stop:

	subl $1, sfarsit0
	
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx
	
	push sfarsit0
	push aux
	push inceput0
	push aux
	push id
	push $formatprintf
	call printf
	add $24, %esp
	
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax
	
	jmp cont	# sar la cont pentru ca am gasit un id care incape in matrice
			# si nu vreau sa afisez si id: ((0,0),(0,0))
	
nu_pot_adauga:	
	
	pushl %eax
	mov id, %eax
	mov %eax, add_aux
	popl %eax
	#am pus in add_aux id ul curent, care nu incape in matrice
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx
	push zero
	push zero
	push zero
	push zero
	push add_aux
	push $formatprintf
	call printf
	add $24, %esp
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax

# acest edx este dinainte de add

cont:
	popl %edx
	popl %eax
	popl %ecx

	inc %edx
	jmp citire_id_loop
	
citire_id_loop_stop:

	# am terminat add-ul
	# am terminat de pus in matrice id-urile de la ultimul add citit, iar afisarea este facuta tot in add
	# ecx- contorul pentru operatii, ebx-liber, eax-liber, edx- liber
	
	xor %ebx, %ebx
	xor %eax, %eax
	xor %edx, %edx
verific_get:
	# vreau sa verific daca operatia citita este get
	
	mov op, %eax
	cmpl $2, %eax
	jne verific_delete
	
	pushl %ecx	# pun valoarea lui ecx pe stiva pt a nu o pierde
	
	# initializez variabilele locale
	# ebx e 0 in acest moment
	
	# citesc id-ul pentru get
	
	pushl %eax
	pushl %ecx
	pushl %edx
	push $id
	push $formatscanf
	call scanf
	add $8, %esp
	popl %edx
	popl %ecx
	popl %eax
	
	movl %ebx, ok
	movl %ebx, aux
	movl %ebx, inceputl
	movl %ebx, sfarsitl
	movl %ebx, inceputc
	inc %ebx
	movl %ebx, sfarsitc
	xor %ebx, %ebx
	
	mov $0, %esi # pentru a compara ok cu 0
	
	# iau pe edx contor pt linii si ecx contor pentru coloane
	
	xor %ecx, %ecx
	xor %edx, %edx
	
get_linii_loop:

	cmpl $1024, %edx
	je get_linii_loop_stop
	
get_coloane_loop:

	cmpl $1024, %ecx
	je get_coloane_loop_stop
	
	# ebx -liber, eax-liber, ecx- contor pt coloane, edx- contor pt el matricei
	# calculez in eax indicele elementului din matrice
	
	xor %eax, %eax
	mov %edx, %eax	# pun indicele de linie in eax
	pushl %edx
	xor %edx, %edx
	mull nrlinii	# am inmultit eax cu 8
	xor %edx, %edx
	popl %edx
	add %ecx, %eax	# am adaugat la eax indicele de coloana
	
	#eax- indicele el din vector, edx- indice de linie, ecx- indice de col, ebx- liber
	#pun in bl el curent din matrice
	
	movb (%edi, %eax, 1), %bl
	
get_if1:
	cmpb %bl, id
	jne get_if2
	
	cmp %esi, ok
	jne get_if2
	
	movl $1, ok
	movb %bl, aux
	movl %edx, inceputl
	movl %edx, sfarsitl
	movl %ecx, inceputc
	movl %ecx, sfarsitc

get_if2:
	cmpb %bl, aux
	jne get_if3
	
	cmp %esi, ok
	je get_if3
	
	addl $1, sfarsitc
	
get_if3:	
	cmpb %bl, aux
	je terminare_ifuri_get
	
	cmp %esi, ok
	je terminare_ifuri_get
	
	movl $0, ok
	
terminare_ifuri_get:
	inc %ecx
	jmp get_coloane_loop

get_coloane_loop_stop:
	xor %ecx, %ecx
	inc %edx
	jmp get_linii_loop
	
get_linii_loop_stop:
	
	subl $1, sfarsitc
	# afisez pozitiile id-ului gasit
	
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx
	
	push sfarsitc
	push sfarsitl
	push inceputc
	push inceputl
	push $formatprintfget
	call printf
	add $20, %esp
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax
	
	popl %ecx
	
verific_delete:
	
	mov op, %eax
	cmp $3, %eax
	jne verific_defrag
	
	# eax-liber, ebx-liber, ecx- liber, edx- liber
	# citesc id-ul pentru delete
	
	pushl %eax
	pushl %ecx
	pushl %edx
	push $id
	push $formatscanf
	call scanf
	add $8, %esp
	popl %edx
	popl %ecx
	popl %eax
	
	# sterg id-ul citit
	pushl %ecx
	
	# edx- contor pt linii, ecx- contor pt coloane, eax- indicele elm curent,
	# bl- el curent din vector
	xor %ecx, %ecx
	xor %edx, %edx
delete_linii_loop:
	cmp $1024, %edx
	je delete_linii_loop_stop
	
delete_coloana_loop:
	cmp $1024, %ecx
	je delete_coloana_loop_stop
	
	# calculez in eax indicele el matricei
	
	xor %eax, %eax
	mov %edx, %eax
	pushl %edx
	xor %edx, %edx
	mull nrlinii
	xor %edx, %edx
	popl %edx
	add %ecx, %eax
	
	movb (%edi, %eax, 1), %bl
	
	cmpb %bl, id
	jne terminare_ifuri_delete
	
	movb $0, %bl
	movb %bl, (%edi, %eax, 1)
	
terminare_ifuri_delete:
	inc %ecx
	jmp delete_coloana_loop
	
delete_coloana_loop_stop:
	xor %ecx, %ecx
	inc %edx
	jmp delete_linii_loop

delete_linii_loop_stop:
	popl %ecx
	
delete_afis:
	
	# incep afisarea memoriei dupa stergerea id-ului citit
	
	pushl %ecx	# salvez val lui ecx (indice pt cit op)
	
	# ecx- va fi indice pt col, edx- indice pt linii, bl- el curent din vect
	# eax- liber
	mov $0, %esi	# pentru compararea cu ok
	
	mov %esi, inceputc
	mov %esi, sfarsitc
	mov %esi, inceputl
	mov %esi, sfarsitl
	mov %esi, aux
	mov %esi, ok
	xor %ecx, %ecx
	xor %edx, %edx
	
delete_afis_linii_loop:

	cmp $1024, %edx
	je delete_afis_linii_loop_stop
	
delete_afis_coloane_loop:

	cmp $1024, %ecx
	je delete_afis_coloane_loop_stop
	
	# calculez in eax indicele el curent din matrice
	xor %eax, %eax
	mov %edx, %eax
	pushl %edx
	xor %edx, %edx
	mull nrlinii
	xor %edx, %edx
	popl %edx
	add %ecx, %eax
	
	mov (%edi, %eax, 1), %bl
	
delete_if1_afis:
	cmpb %bl, aux
	jne delete_if2_afis
	
	cmp %esi, ok
	je delete_if2_afis
	
	addl $1, sfarsitc
	
delete_if2_afis:
	cmpb $0 ,%bl
	je delete_if3_afis
	
	cmp %esi, ok
	jne delete_if3_afis
	
	movb %bl, aux
	movl $1, ok
	mov %edx, inceputl
	mov %edx, sfarsitl
	mov %ecx, inceputc
	mov %ecx, sfarsitc

delete_if3_afis:
	cmpb %bl, aux
	je delete_terminare_ifuri_afis
	
	cmp %esi, ok
	je delete_terminare_ifuri_afis
	
	mov %esi, ok
	dec %ecx
	
	pushl %eax
	pushl %ecx
	pushl %edx
	push sfarsitc
	push sfarsitl
	push inceputc
	push inceputl
	push aux
	push $formatprintf
	call printf
	add $24, %esp
	popl %edx
	popl %ecx
	popl %eax

delete_terminare_ifuri_afis:
	
	inc %ecx
	jmp delete_afis_coloane_loop

delete_afis_coloane_loop_stop:
	
	xor %ecx, %ecx
	inc %edx
	jmp delete_afis_linii_loop

delete_afis_linii_loop_stop:
	popl %ecx

verific_defrag:	

	mov op, %eax
	cmp $4, %eax
	jne continui_citirea_op
	
	# eax- op, ecx- contor pt op, edx- liber, ebx-liber
	
	# initializez vectorii d,l cu 0, la fel si dim lor di, li
	# d, l sunt de tip long
	# edi are adresa lui v-matrice, esi- adresa lui d, ebx- adresa lui l
	
	mov $d, %esi
	mov $l, %ebx
	
	movl $0, di
	movl $0, li
	
	pushl %ecx 	# ecx- contor pt init d, l cu 0
	
	xor %ecx, %ecx
	mov $0, %eax
init_dl_loop:
	cmp $256, %ecx
	je init_dl_loop_stop
	
	mov %eax, (%esi, %ecx, 4)
	mov %eax, (%ebx, %ecx, 4)
	
	inc %ecx
	jmp init_dl_loop
init_dl_loop_stop:
	popl %ecx 
		#am init d si l cu 0
	# ecx- contor pt op, edi-adresa pt v, esi-adresa pt d, ebx- adresa pt l
	# eax, edx- liber
	# fac defragmentare unidim pe fiecare linie din  matrice
	
	pushl %ecx
	pushl %ebx	# pun pe stiva ebx pt a salva val de dinainte
	
	xor %ebx, %ebx	# ebx = 0
	xor %edx, %edx
	xor %ecx, %ecx

defrag_uni_linie_loop:
	cmp $1024, %edx
	je defrag_uni_linie_loop_stop
	
	movl $0, k
defrag_uni_col_loop:
	cmp $1024, %ecx
	je defrag_uni_col_loop_stop
	
	# in eax calculez indicele el din matrice
	mov %edx, %eax
	pushl %edx
	xor %edx, %edx
	mull nrlinii
	xor %edx, %edx
	popl %edx
	add %ecx, %eax
	
	movb (%edi, %eax, 1), %bl
	
	cmpb $0, %bl
	je defrag_urm_elem
	
	pushl %ecx
	pushl %esi
	#movb (%edi, %eax, 1), %cl
	mov %eax, %esi
	pushl %eax
	
	xor %eax, %eax
	mov %edx, %eax
	pushl %edx
	xor %edx, %edx
	mull nrlinii
	xor %edx, %edx
	popl %edx
	addl k, %eax
	
	# in eax am calculat j*nrlinii+k
	
	movb %bl, (%edi, %eax, 1)
	popl %eax
	
	addl $1, k
	
	popl %esi
	popl %ecx
	
	# ecx- contor pt coloane, esi- adresa pt d, ebx- liber, eax- liber,
	# edx- contor pt linii, edi- adresa pt v
	
defrag_urm_elem:
	inc %ecx
	jmp defrag_uni_col_loop
	
defrag_uni_col_loop_stop:

	pushl %ecx	# ecx va fi contor pt atribuire de 0
	mov k, %ecx
defrag_atr_0_loop:
	cmp $1024, %ecx
	je defrag_atr_0_loop_stop
	
	# calculez in eax indicele el din matrice care trb facut 0
	xor %eax, %eax
	mov %edx, %eax
	pushl %edx
	xor %edx, %edx
	mull nrlinii
	xor %edx, %edx
	popl %edx
	add %ecx, %eax
	
	pushl %eax
	xor %eax, %eax
	mov %eax, %ebx
	popl %eax
	movb %bl, (%edi, %eax, 1)
	
	inc %ecx
	jmp defrag_atr_0_loop

defrag_atr_0_loop_stop:
	popl %ecx
	xor %ecx, %ecx
	inc %edx
	jmp defrag_uni_linie_loop
defrag_uni_linie_loop_stop:
	popl %ebx
	popl %ecx
	
	# ecx- contor pt op, ebx- adresa pt l, esi-adresa pt d, eax-liber,
	# edx- liber, edi- adresa pt v
	
	# creez d cu di comp si l cu li comp
	xor %eax, %eax
	movb (%edi, %eax, 1), %dl
	movb %dl, defrag_aux	# defrag_aux contine primul element din matricea v
	
	addl $1, di
	addl $1, li
	
	mov di, %eax
	mov defrag_aux, %edx
	mov %edx, (%esi, %eax, 4)	# d[1] = defarg_aux
	xor %edx, %edx
	mov %edx, (%ebx, %eax, 4)	# l[1] = 0
	movb $0, ok_def
	
	# construiesc d si l
	
	pushl %ecx	# salvez val ant a lui ecx
	
	# ecx-contor pt col, edx- contor pt linii, eax-liber
	xor %ecx, %ecx
	xor %edx, %edx
	
construire_linie_loop:
	cmp $1024, %edx
	je construire_linie_loop_stop

construire_coloana_loop:
	cmp $1024, %ecx
	je construire_coloana_loop_stop
	
	# calculez in eax indicele el curent din matrice
	xor %eax, %eax
	mov %edx, %eax
	pushl %edx
	xor %edx, %edx
	mull nrlinii
	xor %edx, %edx
	popl %edx
	add %ecx, %eax
	
	pushl %edx	# contor linie
	pushl %ecx	# contor coloana
	# salvez edx si ecx pentru a putea fi folositi in for
	movb (%edi, %eax, 1), %dl	# dl el din matrice
	
constr_if1:
	cmpb %dl, ok
	je constr_if2
	
	cmpb %dl, defrag_aux
	jne constr_if2
	
	pushl %eax	# am salvat indicele curent din matrice
	mov di, %eax	# eax- indicele lui l 
	mov (%ebx, %eax, 4), %ecx
	add $1, %ecx
	mov %ecx, (%ebx, %eax, 4)
	popl %eax	# eax- indicele curent din matrice
	
constr_if2:
	
	cmpb %dl, ok
	je terminare_ifuri_constr
	
	cmpb %dl, defrag_aux
	je terminare_ifuri_constr
	
	xor %ecx, %ecx
	movb (%edi, %eax, 1), %cl 
	movb %cl, defrag_aux
	
	addl $1, di
	addl $1, li
	
	pushl %eax
	
	mov di, %eax
	mov defrag_aux, %ecx
	mov %ecx, (%esi, %eax, 4)
	mov $1, %ecx
	mov %ecx, (%ebx, %eax ,4)
	popl %eax

terminare_ifuri_constr:
	popl %ecx
	popl %edx
	
	inc %ecx
	jmp construire_coloana_loop

construire_coloana_loop_stop:
	xor %ecx, %ecx
	inc %edx
	jmp construire_linie_loop

construire_linie_loop_stop:
	popl %ecx
	
	# am terminat de construit d si l
	# ecx- contor pt op, eax- liber, edx- liber, ebx- adresa pt l
	# edi- adresa pt v, esi- adresa pt d
	
	# umplu matricea v cu elemente de 0
	
	pushl %ecx	# salvez valoarea ant a lui ecx
	xor %ecx, %ecx
	xor %edx, %edx
	
umplere_0_linie_loop:
	cmp $1024, %edx
	je umplere_0_linie_loop_stop
	
umplere_0_col_loop:
	cmp $1024, %ecx
	je umplere_0_col_loop_stop

	# calculez in eax indicele curent al elem din matrice
	xor %eax, %eax
	mov %edx, %eax
	pushl %edx
	xor %edx, %edx
	mull nrlinii
	xor  %edx, %edx
	popl %edx
	add %ecx, %eax
	
	pushl %edx
	movb $0, %dl
	movb %dl, (%edi, %eax, 1)
	popl %edx

	inc %ecx
	jmp umplere_0_col_loop
umplere_0_col_loop_stop:
	xor %ecx, %ecx
	inc %edx
	jmp umplere_0_linie_loop

umplere_0_linie_loop_stop:
	popl %ecx	# ii redau lui ecx val de contor pentru op
	
	# matricea are toate el 0
	# ecx- contor pt op, eax- liber, edx- liber, ebx- adresa pt l
	# edi- adresa pt v, esi- adresa pt d
	# reconstuiesc matricea folosindu ma de d si l
	
	pushl %ecx 	# salvez valoarea anterioara a lui ecx
	
	movl $1, auxd
	movl $1, auxl
	movl $0, auxx
	
	xor %ecx, %ecx
	xor %edx, %edx
	
matrice_linie_loop:
	cmp $1024, %edx
	je matrice_linie_loop_stop
	
matrice_coloana_loop:
	cmp $1024, %ecx
	je matrice_coloana_loop_stop
	
	pushl %edx
	mov auxl, %eax
	mov (%ebx, %eax, 4), %edx	# edx=l[auxl]
	xor %eax, %eax
	mov %edx, %eax
	sub nrlinii, %eax
	add %ecx, %eax
	#eax= l[auxl] - nrlinii + j
	popl %edx
pauza:
	
	cmp $0, %eax
	jg nu_se_executa
	
	pushl %edx
	mov auxd, %eax
	mov (%ebx, %eax, 4), %edx	# edx = l[auxd]
	mov %edx, auxx			# auxx = l[auxd]
	popl %edx
	
	mov auxx, %eax
	add %ecx, %eax		# eax = auxx + j
	mov %eax, capat		# capat = auxx + j
	
	mov %ecx, %eax		# eax = j
	
	pushl %ecx	# salvez val lui ecx
	mov %eax, %ecx
	
constr_final_loop:
	cmp capat, %ecx
	je constr_final_loop_stop
	
	# construiesc ind
	mov %edx, %eax
	pushl %edx
	xor %edx, %edx
	mull nrlinii
	xor %edx, %edx
	popl %edx
	add %ecx, %eax
	
	pushl %edx
	mov %eax, %edx		# salvez in edx ind
	mov auxd, %eax
	pushl %ecx
	mov (%esi, %eax, 4), %ecx	# ecx = d[auxd]
	
	mov %ecx, auxiliar
	movb auxiliar, %cl
	
	movb %cl, (%edi, %edx, 1)
	
	popl %ecx
	popl %edx
	
	inc %ecx
	jmp constr_final_loop

constr_final_loop_stop:
	popl %ecx	# restaurez ecx cu val sa anterioara (indice pt col matrice)
	
	# eax- liber, edx- contor pt lin matr, ecx- contor pt col matr,
	# ebx- adresa pt l, edi- adresa pt matrice, esi- adresa pt d
	
	pushl %edx
	mov auxd, %eax
	mov li, %edx
	mov %edx, auxiliar
	popl %edx
	cmp auxiliar, %eax		# auxd > li
	jg gata
	
	pushl %edx
	mov (%ebx, %eax, 4), %edx
	add %edx, %ecx
	sub $1, %ecx
	popl %edx
	addl $1, auxd
	addl $1, auxl
	
gata:
nu_se_executa:
	inc %ecx
	jmp matrice_coloana_loop
matrice_coloana_loop_stop:
	xor %ecx, %ecx
	inc %edx
	jmp matrice_linie_loop

matrice_linie_loop_stop:	
	popl %ecx	# ecx- contor pt op
	
	# fac afisarea pentru defrag
	pushl %ecx	# salvez val ant a lui ecx
	# ecx- contor pt col, edx- contor pt col, eax-liber, ebx- liber
	
	xor %esi, %esi
	xor %ecx, %ecx
	xor %edx, %edx
	xor %ebx, %ebx
	movl $0, inceputc
	movl $0, sfarsitc
	movl $0, inceputl
	movl $0, sfarsitl
	movl $0, aux
	mov %esi, ok
	
defrag_afis_linie_loop:
	cmp $1024, %edx
	je defrag_afis_linie_loop_stop
	
defrag_afis_col_loop:
	cmp $1024, %ecx
	je defrag_afis_col_loop_stop
mam:	
	# calculez in eax indicele el curent din matrice
	xor %eax, %eax
	mov %edx, %eax
	pushl %edx
	xor %edx, %edx
	mull nrlinii
	xor %edx, %edx
	popl %edx
	add %ecx, %eax
	
	mov (%edi, %eax, 1), %bl
	
defrag_if1_afis:
	cmpb %bl, aux
	jne defrag_if2_afis
	
	cmp %esi, ok
	je defrag_if2_afis
	
	addl $1, sfarsitc
	
defrag_if2_afis:
	cmpb $0 ,%bl
	je defrag_if3_afis
	
	cmp %esi, ok
	jne defrag_if3_afis
	
	movb %bl, aux
	movl $1, ok
	mov %edx, inceputl
	mov %edx, sfarsitl
	mov %ecx, inceputc
	mov %ecx, sfarsitc

defrag_if3_afis:
	cmpb %bl, aux
	je defrag_terminare_ifuri_afis
	
	cmp %esi, ok
	je defrag_terminare_ifuri_afis
	
	mov %esi, ok
	dec %ecx
	
	pushl %eax
	pushl %ecx
	pushl %edx
	push sfarsitc
	push sfarsitl
	push inceputc
	push inceputl
	push aux
	push $formatprintf
	call printf
	add $24, %esp
	popl %edx
	popl %ecx
	popl %eax

defrag_terminare_ifuri_afis:
	inc %ecx
	jmp defrag_afis_col_loop
	
defrag_afis_col_loop_stop:
	xor %ecx, %ecx
	inc %edx
	jmp defrag_afis_linie_loop
	
defrag_afis_linie_loop_stop:

	popl %ecx

continui_citirea_op:	
	add $1, %ecx
	jmp citire_operatii_loop

citire_operatii_loop_stop:

et_exit:
	pushl $0
	call fflush
	popl %eax

	mov $1, %eax
	xor %ebx, %ebx
	int $0x80
