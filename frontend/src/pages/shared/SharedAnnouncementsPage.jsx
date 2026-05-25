import React, { useState, useEffect } from 'react';
import { sharedAPI } from '../../services/api';
import { D } from '../../utils/helpers';
import AppLayout from '../../components/layout/AppLayout';
import { Card, Badge, Spinner } from '../../components/ui';

const ROLE_LABELS = {
  all: 'الجميع',
  student: 'الطلاب',
  doctor: 'الدكاترة',
  admin: 'الإداريون',
};

function timeAgo(dateStr) {
  if (!dateStr) return '';
  const diff = Date.now() - new Date(dateStr).getTime();
  const mins  = Math.floor(diff / 60000);
  const hours = Math.floor(diff / 3600000);
  const days  = Math.floor(diff / 86400000);
  if (mins  < 2)  return 'الآن';
  if (mins  < 60) return `منذ ${mins} دقيقة`;
  if (hours < 24) return `منذ ${hours} ساعة`;
  return `منذ ${days} يوم`;
}

export default function SharedAnnouncementsPage() {
  const [items, setItems]     = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError]     = useState(null);

  useEffect(() => {
    setLoading(true);
    sharedAPI.getAnnouncements()
      .then(r => {
        const data = D(r);
        setItems(Array.isArray(data) ? data : []);
      })
      .catch(() => setError('فشل تحميل الإعلانات. تحقق من الاتصال بالخادم.'))
      .finally(() => setLoading(false));
  }, []);

  return (
    <AppLayout>
      <Card title="الإعلانات">
        {loading ? (
          <div style={{ padding: 40, textAlign: 'center' }}><Spinner /></div>
        ) : error ? (
          <div style={{ padding: 24, textAlign: 'center', color: 'var(--color-red-600)' }}>{error}</div>
        ) : items.length === 0 ? (
          <div style={{
            padding: '48px 24px', textAlign: 'center',
            color: 'var(--color-gray-400)',
          }}>
            <div style={{ fontSize: 40, marginBottom: 12 }}>📢</div>
            <p style={{ fontSize: 15, fontWeight: 600 }}>لا توجد إعلانات حالياً</p>
            <p style={{ fontSize: 13, marginTop: 4 }}>ستظهر هنا الإعلانات الموجهة إليك</p>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {items.map(ann => (
              <div key={ann.id} style={{
                border: ann.is_pinned
                  ? '1.5px solid var(--color-primary-300, #93c5fd)'
                  : '1px solid var(--color-gray-200)',
                borderRadius: 'var(--radius-lg)',
                padding: '16px 20px',
                background: ann.is_pinned ? 'var(--color-primary-50, #eff6ff)' : 'var(--surface-card)',
                direction: 'rtl',
              }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 10, flexWrap: 'wrap', marginBottom: 8 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8, flexWrap: 'wrap' }}>
                    {ann.is_pinned && (
                      <span style={{
                        fontSize: 11, fontWeight: 700, color: '#1d4ed8',
                        background: '#dbeafe', borderRadius: 20, padding: '2px 10px',
                      }}>📌 مثبت</span>
                    )}
                    <span style={{ fontSize: 16, fontWeight: 800, color: 'var(--color-gray-900)' }}>
                      {ann.title}
                    </span>
                  </div>
                  <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                    {ann.target_role && (
                      <Badge variant="info" size="sm">
                        {ROLE_LABELS[ann.target_role] || ann.target_role}
                      </Badge>
                    )}
                    <span style={{ fontSize: 11, color: 'var(--color-gray-400)', whiteSpace: 'nowrap' }}>
                      {timeAgo(ann.created_at)}
                    </span>
                  </div>
                </div>

                <p style={{
                  fontSize: 14, color: 'var(--color-gray-700)',
                  lineHeight: 1.7, margin: 0, whiteSpace: 'pre-wrap',
                }}>
                  {ann.body}
                </p>

                {ann.created_by_name && (
                  <div style={{ marginTop: 10, fontSize: 12, color: 'var(--color-gray-400)' }}>
                    بواسطة: {ann.created_by_name}
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </Card>
    </AppLayout>
  );
}
