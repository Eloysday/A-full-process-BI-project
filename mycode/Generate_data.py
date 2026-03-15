import pymysql,random,string
from datetime import datetime
import time
def write_data():
    zhanghao = {
        "host": "", 
        "user": "", 
        "password": "", 
        "database": "",  
        "charset": ""}
    conn = pymysql.connect(**zhanghao)
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    try:
        cursor = conn.cursor()
        cursor.execute("TRUNCATE TABLE refresh_data;")
        sql = """
        INSERT INTO orderinfo (orderid, user, category, prices, volume, stock, order_time,order_channel)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """
        #prepare cross table query for user_info
        data = generate_realtime_data()
        cursor.executemany(sql, data)
        conn.commit()
        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] 数据刷新成功 | 共{len(data)}条记录")
    except Exception as e:
        conn.rollback()
        print(f"数据刷新失败：{str(e)}")
    finally:
        cursor.close()
        conn.close()

def generate_realtime_data():

    CATEGORIES = ["Product A", "Product B", "Product C", "Product D", "Product E","Product F","Product G"]
    CATEGORIES_PRICE = {'Product A': 50, 'Product B': 51, 'Product C': 52, 'Product D': 54, 'Product E': 57, 'Product F': 64, 'Product G': 72}
    start_ts = 1735689600  # 2025-01-01 00:00:00
    end_ts = 1751375999    # 2025-12-31 23:59:59
    CHANNELS = ['Taobao', 'PDD', 'Jingdong']

    data = []
    for _ in range(100000):
        orderid = f"{random.randint(100000,999999)}{''.join(random.choices(string.ascii_lowercase, k=6))}"
        user = f"{''.join(random.choices(string.ascii_lowercase, k=2))}{random.randint(0,20)}"
        category = random.choice(CATEGORIES)
        prices = CATEGORIES_PRICE[category]
        volume = random.randint(300, 1200)
        stock = random.randint(50, 500)
        order_time = datetime.fromtimestamp(random.randint(start_ts, end_ts)).strftime("%Y-%m-%d %H:%M:%S")
        order_channel = random.choice(CHANNELS)
        data.append((
            orderid, user, category, prices, 
            volume, stock, order_time, order_channel
        ))
    
    print(f"生成随机数据{len(data)}条")
    return data

while True:
    write_data()
    time.sleep(30)
