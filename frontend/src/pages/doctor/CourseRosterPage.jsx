import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { doctorAPI } from '../../services/api';
import { D } from '../../utils/helpers';
import AppLayout from '../../components/layout/AppLayout';
import { Card, Table, Th, Td, Button, Tabs, GradeBadge, Spinner, Input } from '../../components/ui';

export default function CourseRosterPage() {
  const { offeringId } = useParams();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [grades, setGrades] = useState({});
  const [saving, setSaving] = useState(null);
  const [tab, setTab] = useState('grades');

  const reload = async () => {
    const r = await doctorAPI.getCourseRoster(offeringId);
    const d = D(r);
    setData(d);
    const g = {};
    (d?.roster || d?.students || []).forEach(s => {
      const eid = s.enrollment_id || s.enrollmentId;
      g[eid] = {
        midterm_grade: s.midterm_grade ?? s.midtermGrade ?? '',
        coursework_grade: s.coursework_grade ?? s.courseworkGrade ?? '',
        practical_grade: s.practical_grade ?? s.practicalGrade ?? '',
        final_exam_grade: s.final_exam_grade ?? s.finalExamGrade ?? ''
      };
    });
    setGrades(g);
  };

  useEffect(() => {
    reload().finally(() => setLoading(false));
  }, [offeringId]);

  const semStatus = (data?.semester?.status || data?.semesterStatus || '').toLowerCase();
  const canEnterGrades = ['grading', 'active'].includes(semStatus) || !semStatus;

  const saveGrades = async eid => {
    if (!canEnterGrades) { toast.error('الدرجات تُدخل فقط في مرحلة النشاط أو الدرجات'); return; }
    const row = (data?.roster || data?.students || []).find(s => (s.enrollment_id || s.enrollmentId) === eid);
    if (row?.grade_locked) { toast.error('الدرجات مقفلة — تواصل مع المدير لفتحها'); return; }
    
    setSaving(eid);
    try {
      await doctorAPI.enterGrades(eid, grades[eid]);
      toast.success('تم حفظ الدرجات');
      reload();
    } catch (e) {
      toast.error(e.response?.data?.message || 'فشل الحفظ');
    } finally {
      setSaving(null);
    }
  };

  const GI = ({ eid, field }) => (
    <input
      type="number" min="0" max="100"
      value={grades[eid]?.[field] ?? ''}
      placeholder="—"
      onChange={e => setGrades(p => ({ ...p, [eid]: { ...p[eid], [field]: e.target.value === '' ? '' : Number(e.target.value) } }))}
      style={{
        width: '50px', padding: '4px 6px', border: '1px solid var(--color-gray-200)',
        borderRadius: '6px', fontSize: '12px', textAlign: 'center', fontFamily: 'var(--font-family)'
      }}
    />
  );

  const roster = data?.roster || data?.students || [];
  const course = data?.course || {};

  return (
    <AppLayout>
      <Card
        title={course.nameAr || course.name_ar || course.name || 'كشف الطلاب'}
        headerActions={
          <Link to="/doctor/courses" style={{ textDecoration: 'none' }}>
            <Button variant="ghost" size="sm">← رجوع</Button>
          </Link>
        }
      >
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '12px', marginBottom: '16px' }}>
          {[
            ['الكود', course.code || '—'],
            ['الطلاب المسجلين', data?.enrolledCount || data?.enrolled_count || 0],
            ['الفصل', data?.semesterName || data?.semester_name || '—']
          ].map(([l, v]) => (
            <div key={l} style={{ background: 'var(--color-gray-50)', border: '1px solid var(--color-gray-200)', borderRadius: '10px', padding: '10px', textAlign: 'center' }}>
              <div style={{ fontSize: '10px', color: 'var(--color-gray-500)', marginBottom: '2px' }}>{l}</div>
              <div style={{ fontSize: '14px', fontWeight: 700, color: 'var(--color-gray-800)' }}>{v}</div>
            </div>
          ))}
        </div>

        <Tabs
          tabs={[['grades', 'الدرجات'], ['attendance', 'الحضور']]}
          active={tab}
          onChange={setTab}
        />

        {loading ? <Spinner /> : tab === 'grades' ? (
          <Table>
            <thead>
              <tr>
                <Th>الطالب</Th>
                <Th>الكود</Th>
                <Th>منتصف<br /><small>/20</small></Th>
                <Th>أعمال<br /><small>/10</small></Th>
                <Th>عملي<br /><small>/10</small></Th>
                <Th>نهائي<br /><small>/60</small></Th>
                <Th>المجموع</Th>
                <Th>التقدير</Th>
                <Th>حفظ</Th>
              </tr>
            </thead>
            <tbody>
              {roster.map(s => {
                const eid = s.enrollment_id || s.enrollmentId;
                return (
                  <tr key={eid}>
                    <Td style={{ fontWeight: 600 }}>{s.studentName || s.student_name || s.full_name_ar || s.full_name_en || 'بدون اسم'}</Td>
                    <Td style={{ fontSize: '12px', color: 'var(--color-gray-500)' }}>{s.studentCode || s.student_code}</Td>
                    <Td><GI eid={eid} field="midterm_grade" /></Td>
                    <Td><GI eid={eid} field="coursework_grade" /></Td>
                    <Td><GI eid={eid} field="practical_grade" /></Td>
                    <Td><GI eid={eid} field="final_exam_grade" /></Td>
                    <Td style={{ fontWeight: 700, color: 'var(--color-primary)' }}>{s.total_grade ?? s.totalGrade ?? '—'}</Td>
                    <Td><GradeBadge grade={s.letter_grade || s.letterGrade} /></Td>
                    <Td>
                      <Button variant="success" size="sm" onClick={() => saveGrades(eid)} disabled={saving === eid}>
                        {saving === eid ? '…' : 'حفظ'}
                      </Button>
                    </Td>
                  </tr>
                );
              })}
              {roster.length === 0 && (
                <tr>
                  <Td colSpan={9} style={{ textAlign: 'center', padding: '32px', color: 'var(--color-gray-400)' }}>لا يوجد طلاب</Td>
                </tr>
              )}
            </tbody>
          </Table>
        ) : (
          <AttendanceTab offeringId={offeringId} roster={roster} />
        )}
      </Card>
    </AppLayout>
  );
}

function AttendanceTab({ offeringId, roster }) {
  const [sessions, setSessions] = useState([]);
  const [loadingS, setLoadingS] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [sessionDate, setSessionDate] = useState(new Date().toISOString().slice(0, 10));
  const [sessionType, setSessionType] = useState('lecture');
  const [presence, setPresence] = useState({});
  const [saving, setSaving] = useState(false);

  const loadSessions = () => {
    setLoadingS(true);
    doctorAPI.getAttendanceReport(offeringId)
      .then(r => { const d = D(r); setSessions(d?.sessions || d || []); })
      .catch(() => {})
      .finally(() => setLoadingS(false));
  };

  useEffect(() => { loadSessions(); }, [offeringId]);

  const initPresence = () => {
    const p = {};
    roster.forEach(s => { p[s.enrollment_id || s.enrollmentId] = true; });
    setPresence(p);
    setShowForm(true);
  };

  const submitAttendance = async () => {
    setSaving(true);
    const records = roster.map(s => ({
      enrollmentId: s.enrollment_id || s.enrollmentId,
      isPresent: presence[s.enrollment_id || s.enrollmentId] !== false,
    }));
    try {
      await doctorAPI.recordAttendance(offeringId, { sessionDate, sessionType, attendanceRecords: records });
      toast.success('تم تسجيل الحضور');
      setShowForm(false);
      loadSessions();
    } catch (e) {
      toast.error(e.response?.data?.message || 'فشل تسجيل الحضور');
    } finally {
      setSaving(false);
    }
  };

  if (showForm) return (
    <div>
      <div style={{ display: 'flex', gap: '12px', alignItems: 'flex-end', marginBottom: '16px' }}>
        <div style={{ flex: 1 }}>
          <label style={{ display: 'block', fontSize: '12px', fontWeight: 700, color: 'var(--color-gray-800)', marginBottom: '5px' }}>تاريخ الجلسة</label>
          <Input type="date" value={sessionDate} onChange={e => setSessionDate(e.target.value)} />
        </div>
        <div style={{ flex: 1 }}>
          <label style={{ display: 'block', fontSize: '12px', fontWeight: 700, color: 'var(--color-gray-800)', marginBottom: '5px' }}>نوع الجلسة</label>
          <select
            style={{ width: '100%', padding: '9px 12px', border: '1.5px solid var(--color-gray-200)', borderRadius: 'var(--radius-md)', fontFamily: 'var(--font-family)', fontSize: 'var(--font-size-base)', outline: 'none', background: 'var(--color-white)' }}
            value={sessionType} onChange={e => setSessionType(e.target.value)}
          >
            <option value="lecture">محاضرة</option>
            <option value="lab">معمل</option>
            <option value="tutorial">تمرين</option>
          </select>
        </div>
        <Button variant="success" size="sm" onClick={() => { const p = {}; roster.forEach(s => { p[s.enrollment_id || s.enrollmentId] = true; }); setPresence(p); }}>حضور الكل</Button>
        <Button variant="danger" size="sm" onClick={() => { const p = {}; roster.forEach(s => { p[s.enrollment_id || s.enrollmentId] = false; }); setPresence(p); }}>غياب الكل</Button>
      </div>
      
      <Table>
        <thead>
          <tr>
            <Th>الطالب</Th>
            <Th>الكود</Th>
            <Th style={{ textAlign: 'center' }}>حضور</Th>
          </tr>
        </thead>
        <tbody>
          {roster.map(s => {
            const eid = s.enrollment_id || s.enrollmentId;
            return (
              <tr key={eid}>
                <Td style={{ fontWeight: 600 }}>{s.studentName || s.student_name || s.full_name_ar || s.full_name_en || 'بدون اسم'}</Td>
                <Td style={{ fontSize: '12px', color: 'var(--color-gray-500)' }}>{s.studentCode || s.student_code}</Td>
                <Td style={{ textAlign: 'center' }}>
                  <Button
                    size="sm"
                    variant={presence[eid] === false ? 'danger' : 'success'}
                    onClick={() => setPresence(p => ({ ...p, [eid]: !p[eid] }))}
                  >
                    {presence[eid] === false ? 'غائب ✗' : 'حاضر ✓'}
                  </Button>
                </Td>
              </tr>
            );
          })}
        </tbody>
      </Table>
      
      <div style={{ display: 'flex', gap: '10px', marginTop: '16px' }}>
        <Button variant="success" onClick={submitAttendance} disabled={saving}>
          {saving ? 'جاري الحفظ…' : 'حفظ الحضور'}
        </Button>
        <Button variant="ghost" onClick={() => setShowForm(false)}>إلغاء</Button>
      </div>
    </div>
  );

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
        <Button size="sm" onClick={initPresence}>+ تسجيل جلسة حضور</Button>
        <div style={{ fontSize: '13px', color: 'var(--color-gray-500)' }}>{sessions.length} جلسة مسجلة</div>
      </div>
      
      {loadingS ? <Spinner /> : sessions.length > 0 ? (
        <Table>
          <thead>
            <tr>
              <Th>التاريخ</Th>
              <Th>النوع</Th>
              <Th>الحضور</Th>
              <Th>الغياب</Th>
              <Th>نسبة الحضور</Th>
            </tr>
          </thead>
          <tbody>
            {sessions.map((ses, i) => {
              const total = (ses.presentCount || 0) + (ses.absentCount || 0) || (ses.total || 1);
              const pct = total > 0 ? Math.round(((ses.presentCount || 0) / total) * 100) : 0;
              return (
                <tr key={ses.id || i}>
                  <Td>{ses.sessionDate || ses.session_date ? new Date(ses.sessionDate || ses.session_date).toLocaleDateString('ar-EG') : '—'}</Td>
                  <Td>{ses.sessionType || ses.session_type || 'محاضرة'}</Td>
                  <Td style={{ color: 'var(--color-success)', fontWeight: 600 }}>{ses.presentCount || ses.present_count || 0}</Td>
                  <Td style={{ color: 'var(--color-error)', fontWeight: 600 }}>{ses.absentCount || ses.absent_count || 0}</Td>
                  <Td>
                    <span style={{ fontWeight: 700, color: pct < 42 ? 'var(--color-error)' : 'var(--color-success)' }}>{pct}%</span>
                  </Td>
                </tr>
              );
            })}
          </tbody>
        </Table>
      ) : (
        <div style={{ textAlign: 'center', padding: '40px', color: 'var(--color-gray-400)' }}>لا توجد جلسات مسجلة بعد</div>
      )}
    </div>
  );
}
