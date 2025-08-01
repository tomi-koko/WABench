import re
import os
import subprocess
import time
import psutil
import csv

def get_process_tree_memory(pid):
    try:
        parent = psutil.Process(pid)
        children = parent.children(recursive=True) 
        total_mem = parent.memory_info().rss
        for child in children:
            total_mem += child.memory_info().rss
        return total_mem / (1024 * 1024) 
    except psutil.NoSuchProcess:
        return 0


BENCHMARKS_DIR = '../benchmarks'
LANGS = ['C', 'Go', 'Python', 'Rust']
RESULTS_CSV = '../results/benchmark_results.csv'


with open(RESULTS_CSV, 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(['Benchmark', 'Language', 'WasmFile', 'AvgCompileTimeSec', 'MaxMemoryMB', 'Import', 'Export'])


for category in os.listdir(BENCHMARKS_DIR):
    cat_path = os.path.join(BENCHMARKS_DIR, category)
    if not os.path.isdir(cat_path):
        continue

    for benchmark in os.listdir(cat_path):
        bench_path = os.path.join(cat_path, benchmark)
        if not os.path.isdir(bench_path):
            continue

        for lang in LANGS:
            lang_path = os.path.join(bench_path, lang)
            if not os.path.isdir(lang_path):
                continue

            run_script = os.path.join(lang_path, 'run.sh')
            if not os.path.isfile(run_script):
                continue

           
            wasm_file = None
            if lang == 'Rust':
                wasm_file = os.path.join(lang_path, "target", "wasm32-wasip1", "debug", f"{benchmark}.wasm")
            else:
                for f in os.listdir(lang_path):
                    if f.endswith('.wasm'):
                        wasm_file = os.path.join(lang_path, f)
                        break
            print('\n'+wasm_file+'\n')
            file_size_kb = os.path.getsize(wasm_file) / 1024 if wasm_file and os.path.exists(wasm_file) else 0

            exec_times = []
            max_memories = []
            print(benchmark + " is compiling for 1 times")
            for i in range(1):
                start_time = time.time()
                #proc = subprocess.Popen(['bash', run_script], cwd=lang_path)
                proc = subprocess.Popen(['bash', 'compile.sh'], cwd=lang_path)

                proc_ps = psutil.Process(proc.pid)

            
                max_mem = 0
                while proc.poll() is None:
                    try:
                        current_mem = get_process_tree_memory(proc.pid)
                        max_mem = max(max_mem, current_mem)
                    except psutil.NoSuchProcess:
                        break
                    time.sleep(0.01)

                end_time = time.time()
                exec_times.append(end_time - start_time)
                max_memories.append(max_mem)

            # output = subprocess.check_output(['wasm-objdump', '-x', wasm_file]).decode()
            # import_count = output.count('Import[ ')
            # export_count = output.count('Export[ ')

            output = subprocess.check_output(['wasm-objdump', '-x', wasm_file]).decode()


            import_match = re.search(r'Import\[(\d+)\]', output)
            import_count = int(import_match.group(1)) if import_match else 0

            export_match = re.search(r'Export\[(\d+)\]', output)
            export_count = int(export_match.group(1)) if export_match else 0



            avg_time = sum(exec_times) / len(exec_times)
            max_memory = max(max_memories)

            with open(RESULTS_CSV, 'a', newline='') as csvfile:
                writer = csv.writer(csvfile)
                writer.writerow([
                    benchmark, lang,
                    os.path.basename(wasm_file) if wasm_file else 'N/A',
                #    f'{file_size_kb:.2f}',
                    f'{avg_time:.4f}',
                    f'{max_memory:.2f}',
                    f'{import_count}',
                    f'{export_count}'
                ])
            

print(f'All benchmarks have completed，result is saved {RESULTS_CSV}')
