1:NANDFLASH 代码量小于4K,前4K会复制到片内内存的SRAM(上电后硬件自动实现)
2:NANDFLASH 代码量大于4K后,前4K会会复制到SRAM,且这4K代码要实现更大的程序从nandflash读出来放入SDRAM中

NANDFLASH只有数据总线,没有地址总线
而我们的SDRAM,DM9000(网卡),有地址总线,接到了2440
结论:NANDFLASH和SDRAM(0x3000 0000 -- 0x3400 0000),DM9000,RAM(0-4096),还有寄存器,如GPFCON(0x5600 0050)的CPU的寻址方式不同:
后者的地址是CPU发出来的,属于CPU统一编址,他们的地址是CPU可见的
前者的地址比如说0和CPU的0地址不是同一个概念

我们2440的NANDFLASH 的容量为256M(我们是大页的 NANDFLASH,所谓大页是一页2K(没有计算OOB区域))
NANDFLASH:每页: 2K字节+ OOB区域(64byte)
          1块:128K,由64页组成
NANDFLASH的编址:
注意:OOB区域大多数情况下是不参与编址,比如说读NANDFLASH 2049这个地址的数据,则是读第二页的数据(OOB不参与编址)
     如果非要强调读某一页的2049的时候,就是指该页的OOB区域
	 
如何访问NANDFLASH(对比SDARM(CPU统一编址)):
访问内存 SDRAM
1:发出地址信号
2:传输数据
访问NANDFLASH
发出命令(告诉 NANDFLASH 我将要对该地址进行读还是写还是其他),再发出地址(对哪个地址进行操作),再发出数据

从硬件上访问 NANDFLASH:比如说读写某个地址的数据
1:发出命令:使能 NANDFLASH 上CLE引脚(告诉 NANDFLASH 我是要读数据还是要写数据或者擦除) , 并将命令发送到 NANDFLASH 数据总线上
2:发出地址:使能 NANDFLASH 上ALE引脚,并将要访问的地址发送到NANDFLASH 数据线上
3:传输数据:CLE 和 ALE 都无效,如果是读,则直接将 NANDFLASH 上的数据取出来,如果写数据,则将数据放到 NANDFLASH 数据线上

2440实际上是怎么访问 NANDFLASH:(2240对以上的硬件步骤进行了精简)
1:发出命令:将命令直接写入 NFCMMD
2:发出地址:将地址直接写入 NFADDR
3:传输数据:.............. NFDATA
4:读取状态(因为擦除不可能一瞬间完成) .........................NFSTAT


Q1:发出命令时不可以直接如下操作
s3c2440nand->NFCMD = cmd;
由于nandflash只有8根数据线,而且从数据手册上看到NFCMD只有低8bit有效,因此要进行数据类型转换
volatile unsigned char *p = (volatile unsigned char *)&s3c2440nand->NFCMD;
*p = cmd;


