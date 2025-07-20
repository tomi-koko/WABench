import time
import random

NUM_SAMPLES = 10000
FILENAME = "sensor_data_py.txt"

class SensorData:
    def __init__(self, timestamp, value):
        self.timestamp = timestamp
        self.value = value

def get_current_ms():
    return int(time.time() * 1000)

def generate_data(count):
    random.seed(time.time())
    data = []
    for _ in range(count):
        timestamp = get_current_ms()
        value = random.random() * 100.0  # 0~100的随机值
        data.append(SensorData(timestamp, value))
    return data

def write_data(data):
    with open(FILENAME, 'w') as f:
        for d in data:
            f.write(f"{d.timestamp},{d.value:.2f}\n")

def read_and_calculate():
    sum_values = 0.0
    count = 0
    with open(FILENAME, 'r') as f:
        for line in f:
            timestamp_str, value_str = line.strip().split(',')
            sum_values += float(value_str)
            count += 1
    return sum_values / count if count > 0 else 0.0

def main():
    # 生成数据
    start = get_current_ms()
    data = generate_data(NUM_SAMPLES)
    end = get_current_ms()
    print(f"[Python] Data generation time: {end - start} ms")

    # 写入文件
    start = get_current_ms()
    write_data(data)
    end = get_current_ms()
    print(f"[Python] Write time: {end - start} ms")

    # 读取并计算
    start = get_current_ms()
    avg = read_and_calculate()
    end = get_current_ms()
    print(f"[Python] Read & calculate time: {end - start} ms")
    print(f"[Python] Average value: {avg:.2f}")

if __name__ == "__main__":
    main()

