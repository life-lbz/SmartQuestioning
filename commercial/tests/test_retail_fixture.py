from decimal import Decimal, ROUND_HALF_UP
from datetime import date
from scripts.create_retail_dataset import build_data

def test_retail_data_is_consistent_and_repeatable():
    data=build_data()
    assert data==build_data()
    assert len(data['orders'])==3864 and len(data['customers'])==637
    registered={row[0]:row[4] for row in data['customers']}
    totals={}
    for _,order,product,quantity,price,discount in data['order_items']:
        assert 1<=product<=20 and quantity>0
        totals[order]=totals.get(order,Decimal(0))+(price*quantity*(1-discount)).quantize(Decimal('.01'),rounding=ROUND_HALF_UP)
    for key,_,customer,status,created,paid,amount,_ in data['orders']:
        assert registered[customer]<=created.date()<date(2026,10,30)
        assert amount==totals[key]
        assert paid is None or paid>=created
        if status=='PENDING': assert created.date()>=date(2026,10,27)
    revenue=sum(row[6] for row in data['orders'] if row[3]=='PAID')
    assert revenue==Decimal('505476.56')
