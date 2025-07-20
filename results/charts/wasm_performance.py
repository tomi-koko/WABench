import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt


csv_path = "ex2.csv" 
df = pd.read_csv(csv_path)
df = df[(df['status'] == 'success') & (df['mode'] == 'JIT')]

language_order = ["C", "Go", "Zig", "Rust", "Python"]
df = df[df['language'].isin(language_order)]
df['language'] = pd.Categorical(df['language'], categories=language_order, ordered=True)


custom_colors = ["#004385", "#c66219", "#ffc000", "#742984", "#b7282c"]

c_language_data = df[df['language'] == 'C'][['benchmark', 'exec_time_sec']]
df = df.merge(c_language_data, on='benchmark', suffixes=('', '_c'))
df['exec_time_rel'] = df['exec_time_sec'] / df['exec_time_sec_c']


plt.figure(figsize=(16, 6), dpi=100) 
ax = plt.gca()


sns.barplot(
    data=df,
    x='benchmark',
    y='exec_time_rel',
    hue='language',
    palette=custom_colors,
    ci=None,
    edgecolor='white',
    linewidth=0.5,
    ax=ax
)


ax.set_yscale('log')
ax.set_ylabel("Relative Execution Time (log scale)", fontsize=17)
ax.set_xlabel("Benchmark", fontsize=17)


ax.grid(which='major', axis='y', linestyle='-', linewidth=0.8, color='gray', alpha=0.5)
ax.grid(which='minor', axis='y', linestyle=':', linewidth=0.5, color='gray', alpha=0.3)
ax.minorticks_on()


ax.tick_params(axis='y', which='major', labelsize=18)
ax.tick_params(axis='x', labelsize=17, rotation=35)


legend = ax.legend(
    loc='upper center',
    bbox_to_anchor=(0.5,0.99),  
    ncol=5,  
    frameon=True,
    framealpha=0.9,
    edgecolor='#DDDDDD',
    facecolor='white',
    fontsize=15,
    title_fontsize=15,
    borderpad=0.8
)


ax.set_ylim(top=df['exec_time_rel'].max()*1.5)  


plt.tight_layout(rect=[0, 0, 1, 0.95]) 


plt.savefig("wasm_performance_relative_to_c_compact.pdf", 
            dpi=600, 
            bbox_inches='tight',
            facecolor='white')
plt.show()
