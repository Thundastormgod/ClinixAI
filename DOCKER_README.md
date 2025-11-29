# ClinixAI Docker Local Development Guide

## Quick Start

### Prerequisites
- Docker Desktop installed and running
- At least 4GB RAM allocated to Docker

### 1. Start All Services
```powershell
cd "c:\Users\MY PC\OneDrive\Documents\DATA SCIENCE\clinix hackathon"
docker-compose up -d
```

### 2. Check Service Status
```powershell
docker-compose ps
```

### 3. View Logs
```powershell
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f api-gateway
docker-compose logs -f triage-service
```

### 4. Stop Services
```powershell
docker-compose down

# Stop and remove volumes (clean reset)
docker-compose down -v
```

---

## Services & Ports

| Service | Port | URL | Description |
|---------|------|-----|-------------|
| **API Gateway** | 3000 | http://localhost:3000 | Main API entry point |
| **Triage Service** | 8000 | http://localhost:8000 | Cloud AI analysis |
| **EHR Bridge** | 3001 | http://localhost:3001 | FHIR/EHR integration |
| **PostgreSQL** | 5432 | localhost:5432 | Database |
| **Redis** | 6379 | localhost:6379 | Cache |
| **HAPI FHIR** | 8080 | http://localhost:8080 | FHIR Server |
| **Adminer** | 8081 | http://localhost:8081 | Database GUI |
| **Redis Commander** | 8082 | http://localhost:8082 | Redis GUI |

---

## Testing the Services

### API Gateway
```powershell
# Health check
curl http://localhost:3000/health

# API Info
curl http://localhost:3000/api/v1

# Create triage session
curl -X POST http://localhost:3000/api/v1/triage/sessions `
  -H "Content-Type: application/json" `
  -d '{"deviceModel": "Nothing Phone (2a)", "appVersion": "1.0.0"}'
```

### Triage Service
```powershell
# Health check
curl http://localhost:8000/health

# Analyze symptoms
curl -X POST http://localhost:8000/analyze `
  -H "Content-Type: application/json" `
  -d '{
    "session_id": "test-123",
    "symptoms": [
      {"description": "High fever for 3 days", "severity": 7},
      {"description": "Severe headache", "severity": 8}
    ],
    "patient_age": 30,
    "patient_gender": "male"
  }'
```

### EHR Bridge
```powershell
# Health check
curl http://localhost:3001/health

# Sync to FHIR
curl -X POST http://localhost:3001/api/v1/sync/fhir `
  -H "Content-Type: application/json" `
  -d '{
    "triageData": {
      "urgencyLevel": "urgent",
      "confidenceScore": 0.85,
      "primaryAssessment": "Possible malaria",
      "recommendedAction": "Visit clinic"
    },
    "symptoms": [
      {"description": "High fever", "severity": 7}
    ],
    "patientId": "patient-123"
  }'
```

### HAPI FHIR Server
```powershell
# Server info
curl http://localhost:8080/fhir/metadata

# List patients
curl http://localhost:8080/fhir/Patient
```

---

## Database Access

### Via Adminer (GUI)
1. Open http://localhost:8081
2. System: PostgreSQL
3. Server: postgres
4. Username: clinixai_user
5. Password: clinixai_dev_password
6. Database: clinixai

### Via Command Line
```powershell
docker exec -it clinixai-postgres psql -U clinixai_user -d clinixai
```

---

## Useful Commands

```powershell
# Rebuild a specific service
docker-compose build api-gateway
docker-compose up -d api-gateway

# View resource usage
docker stats

# Enter a container
docker exec -it clinixai-api-gateway sh

# Reset everything
docker-compose down -v
docker-compose up -d --build
```

---

## Production Deployment

When ready to deploy to production:

1. Update `.env` with production values
2. Use `docker-compose.prod.yml` (create if needed)
3. Push images to container registry
4. Deploy to AWS ECS / Kubernetes

```powershell
# Build for production
docker-compose -f docker-compose.yml build

# Tag and push to registry
docker tag clinixai-api-gateway:latest your-registry/clinixai-api-gateway:v1.0.0
docker push your-registry/clinixai-api-gateway:v1.0.0
```
