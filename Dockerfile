# Multi-stage Docker build for Bori Birthday App
# Stage 1: Build React frontend
FROM node:18-alpine as frontend-build

WORKDIR /app/frontend
COPY package.json package-lock.json ./
RUN npm ci --only=production

COPY src/ ./src/
COPY public/ ./public/
RUN npm run build

# Stage 2: Python backend with frontend
FROM python:3.9-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=app.py
ENV FLASK_ENV=production

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY app.py .
COPY templates/ ./templates/

# Copy built frontend from stage 1
COPY --from=frontend-build /app/frontend/build ./static

# Copy static assets
COPY bori_birthday.jpg .
COPY manifest.json .
COPY sw.js .

# Create non-root user
RUN useradd --create-home --shell /bin/bash app
RUN chown -R app:app /app
USER app

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Run the application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "--timeout", "120", "app:app"]
