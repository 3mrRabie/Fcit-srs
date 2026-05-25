import React, { useState, useEffect, useMemo } from 'react';
import { Link } from 'react-router-dom';
import { doctorAPI, sharedAPI } from '../../services/api';
import { D } from '../../utils/helpers';
import AppLayout from '../../components/layout/AppLayout';
import { Spinner } from '../../components/ui';
import { BookOpen, Users, Edit3, Calendar, ChevronLeft } from 'lucide-react';

const PRIMARY = '#1b4f9e';
const SUCCESS = '#16a34a';
const WARN    = '#d97706';

function StatCard({ label, value, icon, bg, color }) {
  return (
    <div style={{
      background: '#fff', borderRadius: 16, padding: '18px 20px',
      display: 'flex', alignItems: 'center', gap: 16,
      border: '1px solid #e5e7eb', boxShadow: '0 2px 8px rgba(0,0,0,.05)',
      direction: 'rtl',
    }}>
      <div style={{
        width: 50, height: 50, borderRadius: 14,
        background: bg, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
      }}>
        {icon}
      </div>
      <div>
        <div style={{ fontSize: 11, color: '#64748b', marginBottom: 3 }}>{label}</div>
        <div style={{ fontWeight: 800, fontSize: 22, color: color || '#1e293b' }}>{value}</div>
      </div>
    </div>
  );
}

const SEMESTER_TYPE_AR = { fall: 'الترم الأول', spring: 'الترم الثاني', summer: 'الترم الصيفي' };

export default function DoctorDashboard() {
  const [courses, setCourses] = useState([]);
  const [stats,   setStats]   = useState(null);
  const [sems,    setSems]    = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      doctorAPI.getDashboard().catch(() => ({})),
      doctorAPI.getMyCourses().catch(() => ({})),
      sharedAPI.getSemesters().catch(() => ({})),
    ]).then(([dashRes, coursesRes, semsRes]) => {
      const d = D(dashRes) || {};
      setStats({
        totalCourses:  d.totalCourses || 0,
        totalStudents: d.totalStudents || 0,
        pendingGrades: d.pendingGrades || d.pendingGradeCount || 0,
      });
      const raw = D(coursesRes) || [];
      setCourses(Array.isArray(raw) ? raw : []);
      setSems(D(semsRes) || []);
    }).finally(() => setLoading(false));
  }, []);

  // Group courses by semester — only active/registration/grading semesters, Arabic labels
  const grouped = useMemo(() => {
    const ACTIVE_STATUSES = ['active', 'registration', 'grading'];
    const groups = {};
    courses.forEach(c => {
      const semId  = c.semester_id || c.semesterId;
      const sem    = sems.find(s => s.id === semId);
      const status = c.semester_status || sem?.status || '';

      // Skip completed/closed semesters
      if (!ACTIVE_STATUSES.includes(status)) return;

      // Prefer the Arabic label already computed by the backend (c.semester),
      // fall back to the SEMESTER_TYPE_AR map, then the raw DB label.
      const type  = c.semester_type || sem?.semester_type || '';
      const year  = c.year_label    || sem?.year_label    || '';
      const label = c.semester
        || (type && year ? `${SEMESTER_TYPE_AR[type] || type} ${year}` : null)
        || sem?.label
        || 'فصل غير محدد';

      const startDate = sem?.start_date || '';
      if (!groups[label]) groups[label] = { courses: [], status, startDate };
      groups[label].courses.push(c);
    });

    // Sort: registration → active → grading
    const ORDER = { registration: 0, active: 1, grading: 2 };
    return Object.entries(groups).sort(([,a], [,b]) => {
      const ao = ORDER[a.status] ?? 99;
      const bo = ORDER[b.status] ?? 99;
      if (ao !== bo) return ao - bo;
      return b.startDate.localeCompare(a.startDate);
    });
  }, [courses, sems]);

  const semesterBadge = (status) => {
    const map = {
      active:       { label: 'نشط',    bg: '#dcfce7', color: SUCCESS },
      registration: { label: 'تسجيل',  bg: '#dbeafe', color: '#2563eb' },
      grading:      { label: 'درجات',  bg: '#fef3c7', color: WARN },
      closed:       { label: 'مغلق',   bg: '#f1f5f9', color: '#6b7280' },
    };
    const s = map[status] || { label: '—', bg: '#f1f5f9', color: '#94a3b8' };
    return (
      <span style={{
        padding: '3px 10px', borderRadius: 99, background: s.bg,
        color: s.color, fontWeight: 700, fontSize: 11,
      }}>{s.label}</span>
    );
  };

  if (loading) return <AppLayout><div style={{ display: 'flex', justifyContent: 'center', padding: 80 }}><Spinner /></div></AppLayout>;

  return (
    <AppLayout>
      <div style={{ direction: 'rtl', display: 'flex', flexDirection: 'column', gap: 20 }}>

        {/* ── Stat cards ───────────────────────────────────────── */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(190px, 1fr))', gap: 14 }}>
          <StatCard
            label="مقرراتي"
            value={stats?.totalCourses ?? '—'}
            icon={<BookOpen size={24} color={PRIMARY} />}
            bg="#eff6ff"
            color={PRIMARY}
          />
          <StatCard
            label="إجمالي الطلاب"
            value={stats?.totalStudents ?? '—'}
            icon={<Users size={24} color={SUCCESS} />}
            bg="#f0fdf4"
            color={SUCCESS}
          />
          <StatCard
            label="درجات منتظرة"
            value={stats?.pendingGrades ?? '—'}
            icon={<Edit3 size={24} color={WARN} />}
            bg="#fefce8"
            color={WARN}
          />
        </div>

        {/* ── Courses grouped by semester ────────────────────── */}
        {grouped.length === 0 ? (
          <div style={{
            textAlign: 'center', padding: '60px 24px', background: '#fff',
            borderRadius: 16, border: '1px dashed #d1d5db',
          }}>
            <div style={{ fontSize: 48, opacity: 0.2, marginBottom: 12 }}>📚</div>
            <div style={{ fontSize: 16, fontWeight: 700, color: '#64748b' }}>لا توجد مقررات</div>
          </div>
        ) : (
          grouped.map(([semLabel, { courses: semCourses, status }]) => (
            <div key={semLabel} style={{
              background: '#fff', borderRadius: 16,
              border: '1px solid #e5e7eb', overflow: 'hidden',
              boxShadow: '0 2px 8px rgba(0,0,0,.05)',
            }}>
              {/* Semester header */}
              <div style={{
                display: 'flex', alignItems: 'center', gap: 10,
                padding: '14px 18px', borderBottom: '1px solid #e5e7eb',
                background: '#f8fafc',
              }}>
                <Calendar size={16} color={PRIMARY} />
                <span style={{ fontWeight: 800, fontSize: 15, color: PRIMARY }}>{semLabel}</span>
                {semesterBadge(status)}
                <span style={{ marginRight: 'auto', fontSize: 12, color: '#94a3b8' }}>
                  {semCourses.length} {semCourses.length === 1 ? 'مقرر' : 'مقررات'} ·{' '}
                  {semCourses.reduce((s, c) => s + (parseInt(c.enrolled_count || c.enrolledCount) || 0), 0)} طالب
                </span>
              </div>

              {/* Table */}
              <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
                <thead>
                  <tr style={{ background: '#f8fafc' }}>
                    {['المقرر', 'الكود', 'المستوى', 'الطلاب', 'الإجراء'].map(h => (
                      <th key={h} style={{
                        padding: '10px 16px', textAlign: 'right',
                        fontWeight: 700, fontSize: 11, color: '#64748b',
                        borderBottom: '1px solid #e5e7eb',
                      }}>{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {semCourses.map((c, idx) => {
                    const rid      = c.offering_id || c.offeringId || c.id;
                    const enrolled = parseInt(c.enrolled_count || c.enrolledCount) || 0;
                    const capacity = parseInt(c.capacity) || 0;
                    const name     = c.course_name_ar || c.course_name_en || c.courseName || c.course_name || '—';
                    const code     = c.course_code || c.courseCode || '—';
                    const level    = c.level_label || c.level || '—';
                    const fillPct  = capacity > 0 ? Math.min(Math.round(enrolled / capacity * 100), 100) : 0;
                    return (
                      <tr key={rid} style={{ background: idx % 2 === 0 ? '#fff' : '#fafafa', borderBottom: '1px solid #f1f5f9' }}>
                        <td style={{ padding: '12px 16px', fontWeight: 600, color: '#111827' }}>{name}</td>
                        <td style={{ padding: '12px 16px' }}>
                          <span style={{
                            padding: '2px 9px', borderRadius: 6,
                            background: '#eff6ff', color: PRIMARY, fontWeight: 700, fontSize: 11,
                          }}>{code}</span>
                        </td>
                        <td style={{ padding: '12px 16px', fontSize: 12, color: '#6b7280' }}>{level}</td>
                        <td style={{ padding: '12px 16px', minWidth: 120 }}>
                          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                            <div style={{ flex: 1, height: 5, background: '#e5e7eb', borderRadius: 99, overflow: 'hidden', maxWidth: 80 }}>
                              <div style={{
                                width: `${fillPct}%`, height: '100%', borderRadius: 99,
                                background: fillPct > 85 ? '#ef4444' : fillPct > 60 ? '#f97316' : PRIMARY,
                              }} />
                            </div>
                            <span style={{ fontWeight: 700, fontSize: 12, color: '#374151' }}>
                              {enrolled}{capacity > 0 && <span style={{ color: '#94a3b8', fontWeight: 400 }}>/{capacity}</span>}
                            </span>
                          </div>
                        </td>
                        <td style={{ padding: '12px 16px' }}>
                          <Link to={`/doctor/courses/${rid}`} style={{ textDecoration: 'none' }}>
                            <button style={{
                              display: 'flex', alignItems: 'center', gap: 6,
                              padding: '7px 14px', borderRadius: 8, border: 'none',
                              background: PRIMARY, color: '#fff',
                              fontWeight: 700, fontSize: 12, cursor: 'pointer',
                            }}>
                              عرض الطلاب <ChevronLeft size={13} />
                            </button>
                          </Link>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          ))
        )}
      </div>
    </AppLayout>
  );
}
