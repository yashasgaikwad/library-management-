const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const { initMySQL, getDatabaseStatus } = require('./config/db');
const dashboardRoutes = require('./routes/dashboard');
const booksRoutes = require('./routes/books');
const studentsRoutes = require('./routes/students');
const issuesRoutes = require('./routes/issues');
const queryRoutes = require('./routes/query');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve frontend static files
app.use(express.static(path.join(__dirname, 'public')));

// Mount API routes
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/books', booksRoutes);
app.use('/api/students', studentsRoutes);
app.use('/api/issues', issuesRoutes);
app.use('/api/query', queryRoutes);

// Fallback route for SPA
app.get('*', (req, res, next) => {
  if (req.path.startsWith('/api')) {
    return next();
  }
  if (path.extname(req.path)) {
    return res.status(404).send('Static resource not found');
  }
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// 404 handler for unmatched API routes
app.use('/api/*', (req, res) => {
  res.status(404).json({ success: false, message: 'API route not found' });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Unhandled Server Error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error occurred',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Start Express server and connect to database
app.listen(PORT, async () => {
  console.log('====================================================');
  console.log('   📚 LIBRARY MANAGEMENT SYSTEM - SERVER STARTED    ');
  console.log('====================================================');
  console.log(`🚀 Web Application running at : http://localhost:${PORT}`);
  console.log(`🌐 API Base Endpoint          : http://localhost:${PORT}/api`);
  console.log('----------------------------------------------------');
  
  // Attempt Database connection (Supabase PostgreSQL / MySQL)
  await initMySQL();
  const status = getDatabaseStatus();
  console.log(`📊 Database Mode              : ${status.mode.toUpperCase()}`);
  console.log(`ℹ️  Status Message            : ${status.message}`);
  console.log('====================================================');
});
