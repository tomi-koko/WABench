import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.ticker import MultipleLocator


# release
go_data = pd.DataFrame({
    'benchmark': ['batchwrite','randrw','std','writeflow','correlation','fft','floydwarshall','nbody','quicksort', '3mm', 'aes', 'compress', 'edgebmp', 'hash'],
    'tinygo_time': [3.494, 2.065, 4.105, 4.914, 4.424, 4.378, 4.317, 4.361, 4.286, 4.606, 4.583, 4.472, 4.890, 4.455],
    'gc_time': [0.094, 0.088, 0.096, 0.106, 0.090, 0.083, 0.094, 0.090, 0.092, 0.108, 0.102, 0.093, 0.098, 0.096],
    'tinygo_size': [564.669,400.736,573.598,746.333,632.282,637.972,630.280,631.766,630.000, 635.6, 665.2, 657.8, 708.9,658.1],
    'gc_size': [2555.913,2149.151,2450.130,2659.861,2493.085,2502.734,2493.057,2490.425,2489.660, 2497.004, 2590.763, 2579.587,2654.813,2583.523],
    'tinygo_time_std': [0.045, 0.017, 0.043, 0.096, 0.050, 0.055, 0.045, 0.056, 0.026, 0.235, 0.083, 0.085, 0.092, 0.081],
    'gc_time_std': [0.014, 0.010, 0.009, 0.004, 0.009, 0.007, 0.009, 0.009, 0.010, 0.013, 0.009, 0.008, 0.010, 0.009],
})

# debug
# clang_data = pd.DataFrame({
#     'benchmark': ['batchwrite','randrw','std','writeflow','correlation','fft','floydwarshall','nbody','quicksort', '3mm', 'aes','compress','edgebmp','hash' ],
#     'clang21_time': [0.038,0.043,0.04,0.045, 0.055,0.065,0.043,0.054,0.056,0.11,0.06,0.042,0.051,0.053],
#     'clang25_time': [0.073,0.067,0.072,0.071,0.098,0.094,0.071,0.084,0.091,0.146,0.091,0.086,0.088,0.093],
#     'clang21_size': [41.693,23.605,28.974,61.089,32.685,55.33,30.503,33.523,30.211,33.098,49.7,44.6,46.7,50.2],
#     'clang25_size': [232.592,148.031,144.371,292.714,149.667,184.869,147.555,150.571,147.307,149.992,255,249.9,250,250.6],
#     'clang21_time_std': [0.006,0.007,0.007,0.005,0.007,0.011,0.007,0.005,0.007,0.012,0.011,0.004,0.006,0.008],
#     'clang25_time_std': [0.006,0.007,0.009,0.006,0.006,0.007,0.009,0.006,0.015,0.037,0.007,0.013,0.010,0.005],
# })
# release
clang_data = pd.DataFrame({
    'benchmark': ['batchwrite','randrw','std','writeflow','correlation','fft','floydwarshall','nbody','quicksort', '3mm', 'aes','compress','edgebmp','hash' ],
    'clang21_time': [0.052,0.048,0.065,0.074, 0.127,0.097,0.085,0.095,0.074,0.132,0.177,0.066,0.093,0.148],
    'clang25_time': [1.628,1.142,1.517,2.210,1.645,1.617,1.595,1.582,1.567,1.611,1.837,2.003,1.838,1.781],
    'clang21_size': [30.846,13.031,19.259,49.062,30.570,44.077,30.030,29.021,28.141,30.624,34.773,32.692,33.214,35.141],
    'clang25_size': [30.062,12.197,17.828,50.797,30.496,45.719,29.900,28.964,28.099,30.806,36.540,32.945,35.847,35.649],
    'clang21_time_std': [0.008,0.009,0.007,0.007,0.006,0.004,0.005,0.007,0.007,0.004,0.009,0.005,0.008,0.012],
    'clang25_time_std': [0.027,0.026,0.027,0.025,0.053,0.027,0.037,0.039,0.015,0.026,0.036,0.066,0.037,0.027],
})


n = 9
z = 1.96
for df in [go_data, clang_data]:
    if 'tinygo_time_std' in df.columns:
        df['tinygo_time_ci'] = z * df['tinygo_time_std'] / np.sqrt(n)
        df['gc_time_ci'] = z * df['gc_time_std'] / np.sqrt(n)
    if 'clang21_time_std' in df.columns:
        df['clang21_time_ci'] = z * df['clang21_time_std'] / np.sqrt(n)
        df['clang25_time_ci'] = z * df['clang25_time_std'] / np.sqrt(n)

plt.style.use('default')
plt.rcParams.update({
    'font.family': 'Times New Roman',
    'font.size': 12,  
    'axes.titlesize': 14, 
    'axes.labelsize': 13,  
    'xtick.labelsize': 11,  
    'ytick.labelsize': 11, 
    'legend.fontsize': 11,
    'figure.dpi': 600,
    'grid.alpha': 0.3,
    'grid.linewidth': 0.6,
    'figure.constrained_layout.use': True
})


fig, axs = plt.subplots(2, 2, figsize=(12, 10), 
                      gridspec_kw={'width_ratios': [1, 1], 'height_ratios': [1, 1]})
((ax1, ax2), (ax3, ax4)) = axs  


width = 0.35
colors = {
    'tinygo': '#004385', 
    'gc': '#c66219',
    'clang21': '#004385',
    'clang25': '#c66219'
}
x_go = np.arange(len(go_data))
x_clang = np.arange(len(clang_data))

ax1.bar(x_go - width/2, go_data['tinygo_time'], width, 
       color=colors['tinygo'], label='TinyGo', edgecolor='white', linewidth=0.5)
ax1.bar(x_go + width/2, go_data['gc_time'], width, 
       color=colors['gc'], label='Go gc', edgecolor='white', linewidth=0.5)


ax1.errorbar(x_go - width/2, go_data['tinygo_time'], yerr=go_data['tinygo_time_ci'],
            fmt='none', ecolor='#333333', elinewidth=1.2, capsize=3, capthick=1.2)
ax1.errorbar(x_go + width/2, go_data['gc_time'], yerr=go_data['gc_time_ci'],
            fmt='none', ecolor='#333333', elinewidth=1.2, capsize=3, capthick=1.2)

ax1.set_title('(a) Go: Compile Time', pad=12, fontsize=14, fontweight='bold')  # 加粗标题
ax1.set_ylabel('Time (s)', labelpad=10, fontsize=13)
ax1.set_xticks(x_go)
ax1.set_xticklabels(go_data['benchmark'], rotation=35, ha='right', fontsize=11)
ax1.set_ylim(0, 6)
ax1.yaxis.set_major_locator(MultipleLocator(1))
ax1.yaxis.set_minor_locator(MultipleLocator(0.2))
ax1.grid(True, which='major', linestyle='-', alpha=0.5)
ax1.grid(True, which='minor', linestyle=':', alpha=0.2)
ax1.legend(loc='upper right', framealpha=0.9, edgecolor='#DDDDDD', fontsize=11)

ax2.bar(x_go - width/2, go_data['tinygo_size'], width, 
       color=colors['tinygo'], label='TinyGo', edgecolor='white', linewidth=0.5)
ax2.bar(x_go + width/2, go_data['gc_size'], width, 
       color=colors['gc'], label='Go gc', edgecolor='white', linewidth=0.5)

ax2.set_title('(b) Go: Output Size', pad=12, fontsize=14, fontweight='bold')
ax2.set_ylabel('Size (kB)', labelpad=10, fontsize=13)
ax2.set_xticks(x_go)
ax2.set_xticklabels(go_data['benchmark'], rotation=35, ha='right', fontsize=11)
ax2.set_ylim(0, 3000)
ax2.yaxis.set_major_locator(MultipleLocator(500))
ax2.yaxis.set_minor_locator(MultipleLocator(100))
ax2.grid(True, which='major', linestyle='-', alpha=0.5)
ax2.grid(True, which='minor', linestyle=':', alpha=0.2)
ax2.legend(loc='upper right', framealpha=0.9, edgecolor='#DDDDDD', fontsize=11)


ax3.bar(x_clang - width/2, clang_data['clang21_time'], width, 
       color=colors['clang21'], label='wasi-sdk-21', edgecolor='white', linewidth=0.5)
ax3.bar(x_clang + width/2, clang_data['clang25_time'], width, 
       color=colors['clang25'], label='wasi-sdk-25', edgecolor='white', linewidth=0.5)


ax3.errorbar(x_clang - width/2, clang_data['clang21_time'], yerr=clang_data['clang21_time_ci'],
            fmt='none', ecolor='#333333', elinewidth=1.2, capsize=3, capthick=1.2)
ax3.errorbar(x_clang + width/2, clang_data['clang25_time'], yerr=clang_data['clang25_time_ci'],
            fmt='none', ecolor='#333333', elinewidth=1.2, capsize=3, capthick=1.2)


y3_max = max((clang_data['clang21_time'] + clang_data['clang21_time_ci']).max(),
             (clang_data['clang25_time'] + clang_data['clang25_time_ci']).max())
ax3.set_ylim(0, y3_max * 1.15)

ax3.set_title('(c) Clang: Compile Time', pad=12, fontsize=14, fontweight='bold')
ax3.set_ylabel('Time (s)', labelpad=10, fontsize=13)
ax3.set_xticks(x_clang)
ax3.set_xticklabels(clang_data['benchmark'], rotation=35, ha='right', fontsize=11)
ax3.grid(True, which='major', linestyle='-', alpha=0.5)
ax3.grid(True, which='minor', linestyle=':', alpha=0.2)
ax3.legend(loc='upper right', framealpha=0.9, edgecolor='#DDDDDD', fontsize=11)



ax4.bar(x_clang - width/2, clang_data['clang21_size'], width, 
       color=colors['clang21'], label='wasi-sdk-21', edgecolor='white', linewidth=0.5)
ax4.bar(x_clang + width/2, clang_data['clang25_size'], width, 
       color=colors['clang25'], label='wasi-sdk-25', edgecolor='white', linewidth=0.5)


y4_max = max(clang_data[['clang21_size', 'clang25_size']].max())
ax4.set_ylim(0, y4_max * 1.15)

ax4.set_title('(d) Clang: Output Size', pad=12, fontsize=14, fontweight='bold')
ax4.set_ylabel('Size (kB)', labelpad=10, fontsize=13)
ax4.set_xticks(x_clang)
ax4.set_xticklabels(clang_data['benchmark'], rotation=35, ha='right', fontsize=11)
ax4.grid(True, which='major', linestyle='-', alpha=0.5)
ax4.grid(True, which='minor', linestyle=':', alpha=0.2)
ax4.legend(loc='upper right', framealpha=0.9, edgecolor='#DDDDDD', fontsize=11)



plt.tight_layout(pad=3.0, h_pad=3.0, w_pad=3.0) 
plt.subplots_adjust(top=0.92, bottom=0.08, left=0.07, right=0.95)  



plt.savefig('combined_wasm_compilers_large_font.pdf', dpi=600, bbox_inches='tight')
plt.show()
