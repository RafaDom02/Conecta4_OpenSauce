all: conecta.exe
conecta.exe: conecta.obj
 tlink /v conecta
conecta.obj: conecta.asm 
 tasm /zi conecta.asm