from flask import Flask
import time
import os
import psutil
import threading

app = Flask(__name__)

# Memory consumption variables
memory_chunk = []
cpu_busy = False

@app.route('/')
def hello():
    return "ECS Dummy App for Alarm Testing"

@app.route('/health')
def health():
    return {"status": "healthy"}, 200

@app.route('/cpu-spike')
def cpu_spike():
    """Simulate CPU usage spike to trigger CPU reservation alarm"""
    global cpu_busy
    cpu_busy = True
    def consume_cpu():
        # Consume CPU for 2 minutes
        end_time = time.time() + 120
        while time.time() < end_time:
            # Busy loop
            for _ in range(1000000):
                pass
        cpu_busy = False
    thread = threading.Thread(target=consume_cpu)
    thread.start()
    return "Triggering CPU spike...", 202

@app.route('/memory-spike/<int:mb>')
def memory_spike(mb):
    """Allocate memory to trigger memory reservation alarm"""
    global memory_chunk
    # Allocate approximately MB megabytes
    chunk = bytearray(mb * 1024 * 1024)
    memory_chunk.append(chunk)
    return f"Allocated {mb}MB of memory", 200

@app.route('/memory-release')
def memory_release():
    """Release allocated memory"""
    global memory_chunk
    memory_chunk.clear()
    return "Memory released", 200

@app.route('/stop-task')
def stop_task():
    """Self-terminate to trigger task stopped spike alarm"""
    os._exit(1)
    return "Task stopping...", 200

@app.route('/crash')
def crash():
    """Crash the application"""
    raise Exception("Simulated crash")

@app.route('/metrics')
def metrics():
    """Export metrics for monitoring"""
    memory = psutil.virtual_memory()
    cpu = psutil.cpu_percent(interval=1)
    
    return {
        "cpu_percent": cpu,
        "memory_percent": memory.percent,
        "memory_used_mb": memory.used / 1024 / 1024,
        "memory_available_mb": memory.available / 1024 / 1024
    }

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)