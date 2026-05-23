import React, { useState, useEffect } from 'react';
import { studentAPI, sharedAPI } from '../../services/api';
import { D } from '../../utils/helpers';
import AppLayout from '../../components/layout/AppLayout';
import { Card, Button, Spinner, Badge, StatusBadge } from '../../components/ui';

class ErrorBoundary extends React.Component {
  constructor(props) { super(props); this.state = { hasError: false, error: null }; }
  static getDerivedStateFromError(error) { return { hasError: true, error }; }
  componentDidCatch(error, errorInfo) { console.error('Schedule rendering error:', error, errorInfo); }
  render() {
    if (this.state.hasError) {
      return (
        <div style={{ padding: '24px', textAlign: 'center', background: '#fef2f2', borderRadius: '8px', color: '#dc2626', border: '1px solid #fca5a5' }}>
          <h3 style={{ margin: '0 0 8px 0' }}>⚠️ عذراً، حدث خطأ أثناء عرض الجدول</h3>
          <p style={{ margin: 0, fontSize: '14px' }}>يبدو أن بيانات الجدول غير متوافقة أو معطوبة.</p>
        </div>
      );
    }
    return this.props.children;
  }
}

export default function SchedulePage() {
  const [sems, setSems] = useState([]);
  const [semId, setSemId] = useState('');
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  const DAYS = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'];
  const DAY_AR = { Sat: 'السبت', Sun: 'الأحد', Mon: 'الاثنين', Tue: 'الثلاثاء', Wed: 'الأربعاء', Thu: 'الخميس' };
  const SLOT_COLORS = ['#dbeafe', '#dcfce7', '#fef9c3', '#fce7f3', '#e0e7ff', '#fff7ed'];

  useEffect(() => {
    sharedAPI.getSemesters().then(r => {
      const allSems = D(r) || [];
      const current = allSems.find(x => x.status === 'active') || allSems.find(x => x.status === 'registration') || allSems.find(x => x.status === 'grading') || allSems[0];
      
      if (current) {
        setSems(allSems);
        setSemId(current.id);
      } else {
        setSems(allSems);
      }
    }).catch(() => {});
  }, []);

  useEffect(() => {
    if (!semId) { setLoading(false); return; }
    setLoading(true);
    studentAPI.getSchedule(semId)
      .then(r => setData(D(r)))
      .catch(() => setData(null))
      .finally(() => setLoading(false));
  }, [semId]);

  const printSchedule = () => {
    const grid = data?.weeklyGrid || {};
    const enrollments = data?.enrollments || [];
    const semLabel = sems.find(s => s.id == semId)?.label || '';

    const doc = `<!DOCTYPE html>
<html dir="rtl"><head><meta charset="UTF-8"><title>الجدول الدراسي</title>
<style>
  * { box-sizing: border-box; }
  body { font-family: 'Segoe UI', Arial, sans-serif; direction: rtl; margin: 0; padding: 20px; color: #1e293b; }
  h1 { text-align: center; color: #1b4f9e; font-size: 20px; margin-bottom: 4px; }
  .sub { text-align: center; color: #64748b; font-size: 13px; margin-bottom: 20px; }
  table { width: 100%; border-collapse: collapse; margin-bottom: 24px; }
  th { background: #1b4f9e; color: white; padding: 10px; font-size: 13px; }
  td { border: 1px solid #e2e8f0; padding: 8px; vertical-align: top; min-width: 90px; }
  .day-cell { background: #f8fafc; font-weight: 700; text-align: center; font-size: 13px; }
  .slot { background: #eff6ff; border-radius: 6px; padding: 6px 8px; margin-bottom: 4px; font-size: 11px; }
  .slot-code { font-weight: 700; font-size: 13px; color: #1d4ed8; }
  .empty { color: #94a3b8; font-size: 11px; text-align: center; padding: 12px; }
  h2 { font-size: 16px; margin: 20px 0 8px; border-bottom: 2px solid #1b4f9e; padding-bottom: 4px; }
  .course-row { display: flex; gap: 8px; align-items: center; padding: 8px 0; border-bottom: 1px solid #f1f5f9; }
  @media print { body { padding: 10px; } }
</style></head>
<body>
  <h1>الجدول الدراسي الأسبوعي للطالب</h1>
  <div class="sub">${semLabel} — مطبوع ${new Date().toLocaleDateString('ar-EG')}</div>
  <table>
    <thead><tr><th>الوقت</th>${DAYS.map(d => `<th>${DAY_AR[d]}</th>`).join('')}</tr></thead>
    <tbody>
      ${[...Array(14)].map((_, i) => {
        const hour = `${String(8 + i).padStart(2, '0')}:00`;
        return `<tr>
          <td class="day-cell">${hour}</td>
          ${DAYS.map(day => {
            const slots = (grid[day] || []).filter(s => s.start && s.start.startsWith(hour.slice(0, 2)));
            return `<td>${slots.length === 0
              ? ''
              : slots.map(s => `<div class="slot">
                  <div class="slot-code">${s.courseCode || ''}</div>
                  <div>${s.start} - ${s.end}</div>
                  <div style="color:#64748b;font-size:10px">${s.room || ''} | ${s.type === 'lecture' ? 'محاضرة' : 'معمل'}</div>
                </div>`).join('')
            }</td>`;
          }).join('')}
        </tr>`;
      }).join('')}
    </tbody>
  </table>
  <h2>تفاصيل المقررات المسجلة</h2>
  ${enrollments.map(o => `
    <div class="course-row">
      <strong style="min-width:70px;color:#1d4ed8">${o.code}</strong>
      <span style="flex:1">${o.name_ar || o.name_en}</span>
      <span style="color:#64748b;font-size:12px">${o.doctor_name_ar || o.doctor_name || '—'}</span>
    </div>`).join('')}
  <script>window.onload=()=>window.print();</script>
</body></html>`;
    const win = window.open('', '_blank');
    win.document.write(doc);
    win.document.close();
  };

  const currentSem = sems.find(s => s.id == semId);
  const grid = data?.weeklyGrid || {};
  const enrollments = data?.enrollments || [];
  const hasSchedule = enrollments.length > 0;

  return (
    <AppLayout>
      <Card
        title="جدولي الدراسي"
        headerActions={
          <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
            {currentSem && (
              <Badge variant={currentSem.status === 'active' ? 'success' : currentSem.status === 'registration' ? 'info' : 'default'} style={{ fontSize: '11px' }}>
                {currentSem.status === 'active' ? 'نشط' : currentSem.status === 'registration' ? 'تسجيل' : currentSem.status === 'grading' ? 'رصد درجات' : 'مغلق'}
              </Badge>
            )}
            <select
              style={{ padding: '6px 10px', borderRadius: 'var(--radius-md)', border: '1px solid var(--color-gray-200)', fontSize: '12px' }}
              value={semId || ''}
              onChange={e => { setSemId(e.target.value); setData(null); }}
            >
              {sems.map(s => (
                <option key={s.id} value={s.id}>
                  {s.label || `${s.semester_type || ''} ${s.year_label || ''}`}
                </option>
              ))}
            </select>
            <Button size="sm" onClick={printSchedule} disabled={!hasSchedule}>🖨️ طباعة / PDF</Button>
          </div>
        }
      >
        {loading ? <Spinner /> : hasSchedule ? (
          <ErrorBoundary>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
              <div style={{ overflowX: 'auto' }}>
              <table style={{ width: '100%', borderCollapse: 'collapse', direction: 'rtl' }}>
                <thead>
                  <tr>
                    <th style={{ background: 'var(--color-primary)', color: '#fff', padding: '10px 14px', fontSize: '13px', textAlign: 'center', borderRadius: '0 8px 0 0' }}>اليوم</th>
                    {DAYS.map((d, i) => (
                      <th key={d} style={{ background: 'var(--color-primary)', color: '#fff', padding: '10px 14px', fontSize: '13px', textAlign: 'center', borderRadius: i === DAYS.length - 1 ? '8px 0 0 0' : '0' }}>
                        {DAY_AR[d]}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {[...Array(14)].map((_, i) => {
                    const hour = `${String(8 + i).padStart(2, '0')}:00`;
                    return (
                      <tr key={hour}>
                        <td style={{ background: 'var(--color-gray-50)', padding: '8px 12px', fontSize: '12px', color: 'var(--color-gray-600)', fontWeight: 600, textAlign: 'center', border: '1px solid var(--color-gray-100)' }}>
                          {hour}
                        </td>
                        {DAYS.map(day => {
                          const slots = (Array.isArray(grid[day]) ? grid[day] : []).filter(s => s?.start && s.start.startsWith(hour.slice(0, 2)));
                          return (
                            <td key={day} style={{ border: '1px solid var(--color-gray-100)', padding: '4px', verticalAlign: 'top', minWidth: '110px', minHeight: '44px' }}>
                              {slots.map((s, si) => (
                                <div key={si} style={{ background: SLOT_COLORS[si % SLOT_COLORS.length], borderRadius: '8px', padding: '6px 8px', marginBottom: '2px', borderRight: '3px solid var(--color-primary)' }}>
                                  <div style={{ fontWeight: 700, fontSize: '12px', color: 'var(--color-primary-dark)' }}>{s.courseCode}</div>
                                  <div style={{ fontSize: '10px', color: 'var(--color-gray-700)' }}>{s.courseNameAr || s.courseName?.substring(0, 20)}</div>
                                  <div style={{ fontSize: '10px', color: 'var(--color-gray-600)' }}>{s.start} - {s.end}</div>
                                  <div style={{ fontSize: '10px', color: 'var(--color-gray-500)' }}>{s.room || '—'}</div>
                                </div>
                              ))}
                            </td>
                          );
                        })}
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>

            <div>
              <h3 style={{ fontSize: '16px', color: 'var(--color-gray-800)', marginBottom: '12px', paddingRight: '4px', borderRight: '4px solid var(--color-primary)' }}>
                تفاصيل المقررات المسجلة
              </h3>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                {enrollments.map((c, i) => {
                  const att = Number(c.attendance_pct || 0);
                  const attColor = att < 42 ? 'var(--color-error)' : att < 75 ? 'var(--color-warning)' : 'var(--color-success)';
                  return (
                    <div key={c.enrollment_id || i} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 16px', background: 'var(--color-gray-50)', borderRadius: 'var(--radius-md)', border: '1px solid var(--color-gray-200)' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '16px', flex: 1 }}>
                        <div style={{ fontWeight: 700, color: 'var(--color-primary)', width: '70px' }}>{c.code || '—'}</div>
                        <div style={{ flex: 1 }}>
                          <div style={{ fontWeight: 600, color: 'var(--color-gray-800)', fontSize: '14px' }}>{c.name_ar || c.name_en || '—'}</div>
                          <div style={{ fontSize: '12px', color: 'var(--color-gray-500)', marginTop: '4px' }}>
                            الدكتور: {c.doctor_name_ar || c.doctor_name || '—'}
                          </div>
                        </div>
                      </div>
                      
                      <div style={{ display: 'flex', alignItems: 'center', gap: '24px' }}>
                        <div style={{ textAlign: 'center' }}>
                          <div style={{ fontSize: '11px', color: 'var(--color-gray-500)', marginBottom: '2px' }}>الحضور</div>
                          <div style={{ fontWeight: 700, color: attColor, fontSize: '14px' }}>
                            {att.toFixed(1)}%
                          </div>
                        </div>
                        <div style={{ minWidth: '80px', textAlign: 'left' }}>
                          <StatusBadge status={c.status || 'registered'} />
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
          </ErrorBoundary>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '60px 20px', color: 'var(--color-gray-400)', gap: '16px' }}>
            <div style={{ fontSize: '48px', opacity: 0.2 }}>📅</div>
            <div style={{ fontSize: '16px', fontWeight: 600, color: 'var(--color-gray-500)' }}>
              لا يوجد جدول دراسي تم إدخاله بعد
            </div>
            <div style={{ fontSize: '14px' }}>
              إما أنه لا توجد مقررات مسجلة لك، أو لم يتم رفع الجداول الدراسية لـ {currentSem?.label || 'هذا الفصل'}
            </div>
          </div>
        )}
      </Card>
    </AppLayout>
  );
}
