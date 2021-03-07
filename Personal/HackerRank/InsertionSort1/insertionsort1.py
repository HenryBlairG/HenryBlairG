#!/bin/python3

def insertionSort1(n, arr):
    """
    Brute force Demonstartion of de Insert Worst time in O(n) Counting Comparisons
    """
    def shift(p, arr):
        arr[p+1] = arr[p]
        print((n*"{} ")[:-1].format(*arr))
    def insert(x, p, arr):
        arr[p+1] = x
        print((n*"{} ")[:-1].format(*arr))

    if n == 1:
        print((n*"{} ")[:-1].format(*arr))
        return

    numb = arr[-1]
    for i in range(n-2, -2, -1):
        if i == -1:
            insert(numb, i, arr)
        elif arr[i] > numb:
            shift(i, arr)
        else:
            insert(numb, i, arr)
            break


if __name__ == '__main__':
    n = int(input())

    arr = list(map(int, input().rstrip().split()))

    insertionSort1(n, arr)
