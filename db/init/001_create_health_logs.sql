CREATE TABLE IF NOT EXISTS health_logs (
    id SERIAL PRIMARY KEY,
    status VARCHAR(20) NOT NULL,
    cpu_usage DOUBLE PRECISION NOT NULL,
    memory_used_mb INTEGER NOT NULL,
    memory_available_mb INTEGER NOT NULL,
    disk_usage_percent DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
