import React, { useState, useEffect } from 'react';
import { studentAPI } from '../../services/api';
import { D } from '../../utils/helpers';
import AppLayout from '../../components/layout/AppLayout';
import { Card, Badge, ProgressBar, Spinner } from '../../components/ui';
import { useBylaw } from '../../contexts/BylawContext';

export default function GraduationPage() {
  const [d, setD] = useState(null);
  const [loading, setLoading] = useState(true);
  const { bylaw } = useBylaw();

  useEffect(() => {
    studentAPI.getGraduationStatus()
      .then(r => {
        const raw = D(r);
        setD(raw?.eligibility || raw);
      })
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <AppLayout><Spinner /></AppLayout>;

  const earned = d?.credits_earned || d?.creditsEarned || d?.total_credits_passed || 0;
  const required = d?.credits_required || d?.creditsRequired || bylaw?.metadata?.total_credit_hours || 138;
  const passingCgpa = bylaw?.metadata?.passing_cgpa || 2.0;
  const isEligible = d?.isEligible || d?.is_eligible;

  const checks = [
    ['إجمالي الساعات المكتملة (' + earned + '/' + required + ')', d?.credits_met ?? d?.creditsComplete],
    ['شرط المعدل ≥ ' + passingCgpa.toFixed(1) + ' (' + Number(d?.cgpa || 0).toFixed(2) + ')', d?.cgpa_met ?? d?.gpaComplete],
    ['لا درجات F معلقة', d?.no_pending_f ?? d?.noPendingF ?? true],
    ['التدريب الميداني', d?.training_met ?? d?.trainingComplete],
    ['مشروع التخرج', d?.project_met ?? d?.projectComplete]
  ];

  return (
    <AppLayout>
      <Card
        title="حالة التخرج"
        headerActions={
          <Badge variant={isEligible ? 'success' : 'error'} size="lg">
            {isEligible ? '✅ مؤهل للتخرج' : '❌ غير مؤهل بعد'}
          </Badge>
        }
      >
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
          <div style={{ fontSize: '22px', fontWeight: 800, color: 'var(--color-primary)' }}>{earned}/{required}</div>
          <div style={{ fontSize: '13px', color: 'var(--color-gray-500)' }}>تقدم التخرج</div>
        </div>
        
        <ProgressBar value={earned} max={required} className={styles.progressBar} />

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px', marginTop: '20px' }}>
          {checks.map(([l, ok]) => (
            <div key={l} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '9px 0', borderBottom: '1px solid var(--color-gray-100)' }}>
              <Badge variant={ok ? 'success' : 'error'}>{ok ? 'مكتمل' : 'غير مكتمل'}</Badge>
              <div style={{ fontSize: '13px', fontWeight: 500, color: 'var(--color-gray-800)' }}>{l}</div>
            </div>
          ))}
        </div>

        {(d?.honorsEligible || d?.honors_eligible) && (
          <div style={{ marginTop: '16px', background: 'linear-gradient(135deg, #fef3c7, #fffbeb)', border: '1px solid #fde68a', borderRadius: '12px', padding: '14px', textAlign: 'center' }}>
            <div style={{ fontSize: '16px', fontWeight: 800, color: '#92400e' }}>🏆 مؤهل للتخرج بمرتبة الشرف</div>
          </div>
        )}
      </Card>
    </AppLayout>
  );
}

// Inline styles for this specific component (using CSS-in-JS since it's simple)
const styles = {
  progressBar: `margin-bottom: 20px;`
};
