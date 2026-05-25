import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { adminAPI } from '../../services/api';
import { D } from '../../utils/helpers';
import AppLayout from '../../components/layout/AppLayout';
import { Card, Button, Badge, Spinner, Table, Th, Td, GradeBadge, StatusBadge, SpecBadge } from '../../components/ui';

// Map letter grade → typical numeric grade for display when total_grade is missing
const LETTER_TO_NUMERIC = {
  'A+': 97, 'A': 92, 'A-': 88,
  'B+': 85, 'B': 80, 'B-': 77,
  'C+': 73, 'C': 70, 'C-': 67,
  'D+': 63, 'D': 60, 'D-': 57,
  'F': 45, 'Abs': 0,
};

// Grade points for GPA computation
const LETTER_TO_POINTS = {
  'A+': 4.0, 'A': 3.7, 'A-': 3.4,
  'B+': 3.2, 'B': 3.0, 'B-': 2.8,
  'C+': 2.6, 'C': 2.4, 'C-': 2.2,
  'D+': 2.0, 'D': 1.5, 'D-': 1.0,
  'F': 0.0, 'Abs': 0.0,
};

function computeSemGPA(courses) {
  let totalPoints = 0, totalCredits = 0;
  for (const c of courses) {
    const grade = c.letterGrade || c.letter_grade;
    const credits = Number(c.credits || 0);
    if (grade && LETTER_TO_POINTS[grade] !== undefined && credits > 0) {
      totalPoints += LETTER_TO_POINTS[grade] * credits;
      totalCredits += credits;
    }
  }
  if (totalCredits === 0) return null;
  return (totalPoints / totalCredits).toFixed(2);
}

function getGradeDisplay(course) {
  const total = course.totalGrade ?? course.total_grade;
  if (total !== null && total !== undefined) return Number(total).toFixed(1);
  const letter = course.letterGrade || course.letter_grade;
  if (letter && LETTER_TO_NUMERIC[letter] !== undefined) return LETTER_TO_NUMERIC[letter];
  return '—';
}

function getGPAColor(gpa) {
  const n = Number(gpa || 0);
  if (n >= 3.5) return 'var(--color-success)';
  if (n >= 2.0) return 'var(--color-warning)';
  return 'var(--color-error)';
}

export default function AdminStudentDetail() {
  const { studentId } = useParams();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    adminAPI.getStudentDetail(studentId)
      .then(r => setData(D(r)))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, [studentId]);

  if (loading) return <AppLayout><Spinner /></AppLayout>;
  if (!data) return <AppLayout><div style={{ textAlign: 'center', padding: '40px', color: 'var(--color-error)' }}>الطالب غير موجود</div></AppLayout>;

  const st  = data.student || {};
  const ac  = data.academicInfo || {};
  const sems = data.semesters || [];

  const reloadData = async () => {
    try {
      const r = await adminAPI.getStudentDetail(studentId);
      setData(D(r));
    } catch {
      toast.error('فشل تحديث البيانات');
    }
  };

  return (
    <AppLayout>
      <Card
        title={st.fullNameAr || st.full_name_ar || 'بيانات الطالب'}
        headerActions={
          <Link to="/admin/students" style={{ textDecoration: 'none' }}>
            <Button variant="ghost" size="sm">← العودة</Button>
          </Link>
        }
      >
        {/* ── Student meta ────────────────────────────────────── */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '16px', marginBottom: '20px' }}>
          {[
            ['الكود الأكاديمي', st.studentCode || st.student_code],
            ['التخصص', null],
            ['المستوى', st.currentLevel || st.current_level || '—'],
            ['الحالة الأكاديمية', null],
          ].map(([label], i) => (
            <div key={label} style={{ background: 'var(--color-gray-50)', padding: '16px', borderRadius: 'var(--radius-lg)' }}>
              <div style={{ fontSize: '12px', color: 'var(--color-gray-500)', marginBottom: '4px' }}>{label}</div>
              {i === 1 ? <SpecBadge spec={(st.specialization || '').toUpperCase()} /> :
               i === 3 ? <StatusBadge status={st.academicStatus || st.academic_status || 'نشط'} /> :
               <div style={{ fontWeight: 700, fontSize: '16px', color: 'var(--color-gray-800)' }}>
                 {i === 0 ? (st.studentCode || st.student_code) : (st.currentLevel || st.current_level || '—')}
               </div>
              }
            </div>
          ))}
        </div>

        {/* ── Academic summary ────────────────────────────────── */}
        <h3 style={{ fontSize: '16px', color: 'var(--color-gray-800)', marginBottom: '12px', borderBottom: '1px solid var(--color-gray-200)', paddingBottom: '8px' }}>
          السجل الأكاديمي
        </h3>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: '12px', marginBottom: '20px' }}>
          {[
            ['المعدل التراكمي',  Number(ac.cgpa || 0).toFixed(2),           Number(ac.cgpa) < 2 ? 'var(--color-error)' : 'var(--color-success)'],
            ['الساعات المكتملة', ac.totalCreditsPassed || ac.total_credits_passed || 0, 'var(--color-gray-800)'],
            ['الساعات المطلوبة', ac.requiredCredits || 138,                  'var(--color-primary)'],
            ['الإنذارات',        ac.consecutiveWarnings || ac.consecutive_warnings || 0, Number(ac.consecutiveWarnings) > 0 ? 'var(--color-error)' : 'var(--color-gray-800)'],
            ['متوسط النقاط',     ac.totalPoints || ac.total_points || 0,    'var(--color-gray-800)'],
          ].map(([l, v, c]) => (
            <div key={l} style={{ border: '1px solid var(--color-gray-200)', borderRadius: 'var(--radius-md)', padding: '12px', textAlign: 'center' }}>
              <div style={{ fontSize: '11px', color: 'var(--color-gray-500)', marginBottom: '4px' }}>{l}</div>
              <div style={{ fontSize: '18px', fontWeight: 800, color: c }}>{v}</div>
            </div>
          ))}
        </div>

        <div style={{ display: 'flex', gap: '10px', marginBottom: '24px' }}>
          <Button variant="ghost" size="sm" onClick={reloadData}>تحديث البيانات</Button>
        </div>

        {/* ── Semester tables ─────────────────────────────────── */}
        {sems.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '40px', color: 'var(--color-gray-500)', border: '1px solid var(--color-gray-200)', borderRadius: 'var(--radius-lg)' }}>
            لا يوجد سجل أكاديمي متاح لهذا الطالب حتى الآن.
          </div>
        ) : (
          sems.map(s => {
            // Use server-provided GPA; fall back to client-computed if it's 0/null
            const serverGPA = Number(s.gpa || 0);
            const computedGPA = computeSemGPA(s.courses || []);
            const displayGPA = serverGPA > 0 ? serverGPA.toFixed(2) : (computedGPA || '—');
            const gpaColor   = (serverGPA > 0 || computedGPA) ? getGPAColor(displayGPA) : 'var(--color-gray-500)';

            return (
              <div key={s.semesterId || s.semester_id} style={{ marginBottom: '24px', border: '1px solid var(--color-gray-200)', borderRadius: 'var(--radius-lg)', overflow: 'hidden' }}>

                {/* Semester header */}
                <div style={{ background: 'var(--color-gray-50)', padding: '12px 16px', borderBottom: '1px solid var(--color-gray-200)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <h4 style={{ margin: 0, fontSize: '14px', color: 'var(--color-gray-800)' }}>{s.semesterName || s.semester_name}</h4>
                </div>

                {/* GPA banner — shown ABOVE the table, below the header */}
                <div style={{ background: 'var(--color-white)', padding: '10px 16px', borderBottom: '1px solid var(--color-gray-100)', display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <span style={{ fontSize: '13px', color: 'var(--color-gray-600)' }}>المعدل الفصلي</span>
                  <span style={{ fontSize: '22px', fontWeight: 800, color: gpaColor }}>{displayGPA}</span>
                  {computedGPA && serverGPA === 0 && (
                    <span style={{ fontSize: '11px', color: 'var(--color-gray-400)', marginRight: 'auto' }}>محسوب تلقائياً</span>
                  )}
                </div>

                {/* Course table */}
                <Table>
                  <thead>
                    <tr>
                      <Th>المقرر</Th>
                      <Th>الساعات</Th>
                      <Th>الدرجة</Th>
                      <Th>التقدير</Th>
                    </tr>
                  </thead>
                  <tbody>
                    {(s.courses || []).map(c => (
                      <tr key={c.enrollmentId || c.enrollment_id || c.courseCode || c.course_code}>
                        <Td style={{ fontWeight: 600 }}>{c.courseName || c.course_name}</Td>
                        <Td>{c.credits}</Td>
                        <Td style={{ fontWeight: 600, color: 'var(--color-gray-700)' }}>{getGradeDisplay(c)}</Td>
                        <Td><GradeBadge grade={c.letterGrade || c.letter_grade} /></Td>
                      </tr>
                    ))}
                  </tbody>
                </Table>
              </div>
            );
          })
        )}
      </Card>
    </AppLayout>
  );
}
