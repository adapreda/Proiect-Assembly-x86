.data
	v: .space 4096
	O: .space 4
	op: .space 4
	N: .space 4
	id: .space 4
	dim: .space 4
	nrde0 : .space 4
	inceput: .space 4
	zero: .space 4
	sfarsit: .space 4
	impartitor: .long 8
	aux_add: .space 4
	aux: .space 4
	aux2: .space 4
	ok: .space 4
	formatscanf: .asciz "%d"
	formatprintfget: .asciz "(%d, %d)\n"
	formatprintf: .asciz "%d: (%d, %d)\n"
.text
.global main
	

main:

intializare_cu0:
	#initializez fiecare element din v cu 0
	xor %ecx, %ecx
	mov $1024, %eax
	mov $v, %edi
initializare_loop:
	cmp %eax, %ecx
	je initializare_loop_stop
	mov $0, %edx
	mov %edx, (%edi, %ecx,4)
	inc %ecx
	jmp initializare_loop
initializare_loop_stop:
	#dupa initializarea el din v cu 0, reinit toti registrii cu 0
	xor %eax, %eax
	xor %ecx, %ecx
	xor %edx, %edx
	
citire_nr_operatii:
	#citesc nr de operatii care vor fi efectuate
	push $O
	push $formatscanf
	call scanf
	add $8, %esp

citire_operatii:
	# cu un ecx parcurg nr de la 1 la O si in funtie de operatia -op- citita 
	# apelez procedura specifica op
	xor %ecx, %ecx
	xor %eax, %eax
	
citire_operatii_loop:

	cmp %ecx, O	#daca %ecx e egal cu O, atunci ies din for
	je citire_operatii_loop_stop
	
	pushl %eax
	pushl %ecx
	push $op			# citesc op, care imi indica ce operatie fac
	push $formatscanf		# daca nu dau push la ecx si eax la apelul printf si scanf,
	call scanf			# isi vor pierde valoarea dinainte de apel
	add $8, %esp
	popl %ecx
	popl %eax
	
	# am citit op, acum verif daca e 1 2 3 sau 4
	
	mov op, %eax		# eax are val lui op
	cmp $1, %eax 
	jne verific_urm_posibilitate	# daca eax nu este 1 (op nu e 1), atunci 
					# continui sa compar cu 2 3 si 4
	
procedura_add:				# daca eax e 1 (op e 1 execut instr pt add)
	#ecx e contor, eax are valoarea lui op
	
	pushl %eax	#citesc N- nr de id uri care se citesc
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
	push $formatscanf	# am citit id-ul unui fisier
	call scanf
	add $8, %esp
	popl %edx
	popl %ecx
	popl %eax
	
	pushl %eax
	pushl %ecx
	pushl %edx
	push $dim
	push $formatscanf	# am citit dimensiunea unui fisier
	call scanf
	add $8, %esp
	popl %edx
	popl %ecx
	popl %eax
	
	#ecx contor pt operatii, eax are val lui op, edx e contor pt fisiere
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
	# adresa lui v e in %edi
	
	# urmeaza apelarea procedurii add
	# de ce am nevoie? -> id, dim_blocuri(%ebx), v
	# trb sa ma reintorc la val de dinainte de add ale lui eax,ecx,edx
	
	#nu mai folosesc proceduri, scriu direct in main
	
	# pun valorile registrilor pe stiva, pentru a ma putea intoarce la valorile lor, dupa 
	# adaugarea id urilor in vector (fara ebx pt ca am nevoie de dim in blocuri)
	
	pushl %eax
	pushl %ecx
	pushl %edx
	
efectuare_add:
	
	movl $-1, %eax		# am init inceput si sfarsit cu -1
	movl %eax, inceput
	movl %eax, sfarsit
	
	xor %ecx, %ecx		# urmeaza sa parcurg el vectorului		
	#eax are val -1 pt a putea verifica daca inceput si sfrasit au fost modif
	
add_loop:
	
	cmp $1024, %ecx
	je add_loop_stop	
	mov (%edi, %ecx, 4), %edx	# edx e el curent din vector
	
add_if1:
	cmp $0, %edx
	jne add_if2
	cmpl %eax, inceput
	jne add_if2
	movl %ecx, inceput	# am gasit primul 0, ii marchez gasirea prin modif
	movl %ecx, sfarsit	# var inceput si sfarsit
	
add_if2:
	cmp $0, %edx
	jne add_if3
	cmpl %eax, inceput
	je add_if3
	
	mov %ecx, sfarsit
	pushl %ecx	# ii salvez val anterioara, acum in ecx calc: final-ebx+1==inceput?
	#addl $1, sfarsit
	mov sfarsit, %ecx
	sub %ebx, %ecx		#scad din sfarsit nr de blocuri
	add $1, %ecx
	cmpl %ecx, inceput	# daca nu sunt egale, trb sa continui, trebuie dat
	je restaurare_registru	# pop la ecx
	popl %ecx
	
add_if3:
	cmp $0, %edx
	je terminare_ifuri_add
	cmpl %eax, sfarsit
	je terminare_ifuri_add
	movl %eax, inceput
	movl %eax, sfarsit
	#jmp add_loop_stop
	
	
terminare_ifuri_add:	
	inc %ecx
	jmp add_loop

# restaurare_registru este inainde de add_loop_stop, pentru ca voi sari 
# la aceasta eticheta doar daca cond e indeplinita, altfel sar direct la 
# add_loop_stop

restaurare_registru:	
	popl %ecx	
	
add_loop_stop:
	# am terminat for ul din add (c++), adica am gasit poz pe care trebuie
	# pus id ul citit
	
	xor %ecx, %ecx 	# parcurg iar el vect de la inceput la sfarsit, si v[i]=id
	mov inceput, %ecx	# ecx= inceput
	
	#eax=-1, edx=el din vect, ebx=dim bloc, ecx=contor pt atribuire
	
	addl $1, sfarsit	# sfarsit e ultima poz pe care gasesc 0, pt a atribui bine cresc sfarsit cu 
				# o unitate si afisez pana la sfarsit-1
	# in nrde0 numar cati de 0 am pentru fiecare id in parte
	
	pushl %eax
	mov sfarsit, %eax
	sub inceput, %eax
	mov %eax, nrde0
	popl %eax
	
	# daca nrde0 e mai mic decat dim bloc, atunci id ul nu se pune in vector
	
	cmpl %ebx, nrde0
	jl atribuire_loop_nu_incape
	
atribuire_loop:
	cmpl %ecx, sfarsit
	je atribuire_loop_stop
	mov id, %eax
	mov %eax, (%edi, %ecx, 4)
	mov %eax, aux_add
	inc %ecx
	jmp atribuire_loop
	
atribuire_loop_stop:
	# am terminat de atribuit el din vect valoarea din id
	# eax- id ul, ecx- liber, edx- el din vector, ebx- dim bloc
	
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx
	
	subl $1, sfarsit
	
	push sfarsit
	push inceput
	push aux_add
	push $formatprintf
	call printf
	add $16, %esp
	
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax
	
	jmp gata_add
	
atribuire_loop_nu_incape:
	
	mov id, %eax
	mov %eax, aux_add
	
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx
	
	push zero
	push zero
	push aux_add
	push $formatprintf
	call printf
	add $16, %esp
	
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax
	
gata_add:
	popl %edx
	popl %ecx
	popl %eax
	
	
	# dupa restaurarea registrilor din stiva, am terminat add ul

	# acum, citesc urm id si dim 
	
	inc %edx
	jmp citire_id_loop

citire_id_loop_stop:
	# cred ca aici voi apela procedura afis, pt ca edx va fi egal cu N,
	# deci imi iese din loop (nu mai sunt id-uri de citit, deci afisez
	# id-urile cu poz de inceput si final)
	
	# urmeaza afisarea poz de inceput si final a poz fisierelor
	# ecx = contorul pentru operatii, ebx-liber, eax-liber, edx- liber
	
salut:	
	
	xor %ebx, %ebx
	xor %eax, %eax
	xor %edx, %edx
	
	
verific_urm_posibilitate:
	
verific_get: 
	
	# ecx - contor pt citire op, eax- liber, ebx- liber, edx- liber
	# pun in eax val 2 (2 corespunde lui get) si compar cu op sa vad daca 
	# operatia este get

	mov op, %eax
	cmp $2, %eax
	jne verific_delete
	
procedura_get:
	
	# citesc id-ul pentru 'procedura' get
	
	pushl %edx
	pushl %eax
	pushl %ecx
	push $id
	push $formatscanf
	call scanf
	add $8, %esp
	popl %ecx
	popl %eax
	popl %edx
	
	# ecx- contor pt citire op, eax=2, edx- liber, ebx-liber
	
efectuare_get:
	
	pushl %ecx 	# salvez valoarea lui ecx
	movl $0, ok
	movl $0, inceput
	movl $1, sfarsit
	movl $0, aux
	xor %ecx, %ecx
	xor %eax, %eax		# pt comp lui ok cu 0
	
afis_loop_get:

	cmp $1024, %ecx
	je afis_loop_get_stop
	mov (%edi, %ecx, 4), %edx	# edx- el curent din vector
	
afis_get_if1:
	
	cmpl %edx, id
	jne afis_get_if2
	cmpl %eax, ok
	jne afis_get_if2
	movl $1, ok
	mov %ecx, inceput
	mov %ecx, sfarsit
	mov %edx, aux

afis_get_if2:

	cmpl %edx, aux
	jne afis_get_if3
	cmpl %eax, ok
	je afis_get_if3
	addl $1, sfarsit
	
afis_get_if3:
	
	cmpl %edx, aux
	je terminare_ifuri_get
	cmpl %eax, ok
	je terminare_ifuri_get
	movl $0, ok
	
terminare_ifuri_get:
	
	inc %ecx
	jmp afis_loop_get

afis_loop_get_stop:

	# afisez poz de inceput si sfarsit a id ului citit
	
	subl $1, sfarsit
	
	pushl %ecx
	pushl %eax
	pushl %edx
	push sfarsit
	push inceput
	push $formatprintfget
	call printf
	add $12, %esp
	popl %edx
	popl %eax
	popl %ecx
	
	popl %ecx 	# restaurez ecx cu val pt citirea op
	
	# ecx- contor pt citirea op, eax- liber, ebx- liber, edx- liber
	
verific_delete:	
	
	# pun in eax val 3 (3 corespunde operatiei delete)
	
	mov op, %eax
	cmp $3, %eax
	jne verific_defragmentation
	
procedura_delete:
	
	# citesc id ul pentru procedura delete
	
	pushl %edx
	pushl %ecx
	pushl %eax
	push $id
	push $formatscanf
	call scanf
	add $8, %esp
	popl %eax
	popl %ecx
	popl %edx
	
	# ecx- contor pt citire op, eax=3,  edx- liber, ebx- liber
	
efectuare_delete:

	pushl %ecx 	# salvez val anterioara a lui ecx
	
	xor %ecx, %ecx 		# indice pt parcurgerea vect (caut id ul citit 
				# si fac comp respectiva 0)
	# edx- comp curenta a vect
	
delete_loop:

	cmp $1024, %ecx
	je delete_loop_stop_ecx
	mov (%edi, %ecx, 4), %edx
	
	cmpl %edx, id
	jne comp_urm
	mov $0, %eax
	mov %eax, (%edi, %ecx, 4)
	
comp_urm:	
	inc %ecx
	jmp delete_loop

delete_loop_stop_ecx:
	popl %ecx 	# restaurez ecx cu valoarea contorului pt citirea op
delete_loop_stop:
		
	# acum vreau sa afisez poz de inceput si final ale id-urilor != 0
	
	movl $0, aux
	movl $0, ok
	movl $0, sfarsit
	movl $0, inceput
	
	pushl %ecx 	# salvez val anterioara a lui ecx pt a nu o pierde
	
	xor %ecx, %ecx
	xor %eax, %eax
	
	# ecx- cont pt el din vector
	# edx- el din vector
	# eax = 0, ramane 0 pentru a l putea  compara pe ok cu 0 (eax)
	
afis_delete_loop:
	
	cmp $1024, %ecx
	je afis_delete_loop_stop
	mov (%edi, %ecx, 4), %edx
	
afis_delete_if1:

	cmpl %edx, aux
	jne afis_delete_if2
	cmpl %eax, ok
	je afis_delete_if2
	addl $1, sfarsit

afis_delete_if2:

	cmp %eax, %edx
	je afis_delete_if3
	cmpl %eax, ok
	jne afis_delete_if3
	movl $1, ok
	mov %ecx, inceput
	mov %ecx, sfarsit
	mov %edx, aux
	
afis_delete_if3:
	
	cmpl %edx, aux
	je terminare_ifuri_afis_delete
	cmpl %eax, ok
	je terminare_ifuri_afis_delete
	movl $0, ok
	sub $1, %ecx
	
	pushl %eax
	pushl %edx
	pushl %ecx
	push sfarsit
	push inceput
	push aux
	push $formatprintf
	call printf
	add $16, %esp
	popl %ecx
	popl %edx
	popl %eax
	
terminare_ifuri_afis_delete:

	inc %ecx
	jmp afis_delete_loop
	
afis_delete_loop_stop:
	
	# verific daca i a ajuns 1024 si daca v[1023] e dif de 0
	# daca da -> afisez aux inceput si 1023
	
	cmp $1024, %ecx
	jne mai_departe
	
	dec %ecx
	
	mov (%edi, %ecx, 4), %ebx
	cmp $0, %ebx
	je mai_departe
	
	movl $1023, sfarsit
	
	pushl %eax
	pushl %edx
	pushl %ecx
	push sfarsit
	push inceput
	push aux
	push $formatprintf
	call printf
	add $16, %esp
	popl %ecx
	popl %edx
	popl %eax
	
mai_departe:	
	popl %ecx 	# ecx- contor pt citirea op
	
verific_defragmentation:
	
	# ecx- contor pt citirea lui op, eax- liber, ebx- liber, ecx- liber
	# eax=4 -> pun in eax val 4 pentru a l compara cu op (4 e nr coresp pt defragmentare)
	
	mov $4, %eax
	cmpl %eax, op
	jne  ma_duc_la_urm_op
	
procedura_defragmenttation: 

	# incep sa scriu codul pt defragmentare
	
	pushl %ecx 	# salvez val anterioara a lui ecx pt a nu o pierde
	xor %ebx, %ebx		# pe ebx il voi folosi pe post de k
				# k- dimensiune 2 pentru v
	xor %ecx, %ecx		# pt parcurgere el vect
				# edx - el curent din vect
defrag_loop:

	cmp $1024, %ecx
	je defrag_loop_stop
	mov (%edi, %ecx, 4), %edx
	
	cmp $0, %edx
	je urm_elem_vector
	
	mov (%edi, %ecx, 4), %eax
	mov %eax, (%edi, %ebx, 4)
	add $1, %ebx
	
urm_elem_vector:
	
	inc %ecx
	jmp defrag_loop
	
defrag_loop_stop:
	
	# ecx- 1024, il fac 0, parcurg v pt atribuire cu 0
	# ebx- de unde incep pana la final vect
	# edx- el curent
	# eax- pun 0 in v[k]
	
	mov %ebx, %ecx
	
atribuire_defrag_loop:

	cmp $1024, %ecx
	je atribuire_defrag_loop_stop
	mov (%edi, %ecx, 4), %edx
	mov $0, %eax
	mov %eax, (%edi, %ecx, 4)
	
	inc %ecx
	jmp atribuire_defrag_loop
	

atribuire_defrag_loop_stop:

	popl %ecx	# restaurez ecx cu contor pentru citirea op
	
	# incep afisarea poz de inceput si sfarsit ale id-urilor
	
	# ecx-contor pt afis, eax- liber, ebx- liber, eax- liber
	
	pushl %ecx	# salvez val pt citirea de op
	
	xor %ecx, %ecx
	xor %eax, %eax
	
	movl $0, aux
	movl $0, ok
	movl $0, sfarsit
	movl $0, inceput
	
	# ecx- cont pt el din vector
	# edx- el din vector
	# eax = 0, ramane 0 pentru a l putea  compara pe ok cu 0 (eax)
	
afis_defrag_loop:
	
	cmp $1024, %ecx
	je afis_defrag_loop_stop
	mov (%edi, %ecx, 4), %edx
	
afis_defrag_if1:

	cmpl %edx, aux
	jne afis_defrag_if2
	cmpl %eax, ok
	je afis_defrag_if2
	addl $1, sfarsit	
	
afis_defrag_if2:

	cmp %eax, %edx
	je afis_defrag_if3
	cmpl %eax, ok
	jne afis_defrag_if3
	movl $1, ok
	mov %ecx, inceput
	mov %ecx, sfarsit
	mov %edx, aux
	
afis_defrag_if3:
	
	cmpl %edx, aux
	je terminare_ifuri_afis_defrag
	cmpl %eax, ok
	je terminare_ifuri_afis_defrag
	movl $0, ok
	sub $1, %ecx
	
	pushl %eax
	pushl %edx
	pushl %ecx
	push sfarsit
	push inceput
	push aux
	push $formatprintf
	call printf
	add $16, %esp
	popl %ecx
	popl %edx
	popl %eax
	
	
terminare_ifuri_afis_defrag:

	inc %ecx
	jmp afis_defrag_loop
	
afis_defrag_loop_stop:

	cmp $1024, %ecx
	jne uau
	
	mov %ecx, %eax
	dec %eax
	mov (%edi, %eax, 4), %ecx
	cmp $0, %ecx
	je uau
	
	mov $1023, %eax
	pushl %eax
	pushl %edx
	pushl %ecx
	push %eax
	push inceput
	push aux
	push $formatprintf
	call printf
	add $16, %esp
	popl %ecx
	popl %edx
	popl %eax
uau:	
	popl %ecx 	# ecx- contor pt citirea op


ma_duc_la_urm_op:	

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
	
