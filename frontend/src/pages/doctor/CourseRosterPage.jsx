import React, { useState, useEffect, useCallback } from 'react';
import { useParams, Link } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { doctorAPI } from '../../services/api';
import { D } from '../../utils/helpers';
import AppLayout from '../../components/layout/AppLayout';
import { Button, Spinner } from '../../components/ui';

// ─── Grade Scale (mirrors gpa.service.js) ────────────────────────────────────
// Scores: midterm 0-20, coursework 0-10, practical 0-10, final 0-60 (sum = 0-100)
// Total = sum of all components; letter grade derived from total/100 percentage
const GRADE_SCALE = [
  { grade: 'A+', min: 96 }, { grade: 'A', min: 92 }, { grade: 'A-', min: 88 },
  { grade: 'B+', min: 84 }, { grade: 'B', min: 80 }, { grade: 'B-', min: 76 },
  { grade: 'C+', min: 72 }, { grade: 'C', min: 68 }, { grade: 'C-', min: 64 },
  { grade: 'D+', min: 60 }, { grade: 'D', min: 55 }, { grade: 'D-', min: 40 },
  { grade: 'F',  min: 0  },
];

function computeLetterGrade(total, finalExamVal) {
  if (total === null || total === undefined) return null;
  const fin = Number(finalExamVal) || 0;
  // Auto-fail if final exam < 30% of 60 = 18
  if (finalExamVal !== '' && finalExamVal !== null && fin < 18) return 'F';
  for (const { grade, min } of GRADE_SCALE) {
    if (total >= min) return grade;
  }
  return 'F';
}

// ─── Palette ──────────────────────────────────────────────────────────────────
const PRIMARY = '#1b4f9e';
const SUCCESS = '#16a34a';
const DANGER  = '#dc2626';
const WARN    = '#d97706';

// ─── Grade Input ──────────────────────────────────────────────────────────────
function GradeInput({ value, onChange, max, disabled }) {
  const num  = value === '' ? null : Number(value);
  const over = num !== null && num > max;
  return (
    <div style={{ position: 'relative', display: 'inline-block' }}>
      <input
        type="number" min="0" max={max}
        value={value ?? ''}
        placeholder="—"
        disabled={disabled}
        onChange={e => onChange(e.target.value === '' ? '' : Number(e.target.value))}
        style={{
          width: 52, padding: '5px 6px', border: `1.5px solid ${over ? DANGER : '#d1d5db'}`,
          borderRadius: 7, fontSize: 12, textAlign: 'center', fontFamily: 'inherit',
          background: disabled ? '#f9fafb' : '#fff', color: over ? DANGER : '#111827',
          outline: 'none', transition: 'border-color .15s',
        }}
      />
      {over && (
        <div style={{ position: 'absolute', top: -18, left: '50%', transform: 'translateX(-50%)',
          background: DANGER, color: '#fff', fontSize: 9, padding: '1px 5px', borderRadius: 3,
          whiteSpace: 'nowrap', zIndex: 10 }}>
          تجاوز الحد
        </div>
      )}
    </div>
  );
}

// ─── Grade Badge ──────────────────────────────────────────────────────────────
function LetterBadge({ grade }) {
  if (!grade) return <span style={{ color: '#9ca3af', fontSize: 12 }}>—</span>;
  const ok = !['F','Abs','W'].includes(grade);
  return (
    <span style={{
      display: 'inline-block', minWidth: 34, padding: '2px 8px', borderRadius: 6,
      background: ok ? '#dcfce7' : '#fee2e2',
      color: ok ? SUCCESS : DANGER,
      fontWeight: 800, fontSize: 12, textAlign: 'center',
    }}>
      {grade}
    </span>
  );
}

// ─── Attendance Pill ──────────────────────────────────────────────────────────
function AttPill({ pct }) {
  if (pct == null) return <span style={{ color: '#9ca3af', fontSize: 11 }}>—</span>;
  const color = pct < 42 ? DANGER : pct < 60 ? WARN : SUCCESS;
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
      <div style={{ flex: 1, height: 5, background: '#e5e7eb', borderRadius: 99, overflow: 'hidden', minWidth: 36 }}>
        <div style={{ width: `${Math.min(pct, 100)}%`, height: '100%', background: color, borderRadius: 99 }} />
      </div>
      <span style={{ fontSize: 10, fontWeight: 700, color, minWidth: 30 }}>{pct}%</span>
    </div>
  );
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
function StatCard({ label, value, icon, color = PRIMARY }) {
  return (
    <div style={{
      background: '#fff', border: '1px solid #e5e7eb', borderRadius: 12,
      padding: '12px 16px', display: 'flex', alignItems: 'center', gap: 12, direction: 'rtl',
    }}>
      <div style={{ fontSize: 26, lineHeight: 1 }}>{icon}</div>
      <div>
        <div style={{ fontSize: 10, color: '#64748b', marginBottom: 2 }}>{label}</div>
        <div style={{ fontWeight: 800, fontSize: 16, color }}>{value}</div>
      </div>
    </div>
  );
}

// ─── Grades Tab ───────────────────────────────────────────────────────────────
function GradesTab({ roster, canEnter, offeringId, onReload }) {
  const [grades, setGrades]   = useState({});
  const [saving, setSaving]   = useState(null);
  const [savingAll, setSavingAll] = useState(false);
  const [dirty, setDirty]     = useState({});

  // init grades from roster
  useEffect(() => {
    const g = {};
    roster.forEach(s => {
      const eid = s.enrollment_id;
      g[eid] = {
        midterm_grade:    s.midterm_grade ?? '',
        coursework_grade: s.coursework_grade ?? '',
        practical_grade:  s.practical_grade ?? '',
        final_exam_grade: s.final_exam_grade ?? '',
      };
    });
    setGrades(g);
    setDirty({});
  }, [roster]);

  const setField = (eid, field, val) => {
    setGrades(p => ({ ...p, [eid]: { ...p[eid], [field]: val } }));
    setDirty(p => ({ ...p, [eid]: true }));
  };

  const save = async (eid) => {
    setSaving(eid);
    try {
      await doctorAPI.enterGrades(eid, grades[eid]);
      toast.success('تم حفظ الدرجات ✓');
      setDirty(p => ({ ...p, [eid]: false }));
      onReload();
    } catch (e) {
      toast.error(e.response?.data?.message || 'فشل الحفظ');
    } finally { setSaving(null); }
  };

  const saveAll = async () => {
    const dirtyEids = Object.keys(dirty).filter(e => dirty[e]);
    if (!dirtyEids.length) { toast('لا توجد تغييرات', { icon: 'ℹ️' }); return; }
    setSavingAll(true);
    let ok = 0, fail = 0;
    for (const eid of dirtyEids) {
      try {
        await doctorAPI.enterGrades(eid, grades[eid]);
        ok++;
        setDirty(p => ({ ...p, [eid]: false }));
      } catch { fail++; }
    }
    setSavingAll(false);
    onReload();
    if (ok)   toast.success(`تم حفظ ${ok} طالب`);
    if (fail) toast.error(`فشل ${fail} طالب`);
  };

  const FIELDS = [
    { key: 'midterm_grade',    label: 'منتصف', max: 20 },
    { key: 'coursework_grade', label: 'أعمال',  max: 10 },
    { key: 'practical_grade',  label: 'عملي',   max: 10 },
    { key: 'final_exam_grade', label: 'نهائي',  max: 60 },
  ];

  const dirtyCount = Object.values(dirty).filter(Boolean).length;

  return (
    <div>
      {/* Toolbar */}
      <div style={{
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        marginBottom: 14, padding: '10px 16px',
        background: canEnter ? '#f0fdf4' : '#fef2f2',
        borderRadius: 10, border: `1px solid ${canEnter ? '#bbf7d0' : '#fecaca'}`,
        direction: 'rtl',
      }}>
        <div style={{ fontSize: 12, fontWeight: 600, color: canEnter ? SUCCESS : DANGER }}>
          {canEnter ? '✓ وضع الإدخال نشط' : '✗ الدرجات مغلقة في هذا الفصل'}
        </div>
        {canEnter && (
          <Button
            size="sm"
            onClick={saveAll}
            disabled={savingAll || dirtyCount === 0}
            style={{ background: PRIMARY, color: '#fff', fontSize: 12, padding: '6px 14px' }}
          >
            {savingAll ? 'جاري الحفظ…' : `حفظ الكل ${dirtyCount > 0 ? `(${dirtyCount})` : ''}`}
          </Button>
        )}
      </div>

      {/* Table */}
      <div style={{ overflowX: 'auto' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13, direction: 'rtl' }}>
          <thead>
            <tr style={{ background: '#f8fafc' }}>
              {['#', 'الطالب', 'الكود', 'حضور',
                ...FIELDS.map(f => `${f.label}\n/${f.max}`),
                'المجموع', 'التقدير', 'حفظ'
              ].map((h, i) => (
                <th key={i} style={{
                  padding: '9px 10px', borderBottom: '2px solid #e5e7eb',
                  color: '#374151', fontWeight: 700, fontSize: 11, textAlign: 'center',
                  whiteSpace: 'pre-line', lineHeight: 1.3,
                }}>{h}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {roster.map((s, idx) => {
              const eid  = s.enrollment_id;
              const g    = grades[eid] || {};
              const mid  = Number(g.midterm_grade) || 0;
              const cw   = Number(g.coursework_grade) || 0;
              const pr   = Number(g.practical_grade) || 0;
              const fin  = Number(g.final_exam_grade) || 0;
              const hasAny = g.midterm_grade !== '' || g.coursework_grade !== '' ||
                             g.practical_grade !== '' || g.final_exam_grade !== '';
              const total  = hasAny ? mid + cw + pr + fin : null;
              // Dynamic letter: compute from form if any marks entered,
              // else show DB letter only if a total_grade is already stored
              const dynamicLetter = hasAny
                ? computeLetterGrade(total, g.final_exam_grade)
                : (s.total_grade !== null && s.total_grade !== undefined ? s.letter_grade : null);
              const isDirty = dirty[eid];
              return (
                <tr key={eid} style={{
                  background: isDirty ? '#fffbeb' : idx % 2 === 0 ? '#fff' : '#fafafa',
                  transition: 'background .15s',
                }}>
                  <td style={{ padding: '8px 10px', textAlign: 'center', color: '#9ca3af', fontSize: 11 }}>{idx + 1}</td>
                  <td style={{ padding: '8px 10px', fontWeight: 600, color: '#111827', minWidth: 140 }}>
                    {s.student_name || '—'}
                    {s.below_minimum && (
                      <span title="حضور دون الحد الأدنى" style={{ marginRight: 6, fontSize: 10, color: DANGER }}>⚠️</span>
                    )}
                  </td>
                  <td style={{ padding: '8px 10px', fontSize: 11, color: '#6b7280', textAlign: 'center' }}>{s.student_code}</td>
                  <td style={{ padding: '8px 10px', minWidth: 80 }}>
                    <AttPill pct={Math.round(s.attendance_pct)} />
                  </td>
                  {FIELDS.map(f => (
                    <td key={f.key} style={{ padding: '6px 6px', textAlign: 'center' }}>
                      <GradeInput
                        value={g[f.key]}
                        onChange={val => setField(eid, f.key, val)}
                        max={f.max}
                        disabled={!canEnter || s.grade_locked}
                      />
                    </td>
                  ))}
                  <td style={{ padding: '8px 10px', textAlign: 'center', fontWeight: 800,
                    color: total !== null ? (total >= 60 ? SUCCESS : DANGER) : '#9ca3af', fontSize: 13 }}>
                    {total !== null ? total.toFixed(0) : (s.total_grade ?? '—')}
                  </td>
                  <td style={{ padding: '8px 8px', textAlign: 'center' }}>
                    <LetterBadge grade={dynamicLetter} />
                  </td>
                  <td style={{ padding: '6px 8px', textAlign: 'center' }}>
                    {canEnter && !s.grade_locked ? (
                      <button
                        onClick={() => save(eid)}
                        disabled={saving === eid || !isDirty}
                        style={{
                          padding: '5px 12px', borderRadius: 7, border: 'none',
                          background: isDirty ? SUCCESS : '#e5e7eb',
                          color: isDirty ? '#fff' : '#9ca3af',
                          fontWeight: 700, fontSize: 11, cursor: isDirty ? 'pointer' : 'default',
                          transition: 'all .15s',
                        }}
                      >
                        {saving === eid ? '…' : 'حفظ'}
                      </button>
                    ) : (
                      <span style={{ fontSize: 10, color: '#9ca3af' }}>
                        {s.grade_locked ? '🔒' : '—'}
                      </span>
                    )}
                  </td>
                </tr>
              );
            })}
            {roster.length === 0 && (
              <tr>
                <td colSpan={10} style={{ textAlign: 'center', padding: 40, color: '#9ca3af' }}>
                  لا يوجد طلاب مسجلون في هذا المقرر
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

// ─── Attendance Tab ───────────────────────────────────────────────────────────
function AttendanceTab({ offeringId, roster }) {
  const [sessions, setSessions]     = useState([]);
  const [loading, setLoading]       = useState(true);
  const [showForm, setShowForm]     = useState(false);
  const [sessionDate, setSessionDate] = useState(new Date().toISOString().slice(0, 10));
  const [sessionType, setSessionType] = useState('lecture');
  const [presence, setPresence]     = useState({});
  const [saving, setSaving]         = useState(false);

  const loadSessions = useCallback(() => {
    setLoading(true);
    doctorAPI.getAttendanceReport(offeringId)
      .then(r => { const d = D(r); setSessions(d?.sessions || d || []); })
      .catch(() => {})
      .finally(() => setLoading(false));
  }, [offeringId]);

  useEffect(() => { loadSessions(); }, [loadSessions]);

  const initForm = () => {
    const p = {};
    roster.forEach(s => { p[s.enrollment_id] = true; });
    setPresence(p);
    setShowForm(true);
  };

  const toggleAll = (val) => {
    const p = {};
    roster.forEach(s => { p[s.enrollment_id] = val; });
    setPresence(p);
  };

  const submit = async () => {
    setSaving(true);
    const records = roster.map(s => ({
      enrollmentId: s.enrollment_id,
      isPresent: presence[s.enrollment_id] !== false,
    }));
    try {
      await doctorAPI.recordAttendance(offeringId, { sessionDate, sessionType, attendanceData: records });
      toast.success('تم تسجيل الحضور بنجاح ✓');
      setShowForm(false);
      loadSessions();
    } catch (e) {
      toast.error(e.response?.data?.message || 'فشل تسجيل الحضور');
    } finally { setSaving(false); }
  };

  const presentCount = Object.values(presence).filter(Boolean).length;
  const absentCount  = roster.length - presentCount;

  // ── Form view ──
  if (showForm) return (
    <div style={{ direction: 'rtl' }}>
      {/* Header controls */}
      <div style={{
        display: 'grid', gridTemplateColumns: '1fr 1fr auto auto', gap: 10,
        alignItems: 'flex-end', marginBottom: 16,
        padding: 14, background: '#f8fafc', borderRadius: 10, border: '1px solid #e5e7eb',
      }}>
        <div>
          <label style={{ display: 'block', fontSize: 11, fontWeight: 700, color: '#374151', marginBottom: 4 }}>تاريخ الجلسة</label>
          <input
            type="date" value={sessionDate}
            onChange={e => setSessionDate(e.target.value)}
            style={{ width: '100%', padding: '8px 10px', border: '1.5px solid #d1d5db',
              borderRadius: 8, fontSize: 13, fontFamily: 'inherit', outline: 'none' }}
          />
        </div>
        <div>
          <label style={{ display: 'block', fontSize: 11, fontWeight: 700, color: '#374151', marginBottom: 4 }}>نوع الجلسة</label>
          <select
            value={sessionType} onChange={e => setSessionType(e.target.value)}
            style={{ width: '100%', padding: '8px 10px', border: '1.5px solid #d1d5db',
              borderRadius: 8, fontSize: 13, fontFamily: 'inherit', outline: 'none', background: '#fff' }}
          >
            <option value="lecture">محاضرة</option>
            <option value="lab">معمل</option>
            <option value="tutorial">تمرين</option>
          </select>
        </div>
        <button onClick={() => toggleAll(true)}
          style={{ padding: '8px 14px', borderRadius: 8, border: 'none', background: '#dcfce7',
            color: SUCCESS, fontWeight: 700, fontSize: 12, cursor: 'pointer' }}>
          حضور الكل ✓
        </button>
        <button onClick={() => toggleAll(false)}
          style={{ padding: '8px 14px', borderRadius: 8, border: 'none', background: '#fee2e2',
            color: DANGER, fontWeight: 700, fontSize: 12, cursor: 'pointer' }}>
          غياب الكل ✗
        </button>
      </div>

      {/* Summary bar */}
      <div style={{
        display: 'flex', gap: 12, marginBottom: 14, direction: 'rtl',
      }}>
        {[
          { label: 'حضور', val: presentCount, color: SUCCESS, bg: '#dcfce7' },
          { label: 'غياب', val: absentCount,  color: DANGER,  bg: '#fee2e2' },
          { label: 'إجمالي', val: roster.length, color: '#1e293b', bg: '#f1f5f9' },
        ].map(s => (
          <div key={s.label} style={{
            padding: '8px 18px', borderRadius: 8, background: s.bg,
            fontWeight: 800, fontSize: 14, color: s.color,
            display: 'flex', gap: 6, alignItems: 'center',
          }}>
            <span style={{ fontSize: 11, fontWeight: 400, opacity: 0.8 }}>{s.label}</span>
            {s.val}
          </div>
        ))}
      </div>

      {/* Student list */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 8, marginBottom: 16 }}>
        {roster.map(s => {
          const eid     = s.enrollment_id;
          const present = presence[eid] !== false;
          return (
            <button
              key={eid}
              onClick={() => setPresence(p => ({ ...p, [eid]: !p[eid] }))}
              style={{
                display: 'flex', alignItems: 'center', gap: 10,
                padding: '10px 14px', borderRadius: 10, cursor: 'pointer',
                border: `2px solid ${present ? '#86efac' : '#fca5a5'}`,
                background: present ? '#f0fdf4' : '#fff5f5',
                transition: 'all .15s', textAlign: 'right',
              }}
            >
              <div style={{
                width: 28, height: 28, borderRadius: '50%',
                background: present ? SUCCESS : DANGER,
                color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontWeight: 800, fontSize: 14, flexShrink: 0,
              }}>
                {present ? '✓' : '✗'}
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontWeight: 600, fontSize: 12, color: '#111827',
                  overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                  {s.student_name}
                </div>
                <div style={{ fontSize: 10, color: '#6b7280' }}>{s.student_code}</div>
              </div>
            </button>
          );
        })}
      </div>

      {/* Actions */}
      <div style={{ display: 'flex', gap: 10 }}>
        <button
          onClick={submit} disabled={saving}
          style={{
            padding: '10px 24px', borderRadius: 9, border: 'none',
            background: PRIMARY, color: '#fff', fontWeight: 700, fontSize: 14,
            cursor: saving ? 'not-allowed' : 'pointer', opacity: saving ? 0.7 : 1,
          }}
        >
          {saving ? 'جاري الحفظ…' : 'حفظ الحضور'}
        </button>
        <button
          onClick={() => setShowForm(false)}
          style={{
            padding: '10px 20px', borderRadius: 9, border: '1px solid #d1d5db',
            background: '#fff', color: '#374151', fontWeight: 600, fontSize: 14, cursor: 'pointer',
          }}
        >
          إلغاء
        </button>
      </div>
    </div>
  );

  // ── Sessions list view ──
  return (
    <div style={{ direction: 'rtl' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 14 }}>
        <div style={{ fontSize: 12, color: '#64748b' }}>
          {sessions.length > 0 ? `${sessions.length} جلسة مسجلة` : 'لا توجد جلسات بعد'}
        </div>
        <button
          onClick={initForm}
          style={{
            padding: '8px 18px', borderRadius: 8, border: 'none',
            background: PRIMARY, color: '#fff', fontWeight: 700, fontSize: 13, cursor: 'pointer',
          }}
        >
          + تسجيل جلسة جديدة
        </button>
      </div>

      {loading ? (
        <div style={{ display: 'flex', justifyContent: 'center', padding: 40 }}><Spinner /></div>
      ) : sessions.length === 0 ? (
        <div style={{
          textAlign: 'center', padding: '48px 24px',
          background: '#f8fafc', borderRadius: 12, border: '1px dashed #d1d5db',
        }}>
          <div style={{ fontSize: 40, marginBottom: 10, opacity: 0.3 }}>📋</div>
          <div style={{ fontSize: 14, fontWeight: 700, color: '#64748b', marginBottom: 4 }}>لا توجد جلسات مسجلة</div>
          <div style={{ fontSize: 12, color: '#94a3b8' }}>اضغط على "تسجيل جلسة جديدة" لتسجيل أول جلسة</div>
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {sessions.map((ses, i) => {
            // [FIX-ATT-2] Backend returns snake_case; normalise to expected names.
            const presentCount = parseInt(ses.present_count ?? ses.presentCount ?? 0);
            const absentCount  = parseInt(ses.absent_count  ?? ses.absentCount  ?? 0);
            const total   = presentCount + absentCount || (ses.total_students || 1);
            const pct     = total > 0 ? Math.round((presentCount / total) * 100) : 0;
            const barColor = pct < 42 ? DANGER : pct < 70 ? WARN : SUCCESS;
            const typeMap  = { lecture: 'محاضرة', lab: 'معمل', tutorial: 'تمرين' };
            // backend sends session_type (snake_case); sessionType (camelCase) is the legacy shape
            const sType   = ses.session_type || ses.sessionType || 'lecture';
            const date     = ses.session_date || ses.sessionDate;
            const dateStr  = date ? new Date(date).toLocaleDateString('ar-EG', { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric' }) : '—';
            return (
              <div key={ses.id || i} style={{
                display: 'flex', alignItems: 'center', gap: 14,
                padding: '12px 16px', background: '#fff',
                border: '1px solid #e5e7eb', borderRadius: 10,
              }}>
                <div style={{
                  width: 40, height: 40, borderRadius: 10,
                  background: '#f1f5f9', display: 'flex', alignItems: 'center',
                  justifyContent: 'center', fontSize: 18, flexShrink: 0,
                }}>
                  {sType === 'lab' ? '🔬' : sType === 'tutorial' ? '✏️' : '📖'}
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
                    <span style={{ fontWeight: 700, fontSize: 13, color: '#111827' }}>{dateStr}</span>
                    <span style={{
                      padding: '1px 8px', borderRadius: 99, background: '#f1f5f9',
                      fontSize: 10, color: '#64748b', fontWeight: 600,
                    }}>
                      {typeMap[sType] || 'محاضرة'}
                    </span>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                    <div style={{ flex: 1, height: 6, background: '#e5e7eb', borderRadius: 99, overflow: 'hidden', maxWidth: 120 }}>
                      <div style={{ width: `${pct}%`, height: '100%', background: barColor, borderRadius: 99 }} />
                    </div>
                    <span style={{ fontSize: 11, fontWeight: 700, color: barColor }}>{pct}%</span>
                  </div>
                </div>
                <div style={{ display: 'flex', gap: 16, flexShrink: 0 }}>
                  <div style={{ textAlign: 'center' }}>
                    <div style={{ fontSize: 16, fontWeight: 800, color: SUCCESS }}>{presentCount}</div>
                    <div style={{ fontSize: 9, color: '#94a3b8' }}>حضور</div>
                  </div>
                  <div style={{ textAlign: 'center' }}>
                    <div style={{ fontSize: 16, fontWeight: 800, color: DANGER }}>{absentCount}</div>
                    <div style={{ fontSize: 9, color: '#94a3b8' }}>غياب</div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

// ─── Main Page ────────────────────────────────────────────────────────────────
export default function CourseRosterPage() {
  const { offeringId }  = useParams();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [tab, setTab]   = useState('grades');

  const reload = useCallback(async () => {
    try {
      const r = await doctorAPI.getCourseRoster(offeringId);
      setData(D(r));
    } catch { toast.error('فشل تحميل البيانات'); }
  }, [offeringId]);

  useEffect(() => {
    reload().finally(() => setLoading(false));
  }, [reload]);

  const roster     = data?.roster || [];
  const course     = data?.offering || data?.course || {};
  const semStatus  = (data?.offering?.semester_status || '').toLowerCase();
  const canEnter   = data?.canEnterGrades ?? ['active', 'grading'].includes(semStatus);
  const totalStu   = data?.totalStudents ?? roster.length;
  const gradeSumm  = data?.gradeSummary || {};

  const TABS = [
    { id: 'grades',     label: '📝 الدرجات'  },
    { id: 'attendance', label: '📋 الحضور'   },
  ];

  return (
    <AppLayout>
      <div style={{ direction: 'rtl', display: 'flex', flexDirection: 'column', gap: 14 }}>

        {/* ── Header ── */}
        <div style={{
          background: '#fff', borderRadius: 14, padding: '14px 18px',
          border: '1px solid #e5e7eb', boxShadow: '0 2px 8px rgba(0,0,0,.05)',
          display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 10,
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{
              width: 44, height: 44, borderRadius: 12,
              background: '#eff6ff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 22,
            }}>📚</div>
            <div>
              <div style={{ fontWeight: 800, fontSize: 16, color: PRIMARY }}>
                {course.name_ar || course.name || 'كشف الطلاب'}
              </div>
              <div style={{ fontSize: 12, color: '#64748b', marginTop: 1 }}>
                {course.code || '—'} · {course.semester_label || '—'}
              </div>
            </div>
          </div>
          <Link to="/doctor/courses" style={{ textDecoration: 'none' }}>
            <button style={{
              padding: '7px 16px', borderRadius: 8, border: '1px solid #e5e7eb',
              background: '#fff', color: '#374151', fontWeight: 600, fontSize: 13, cursor: 'pointer',
            }}>
              ← رجوع
            </button>
          </Link>
        </div>

        {/* ── Stats ── */}
        {loading ? null : (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(160px, 1fr))', gap: 10 }}>
            <StatCard icon="👥" label="الطلاب المسجلين"  value={totalStu} />
            <StatCard icon="✅" label="تم رصد درجاتهم"   value={`${gradeSumm.graded || 0}/${totalStu}`} color={SUCCESS} />
            <StatCard icon="📊" label="متوسط الدرجات"    value={gradeSumm.avg_grade ? `${gradeSumm.avg_grade}` : '—'} />
            <StatCard icon="🏆" label="أعلى درجة"        value={gradeSumm.max_grade ?? '—'} />
            <StatCard icon="📉" label="أدنى درجة"        value={gradeSumm.min_grade ?? '—'} />
          </div>
        )}

        {/* ── Tabs + Content ── */}
        <div style={{ background: '#fff', borderRadius: 14, border: '1px solid #e5e7eb', boxShadow: '0 2px 8px rgba(0,0,0,.05)', overflow: 'hidden' }}>
          {/* Tab bar */}
          <div style={{ display: 'flex', borderBottom: '2px solid #e5e7eb', background: '#f8fafc' }}>
            {TABS.map(t => (
              <button
                key={t.id}
                onClick={() => setTab(t.id)}
                style={{
                  flex: 1, padding: '12px 16px', border: 'none', cursor: 'pointer',
                  background: tab === t.id ? '#fff' : 'transparent',
                  borderBottom: tab === t.id ? `3px solid ${PRIMARY}` : '3px solid transparent',
                  fontWeight: tab === t.id ? 800 : 600,
                  fontSize: 13, color: tab === t.id ? PRIMARY : '#64748b',
                  transition: 'all .15s',
                }}
              >
                {t.label}
              </button>
            ))}
          </div>

          {/* Content */}
          <div style={{ padding: 16 }}>
            {loading ? (
              <div style={{ display: 'flex', justifyContent: 'center', padding: 60 }}><Spinner /></div>
            ) : tab === 'grades' ? (
              <GradesTab
                roster={roster}
                canEnter={canEnter}
                offeringId={offeringId}
                onReload={reload}
              />
            ) : (
              <AttendanceTab offeringId={offeringId} roster={roster} />
            )}
          </div>
        </div>

      </div>
    </AppLayout>
  );
}
