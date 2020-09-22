import os, time, sys, multiprocessing as mp


def deleteFiles(file):
    os.system('azcopy remove "https://jonahmlstorage.blob.core.windows.net/projectcanary/'+file+'?se=2020-10-18T20%3A21%3A09Z&sp=rdl&sv=2018-03-28&sr=c&sig=eQQ4HnMUdgu05pTSD%2B9vaEaWTQQrR%2Bw%2Fnw9ozItjvFY%3D" --recursive')


if __name__ == "__main__":
    start_time = time.time()
    fileList = os.listdir("D:\\YourFolder\\")
    a_pool = mp.Pool(processes=8)
    result = a_pool.map(deleteFiles, fileList)
