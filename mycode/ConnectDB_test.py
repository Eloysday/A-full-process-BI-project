import pymysql

def getdata():
    zhanghao = {
        "host": "", 
        "user": "", 
        "password": "", 
        "database": "",  
        "charset": ""}

    conn = pymysql.connect(**zhanghao)
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    print('conn good')
    cursor.execute("SELECT COUNT(*) from refresh_data")

    feedback = cursor.fetchall()
    cursor.close()
    conn.close()
    return feedback
  
print('feedback good')
df = pd.DataFrame(getdata).dropna()
print(df)
