from flask import Flask, jsonify
import shutil
import time

from .database import save_health_log

app = Flask(__name__)


def get_cpu_usage():
    with open("/proc/stat", "r") as file:
        values = file.readline().split()

    user, nice, system, idle, iowait, irq, softirq, steal = map(
        int, values[1:9]
    )

    idle1 = idle + iowait
    total1 = user + nice + system + idle + iowait + irq + softirq + steal

    time.sleep(1)

    with open("/proc/stat", "r") as file:
        values = file.readline().split()

    user, nice, system, idle, iowait, irq, softirq, steal = map(
        int, values[1:9]
    )

    idle2 = idle + iowait
    total2 = user + nice + system + idle + iowait + irq + softirq + steal

    total_diff = total2 - total1
    idle_diff = idle2 - idle1

    if total_diff <= 0:
        return None

    return round(100 * (total_diff - idle_diff) / total_diff, 2)


def get_memory_usage():
    memory = {}

    with open("/proc/meminfo", "r") as file:
        for line in file:
            key, value = line.split(":", 1)
            memory[key] = int(value.strip().split()[0])

    total = memory["MemTotal"]
    available = memory["MemAvailable"]
    used = total - available

    return {
        "total_mb": round(total / 1024, 2),
        "used_mb": round(used / 1024, 2),
        "available_mb": round(available / 1024, 2),
    }


def get_disk_usage():
    usage = shutil.disk_usage("/")

    usage_percent = (usage.used / usage.total) * 100

    return {
        "usage_percent": round(usage_percent, 2),
        "status": "warning" if usage_percent > 80 else "ok",
    }


@app.get("/")
def home():
    return jsonify(
        {
            "service": "devops-health-checker",
            "status": "running",
        }
    )


@app.get("/health")
def health():
    cpu_usage = get_cpu_usage()
    memory = get_memory_usage()
    disk = get_disk_usage()

    status = "healthy"

    if disk["status"] == "warning":
        status = "warning"

    save_health_log(
        status=status,
        cpu_usage=cpu_usage,
        memory_used_mb=memory["used_mb"],
        memory_available_mb=memory["available_mb"],
        disk_usage_percent=disk["usage_percent"],
    )

    return jsonify(
        {
            "status": status,
            "cpu_usage_percent": cpu_usage,
            "memory": memory,
            "disk": disk,
        }
    )


def main() -> None:
    app.run(host="0.0.0.0", port=8000)


if __name__ == "__main__":
    main()
