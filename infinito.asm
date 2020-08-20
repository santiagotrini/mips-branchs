#############################################
### Ejecutar paso a paso! Bucle infinito! ###
#############################################

.data
new_line: .asciiz "\n"   # para poner cada potencia en una nueva linea

.text
.globl main
main:
  li        $t0, 2             # n = 2
loop:
  li        $v0, 1             # print_int code
  move      $a0, $t0           # copio t0 a a0
  syscall                      # print n
  mul       $t0, $t0, 2        # t0 *= 2
  li        $v0, 4             # print_string code
  la        $a0, new_line      # newline char
  syscall                      # print "\n"
  j         loop               # goto loop
exit:
  li        $v0, 10            # exit code
  syscall                      # a esta syscall no voy a llegar nunca
