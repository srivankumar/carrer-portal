import express from 'express';
import multer from 'multer';
import {
  applyForJob,
  checkApplicationStatus,
  getUserApplications,
  getAllApplications,
  updateApplicationStatus,
  getTopCandidates,
  downloadResume,
} from '../controllers/applicationController.js';
import { authenticate, isAdmin } from '../middleware/auth.js';

const router = express.Router();

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024,
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Only PDF and Word documents are allowed'));
    }
  },
});

router.post('/apply', authenticate, upload.single('resume'), applyForJob);
router.get('/check/:jobId', authenticate, checkApplicationStatus);
router.get('/my-applications', authenticate, getUserApplications);
router.get('/all', authenticate, isAdmin, getAllApplications);
router.put('/:id/status', authenticate, isAdmin, updateApplicationStatus);
router.get('/top-candidates', authenticate, isAdmin, getTopCandidates);
router.get('/download/:key', authenticate, downloadResume);

export default router;
