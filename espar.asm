.data
prompt: .asciiz "Ingrese un numero\n"    # prompt string
es_par: .asciiz "El numero es par\n"     # es_par string
no_par: .asciiz "El numero no es par\n"  # no_par string

.text
.globl main
main:
  li        $v0, 4             # syscall print_string code
  la        $a0, prompt        # cargo la direccion del string en a0
  syscall                      # imprimo el prompt
  li        $v0, 5             # syscall read_int code
  syscall                      # leo el primer numero
  move      $t0, $v0           # muevo el resultado de la syscall a t1
  rem       $t1, $t0, 2        # t1 = t0 % 2
  beq       $t1, $zero, yes    # if (t1 == 0) goto yes
  li        $v0, 4             # syscall print_string code
  la        $a0, no_par        # cargo la direccion del string en a0
  syscall                      # imprimo no es par
  j         exit               # voy a exit
yes:
  li        $v0, 4             # syscall print_string code
  la        $a0, es_par        # cargo la direccion del string en a0
  syscall                      # imprimo es par
exit:
  li        $v0, 10            # syscall exit code
  syscall                      # exit syscall
