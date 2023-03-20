# coding=utf-8
import time
import threading

def sing():
    for i in range(5):
        print("正在唱歌")
        time.sleep(1)


def dance():
    for i in range(5):
        print("正在跳舞")
        time.sleep(1)


def main():
    t1=threading.Thread(target=sing)
    t2 = threading.Thread(target=dance)

    t1.start()
    t2.start()
    lengh = len(threading.enumerate())  # 线程数
    print(lengh)

if __name__ == '__main__':
    main()
    lengh = threading.enumerate()  # 线程
    print(lengh)
