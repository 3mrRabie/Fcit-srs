import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { adminAPI } from '../../services/api';
import { D } from '../../utils/helpers';
import AppLayout from '../../components/layout/AppLayout';
import { Card, StatCard, Table, Th, Td, Badge, Spinner, Button } from '../../components/ui';
import { Users, UserCheck, BookOpen, AlertTriangle } from 'lucide-react';

export default function AdminDashboard() {
  const [d, setD] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    adminAPI.getDashboard()
      .then(r => setD(D(r)))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <AppLayout><Spinner /></AppLayout>;

  const st = d?.stats || d || {};
  const stats = [
    { lbl: 'إجمالي الطلاب', val: st?.totalStudents ?? st?.total_students ?? st?.active_students ?? '—', ic: <Users size={22} color="var(--color-primary)" />, bg: 'var(--color-primary-50)' },
    { lbl: 'الدكاترة', val: st?.totalDoctors ?? st?.total_doctors ?? st?.total_doctors ?? '—', ic: <UserCheck size={22} color="var(--color-success)" />, bg: 'var(--color-success-light)' },
    { lbl: 'المقررات', val: st?.totalCourses ?? st?.total_courses ?? '—', ic: <BookOpen size={22} color="var(--color-spec-is)" />, bg: 'var(--color-spec-is-bg)' },
    { lbl: 'إنذارات نشطة', val: st?.activeWarnings ?? st?.active_warnings ?? st?.warning_students ?? 0, ic: <AlertTriangle size={22} color="var(--color-warning)" />, bg: 'var(--color-warning-light)' }
  ];

  return (
    <AppLayout>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '14px', marginBottom: '20px' }}>
        {stats.map(s => (
          <StatCard key={s.lbl} label={s.lbl} value={s.val} icon={s.ic} iconBg={s.bg} />
        ))}
      </div>
      <Card
        title="الطلاب ذوو الإنذارات الأكاديمية"
        headerActions={
          <Link to="/admin/students" style={{ textDecoration: 'none' }}>
            <Button variant="ghost" size="sm">عرض الكل</Button>
          </Link>
        }
      >
        {d?.recentWarnings?.length > 0 ? (
          <Table>
            <thead>
              <tr>
                <Th>الطالب</Th>
                <Th>الكود</Th>
                <Th>المستوى</Th>
                <Th>المعدل</Th>
                <Th>الحالة</Th>
                <Th>إنذارات</Th>
              </tr>
            </thead>
            <tbody>
              {d.recentWarnings.map(w => (
                <tr key={w.studentId || w.student_id || w.id}>
                  <Td style={{ fontWeight: 600 }}>{w.studentName || w.student_name || w.name}</Td>
                  <Td style={{ fontSize: '12px', color: 'var(--color-gray-500)' }}>{w.studentCode || w.student_code}</Td>
                  <Td>{w.currentLevel || w.current_level}</Td>
                  <Td style={{ color: 'var(--color-error)', fontWeight: 700 }}>{Number(w.cgpa || 0).toFixed(2)}</Td>
                  <Td>
                    {w.academicStatus === 'probation' || w.academic_status === 'probation' ? (
                      <Badge variant="error">تحت الملاحظة (Probation)</Badge>
                    ) : (
                      <Badge variant="warning">إنذار أكاديمي</Badge>
                    )}
                  </Td>
                  <Td>
                    <Badge variant="error">{w.warningCount || w.warning_count || w.totalWarnings}</Badge>
                  </Td>
                </tr>
              ))}
            </tbody>
          </Table>
        ) : (
          <div style={{ textAlign: 'center', padding: '32px', color: 'var(--color-gray-400)' }}>لا توجد إنذارات نشطة 🎉</div>
        )}
      </Card>
    </AppLayout>
  );
}
