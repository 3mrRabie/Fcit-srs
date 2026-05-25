import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { adminAPI } from '../../services/api';
import { D } from '../../utils/helpers';
import AppLayout from '../../components/layout/AppLayout';
import { Card, Button, Badge, Spinner, Table, Th, Td, GradeBadge, StatusBadge, SpecBadge } from '../../components/ui';

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

  const st = data.student || {};
  const ac = data.academicInfo || {};
  const sems = data.semesters || [];

  const reloadData = async () => {
    try {
      const r = await adminAPI.getStudentDetail(studentId);
      setData(D(r));
    } catch (e) {
      toast.error('فشل تحديث البيانات');
    }
  };

  return (
    <AppLayout>
      <Card
        title={st.fullNameAr || st.full_name_ar || 'بيانات الطالب'}
        headerActions={
          <div style={{ display: 'flex', gap: '8px' }}>
            <Link to="/admin/students" style={{ textDecoration: 'none' }}>
              <Button variant="ghost" size="sm">← العودة</Button>
            </Link>
          </div>
        }
      >
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '16px', marginBottom: '20px' }}>
          <div style={{ background: 'var(--color-gray-50)', padding: '16px', borderRadius: 'var(--radius-lg)' }}>
            <div style={{ fontSize: '12px', color: 'var(--color-gray-500)', marginBottom: '4px' }}>الكود الأكاديمي</div>
            <div style={{ fontWeight: 700, fontSize: '16px', color: 'var(--color-gray-800)' }}>{st.studentCode || st.student_code}</div>
          </div>
          <div style={{ background: 'var(--color-gray-50)', padding: '16px', borderRadius: 'var(--radius-lg)' }}>
            <div style={{ fontSize: '12px', color: 'var(--color-gray-500)', marginBottom: '4px' }}>التخصص</div>
            <SpecBadge spec={(st.specialization || '').toUpperCase()} />
          </div>
          <div style={{ background: 'var(--color-gray-50)', padding: '16px', borderRadius: 'var(--radius-lg)' }}>
            <div style={{ fontSize: '12px', color: 'var(--color-gray-500)', marginBottom: '4px' }}>المستوى</div>
            <div style={{ fontWeight: 700, fontSize: '16px', color: 'var(--color-gray-800)' }}>{st.currentLevel || st.current_level || '—'}</div>
          </div>
          <div style={{ background: 'var(--color-gray-50)', padding: '16px', borderRadius: 'var(--radius-lg)' }}>
            <div style={{ fontSize: '12px', color: 'var(--color-gray-500)', marginBottom: '4px' }}>الحالة الأكاديمية</div>
            <StatusBadge status={st.academicStatus || st.academic_status || 'نشط'} />
          </div>
        </div>

        <h3 style={{ fontSize: '16px', color: 'var(--color-gray-800)', marginBottom: '12px', borderBottom: '1px solid var(--color-gray-200)', paddingBottom: '8px' }}>
          السجل الأكاديمي
        </h3>
        
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: '12px', marginBottom: '24px' }}>
          {[
            ['المعدل التراكمي', Number(ac.cgpa || 0).toFixed(2), Number(ac.cgpa) < 2 ? 'var(--color-error)' : 'var(--color-success)'],
            ['الساعات المكتملة', ac.totalCreditsPassed || ac.total_credits_passed || 0, 'var(--color-gray-800)'],
            ['الساعات المطلوبة', ac.requiredCredits || 138, 'var(--color-primary)'],
            ['الإنذارات', ac.consecutiveWarnings || ac.consecutive_warnings || 0, Number(ac.consecutiveWarnings) > 0 ? 'var(--color-error)' : 'var(--color-gray-800)'],
            ['متوسط النقاط', ac.totalPoints || ac.total_points || 0, 'var(--color-gray-800)']
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

        {sems.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '40px', color: 'var(--color-gray-500)', border: '1px solid var(--color-gray-200)', borderRadius: 'var(--radius-lg)' }}>
            لا يوجد سجل أكاديمي متاح لهذا الطالب حتى الآن.
          </div>
        ) : (
          sems.map(s => (
            <div key={s.semesterId || s.semester_id} style={{ marginBottom: '20px', border: '1px solid var(--color-gray-200)', borderRadius: 'var(--radius-lg)', overflow: 'hidden' }}>
              <div style={{ background: 'var(--color-gray-50)', padding: '12px 16px', borderBottom: '1px solid var(--color-gray-200)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <h4 style={{ margin: 0, fontSize: '14px', color: 'var(--color-gray-800)' }}>{s.semesterName || s.semester_name}</h4>
                <div style={{ fontSize: '13px', color: 'var(--color-gray-600)' }}>المعدل الفصلي: <strong style={{ color: 'var(--color-primary)' }}>{Number(s.gpa || 0).toFixed(2)}</strong></div>
              </div>
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
                      <Td>{c.totalGrade ?? c.total_grade ?? '—'}</Td>
                      <Td><GradeBadge grade={c.letterGrade || c.letter_grade} /></Td>
                    </tr>
                  ))}
                </tbody>
              </Table>
            </div>
          ))
        )}
      </Card>
    </AppLayout>
  );
}
