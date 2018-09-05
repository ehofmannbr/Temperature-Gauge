;
; max6675.asm
;
; Created: 10/07/2018 12:24:53
; Author : Home
;
.include "m328pdef.inc"

;Definicioes do Modulo Display TM1637

#define LETRAD 0x5E
#define LETRAO 0x5C
#define LETRAN 0x54
#define LETRAE 0x79
#define LETRAU 0x3E
#define LETRAR 0x31
;Dois pontos eh ligado quando o bit 7 da centena esta ligado
#define NUM0 0x003f;0b00111111;0x3f
#define NUM1 0x0006;0b00000110;0x06
#define NUM2 0x005B;0b01011011;0x5B
#define NUM3 0x004F;0b01001111;0x4F
#define NUM4 0x0066;0b01100110;0x66
#define NUM5 0x006D;0b01101101;0x6D
#define NUM6 0x007D;0b01111101;0x7D
#define NUM7 0x0007;0b00000111;0x07
#define NUM8 0x007F;0b01111111;0x7F
#define NUM9 0x006F;0b01101111;0x6F
#define NUMA 0x0077;0b01110111;0x77
#define NUMB 0x007C;0b01111100;0x7C
#define NUMC 0x0039;0b00111001;0x39
#define NUMD 0x005E;0b01011110;0x5E
#define NUME 0x0079;0b01111001;0x79
#define NUMF 0x0031;0b01110001;0x31
#define NOFF 0x0000;0b00000000;0x00


; Map TM1637 PIN1 CLK = ATMEGA328 PIN 9 PORTB 6
;            PIN2 DATA = ATMEGA328 PIN 10 PORTB 7 
;            LED = ATMEGA328 PIN 19 PORTB 5

#define p_DIO 7
#define p_CLK 6
#define p_LED 5

; Definicoes do Modulo MAX6675

; Map MAX6675 PIN 3 SCK = ATMEGA328 PIN 16 PORTB 2
;             PIN 4 CS = ATMEGA328 PIN 15 PORTB 1
;             PIN 5 SO = ATMEGA328P PIN 13 PORTD 7

#define p_SCK 2
#define p_CS  1
#define p_SO  7

		.org 0x00
		jmp start

start:

;inicializacao do display tm1637
		sbi DDRB, p_DIO
		sbi DDRB, p_CLK ;PORTB 7 e 6 e 5 saida
		sbi DDRB, p_LED
		sbi PORTB, p_DIO
		sbi PORTB, p_CLK; DATA e CLK em 1
		cbi PORTB, p_LED; LED Apagado
		ldi r16, NOFF
		sts dp_m, r16
		sts dp_c, r16
		sts dp_d, r16
		sts dp_u, r16
		ldi r16, 0x04
		sts dp_bright, r16

;inicializacao do modulo de temperatura max6675
		sbi DDRB, p_SCK ;Clock Saida
		sbi DDRB, p_CS  ;Chip Select Saida
		cbi DDRD, p_SO  ;Serial Out Entrada
		sbi PORTB, p_CS ; CS 1
		cbi PORTB, p_SCK; CK 0
;da retardo de 1 segundo para estabilizar coleta no modulo
		rcall delay3
		rcall delay3
		rcall delay3

lupi:	
		rcall le_max6675
		rcall formata_max6675
		rcall write_display_tm1637
;pisca o LED
		in r16, PORTB
		ldi r17, 0b00100000
		eor r16, r17
		out PORTB, r16
;da retardo de 1 segundo para estabilizar coleta no modulo
		rcall delay3
		rcall delay3
		rcall delay3
		rjmp lupi

Delay:
;200uS Carregar com 28
		ldi r20, 28
Delay_1:
		dec r20
		brne Delay_1
		ret

Delay3:
;Delay de 3 niveis para 0.502s
		ldi r20, 50
Delay3_1:
		ldi r21, 118
Delay3_2:
		ldi r22, 28
Delay3_3:
		dec r22
		brne Delay3_3
		dec r21
		brne Delay3_2
		dec r20
		brne Delay3_1
		ret

le_max6675:
		clr r17;vai ser usado para montar a resposta bit a bit
;abaixa p_CS
		cbi PORTB, p_CS
		rcall Delay;D15 disponivel, ignorar
;Aciona Serial Clock
		sbi PORTB, p_SCK
		rcall Delay
		cbi PORTB, p_SCK;
		rcall Delay;D14 disponivel
		in r16, PIND
		bst r16, 7
		bld r17, 6
;Aciona Serial Clock
		sbi PORTB, p_SCK
		rcall Delay
		cbi PORTB, p_SCK;
		rcall Delay;D13 disponivel
		in r16, PIND
		bst r16, 7
		bld r17, 5
;Aciona Serial Clock
		sbi PORTB, p_SCK
		rcall Delay
		cbi PORTB, p_SCK;
		rcall Delay;D12 disponivel
		in r16, PIND
		bst r16, 7
		bld r17, 4
;Aciona Serial Clock
		sbi PORTB, p_SCK
		rcall Delay
		cbi PORTB, p_SCK;
		rcall Delay;D11 disponivel
		in r16, PIND
		bst r16, 7
		bld r17, 3
;Aciona Serial Clock
		sbi PORTB, p_SCK
		rcall Delay
		cbi PORTB, p_SCK;
		rcall Delay;D10 disponivel
		in r16, PIND
		bst r16, 7
		bld r17, 2
;Aciona Serial Clock
		sbi PORTB, p_SCK
		rcall Delay
		cbi PORTB, p_SCK;
		rcall Delay;D9 disponivel
		in r16, PIND
		bst r16, 7
		bld r17, 1
;Aciona Serial Clock
		sbi PORTB, p_SCK
		rcall Delay
		cbi PORTB, p_SCK;
		rcall Delay;D8 disponivel
		in r16, PIND
		bst r16, 7
		bld r17, 0
		sts temp_h, r17
;Aciona Serial Clock
		sbi PORTB, p_SCK
		rcall Delay
		cbi PORTB, p_SCK;
		rcall Delay;D7 disponivel
		in r16, PIND
		bst r16, 7
		bld r17, 7
;Aciona Serial Clock
		sbi PORTB, p_SCK
		rcall Delay
		cbi PORTB, p_SCK;
		rcall Delay;D6 disponivel
		in r16, PIND
		bst r16, 7
		bld r17, 6
;Aciona Serial Clock
		sbi PORTB, p_SCK
		rcall Delay
		cbi PORTB, p_SCK;
		rcall Delay;D5 disponivel
		in r16, PIND
		bst r16, 7
		bld r17, 5
;Aciona Serial Clock
		sbi PORTB, p_SCK
		rcall Delay
		cbi PORTB, p_SCK;
		rcall Delay;D4 disponivel
		in r16, PIND
		bst r16, 7
		bld r17, 4
;Aciona Serial Clock
		sbi PORTB, p_SCK
		rcall Delay
		cbi PORTB, p_SCK;
		rcall Delay;D3 disponivel
		in r16, PIND
		bst r16, 7
		bld r17, 3
;Aciona Serial Clock
		sbi PORTB, p_SCK
		rcall Delay
		cbi PORTB, p_SCK;
		rcall Delay;D2 disponivel
		in r16, PIND
		bst r16, 7
		bld r17, 2
;Aciona Serial Clock
		sbi PORTB, p_SCK
		rcall Delay
		cbi PORTB, p_SCK;
		rcall Delay;D1 disponivel
		in r16, PIND
		bst r16, 7
		bld r17, 1
;Aciona Serial Clock
		sbi PORTB, p_SCK
		rcall Delay
		cbi PORTB, p_SCK;
		rcall Delay;D0 disponivel
		in r16, PIND
		bst r16, 7
		bld r17, 0
		sts temp_l, r17
;levanta CS
		sbi PORTB, p_CS
		ret

formata_max6675:
;interpreta bits do max6675
;tenta manter maximo de numeros significativos
;se burnout escreve bur
;se maior que cem graus escreve so 1 casa decimal
;valores menores escreve duas casas decimais
;apaga zeros aa esquerda
		lds r16, temp_l
		sbrs r16, 2;testa burnout
		rjmp formata_max6675_1
;burnout escreve burn
		ldi r16, NUMB
		sts dp_m, r16
		ldi r16, LETRAU
		sts dp_c, r16
		ldi r16, LETRAR
		sts dp_d, r16
		ldi r16, LETRAN
		sts dp_u, r16
		rjmp formata_max6675_3
formata_max6675_1:
;monta a parte fracionaria em r20
		clr r20
		lds r16, temp_l
		bst r16, 3
		bld r20, 0
		bst r16, 4
		bld r20, 1
;aritmetica de 16 bits eh feita em r24, r26, r28, r30
;monta valor inteiro em r19(H) e r18(L)
		lds r19, temp_h
		lds r18, temp_l
;elimina os cinco bits iniciais deixando so parte inteira
		lsr r19
		ror r18
		lsr r19
		ror r18
		lsr r19
		ror r18
		lsr r19
		ror r18
		lsr r19
		ror r18
;mostragem de parte fracionaria em disp_d e disp_u
;testa se em zero
		ldi r17, 0x00
		cp r17, r20
		breq fracionariaeh00
		inc r17
		cp r17, r20
		breq fracionariaeh25
		inc r17
		cp r17, r20
		breq fracionariaeh50
;so pode ser 75
		ldi r16, NUM7
		sts dp_d, r16
		ldi r16, NUM5
		sts dp_u, r16
		rjmp montaparteinteira
fracionariaeh00:
		ldi r16, NUM0
		sts dp_d, r16
		sts dp_u, r16
		rjmp montaparteinteira
fracionariaeh25:
		ldi r16, NUM2
		sts dp_d, r16
		ldi r16, NUM5
		sts dp_u, r16
		rjmp montaparteinteira
fracionariaeh50:
		ldi r16, NUM5
		sts dp_d, r16
		ldi r16, NUM0
		sts dp_u, r16
montaparteinteira:
;valor inteiro em r19(H) e r18(L)
;input: R17, R16 = 16 bit value 0 ... 65535
;output: R20, R19, R18, R17, R16 = 5 digits (ASCII)
;cycle: 20 ... 170
;Transfere r19->r17 r18->r16   
        mov r17, r19
		mov r16, r18
;Converte em 5 digitos Ascii
        ldi     r20, -1 + '0'
_bcd1:  inc     r20
        subi    r16, low(10000)         ;-10000
        sbci    r17, high(10000)
        brcc    _bcd1

        ldi     r19, 10 + '0'
_bcd2:  dec     r19
        subi    r16, low(-1000)         ;+1000
        sbci    r17, high(-1000)
        brcs    _bcd2

        ldi     r18, -1 + '0'
_bcd3:  inc     r18
        subi    r16, low(100)           ;-100
        sbci    r17, high(100)
        brcc    _bcd3

        ldi     r17, 10 + '0'
_bcd4:  dec     r17
        subi    r16, -10                ;+10
        brcs    _bcd4

        subi    r16, -'0'
;Converte os digitos de r20 r19 r18 r17 r16 em seus equivalentes de segmento
		subi r20, 0x30
		subi r19, 0x30
		subi r18, 0x30
		subi r17, 0x30
		subi r16, 0x30
		rol r20
		ldi ZH, high(hex2seg<<1)
		ldi ZL, low(hex2seg<<1)
		add ZL, r20
		lpm r20, Z
		rol r19
		ldi ZH, high(hex2seg<<1)
		ldi ZL, low(hex2seg<<1)
		add ZL, r19
		lpm r19, Z
		rol r18
		ldi ZH, high(hex2seg<<1)
		ldi ZL, low(hex2seg<<1)
		add ZL, r18
		lpm r18, Z
		rol r17
		ldi ZH, high(hex2seg<<1)
		ldi ZL, low(hex2seg<<1)
		add ZL, r17
		lpm r17, Z
		rol r16
		ldi ZH, high(hex2seg<<1)
		ldi ZL, low(hex2seg<<1)
		add ZL, r16
		lpm r16, Z
;se temperatura de 4 digitos mostra apenas 4 digitos
;se temperatura de 3 digitos mostra e dp_u=dp_d e faz dp_m, dp_c e dp_d 
;se temperatura de 2 digitos mostra dp_m e dp_c 
;se temperatura de 1 digito apaga dp_m
;ignora r20 dezena de milhar nao existe
		cpi r19, NUM0
		breq mostra3
;mostra 4 digitos
		sts dp_m, r19
		sts dp_c, r18
		sts dp_d, r17
		sts dp_u, r16
		ret
mostra3:
		cpi r18, NUM0
		breq mostra2
		lds r21, dp_d
		sts dp_u, r21
		sts dp_m, r18
		sts dp_c, r17
		sts dp_d, r16
		ret
mostra2:
		sts dp_m, r17
		sts dp_c, r16
		ret
mostra1:
		ldi r21, NOFF
		sts dp_m, r21
		sts dp_c, r16
		ret
formata_max6675_3:
		ret

write_display_tm1637:
;Supoe conteudo a ser escrito em dp_m, dp_c, dp_d, dp_u e dp_bright
;Comeca e termina com CLK e DIO em 1 
		cbi PORTB, p_DIO;;Abaixa DIO indicando START
		rcall Delay
		rcall Delay
;Abaixa CLK
		cbi PORTB, p_CLK
		ldi r16, 0x40
		sts dp_shift, r16;Data Command Setting Write Data Automatic Address Adding Normal Mode
		rcall write_command_tm1637
		rcall write_ack
;Novo protocolo de envio de comando. Sobe Clock
		sbi PORTB, p_CLK
		rcall Delay
;Sobe DIO para forcar start
		sbi PORTB, p_DIO
		rcall Delay
;Abaixa DIO indicando fim de start
		cbi PORTB, p_DIO
		rcall Delay
;Abaixa CLK
		cbi PORTB, p_CLK
		rcall Delay
		ldi r16, 0xc0;Initial Address 0
		sts dp_shift, r16;
		rcall write_command_tm1637
		rcall write_ack
; Milhar
		lds r16, dp_m
		sts dp_shift, r16
		rcall write_command_tm1637
		rcall write_ack
; Centena
		lds r16, dp_c
		sts dp_shift, r16
		rcall write_command_tm1637
		rcall write_ack
; Dezena
		lds r16, dp_d
		sts dp_shift, r16
		rcall write_command_tm1637
		rcall write_ack
; Unidade
		lds r16, dp_u
		sts dp_shift, r16
		rcall write_command_tm1637
		rcall write_ack
;Novo protocolo de envio de comando. Sobe Clock
		sbi PORTB, p_CLK
		rcall Delay
;Sobe DIO para forcar start
		sbi PORTB, p_DIO
		rcall Delay
;Abaixa DIO indicando fim de start
		cbi PORTB, p_DIO
		rcall Delay
;Abaixa CLK
		cbi PORTB, p_CLK
		rcall Delay
		lds r16, dp_bright;Comando Display Control Max Brightness
		ori r16, 0x88
		sts dp_shift, r16
		rcall write_command_tm1637
		rcall write_ack
;Levanta Clock
		sbi PORTB, p_CLK
		rcall Delay
;Levanta DIO forcando start
		sbi PORTB, p_DIO
		rcall Delay
;fim de protocolo
		ret

write_ack:
;DIO em 0 e CLK em 0, deve estar no ciclo de ACK
		rcall Delay
		rcall Delay
;Sobe clock
		sbi PORTB, p_CLK
		rcall Delay
;Retorna com Clock zerado
		cbi PORTB, p_CLK
		rcall Delay
		ret

write_command_tm1637:
;Comeca com CLK em 0 para permitir mudanca de DIO
;Termina com CLK em 0 para permitir ciclo de ACK
;Supoe byte a ser shiftado em dp_shift
		ldi r17, 8
		lds r18, dp_shift
write_command_tm1637_1:
		ror r18
		brbs 0, write_command_tm1637_2
;bit eh 0 replica em DIO
		cbi PORTB, p_DIO
		rjmp write_command_tm1637_3
write_command_tm1637_2:
;bit eh 1 replica em DIO
		sbi PORTB, p_DIO
write_command_tm1637_3:
;da tempo de setup
		rcall Delay
;ativa transicao positiva do CLOCK
		sbi PORTB, p_CLK
		rcall Delay
;Abaixa CLK
		cbi PORTB, p_CLK
		dec r17
		brne write_command_tm1637_1
;Poe 0 em DIO para nao atrapalhar ACK
		cbi PORTB, p_DIO
		ret

;area de tabelas
hex2seg: .DW NUM0, NUM1, NUM2, NUM3, NUM4, NUM5, NUM6, NUM7, NUM8, NUM9, NUMA, NUMB, NUMC, NUMD, NUME, NUMF

.dseg
dp_m: .byte 1
dp_c: .byte 1
dp_d: .byte 1
dp_u: .byte 1
dp_shift: .byte 1
dp_bright: .byte 1
temp_h: .byte 1
temp_l: .byte 1
