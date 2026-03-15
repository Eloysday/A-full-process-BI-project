import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

df = pd.read_excel(
    "./burr-radius.xlsx",
    sheet_name="Sheet11-modified",
    skiprows=2,
    usecols="C:R",
    header=None
)

labels = []
for i in [0,10,20,30]:
    labels += [f'main-external\n{i}', f'main-internal\n{i}', f'back-external\n{i}', f'back-internal\n{i}']
print(df)

df.columns = labels

print(df)

df_long = df.melt(
    var_name="Group",
    value_name="Burr_Size"
).dropna()
fig, ax = plt.subplots(figsize=(9, 6))

violin_plot = sns.violinplot(
    data=df_long,

    hue='Group',
    palette='Set3',

    x="Group",
    y="Burr_Size",
    inner=None,
    width=1.0,
    cut=0,
    ax=ax,
    linewidth=0.6, 
    scale="width"   
)

# 叠加箱线图
sns.boxplot(
    data=df_long,
    x="Group",
    y="Burr_Size",
    color="white",
    width=0.2,
    whis=[0,100],
    ax=ax,
    linewidth=0.6
)

sns.stripplot(
    data=df_long,
    x="Group",              
    y="Burr_Size",          
    hue="Group",           
    dodge=False,            
    size=8,                 
    alpha=0.8,               
    jitter=0.1,              
    ax=ax
)


for i in ['top','right','left','bottom']:
    if i != 'bottom':
        ax.spines[i].set_visible(False)
    else:
        ax.spines[i].set_color('#666666')   
        ax.spines[i].set_linewidth(0.8)     

ax.set_xticklabels(labels, rotation=45, ha="right")


plt.tight_layout(h_pad=0.5,w_pad=0.5)
plt.show()
