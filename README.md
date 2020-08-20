# MIPS: branchs y jumps

Segunda parte de la introducción a _assembler_ de MIPS. La primera parte la pueden encontrar [aquí](https://la35.net/orga/mips-intro.html).

## El infame GO TO

Cuando programamos usando `if` o `while` en algún lenguaje de alto nivel como C o Python estamos adhiriendo a lo que se conoce como **programación estructurada**, un paradigma de programación surgido en los años '60.

La programación estructurada estableció que las estructuras de control básicas son tres. Secuencial, de selección e iterativas. La primera la vimos en el artículo anterior. El código se ejecuta secuencialmente desde la primer instrucción hasta la última tal como se lee. Las otras dos requieren una **decisión** entre tomar un camino u otro dentro del código. Es lo que hacemos con los condicionales y los ciclos: `if`, `while`, `switch`, `for`, etc.

Cuando empezó a circular la idea de la programación estructurada hubo víctimas. Probablemente la víctima más famosa fue el enunciado `goto`. "Ir hacia" en español. Esta palabra clave que existe en C y muchos otros lenguajes de alto nivel pero que hoy en día nadie usa viene de la programación en _assembler_. Claro, en esa época todavía se hacía mucha programación en ensamblador y la idea era natural. Pero la programación estructurada desterró el enunciado `goto` considerándolo dañino.

Es que en lenguaje ensamblador si uno quiere modificar el flujo de un programa, lo que hace es modificar el _program counter_. Cambiando el PC cambiamos la próxima instrucción que se va a ejecutar. El `goto` en los lenguajes de alto nivel es la contrapartida de dos tipos de instrucciones en ensamblador, los _jumps_ y los _branchs_. Saltos y ramificaciones.

## Jumps

Trabajar con _jumps_ en MIPS es simple. Un salto o _jump_ es cuando cambiamos el valor del PC de manera **incondicional**. El primer programa de ejemplo implementa un ciclo infinito que imprime potencias de dos.

```asm
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
```

Cuando escribimos _jumps_ no tenemos que escribir literalmente la dirección de memoria de la instrucción a la que queremos saltar. Podemos valernos de la comodidad de las etiquetas. En este caso saltamos a la etiqueta `loop:` en cada iteración del ciclo.

Claro que para ir calculando potencias de dos multiplicamos. Para eso podemos usar la pseudoinstrucción `mul` que opera de la misma manera que `add`, con dos registros como operandos y un registro como destino de la operación.

Si deciden probar este ejemplo en SPIM no ejecuten el código con el botón de _run_, usen la función de ejecutar el código paso a paso porque el programa no termina nunca, es un bucle infinito.

Existen tres tipos de _jumps_ en MIPS.

- _Jump_: la instrucción `j label` donde `label` es una etiqueta.
- _Jump register_: la instrucción `j $rd` donde `$rd` es algún registro que debería contener una dirección de memoria válida que apunte a una instrucción.
- _Jump and link_: la instrucción `jal label` donde `label` es una etiqueta, generalmente apuntando a una función.

Los dos últimos tipos de _jumps_ van a tener más sentido cuando veamos como escribir funciones en _assembler_.   

## Branchs

Cuando queremos cambiar el _program counter_ según se cumpla o no una condición usamos un _branch_ o ramificación. Un **salto condicional** en el código.

Los _branchs_ disponibles en MIPS son:

- _Branch on equal_: la instrucción `beq $rs, $rt, label` donde `$rs` y `$rt` son dos registros. Si son iguales el PC toma el valor de `label`.
- _Branch on not equal_: la instrucción `bne $rs, $rt, label`, igual que `beq` pero el salto se produce si los registros no son iguales.

Si arreglamos el programa anterior para que el bucle no sea infinito, sino que imprima las primeras 10 potencias nos quedaría de la siguiente manera.

```asm
.data
new_line: .asciiz "\n"   # para poner cada potencia en una nueva linea

.text
.globl main
main:
  li        $t0, 2             # n = 2
  li        $t1, 10            # count = 10
loop:
  beq       $t1, $zero, exit   # if (t1 == 0) goto exit
  li        $v0, 1             # print_int code
  move      $a0, $t0           # copio t0 a a0
  syscall                      # print n
  mul       $t0, $t0, 2        # t0 *= 2
  li        $v0, 4             # print_string code
  la        $a0, new_line      # newline char
  syscall                      # print "\n"
  addi      $t1, $t1, -1       # count--
  j         loop               # goto loop
exit:
  li        $v0, 10            # exit code
  syscall                      # exit
```

En este programa usamos un contador para salir del _loop_ aunque también podríamos tomar esa decisión con el valor del registro `$t0` y ahorrarnos el registro del contador.

Vemos que en _assembler_ no hay una diferencia tan clara entre un bucle y un condicional. La implementación de estas dos estructuras de control se realizan con las mismas instrucciones. Veamos un tercer ejemplo con un condicional.

```asm
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
```

Este programa recibe un número del usuario y decide si es un número par o no. El código hace uso de la pseudoinstrucción `rem` por _remainder_ o resto (de la división). Mismo formato que `add`, `rem $rd, $rs, $rt` es la manera convencional de nombrar los registros. El primer registro siempre es el destino de la operación (`rd` es por _register destination_) y los dos operandos o fuentes de la operación son `rs` (_register source_) y `rt` porque la "t" es la próxima letra después de la "s". Pero como es una pseudoinstrucción también podemos usar valores inmediatos, el ensamblador de MIPS es los suficientemente inteligente para reemplazar de antemano ese 2 por un registro con el número 2.

Noten que si el _branch_ no es exitoso, o sea no se produce el salto, el código sigue con la próxima instrucción. El PC incrementa su valor en 4 para apuntar a la próxima instrucción.

Creo que viendo el ejemplo de la estructura condicional usando saltos uno se convence de que los programadores de la década del '60 tenían razón al proponer el paradigma de la programación estructurada al que estamos tan acostumbrados hoy en día.
