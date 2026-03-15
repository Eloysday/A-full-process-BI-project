参数名称	类型	可选值 / 可调区间	默认值	极简备注
1. seasonality_mode	枚举（固定选）	additive  multiplicative	additive	二选一
2. yearly_seasonality	布尔（开关）	True  False	True	开 / 关
3. weekly_seasonality	布尔（开关）	True  False	True	开 / 关
4. daily_seasonality	布尔（开关）	True  False	False	开 / 关
5. changepoint_prior_scale	数值（可调）	0.001 ~ 0.5  常用：0.01 / 0.05 / 0.1	0.05	趋势灵活度
6. seasonality_prior_scale	数值（可调）	1 ~ 30  常用：5 / 10 / 15 / 20	10	季节性强度
7. holidays_prior_scale	数值（可调）	1 ~ 30  常用：3 / 10 / 15	10	节假日强度
