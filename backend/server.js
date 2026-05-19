const express = require('express');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

let applications = [
  {
    id: 1,
    company: 'Apple',
    role: 'iOS Developer',
    status: 'Applied',
    dateApplied: 'May 17, 2026',
    location: 'Cupertino, CA',
    salaryRange: '$120k - $160k',
    notes: 'Applied through LinkedIn.',
    hasResume: true,
    hasPortfolio: true,
    hasCoverLetter: false,
    hasApplicationQuestions: true,
    hasOther: false,
    isSaved: true
  },
  {
    id: 2,
    company: 'Robinhood',
    role: 'Mobile Engineer',
    status: 'Interviewing',
    dateApplied: 'May 15, 2026',
    location: 'Remote',
    salaryRange: '$130k - $170k',
    notes: 'Need to follow up with recruiter.',
    hasResume: true,
    hasPortfolio: true,
    hasCoverLetter: true,
    hasApplicationQuestions: true,
    hasOther: false,
    isSaved: false
  },
  {
    id: 3,
    company: 'Duolingo',
    role: 'Software Engineer',
    status: 'Rejected',
    dateApplied: 'May 10, 2026',
    location: 'Pittsburgh, PA',
    salaryRange: 'Not listed',
    notes: 'Keep improving mobile portfolio.',
    hasResume: true,
    hasPortfolio: false,
    hasCoverLetter: false,
    hasApplicationQuestions: true,
    hasOther: false,
    isSaved: false
  }
];

let nextId = 4;

app.get('/', (req, res) => {
  res.json({
    message: 'TrackHire API is running',
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
  res.json(applications);
});

app.get('/applications/:id', (req, res) => {
  const id = Number(req.params.id);

  const application = applications.find((item) => item.id === id);

  if (!application) {
    return res.status(404).json({
      error: 'Application not found'
    });
  }

  res.json(application);
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

  const newApplication = {
    id: nextId,
    company,
    role,
    status: status || 'Applied',
    dateApplied: dateApplied || 'No date added',
    location: location || 'No location added',
    salaryRange: salaryRange || 'No salary added',
    notes: notes || 'No notes added.',
    hasResume: Boolean(hasResume),
    hasPortfolio: Boolean(hasPortfolio),
    hasCoverLetter: Boolean(hasCoverLetter),
    hasApplicationQuestions: Boolean(hasApplicationQuestions),
    hasOther: Boolean(hasOther),
    isSaved: Boolean(isSaved)
  };

  applications.unshift(newApplication);
  nextId++;

  res.status(201).json(newApplication);
});

app.put('/applications/:id', (req, res) => {
  const id = Number(req.params.id);

  const index = applications.findIndex((item) => item.id === id);

  if (index === -1) {
    return res.status(404).json({
      error: 'Application not found'
    });
  }

  const updatedApplication = {
    ...applications[index],
    ...req.body,
    id
  };

  applications[index] = updatedApplication;

  res.json(updatedApplication);
});

app.delete('/applications/:id', (req, res) => {
  const id = Number(req.params.id);

  const index = applications.findIndex((item) => item.id === id);

  if (index === -1) {
    return res.status(404).json({
      error: 'Application not found'
    });
  }

  const deletedApplication = applications[index];

  applications.splice(index, 1);

  res.json({
    message: 'Application deleted successfully',
    application: deletedApplication
  });
});

app.patch('/applications/:id/save', (req, res) => {
  const id = Number(req.params.id);

  const index = applications.findIndex((item) => item.id === id);

  if (index === -1) {
    return res.status(404).json({
      error: 'Application not found'
    });
  }

  applications[index].isSaved = !applications[index].isSaved;

  res.json(applications[index]);
});

app.listen(PORT, () => {
  console.log(`TrackHire API is running on port ${PORT}`);
});