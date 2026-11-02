const express = require('express');
const cors = require('cors');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const nodemailer = require('nodemailer');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Request logger
app.use((req, _res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// Load the 50 call records from the Postman collection asset
const listDetailsPath = path.join(
  __dirname,
  '..',
  'assets',
  'mock',
  'list_details.json'
);
const listDetailsData = JSON.parse(fs.readFileSync(listDetailsPath, 'utf8'));

// Persistent JSON store for registered users & active OTP codes
const dbPath = path.join(__dirname, 'db.json');

function loadDb() {
  const defaultUsers = {
    'testing@yopmail.com': {
      _id: '68626f9497757cb741f449b0',
      username: 'Dhrubo',
      email: 'testing@yopmail.com',
      password: '123',
    },
    'dhrubo@yopmail.com': {
      _id: '68626f9497757cb741f449b0',
      username: 'Dhrubo',
      email: 'dhrubo@yopmail.com',
      password: '123',
    },
  };
  if (!fs.existsSync(dbPath)) {
    return { users: defaultUsers, otps: {} };
  }
  try {
    const raw = JSON.parse(fs.readFileSync(dbPath, 'utf8'));
    return {
      users: { ...defaultUsers, ...(raw.users || {}) },
      otps: raw.otps || {},
    };
  } catch (_) {
    return { users: defaultUsers, otps: {} };
  }
}

function saveDb(db) {
  fs.writeFileSync(dbPath, JSON.stringify(db, null, 2), 'utf8');
}

function generateObjectId() {
  return crypto.randomBytes(12).toString('hex');
}

function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Configure Nodemailer transporter (uses real SMTP if SMTP_USER/SMTP_PASS are
// provided, or creates an Ethereal test account automatically).
let mailTransporterPromise = null;

async function getTransporter() {
  if (mailTransporterPromise) return mailTransporterPromise;
  mailTransporterPromise = (async () => {
    if (process.env.SMTP_USER && process.env.SMTP_PASS) {
      return nodemailer.createTransport({
        service: process.env.SMTP_SERVICE || 'gmail',
        auth: {
          user: process.env.SMTP_USER,
          pass: process.env.SMTP_PASS,
        },
      });
    }
    try {
      const testAccount = await nodemailer.createTestAccount();
      return nodemailer.createTransport({
        host: testAccount.smtp.host,
        port: testAccount.smtp.port,
        secure: testAccount.smtp.secure,
        auth: {
          user: testAccount.user,
          pass: testAccount.pass,
        },
      });
    } catch (_) {
      return null;
    }
  })();
  return mailTransporterPromise;
}

// Health check
app.get('/api/health', (_req, res) => {
  res.status(200).json({ status: 'ok', service: 'Calley Mock API V2' });
});

/**
 * 1. POST /api/auth/register
 * Body: { username, email, password }
 * Response: 201 { message: "User registered" }
 */
app.post('/api/auth/register', (req, res) => {
  const { username, email, password } = req.body || {};
  if (!username || !email || !password) {
    return res
      .status(400)
      .json({ message: 'username, email, and password are required' });
  }

  const db = loadDb();
  const key = String(email).trim().toLowerCase();
  const existing = db.users[key];

  db.users[key] = {
    _id: existing ? existing._id : generateObjectId(),
    username: String(username).trim(),
    email: String(email).trim(),
    password: String(password),
  };
  saveDb(db);

  console.log(`[REGISTER] Registered ${email} (_id: ${db.users[key]._id})`);
  return res.status(201).json({ message: 'User registered' });
});

/**
 * 2. POST /api/auth/login
 * Body: { email, password }
 * Response: 200 { message: "Login successful", user: { _id, username, email } }
 */
app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body || {};
  if (!email || !password) {
    return res
      .status(400)
      .json({ message: 'email and password are required' });
  }

  const db = loadDb();
  const key = String(email).trim().toLowerCase();
  const user = db.users[key];

  if (!user || user.password !== String(password)) {
    return res.status(401).json({ message: 'Invalid email or password' });
  }

  console.log(`[LOGIN] Authenticated ${user.email} (_id: ${user._id})`);
  return res.status(200).json({
    message: 'Login successful',
    user: {
      _id: user._id,
      username: user.username,
      email: user.email,
    },
  });
});

/**
 * 3. POST /api/auth/send-otp
 * Body: { email }
 * Response: 200 { message: "OTP sent", otp: "<6-digit-otp>" }
 */
app.post('/api/auth/send-otp', async (req, res) => {
  const { email } = req.body || {};
  if (!email) {
    return res.status(400).json({ message: 'email is required' });
  }

  const key = String(email).trim().toLowerCase();
  const otp = generateOtp();

  const db = loadDb();
  db.otps[key] = {
    otp,
    createdAt: new Date().toISOString(),
  };
  saveDb(db);

  console.log('====================================================');
  console.log(`  [OTP GENERATED] Email: ${email}  -->  OTP: ${otp}`);
  console.log('====================================================');

  let previewUrl = null;
  try {
    const transporter = await getTransporter();
    if (transporter) {
      const info = await transporter.sendMail({
        from: '"Calley Automatic Call Dialer" <no-reply@calleyacd.com>',
        to: email,
        subject: `Your Calley OTP Verification Code: ${otp}`,
        text: `Your Calley verification OTP is ${otp}.`,
        html: `
          <div style="font-family: Inter, Arial, sans-serif; padding: 24px; max-width: 460px; border: 1px solid #e3e8f0; border-radius: 12px;">
            <h2 style="color: #2563EB; margin-top: 0;">Calley OTP Verification</h2>
            <p>Use the 6-digit verification code below to verify your account:</p>
            <div style="font-size: 28px; font-weight: 700; letter-spacing: 6px; padding: 14px 20px; background: #EEF4FF; color: #1E2A4A; border-radius: 8px; text-align: center;">
              ${otp}
            </div>
          </div>
        `,
      });
      previewUrl = nodemailer.getTestMessageUrl(info) || null;
      if (previewUrl) {
        console.log(`  [EMAIL PREVIEW] ${previewUrl}`);
      }
    }
  } catch (err) {
    console.warn('[MAIL WARNING]', err.message);
  }

  return res.status(200).json({
    message: 'OTP sent',
    otp,
    ...(previewUrl ? { previewUrl } : {}),
  });
});

/**
 * 4. POST /api/auth/verify-otp
 * Body: { email, otp }
 * Response: 200 { message: "OTP Verfied" }
 */
app.post('/api/auth/verify-otp', (req, res) => {
  const { email, otp } = req.body || {};
  if (!email || !otp) {
    return res.status(400).json({ message: 'email and otp are required' });
  }

  const key = String(email).trim().toLowerCase();
  const submitted = String(otp).trim();
  const db = loadDb();
  const record = db.otps[key];

  // Accept the generated OTP for this email (or Postman's static example 229166)
  if ((record && record.otp === submitted) || submitted === '229166') {
    delete db.otps[key];
    saveDb(db);
    console.log(`[VERIFY-OTP] Verified OTP ${submitted} for ${email}`);
    return res.status(200).json({ message: 'OTP Verfied' });
  }

  return res.status(400).json({ message: 'Invalid OTP code' });
});

/**
 * 5. GET /api/list?userId=...
 * Response: 200 { _id, name, agents, clientId }
 */
app.get('/api/list', (req, res) => {
  const userId = req.query.userId || '68626f9497757cb741f449b0';
  return res.status(200).json({
    _id: '68626fb697757cb741f449b9',
    name: 'Test List',
    agents: [],
    clientId: userId,
  });
});

/**
 * 6. GET /api/list/:listId
 * Response: 200 { pending: 27, called: 23, rescheduled: 11, calls: [...] }
 */
app.get('/api/list/:listId', (_req, res) => {
  return res.status(200).json(listDetailsData);
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`\nCalley Mock API V2 Server running on:`);
  console.log(`  • Local:   http://localhost:${PORT}/api`);
  console.log(`  • Network: http://192.168.1.97:${PORT}/api\n`);
});
