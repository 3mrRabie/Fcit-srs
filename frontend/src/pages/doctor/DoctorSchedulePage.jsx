import React, { useState, useEffect } from 'react';
import { sharedAPI, doctorAPI } from '../../services/api';
import { D } from '../../utils/helpers';
import AppLayout from '../../components/layout/AppLayout';
import { Button, Spinner, Badge } from '../../components/ui';

// ─── Constants ────────────────────────────────────────────────────────────────
const DAYS = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'];
const DAY_AR = { Sat: 'السبت', Sun: 'الأحد', Mon: 'الاثنين', Tue: 'الثلاثاء', Wed: 'الأربعاء', Thu: 'الخميس' };
const COURSE_PALETTE = [
  { bg: '#eff6ff', border: '#3b82f6', text: '#1d4ed8' },
  { bg: '#f0fdf4', border: '#22c55e', text: '#15803d' },
  { bg: '#fdf4ff', border: '#a855f7', text: '#7e22ce' },
  { bg: '#fff7ed', border: '#f97316', text: '#c2410c' },
  { bg: '#fef2f2', border: '#ef4444', text: '#b91c1c' },
  { bg: '#f0f9ff', border: '#06b6d4', text: '#0e7490' },
];

const timeToMinutes = (t) => {
  if (!t) return 0;
  const [h, m] = t.split(':').map(Number);
  return h * 60 + (m || 0);
};
const DAY_START    = 8 * 60;
const DAY_END      = 22 * 60;
const PX_PER_MIN   = 1.6;
const topPx    = (t) => (timeToMinutes(t) - DAY_START) * PX_PER_MIN;
const heightPx = (s, e) => (timeToMinutes(e) - timeToMinutes(s)) * PX_PER_MIN;
const HOUR_LABELS  = Array.from({ length: 15 }, (_, i) => `${String(8 + i).padStart(2, '0')}:00`);

// ── Course slot card ──────────────────────────────────────────────────────────
function SlotCard({ slot, colorIdx }) {
  const col = COURSE_PALETTE[colorIdx % COURSE_PALETTE.length];
  const h   = heightPx(slot.start, slot.end);
  const top = topPx(slot.start);
  const isShort = h < 52;

  return (
    <div
      title={`${slot.courseCode} — ${slot.courseNameAr || slot.courseName}\n${slot.start?.slice(0,5)} – ${slot.end?.slice(0,5)}\n${slot.room || ''}`}
      style={{
        position: 'absolute',
        top,
        left: 3,
        right: 3,
        height: Math.max(h, 28),
        background: col.bg,
        border: `2px solid ${col.border}`,
        borderRadius: 8,
        padding: isShort ? '2px 6px' : '6px 8px',
        overflow: 'hidden',
        boxSizing: 'border-box',
        boxShadow: '0 1px 4px rgba(0,0,0,.08)',
        zIndex: 2,
      }}
    >
      <div style={{ fontWeight: 800, fontSize: 11, color: col.text }}>{slot.courseCode}</div>
      {!isShort && (
        <>
          <div style={{ fontSize: 10, color: '#374151', marginTop: 1, overflow: 'hidden', whiteSpace: 'nowrap', textOverflow: 'ellipsis' }}>
            {slot.courseNameAr || slot.courseName}
          </div>
          <div style={{ fontSize: 10, color: '#6b7280', marginTop: 1 }}>
            {slot.start?.slice(0,5)} – {slot.end?.slice(0,5)}
          </div>
          {slot.room && <div style={{ fontSize: 10, color: '#9ca3af' }}>{slot.room}</div>}
        </>
      )}
    </div>
  );
}

// ── Course code → color index map ─────────────────────────────────────────────
function buildColorMap(grid) {
  const map = {};
  let idx = 0;
  DAYS.forEach(day => {
    (grid[day] || []).forEach(slot => {
      if (slot.courseCode && !(slot.courseCode in map)) {
        map[slot.courseCode] = idx++;
      }
    });
  });
  return map;
}

// ── Weekly grid ───────────────────────────────────────────────────────────────
function WeeklyGrid({ grid }) {
  const colorMap = buildColorMap(grid);
  const totalH   = (DAY_END - DAY_START) * PX_PER_MIN;

  return (
    <div style={{ overflowX: 'auto', direction: 'ltr' }}>
      <div style={{ display: 'flex', minWidth: 820 }}>

        {/* Time column */}
        <div style={{ width: 52, flexShrink: 0, position: 'relative', height: totalH + 24 }}>
          <div style={{ height: 24 }} />
          <div style={{ position: 'relative', height: totalH }}>
            {HOUR_LABELS.map(label => (
              <div key={label} style={{
                position: 'absolute',
                top: topPx(label) - 7,
                right: 0,
                width: '100%',
                textAlign: 'right',
                fontSize: 10,
                color: '#94a3b8',
                paddingRight: 6,
              }}>
                {label}
              </div>
            ))}
          </div>
        </div>

        {/* Day columns */}
        {[...DAYS].reverse().map(day => (
          <div key={day} style={{ flex: 1, minWidth: 110, display: 'flex', flexDirection: 'column' }}>
            <div style={{
              height: 24,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              background: '#1b4f9e',
              color: '#fff',
              fontSize: 12, fontWeight: 700,
              borderRight: '1px solid rgba(255,255,255,.15)',
            }}>
              {DAY_AR[day]}
            </div>
            <div style={{ position: 'relative', height: totalH, borderRight: '1px solid #e5e7eb' }}>
              {HOUR_LABELS.map(label => (
                <div key={label} style={{ position: 'absolute', top: topPx(label), left: 0, right: 0, borderTop: '1px solid #f1f5f9' }} />
              ))}
              {HOUR_LABELS.map(label => {
                const [h] = label.split(':').map(Number);
                return (
                  <div key={`${h}:30`} style={{ position: 'absolute', top: topPx(`${String(h).padStart(2,'0')}:30`), left: 0, right: 0, borderTop: '1px dashed #f1f5f9' }} />
                );
              })}
              {(grid[day] || []).map((slot, i) => (
                <SlotCard key={`${slot.courseCode}-${i}`} slot={slot} colorIdx={colorMap[slot.courseCode] ?? i} />
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ── Main page ─────────────────────────────────────────────────────────────────
export default function DoctorSchedulePage() {
  const [data, setData]       = useState(null);
  const [loading, setLoading] = useState(true);
  const [sems, setSems]       = useState([]);
  const [selSem, setSelSem]   = useState('');

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

  const grid        = data?.weeklyGrid || {};
  const offerings   = data?.offerings || [];
  const hasSchedule = offerings.length > 0;
  const currentSem  = sems.find(s => s.id == selSem);

  const totalStudents = offerings.reduce((s, o) => s + (o.enrolled_count || 0), 0);

  const offeringsByLevel = offerings.reduce((acc, off) => {
    const level = off.level_name || 'الفرقة الأولى';
    if (!acc[level]) acc[level] = [];
    acc[level].push(off);
    return acc;
  }, {});

  const printSchedule = () => {
    const semLabel = currentSem?.label || '';
    const doc = `<!DOCTYPE html>
<html dir="rtl"><head><meta charset="UTF-8"><title>جدول عضو هيئة التدريس</title>
<style>*{box-sizing:border-box}body{font-family:'Segoe UI',Arial,sans-serif;direction:rtl;margin:0;padding:20px;color:#1e293b}
h1{text-align:center;color:#1b4f9e;font-size:20px;margin-bottom:4px}.sub{text-align:center;color:#64748b;font-size:13px;margin-bottom:20px}
table{width:100%;border-collapse:collapse;margin-bottom:24px}th{background:#1b4f9e;color:white;padding:10px;font-size:13px}
td{border:1px solid #e2e8f0;padding:8px;vertical-align:top;min-width:90px}
h2{font-size:15px;border-bottom:2px solid #1b4f9e;padding-bottom:4px}
.row{display:flex;gap:8px;padding:8px 0;border-bottom:1px solid #f1f5f9;font-size:13px}
.code{font-weight:700;color:#1d4ed8;font-size:12px}.time{font-size:11px;color:#64748b}
@media print{body{padding:10px}}</style></head><body>
<h1>الجدول الدراسي لعضو هيئة التدريس</h1>
<div class="sub">${semLabel} — مطبوع ${new Date().toLocaleDateString('ar-EG')}</div>
<table><thead><tr><th>الوقت</th>${DAYS.map(d=>`<th>${DAY_AR[d]}</th>`).join('')}</tr></thead>
<tbody>
${Array.from({length:14},(_,i)=>{
  const h=`${String(8+i).padStart(2,'0')}:00`;
  return `<tr><td style="background:#f8fafc;font-weight:700;text-align:center;font-size:12px">${h}</td>
    ${DAYS.map(d=>{const slots=(grid[d]||[]).filter(s=>s.start&&s.start.startsWith(String(8+i).padStart(2,'0')));return `<td>${slots.map(s=>`<div class="code">${s.courseCode}</div><div class="time">${s.start?.slice(0,5)}–${s.end?.slice(0,5)}</div><div class="time">${s.room||''}</div>`).join('')}</td>`;}).join('')}</tr>`;
}).join('')}
</tbody></table>
<h2>المقررات والمهام التدريسية</h2>
${Object.entries(offeringsByLevel).map(([level,courses])=>`
<div style="margin-bottom:12px"><div style="font-weight:700;font-size:13px;background:#f1f5f9;padding:4px 8px;border-radius:4px;margin-bottom:6px">${level}</div>
${courses.map(o=>`<div class="row"><strong style="min-width:70px;color:#1d4ed8">${o.code}</strong><span style="flex:1">${o.name_ar||o.name_en}</span><span style="color:#64748b;font-size:12px">${o.enrolled_count||0}/${o.capacity||0} طالب</span></div>`).join('')}
</div>`).join('')}
<script>window.onload=()=>window.print();</script>
</body></html>`;
    const w = window.open('', '_blank');
    w.document.write(doc);
    w.document.close();
  };

  return (
    <AppLayout>
      {/* ── Header ──────────────────────────────────────────────── */}
      <div style={{
        background: '#fff',
        borderRadius: 14,
        padding: '12px 18px',
        marginBottom: 14,
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        flexWrap: 'wrap',
        gap: 10,
        boxShadow: '0 2px 8px rgba(0,0,0,.06)',
        border: '1px solid #e2e8f0',
        direction: 'rtl',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <span style={{ fontSize: 22 }}>🏛️</span>
          <div>
            <div style={{ fontWeight: 800, fontSize: 16, color: '#1b4f9e' }}>جدول عضو هيئة التدريس</div>
            {currentSem && <div style={{ fontSize: 12, color: '#64748b', marginTop: 1 }}>{currentSem.label}</div>}
          </div>
        </div>
        <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
          {currentSem && (
            <Badge variant={currentSem.status === 'active' ? 'success' : currentSem.status === 'registration' ? 'info' : 'default'} style={{ fontSize: 11 }}>
              {currentSem.status === 'active' ? 'نشط' : currentSem.status === 'registration' ? 'تسجيل' : 'مغلق'}
            </Badge>
          )}
          <select
            style={{ padding: '7px 12px', borderRadius: 8, border: '1px solid #e2e8f0', fontSize: 12, background: '#f8fafc' }}
            value={selSem}
            onChange={e => setSelSem(e.target.value)}
          >
            {sems.map(s => (
              <option key={s.id} value={s.id}>{s.label || `${s.semester_type||''} ${s.year_label||''}`}</option>
            ))}
          </select>
          <Button size="sm" onClick={printSchedule} disabled={!hasSchedule} style={{ fontSize: 12 }}>
            🖨️ طباعة
          </Button>
        </div>
      </div>

      {loading ? (
        <div style={{ display: 'flex', justifyContent: 'center', padding: 60 }}><Spinner /></div>
      ) : hasSchedule ? (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>

          {/* ── Stats row ────────────────────────────────────── */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 10 }}>
            {[
              { icon: '📚', label: 'عدد المقررات', value: offerings.length },
              { icon: '👥', label: 'إجمالي الطلاب', value: `${totalStudents} طالب` },
              { icon: '📆', label: 'أيام التدريس', value: DAYS.filter(d => (grid[d]||[]).length > 0).map(d => DAY_AR[d]).join(' · ') || '—' },
            ].map(s => (
              <div key={s.label} style={{ background: '#fff', border: '1px solid #e2e8f0', borderRadius: 12, padding: '12px 16px', display: 'flex', alignItems: 'center', gap: 12, direction: 'rtl' }}>
                <span style={{ fontSize: 24 }}>{s.icon}</span>
                <div>
                  <div style={{ fontSize: 11, color: '#64748b' }}>{s.label}</div>
                  <div style={{ fontWeight: 800, fontSize: 15, color: '#1e293b' }}>{s.value}</div>
                </div>
              </div>
            ))}
          </div>

          {/* ── Weekly grid ──────────────────────────────────── */}
          <div style={{ background: '#fff', borderRadius: 14, border: '1px solid #e2e8f0', overflow: 'hidden', boxShadow: '0 2px 8px rgba(0,0,0,.05)', direction: 'rtl' }}>
            <div style={{ padding: '12px 16px', borderBottom: '1px solid #e2e8f0', fontWeight: 700, fontSize: 14, color: '#1e293b', display: 'flex', alignItems: 'center', gap: 8 }}>
              <span>🗓️</span> الجدول الأسبوعي
            </div>
            <div style={{ padding: 8 }}>
              <WeeklyGrid grid={grid} />
            </div>
          </div>

          {/* ── Courses by level ─────────────────────────────── */}
          <div style={{ background: '#fff', borderRadius: 14, border: '1px solid #e2e8f0', overflow: 'hidden', boxShadow: '0 2px 8px rgba(0,0,0,.05)', direction: 'rtl' }}>
            <div style={{ padding: '12px 16px', borderBottom: '1px solid #e2e8f0', fontWeight: 700, fontSize: 14, color: '#1e293b', display: 'flex', alignItems: 'center', gap: 8 }}>
              <span>🎓</span> المقررات والمهام التدريسية
            </div>
            {Object.entries(offeringsByLevel).map(([level, courses]) => (
              <div key={level} style={{ marginBottom: 0 }}>
                <div style={{ padding: '8px 16px', background: '#f8fafc', borderBottom: '1px solid #e2e8f0', fontWeight: 700, fontSize: 13, color: '#374151', display: 'flex', alignItems: 'center', gap: 8 }}>
                  <span>🎓</span> {level}
                </div>
                {courses.map((o, i) => {
                  const col = COURSE_PALETTE[i % COURSE_PALETTE.length];
                  return (
                    <div key={o.offering_id || i} style={{
                      display: 'flex', alignItems: 'center', gap: 14,
                      padding: '11px 16px',
                      borderBottom: i < courses.length - 1 ? '1px solid #f1f5f9' : '1px solid #e2e8f0',
                    }}>
                      <div style={{ width: 4, height: 38, borderRadius: 4, background: col.border, flexShrink: 0 }} />
                      <div style={{ fontWeight: 800, color: col.text, width: 72, fontSize: 13 }}>{o.code}</div>
                      <div style={{ flex: 1 }}>
                        <div style={{ fontWeight: 600, color: '#1e293b', fontSize: 13 }}>{o.name_ar || o.name_en}</div>
                        <div style={{ fontSize: 11, color: '#64748b', marginTop: 1 }}>{o.room || 'القاعة غير محددة'}</div>
                      </div>
                      <div style={{ textAlign: 'center', minWidth: 70 }}>
                        <div style={{ fontSize: 10, color: '#94a3b8', marginBottom: 2 }}>الطلاب</div>
                        <div style={{ fontWeight: 700, color: '#1e293b', fontSize: 13 }}>
                          {o.enrolled_count || 0}
                          <span style={{ color: '#94a3b8', fontWeight: 400 }}>/{o.capacity || 0}</span>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            ))}
          </div>

        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '80px 20px', background: '#fff', borderRadius: 14, border: '1px solid #e2e8f0', gap: 12 }}>
          <div style={{ fontSize: 56, opacity: 0.15 }}>📅</div>
          <div style={{ fontWeight: 700, fontSize: 16, color: '#64748b' }}>لا يوجد جدول دراسي</div>
          <div style={{ fontSize: 13, color: '#94a3b8', textAlign: 'center', maxWidth: 360 }}>
            لم يتم إسناد مقررات لك في هذا الفصل، أو لم يتم رفع الجداول بعد لـ {currentSem?.label || 'هذا الفصل'}
          </div>
        </div>
      )}
    </AppLayout>
  );
}
