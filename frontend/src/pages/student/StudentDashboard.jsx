import React, { useState, useEffect } from 'react';
import { studentAPI } from '../../services/api';
import { D } from '../../utils/helpers';
import AppLayout from '../../components/layout/AppLayout';
import { Card, StatCard, Table, Th, Td, Spinner, EmptyState } from '../../components/ui';
import { useBylaw } from '../../contexts/BylawContext';
import { BarChart3, BookOpen, Trophy, AlertTriangle, GraduationCap } from 'lucide-react';

export default function StudentDashboard() {
  const [d, setD] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const { bylaw } = useBylaw();

  useEffect(() => {
    studentAPI.getDashboard()
      .then(r => setD(D(r)))
      .catch(() => setError(true))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <AppLayout><Spinner /></AppLayout>;

  if (error || !d) {
    return (
      <AppLayout>
        <div style={{ textAlign: 'center', padding: '48px', color: 'var(--color-gray-500)' }}>
          <AlertTriangle size={32} color="var(--color-warning)" style={{ marginBottom: '12px' }} />
          <div style={{ fontSize: '16px', fontWeight: 700, marginBottom: '6px' }}>تعذر تحميل لوحة التحكم</div>
          <div style={{ fontSize: '13px' }}>يرجى المحاولة مرة أخرى لاحقاً</div>
        </div>
      </AppLayout>
    );
  }

  const st = d?.student || d || {};
  
  // [B3-FIX] Backend returns { enrollments, weeklyGrid }, not an array.
  // We extract the enrollments array safely to prevent the EmptyState fallback.
  const scheduleData = d?.schedule || d?.currentSchedule || { enrollments: [] };
  const scheduleList = Array.isArray(scheduleData) ? scheduleData : (scheduleData.enrollments || []);

  const warnings = d?.warnings || [];
  
  const totalCredits = bylaw?.metadata?.total_credit_hours || 138;
  const creditsPassed = Number(st.totalCreditsPassed ?? st.total_credits_passed ?? 0);
  const cgpa = Number(st.cgpa || 0);
  const warningCount = Number(st.consecutiveWarnings ?? st.consecutive_warnings ?? st.totalWarnings ?? st.total_warnings ?? 0);
  // Program: عام for level 1-2, specialization for level 3-4
  const program = st.program || st.specialization || 'عام';

  const stats = [
    { lbl: 'المعدل التراكمي', val: cgpa.toFixed(2), ic: <BarChart3 size={22} color="var(--color-primary)" />, bg: 'var(--color-primary-50)' },
    { lbl: 'الساعات المكتملة', val: `${creditsPassed}/${totalCredits}`, ic: <BookOpen size={22} color="var(--color-success)" />, bg: 'var(--color-success-light)' },
    { lbl: 'المستوى الحالي', val: st.currentLevel || st.current_level || '—', ic: <Trophy size={22} color="var(--color-spec-is)" />, bg: 'var(--color-spec-is-bg)' },
    { lbl: 'البرنامج', val: program, ic: <GraduationCap size={22} color="#7c3aed" />, bg: 'rgba(124, 58, 237, 0.08)' },
    { lbl: 'الإنذارات', val: warningCount, ic: <AlertTriangle size={22} color="var(--color-warning)" />, bg: 'var(--color-warning-light)' },
  ];

  return (
    <AppLayout>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '14px', marginBottom: '20px' }}>
        {stats.map(s => (
          <StatCard key={s.lbl} label={s.lbl} value={s.val} icon={s.ic} iconBg={s.bg} />
        ))}
      </div>

      <Card title="الجدول الدراسي الحالي">
        {scheduleList.length > 0 ? (
          <Table>
            <thead>
              <tr>
                <Th>المقرر</Th>
                <Th>الدكتور</Th>
                <Th>الموعد</Th>
              </tr>
            </thead>
            <tbody>
              {scheduleList.map((c, i) => (
                <tr key={i}>
                  <Td style={{ fontWeight: 600 }}>{c.name_ar || c.courseName || c.course_name || '—'}</Td>
                  <Td>{c.doctor_name_ar || c.doctorName || c.doctor_name || '—'}</Td>
                  <Td>
                    {c.schedule_slots && c.schedule_slots.length > 0
                      ? c.schedule_slots.map(s => {
                          const dayAr = { Sat: 'السبت', Sun: 'الأحد', Mon: 'الاثنين', Tue: 'الثلاثاء', Wed: 'الأربعاء', Thu: 'الخميس' }[s.day] || s.day;
                          // [FIX-TIME] Strip trailing seconds (HH:MM:SS → HH:MM) and guarantee start < end order
                          const fmt = t => (t || '').replace(/^(\d{2}:\d{2}):\d{2}$/, '$1').replace(/^(\d{2}:\d{2})$/, '$1');
                          const start = fmt(s.start);
                          const end   = fmt(s.end);
                          // If start > end the values were stored reversed — swap them
                          const [from, to] = start > end ? [end, start] : [start, end];
                          return `${dayAr} ${from} - ${to}`;
                        }).join('، ')
                      : (c.schedule || c.time || '—')}
                  </Td>
                </tr>
              ))}
            </tbody>
          </Table>
        ) : (
          <EmptyState description="لا توجد مقررات مسجلة حالياً" />
        )}
      </Card>

      {warnings.length > 0 && (
        <div style={{ background: 'var(--color-warning-light)', border: '1px solid #fde68a', borderRadius: 'var(--radius-lg)', padding: '16px', marginTop: '16px' }}>
          <div style={{ fontWeight: 700, color: 'var(--color-warning-dark)', marginBottom: '8px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <AlertTriangle size={18} />
            تحذيرات أكاديمية
          </div>
          {warnings.map((w, i) => (
            <div key={i} style={{ fontSize: '13px', color: 'var(--color-warning-dark)' }}>
              {w.description || w.message || w.semester_label || '—'}
            </div>
          ))}
        </div>
      )}
    </AppLayout>
  );
}
