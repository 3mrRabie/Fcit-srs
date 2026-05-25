import React, { useState, useEffect, useMemo } from 'react';
import { Link, useSearchParams } from 'react-router-dom';
import { doctorAPI, sharedAPI } from '../../services/api';
import { D } from '../../utils/helpers';
import AppLayout from '../../components/layout/AppLayout';
import { Card, Button, Spinner, Badge } from '../../components/ui';
import { Search, Users, Calendar } from 'lucide-react';

export default function DoctorCoursesPage() {
  const [courses, setCourses] = useState([]);
  const [sems, setSems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchParams] = useSearchParams();
  const [searchQ, setSearchQ] = useState(searchParams.get('search') || '');

  // Read search param from URL when it changes
  useEffect(() => {
    const q = searchParams.get('search');
    if (q !== null) setSearchQ(q);
  }, [searchParams]);

  useEffect(() => {
    Promise.all([
      doctorAPI.getDashboard().catch(() => ({})),
      sharedAPI.getSemesters().catch(() => ({}))
    ]).then(([dRes, sRes]) => {
      setCourses(D(dRes)?.courses || []);
      setSems(D(sRes) || []);
    }).finally(() => setLoading(false));
  }, []);

  // Filter and group courses by semester
  const filteredAndGrouped = useMemo(() => {
    const q = searchQ.toLowerCase().trim();
    const filtered = courses.filter(c => {
      if (!q) return true;
      return (c.courseName || c.course_name || '').toLowerCase().includes(q) ||
             (c.courseCode || c.course_code || '').toLowerCase().includes(q);
    });

    const groups = {};
    filtered.forEach(c => {
      const semId = c.semester_id || c.semesterId;
      const sem = sems.find(s => s.id === semId);
      const semLabel = sem ? (sem.label || `${sem.semester_type || ''} ${sem.year_label || ''}`) : 'فصل دراسي غير محدد';
      
      if (!groups[semLabel]) groups[semLabel] = [];
      groups[semLabel].push(c);
    });
    return groups;
  }, [courses, sems, searchQ]);

  return (
    <AppLayout>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '10px' }}>
        <h1 style={{ fontSize: '24px', fontWeight: 800, color: 'var(--color-primary-dark)', margin: 0 }}>مقرراتي</h1>
        
        <div style={{ position: 'relative', width: '300px', maxWidth: '100%' }}>
          <input
            type="text"
            placeholder="ابحث في مقرراتك..."
            value={searchQ}
            onChange={e => setSearchQ(e.target.value)}
            style={{
              width: '100%', padding: '10px 14px 10px 36px', borderRadius: 'var(--radius-lg)',
              border: '1px solid var(--color-gray-200)', fontSize: '14px', outline: 'none'
            }}
          />
          <Search size={16} color="var(--color-gray-400)" style={{ position: 'absolute', left: '12px', top: '12px' }} />
        </div>
      </div>

      {loading ? <Spinner /> : Object.keys(filteredAndGrouped).length === 0 ? (
        <Card>
          <div style={{ textAlign: 'center', padding: '48px 24px', color: 'var(--color-gray-400)' }}>
            <div style={{ fontSize: '48px', marginBottom: '16px', opacity: 0.5 }}>📚</div>
            <div style={{ fontSize: '18px', fontWeight: 700, color: 'var(--color-gray-600)', marginBottom: '8px' }}>لا توجد مقررات</div>
            <div style={{ fontSize: '14px' }}>لم يتم العثور على مقررات مسندة إليك مطابقة للبحث.</div>
          </div>
        </Card>
      ) : (
        Object.entries(filteredAndGrouped).map(([semLabel, semCourses]) => (
          <div key={semLabel} style={{ marginBottom: '24px' }}>
            <h2 style={{ fontSize: '16px', fontWeight: 800, color: 'var(--color-primary)', marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Calendar size={18} />
              {semLabel}
            </h2>
            
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '16px' }}>
              {semCourses.map(c => {
                const rosterId = c.offering_id || c.offeringId || c.id;
                return (
                  <Card key={rosterId} noPadding style={{ overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
                    <div style={{ background: 'var(--color-gray-50)', padding: '16px', borderBottom: '1px solid var(--color-gray-100)' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '8px' }}>
                        <div style={{ fontWeight: 800, fontSize: '14px', color: 'var(--color-primary-dark)' }}>{c.courseCode || c.course_code}</div>
                      </div>
                      <div style={{ fontWeight: 700, fontSize: '16px', color: 'var(--color-gray-900)' }}>{c.courseName || c.course_name}</div>
                    </div>
                    
                    <div style={{ padding: '16px', flex: 1 }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--color-gray-600)', fontSize: '13px', marginBottom: '8px' }}>
                        <Users size={14} />
                        <span>الطلاب المسجلين: <strong>{c.enrolledCount || c.enrolled_count || 0}</strong></span>
                      </div>
                      <div style={{ fontSize: '13px', color: 'var(--color-gray-500)' }}>
                        المستوى / الفرقة: <strong>{c.level_label || c.level || 'غير محدد'}</strong>
                      </div>
                    </div>
                    
                    <div style={{ padding: '12px 16px', background: 'var(--color-white)', borderTop: '1px solid var(--color-gray-100)' }}>
                      <Link to={`/doctor/courses/${rosterId}`} style={{ textDecoration: 'none', display: 'block' }}>
                        <Button style={{ width: '100%', justifyContent: 'center' }}>إدارة الطلاب والدرجات</Button>
                      </Link>
                    </div>
                  </Card>
                );
              })}
            </div>
          </div>
        ))
      )}
    </AppLayout>
  );
}
