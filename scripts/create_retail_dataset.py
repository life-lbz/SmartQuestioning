"""Deterministic small-retailer fixture and portable UTF-8 MySQL export.

Creates NEW databases only. Does not overwrite the existing demo database.
Requires MYSQL_ROOT_PASSWORD; never exports credentials or platform accounts.
"""
from __future__ import annotations
from datetime import date,datetime,time,timedelta
from decimal import Decimal, ROUND_HALF_UP
from pathlib import Path
import hashlib,json,os,random,subprocess
import pymysql

ROOT=Path(__file__).resolve().parents[1]
TABLES=('regions','categories','products','customers','orders','order_items')
DATABASE='data_agent_retail_20261030'

def build_data():
    rng=random.Random(20261030)
    regions=[(1,'华东'),(2,'华南'),(3,'华北'),(4,'西部')]
    categories=[(1,'办公设备'),(2,'数码配件'),(3,'家居用品'),(4,'食品饮料'),(5,'运动户外')]
    names=['轻薄笔记本','商务显示器','机械键盘','无线鼠标','移动硬盘','降噪耳机','多口充电器','高清摄像头','护眼台灯','人体工学椅','收纳套装','恒温水杯','精品咖啡豆','每日坚果','低糖麦片','气泡饮料','瑜伽垫','城市背包','运动手环','折叠水壶']
    prices=[4299,899,169,59,399,299,89,159,129,699,39,79,68,39.9,32.9,24.9,69,159,199,39]
    weights=[.15,.4,3,6,1.2,1.5,4,1.2,3,.5,7,5,8,12,8,8,3,2,1,4]
    products=[(i+1,name,i//4+1,Decimal(str(prices[i])),(Decimal(str(prices[i]))*Decimal(str(rng.uniform(.56,.76)))).quantize(Decimal('.01')),1) for i,name in enumerate(names)]
    customers=[]
    for i in range(1,638):
        registered=date(2024,10,1)+timedelta(days=int(rng.triangular(0,700,200)))
        customers.append((i,f'演示客户{i:04d}',rng.choices([1,2,3,4],[42,28,18,12])[0],rng.choices(['个人','小微企业','中型企业'],[84,14,2])[0],registered))
    start=date(2025,1,1);end=date(2026,10,29)
    days=[start+timedelta(days=i) for i in range((end-start).days+1)]
    day_weights=[(1+(d-start).days*.0008)*(1.5 if d.month in [6,11,12] else .78 if d.month==2 else 1)*(1.1 if d.weekday()>=5 else 1) for d in days]
    drafts=[]
    for i in range(3864):
        customer=customers[i] if i<637 else rng.choices(customers,weights=[1+(637-c[0])/190 for c in customers])[0]
        eligible=[(d,w) for d,w in zip(days,day_weights) if d>=customer[4]]
        d=rng.choices([x[0] for x in eligible],[x[1] for x in eligible])[0]
        at=datetime.combine(d,time(rng.choices(list(range(8,23)),[1,2,4,5,6,5,4,5,6,7,8,7,5,3,1])[0],rng.randrange(60),rng.randrange(60)))
        status=rng.choices(['PAID','REFUNDED','CANCELLED'],[87,4,9])[0]
        if d>=end-timedelta(days=2) and rng.random()<.18: status='PENDING'
        selected=set()
        count=rng.choices([1,2,3],[64,29,7])[0]
        while len(selected)<count: selected.add(rng.choices(range(20),weights)[0])
        items=[];amount=Decimal('0')
        for j in sorted(selected):
            qty=rng.choices([1,2,3],[85,12,3])[0]
            discount=rng.choices([Decimal('0'),Decimal('.05'),Decimal('.10')],[72,20,8])[0]
            price=products[j][3]
            amount+=(price*qty*(1-discount)).quantize(Decimal('.01'),rounding=ROUND_HALF_UP)
            items.append((j+1,qty,price,discount))
        channel=rng.choices(['官网','小程序','线下门店','企业采购'],[22,44,30,4])[0]
        paid=at+timedelta(minutes=rng.randint(1,75)) if status in ['PAID','REFUNDED'] else None
        drafts.append((at,customer[0],status,paid,amount,channel,items))
    orders=[];items=[]
    for i,row in enumerate(sorted(drafts,key=lambda x:x[0]),1):
        at,cid,status,paid,amount,channel,lines=row
        orders.append((i,f'RT{at:%Y%m%d}{i:06d}',cid,status,at,paid,amount,channel))
        for line in lines: items.append((len(items)+1,i,*line))
    return dict(zip(TABLES,[regions,categories,products,customers,orders,items]))

def audit(c,db,strict=True):
    with c.cursor() as q:
        q.execute(f'USE `{db}`')
        counts={};hashes={}
        for t in TABLES:
            q.execute(f'SELECT * FROM `{t}` ORDER BY id');rows=q.fetchall()
            counts[t]=len(rows);hashes[t]=hashlib.sha256(json.dumps(rows,default=str,ensure_ascii=False).encode()).hexdigest()
        q.execute("SELECT COUNT(*),ROUND(SUM(amount),2),ROUND(AVG(amount),2) FROM orders WHERE status='PAID'")
        paid,revenue,basket=q.fetchone()
        checks={
          'order_amount_mismatch':"SELECT COUNT(*) FROM orders o JOIN (SELECT order_id,SUM(ROUND(quantity*unit_price*(1-discount),2)) total FROM order_items GROUP BY order_id) i ON o.id=i.order_id WHERE o.amount<>i.total",
          'orders_before_registration':'SELECT COUNT(*) FROM orders o JOIN customers c ON c.id=o.customer_id WHERE DATE(o.created_at)<c.registered_at',
          'payment_before_order':"SELECT COUNT(*) FROM orders WHERE paid_at<created_at",
          'future_orders':"SELECT COUNT(*) FROM orders WHERE created_at>='2026-10-30'",
          'old_pending':"SELECT COUNT(*) FROM orders WHERE status='PENDING' AND created_at<'2026-10-27'",
        }
        results={}
        for key,sql in checks.items():q.execute(sql);results[key]=q.fetchone()[0]
        if strict: assert not any(results.values()),results
        q.execute("SELECT DATE_FORMAT(created_at,'%Y-%m'),COUNT(*),ROUND(SUM(CASE WHEN status='PAID' THEN amount ELSE 0 END),2) FROM orders GROUP BY 1 ORDER BY 1")
        monthly=q.fetchall()
    return {'database':db,'counts':counts,'hashes':hashes,'paid_orders':paid,'paid_revenue':str(revenue),'paid_average_order':str(basket),'checks':results,'monthly':monthly}

def main():
    data=build_data()
    c=pymysql.connect(host='127.0.0.1',user='root',password=os.environ['MYSQL_ROOT_PASSWORD'],charset='utf8mb4',autocommit=True)
    out=ROOT/'database/retail_demo_20261030.sql'
    with c.cursor() as q:
        q.execute('SHOW DATABASES');existing={x[0] for x in q.fetchall()}
        assert DATABASE not in existing and DATABASE+'_verify' not in existing,'Refusing to overwrite an existing database'
        baseline=audit(c,'data_agent_demo',strict=False)
        parts=['-- Synthetic small-retailer demo. UTF-8. MySQL 8.0+.\n-- Import into a NEW EMPTY database; no users, secrets, DROP or TRUNCATE.\n-- Cutoff 2026-10-29; seed 20261030.\nSET NAMES utf8mb4;']
        for t in TABLES:
            q.execute(f'SHOW CREATE TABLE data_agent_demo.`{t}`');parts.append(q.fetchone()[1]+';')
        parts.append('START TRANSACTION;')
        for t in TABLES:
            fmt=f'INSERT INTO `{t}` VALUES ('+','.join(['%s']*len(data[t][0]))+');'
            parts.extend(q.mogrify(fmt,row) for row in data[t])
        parts.append('COMMIT;')
        payload=('\n\n'.join(parts)+'\n').encode('utf-8')
        out.write_bytes(payload)
        mysql=r'D:\phpstudy_pro\Extensions\MySQL8.0.12\bin\mysql.exe'
        env={**os.environ,'MYSQL_PWD':os.environ['MYSQL_ROOT_PASSWORD']}
        reports=[]
        for db in [DATABASE,DATABASE+'_verify']:
            q.execute(f'CREATE DATABASE `{db}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci')
            result=subprocess.run([mysql,'-h127.0.0.1','-uroot','--default-character-set=utf8mb4',db],input=out.read_bytes(),capture_output=True,env=env)
            assert result.returncode==0,result.stderr.decode(errors='replace')
            reports.append(audit(c,db))
        assert reports[0]['hashes']==reports[1]['hashes'],'Migration round-trip differs'
        assert audit(c,'data_agent_demo',strict=False)['hashes']==baseline['hashes'],'Original database changed'
        q.execute(f"GRANT SELECT, SHOW VIEW ON `{DATABASE}`.* TO 'data_agent_ro'@'127.0.0.1'")
    report={'BASELINE':baseline,'MODIFIED':reports[0],'SQL_REIMPORT':reports[1],'original_database_unchanged':True,'sql_path':str(out),'sql_sha256':hashlib.sha256(out.read_bytes()).hexdigest(),'sql_bytes':len(payload)}
    p=ROOT/'database/retail_demo_20261030.validation.json';p.write_text(json.dumps(report,default=str,ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps({'path':str(out),'bytes':len(payload),'revenue':reports[0]['paid_revenue'],'average_order':reports[0]['paid_average_order'],'counts':reports[0]['counts'],'checks':reports[0]['checks'],'import_verified':True},ensure_ascii=False))
    c.close()

if __name__=='__main__':main()
