import React, { useState, useEffect } from 'react';
import { studentAPI } from '../../services/api';
import { D } from '../../utils/helpers';
import AppLayout from '../../components/layout/AppLayout';
import { Card, Table, Th, Td, GradeBadge, Spinner } from '../../components/ui';

export default function TranscriptPage() {
  const [d, setD] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    studentAPI.getTranscript()
      .then(r => setD(D(r)))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <AppLayout><Spinner /></AppLayout>;

  const st = d?.student || d || {};

  return (
    <AppLayout>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '14px', marginBottom: '20px' }}>
        {[
          ['المعدل التراكمي', Number(st.cgpa || 0).toFixed(2) || '—'],
          ['إجمالي الساعات', st.totalCredits || st.total_credits || '—'],
          ['المستوى', st.currentLevel || st.current_level || '—']
        ].map(([l, v]) => (
          <div key={l} style={{ background: 'var(--color-white)', border: '1px solid var(--color-gray-200)', borderRadius: 'var(--radius-xl)', padding: '20px', textAlign: 'center' }}>
            <div style={{ fontSize: '12px', color: 'var(--color-gray-500)', marginBottom: '4px' }}>{l}</div>
            <div style={{ fontSize: '28px', fontWeight: 800, color: 'var(--color-primary)' }}>{v}</div>
          </div>
        ))}
      </div>

      {(d?.semesters || d?.transcript || []).map(s => (
        <Card
          key={s.id || s.semester_id}
          title={s.name || s.academicYear || s.academic_year}
          headerActions={
            <div style={{ fontSize: '13px', color: 'var(--color-gray-600)' }}>
              المعدل: <strong style={{ color: 'var(--color-primary)' }}>{Number(s.gpa || s.semester_gpa || 0).toFixed(2)}</strong>
            </div>
          }
        >
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
              {(s.courses || s.enrollments || []).map(c => (
                <tr key={c.id}>
                  <Td>{c.nameAr || c.name_ar || c.courseName || c.course_name}</Td>
                  <Td>{c.credits || c.credit_hours}</Td>
                  <Td>{c.totalGrade ?? c.total_grade ?? '—'}</Td>
                  <Td>
                    <GradeBadge grade={c.letterGrade || c.letter_grade} />
                  </Td>
                </tr>
              ))}
            </tbody>
          </Table>
        </Card>
      ))}

      {!(d?.semesters || d?.transcript)?.length && (
        <Card>
          <div style={{ textAlign: 'center', padding: '32px', color: 'var(--color-gray-400)' }}>لا توجد سجلات درجات</div>
        </Card>
      )}
    </AppLayout>
  );
}
