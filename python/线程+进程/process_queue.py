# coding=utf-8
# 进程之间的数据共享通过Queue（队列）实现
import time
import multiprocessing
# 创建队列这个对象（先进先出）
q = multiprocessing.Queue(3)
# 添加数据
q.put('111')

q.put(2222)

q.put([11,22,333])
# 读取数据
q.get()

# 如果数据都读完，会以报错的形式告诉你数据读完了
q.get_nowait()

# 判断队列是否满了
q.full()
# 判断队列是否为空
q.empty()