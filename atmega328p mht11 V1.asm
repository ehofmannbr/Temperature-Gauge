;
; MHT11.asm
;
.include "m328pdef.inc"

;Definicoes do Modulo Display TM1637
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
#define LETRAN 0x0054;0b01010100;0x54
#define NOFF 0x0000;0b00000000;0x00

; Oscilador 8Mhz - 1uS por instrucao
; Saida de 1Mhz no pino 14 PORTB0 

; TM1637     PIN1 CLK = ATMEGA328 PIN 9 PORTB 6
;            PIN2 DATA = ATMEGA328 PIN 10 PORTB 7 
;            LED = ATMEGA328 PIN 19 PORTB 5

#define p_DIO 7
#define p_CLK 6
#define p_LED 5

; Map MHT11 PIN 1 VCC
;           PIN 2 DATA = ATMEGA328 PIN 13 PORTD 7
;           PIN 3 NC
;           PIN 4 GND

.org 0x00
		jmp start

start:

;inicializacao do display tm1637
		ldi r16, 0xff
		out DDRB, r16	;PORTB saida
		sbi PORTB, p_DIO
		sbi PORTB, p_CLK; DATA e CLK em 1
		cbi PORTB, p_LED; LED Apagado
		cbi PORTB,1;Bit de teste desligado
		ldi r16, NOFF
		sts dp_m, r16
		ldi r16, NUMA
		sts dp_c, r16
		ldi r16, LETRAN
		sts dp_d, r16
		ldi r16, NUMA
		sts dp_u, r16
		ldi r16, 0x04
		sts dp_bright, r16
;inicializacao do MHT11
		ldi r16, 0x10
		sts MCUCR, r16;desliga pull ups internos
        cbi DDRD, 7 ;PORTD 7 entrada pullapada deve ler 1

lupi:	
        rcall le_mht11
;		rcall confere_lemht11
;		rcall formata_lemht11h
;		rcall write_display_tm1637
;		rcall delay3
;		rcall delay3
;		rcall formata_lemht11t
;		rcall write_display_tm1637
;		rcall delay3
;		rcall delay3
;		rcall formata_lemht11checksum
;		rcall write_display_tm1637
		rcall delay3
		rcall delay3
;pisca o LED
		ldi r16, 0x80
		out PINB, r16
		rjmp lupi

le_mht11:
        sbi DDRD, 7 ;PORTD 7 saida
		cbi PORTD, 7;PORTD 7 em 0 por 23ms solicita dado
		rcall Delay25ms
		sbi PORTB,1
		cbi PORTB,1;pisca PORTB1 para analisador logico
		sbi PORTD, 7;PORTD 7 em 1
		ldi r16, 13
Del_1:
		dec r16
		brne Del_1;aguarda 41uS
		cbi DDRD, 7;Retorna para entrada e aguarda resposta
		cbi PORTD,7;Retira influencia da saida 
		nop
		nop
		sbi PORTB,1
		cbi PORTB,1;pisca PORTB1 para analisador logico
;etapa de resposta
le01:	in r16, PIND
		bst r16, 7
		brtc le01;aguarda 54uS de 0
		sbi PORTB,1
		cbi PORTB,1;pisca PORTB1 para analisador logico
le02:	in r16, PIND
		bst r16, 7
		brts le02;aguarda 80uS de response
		sbi PORTB,1
		cbi PORTB,1;pisca PORTB1 para analisador logico
;		ldi r19, 40
;le03:	in r17, PIND; le porta D
;		bst r17, p_DAT; testa bit 7
;		brtc le03;aguarda terminar o 0
;		clr r18;limpa contador de tempo
;le04:	inc r18;incrementa r18
;		in r17, PIND; le porta D
;		bst r17, p_DAT; testa bit 7
;		brts le04;
;mostra r18 no display
;		mov r16, r18
;		swap r16
;		rcall hex2seg
;		sts dp_d, r16
;		mov r16, r18
;		rcall hex2seg
;		sts dp_u, r16
;		clr r16
;		sts dp_m, r16
;		sts dp_c, r16
;		sts int_rh, r16
;		sts dec_rh, r16
;		sts int_temp, r16
;		sts dec_temp, r16
;		sts checksum, r16
        ret

confere_lemht11:
		clr r16
		sts errochecksum, r16
		ret

formata_lemht11t:
		lds r16, int_temp
		swap r16
		rcall hex2seg
		sts dp_m, r16
		lds r16, int_temp
		rcall hex2seg
		sts dp_c, r16
		lds r16, dec_temp
		swap r16
		rcall hex2seg
		sts dp_d, r16
		lds r16, dec_temp
		rcall hex2seg
		sts dp_u, r16
		ret

formata_lemht11h:
		lds r16, int_rh
		swap r16
		rcall hex2seg
		sts dp_m, r16
		lds r16, int_rh
		rcall hex2seg
		sts dp_c, r16
		lds r16, dec_rh
		swap r16
		rcall hex2seg
		sts dp_d, r16
		lds r16, dec_rh
		rcall hex2seg
		sts dp_u, r16
		ret

formata_lemht11checksum:
		ldi r16, NOFF
		sts dp_m, r16
		sts dp_c, r16
		lds r16, checksum
		swap r16
		rcall hex2seg
		sts dp_d, r16
		lds r16, checksum
		rcall hex2seg
		sts dp_u, r16
		ret

hex2seg:
;nibble hexa em R16, retorna byte do segmento
		andi r16, 0x0f
		clc;limpa carry antes do rol
		rol r16
		clr r17
		ldi ZH, high(hex2segt<<1)
		ldi ZL, low(hex2segt<<1)
		add ZL, r16
		adc ZH, r17
		lpm r16, Z
		ret

Delay:
;200uS Carregar com 28
		ldi r20, 28
Delay_1:
		dec r20
		brne Delay_1
		ret

Delay25ms:
;Delay de 2 niveis para 23 ms
		ldi r20, 125
Delay25_1:
		ldi r21, 60
Delay25_2:
		dec r21
		brne Delay25_2
		dec r20
		brne Delay25_1
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
hex2segt: .DW NUM0, NUM1, NUM2, NUM3, NUM4, NUM5, NUM6, NUM7, NUM8, NUM9, NUMA, NUMB, NUMC, NUMD, NUME, NUMF

.dseg
;Variaveis do display TM1637
dp_m: .byte 1
dp_c: .byte 1
dp_d: .byte 1
dp_u: .byte 1
dp_shift: .byte 1
dp_bright: .byte 1
;Variaveis do Sensor MHT11
int_rh: .byte 1
dec_rh: .byte 1
int_temp: .byte 1
dec_temp: .byte 1
checksum: .byte 1
errochecksum: .byte 1
