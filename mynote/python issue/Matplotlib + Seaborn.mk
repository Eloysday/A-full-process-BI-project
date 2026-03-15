Matplotlib + Seaborn 静态可视化（全场景）
核心定位
离线数据分析/报告专用，静态、高清、适合导出文档，Plotly 的互补方案
1. 基础配置（必写：解决中文乱码）
import matplotlib.pyplot as plt
import seaborn as sns
plt.rcParams["font.sans-serif"] = ["SimHei"]  # 中文
plt.rcParams["axes.unicode_minus"] = False    # 负号
plt.figure(figsize=(12,6))  # 画布大小
2. 全类型图表（业务全覆盖）
# 1. 柱状图（品类销量）
sns.barplot(data=df, x="category", y="volume")
# 2. 箱线图（库存分布/异常值检测）
sns.boxplot(data=df, x="category", y="stock")
# 3. 折线图（时间趋势）
sns.lineplot(data=df, x="date", y="sales")
# 4. 饼图（占比）
df.groupby("category")["sales"].sum().plot(kind="pie")
# 5. 热力图（指标相关性）
corr = df[["volume","sales","stock"]].corr()
sns.heatmap(corr, annot=True)
# 6. 小提琴图（数据分布）
sns.violinplot(data=df, x="category", y="volume")
3. 图表美化与存储
plt.title("销售数据统计")
plt.xlabel("品类")
plt.ylabel("销量")
plt.xticks(rotation=45)
plt.tight_layout()  # 自适应布局
plt.savefig("chart.png", dpi=300)  # 高清保存
plt.show()


st.plotly_chart(px.bar(
