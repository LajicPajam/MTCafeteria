const express = require('express');
const cors = require('cors');
const env = require('./config/env');

const authRoutes = require('./routes/authRoutes');
const contentRoutes = require('./routes/contentRoutes');
const trainingRoutes = require('./routes/trainingRoutes');
const shiftRoutes = require('./routes/shiftRoutes');
const taskBoardRoutes = require('./routes/taskBoardRoutes');

const app = express();

app.use(
  cors({
    origin(origin, callback) {
      if (!origin || env.corsOrigins.length === 0 || env.corsOrigins.includes(origin)) {
        callback(null, true);
        return;
      }
      callback(new Error('CORS origin not allowed.'));
    },
  })
);
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    mode: env.useMockData ? 'mock' : 'postgres',
    environment: env.nodeEnv,
  });
});

app.use('/api/auth', authRoutes);
app.use('/api/content', contentRoutes);
app.use('/api', trainingRoutes);
app.use('/api', shiftRoutes);
app.use('/api', taskBoardRoutes);

app.use((error, req, res, next) => {
  // TODO: Replace with structured logger when observability is added.
  console.error(error);
  res.status(500).json({ message: 'Internal server error.' });
});

app.listen(env.port, () => {
  console.log(`MTC Cafeteria backend running on http://localhost:${env.port}`);
});
