const express = require('express');
const OpenAI = require('openai');

const router = express.Router();

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

router.post('/resume-tailor', async (req, res) => {
  try {
    const { jobDescription } = req.body;

    if (!jobDescription) {
      return res.status(400).json({
        error: 'Job description is required'
      });
    }

    if (!process.env.OPENAI_API_KEY) {
      return res.status(500).json({
        error: 'Missing OPENAI_API_KEY'
      });
    }

    const response = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        {
          role: 'system',
          content:
            'You are a professional resume assistant. Write exactly 5 concise resume bullet points tailored to the job description. Return each bullet on its own line. Do not use markdown.'
        },
        {
          role: 'user',
          content: `Job description:\n${jobDescription}`
        }
      ]
    });

    const content = response.choices[0].message.content || '';

    const bullets = content
      .split('\n')
      .map((line) => line.replace(/^[-•\d.]+\s*/, '').trim())
      .filter((line) => line.length > 0)
      .slice(0, 5);

    return res.json({
      bullets: bullets
    });
  } catch (error) {
    console.error('AI resume tailoring failed:', error);

    return res.status(500).json({
      error: error.message || 'AI failed'
    });
  }
});

module.exports = router;