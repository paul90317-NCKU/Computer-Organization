# assembler
## 記憶體儲存
已知記憶體儲存: msb <-> lsb
* Big Endian  
lower address <-> higher address  
依照位置來存，符合直覺，MIPS 使用該存法。  
* Small Endian  
higher address <-> lower address  
好處左而右都是由大到小，但是數字超過 1B，Bytes 要由右而左，且之中的 bit 右由左而右看。
* MIPS 存法  
MSB  low adderss  
^  
|  
v  
LSB  high address  
