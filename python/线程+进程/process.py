# coding=utf-8
import time
import multiprocessing
from multiprocessing import process

def sing(data):
    for i in range(data):
        print("正在唱歌")
        time.sleep(1)


def dance():
    for i in range(5):
        print("正在跳舞")
        time.sleep(1)


def main():
    data=5
    t1 = multiprocessing.Process(target=sing,args=(data,))
    t2 = multiprocessing.Process(target=dance)

    t1.start()
    t2.start()
if __name__ == '__main__':
    main()
# 线程与进程的区别：
# 线程执行开销小，但不利于资源的管理和保护；而进程正相反
# 线程不能独立执行，必须依存在进程中，进程是资源分配的单位，线程是 将来操作系统资源调度的单位
# 线程之间共享全局变量  进程之间全局变量是相互独立的  但进程之间的数据共享通过Queue（队列）实现
