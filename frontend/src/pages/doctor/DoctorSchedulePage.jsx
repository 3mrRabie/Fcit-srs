import React, { useState, useEffect } from 'react';
import { sharedAPI, doctorAPI } from '../../services/api';
import { D } from '../../utils/helpers';
import AppLayout from '../../components/layout/AppLayout';
import { Card, Button, Spinner } from '../../components/ui';

export default function DoctorSchedulePage() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [sems, setSems] = useState([]);
  const [selSem, setSelSem] = useState('');

  const DAYS = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'];
  const DAY_AR = { Sat: 'السبت', Sun: 'الأحد', Mon: 'الاثنين', Tue: 'الثلاثاء', Wed: 'الأربعاء', Thu: 'الخميس' };
  const SLOT_COLORS = ['#dbeafe', '#dcfce7', '#fef9c3', '#fce7f3', '#e0e7ff', '#fff7ed'];

  useEffect(() => {
    sharedAPI.getSemesters()
      .then(r => {
        const s = D(r) || [];
        setSems(s);
        const cur = s.find(x => ['registration', 'active', 'grading'].includes(x.status));
        if (cur) setSelSem(cur.id);
        else if (s.length > 0) setSelSem(s[0].id);
      })
      .catch(() => {});
  }, []);

  useEffect(() => {
    if (!selSem) { setLoading(false); return; }
    setLoading(true);
    doctorAPI.getSchedule({ semesterId: selSem })
      .then(r => setData(D(r)))
      .catch(() => setData(null))
      .finally(() => setLoading(false));
  }, [selSem]);

  const grid = data?.weeklyGrid || {};
  const offerings = data?.offerings || [];
  const hasSchedule = offerings.length > 0;

  // Group offerings by level
  const offeringsByLevel = offerings.reduce((acc, off) => {
    const level = off.level_name || 'الفرقة الأولى';
    if (!acc[level]) acc[level] = [];
    acc[level].push(off);
    return acc;
  }, {});

  const printSchedule = () => {
    const semLabel = sems.find(s => s.id == selSem)?.label || '';

    const doc = `<!DOCTYPE html>
<html dir="rtl"><head><meta charset="UTF-8"><title>الجدول الدراسي لعضو هيئة التدريس</title>
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
  .level-group { margin-bottom: 16px; }
  .level-title { font-weight: bold; color: #1e293b; font-size: 14px; margin-bottom: 8px; padding: 4px 8px; background: #f1f5f9; border-radius: 4px; }
  .course-row { display: flex; gap: 8px; align-items: center; padding: 8px 12px; border-bottom: 1px solid #f1f5f9; font-size: 13px; }
  @media print { body { padding: 10px; } }
</style></head>
<body>
  <h1>الجدول الدراسي الأسبوعي لعضو هيئة التدريس</h1>
  <div class="sub">${semLabel} — مطبوع ${new Date().toLocaleDateString('ar-EG')}</div>
  <table>
    <thead><tr><th>اليوم</th><th>الأحد</th><th>الاثنين</th><th>الثلاثاء</th><th>الأربعاء</th><th>الخميس</th></tr></thead>
    <tbody>
      ${DAYS.map(day => `
        <tr>
          <td class="day-cell">${DAY_AR[day]}</td>
          ${DAYS.map(d => {
            const slots = grid[d] || [];
            if (d !== day) return '';
            return `<td>${slots.length === 0
              ? '<div class="empty">لا يوجد</div>'
              : slots.map(s => `<div class="slot">
                  <div class="slot-code">${s.courseCode}</div>
                  <div>${s.start} - ${s.end}</div>
                  <div style="color:#64748b">${s.room || ''} | ${s.type === 'lecture' ? 'محاضرة' : 'معمل'}</div>
                </div>`).join('')
            }</td>`;
          }).filter(Boolean).join('')}
        </tr>`).join('')}
    </tbody>
  </table>
  
  <h2>تفاصيل المقررات والمهام التدريسية</h2>
  ${Object.entries(offeringsByLevel).map(([level, courses]) => `
    <div class="level-group">
      <div class="level-title">${level}</div>
      ${courses.map(o => `
        <div class="course-row">
          <strong style="min-width:70px;color:#1d4ed8">${o.code}</strong>
          <span style="flex:1">${o.name_ar || o.name_en}</span>
          <span style="color:#64748b;font-size:12px;min-width:80px">${o.enrolled_count || 0}/${o.capacity || 0} طالب</span>
        </div>`).join('')}
    </div>
  `).join('')}
  <script>window.onload=()=>window.print();</script>
</body></html>`;
    const win = window.open('', '_blank');
    win.document.write(doc);
    win.document.close();
  };

  return (
    <AppLayout>
      <Card
        title="الجدول الدراسي لعضو هيئة التدريس"
        headerActions={
          <div style={{ display: 'flex', gap: '10px' }}>
            <select
              style={{ padding: '6px 10px', borderRadius: 'var(--radius-md)', border: '1px solid var(--color-gray-200)', fontSize: '12px', background: 'var(--color-gray-50)', cursor: 'pointer' }}
              value={selSem} onChange={e => setSelSem(e.target.value)}
            >
              {sems.map(s => <option key={s.id} value={s.id}>{s.label || `${s.semester_type || ''} ${s.year_label || ''}`}</option>)}
            </select>
            <Button size="sm" onClick={printSchedule} disabled={!hasSchedule}>🖨️ طباعة / PDF</Button>
          </div>
        }
      >
        {loading ? <Spinner /> : hasSchedule ? (
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
                          const slots = (grid[day] || []).filter(s => s.start && s.start.startsWith(hour.slice(0, 2)));
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
              <h3 style={{ fontSize: '16px', color: 'var(--color-gray-800)', marginBottom: '16px', paddingRight: '4px', borderRight: '4px solid var(--color-primary)' }}>
                المهام التدريسية والمقررات
              </h3>
              
              <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                {Object.entries(offeringsByLevel).map(([level, courses]) => (
                  <div key={level} style={{ background: 'white', borderRadius: 'var(--radius-md)', border: '1px solid var(--color-gray-200)', overflow: 'hidden' }}>
                    <div style={{ background: 'var(--color-gray-50)', padding: '10px 16px', fontWeight: 600, color: 'var(--color-gray-800)', borderBottom: '1px solid var(--color-gray-200)', fontSize: '14px' }}>
                      {level}
                    </div>
                    <div>
                      {courses.map((o, i) => (
                        <div key={o.offering_id || i} style={{ display: 'flex', alignItems: 'center', padding: '12px 16px', borderBottom: i < courses.length - 1 ? '1px solid var(--color-gray-100)' : 'none', gap: '16px' }}>
                          <div style={{ fontWeight: 700, color: 'var(--color-primary)', width: '70px', fontSize: '14px' }}>{o.code}</div>
                          <div style={{ flex: 1, fontWeight: 500, color: 'var(--color-gray-800)' }}>{o.name_ar || o.name_en}</div>
                          <div style={{ color: 'var(--color-gray-500)', fontSize: '13px', width: '80px' }}>{o.room || 'TBD'}</div>
                          <div style={{ color: 'var(--color-gray-500)', fontSize: '13px', width: '100px', display: 'flex', alignItems: 'center', gap: '4px' }}>
                            <span style={{ fontSize: '16px' }}>👥</span> {o.enrolled_count || 0}/{o.capacity || 0} طالب
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '60px 20px', color: 'var(--color-gray-400)', gap: '16px' }}>
            <div style={{ fontSize: '48px', opacity: 0.2 }}>📅</div>
            <div style={{ fontSize: '16px', fontWeight: 600, color: 'var(--color-gray-500)' }}>
              لا يوجد جدول دراسي تم إدخاله بعد
            </div>
            <div style={{ fontSize: '14px' }}>
              إما أنه لا توجد مقررات مسندة لك، أو لم يتم رفع الجداول الدراسية لـ {sems.find(s => s.id == selSem)?.label || 'هذا الفصل'}
            </div>
          </div>
        )}
      </Card>
    </AppLayout>
  );
}
