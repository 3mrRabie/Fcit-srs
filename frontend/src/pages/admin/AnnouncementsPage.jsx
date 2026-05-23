import React, { useState, useEffect } from 'react';
import { toast } from 'react-hot-toast';
import { adminAPI } from '../../services/api';
import { D } from '../../utils/helpers';
import AppLayout from '../../components/layout/AppLayout';
import { Card, Badge, Button, Spinner } from '../../components/ui';

export default function AnnouncementsPage() {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showAdd, setShowAdd] = useState(false);
  const [form, setForm] = useState({ title: '', body: '', targetRole: 'all', isPinned: false });

  const load = () => {
    setLoading(true);
    adminAPI.getAnnouncements()
      .then(r => setItems(D(r) || []))
      .catch(() => {})
      .finally(() => setLoading(false));
  };
  
  useEffect(() => { load(); }, []);

  const create = async e => {
    e.preventDefault();
    try {
      await adminAPI.createAnnouncement(form);
      toast.success('تم نشر الإعلان');
      setShowAdd(false);
      setForm({ title: '', body: '', targetRole: 'all', isPinned: false });
      load();
    } catch {
      toast.error('فشل نشر الإعلان');
    }
  };

  const ROLE_AR = { all: 'الجميع', student: 'الطلاب', doctor: 'الدكاترة', admin: 'الإداريون' };

  return (
    <AppLayout>
      <Card
        title="الإعلانات"
        headerActions={
          <Button size="sm" onClick={() => setShowAdd(p => !p)}>
            {showAdd ? '✕ إلغاء' : '+ إضافة إعلان'}
          </Button>
        }
      >
        {showAdd && (
          <form onSubmit={create} style={{ background: 'var(--color-gray-50)', border: '1px solid var(--color-gray-200)', borderRadius: 'var(--radius-lg)', padding: '20px', marginBottom: '20px' }}>
            <div style={{ marginBottom: '14px' }}>
              <label style={{ display: 'block', fontSize: '12px', fontWeight: 700, color: 'var(--color-gray-800)', marginBottom: '6px' }}>العنوان</label>
              <input required style={{ width: '100%', padding: '9px 12px', border: '1.5px solid var(--color-gray-200)', borderRadius: 'var(--radius-md)', fontFamily: 'var(--font-family)', fontSize: 'var(--font-size-base)', outline: 'none' }} value={form.title} onChange={e => setForm(p => ({ ...p, title: e.target.value }))} />
            </div>
            <div style={{ marginBottom: '14px' }}>
              <label style={{ display: 'block', fontSize: '12px', fontWeight: 700, color: 'var(--color-gray-800)', marginBottom: '6px' }}>المحتوى</label>
              <textarea required rows={3} style={{ width: '100%', padding: '9px 12px', border: '1.5px solid var(--color-gray-200)', borderRadius: 'var(--radius-md)', fontFamily: 'var(--font-family)', fontSize: 'var(--font-size-base)', outline: 'none', resize: 'vertical' }} value={form.body} onChange={e => setForm(p => ({ ...p, body: e.target.value }))} />
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px', marginBottom: '14px' }}>
              <div>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: 700, color: 'var(--color-gray-800)', marginBottom: '6px' }}>المستهدف</label>
                <select style={{ width: '100%', padding: '9px 12px', border: '1.5px solid var(--color-gray-200)', borderRadius: 'var(--radius-md)', fontFamily: 'var(--font-family)', fontSize: 'var(--font-size-base)', outline: 'none', background: 'var(--color-white)' }} value={form.targetRole} onChange={e => setForm(p => ({ ...p, targetRole: e.target.value }))}>
                  <option value="all">الجميع</option>
                  <option value="student">الطلاب</option>
                  <option value="doctor">الدكاترة</option>
                  <option value="admin">الإداريون</option>
                </select>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', paddingTop: '24px' }}>
                <input type="checkbox" id="pin" checked={form.isPinned} onChange={e => setForm(p => ({ ...p, isPinned: e.target.checked }))} />
                <label htmlFor="pin" style={{ fontSize: '13px', color: 'var(--color-gray-800)', cursor: 'pointer' }}>تثبيت الإعلان</label>
              </div>
            </div>
            <div style={{ display: 'flex', gap: '10px' }}>
              <Button type="submit" variant="primary">نشر الإعلان</Button>
              <Button type="button" variant="ghost" onClick={() => setShowAdd(false)}>إلغاء</Button>
            </div>
          </form>
        )}

        {loading ? <Spinner /> : (
          <div>
            {items.map(a => (
              <div key={a.id} style={{ padding: '16px 0', borderBottom: '1px solid var(--color-gray-100)' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
                  <div style={{ display: 'flex', gap: '6px' }}>
                    {(a.isPinned || a.is_pinned) && <Badge variant="warning">📌 مثبت</Badge>}
                    <Badge variant="primary">{ROLE_AR[a.targetRole || a.target_role || 'all']}</Badge>
                  </div>
                  <div style={{ fontWeight: 700, fontSize: '14px', color: 'var(--color-gray-800)' }}>{a.title}</div>
                </div>
                <div style={{ fontSize: '13px', color: 'var(--color-gray-600)', lineHeight: 1.7 }}>{a.body}</div>
                <div style={{ fontSize: '11px', color: 'var(--color-gray-500)', marginTop: '6px' }}>
                  {a.createdAt || a.created_at ? new Date(a.createdAt || a.created_at).toLocaleDateString('ar-EG') : ''}
                </div>
              </div>
            ))}
            {items.length === 0 && (
              <div style={{ textAlign: 'center', padding: '40px', color: 'var(--color-gray-500)' }}>لا توجد إعلانات</div>
            )}
          </div>
        )}
      </Card>
    </AppLayout>
  );
}
