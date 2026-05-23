import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { doctorAPI } from '../../services/api';
import { D } from '../../utils/helpers';
import AppLayout from '../../components/layout/AppLayout';
import { Card, StatCard, Table, Th, Td, Spinner, Button } from '../../components/ui';
import { BookOpen, Users, Edit3 } from 'lucide-react';

export default function DoctorDashboard() {
  const [d, setD] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    doctorAPI.getDashboard()
      .then(r => setD(D(r)))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <AppLayout><Spinner /></AppLayout>;

  const stats = [
    { lbl: 'مقرراتي', val: d?.totalCourses || d?.courses?.length || '—', ic: <BookOpen size={22} color="var(--color-primary)" />, bg: 'var(--color-primary-50)' },
    { lbl: 'إجمالي الطلاب', val: d?.totalStudents || d?.total_students || '—', ic: <Users size={22} color="var(--color-success)" />, bg: 'var(--color-success-light)' },
    { lbl: 'درجات منتظرة', val: d?.pendingGrades || d?.pending_grades || '—', ic: <Edit3 size={22} color="var(--color-spec-is)" />, bg: 'var(--color-spec-is-bg)' }
  ];

  return (
    <AppLayout>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '14px', marginBottom: '20px' }}>
        {stats.map(s => (
          <StatCard key={s.lbl} label={s.lbl} value={s.val} icon={s.ic} iconBg={s.bg} />
        ))}
      </div>
      <Card title="مقرراتي هذا الفصل">
        {d?.courses?.length > 0 ? (
          <Table>
            <thead>
              <tr>
                <Th>المقرر</Th>
                <Th>الكود</Th>
                <Th>الطلاب</Th>
                <Th>الإجراء</Th>
              </tr>
            </thead>
            <tbody>
              {d.courses.map(c => {
                const rid = c.offering_id || c.offeringId || c.id;
                return (
                  <tr key={rid}>
                    <Td style={{ fontWeight: 600 }}>{c.courseName || c.course_name}</Td>
                    <Td style={{ fontSize: '12px', color: 'var(--color-gray-500)' }}>{c.courseCode || c.course_code}</Td>
                    <Td>{c.enrolledCount || c.enrolled_count || 0}</Td>
                    <Td>
                      <Link to={`/doctor/courses/${rid}`} style={{ textDecoration: 'none' }}>
                        <Button size="sm">عرض الطلاب</Button>
                      </Link>
                    </Td>
                  </tr>
                );
              })}
            </tbody>
          </Table>
        ) : (
          <div style={{ textAlign: 'center', padding: '32px', color: 'var(--color-gray-400)' }}>لا توجد مقررات حالياً</div>
        )}
      </Card>
    </AppLayout>
  );
}
