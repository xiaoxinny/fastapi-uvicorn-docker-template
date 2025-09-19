# Use official Python slim image for small size
FROM python:3.12-slim

# Set working directory inside container
WORKDIR /app

# Install uv (Rust-based package manager)
RUN pip install --no-cache-dir uv

# Copy project files
COPY . .

# Install dependencies (frozen to lock file for reproducibility)
RUN uv sync --frozen --no-dev

# Expose port the app will run on
EXPOSE 8080

# Run FastAPI using Uvicorn with multiple workers for production
CMD ["uv", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080", "--workers", "4"]