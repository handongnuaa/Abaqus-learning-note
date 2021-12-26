# Abaqus学习笔记
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
#### 1. 符号常量(symbolic constants)
使用Abaqus内置符号常量需要载入***abaqus-Constants***模块，具体如下：

(1) *from abaqusConstants import **    #载入符号常量模块中的**所有符号常量**

(2) *from abaqusConstants import UNIFORM, ISOTROPIC*   #载入符号常量模块中的**指定符号常量**

(3) *from abaqusConstants import (UNIFORM, ISOTROPIC, FINER, QUAD)*   #载入符号常量模块中的**指定符号常量**, Python推荐的方式

创建符号常量则需要***symbolicConstants***模块，具体如下：

*import symbolicConstants*
