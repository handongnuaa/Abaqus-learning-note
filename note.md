# Abaqus学习笔记
[1. Abaqus内核脚本基础](#abaqus内核脚本基础)  
[1.1 数据类型](#数据类型)  
[1.2 获取帮助](#获取帮助)    
[1.3 脚本日志](#脚本日志)   
[1.4 对象结构](#对象结构)   

[2. 前处理](#前处理)  
[2.1 Sketch模块](#sketch模块)  



Author: Dong HAN

E-mail: dong.han@nuaa.edu.cn

College of Energy and Power Engineering, Nanjing University of Aeronautics and Astronautics, Nanjing 210016, China
## Python版本信息查询
在Abaqus Command中输入“abaqus python”；

得到：“Python 2.7.15 for Abaqus 2020 (default, Aug 31 2019, 06:41:47) [MSC v.1916 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license" for more information.”

可知Abaqus2020对应的python版本为2.7.15。

## 1. Abaqus内核脚本基础
### 1.1 数据类型
#### 1.1.1 符号常量
使用Abaqus内置符号常量需要载入***abaqus-Constants***模块，具体如下：

(1) *from abaqusConstants import* *    \#载入符号常量模块中的**所有符号常量**  
(2) *from abaqusConstants import UNIFORM, ISOTROPIC*   \#载入符号常量模块中的**指定符号常量**  
(3) *from abaqusConstants import (UNIFORM, ISOTROPIC, FINER, QUAD)*   #载入符号常量模块中的**指定符号常量**, **Python推荐的方式**

创建符号常量则需要***symbolicConstants***模块，具体如下：

*import symbolicConstants*   
*SNIPER = symbolicConstants.SymbolicConstants('SNIPER')*  
*CRYSTAL_MAIDEN = symbolicConstants.SymbolicConstants('CRYSTAL_MAIDEN')*

每个符号常量包含名字(name)属性和内部序号(\_id)属性(取决于符号变量创建次序)，可以用getText()，getId()方法获得。在Abaqus模块中类似符号变量，但实际是其他类型，例如：

*abaqus.ABASOLUTE_ZERO_CELSIUS*  \#摄氏温标绝对零度

#### 1.1.2 布尔值
Abaqus模块和*abaqusConstants*模块中包含*ON/OFF*, *TRUE/FALSE*两组布尔值：*ON/OFF*是Abaqus自定义布尔类型；*TRUE/FALSE*是python的*True/False*的别名，为布尔型。脚本中用到ON, OFF的地方，都可以用*True, TRUE, False, FALSE*代替。

#### 1.1.3 仓库
Repository仓库对象是储存某个类的多个对象的容器，与Python的字典类型相似，均为映射型的数据类型。不同之处是，Repository只能通过构造函数实现构造。仓库对象有5中基本方法，包括：

(1) *Repository.changeKey(fromName,toName)* **\#改键的名字**  
(2) *Repository.has_key(keyName)*  **\#return ->bool 含有某键**  
(3) *Repository.keys()*  **\# return-> 键的列表**  
(4) *Repository.values()*  **\# return-> 键-值对象列表**  

通常，仓库对象的keys(), values()和items()方法返回的是无序列表，但是部分仓库对象会返回有序列表，如steps分析步仓库。除了这5种基本方法，部分仓库对象还有其他方法。

仓库对象的方式示例：  
mdb.models  \#**模型仓库** ps. 之前已经导入了Mdb类，并实例化了一个对象，名为mdb，见问题(1)。  
m=mdb.Model['Model-demo'] \#用mdb对象的**Model()方法(构造函数)**构造了一个**新的模型**，并添加到mdb对象的**models属性**中，返回Model对象。

m.parts  \#**部件仓库**  
p=m.Part(name='demo',dimensionality=THREE_D,type=DEFORMABLE_BODY)  \#用m对象(Model类)中的**Part()**方法构造了一个Part类的对象，及一个实例部件，添加到Model类的实例化对象——m的parts属性中，并返回一个Part类的实例化对象，并赋值给p。  

m.parts.changeKey(fromName='demo',toName='Part-1') \#用仓库中的changeKey方法重命名仓库中的对象。

del p \#删除引用变量p，但是不能删除被引用的对象——m.parts['Part-1']。

del m.parts['Part-1'] \#删除了仓库(Repository)中的对象。  

'Part-1' in m.parts \#判断是否含有键——'Part-1'。  
m.parts.has_key('Part-1')

### 1.2 获取帮助
一方面，可以从**Abaqus Scripting Reference Guide**获得脚本接口的帮助信息；另一方面，可通过对象**内建属性**、**help函数**、**textRepr模块**获取帮助。

#### 1.2.1 内建属性
大多数Abaqus对象都有\_ \_method\_ \_属性和\_ \_members\_ \_属性，分别为该对象的方法列表和属性列表，使用方法：  
\>\>\>mdb.\_ \_methods\_ \_  
\>\>\>mdb.\_ \_members\_ \_

可使用dir()函数查看Abaqus对象的所有成员，使用方法：  
\>\>\>dir(mdb)  

Abaqus对象的方法大都含有简短的\_ \_doc\_ \_说明，可通过print命令查看，使用方法：  
\>\>\>print mdb.saveAs.\_ \_doc\_ \_ \#查看mdb对象的saveAs方法的说明。  
\>\>\>print mdb.Model.\_ \_doc\_ \_ \#查看mdb对象的Model函数的说明。

#### 1.2.2 help函数
Python的help函数无法从Abaqus的CLI执行，包含help函数的脚本文件也无法从CLI执行，通过FILE->Run Script···执行包含help函数的脚本文件时，将会报错。

包含help函数的脚本只能通过noGUI模式执行，具体的：  
abaqus cae noGUI=kernelHelper.py

#### 1.2.3 textRepr模块
Abaqus提供了textRepr模块用于打印Abaqus对象信息。textRepr模块可以应用于abaqus python环境、kernel脚本、GUI脚本。

## 1.3 脚本日志
Abaqus脚本日志分为replay(rpy)文件和journal(jnl)文件。  

rpy文件会即时记录CAE界面操作，文件名一般为abaqus.rpy，位于启动Abaqus/CAE或Abaqus/Viewer时的工作目录下。在CLI窗口输入**getReplayFileName()**可查看当前rpy文件名；输入**getStartupDir()**可查看启动目录，rpy文件位于此目录。这两个函数都在abaqus模块中。

jnl文件在保存cae文件(saveAs或save)时候才会生效。文件名和存储位置同cae文件，只记录各种建模命令。保存命令本身不会被记录，只会将上次保存后的命令写入jnl文件。



## 1.4 对象结构
##### 1.4.1 Mdb对象
Mdb对象用于组织模型，Abaqus/CAE只能存在一个Mdb对象，所有建模操作都在此对象下进行。建模过程中常用的仓库的访问如下：

\# 几何模型&有限元模型  
mdf.models \#模型  
mdb.models['Model-1'].sketches \#草图  
mdb.models['Model-1'].sketches['DEMO'].geometry \#草图几何对象  
mdb.models['Model-1'].parts \#部件  
mdb.models['Model-1'].parts['Part-1'].features \#特征

mdb.models['Model-1'].parts['Part-1'].elements \#单元  
mdb.models['Model-1'].parts['Part-1'].nodes \#节点  

mdb.models['Model-1'].parts['Part-1'].sets \#集合  

\# 材料  
mdb.models['Model-1'].materials

\# 截面  
mdb.models['Model-1'].sections

\# 装配  
mdb.models['Model-1'].rootAssembly.instances \#装配体  
mdb.models['Model-1'].rootAssembly.sets \#装配集  
mdb.models['Model-1'].rootAssembly.surfaces \#装配面  

\# 分析步  
mdb.models['Model-1'].steps  

......  

\# 相互作用  
mdb.models['Model-1'].interactions  

\# 约束  
mdb.models['Model-1'].constrations

\# 边界条件  
mdb.models['Model-1'].boundaryConditions

\# 载荷  
mdb.models['Model-1'].loads

##### 1.4.2 Odb对象
Odb对象用于组织计算结果，在Abaqus/CAE中可打开多个Odb对象，每个对象对应一个ODB文件。

##### 1.4.3 Session对象
Session对象用于组织XAE绘画，常用的仓库访问路径如下：

sssion.xyPlots \#XYPlot绘图  
session.ciews \#视图'Front' 'Back'  
session.xyDataObjects \#XYData对象  
session.charts \#图表  
session.curves \#曲线  
...

## 2 前处理
### 2.1 Skectch模块
#### 2.1.1 草图对象
ConstrainedSketch草图对象的创建方法有三种，均会返回草图对象，并添加到Model模型对象的sketches仓库中，语法如下：

\#创建草图  
mdb.models[name].ConstrainedSketch  
(name, \#名字  
sheetSize, \#草图网格尺寸  
gridSpacing, \#网格间隔  
transform=(1,0,0, 0,1,0, 0,0,1, 0,0,0)) \#坐标变换

\#复制草图  
mdb.models[name].ConstrainedSketch  
(name,  \#草图名称   
  objectToCopy) \#被复制的草图对象

\#从文件创建草图  
mdb.models[name].ConstrainedSketchFromGeometryFile  
(name, \#名字  
  geometryFile) \#AcisFile对象，文件中的几何对象将会被转换到XY平面内。

创建草图示例：  
m=mdb.models['Model-1']  
s1=m.ConstrainedSketch('sketch1',200.0) \#脚本建模不需要人去看图，因此无需gridSpacing  
s2=m.ConstrainedSketch(name='sketch2',sheetSize=200.0,gridSpacing=2)
s3=m.ConstrainedSketch(name='sketch2',sheetSize=200.0,gridSpacing=2,  
transform=(0,1,0,0,0,1,1,0,0,0,0,0))

草图对象有geometry, vertices, dimensions, constraints等属性，分别为几何对象、顶点、尺寸、约束仓库，这4个仓库的键均为整数。geometry和vertices仓库具有findAt(coordinates)方法，可以查找过某个点的几何对象，使用示例：

s=mdb.models['Model-1'].sketches['demoSketch']
s.geometry.findAt((1,1))
s.geometry.findAt(coordinates=[0,1])
s.geometry.findAt(coordinates=(0,0))
s.vertices.findAt([10,0])
s.vertices.findAt(coordinates=[10,0])

#### 2.1.2 绘图命令

## 问题记录
(1) 什么是mdb对象？  

Abaqus中有三大对象: Session, Mdb, Odb。可通过：“*from abaqus import **”命令载入并创建session, mdb和odb这三个对象。Mdb对象包括两大对象：jobs和models对象。
