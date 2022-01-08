# Abaqus学习笔记
[1. Python版本信息查询](#python版本信息查询)  
[2. Abaqus内核脚本](#abaqus内核脚本)  
[2.1 数据类型](#数据类型)  
[2.1.1 符号常量](#1-符号常量)  
[2.1.2 布尔值](#2-布尔值)


Author: Dong HAN

E-mail: handong_nuaa@163.com

College of Energy and Power Engineering, Nanjing University of Aeronautics and Astronautics, Nanjing 210016, China
## Python版本信息查询
在Abaqus Command中输入“abaqus python”；

得到：“Python 2.7.15 for Abaqus 2020 (default, Aug 31 2019, 06:41:47) [MSC v.1916 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license" for more information.”

可知Abaqus2020对应的python版本为2.7.15。

## Abaqus内核脚本
### 数据类型
#### 1. 符号常量
使用Abaqus内置符号常量需要载入***abaqus-Constants***模块，具体如下：

(1) *from abaqusConstants import* *    #载入符号常量模块中的**所有符号常量**  
(2) *from abaqusConstants import UNIFORM, ISOTROPIC*   #载入符号常量模块中的**指定符号常量**  
(3) *from abaqusConstants import (UNIFORM, ISOTROPIC, FINER, QUAD)*   #载入符号常量模块中的**指定符号常量**, **Python推荐的方式**

创建符号常量则需要***symbolicConstants***模块，具体如下：

*import symbolicConstants*   
*SNIPER = symbolicConstants.SymbolicConstants('SNIPER')*  
*CRYSTAL_MAIDEN = symbolicConstants.SymbolicConstants('CRYSTAL_MAIDEN')*

每个符号常量包含名字(name)属性和内部序号(\_id)属性(取决于符号变量创建次序)，可以用getText()，getId()方法获得。在Abaqus模块中类似符号变量，但实际是其他类型，例如：

*abaqus.ABASOLUTE_ZERO_CELSIUS*  #摄氏温标绝对零度

#### 2. 布尔值
Abaqus模块和*abaqusConstants*模块中包含*ON/OFF*, *TRUE/FALSE*两组布尔值：*ON/OFF*是Abaqus自定义布尔类型；*TRUE/FALSE*是python的*True/False*的别名，为布尔型。脚本中用到ON, OFF的地方，都可以用*True, TRUE, False, FALSE*代替。

#### 3. 仓库
Repository仓库对象是储存某个类的多个对象的容器，与Python的字典类型相似，均为映射型的数据类型。不同之处是，Repository只能通过构造函数实现构造。仓库对象有5中基本方法，包括：

(1) *Repository.changeKey(fromName,toName)* **#改键的名字**  
(2) *Repository.has_key(keyName)*  **#return ->bool 含有某键**  
(3) *Repository.keys()*  **# return-> 键的列表**  
(4) *Repository.values()*  **# return-> 键-值对象列表**  

通常，仓库对象的keys(), values()和items()方法返回的是无序列表，但是部分仓库对象会返回有序列表，如steps分析步仓库。除了这5种基本方法，部分仓库对象还有其他方法。

仓库对象的方式示例：

mdb.models #模型仓库  
m=mdb.Model['Model-demo'] #用mdb对象的Model()方法创建了一个新的模型，并添加到mdb对象的models属性中，返回Model对象

## 问题记录
(1) 什么是mdb对象？  

Abaqus中有三大对象: Session, Mdb, Odb。可通过：“*from abaqus import **”命令载入并创建session, mdb和odb这三个对象。Mdb对象包括两大对象：jobs和models对象。
