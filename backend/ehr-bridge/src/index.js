require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const axios = require('axios');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = process.env.PORT || 3001;
const FHIR_SERVER_URL = process.env.FHIR_SERVER_URL || 'http://localhost:8080/fhir';

app.use(helmet());
app.use(cors());
app.use(express.json());

// ==================== FHIR HELPERS ====================

/**
 * Convert ClinixAI triage session to FHIR Observation
 */
function triageToFhirObservation(triageData) {
  return {
    resourceType: 'Observation',
    id: uuidv4(),
    status: 'final',
    category: [{
      coding: [{
        system: 'http://terminology.hl7.org/CodeSystem/observation-category',
        code: 'exam',
        display: 'Exam',
      }],
    }],
    code: {
      coding: [{
        system: 'http://clinixai.com/triage',
        code: 'emergency-triage',
        display: 'Emergency Triage Assessment',
      }],
      text: 'ClinixAI Emergency Triage',
    },
    subject: {
      reference: `Patient/${triageData.patientId || 'unknown'}`,
    },
    effectiveDateTime: triageData.sessionStart || new Date().toISOString(),
    valueCodeableConcept: {
      coding: [{
        system: 'http://clinixai.com/urgency',
        code: triageData.urgencyLevel,
        display: triageData.urgencyLevel.toUpperCase(),
      }],
      text: triageData.primaryAssessment,
    },
    component: [
      {
        code: {
          coding: [{
            system: 'http://clinixai.com/triage',
            code: 'confidence-score',
          }],
          text: 'AI Confidence Score',
        },
        valueQuantity: {
          value: triageData.confidenceScore,
          unit: 'ratio',
          system: 'http://unitsofmeasure.org',
          code: '{ratio}',
        },
      },
      {
        code: {
          coding: [{
            system: 'http://clinixai.com/triage',
            code: 'recommended-action',
          }],
          text: 'Recommended Action',
        },
        valueString: triageData.recommendedAction,
      },
    ],
    note: [{
      text: triageData.disclaimer || 'AI-assisted assessment. Consult healthcare professional.',
    }],
  };
}

/**
 * Convert ClinixAI symptoms to FHIR Condition resources
 */
function symptomsToFhirConditions(symptoms, patientId) {
  return symptoms.map(symptom => ({
    resourceType: 'Condition',
    id: uuidv4(),
    clinicalStatus: {
      coding: [{
        system: 'http://terminology.hl7.org/CodeSystem/condition-clinical',
        code: 'active',
      }],
    },
    verificationStatus: {
      coding: [{
        system: 'http://terminology.hl7.org/CodeSystem/condition-ver-status',
        code: 'provisional',
      }],
    },
    category: [{
      coding: [{
        system: 'http://terminology.hl7.org/CodeSystem/condition-category',
        code: 'problem-list-item',
      }],
    }],
    severity: symptom.severity ? {
      coding: [{
        system: 'http://snomed.info/sct',
        code: symptom.severity >= 7 ? '24484000' : symptom.severity >= 4 ? '6736007' : '255604002',
        display: symptom.severity >= 7 ? 'Severe' : symptom.severity >= 4 ? 'Moderate' : 'Mild',
      }],
    } : undefined,
    code: {
      coding: symptom.symptomCode ? [{
        system: 'http://hl7.org/fhir/sid/icd-10',
        code: symptom.symptomCode,
      }] : [],
      text: symptom.description,
    },
    bodySite: symptom.bodyLocation ? [{
      text: symptom.bodyLocation,
    }] : undefined,
    subject: {
      reference: `Patient/${patientId || 'unknown'}`,
    },
    onsetString: symptom.durationHours ? `${symptom.durationHours} hours` : undefined,
    recordedDate: symptom.recordedAt || new Date().toISOString(),
  }));
}

// ==================== ROUTES ====================

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'clinixai-ehr-bridge',
    fhirServer: FHIR_SERVER_URL,
    timestamp: new Date().toISOString(),
  });
});

// Sync triage session to FHIR server
app.post('/api/v1/sync/fhir', async (req, res) => {
  try {
    const { triageData, symptoms, patientId } = req.body;
    
    // Convert to FHIR resources
    const observation = triageToFhirObservation({ ...triageData, patientId });
    const conditions = symptomsToFhirConditions(symptoms || [], patientId);
    
    // Create FHIR Bundle
    const bundle = {
      resourceType: 'Bundle',
      type: 'transaction',
      entry: [
        {
          resource: observation,
          request: {
            method: 'POST',
            url: 'Observation',
          },
        },
        ...conditions.map(condition => ({
          resource: condition,
          request: {
            method: 'POST',
            url: 'Condition',
          },
        })),
      ],
    };
    
    // Send to FHIR server
    const response = await axios.post(FHIR_SERVER_URL, bundle, {
      headers: { 'Content-Type': 'application/fhir+json' },
      timeout: 10000,
    });
    
    res.json({
      success: true,
      data: {
        bundleId: response.data.id,
        resourcesCreated: bundle.entry.length,
        fhirServer: FHIR_SERVER_URL,
      },
    });
  } catch (error) {
    console.error('FHIR sync error:', error.message);
    res.status(500).json({
      success: false,
      error: error.message,
      fhirServer: FHIR_SERVER_URL,
    });
  }
});

// Get patient history from FHIR server
app.get('/api/v1/patient/:patientId/history', async (req, res) => {
  try {
    const { patientId } = req.params;
    
    // Fetch observations for patient
    const observationsResponse = await axios.get(
      `${FHIR_SERVER_URL}/Observation?subject=Patient/${patientId}&_sort=-date&_count=50`,
      { headers: { Accept: 'application/fhir+json' } }
    );
    
    // Fetch conditions for patient
    const conditionsResponse = await axios.get(
      `${FHIR_SERVER_URL}/Condition?subject=Patient/${patientId}&_sort=-recorded-date&_count=50`,
      { headers: { Accept: 'application/fhir+json' } }
    );
    
    res.json({
      success: true,
      data: {
        patientId,
        observations: observationsResponse.data.entry || [],
        conditions: conditionsResponse.data.entry || [],
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// Connect to external EHR (OpenMRS, DHIS2)
app.post('/api/v1/ehr/connect', async (req, res) => {
  try {
    const { ehrSystem, apiEndpoint, credentials } = req.body;
    
    // Test connection based on EHR type
    let connectionStatus = 'unknown';
    
    if (ehrSystem === 'openmrs') {
      try {
        const response = await axios.get(`${apiEndpoint}/ws/rest/v1/session`, {
          auth: {
            username: credentials.username,
            password: credentials.password,
          },
          timeout: 5000,
        });
        connectionStatus = response.data.authenticated ? 'connected' : 'auth_failed';
      } catch (e) {
        connectionStatus = 'connection_failed';
      }
    } else if (ehrSystem === 'dhis2') {
      try {
        const response = await axios.get(`${apiEndpoint}/api/me`, {
          auth: {
            username: credentials.username,
            password: credentials.password,
          },
          timeout: 5000,
        });
        connectionStatus = response.status === 200 ? 'connected' : 'auth_failed';
      } catch (e) {
        connectionStatus = 'connection_failed';
      }
    }
    
    res.json({
      success: connectionStatus === 'connected',
      data: {
        ehrSystem,
        status: connectionStatus,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

app.get('/', (req, res) => {
  res.json({
    service: 'ClinixAI EHR Bridge',
    version: '1.0.0',
    fhirServer: FHIR_SERVER_URL,
    endpoints: {
      health: '/health',
      syncFhir: 'POST /api/v1/sync/fhir',
      patientHistory: 'GET /api/v1/patient/:id/history',
      connectEhr: 'POST /api/v1/ehr/connect',
    },
  });
});

app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════════════════════╗
║          ClinixAI EHR Bridge Started                  ║
╠═══════════════════════════════════════════════════════╣
║  Port: ${PORT}                                           ║
║  FHIR Server: ${FHIR_SERVER_URL.substring(0, 35)}...      
║  Health: http://localhost:${PORT}/health                 ║
╚═══════════════════════════════════════════════════════╝
  `);
});

module.exports = app;
