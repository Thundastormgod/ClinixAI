require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');

const app = express();
const PORT = process.env.PORT || 3000;

// ==================== MIDDLEWARE ====================

// Security headers
app.use(helmet());

// CORS
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  credentials: true,
}));

// Compression
app.use(compression());

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Logging
app.use(morgan('combined'));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per window
  message: { error: 'Too many requests, please try again later.' },
});
app.use('/api/', limiter);

// ==================== ROUTES ====================

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'clinixai-api-gateway',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});

// API Info
app.get('/api/v1', (req, res) => {
  res.json({
    name: 'ClinixAI API',
    version: '1.0.0',
    description: 'AI-Powered Emergency Triage System for Africa',
    endpoints: {
      auth: '/api/v1/auth',
      triage: '/api/v1/triage',
      users: '/api/v1/users',
      ehr: '/api/v1/ehr',
      sync: '/api/v1/sync',
    },
  });
});

// ==================== AUTH ROUTES ====================
app.post('/api/v1/auth/register', async (req, res) => {
  try {
    const { phoneNumber, fullName, dateOfBirth, gender } = req.body;
    
    // TODO: Implement actual registration
    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        userId: require('uuid').v4(),
        phoneNumber,
        fullName,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/v1/auth/login', async (req, res) => {
  try {
    const { phoneNumber, otp } = req.body;
    
    // TODO: Implement actual OTP verification
    const jwt = require('jsonwebtoken');
    const token = jwt.sign(
      { phoneNumber, userId: 'test-user-id' },
      process.env.JWT_SECRET || 'dev-secret',
      { expiresIn: '15m' }
    );
    
    res.json({
      success: true,
      data: {
        accessToken: token,
        refreshToken: 'refresh-token-placeholder',
        expiresIn: 900,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== TRIAGE ROUTES ====================
app.post('/api/v1/triage/sessions', async (req, res) => {
  try {
    const { deviceId, deviceModel, appVersion, location } = req.body;
    
    const sessionId = require('uuid').v4();
    
    res.status(201).json({
      success: true,
      data: {
        sessionId,
        sessionStart: new Date().toISOString(),
        status: 'active',
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/v1/triage/sessions/:sessionId/symptoms', async (req, res) => {
  try {
    const { sessionId } = req.params;
    const { symptoms, vitalSigns } = req.body;
    
    res.json({
      success: true,
      data: {
        sessionId,
        symptomsRecorded: symptoms.length,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/v1/triage/sessions/:sessionId/analyze', async (req, res) => {
  try {
    const { sessionId } = req.params;
    
    // Forward to Triage Service
    const axios = require('axios');
    const triageServiceUrl = process.env.TRIAGE_SERVICE_URL || 'http://localhost:8000';
    
    const response = await axios.post(`${triageServiceUrl}/analyze`, {
      sessionId,
      ...req.body,
    });
    
    res.json(response.data);
  } catch (error) {
    // Fallback response if triage service is unavailable
    res.json({
      success: true,
      data: {
        sessionId: req.params.sessionId,
        urgencyLevel: 'standard',
        confidenceScore: 0.75,
        primaryAssessment: 'Cloud analysis unavailable. Please use local triage.',
        recommendedAction: 'Visit a healthcare facility for proper evaluation.',
        escalatedToCloud: false,
      },
    });
  }
});

// ==================== SYNC ROUTES ====================
app.post('/api/v1/sync/batch', async (req, res) => {
  try {
    const { sessions } = req.body;
    
    // TODO: Process batch sync from mobile app
    res.json({
      success: true,
      data: {
        synced: sessions?.length || 0,
        failed: 0,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== EHR ROUTES ====================
app.post('/api/v1/ehr/connect', async (req, res) => {
  try {
    const { providerId, ehrSystem, apiEndpoint } = req.body;
    
    res.json({
      success: true,
      data: {
        connectionId: require('uuid').v4(),
        status: 'connected',
        ehrSystem,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== ERROR HANDLING ====================
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found',
  });
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    error: 'Internal server error',
  });
});

// ==================== START SERVER ====================
app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════════════════════╗
║          ClinixAI API Gateway Started                 ║
╠═══════════════════════════════════════════════════════╣
║  Port: ${PORT}                                           ║
║  Environment: ${process.env.NODE_ENV || 'development'}                        ║
║  Health: http://localhost:${PORT}/health                 ║
║  API: http://localhost:${PORT}/api/v1                    ║
╚═══════════════════════════════════════════════════════╝
  `);
});

module.exports = app;
