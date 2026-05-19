const express = require('express');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const app = express();

app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;
const databasePath = path.join(__dirname, 'trackhire.db');

const db = new sqlite3.Database(databasePath, (error) => {
  if (error) {
    console.error('Failed to connect to SQLite database:', error.message);
  } else {
    console.log('Connected to TrackHire SQLite database.');
  }
});

db.serialize(() => {
  db.run(`
    CREATE TABLE IF NOT EXISTS applications (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      company TEXT NOT NULL,
      role TEXT NOT NULL,
      status TEXT NOT NULL,
      dateApplied TEXT NOT NULL,
      location TEXT NOT NULL,
      salaryRange TEXT NOT NULL,
      notes TEXT NOT NULL,
      hasResume INTEGER NOT NULL,
      hasPortfolio INTEGER NOT NULL,
      hasCoverLetter INTEGER NOT NULL,
      hasApplicationQuestions INTEGER NOT NULL,
      hasOther INTEGER NOT NULL,
      isSaved INTEGER NOT NULL
    )
  `);

  db.get('SELECT COUNT(*) AS count FROM applications', (error, row) => {
    if (error) {
      console.error('Failed to count applications:', error.message);
      return;
    }

    if (row.count === 0) {
      const sampleApplications = [
        {
          company: 'Apple',
          role: 'iOS Developer',
          status: 'Applied',
          dateApplied: 'May 17, 2026',
          location: 'Cupertino, CA',
          salaryRange: '$120k - $160k',
          notes: 'Applied through LinkedIn.',
          hasResume: 1,
          hasPortfolio: 1,
          hasCoverLetter: 0,
          hasApplicationQuestions: 1,
          hasOther: 0,
          isSaved: 1
        },
        {
          company: 'Robinhood',
          role: 'Mobile Engineer',
          status: 'Interviewing',
          dateApplied: 'May 15, 2026',
          location: 'Remote',
          salaryRange: '$130k - $170k',
          notes: 'Need to follow up with recruiter.',
          hasResume: 1,
          hasPortfolio: 1,
          hasCoverLetter: 1,
          hasApplicationQuestions: 1,
          hasOther: 0,
          isSaved: 0
        },
        {
          company: 'Duolingo',
          role: 'Software Engineer',
          status: 'Rejected',
          dateApplied: 'May 10, 2026',
          location: 'Pittsburgh, PA',
          salaryRange: 'Not listed',
          notes: 'Keep improving mobile portfolio.',
          hasResume: 1,
          hasPortfolio: 0,
          hasCoverLetter: 0,
          hasApplicationQuestions: 1,
          hasOther: 0,
          isSaved: 0
        }
      ];

      const insertStatement = db.prepare(`
        INSERT INTO applications (
          company,
          role,
          status,
          dateApplied,
          location,
          salaryRange,
          notes,
          hasResume,
          hasPortfolio,
          hasCoverLetter,
          hasApplicationQuestions,
          hasOther,
          isSaved
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `);

      sampleApplications.forEach((application) => {
        insertStatement.run(
          application.company,
          application.role,
          application.status,
          application.dateApplied,
          application.location,
          application.salaryRange,
          application.notes,
          application.hasResume,
          application.hasPortfolio,
          application.hasCoverLetter,
          application.hasApplicationQuestions,
          application.hasOther,
          application.isSaved
        );
      });

      insertStatement.finalize();
      console.log('Seeded sample TrackHire applications.');
    }
  });
});

function formatApplication(row) {
  return {
    id: row.id,
    company: row.company,
    role: row.role,
    status: row.status,
    dateApplied: row.dateApplied,
    location: row.location,
    salaryRange: row.salaryRange,
    notes: row.notes,
    hasResume: row.hasResume === 1,
    hasPortfolio: row.hasPortfolio === 1,
    hasCoverLetter: row.hasCoverLetter === 1,
    hasApplicationQuestions: row.hasApplicationQuestions === 1,
    hasOther: row.hasOther === 1,
    isSaved: row.isSaved === 1
  };
}

function toDatabaseBoolean(value) {
  return value ? 1 : 0;
}

app.get('/', (req, res) => {
  res.json({
    message: 'TrackHire API is running with SQLite persistence',
    database: 'SQLite',
    endpoints: [
      'GET /applications',
      'GET /applications/:id',
      'POST /applications',
      'PUT /applications/:id',
      'DELETE /applications/:id',
      'PATCH /applications/:id/save'
    ]
  });
});

app.get('/applications', (req, res) => {
  db.all('SELECT * FROM applications ORDER BY id DESC', (error, rows) => {
    if (error) {
      return res.status(500).json({
        error: 'Failed to fetch applications'
      });
    }

    res.json(rows.map(formatApplication));
  });
});

app.get('/applications/:id', (req, res) => {
  const id = Number(req.params.id);

  db.get('SELECT * FROM applications WHERE id = ?', [id], (error, row) => {
    if (error) {
      return res.status(500).json({
        error: 'Failed to fetch application'
      });
    }

    if (!row) {
      return res.status(404).json({
        error: 'Application not found'
      });
    }

    res.json(formatApplication(row));
  });
});

app.post('/applications', (req, res) => {
  const {
    company,
    role,
    status,
    dateApplied,
    location,
    salaryRange,
    notes,
    hasResume,
    hasPortfolio,
    hasCoverLetter,
    hasApplicationQuestions,
    hasOther,
    isSaved
  } = req.body;

  if (!company || !role) {
    return res.status(400).json({
      error: 'Company and role are required'
    });
  }

  const application = {
    company,
    role,
    status: status || 'Applied',
    dateApplied: dateApplied || 'No date added',
    location: location || 'No location added',
    salaryRange: salaryRange || 'No salary added',
    notes: notes || 'No notes added.',
    hasResume: toDatabaseBoolean(hasResume),
    hasPortfolio: toDatabaseBoolean(hasPortfolio),
    hasCoverLetter: toDatabaseBoolean(hasCoverLetter),
    hasApplicationQuestions: toDatabaseBoolean(hasApplicationQuestions),
    hasOther: toDatabaseBoolean(hasOther),
    isSaved: toDatabaseBoolean(isSaved)
  };

  const sql = `
    INSERT INTO applications (
      company,
      role,
      status,
      dateApplied,
      location,
      salaryRange,
      notes,
      hasResume,
      hasPortfolio,
      hasCoverLetter,
      hasApplicationQuestions,
      hasOther,
      isSaved
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `;

  db.run(
    sql,
    [
      application.company,
      application.role,
      application.status,
      application.dateApplied,
      application.location,
      application.salaryRange,
      application.notes,
      application.hasResume,
      application.hasPortfolio,
      application.hasCoverLetter,
      application.hasApplicationQuestions,
      application.hasOther,
      application.isSaved
    ],
    function (error) {
      if (error) {
        return res.status(500).json({
          error: 'Failed to create application'
        });
      }

      db.get(
        'SELECT * FROM applications WHERE id = ?',
        [this.lastID],
        (selectError, row) => {
          if (selectError) {
            return res.status(500).json({
              error: 'Failed to fetch created application'
            });
          }

          res.status(201).json(formatApplication(row));
        }
      );
    }
  );
});

app.put('/applications/:id', (req, res) => {
  const id = Number(req.params.id);

  const {
    company,
    role,
    status,
    dateApplied,
    location,
    salaryRange,
    notes,
    hasResume,
    hasPortfolio,
    hasCoverLetter,
    hasApplicationQuestions,
    hasOther,
    isSaved
  } = req.body;

  if (!company || !role) {
    return res.status(400).json({
      error: 'Company and role are required'
    });
  }

  const sql = `
    UPDATE applications
    SET
      company = ?,
      role = ?,
      status = ?,
      dateApplied = ?,
      location = ?,
      salaryRange = ?,
      notes = ?,
      hasResume = ?,
      hasPortfolio = ?,
      hasCoverLetter = ?,
      hasApplicationQuestions = ?,
      hasOther = ?,
      isSaved = ?
    WHERE id = ?
  `;

  db.run(
    sql,
    [
      company,
      role,
      status || 'Applied',
      dateApplied || 'No date added',
      location || 'No location added',
      salaryRange || 'No salary added',
      notes || 'No notes added.',
      toDatabaseBoolean(hasResume),
      toDatabaseBoolean(hasPortfolio),
      toDatabaseBoolean(hasCoverLetter),
      toDatabaseBoolean(hasApplicationQuestions),
      toDatabaseBoolean(hasOther),
      toDatabaseBoolean(isSaved),
      id
    ],
    function (error) {
      if (error) {
        return res.status(500).json({
          error: 'Failed to update application'
        });
      }

      if (this.changes === 0) {
        return res.status(404).json({
          error: 'Application not found'
        });
      }

      db.get('SELECT * FROM applications WHERE id = ?', [id], (selectError, row) => {
        if (selectError) {
          return res.status(500).json({
            error: 'Failed to fetch updated application'
          });
        }

        res.json(formatApplication(row));
      });
    }
  );
});

app.delete('/applications/:id', (req, res) => {
  const id = Number(req.params.id);

  db.run('DELETE FROM applications WHERE id = ?', [id], function (error) {
    if (error) {
      return res.status(500).json({
        error: 'Failed to delete application'
      });
    }

    if (this.changes === 0) {
      return res.status(404).json({
        error: 'Application not found'
      });
    }

    res.json({
      message: 'Application deleted successfully',
      id
    });
  });
});

app.patch('/applications/:id/save', (req, res) => {
  const id = Number(req.params.id);

  db.get('SELECT * FROM applications WHERE id = ?', [id], (error, row) => {
    if (error) {
      return res.status(500).json({
        error: 'Failed to fetch application'
      });
    }

    if (!row) {
      return res.status(404).json({
        error: 'Application not found'
      });
    }

    const updatedSavedValue = row.isSaved === 1 ? 0 : 1;

    db.run(
      'UPDATE applications SET isSaved = ? WHERE id = ?',
      [updatedSavedValue, id],
      (updateError) => {
        if (updateError) {
          return res.status(500).json({
            error: 'Failed to update saved status'
          });
        }

        db.get('SELECT * FROM applications WHERE id = ?', [id], (selectError, updatedRow) => {
          if (selectError) {
            return res.status(500).json({
              error: 'Failed to fetch updated application'
            });
          }

          res.json(formatApplication(updatedRow));
        });
      }
    );
  });
});

app.listen(PORT, () => {
  console.log(`TrackHire API is running on port ${PORT}`);
});